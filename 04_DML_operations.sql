-- =====================================================
-- ALKE WALLET - OPERACIONES DML (MANIPULACIÓN DE DATOS)
-- PostgreSQL 17.6
-- Autor: Proyecto Alke Wallet
-- Fecha: 11 de febrero de 2026
-- Descripción: Operaciones INSERT, UPDATE y DELETE requeridas en la consigna
-- =====================================================

-- Nota: Asegúrate de haber ejecutado primero:
--   1. 01_DDL_schema.sql
--   2. 02_DML_seed_data.sql
-- Conectarse a la base de datos: \c alke_wallet


-- =====================================================
-- OPERACIÓN 1: MODIFICAR EL CAMPO CORREO ELECTRÓNICO DE UN USUARIO ESPECÍFICO
-- Requerimiento: Sentencia DML para UPDATE del email
-- Tabla: users
-- =====================================================

-- PASO 1: Verificar estado ANTES del cambio
SELECT
    user_id,
    name,
    email,
    updated_at
FROM users
WHERE user_id = 1;

-- PASO 2: Ejecutar UPDATE - Modificar email del usuario ID = 1
UPDATE users
SET
    email = 'juan.perez.nuevo@alkewallet.com',
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 1;

-- PASO 3: Verificar estado DESPUÉS del cambio
SELECT
    user_id,
    name,
    email,
    updated_at
FROM users
WHERE user_id = 1;


-- =====================================================
-- OPERACIÓN 1 - VARIANTES ADICIONALES
-- =====================================================

-- Ejemplo 2: Modificar email buscando por email anterior
-- (Primero verificar que existe)
SELECT user_id, name, email FROM users WHERE email = 'maria.gonzalez@alkewallet.com';

UPDATE users
SET
    email = 'maria.gonzalez.updated@alkewallet.com',
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'maria.gonzalez@alkewallet.com';

-- Verificar cambio
SELECT user_id, name, email, updated_at FROM users WHERE user_id = 2;

-- Ejemplo 3: Modificar email con RETURNING (buena práctica PostgreSQL)
UPDATE users
SET
    email = 'carlos.rodriguez.updated@alkewallet.com',
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 3
RETURNING user_id, name, email AS new_email, updated_at;

-- Ejemplo 4: Cambio masivo - Actualizar dominio de emails
-- (Descomentar para ejecutar)
-- UPDATE users
-- SET
--     email = REPLACE(email, '@alkewallet.com', '@alkewallet.cl'),
--     updated_at = CURRENT_TIMESTAMP
-- WHERE email LIKE '%@alkewallet.com'
-- RETURNING user_id, name, email;


-- =====================================================
-- OPERACIÓN 2: ELIMINAR LOS DATOS DE UNA TRANSACCIÓN (FILA COMPLETA)
-- Requerimiento: Sentencia DELETE de una transacción
-- Tabla: transactions
-- =====================================================

-- PASO 1: Verificar que la transacción existe ANTES de eliminar
SELECT
    transaction_id,
    transaction_date,
    sender_user_id,
    receiver_user_id,
    amount,
    currency_id,
    description
FROM transactions
WHERE transaction_id = 35;

-- PASO 2: Ejecutar DELETE - Eliminar transacción con ID = 35
DELETE FROM transactions
WHERE transaction_id = 35;

-- PASO 3: Verificar que se eliminó (debería retornar 0 filas)
SELECT
    transaction_id,
    transaction_date,
    sender_user_id,
    receiver_user_id,
    amount,
    description
FROM transactions
WHERE transaction_id = 35;

-- PASO 4: Verificar total de transacciones restantes
SELECT COUNT(*) AS total_transactions_remaining FROM transactions;


-- =====================================================
-- OPERACIÓN 2 - VARIANTES ADICIONALES
-- =====================================================

-- Ejemplo 2: Eliminar con RETURNING para confirmar qué se eliminó
-- (Crea una transacción temporal primero)
INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
VALUES (1, 2, 100.00, 1, 'Transacción temporal para eliminar')
RETURNING transaction_id, sender_user_id, receiver_user_id, amount;

-- Asumiendo que el ID insertado es el último
DELETE FROM transactions
WHERE description = 'Transacción temporal para eliminar'
RETURNING transaction_id, amount, description AS deleted_transaction;

-- Ejemplo 3: Eliminar transacciones antiguas (ejemplo condicional)
-- CUIDADO: Esto eliminaría múltiples filas, usar con precaución
-- DELETE FROM transactions
-- WHERE transaction_date < CURRENT_DATE - INTERVAL '1 year'
-- RETURNING transaction_id, transaction_date;

-- Ejemplo 4: Eliminar transacciones de un usuario específico
-- (Solo para demostración - NO ejecutar en producción sin análisis)
-- DELETE FROM transactions
-- WHERE sender_user_id = 10 AND receiver_user_id = 10
-- RETURNING transaction_id;


-- =====================================================
-- OPERACIÓN 3: INSERTAR NUEVA TRANSACCIÓN (ADICIONAL)
-- Demostración de INSERT individual con RETURNING
-- =====================================================

-- Insertar nueva transacción entre usuarios existentes
INSERT INTO transactions (
    sender_user_id,
    receiver_user_id,
    amount,
    currency_id,
    description,
    transaction_type
)
VALUES (
    5,  -- Pedro Sánchez
    6,  -- Laura Fernández
    2500.00,
    1,  -- CLP
    'Nueva transacción de prueba DML',
    'transfer'
)
RETURNING
    transaction_id,
    transaction_date,
    sender_user_id,
    receiver_user_id,
    amount,
    description;

