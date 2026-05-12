# Documentación Técnica - Casha Clin Pro

Este documento describe la arquitectura, el flujo de datos y las funcionalidades principales del sistema de gestión y ventas "Casha Clin Pro".

## 1. Arquitectura del Sistema
El proyecto sigue una arquitectura de **Separación de Capas** para garantizar escalabilidad y mantenimiento:

*   **Frontend (Flutter)**: Interfaz de usuario responsiva compatible con Android, iOS y Navegadores Web.
*   **Backend (Node.js + Express)**: Servidor RESTful que gestiona la lógica de negocio y seguridad.
*   **Base de Datos (MongoDB Atlas)**: Almacenamiento persistente en la nube para datos globales.
*   **Persistencia Local (SQLite)**: Almacenamiento de recibos en el dispositivo móvil para consulta offline.

## 2. Flujo de Autenticación
1. El usuario inicia sesión o se registra en el sistema.
2. El servidor valida las credenciales y emite un **Token JWT**.
3. Flutter almacena el token de forma segura y lo incluye en todas las peticiones HTTP posteriores para autorizar el acceso.
4. El sistema identifica automáticamente al usuario a través del token, eliminando la necesidad de ingresar el correo manualmente en cada formulario.

## 3. Flujo de Pedidos Especiales (Negociación)
Es el módulo más avanzado del sistema:
1. **Solicitud**: El cliente selecciona una fecha en el calendario y describe su necesidad (mayoreo o productos específicos).
2. **Cotización**: El administrador recibe la solicitud, asigna un precio sugerido y envía un mensaje informativo. El estado cambia a "Cotizado".
3. **Aceptación**: El cliente visualiza la propuesta en su panel "Mis Pedidos" y puede aceptar el precio final o seguir enviando mensajes hasta llegar a un acuerdo.

## 4. Gestión de Productos e Inventario
*   **Generación de SKU**: Al crear un producto, el sistema genera automáticamente un código basado en la categoría (ej: LIM-001 para Limpieza).
*   **Control de Stock**: Las ventas directas desde el carrito descuentan automáticamente las existencias en la base de datos centralizada.
*   **Alertas**: El dashboard administrativo notifica automáticamente cuando un producto tiene menos de 10 unidades.

## 5. Detalles Técnicos de Implementación
*   **Patrón Repositorio**: Actúa como mediador entre la interfaz y la API, permitiendo cambiar la fuente de datos sin afectar las pantallas.
*   **TableCalendar**: Proporciona una experiencia intuitiva para la selección de fechas en pedidos especiales.
*   **FL Chart**: Utilizado para renderizar gráficas de rendimiento económico en tiempo real.
