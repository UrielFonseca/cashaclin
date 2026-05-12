# Documentación Técnica - Casha Clin Pro

Este documento detalla el funcionamiento, arquitectura y flujo de datos del sistema de gestión de productos de limpieza.

## 1. Arquitectura del Proyecto
El sistema utiliza una arquitectura de **Separación de Capas** (Decoupled Architecture):
*   **Frontend (Flutter)**: Interfaz de usuario responsiva compatible con Web y Móvil.
*   **Backend (Node.js)**: Servidor RESTful que gestiona la lógica de negocio y seguridad.
*   **Base de Datos (MongoDB Atlas)**: Almacenamiento persistente en la nube.
*   **Seguridad (JWT)**: Autenticación mediante tokens para proteger las rutas y datos.

## 2. Flujo de Datos y Roles
El sistema identifica al usuario mediante su correo y rol guardados en el token JWT:
1.  **Administrador**: Acceso total al Dashboard, Inventario, Gestión de Productos y Negociación de pedidos especiales.
2.  **Cliente**: Acceso al catálogo, carrito de compras y seguimiento automatizado de sus pedidos.

## 3. Pantallas Principales

### Panel Administrativo
*   **Dashboard**: Mide el rendimiento económico (Ingresos), nivel de inventario (Artículos) y alertas críticas (Stock Bajo).
*   **Productos**: CRUD centralizado con generación automática de SKU según la categoría.
*   **Ventas/Negociación**: Flujo de interacción directa con el cliente para pedidos de mayoreo.

### Portal del Cliente
*   **Catálogo**: Consulta y búsqueda de productos con validación de existencia.
*   **Pedido Especial**: Solicitud de cotizaciones mediante un calendario interactivo (`table_calendar`).
*   **Mis Pedidos**: Vista automatizada (vía JWT) del estado de solicitudes y respuestas del administrador.

## 4. Detalles de Implementación (Puntos de Interés)
*   **CORS y Headers**: Configurados en el `ApiService` para permitir la comunicación segura entre Chrome y el servidor.
*   **Persistencia Local**: SQLite integrado para el almacenamiento de recibos de compra en dispositivos móviles.
*   **Atomicidad**: Los descuentos de inventario se realizan en el servidor para evitar discrepancias de datos.
