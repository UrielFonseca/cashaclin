# Documentación Técnica - Sistema Casha Clin Pro

Este documento detalla el funcionamiento, arquitectura y flujo de operación del sistema de gestión comercial para "Casha Clin".

## 1. Arquitectura de Software
El sistema implementa una arquitectura de **Separación de Capas** (Decoupled Architecture) para garantizar escalabilidad y mantenimiento:

*   **Capa de Presentación (Frontend)**: Desarrollada en Flutter, utilizando un diseño responsivo adaptativo para dispositivos móviles y navegadores web (Chrome).
*   **Capa de Negocio (Repositories)**: Actúa como mediador entre la interfaz de usuario y los servicios de datos, gestionando la lógica de actualización de stock, validación de estados y sincronización.
*   **Capa de Servicios (API/Auth)**: Gestiona la comunicación asíncrona mediante protocolos HTTP y seguridad basada en JWT (JSON Web Tokens).
*   **Capa de Datos (Backend)**: Servidor Node.js con MongoDB Atlas para persistencia en la nube.
*   **Persistencia Local**: SQLite (exclusivo para dispositivos móviles) para el almacenamiento de comprobantes de compra offline.

## 2. Flujo de Usuario y Roles

### Flujo de Acceso y Seguridad
1. El sistema verifica la validez del token JWT en el almacenamiento local (`SharedPreferences`).
2. Si no existe una sesión activa, el usuario es redirigido automáticamente al módulo de **Autenticación**.
3. El servidor identifica al usuario mediante el token en cada petición, asociando automáticamente los pedidos al correo electrónico del titular de la sesión.

### Portal Administrativo (Rol: Admin)
*   **Resumen de Operaciones (Dashboard)**: Muestrario de indicadores clave (KPIs) con gráficas dinámicas de ingresos y alertas de inventario crítico.
*   **Gestión de Catálogo**: Módulo CRUD con generación automatizada de SKU basado en la nomenclatura de categorías (LIM, LAV, DES).
*   **Control de Ventas y Negociación**: Interfaz interactiva para procesar solicitudes de mayoreo, permitiendo cotizar precios y mantener un historial de mensajes con el cliente.

### Portal del Cliente (Rol: Customer)
*   **Catálogo Inteligente**: Consulta de existencias en tiempo real con filtrado por categorías.
*   **Proceso de Checkout**: Registro de transacciones con cálculo automático de impuestos y persistencia local del recibo.
*   **Seguimiento de Pedidos (Mis Pedidos)**: Panel automatizado para consultar el estatus de sus solicitudes especiales y responder a las propuestas del administrador.

## 3. Puntos de Interés Técnico
*   **Interoperabilidad**: El `ApiService` detecta el entorno de ejecución para ajustar las URLs de conexión (localhost para web vs 10.0.2.2 para emuladores).
*   **Negociación Bidireccional**: El sistema permite un flujo de mensajes entre admin y cliente dentro de un mismo pedido, permitiendo la discusión de precios antes de la aceptación final.
*   **Robustez Visual**: Implementación de `SingleChildScrollView` y layouts adaptativos para evitar errores de desbordamiento en pantallas pequeñas.
