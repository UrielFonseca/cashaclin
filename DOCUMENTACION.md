# Documentación del Proyecto - Casha Clin Pro

Este documento proporciona una visión general del sistema de gestión comercial para productos de limpieza, detallando su arquitectura, flujo de datos y características técnicas.

## 1. Arquitectura del Sistema
El proyecto está diseñado bajo una arquitectura de **Separación de Capas** (Frontend y Backend), lo que permite independencia entre la interfaz de usuario y la lógica de datos.

*   **Frontend**: Desarrollado en Flutter, con un diseño responsivo que se adapta a dispositivos móviles y navegadores web (Chrome).
*   **Backend**: Servidor RESTful en Node.js con Express, encargado de la validación de negocio y seguridad.
*   **Base de Datos**: MongoDB Atlas para el almacenamiento persistente en la nube.
*   **Persistencia Local**: SQLite (exclusivo para dispositivos móviles) para el almacenamiento de comprobantes de compra offline.

## 2. Flujo de Autenticación y Seguridad
El sistema utiliza **JWT (JSON Web Tokens)** para gestionar las sesiones:
1.  El usuario se autentica o registra mediante el servicio de identidad.
2.  El servidor emite un token que contiene el ID, Email y Rol del usuario.
3.  Flutter almacena este token localmente y lo adjunta en cada petición HTTP para autorizar el acceso a los datos.

## 3. Funcionalidades del Administrador
*   **Dashboard Ejecutivo**: Visualización de métricas de ingresos, conteo de stock y alertas automáticas de reabastecimiento.
*   **Gestión de Catálogo**: Administración de productos con generación automatizada de SKU según la categoría seleccionada (LIM, LAV, DES).
*   **Módulo de Negociación**: Sistema de comunicación bidireccional para procesar solicitudes de mayoreo, permitiendo asignar precios personalizados y enviar mensajes informativos al cliente.

## 4. Funcionalidades del Cliente
*   **Portal de Compras**: Interfaz intuitiva para navegar el catálogo y gestionar el carrito con cálculo de impuestos.
*   **Seguimiento de Solicitudes**: Panel automatizado donde el cliente consulta en tiempo real el estatus de sus pedidos especiales y responde a las cotizaciones del administrador.

## 5. Detalles Técnicos de Interés
*   **Patrón Repositorio**: Actúa como una capa de abstracción para que la interfaz no dependa directamente de la implementación de la API.
*   **Manejo de Errores**: El sistema incluye validaciones de red y estados de carga (Loading) para mejorar la experiencia de usuario.
*   **Diseño Responsivo**: Uso de `MediaQuery` y layouts adaptativos (Sidebar/Drawer) para garantizar usabilidad en cualquier resolución.
