-- =====================================================
-- ALKE WALLET - CONSULTAS AVANZADAS Y VISTAS
-- PostgreSQL 17.6
-- Autor: Proyecto Alke Wallet
-- Fecha: 11 de febrero de 2026
-- Descripción: Consultas avanzadas, vistas, agregaciones, subconsultas y análisis
-- =====================================================

-- Nota: Asegúrate de haber ejecutado los scripts anteriores
-- Conectarse a la base de datos: \c alke_wallet


-- =====================================================
-- VISTA 1: TOP 5 USUARIOS CON MAYOR SALDO
-- Requerimiento: Lección 2 - Tarea Plus
-- =====================================================

CREATE OR REPLACE VIEW vw_top_users_by_balance AS
SELECT
    u.user_id,
    u.name,
    u.email,
    u.balance,
    c.currency_name,
    c.currency_symbol,
    c.currency_code,
    CONCAT(c.currency_symbol, ' ', TO_CHAR(u.balance, 'FM999,999,990.00')) AS formatted_balance,
    u.is_active,
    u.created_at
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE u.is_active = TRUE
ORDER BY u.balance DESC
LIMIT 5;

-- Uso de la vista
SELECT * FROM vw_top_users_by_balance;


-- =====================================================
-- VISTA 2: RESUMEN DE TRANSACCIONES POR USUARIO
-- =====================================================

CREATE OR REPLACE VIEW vw_user_transaction_summary AS
SELECT
    u.user_id,
    u.name,
    u.email,
    COALESCE(COUNT(DISTINCT t_sent.transaction_id), 0) AS transactions_sent,
    COALESCE(COUNT(DISTINCT t_received.transaction_id), 0) AS transactions_received,
    COALESCE(COUNT(DISTINCT t_sent.transaction_id), 0) +
    COALESCE(COUNT(DISTINCT t_received.transaction_id), 0) AS total_transactions,
    COALESCE(SUM(t_sent.amount), 0) AS total_amount_sent,
    COALESCE(SUM(t_received.amount), 0) AS total_amount_received,
    u.balance AS current_balance,
    c.currency_symbol
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
LEFT JOIN transactions t_sent ON u.user_id = t_sent.sender_user_id
LEFT JOIN transactions t_received ON u.user_id = t_received.receiver_user_id
GROUP BY u.user_id, u.name, u.email, u.balance, c.currency_symbol
ORDER BY total_transactions DESC;

-- Uso de la vista
SELECT * FROM vw_user_transaction_summary;


-- =====================================================
-- VISTA 3: ÚLTIMAS TRANSACCIONES (HISTORIAL RECIENTE)
-- =====================================================

CREATE OR REPLACE VIEW vw_recent_transactions AS
SELECT
    t.transaction_id,
    t.transaction_date,
    TO_CHAR(t.transaction_date, 'DD/MM/YYYY HH24:MI:SS') AS formatted_date,
    sender.name AS sender_name,
    sender.email AS sender_email,
    receiver.name AS receiver_name,
    receiver.email AS receiver_email,
    t.amount,
    c.currency_symbol,
    c.currency_code,
    CONCAT(c.currency_symbol, ' ', TO_CHAR(t.amount, 'FM999,999,990.00')) AS formatted_amount,
    t.description,
    t.transaction_type
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.transaction_date DESC, t.transaction_id DESC
LIMIT 20;

-- Uso de la vista
SELECT * FROM vw_recent_transactions;


-- =====================================================
-- AGREGACIONES: TOTAL DE TRANSACCIONES POR USUARIO
-- Con COUNT, SUM, AVG, MIN, MAX, GROUP BY, HAVING
-- =====================================================

-- Estadísticas completas de transacciones enviadas por usuario
SELECT
    u.user_id,
    u.name,
    u.email,
    COUNT(t.transaction_id) AS total_transactions_sent,
    COALESCE(SUM(t.amount), 0) AS total_amount_sent,
    COALESCE(AVG(t.amount), 0) AS average_transaction_amount,
    COALESCE(MIN(t.amount), 0) AS min_transaction,
    COALESCE(MAX(t.amount), 0) AS max_transaction,
    MIN(t.transaction_date) AS first_transaction_date,
    MAX(t.transaction_date) AS last_transaction_date
