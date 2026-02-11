-- =====================================================
-- ALKE WALLET - DATABASE SCHEMA
-- PostgreSQL 17.6
-- Autor: Proyecto Alke Wallet
-- Fecha: 11 de febrero de 2026
-- Descripción: Script de creación de base de datos y tablas
-- =====================================================

-- =====================================================
-- PASO 1: ELIMINAR Y CREAR BASE DE DATOS
-- =====================================================

-- Nota: Ejecutar esta sección solo la primera vez o para reiniciar la BD
-- Descomentar las siguientes líneas si necesitas recrear la base de datos

-- DROP DATABASE IF EXISTS alke_wallet;

-- CREATE DATABASE alke_wallet
--     WITH
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'Spanish_Spain.1252'
--     LC_CTYPE = 'Spanish_Spain.1252'
--     TEMPLATE = template0;

-- Después de crear la base de datos, conectarse a ella:
-- \c alke_wallet

-- =====================================================
-- PASO 2: ELIMINAR TABLAS SI EXISTEN (orden inverso por FKs)
-- =====================================================

DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS currencies CASCADE;

-- =====================================================
-- TABLA: currencies
-- Descripción: Catálogo de monedas disponibles en la wallet
-- Tipo de entidad: Entidad fuerte (no depende de otras tablas)
-- =====================================================

CREATE TABLE IF NOT EXISTS currencies (
    -- Identificador único de la moneda
    currency_id         SERIAL,

    -- Nombre completo de la moneda (ej: "Peso Chileno", "Dólar Estadounidense")
    currency_name       VARCHAR(50) NOT NULL,

    -- Símbolo de la moneda (ej: "$", "USD", "€")
    currency_symbol     VARCHAR(10) NOT NULL,

    -- Código ISO 4217 de 3 letras (ej: "CLP", "USD", "EUR")
    currency_code       CHAR(3) NOT NULL,

    -- Fecha de creación del registro
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- CONSTRAINTS
    CONSTRAINT pk_currencies PRIMARY KEY (currency_id),
    CONSTRAINT uq_currencies_name UNIQUE (currency_name),
    CONSTRAINT uq_currencies_code UNIQUE (currency_code),
    CONSTRAINT chk_currencies_code_length CHECK (LENGTH(currency_code) = 3),
    CONSTRAINT chk_currencies_code_uppercase CHECK (currency_code = UPPER(currency_code))
);

-- Comentarios en la tabla y columnas (buena práctica PostgreSQL)
COMMENT ON TABLE currencies IS 'Catálogo de monedas soportadas en la wallet';
COMMENT ON COLUMN currencies.currency_id IS 'Identificador único autoincremental';
COMMENT ON COLUMN currencies.currency_name IS 'Nombre completo de la moneda';
COMMENT ON COLUMN currencies.currency_symbol IS 'Símbolo visual de la moneda';
COMMENT ON COLUMN currencies.currency_code IS 'Código ISO 4217 de 3 letras';
COMMENT ON COLUMN currencies.created_at IS 'Fecha y hora de creación del registro';


-- =====================================================
-- TABLA: users
-- Descripción: Usuarios del sistema de wallet
-- Tipo de entidad: Entidad fuerte con relación a currencies
-- =====================================================

