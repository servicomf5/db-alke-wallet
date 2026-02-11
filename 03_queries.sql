-- =====================================================
-- ALKE WALLET - CONSULTAS SQL REQUERIDAS
-- PostgreSQL 17.6
-- Autor: Proyecto Alke Wallet
-- Fecha: 11 de febrero de 2026
-- Descripción: Consultas SQL solicitadas en la consigna del proyecto
-- =====================================================

-- Nota: Asegúrate de haber ejecutado primero:
--   1. 01_DDL_schema.sql
--   2. 02_DML_seed_data.sql
-- Conectarse a la base de datos: \c alke_wallet


-- =====================================================
-- CONSULTA 1: OBTENER EL NOMBRE DE LA MONEDA ELEGIDA POR UN USUARIO ESPECÍFICO
-- Requerimiento: Mostrar la moneda predeterminada de un usuario
-- Tablas: users, currencies
-- JOIN: INNER JOIN entre users y currencies
-- =====================================================

-- Ejemplo 1: Consultar la moneda del usuario con ID = 1
SELECT
    u.user_id,
    u.name AS user_name,
    u.email,
    c.currency_name,
    c.currency_symbol,
    c.currency_code,
    u.balance,
    CONCAT(c.currency_symbol, ' ', TO_CHAR(u.balance, 'FM999,999,990.00')) AS formatted_balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE u.user_id = 1;

-- Ejemplo 2: Consultar por email del usuario
SELECT
    u.user_id,
    u.name AS user_name,
    c.currency_name,
    c.currency_symbol,
    c.currency_code,
    CONCAT(c.currency_symbol, ' ', u.balance) AS current_balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE u.email = 'maria.gonzalez@alkewallet.com';

-- Ejemplo 3: Versión simplificada - Solo nombre de moneda
SELECT
    c.currency_name
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE u.user_id = 1;

-- Ejemplo 4: Consulta parametrizable para todos los usuarios activos
SELECT
    u.user_id,
    u.name AS user_name,
    u.email,
    c.currency_name AS preferred_currency,
    c.currency_symbol,
    u.balance AS balance_amount,
    u.is_active AS active_status
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE u.is_active = TRUE
ORDER BY u.user_id;


-- =====================================================
-- CONSULTA 2: OBTENER TODAS LAS TRANSACCIONES REGISTRADAS
-- Requerimiento: Listar el historial completo de transacciones
-- Tablas: transactions, users (sender y receiver), currencies
-- JOIN: Múltiples INNER JOINs
-- =====================================================

-- Versión completa con toda la información relevante
SELECT
    t.transaction_id,
    TO_CHAR(t.transaction_date, 'DD/MM/YYYY HH24:MI:SS') AS transaction_date,
    sender.user_id AS sender_id,
    sender.name AS sender_name,
    sender.email AS sender_email,
    receiver.user_id AS receiver_id,
    receiver.name AS receiver_name,
    receiver.email AS receiver_email,
    t.amount,
    c.currency_symbol,
    c.currency_code,
    c.currency_name,
    CONCAT(c.currency_symbol, ' ', TO_CHAR(t.amount, 'FM999,999,990.00')) AS formatted_amount,
    t.description,
    t.transaction_type
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.transaction_date DESC, t.transaction_id DESC;

-- Versión simplificada
SELECT
    t.transaction_id,
    t.transaction_date,
    sender.name AS from_user,
    receiver.name AS to_user,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.description
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.transaction_date DESC;

-- Versión con flujo de transferencia visual
SELECT
    t.transaction_id,
    t.transaction_date,
    CONCAT(sender.name, ' → ', receiver.name) AS transfer_flow,
    CONCAT(c.currency_symbol, ' ', t.amount, ' ', c.currency_code) AS amount,
    t.description AS concept,
    t.transaction_type AS type
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.transaction_date DESC;


-- =====================================================
-- CONSULTA 3: OBTENER TODAS LAS TRANSACCIONES REALIZADAS POR UN USUARIO ESPECÍFICO
-- Requerimiento: Historial de transacciones donde el usuario es EMISOR/SENDER
-- Tablas: transactions, users, currencies
-- JOIN: INNER JOIN
-- WHERE: Filtro por sender_user_id
-- =====================================================

-- Ejemplo 1: Transacciones ENVIADAS por el usuario con ID = 1
SELECT
    t.transaction_id,
    TO_CHAR(t.transaction_date, 'DD/MM/YYYY HH24:MI:SS') AS date_time,
    receiver.user_id AS recipient_id,
    receiver.name AS recipient_name,
    receiver.email AS recipient_email,
    t.amount,
    c.currency_symbol,
    c.currency_code,
    CONCAT(c.currency_symbol, ' ', TO_CHAR(t.amount, 'FM999,999,990.00')) AS formatted_amount,
    t.description,
    t.transaction_type
FROM transactions t
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
WHERE t.sender_user_id = 1
ORDER BY t.transaction_date DESC;

-- Ejemplo 2: Versión simplificada
SELECT
    t.transaction_id,
    t.transaction_date,
    receiver.name AS sent_to,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.description
FROM transactions t
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
WHERE t.sender_user_id = 1
ORDER BY t.transaction_date DESC;

