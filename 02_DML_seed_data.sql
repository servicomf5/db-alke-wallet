-- =====================================================
-- ALKE WALLET - DATOS DE PRUEBA (SEED DATA)
-- PostgreSQL 17.6
-- Autor: Proyecto Alke Wallet
-- Fecha: 11 de febrero de 2026
-- Descripción: Inserción de datos iniciales para pruebas
-- =====================================================

-- Nota: Asegúrate de haber ejecutado primero 01_DDL_schema.sql
-- Conectarse a la base de datos alke_wallet:
-- \c alke_wallet

-- =====================================================
-- PASO 1: LIMPIAR DATOS EXISTENTES (opcional)
-- =====================================================

-- Descomentar si deseas reiniciar los datos
-- TRUNCATE TABLE transactions RESTART IDENTITY CASCADE;
-- TRUNCATE TABLE users RESTART IDENTITY CASCADE;
-- TRUNCATE TABLE currencies RESTART IDENTITY CASCADE;


-- =====================================================
-- PASO 2: INSERCIÓN DE MONEDAS
-- Orden: Debe ser primero ya que users y transactions dependen de esta tabla
-- =====================================================

INSERT INTO currencies (currency_name, currency_symbol, currency_code) VALUES
    ('Peso Chileno', '$', 'CLP'),
    ('Dólar Estadounidense', 'USD', 'USD'),
    ('Euro', '€', 'EUR'),
    ('Bitcoin', '₿', 'BTC'),
    ('Peso Argentino', '$', 'ARS'),
    ('Real Brasileño', 'R$', 'BRL')
ON CONFLICT (currency_code) DO NOTHING;

-- Verificar inserción de monedas
SELECT
    currency_id,
    currency_name,
    currency_symbol,
    currency_code,
    created_at
FROM currencies
ORDER BY currency_id;


-- =====================================================
-- PASO 3: INSERCIÓN DE USUARIOS
-- Orden: Después de currencies
-- =====================================================

-- Nota sobre contraseñas:
-- En producción, las contraseñas deben estar hasheadas con bcrypt
-- Para pruebas, usamos texto plano con prefijo 'HASH:' como recordatorio
-- Ejemplo de hash bcrypt real: '$2b$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy'

INSERT INTO users (name, email, password, balance, currency_id, is_active) VALUES
    ('Juan Pérez', 'juan.perez@alkewallet.com', 'HASH:password123', 50000.00, 1, TRUE),
    ('María González', 'maria.gonzalez@alkewallet.com', 'HASH:password456', 1200.50, 2, TRUE),
    ('Carlos Rodríguez', 'carlos.rodriguez@alkewallet.com', 'HASH:password789', 800.00, 3, TRUE),
    ('Ana Martínez', 'ana.martinez@alkewallet.com', 'HASH:passwordabc', 0.05, 4, TRUE),
    ('Pedro Sánchez', 'pedro.sanchez@alkewallet.com', 'HASH:passwordxyz', 15000.00, 1, TRUE),
    ('Laura Fernández', 'laura.fernandez@alkewallet.com', 'HASH:password111', 25000.00, 1, TRUE),
    ('Diego Torres', 'diego.torres@alkewallet.com', 'HASH:password222', 500.00, 2, TRUE),
    ('Sofía Ramírez', 'sofia.ramirez@alkewallet.com', 'HASH:password333', 1500.75, 3, TRUE),
    ('Miguel Ángel Castro', 'miguel.castro@alkewallet.com', 'HASH:password444', 0.02, 4, TRUE),
    ('Carmen López', 'carmen.lopez@alkewallet.com', 'HASH:password555', 8000.00, 1, FALSE)
ON CONFLICT (email) DO NOTHING;

-- Verificar inserción de usuarios
SELECT
    u.user_id,
    u.name,
    u.email,
    c.currency_name,
    c.currency_symbol,
    u.balance,
    CONCAT(c.currency_symbol, ' ', u.balance) AS formatted_balance,
    u.is_active,
    u.created_at  -- AQUÍ: Especificar u.created_at en lugar de solo created_at
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
ORDER BY u.user_id;


-- =====================================================
-- PASO 4: INSERCIÓN DE TRANSACCIONES
-- Orden: Después de users y currencies
-- =====================================================

