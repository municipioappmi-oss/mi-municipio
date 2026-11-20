# MI MUNICIPIO

Sistema Integral de Reportes Ciudadanos y Gestión Municipal para San Juan de los Lagos y Delegación de Mezquitic de la Magdalena, Jalisco.

## Arquitectura

- React 18 + Vite
- Supabase Auth, Postgres, Row Level Security y Storage
- PWA con manifest y service worker
- Despliegue previsto: Netlify

## Configuración local

1. Instala Node.js 20 o superior.
2. Copia `.env.example` a `.env.local`.
3. Configura `VITE_SUPABASE_URL` y `VITE_SUPABASE_PUBLISHABLE_KEY` del proyecto `Mi Municipio Nuevo`.
4. Ejecuta `npm install`.
5. Ejecuta `npm run dev`.
6. Para compilar: `npm run build`.

## Base de datos

El proyecto se conecta a la base existente `weosqhohvstctwdnahac`. No crear otra base para esta entrega.

`ACTUALIZACION_INTEGRAL_ADITIVA.sql` prepara foto de perfil, dirección y notificaciones. Revisar y ejecutar primero en un entorno de pruebas. No ejecutar en producción sin respaldo y validación de políticas RLS.

## Publicación en Netlify

- Build command: `npm run build`
- Publish directory: `dist`
- Variables: `VITE_SUPABASE_URL` y `VITE_SUPABASE_PUBLISHABLE_KEY`
- El sitio debe publicarse con HTTPS para GPS y PWA.

## Seguridad y alcance

Los permisos finales dependen de las políticas RLS de Supabase. No asignar roles editando datos desde el navegador. La separación territorial de Administrador de Delegación sigue pendiente de una migración de seguridad revisada y pruebas con cuentas reales. No publicar datos reales hasta completar esas pruebas.

Consulta `ESTADO_INTEGRACION.md` para conocer el alcance implementado y los pendientes de producción.

### Mapa interactivo
La captura de reportes y la vista Mapa utilizan Leaflet con OpenStreetMap. En la captura se puede seleccionar un punto tocando el mapa, buscar una dirección o utilizar GPS; la vista general presenta marcadores por estado y fichas emergentes. Requiere conexión a internet; la geolocalización requiere HTTPS y permiso del usuario.

Esta versión no agrega aislamiento territorial. No se ejecutaron pruebas ni se modificó la base de datos.