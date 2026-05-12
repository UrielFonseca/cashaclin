# Documentación Técnica - Casha Clin Pro

Este documento describe la arquitectura, el flujo de datos y las funcionalidades principales del sistema de gestión y ventas de productos de limpieza "Casha Clin Pro".

## 1. Arquitectura General
El proyecto sigue una arquitectura de **Separación de Capas** (Frontend/Backend) utilizando el patrón **Repositorio**.

*   **Frontend**: Desarrollado en Flutter, compatible con Android, iOS y Navegadores Web (Chrome).
*   **Backend**: Servidor RESTful desarrollado en Node.js con Express, utilizando JWT (JSON Web Tokens) para la seguridad.
*   **Base de Datos**: MongoDB Atlas (Nube) para la persistencia de datos globales.
*   **Persistencia Local**: SQLite (exclusivo para móviles) utilizado para el almacenamiento de recibos de compra offline.

## 2. Flujo de Navegación y Roles
El sistema implementa un control de acceso basado en roles:

### Flujo de Autenticación
1. Al iniciar la aplicación, se verifica la existencia de un token JWT válido en las preferencias locales.
2. Si no existe sesión, el usuario es dirigido a la pantalla de **Login**.
3. El usuario puede registrarse como **Cliente** o **Administrador**.

### Portal del Administrador
Visible únicamente para usuarios con el rol `admin`.
*   **Dashboard**: Resumen ejecutivo con gráficas de ventas y alertas de inventario crítico.
*   **Gestión de Productos**: CRUD completo con generación automática de SKU basada en categorías.
*   **Inventario**: Ajuste rápido de existencias y control de stock.
*   **Clientes**: Base de datos de usuarios con consulta de historial de compras integrado.
*   **Ventas y Negociación**: Gestión de pedidos del carrito y solicitudes especiales.

### Portal del Cliente
*   **Catálogo**: Compra de productos con validación de stock en tiempo real.
*   **Carrito**: Procesamiento de pagos con cálculo automático de impuestos (IVA 16%).
*   **Pedido Especial**: Formulario para cotizaciones de mayoreo con selección de fecha mediante calendario interactivo.
*   **Mis Pedidos**: Seguimiento en tiempo real de solicitudes y chat de negociación con el administrador.

## 3. Componentes Técnicos de Interés

### Gestión de Pedidos Especiales (Negociación)
Es una de las funciones más robustas del sistema. Permite un flujo de comunicación bidireccional:
1. El cliente envía una solicitud con una descripción y fecha tentativa.
2. El administrador recibe la solicitud, asigna un precio cotizado y envía un mensaje de respuesta.
3. El cliente visualiza la cotización y puede aceptar el precio final o responder al mensaje.

### Automatización de SKU
Para mantener el orden logístico, el sistema genera automáticamente claves de producto únicas:
*   Prefijo basado en categoría (Ej: LIM para Limpieza, LAV para Lavado).
*   Sufijo numérico incremental basado en el conteo total de artículos.

### Seguridad JWT
Todas las peticiones a la API (excepto login y registro) requieren un encabezado de autorización. El servidor decodifica el token para identificar al usuario, lo que garantiza que los pedidos se asocien automáticamente a la cuenta correcta sin que el usuario tenga que ingresar sus datos repetidamente.
