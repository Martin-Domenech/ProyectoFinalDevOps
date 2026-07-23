resource "aws_security_group" "eks_nodes" {
  name        = "eks-nodes-sg-${var.cluster_name}"
  description = "Security group para nodos EKS"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow intra-node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({ Name = "eks-nodes-${var.cluster_name}" }, var.tags)
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  dynamic "vpc_config" {
    for_each = [1]
    content {
      subnet_ids             = var.subnet_ids
      endpoint_public_access = true
    }
  }

  lifecycle {
    ignore_changes = [vpc_config[0].endpoint_public_access]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_attach]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ng-${var.cluster_name}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  launch_template {
    id      = aws_launch_template.node_launch_template.id
    version = "$Latest"
  }

  tags = merge({ Name = "eks-node-${var.cluster_name}" }, var.tags)

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_attach,
    aws_iam_role_policy_attachment.eks_cni_attach,
    aws_iam_role_policy_attachment.ecr_readonly_attach,
    aws_launch_template.node_launch_template,
    aws_security_group_rule.nodes_from_cluster,
    aws_security_group_rule.cluster_from_nodes
  ]
}

resource "aws_launch_template" "node_launch_template" {
  name_prefix   = "lt-${var.cluster_name}-"
  image_id      = null
  instance_type = var.node_instance_type

  vpc_security_group_ids = [aws_security_group.eks_nodes.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.node_disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nodes_from_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  description              = "Allow EKS control plane to reach kubelet and pods"
}

resource "aws_security_group_rule" "cluster_from_nodes" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_nodes.id
  description              = "Allow worker nodes to reach EKS API"
}
