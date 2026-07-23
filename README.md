# Proyecto Final DevOps

API REST académica construida con Node.js, Express y PostgreSQL. El repositorio demuestra pruebas, contenedores, infraestructura como código, CI/CD, Kubernetes, seguridad automatizada, observabilidad y optimización básica de costos.

> Este proyecto prioriza simplicidad y claridad didáctica. No representa una plataforma preparada para producción.

## Arquitectura

```text
GitHub Actions
  ├── tests + npm audit + CodeQL
  ├── Docker build → GHCR
  ├── Terraform → AWS (EC2, RDS y EKS)
  ├── kubectl → API + HPA + Ingress
  └── OWASP ZAP

Cliente → Ingress → Service → Pods Express → PostgreSQL RDS
                              └→ /metrics → Prometheus → Grafana
```

EC2 conserva una forma directa de demostrar el despliegue inicial. EKS representa el destino final con Kubernetes. Ambos reutilizan la misma base RDS.

## Funcionalidad

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/` | Mensaje de bienvenida |
| GET | `/health` | Estado de la API y PostgreSQL |
| GET | `/metrics` | Métricas compatibles con Prometheus |
| GET | `/users` | Lista usuarios |
| POST | `/users` | Crea un usuario |
| DELETE | `/users/:id` | Elimina un usuario |

La tabla `users` se crea de forma idempotente mediante `npm run init-db`.

## Estructura

```text
app/                         API, Dockerfile y pruebas
database/                    esquema SQL inicial
infrastructure/
  kubernetes/                Deployment, Service, Ingress, Job y HPA
  monitoring/                Prometheus, Alertmanager, Grafana y dashboard
  terraform/                 módulos AWS: EC2, RDS, EKS, seguridad y FinOps
.github/workflows/
  pipeline.yml               CI/CD, SAST y DAST
  finops-schedule.yml        apagado y encendido programado de nodos
```

## Ejecución local

```bash
cp .env.example .env
docker compose up --build
```

Validación:

```bash
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/metrics
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Ada","email":"ada@example.com"}'
```

Sin Docker, desde `app/`:

```bash
npm ci
npm run init-db
npm test
npm start
```

## Docker

El Dockerfile multi-stage separa las dependencias de la imagen runtime. Usa Node.js 20 Alpine, instala únicamente dependencias de producción, copia sólo archivos necesarios y se ejecuta como usuario `node`.

```bash
docker build -t proyecto-final-devops:local app
```

El pipeline publica:

- `ghcr.io/martin-domenech/proyecto-final-devops:latest`
- `ghcr.io/martin-domenech/proyecto-final-devops:<commit-sha>`

## Terraform

La configuración usa la VPC por defecto para reducir complejidad y costo académico. Los módulos crean security groups, EC2 con `systemd`, PostgreSQL RDS privado, EKS con managed node group y un presupuesto mensual.

```bash
cd infrastructure/terraform
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan
```

El backend remoto usa un bucket S3 cuyo nombre se configura con el secreto `TF_STATE_BUCKET`. El bucket debe crearse una vez antes del primer pipeline. Para validar sin backend:

```bash
terraform init -backend=false
terraform validate
```

Los valores configurables están en `terraform.tfvars.example`. No se versionan archivos `.tfvars` reales ni estados.

## Kubernetes

Los manifiestos incluyen Namespace, configuración, Secret de ejemplo, Job de base de datos, Deployment, Service, Ingress y HPA de 1 a 5 réplicas.

Requisitos:

- Ingress NGINX Controller;
- Metrics Server para HPA;
- secreto `ghcr-pull` si GHCR es privado.

```bash
kubectl kustomize infrastructure/kubernetes
```

El pipeline reemplaza la imagen con el SHA, obtiene las credenciales RDS desde Terraform, crea los secretos y espera que finalice el Job antes de desplegar la API.

## Prometheus, Grafana y alertas

La API publica métricas estándar de Node.js en `/metrics`. Prometheus descubre los pods por annotations y conserva datos durante siete días.

Se incluyen:

- alerta de API no disponible;
- alerta de CPU elevada;
- Alertmanager para agrupar y enviar eventos;
- webhook académico que registra las notificaciones;
- datasource y dashboard Grafana provisionados;
- paneles de disponibilidad, CPU y memoria.

```bash
kubectl apply -f infrastructure/monitoring/monitoring.yml
kubectl -n monitoring create secret generic grafana-admin \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='CAMBIAR_ESTA_CLAVE'
kubectl -n monitoring port-forward service/grafana 3001:3000
```

Grafana: `http://localhost:3001`. Para inspeccionar alertas notificadas:

```bash
kubectl -n monitoring logs deployment/alert-webhook
```

## CI/CD y DevSecOps

`pipeline.yml` ejecuta:

1. instalación, tests y auditoría de dependencias;
2. validación Terraform y Kubernetes;
3. SAST con CodeQL;
4. build y push Docker a GHCR;
5. aprovisionamiento con Terraform;
6. despliegue en EKS;
7. DAST con OWASP ZAP;
8. publicación del reporte ZAP como artifact.

Secretos requeridos en GitHub:

| Secreto | Uso |
|---|---|
| `AWS_ACCESS_KEY_ID` | Autenticación AWS |
| `AWS_SECRET_ACCESS_KEY` | Autenticación AWS |
| `GHCR_USERNAME` | Pull de imagen desde EKS |
| `GHCR_TOKEN` | Token de lectura de GHCR |
| `GRAFANA_ADMIN_PASSWORD` | Acceso inicial a Grafana |
| `TF_STATE_BUCKET` | Bucket S3 único para el estado Terraform |

`GITHUB_TOKEN` publica la imagen. Las credenciales no se almacenan en los manifiestos finales.

## FinOps

- Instancias Graviton pequeñas.
- Un nodo EKS y una réplica por defecto.
- HPA y requests/limits.
- Retención Prometheus limitada.
- RDS de 20 GB.
- AWS Budget mensual de USD 10.
- Workflow que escala EKS a cero por la noche y lo restaura en horario de uso.

El workflow FinOps también admite ejecución manual `up` o `down`. Al finalizar la demostración se puede ejecutar `terraform destroy`.

## Validación y evidencias

```bash
cd app && npm test
docker compose config
terraform -chdir=infrastructure/terraform validate
kubectl kustomize infrastructure/kubernetes
```

Guardar en `docs/evidencias/` capturas o logs de:

- tests y pipeline en verde;
- imagen GHCR;
- outputs Terraform no sensibles;
- recursos Kubernetes;
- dashboard, targets y alertas;
- reporte OWASP ZAP.

## Entrega

El informe debe explicar arquitectura, pasos reproducibles, decisiones FinOps y evidencias. Exportarlo como `PF+APELLIDO.pdf` y publicar el enlace solicitado de Google Drive.
