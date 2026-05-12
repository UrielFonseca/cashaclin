# Documentación de Arquitectura y Flujo - Casha Clin Pro

Este documento describe el funcionamiento técnico y el flujo de datos del sistema integral para la gestión de productos de limpieza.

## 1. Arquitectura General
El proyecto sigue una arquitectura de **Separación de Capas** (Frontend y Backend), lo que permite independencia entre la interfaz de usuario y la persistencia de datos.

*   **Frontend (Flutter)**: Interfaz responsiva compatible con Android, iOS y Chrome. Utiliza el patrón **Repositorio** para abstraer las llamadas a la API REST.
*   **Backend (Node.js + Express)**: Servidor encargado de procesar la lógica de negocio, validaciones de seguridad y gestión de la base de datos.
*   **Base de Datos (MongoDB Atlas)**: Almacenamiento persistente en la nube para el catálogo, usuarios y transacciones.
*   **Seguridad (JWT)**: Implementación de JSON Web Tokens para autorizar cada petición HTTP y proteger los datos sensibles.

## 2. Flujo de Autenticación
1.  Al iniciar, el sistema verifica la existencia de un token en el almacenamiento local.
2.  Si no hay sesión, se redirige al módulo de **Autenticación**.
3.  Tras el login exitoso, el servidor asocia el **Email** y el **Rol** del usuario al token, lo que permite al sistema filtrar automáticamente la información (ej. "Mis Pedidos") sin intervención del usuario.

## 3. Módulo de Negociación (Pedidos Especiales)
Este es el flujo más dinámico del sistema:
*   **Solicitud**: El cliente selecciona una fecha estimada en el calendario (`TableCalendar`) y describe su requerimiento.
*   **Gestión Administrativa**: El administrador visualiza la solicitud, asigna un monto total cotizado y envía un mensaje de respuesta.
*   **Resolución**: El cliente recibe la notificación en su panel, visualiza el historial de mensajes y puede aceptar la propuesta económica definitiva.

## 4. Gestión Automatizada
*   **Generador de SKU**: Basado en nomenclaturas técnicas (Prefijos LIM, LAV, DES) y correlativos numéricos automáticos.
*   **Alertas de Inventario**: El Dashboard identifica en tiempo real los productos con existencias menores a 10 unidades para su reabastecimiento inmediato.
*   **Manejo de Stock**: El descuento de existencias se realiza mediante operaciones atómicas en el servidor para evitar discrepancias.
