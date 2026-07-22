# Proyecto Final DevOps - Etapa 1

Este repositorio contiene la etapa inicial de un proyecto DevOps guiado.

## Objetivo de la etapa 1
Crear una API Express mínima y pruebas automatizadas.

## Estructura del proyecto
- `AGENTS.md`: reglas y enfoque del proyecto guiado.
- `README.md`: documentación del proyecto.
- `.gitignore`: archivos ignorados.
- `app/`: carpeta de la aplicación Express mínima.
  - `package.json`: configuración del proyecto Node.js.
  - `package-lock.json`: dependencias bloqueadas.
  - `src/app.js`: definición de la aplicación Express.
  - `src/server.js`: arranque del servidor.
  - `tests/app.test.js`: pruebas automatizadas.
  - `Dockerfile`: definición de la imagen de contenedor.
  - `.dockerignore`: archivos ignorados durante la construcción de la imagen.

## Scripts disponibles (desde `app/`)
- `npm install`: instala dependencias.
- `npm test`: ejecuta las pruebas.
- `npm start`: arranca la aplicación.

## Rutas disponibles
- `GET /` → bienvenida.
- `GET /health` → estado de la app y salud de la base de datos.
- `POST /users` → crea un usuario.
- `GET /users` → lista usuarios.
- `DELETE /users/:id` → elimina un usuario.

## Uso
1. Ir a la carpeta de la app:
   ```bash
   cd app
   ```
2. Instalar dependencias:
   ```bash
   npm install
   ```
3. Ejecutar pruebas:
   ```bash
   npm test
   ```
4. Iniciar la app localmente:
   ```bash
   npm start
   ```

## Docker
1. Construir la imagen desde la carpeta `app`:
   ```bash
   cd app
   docker build -t proyecto-final-devops:local .
   ```
2. Ejecutar el contenedor y exponer el puerto 3000:
   ```bash
   docker run -d --name proyecto-final-devops-local -p 3000:3000 proyecto-final-devops:local
   ```
3. Probar los endpoints:
   ```bash
   curl http://localhost:3000/
   curl http://localhost:3000/health
   curl -X POST -H "Content-Type: application/json" -d '{"name":"Martín","email":"martin@example.com"}' http://localhost:3000/users
   curl http://localhost:3000/users
   curl -X DELETE http://localhost:3000/users/1
   ```
4. Detener el contenedor:
   ```bash
   docker stop proyecto-final-devops-local
   ```
5. Eliminar el contenedor:
   ```bash
   docker rm proyecto-final-devops-local
   ```

## GitHub Actions CI
Este repositorio incluye un workflow de GitHub Actions que valida el proyecto en cada push y pull request hacia la rama `main`.

### Qué hace
- descarga el repositorio
- instala Node.js 20
- restaura y cachea dependencias npm
- ejecuta `npm ci` en `app/`
- corre todos los tests con `npm test`
- construye la imagen Docker usando `app/Dockerfile`
- ejecuta `npm audit --audit-level=moderate`

### Cuándo se ejecuta
- `push` a `main`
- `pull_request` hacia `main`

### Qué valida
- que el código se pueda instalar correctamente
- que los tests pasen
- que la imagen pueda construirse con Docker
- que no haya vulnerabilidades de npm de nivel `moderate` o superior

### Cómo verlo en GitHub
En el repositorio, ir a la pestaña `Actions` y seleccionar el workflow `CI`.

### Qué significa un workflow fallido
- si falla la instalación, hay un problema con dependencias o `package-lock`
- si fallan tests, hay un error en la aplicación o en las pruebas
- si falla la construcción de Docker, el `Dockerfile` o la app no están configurados correctamente
- si falla `npm audit`, hay vulnerabilidades de nivel `moderate` o mayor en dependencias

## Comentario
Esta etapa se concentra en integrar CI; no se realiza publicación de imágenes ni despliegues automáticos.