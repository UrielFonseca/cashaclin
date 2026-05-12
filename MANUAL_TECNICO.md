# Manual Técnico y Flujo de Aplicación - Casha Clin Pro

Este documento describe la arquitectura de software, el flujo de datos y las funcionalidades del sistema integral para la gestión y venta de productos de limpieza.

## 1. Arquitectura del Sistema
El sistema se basa en una arquitectura de **Separación de Capas** (Frontend y Backend), lo que garantiza un mantenimiento sencillo y una alta escalabilidad.

*   **Frontend (Flutter)**: Interfaz de usuario responsiva que se adapta dinámicamente a dispositivos móviles y navegadores web (Chrome).
*   **Backend (Node.js + Express)**: Servidor centralizado encargado de procesar la lógica de negocio, validaciones de seguridad y gestión de la base de datos.
*   **Base de Datos (MongoDB Atlas)**: Repositorio NoSQL en la nube para la persistencia global de usuarios, productos, ventas y clientes.
*   **Persistencia Local (SQLite)**: Implementación para móviles que permite el almacenamiento físico de comprobantes de compra para consulta offline.

## 2. Flujo de Autenticación y Sesión (JWT)
1.  **Inicio**: Al arrancar, el sistema verifica en el almacenamiento local si existe un token JWT válido.
2.  **Validación**: Si no existe sesión, se redirige al usuario al módulo de Autenticación.
3.  **Seguridad**: El token JWT generado por el servidor contiene la identidad (email) y los privilegios (rol) del usuario. Este token se inyecta automáticamente en todas las peticiones HTTP a través del `ApiService`.

## 3. Flujo de Pedidos Especiales (Negociación)
Este es el componente más avanzado de la plataforma, permitiendo una interacción directa entre cliente y empresa:
*   **Solicitud**: El cliente define sus necesidades y selecciona una fecha en el calendario interactivo. El sistema asocia automáticamente su identidad desde el token JWT.
*   **Revisión**: El pedido llega al administrador con un estatus inicial de espera.
*   **Cotización**: El administrador asigna un precio sugerido y envía un mensaje técnico. El estatus evoluciona a "Cotizado".
*   **Aceptación**: El cliente visualiza la oferta en su panel de pedidos y procede a la aceptación final, lo que formaliza la transacción.

## 4. Gestión Automatizada de Catálogo e Inventario
*   **Identificación (SKU)**: El sistema genera automáticamente claves únicas (SKU) combinando el prefijo de la categoría (LIM, LAV, DES) con un folio secuencial.
*   **Stock Atómico**: Las ventas descuentan existencias mediante operaciones seguras en el servidor para evitar discrepancias si varios usuarios compran simultáneamente.

## 5. Puntos de Interés Técnico
*   **Diseño Responsivo**: Uso de menús laterales fijos en escritorio y menús desplegables en móviles.
*   **Manejo de Errores**: El sistema incluye capturas de excepciones de red y muestra indicadores de carga para mejorar la retroalimentación al usuario.
*   **Interoperabilidad**: Detección automática del entorno para ajustar las direcciones de conexión al servidor central.
