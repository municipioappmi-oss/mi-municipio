# MI MUNICIPIO — Estado de integración

## Base técnica verificada

- Proyecto Supabase activo: `Mi Municipio Nuevo` (`weosqhohvstctwdnahac`).
- Aplicación React + Vite con Supabase Auth.
- Tablas existentes verificadas: perfiles, reportes, asignaciones, documentos, notas internas, historial de estados, mensajes entre dependencias, departamentos, categorías, avisos, encuestas, apariencia, auditoría y eventos de entrega de correo.
- Bucket privado existente: `report-files`.
- Se conserva el fondo institucional y el logotipo que ya venían en el paquete.

## Integraciones que ya contiene esta versión de código

- Seis perfiles de experiencia: visitante, ciudadano, dependencia, administrador municipal, administrador de delegación y administrador digital.
- Menús diferenciados por rol.
- Registro e inicio de sesión ciudadano.
- Alta de reportes con folio generado por PostgreSQL, ubicación GPS y evidencias.
- Consulta pública de folio mediante la función existente.
- Listados de reportes sujetos a RLS; personal de dependencia sólo obtiene los expedientes que la base le permite consultar.
- Actualización de estado, notas internas e historial visible para personal autorizado.
- Asignación a dependencias y flujo para compartir expedientes desde perfiles administradores.
- Carga y descarga de documentos desde el bucket privado existente.
- Directorio y alta de dependencias y categorías para perfiles administradores.
- Avisos, encuestas, estadísticas, exportación CSV, auditoría y eventos de correo.
- Pantalla de perfil con fotografía, nombre, teléfono, dirección y municipio; requiere la migración aditiva incluida.
- Pantalla de notificaciones; requiere la migración aditiva incluida.

## Migración nueva

`ACTUALIZACION_INTEGRAL_ADITIVA.sql` añade columnas de dirección/foto, tabla de notificaciones, bucket privado de fotos y políticas propias. No elimina tablas ni registros existentes. No se ha ejecutado en la base conectada: debe revisarse y probarse primero en un entorno de pruebas.

## Pendientes críticos antes de producción

1. Aplicar y probar la migración aditiva en staging; después decidir su promoción a producción.
2. Ajustar y verificar el aislamiento territorial del Administrador de Delegación. La política actual `is_admin()` permite a administradores municipales y de delegación consultar/modificar reportes de forma amplia; no se debe publicar hasta separar y probar esos alcances.
3. Revisar políticas públicas de avisos y seguimiento por folio para evitar exposición de datos personales.
4. Completar mapa cartográfico interactivo con marcadores y filtros; esta versión mantiene una lista de ubicaciones que abre Google Maps.
5. Completar notificaciones automáticas al ciudadano (la bandeja y tabla se preparan, pero falta automatizar su generación al cambiar estados o adjuntar documentos).
6. Completar creación/provisión administrativa segura de cuentas de personal y primer cambio obligatorio de credenciales.
7. Probar los seis perfiles con cuentas reales, especialmente RLS, asignación múltiple, carga/descarga y límites territoriales.
8. Revisar funciones `SECURITY DEFINER` y activar protección contra contraseñas filtradas después de analizar sus dependencias.
9. Instalar dependencias y ejecutar `npm run build` en un entorno con acceso al registro npm.
10. Subir al repositorio de GitHub y publicar en Netlify. Aún no se han realizado esas operaciones.

## Estado de validación

- La estructura real de Supabase se inspeccionó en modo lectura.
- No se ejecutó SQL en la base de producción.
- No se borraron ni alteraron registros.
- La instalación npm y la compilación no se pudieron completar en este entorno por problemas de red con el registro de paquetes. Por tanto, esta entrega no se declara lista para producción.
- El repositorio `municipioappmi-oss/mi-municipio` se encontró vacío al intentar leer su README; no se subió código.

## Mapa interactivo (actualización)
- Se incorporó un mapa Leaflet/OpenStreetMap en la captura de reportes y en la vista general de mapa.
- En la captura, el usuario puede tocar el mapa para colocar el marcador, buscar una dirección, usar la ubicación GPS y quitar el punto seleccionado. Las coordenadas se guardan en el reporte; se intenta completar la dirección mediante geocodificación inversa.
- En la vista general, los reportes con coordenadas se muestran como marcadores diferenciados por estado y con ficha emergente de folio, categoría, estado, municipio y dirección.
- Los reportes sin coordenadas continúan disponibles en las listas y bandejas; no se inventan ubicaciones.
- El mapa utiliza Leaflet y teselas de OpenStreetMap cargadas desde CDN; requiere conexión a internet. El GPS requiere permiso del dispositivo y HTTPS.
- Por instrucción expresa, esta actualización no agrega aislamiento territorial ni modifica políticas de acceso para ese fin. No se ejecutaron pruebas, compilación ni cambios en Supabase.

## Sincronización automática entre dispositivos (nueva integración)

- La aplicación utiliza el mismo proyecto central `Mi Municipio Nuevo` configurado en `.env`.
- Se agregó una suscripción Supabase Realtime para cambios en reportes, asignaciones, historial, archivos, avisos, notificaciones, categorías, dependencias y encuestas.
- Al recibir un cambio remoto, los paneles vuelven a consultar los datos permitidos por las políticas RLS vigentes; los cambios no dependen de la misma red Wi-Fi.
- Se muestra el estado de conexión en la cabecera de la aplicación.
- Se agregó `ACTIVAR_REALTIME.sql`, un script aditivo que incorpora a la publicación `supabase_realtime` las tablas existentes que correspondan. No elimina ni modifica datos, tablas, roles o políticas.
- **Pendiente de activación en el servidor:** ejecutar `ACTIVAR_REALTIME.sql` en el SQL Editor de `Mi Municipio Nuevo`. No se ejecutó desde esta integración y no se modificó la base de datos.
- La sincronización requiere internet y que Netlify esté configurado con `VITE_SUPABASE_URL` y `VITE_SUPABASE_PUBLISHABLE_KEY` del proyecto existente.