-- Transacciones variadas para demostrar diferentes escenarios
INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description, transaction_type) VALUES
    -- Transacciones en Peso Chileno (CLP)
    (1, 2, 10000.00, 1, 'Pago de servicios de consultoría', 'transfer'),
    (5, 1, 5000.00, 1, 'Transferencia mensual - Arriendo', 'transfer'),
    (1, 6, 15000.00, 1, 'Préstamo personal', 'transfer'),
    (6, 5, 8000.00, 1, 'Pago de factura', 'transfer'),

    -- Transacciones en Dólar (USD)
    (2, 7, 150.00, 2, 'Pago de alquiler', 'transfer'),
    (7, 2, 50.00, 2, 'Devolución de préstamo', 'transfer'),
    (2, 7, 200.00, 2, 'Compra de productos', 'transfer'),

    -- Transacciones en Euro (EUR)
    (3, 8, 50.00, 3, 'Regalo de cumpleaños', 'transfer'),
    (8, 3, 125.00, 3, 'Pago de servicios profesionales', 'transfer'),
    (3, 8, 75.50, 3, 'Cena compartida', 'transfer'),

    -- Transacciones en Bitcoin (BTC)
    (4, 9, 0.01, 4, 'Prueba de microtransacción crypto', 'transfer'),
    (9, 4, 0.02, 4, 'Pago por freelance', 'transfer'),
    (4, 9, 0.015, 4, 'Inversión conjunta', 'transfer'),

    -- Transacciones mixtas (diferentes usuarios y monedas)
    (1, 3, 25.00, 3, 'Pago internacional', 'transfer'),
    (6, 2, 100.00, 2, 'Transferencia internacional', 'transfer'),
    (5, 7, 75.00, 2, 'Pago de servicios online', 'transfer'),
    (7, 5, 50.00, 2, 'Reembolso', 'transfer'),
    (1, 8, 30.00, 3, 'Compra de artículos europeos', 'transfer'),
    (8, 1, 15.00, 3, 'Comisión por venta', 'transfer'),
    (2, 4, 10.00, 2, 'Donación crypto', 'transfer')
ON CONFLICT DO NOTHING;

-- Verificar inserción de transacciones
SELECT
    t.transaction_id,
    sender.name AS sender_name,
    receiver.name AS receiver_name,
    t.amount,
    c.currency_symbol,
    CONCAT(c.currency_symbol, ' ', t.amount) AS formatted_amount,
    t.transaction_date,
    t.description,
    t.transaction_type
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.transaction_id;


-- =====================================================
-- PASO 5: ESTADÍSTICAS Y VERIFICACIÓN FINAL
-- =====================================================

-- Resumen general de la base de datos
SELECT
    'currencies' AS tabla,
    COUNT(*) AS total_registros
FROM currencies
UNION ALL
SELECT
    'users',
    COUNT(*)
FROM users
UNION ALL
SELECT
    'transactions',
    COUNT(*)
FROM transactions;

-- Estadísticas por moneda
SELECT
    c.currency_name,
    c.currency_symbol,
    c.currency_code,
    COUNT(DISTINCT u.user_id) AS users_count,
    COUNT(DISTINCT t.transaction_id) AS transactions_count,
    COALESCE(SUM(t.amount), 0) AS total_volume
FROM currencies c
LEFT JOIN users u ON c.currency_id = u.currency_id
LEFT JOIN transactions t ON c.currency_id = t.currency_id
GROUP BY c.currency_id, c.currency_name, c.currency_symbol, c.currency_code
ORDER BY users_count DESC, total_volume DESC;

-- Top 5 usuarios con más transacciones enviadas
SELECT
    u.user_id,
    u.name,
    u.email,
    COUNT(t.transaction_id) AS transactions_sent,
    COALESCE(SUM(t.amount), 0) AS total_amount_sent
FROM users u
LEFT JOIN transactions t ON u.user_id = t.sender_user_id
GROUP BY u.user_id, u.name, u.email
ORDER BY transactions_sent DESC, total_amount_sent DESC
LIMIT 5;

-- Últimas 10 transacciones registradas
SELECT
    t.transaction_id,
    TO_CHAR(t.transaction_date, 'DD/MM/YYYY HH24:MI:SS') AS formatted_date,
    CONCAT(sender.name, ' → ', receiver.name) AS transfer_flow,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.description
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.transaction_date DESC, t.transaction_id DESC
LIMIT 10;


-- =====================================================
-- MENSAJE DE CONFIRMACIÓN
-- =====================================================

DO $$
DECLARE
    v_currencies_count INTEGER;
    v_users_count INTEGER;
    v_transactions_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_currencies_count FROM currencies;
    SELECT COUNT(*) INTO v_users_count FROM users;
    SELECT COUNT(*) INTO v_transactions_count FROM transactions;

    RAISE NOTICE '╔════════════════════════════════════════════╗';
    RAISE NOTICE '║   ALKE WALLET - DATOS INSERTADOS          ║';
    RAISE NOTICE '╠════════════════════════════════════════════╣';
    RAISE NOTICE '║ Monedas:       % registros              ║', LPAD(v_currencies_count::TEXT, 4, ' ');
    RAISE NOTICE '║ Usuarios:      % registros              ║', LPAD(v_users_count::TEXT, 4, ' ');
    RAISE NOTICE '║ Transacciones: % registros              ║', LPAD(v_transactions_count::TEXT, 4, ' ');
    RAISE NOTICE '╚════════════════════════════════════════════╝';
    RAISE NOTICE '';
    RAISE NOTICE '✓ Base de datos inicializada correctamente';
    RAISE NOTICE '✓ Puedes ejecutar ahora: 03_queries.sql';
END $$;

-- =====================================================
-- FIN DEL SCRIPT DE DATOS INICIALES
-- =====================================================