FROM users u
LEFT JOIN transactions t ON u.user_id = t.sender_user_id
GROUP BY u.user_id, u.name, u.email
HAVING COUNT(t.transaction_id) > 0
ORDER BY total_amount_sent DESC;


-- =====================================================
-- SUBCONSULTAS: USUARIOS CON MÁS TRANSACCIONES QUE EL PROMEDIO
-- =====================================================

-- Usuarios que han enviado más transacciones que el promedio
SELECT
    u.user_id,
    u.name,
    u.email,
    (SELECT COUNT(*)
     FROM transactions
     WHERE sender_user_id = u.user_id) AS transactions_count,
    (SELECT ROUND(AVG(transaction_count))
     FROM (
         SELECT COUNT(*) AS transaction_count
         FROM transactions
         GROUP BY sender_user_id
     ) AS avg_calc) AS average_transactions
FROM users u
WHERE (SELECT COUNT(*)
       FROM transactions
       WHERE sender_user_id = u.user_id) >
      (SELECT AVG(transaction_count)
       FROM (
           SELECT COUNT(*) AS transaction_count
           FROM transactions
           GROUP BY sender_user_id
       ) AS avg_calc)
ORDER BY transactions_count DESC;


-- =====================================================
-- SUBCONSULTAS: USUARIOS QUE NUNCA HAN REALIZADO TRANSACCIONES
-- =====================================================

-- Usuarios sin transacciones enviadas
SELECT
    u.user_id,
    u.name,
    u.email,
    CONCAT(c.currency_symbol, ' ', u.balance) AS balance,
    u.created_at
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE NOT EXISTS (
    SELECT 1
    FROM transactions t
    WHERE t.sender_user_id = u.user_id
)
AND u.is_active = TRUE
ORDER BY u.created_at DESC;


-- =====================================================
-- REPORTE: VOLUMEN DE TRANSACCIONES POR MONEDA
-- =====================================================

SELECT
    c.currency_id,
    c.currency_name,
    c.currency_symbol,
    c.currency_code,
    COUNT(t.transaction_id) AS total_transactions,
    COALESCE(SUM(t.amount), 0) AS total_volume,
    COALESCE(AVG(t.amount), 0) AS average_transaction_amount,
    COALESCE(MIN(t.amount), 0) AS min_transaction,
    COALESCE(MAX(t.amount), 0) AS max_transaction,
    MIN(t.transaction_date) AS first_transaction_date,
    MAX(t.transaction_date) AS last_transaction_date
FROM currencies c
LEFT JOIN transactions t ON c.currency_id = t.currency_id
GROUP BY c.currency_id, c.currency_name, c.currency_symbol, c.currency_code
ORDER BY total_volume DESC NULLS LAST;


-- =====================================================
-- REPORTE: USUARIOS MÁS ACTIVOS (ENVIADOS + RECIBIDOS)
-- =====================================================

WITH user_activity AS (
    SELECT
        u.user_id,
        u.name,
        u.email,
        (SELECT COUNT(*) FROM transactions WHERE sender_user_id = u.user_id) AS sent_count,
        (SELECT COUNT(*) FROM transactions WHERE receiver_user_id = u.user_id) AS received_count
    FROM users u
)
SELECT
    user_id,
    name,
    email,
    sent_count,
    received_count,
    (sent_count + received_count) AS total_activity,
    ROUND((sent_count::NUMERIC / NULLIF(sent_count + received_count, 0)) * 100, 2) AS sent_percentage
FROM user_activity
WHERE (sent_count + received_count) > 0
ORDER BY total_activity DESC;


-- =====================================================
-- ANÁLISIS: BALANCE DE TRANSACCIONES POR USUARIO
-- (Cuánto ha enviado vs cuánto ha recibido)
-- =====================================================

