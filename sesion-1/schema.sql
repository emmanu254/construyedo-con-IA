-- Sesión 1 — Construye con IA
-- DDL PostgreSQL para la librería

CREATE TABLE usuario (
    usuario_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    telefono VARCHAR(30)
);

CREATE TABLE autor (
    autor_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL,
    apellido VARCHAR(80)
);

CREATE TABLE libro (
    libro_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    numero_paginas INTEGER CHECK (numero_paginas > 0),
    precio NUMERIC(12,2) CHECK (precio >= 0)
);

CREATE TABLE ubicacion (
    ubicacion_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre_tienda VARCHAR(120) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    departamento VARCHAR(100),
    pais VARCHAR(100) NOT NULL
);

CREATE TABLE libro_autor (
    libro_id BIGINT NOT NULL REFERENCES libro(libro_id),
    autor_id BIGINT NOT NULL REFERENCES autor(autor_id),
    PRIMARY KEY (libro_id, autor_id)
);

CREATE TABLE inventario (
    libro_id BIGINT NOT NULL REFERENCES libro(libro_id),
    ubicacion_id BIGINT NOT NULL REFERENCES ubicacion(ubicacion_id),
    cantidad INTEGER NOT NULL DEFAULT 0 CHECK (cantidad >= 0),
    PRIMARY KEY (libro_id, ubicacion_id)
);

CREATE TABLE transaccion (
    transaccion_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id BIGINT NOT NULL REFERENCES usuario(usuario_id),
    ubicacion_id BIGINT REFERENCES ubicacion(ubicacion_id),
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('PRESTAMO', 'COMPRA')),
    fecha TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transaccion_detalle (
    transaccion_id BIGINT NOT NULL REFERENCES transaccion(transaccion_id) ON DELETE CASCADE,
    linea INTEGER NOT NULL CHECK (linea > 0),
    libro_id BIGINT NOT NULL REFERENCES libro(libro_id),
    cantidad INTEGER NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) CHECK (precio_unitario >= 0),
    PRIMARY KEY (transaccion_id, linea)
);

-- Índices útiles para búsquedas por claves foráneas.
CREATE INDEX idx_transaccion_usuario ON transaccion(usuario_id);
CREATE INDEX idx_transaccion_ubicacion ON transaccion(ubicacion_id);
CREATE INDEX idx_detalle_libro ON transaccion_detalle(libro_id);

-- Datos mínimos de prueba
INSERT INTO usuario (nombre, apellido, email, telefono)
VALUES ('Emmanuel', 'Baena', 'emmanuel@example.com', '3000000000');

INSERT INTO autor (nombre, apellido)
VALUES ('George', 'Orwell');

INSERT INTO libro (titulo, isbn, numero_paginas, precio)
VALUES ('1984', '9780451524935', 328, 55000.00);

INSERT INTO ubicacion (nombre_tienda, ciudad, departamento, pais)
VALUES ('Librería Centro', 'Medellín', 'Antioquia', 'Colombia');

INSERT INTO libro_autor (libro_id, autor_id)
VALUES (1, 1);

INSERT INTO inventario (libro_id, ubicacion_id, cantidad)
VALUES (1, 1, 10);

INSERT INTO transaccion (usuario_id, ubicacion_id, tipo)
VALUES (1, 1, 'COMPRA');

INSERT INTO transaccion_detalle (transaccion_id, linea, libro_id, cantidad, precio_unitario)
VALUES (1, 1, 1, 1, 55000.00);

-- Consulta rápida para comprobar las relaciones
SELECT
    t.transaccion_id,
    u.nombre || ' ' || u.apellido AS usuario,
    l.titulo AS libro,
    td.cantidad,
    td.precio_unitario,
    t.tipo,
    t.fecha
FROM transaccion t
JOIN usuario u ON u.usuario_id = t.usuario_id
JOIN transaccion_detalle td ON td.transaccion_id = t.transaccion_id
JOIN libro l ON l.libro_id = td.libro_id;