-- Ejemplo 3: Con estadísticas agregadas
SELECT
    t.transaction_id,
    t.transaction_date,
    receiver.name AS recipient,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.description
FROM transactions t
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
WHERE t.sender_user_id = 1
ORDER BY t.transaction_date DESC;

-- Resumen de transacciones enviadas por el usuario ID = 1
SELECT
    sender.user_id,
    sender.name AS user_name,
    COUNT(t.transaction_id) AS total_transactions_sent,
    SUM(t.amount) AS total_amount_sent,
    AVG(t.amount) AS average_transaction_amount,
    MIN(t.amount) AS min_transaction,
    MAX(t.amount) AS max_transaction,
    MIN(t.transaction_date) AS first_transaction,
    MAX(t.transaction_date) AS last_transaction
FROM users sender
LEFT JOIN transactions t ON sender.user_id = t.sender_user_id
WHERE sender.user_id = 1
GROUP BY sender.user_id, sender.name;


-- =====================================================
-- CONSULTAS ADICIONALES ÚTILES (NO REQUERIDAS PERO RECOMENDADAS)
-- =====================================================

-- CONSULTA EXTRA 1: Transacciones RECIBIDAS por un usuario
SELECT
    t.transaction_id,
    t.transaction_date,
    sender.name AS received_from,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.description
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
WHERE t.receiver_user_id = 1
ORDER BY t.transaction_date DESC;

-- CONSULTA EXTRA 2: TODAS las transacciones de un usuario (enviadas + recibidas)
SELECT
    t.transaction_id,
    t.transaction_date,
    CASE
        WHEN t.sender_user_id = 1 THEN 'ENVIADO'
        ELSE 'RECIBIDO'
    END AS transaction_direction,
    CASE
        WHEN t.sender_user_id = 1 THEN receiver.name
        ELSE sender.name
    END AS counterpart_name,
    CASE
        WHEN t.sender_user_id = 1 THEN CONCAT('- ', c.currency_symbol, ' ', t.amount)
        ELSE CONCAT('+ ', c.currency_symbol, ' ', t.amount)
    END AS amount_with_sign,
    t.description
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
WHERE t.sender_user_id = 1 OR t.receiver_user_id = 1
ORDER BY t.transaction_date DESC;

-- CONSULTA EXTRA 3: Balance de transacciones por usuario (enviado vs recibido)
SELECT
    u.user_id,
    u.name,
    COALESCE(sent.total_sent, 0) AS total_sent,
    COALESCE(received.total_received, 0) AS total_received,
    COALESCE(received.total_received, 0) - COALESCE(sent.total_sent, 0) AS net_balance
FROM users u
LEFT JOIN (
    SELECT sender_user_id, SUM(amount) AS total_sent
    FROM transactions
    GROUP BY sender_user_id
) sent ON u.user_id = sent.sender_user_id
LEFT JOIN (
    SELECT receiver_user_id, SUM(amount) AS total_received
    FROM transactions
    GROUP BY receiver_user_id
) received ON u.user_id = received.receiver_user_id
WHERE u.user_id = 1;


-- =====================================================
-- VERIFICACIÓN Y CONTEO DE RESULTADOS
-- =====================================================

-- Contar total de transacciones en la base de datos
SELECT COUNT(*) AS total_transactions FROM transactions;

-- Contar transacciones por usuario (como sender)
SELECT
    u.user_id,
    u.name,
    COUNT(t.transaction_id) AS transactions_as_sender
FROM users u
LEFT JOIN transactions t ON u.user_id = t.sender_user_id
GROUP BY u.user_id, u.name
ORDER BY transactions_as_sender DESC;

-- Contar transacciones por usuario (como receiver)
SELECT
    u.user_id,
    u.name,
    COUNT(t.transaction_id) AS transactions_as_receiver
FROM users u
LEFT JOIN transactions t ON u.user_id = t.receiver_user_id
GROUP BY u.user_id, u.name
ORDER BY transactions_as_receiver DESC;


-- =====================================================
-- MENSAJE INFORMATIVO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '╔════════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  CONSULTAS SQL OBLIGATORIAS - ALKE WALLET                  ║';
    RAISE NOTICE '╠════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║                                                            ║';
    RAISE NOTICE '║  ✓ Consulta 1: Moneda de usuario específico                ║';
    RAISE NOTICE '║  ✓ Consulta 2: Todas las transacciones                     ║';
    RAISE NOTICE '║  ✓ Consulta 3: Transacciones por usuario (sender)          ║';
    RAISE NOTICE '║                                                            ║';
    RAISE NOTICE '║  Consultas EXTRA incluidas:                                ║';
    RAISE NOTICE '║  • Transacciones recibidas por usuario                     ║';
    RAISE NOTICE '║  • Todas las transacciones (enviadas + recibidas)          ║';
    RAISE NOTICE '║  • Balance neto de transacciones                           ║';
    RAISE NOTICE '║                                                            ║';
    RAISE NOTICE '╚════════════════════════════════════════════════════════════╝';
END $$;

-- =====================================================
-- FIN DEL SCRIPT DE CONSULTAS
-- =====================================================
