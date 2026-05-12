# Documentación de Flujo y Arquitectura - Casha Clin Pro

Este documento detalla el funcionamiento técnico y el flujo de datos del ecosistema Casha Clin Pro, diseñado para la gestión y venta de productos de limpieza.

## 1. Arquitectura del Sistema
El proyecto se basa en una arquitectura de **Separación de Capas** (Decoupled Architecture) para garantizar la escalabilidad y mantenimiento:

*   **Frontend (Flutter)**: Interfaz de usuario responsiva compatible con Android, iOS y Navegadores Web (Chrome). Utiliza el patrón **Repositorio** para abstraer las llamadas a la API.
*   **Backend (Node.js + Express)**: Servidor central que gestiona la lógica de negocio, seguridad (JWT) y la comunicación con la base de datos.
*   **Base de Datos (MongoDB Atlas)**: Almacenamiento NoSQL en la nube para la persistencia de datos globales (Productos, Usuarios, Ventas).
*   **Persistencia Local (SQLite)**: Implementación exclusiva para dispositivos móviles que permite almacenar un historial físico de recibos de compra para consulta offline.

## 2. Flujo de Autenticación y Seguridad (JWT)
1.  **Inicio**: Al arrancar, el sistema verifica la existencia de un token JWT en el almacenamiento seguro.
2.  **Identidad**: Si existe sesión, se recupera el **Rol** del usuario (admin o customer) para personalizar la interfaz.
3.  **Autorización**: Todas las peticiones HTTP (vía `ApiService`) adjuntan automáticamente el token en el encabezado `Authorization`. El servidor decodifica este token para identificar al usuario sin necesidad de que este ingrese sus datos repetidamente.

## 3. Flujo de Negocio: Pedidos Especiales
Es el módulo de negociación interactiva entre cliente y administrador:
1.  **Solicitud**: El cliente selecciona una fecha en el calendario interactivo y describe su necesidad. El sistema extrae su email automáticamente del token JWT.
2.  **Notificación Administrativa**: El pedido aparece en el panel de Ventas del administrador con estatus "Esperando aprobación".
3.  **Cotización**: El administrador asigna un precio sugerido y envía un mensaje informativo. El estatus cambia a "Cotizado".
4.  **Aceptación**: El cliente visualiza la propuesta en su panel y puede proceder a la aceptación final, lo que cierra el ciclo de venta.

## 4. Gestión Automatizada de Inventario
*   **Generación de SKU**: Al registrar un producto, el sistema genera una clave única basada en la categoría (Ej: LIM para Limpieza) y un folio incremental.
*   **Actualización de Stock**: Las ventas directas del carrito descuentan automáticamente las existencias en MongoDB mediante operaciones atómicas en el servidor.

## 5. Puntos de Interés Técnico
*   **Diseño Responsivo**: El sistema detecta el ancho de pantalla para alternar entre menús laterales (Escritorio) y menús desplegables (Móvil).
*   **Resiliencia de Red**: Los servicios están preparados para manejar errores de conexión y mostrar estados de carga (Loading) para una mejor experiencia de usuario.
*   **Compatibilidad Web**: Se utiliza detección de plataforma (`kIsWeb`) para deshabilitar SQLite en navegadores, manteniendo la estabilidad de la aplicación.
