# Sesión 1 — Modelo entidad-relación

## Problema
Diseñar la base de datos transaccional de una librería que permita registrar usuarios, libros, autores, ubicaciones e historial de préstamos/compras sin duplicar información.

## Entidades

### Usuario
- `usuario_id` — clave primaria
- `nombre`
- `apellido`
- `email`
- `telefono`

### Autor
- `autor_id` — clave primaria
- `nombre`
- `apellido`

### Libro
- `libro_id` — clave primaria
- `titulo`
- `isbn`
- `numero_paginas`
- `precio`

### Ubicacion
- `ubicacion_id` — clave primaria
- `nombre_tienda`
- `ciudad`
- `departamento`
- `pais`

### LibroAutor
Entidad intermedia para resolver la relación muchos-a-muchos entre libros y autores.
- `libro_id` — clave foránea a `Libro`
- `autor_id` — clave foránea a `Autor`
- clave primaria compuesta: (`libro_id`, `autor_id`)

### Inventario
Representa cuántas copias de un libro existen en una ubicación.
- `libro_id` — clave foránea a `Libro`
- `ubicacion_id` — clave foránea a `Ubicacion`
- `cantidad`
- clave primaria compuesta: (`libro_id`, `ubicacion_id`)

### Transaccion
Representa un préstamo o una compra realizada por un usuario.
- `transaccion_id` — clave primaria
- `usuario_id` — clave foránea a `Usuario`
- `tipo` — PRESTAMO o COMPRA
- `fecha`
- `ubicacion_id` — clave foránea a `Ubicacion`

### TransaccionDetalle
Permite que una transacción tenga uno o varios libros.
- `transaccion_id` — clave foránea a `Transaccion`
- `linea` — número de línea dentro de la transacción
- `libro_id` — clave foránea a `Libro`
- `cantidad`
- `precio_unitario`
- clave primaria compuesta: (`transaccion_id`, `linea`)

## Relaciones y cardinalidad
- Usuario 1:N Transaccion — un usuario puede realizar muchas transacciones.
- Ubicacion 1:N Transaccion — una ubicación puede registrar muchas transacciones.
- Libro N:M Autor — un libro puede tener varios autores y un autor varios libros. Se resuelve con `LibroAutor`.
- Libro N:M Ubicacion — un libro puede existir en varias ubicaciones y cada ubicación tiene muchos libros. Se resuelve con `Inventario`.
- Transaccion 1:N TransaccionDetalle — una transacción puede contener varias líneas.
- Libro 1:N TransaccionDetalle — un libro puede aparecer en muchas líneas de transacción.

## Diagrama simplificado

```text
Usuario 1 ─────── N Transaccion 1 ─────── N TransaccionDetalle N ─────── 1 Libro
                         │                                           │
                         │                                           │
                         N                                           N
                         │                                           │
                         1                                           N
                    Ubicacion                                LibroAutor
                         │                                           │
                         │                                           1
                         N                                         Autor
                         │
                         N
                    Inventario
                         │
                         1
                       Libro
```

## Normalización

### 1NF
Cada columna contiene un único valor atómico. Por ejemplo, autores no se guardan como `"Gabriel García Márquez, Jorge Luis Borges"` en una sola celda; se modelan en la entidad `Autor` y su relación se guarda en `LibroAutor`.

### 2NF
En las tablas con clave primaria compuesta, cada atributo depende de toda la clave. Por ejemplo, en `Inventario`, `cantidad` depende de la combinación `libro_id + ubicacion_id`, no solamente de una de las dos columnas.

### 3NF
Los atributos no dependen de otros atributos no-clave. Por ejemplo, los datos del autor no se almacenan en `Libro`; viven en `Autor`. Del mismo modo, los datos del usuario no se repiten en cada transacción: solo se guarda `usuario_id`.

## Decisión OLTP / OLAP
Este sistema es principalmente **OLTP**, porque registra operaciones individuales en tiempo real: usuarios, préstamos, compras, inventario y devoluciones. Una solución OLAP podría añadirse posteriormente para reportes y analítica, pero no es el objetivo principal de esta aplicación.