-- Verificar la transacción insertada con JOIN
SELECT
    t.transaction_id,
    t.transaction_date,
    sender.name AS sender_name,
    receiver.name AS receiver_name,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.description
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.transaction_id DESC
LIMIT 1;


-- =====================================================
-- OPERACIÓN 4: ACTUALIZAR SALDO DE USUARIO TRAS TRANSACCIÓN (ADICIONAL)
-- Demostración de UPDATE con lógica de negocio
-- IMPORTANTE: En producción esto debería hacerse en una TRANSACCIÓN ACID
-- =====================================================

-- Escenario: Usuario 1 transfiere $1000 CLP a Usuario 6
-- (Asumiendo ambos usuarios tienen currency_id = 1 para CLP)

-- Verificar saldos ANTES
SELECT
    user_id,
    name,
    CONCAT(c.currency_symbol, ' ', balance) AS current_balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE user_id IN (1, 6);

-- INICIO DE TRANSACCIÓN ACID (explicado en detalle en 06_transactions_ACID.sql)
BEGIN;

-- Descontar del emisor (sender)
UPDATE users
SET
    balance = balance - 1000.00,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 1
RETURNING user_id, name, balance;

-- Acreditar al receptor (receiver)
UPDATE users
SET
    balance = balance + 1000.00,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 6
RETURNING user_id, name, balance;

-- Registrar la transacción
INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
VALUES (1, 6, 1000.00, 1, 'Transferencia de prueba con actualización de saldos')
RETURNING transaction_id, transaction_date, amount;

-- Verificar saldos DESPUÉS
SELECT
    user_id,
    name,
    CONCAT(c.currency_symbol, ' ', balance) AS new_balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE user_id IN (1, 6);

-- CONFIRMAR CAMBIOS (comentar si quieres revertir)
COMMIT;
-- O usar ROLLBACK; para deshacer todos los cambios


-- =====================================================
-- OPERACIÓN 5: ACTUALIZAR OTROS CAMPOS DE USUARIO (ADICIONAL)
-- =====================================================

-- Cambiar nombre de usuario
UPDATE users
SET
    name = 'Juan Carlos Pérez Gómez',
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 1
RETURNING user_id, name, email, updated_at;

-- Cambiar moneda predeterminada de un usuario
UPDATE users
SET
    currency_id = 2,  -- Cambiar a USD
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 7
RETURNING user_id, name, currency_id, updated_at;

-- Ajustar saldo manualmente (con validación de constraint)
UPDATE users
SET
    balance = 10000.00,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 8
RETURNING user_id, name, balance, updated_at;

-- Desactivar usuario (soft delete)
UPDATE users
SET
    is_active = FALSE,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 9
RETURNING user_id, name, is_active, updated_at;

-- Reactivar usuario
UPDATE users
SET
    is_active = TRUE,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 9
RETURNING user_id, name, is_active, updated_at;


-- =====================================================
-- VERIFICACIÓN FINAL DE INTEGRIDAD
-- =====================================================

-- Verificar que no hay emails duplicados
SELECT email, COUNT(*)
FROM users
GROUP BY email
HAVING COUNT(*) > 1;

-- Verificar que todos los saldos son no negativos
SELECT user_id, name, balance
FROM users
WHERE balance < 0;

-- Verificar integridad referencial en transactions
SELECT t.transaction_id
FROM transactions t
LEFT JOIN users sender ON t.sender_user_id = sender.user_id
LEFT JOIN users receiver ON t.receiver_user_id = receiver.user_id
LEFT JOIN currencies c ON t.currency_id = c.currency_id
WHERE sender.user_id IS NULL
   OR receiver.user_id IS NULL
   OR c.currency_id IS NULL;

-- Estadísticas actualizadas después de las operaciones
SELECT
    (SELECT COUNT(*) FROM currencies) AS total_currencies,
    (SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM transactions) AS total_transactions,
    (SELECT COUNT(*) FROM users WHERE is_active = TRUE) AS active_users,
    (SELECT COUNT(*) FROM users WHERE is_active = FALSE) AS inactive_users;


-- =====================================================
-- MENSAJE INFORMATIVO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '╔═══════════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║  OPERACIONES DML COMPLETADAS - ALKE WALLET                    ║';
    RAISE NOTICE '╠═══════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║                                                               ║';
    RAISE NOTICE '║  ✓ UPDATE de email de usuario específico                      ║';
    RAISE NOTICE '║  ✓ DELETE de transacción completa                             ║';
    RAISE NOTICE '║  ✓ INSERT de nueva transacción                                ║';
    RAISE NOTICE '║  ✓ UPDATE de saldos tras transacción (con ACID)               ║';
    RAISE NOTICE '║  ✓ Operaciones adicionales de UPDATE variadas                 ║';
    RAISE NOTICE '║                                                               ║';
    RAISE NOTICE '║  REQUERIMIENTOS CUMPLIDOS:                                    ║';
    RAISE NOTICE '║  ✓ Modificar correo electrónico de usuario                    ║';
    RAISE NOTICE '║  ✓ Eliminar datos de transacción (fila completa)              ║';
    RAISE NOTICE '║                                                               ║';
    RAISE NOTICE '╚═══════════════════════════════════════════════════════════════╝';
END $$;

-- =====================================================
-- FIN DEL SCRIPT DE OPERACIONES DML
-- =====================================================