CREATE TABLE IF NOT EXISTS users (
    -- Identificador único del usuario
    user_id             SERIAL,

    -- Nombre completo del usuario
    name                VARCHAR(100) NOT NULL,

    -- Correo electrónico (usado para login)
    email               VARCHAR(255) NOT NULL,

    -- Contraseña hasheada (bcrypt recomendado, mínimo 60 caracteres)
    password            VARCHAR(255) NOT NULL,

    -- Saldo actual del usuario en su moneda predeterminada
    balance             DECIMAL(15,2) DEFAULT 0.00 NOT NULL,

    -- Moneda predeterminada del usuario (FK a currencies)
    currency_id         INTEGER NOT NULL,

    -- Estado del usuario (activo/inactivo) - soft delete
    is_active           BOOLEAN DEFAULT TRUE,

    -- Fecha de creación del registro
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Fecha de última modificación
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- CONSTRAINTS
    CONSTRAINT pk_users PRIMARY KEY (user_id),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT fk_users_currency FOREIGN KEY (currency_id)
        REFERENCES currencies(currency_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_users_balance_positive CHECK (balance >= 0),
    CONSTRAINT chk_users_email_format CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Comentarios en la tabla y columnas
COMMENT ON TABLE users IS 'Usuarios registrados en la plataforma Alke Wallet';
COMMENT ON COLUMN users.user_id IS 'Identificador único autoincremental';
COMMENT ON COLUMN users.name IS 'Nombre completo del usuario';
COMMENT ON COLUMN users.email IS 'Correo electrónico único del usuario';
COMMENT ON COLUMN users.password IS 'Contraseña hasheada (bcrypt en producción)';
COMMENT ON COLUMN users.balance IS 'Saldo actual en la moneda predeterminada del usuario (desnormalizado para rendimiento)';
COMMENT ON COLUMN users.currency_id IS 'Moneda predeterminada elegida por el usuario';
COMMENT ON COLUMN users.is_active IS 'Indica si el usuario está activo en el sistema';
COMMENT ON COLUMN users.created_at IS 'Fecha y hora de registro del usuario';
COMMENT ON COLUMN users.updated_at IS 'Fecha y hora de última modificación';


-- =====================================================
-- TABLA: transactions
-- Descripción: Registro de todas las transacciones financieras
-- Tipo de entidad: Entidad débil (depende de users y currencies)
-- =====================================================

CREATE TABLE IF NOT EXISTS transactions (
    -- Identificador único de la transacción
    transaction_id      SERIAL,

    -- Usuario que envía el dinero (FK a users)
    sender_user_id      INTEGER NOT NULL,

    -- Usuario que recibe el dinero (FK a users)
    receiver_user_id    INTEGER NOT NULL,

    -- Monto de la transacción
    amount              DECIMAL(15,2) NOT NULL,

    -- Moneda en la que se realiza la transacción (FK a currencies)
    currency_id         INTEGER NOT NULL,

    -- Fecha y hora de la transacción
    transaction_date    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Descripción o concepto de la transacción
    description         VARCHAR(255),

    -- Tipo de transacción: transfer, deposit, withdrawal
    transaction_type    VARCHAR(20) DEFAULT 'transfer',

    -- Fecha de creación del registro
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- CONSTRAINTS
    CONSTRAINT pk_transactions PRIMARY KEY (transaction_id),
    CONSTRAINT fk_transactions_sender FOREIGN KEY (sender_user_id)
        REFERENCES users(user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_receiver FOREIGN KEY (receiver_user_id)
        REFERENCES users(user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_currency FOREIGN KEY (currency_id)
        REFERENCES currencies(currency_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_transactions_amount_positive CHECK (amount > 0),
    CONSTRAINT chk_transactions_different_users CHECK (sender_user_id <> receiver_user_id),
    CONSTRAINT chk_transactions_type CHECK (transaction_type IN ('transfer', 'deposit', 'withdrawal'))
);

-- Comentarios en la tabla y columnas
COMMENT ON TABLE transactions IS 'Registro histórico de todas las transacciones financieras';
COMMENT ON COLUMN transactions.transaction_id IS 'Identificador único autoincremental';
COMMENT ON COLUMN transactions.sender_user_id IS 'ID del usuario que envía los fondos';
COMMENT ON COLUMN transactions.receiver_user_id IS 'ID del usuario que recibe los fondos';
COMMENT ON COLUMN transactions.amount IS 'Monto de la transacción (debe ser positivo)';
COMMENT ON COLUMN transactions.currency_id IS 'Moneda en la que se realiza la transacción';
COMMENT ON COLUMN transactions.transaction_date IS 'Fecha y hora en que se ejecutó la transacción';
COMMENT ON COLUMN transactions.description IS 'Descripción opcional o concepto de pago';
COMMENT ON COLUMN transactions.transaction_type IS 'Tipo: transfer (defecto), deposit, withdrawal';
COMMENT ON COLUMN transactions.created_at IS 'Fecha y hora de creación del registro';


-- =====================================================
-- ÍNDICES ADICIONALES PARA OPTIMIZACIÓN
-- =====================================================

-- Índice en currency_code para búsquedas frecuentes por código ISO
CREATE INDEX IF NOT EXISTS idx_currencies_code
    ON currencies(currency_code);

-- Índice en email para búsquedas y login
-- (UNIQUE ya crea un índice automáticamente, pero lo hacemos explícito)
CREATE INDEX IF NOT EXISTS idx_users_email
    ON users(email);

-- Índice en currency_id de users para JOINs frecuentes
CREATE INDEX IF NOT EXISTS idx_users_currency
    ON users(currency_id);

-- Índice en usuarios activos para filtrado
CREATE INDEX IF NOT EXISTS idx_users_active
    ON users(is_active)
    WHERE is_active = TRUE;

-- Índice en sender_user_id para historial de transacciones enviadas
CREATE INDEX IF NOT EXISTS idx_transactions_sender
    ON transactions(sender_user_id);

-- Índice en receiver_user_id para historial de transacciones recibidas
CREATE INDEX IF NOT EXISTS idx_transactions_receiver
    ON transactions(receiver_user_id);

-- Índice en transaction_date para ordenamiento cronológico
CREATE INDEX IF NOT EXISTS idx_transactions_date
    ON transactions(transaction_date DESC);

-- Índice en currency_id de transactions para reportes por moneda
CREATE INDEX IF NOT EXISTS idx_transactions_currency
    ON transactions(currency_id);

-- Índice compuesto para consulta frecuente: transacciones de un usuario ordenadas por fecha
CREATE INDEX IF NOT EXISTS idx_transactions_sender_date
    ON transactions(sender_user_id, transaction_date DESC);

-- Índice compuesto para transacciones recibidas ordenadas por fecha
CREATE INDEX IF NOT EXISTS idx_transactions_receiver_date
    ON transactions(receiver_user_id, transaction_date DESC);


-- =====================================================
-- VERIFICACIÓN DE TABLAS CREADAS
-- =====================================================

-- Listar todas las tablas creadas
SELECT
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
    AND table_name IN ('currencies', 'users', 'transactions')
ORDER BY table_name;

-- Mostrar estructura de cada tabla
\d currencies
\d users
\d transactions

-- Listar todas las constraints de integridad referencial
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
LEFT JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public'
    AND tc.table_name IN ('currencies', 'users', 'transactions')
ORDER BY tc.table_name, tc.constraint_type, tc.constraint_name;

-- =====================================================
-- FIN DEL SCRIPT DDL
-- =====================================================
