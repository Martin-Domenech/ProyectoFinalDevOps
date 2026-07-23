output "budget_name" {
  description = "Nombre del presupuesto mensual."
  value       = aws_budgets_budget.monthly.name
}