SELECT
    u.user_id,
    u.name,
    u.email,
    c.currency_symbol,
    u.balance AS wallet_balance,
    COALESCE(sent.total_sent, 0) AS total_sent,
    COALESCE(sent.count_sent, 0) AS transactions_sent,
    COALESCE(received.total_received, 0) AS total_received,
    COALESCE(received.count_received, 0) AS transactions_received,
    COALESCE(received.total_received, 0) - COALESCE(sent.total_sent, 0) AS net_flow,
    CASE
        WHEN COALESCE(received.total_received, 0) > COALESCE(sent.total_sent, 0) THEN 'NET POSITIVE'
        WHEN COALESCE(received.total_received, 0) < COALESCE(sent.total_sent, 0) THEN 'NET NEGATIVE'
        ELSE 'BALANCED'
    END AS flow_status
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
LEFT JOIN (
    SELECT
        sender_user_id,
        SUM(amount) AS total_sent,
        COUNT(*) AS count_sent
    FROM transactions
    GROUP BY sender_user_id
) sent ON u.user_id = sent.sender_user_id
LEFT JOIN (
    SELECT
        receiver_user_id,
        SUM(amount) AS total_received,
        COUNT(*) AS count_received
    FROM transactions
    GROUP BY receiver_user_id
) received ON u.user_id = received.receiver_user_id
WHERE u.is_active = TRUE
ORDER BY net_flow DESC;


-- =====================================================
-- RANKING: TOP 10 TRANSACCIONES MÁS GRANDES
-- =====================================================

SELECT
    t.transaction_id,
    TO_CHAR(t.transaction_date, 'DD/MM/YYYY') AS date,
    sender.name AS from_user,
    receiver.name AS to_user,
    t.amount,
    c.currency_symbol,
    c.currency_code,
    CONCAT(c.currency_symbol, ' ', TO_CHAR(t.amount, 'FM999,999,990.00')) AS formatted_amount,
    t.description,
    RANK() OVER (ORDER BY t.amount DESC) AS amount_rank
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.amount DESC
LIMIT 10;


-- =====================================================
-- ANÁLISIS TEMPORAL: TRANSACCIONES POR DÍA
-- =====================================================

SELECT
    DATE(transaction_date) AS transaction_day,
    COUNT(*) AS daily_transactions,
    SUM(amount) AS daily_volume,
    AVG(amount) AS avg_transaction_amount,
    COUNT(DISTINCT sender_user_id) AS unique_senders,
    COUNT(DISTINCT receiver_user_id) AS unique_receivers
FROM transactions
GROUP BY DATE(transaction_date)
ORDER BY transaction_day DESC;


-- =====================================================
-- WINDOW FUNCTIONS: TRANSACCIONES CON RANKING POR USUARIO
-- =====================================================

SELECT
    t.transaction_id,
    t.sender_user_id,
    sender.name AS sender_name,
    t.amount,
    c.currency_symbol,
    t.transaction_date,
    ROW_NUMBER() OVER (PARTITION BY t.sender_user_id ORDER BY t.transaction_date DESC) AS transaction_number,
    RANK() OVER (PARTITION BY t.sender_user_id ORDER BY t.amount DESC) AS amount_rank_for_user,
    SUM(t.amount) OVER (PARTITION BY t.sender_user_id ORDER BY t.transaction_date) AS running_total
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.sender_user_id, t.transaction_date DESC;


-- =====================================================
-- ANÁLISIS: MATRIZ DE TRANSACCIONES ENTRE USUARIOS
-- (Quién le ha transferido a quién)
-- =====================================================

SELECT
    sender.name AS from_user,
    receiver.name AS to_user,
    COUNT(*) AS number_of_transactions,
    SUM(t.amount) AS total_amount_transferred,
    MIN(t.transaction_date) AS first_transaction,
    MAX(t.transaction_date) AS last_transaction
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
GROUP BY sender.user_id, sender.name, receiver.user_id, receiver.name
HAVING COUNT(*) >= 2
ORDER BY total_amount_transferred DESC;


