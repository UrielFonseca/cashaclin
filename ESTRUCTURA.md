# Arquitectura y Flujo de Datos - Casha Clin Pro

Este documento proporciona una visión técnica detallada del funcionamiento interno del sistema Casha Clin Pro.

## 1. Arquitectura de Capas
El proyecto utiliza una arquitectura de **Separación de Responsabilidades** para facilitar el mantenimiento y la escalabilidad:

*   **Capa de Presentación (UI)**: Desarrollada en Flutter, utiliza widgets responsivos que se adaptan a la resolución del dispositivo (Móvil/Web).
*   **Capa de Modelos**: Define las estructuras de datos (Product, CartItem, Sale) garantizando el tipado fuerte en toda la aplicación.
*   **Capa de Repositorios**: Actúa como el único punto de acceso a los datos para la interfaz de usuario, abstrayendo la lógica de las peticiones HTTP.
*   **Capa de Servicios (API/Auth)**: Gestiona la comunicación de bajo nivel con el servidor Node.js y la persistencia de la sesión mediante JWT.
*   **Capa de Persistencia Local**: Implementación de SQLite para el almacenamiento de comprobantes de transacciones en dispositivos móviles.

## 2. Flujos Principales del Sistema

### Proceso de Autenticación (JWT)
1. El usuario ingresa sus credenciales en `login.dart`.
2. `AuthService` envía una petición POST al servidor.
3. El servidor valida en MongoDB y devuelve un token firmado (JWT) con el rol del usuario.
4. Flutter almacena el token en `SharedPreferences` y protege las rutas según el rol (Admin/Customer).

### Ciclo de Vida de un Pedido Especial
1. **Solicitud**: El cliente completa el formulario en `custom_order.dart` seleccionando una fecha mediante `TableCalendar`. El sistema inyecta automáticamente el email del usuario desde el token JWT.
2. **Recepción**: El pedido llega al servidor con estatus "Esperando aprobación".
3. **Negociación Administrativa**: El administrador visualiza la solicitud en `sales.dart`, asigna un monto total y añade un mensaje técnico. El estatus cambia a "Cotizado".
4. **Cierre de Venta**: El cliente consulta su panel de "Mis Pedidos", visualiza la respuesta y procede a la aceptación definitiva de la cotización.

## 3. Puntos Técnicos de Interés
*   **Generación de SKU**: Los códigos de producto se generan dinámicamente combinando el prefijo de la categoría (LIM, LAV, DES) con un folio incremental, asegurando la integridad del inventario.
*   **Interoperabilidad HTTP**: El `ApiService` gestiona automáticamente los encabezados de autorización y detecta el entorno (Localhost/Emulador) mediante la constante `kIsWeb`.
*   **Manejo de Stock Atómico**: El descuento de existencias se realiza mediante la operación `$inc` de MongoDB en el servidor, evitando condiciones de carrera si varios usuarios compran simultáneamente.