-- =====================================================
-- ÍNDICE COMPUESTO: DEMOSTRACIÓN DE USO CON EXPLAIN
-- =====================================================

-- El índice idx_transactions_sender_date ya fue creado en 01_DDL_schema.sql
-- Ahora demostramos su uso con EXPLAIN ANALYZE

EXPLAIN ANALYZE
SELECT
    t.transaction_id,
    t.receiver_user_id,
    t.amount,
    t.transaction_date,
    t.description
FROM transactions t
WHERE t.sender_user_id = 1
ORDER BY t.transaction_date DESC
LIMIT 10;


-- =====================================================
-- CTE (Common Table Expressions): ANÁLISIS COMPLEJO
-- =====================================================

WITH monthly_stats AS (
    SELECT
        DATE_TRUNC('month', transaction_date) AS month,
        COUNT(*) AS transaction_count,
        SUM(amount) AS total_volume
    FROM transactions
    GROUP BY DATE_TRUNC('month', transaction_date)
),
user_counts AS (
    SELECT
        COUNT(*) AS total_users,
        COUNT(CASE WHEN is_active = TRUE THEN 1 END) AS active_users
    FROM users
)
SELECT
    ms.month,
    ms.transaction_count,
    ms.total_volume,
    uc.total_users,
    uc.active_users,
    ROUND(ms.total_volume / uc.active_users, 2) AS avg_volume_per_active_user
FROM monthly_stats ms
CROSS JOIN user_counts uc
ORDER BY ms.month DESC;


-- =====================================================
-- LISTAR TODAS LAS VISTAS CREADAS
-- =====================================================

SELECT
    table_name AS view_name,
    view_definition
FROM information_schema.views
WHERE table_schema = 'public'
    AND table_name LIKE 'vw_%'
ORDER BY table_name;


-- =====================================================
-- VERIFICAR RENDIMIENTO DE ÍNDICES
-- =====================================================

SELECT
    schemaname,
    relname AS tablename,
    indexrelname AS indexname,
    idx_scan AS index_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;


-- =====================================================
-- MENSAJE INFORMATIVO
-- =====================================================

DO $$
DECLARE
    v_view_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_view_count
    FROM information_schema.views
    WHERE table_schema = 'public' AND table_name LIKE 'vw_%';

    RAISE NOTICE '╔═════════════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  CONSULTAS AVANZADAS Y VISTAS - ALKE WALLET                     ║';
    RAISE NOTICE '╠═════════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║                                                                 ║';
    RAISE NOTICE '║  VISTAS CREADAS: %                                             ║', LPAD(v_view_count::TEXT, 2, ' ');
    RAISE NOTICE '║  ✓ vw_top_users_by_balance - Top 5 usuarios mayor saldo         ║';
    RAISE NOTICE '║  ✓ vw_user_transaction_summary - Resumen por usuario            ║';
    RAISE NOTICE '║  ✓ vw_recent_transactions - Últimas 20 transacciones            ║';
    RAISE NOTICE '║                                                                 ║';
    RAISE NOTICE '║  TÉCNICAS IMPLEMENTADAS:                                        ║';
    RAISE NOTICE '║  ✓ Agregaciones (COUNT, SUM, AVG, MIN, MAX)                     ║';
    RAISE NOTICE '║  ✓ GROUP BY y HAVING                                            ║';
    RAISE NOTICE '║  ✓ Subconsultas (IN, EXISTS, FROM)                              ║';
    RAISE NOTICE '║  ✓ JOINs múltiples                                              ║';
    RAISE NOTICE '║  ✓ Window Functions (ROW_NUMBER, RANK, SUM OVER)                ║';
    RAISE NOTICE '║  ✓ CTEs (Common Table Expressions / WITH)                       ║';
    RAISE NOTICE '║  ✓ EXPLAIN ANALYZE para optimización                            ║';
    RAISE NOTICE '║                                                                 ║';
    RAISE NOTICE '╚═════════════════════════════════════════════════════════════════╝';
END $$;

-- =====================================================
-- FIN DEL SCRIPT DE CONSULTAS AVANZADAS
-- =====================================================
