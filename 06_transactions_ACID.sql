-- =====================================================
-- ALKE WALLET - TRANSACCIONES ACID
-- PostgreSQL 17.6
-- Autor: Proyecto Alke Wallet
-- Fecha: 11 de febrero de 2026
-- Descripción: Demostración de propiedades ACID (Atomicity, Consistency, Isolation, Durability)
-- =====================================================

-- Nota: Las propiedades ACID son fundamentales para garantizar la integridad de datos
-- Conectarse a la base de datos: \c alke_wallet


-- =====================================================
-- TABLA DE PROPIEDADES ACID (PARA DOCUMENTACIÓN)
-- =====================================================

/*
╔══════════════════╦═══════════════════════════════════════════════════════════════════════════╗
║ Propiedad        ║ Descripción e Implementación en Alke Wallet                               ║
╠══════════════════╬═══════════════════════════════════════════════════════════════════════════╣
║ ATOMICITY        ║ Una transacción es todo o nada. Si una parte falla, se revierte TODO     ║
║ (Atomicidad)     ║ con ROLLBACK. En transferencias, si falla el débito del emisor, no se    ║
║                  ║ acredita al receptor. PostgreSQL garantiza esto con BEGIN/COMMIT.        ║
╠══════════════════╬═══════════════════════════════════════════════════════════════════════════╣
║ CONSISTENCY      ║ La BD pasa de un estado válido a otro. Los constraints (CHECK, FK,       ║
║ (Consistencia)   ║ NOT NULL, UNIQUE) garantizan que balance >= 0, emails únicos, montos      ║
║                  ║ positivos, etc. PostgreSQL valida todas las reglas antes de COMMIT.      ║
╠══════════════════╬═══════════════════════════════════════════════════════════════════════════╣
║ ISOLATION        ║ Transacciones concurrentes no interfieren entre sí. PostgreSQL maneja    ║
║ (Aislamiento)    ║ niveles de aislamiento (READ COMMITTED por defecto) para evitar lecturas ║
║                  ║ sucias (dirty reads), lecturas no repetibles y fantasmas.                ║
╠══════════════════╬═══════════════════════════════════════════════════════════════════════════╣
║ DURABILITY       ║ Una vez hecho COMMIT, los datos persisten incluso ante fallos del        ║
║ (Durabilidad)    ║ sistema (crash del servidor, corte de energía). PostgreSQL escribe en    ║
║                  ║ WAL (Write-Ahead Log) antes de confirmar cambios.                         ║
╚══════════════════╩═══════════════════════════════════════════════════════════════════════════╝
*/


-- =====================================================
-- ESCENARIO 1: COMMIT - TRANSACCIÓN EXITOSA
-- Demostración de: ATOMICITY y DURABILITY
-- =====================================================

-- Paso 1: Verificar estado inicial de los usuarios
SELECT
    user_id,
    name,
    CONCAT(c.currency_symbol, ' ', balance) AS balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE user_id IN (5, 6)
ORDER BY user_id;

-- Paso 2: Iniciar transacción
BEGIN;

    -- Operación 1: Descontar del emisor (Usuario 5: Pedro Sánchez)
    UPDATE users
    SET
        balance = balance - 2000.00,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = 5;

    -- Verificar descuento intermedio (solo visible dentro de esta transacción)
    SELECT user_id, name, balance FROM users WHERE user_id = 5;

    -- Operación 2: Acreditar al receptor (Usuario 6: Laura Fernández)
    UPDATE users
    SET
        balance = balance + 2000.00,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = 6;

    -- Verificar acreditación intermedia
    SELECT user_id, name, balance FROM users WHERE user_id = 6;

    -- Operación 3: Registrar la transacción
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
    VALUES (5, 6, 2000.00, 1, 'Transferencia ACID test - COMMIT exitoso')
    RETURNING transaction_id, transaction_date, amount;

    -- Verificar estado antes de confirmar
    SELECT
        user_id,
        name,
        balance
    FROM users
    WHERE user_id IN (5, 6)
    ORDER BY user_id;

-- Paso 3: CONFIRMAR todos los cambios (COMMIT)
COMMIT;

-- Paso 4: Verificación final DESPUÉS del COMMIT
SELECT
    user_id,
    name,
    CONCAT(c.currency_symbol, ' ', balance) AS new_balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE user_id IN (5, 6)
ORDER BY user_id;

-- Verificar que la transacción se registró
SELECT * FROM transactions WHERE description LIKE '%COMMIT exitoso%';

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 1 COMPLETADO: Transacción confirmada con COMMIT';
END $$;


-- =====================================================
-- ESCENARIO 2: ROLLBACK - TRANSACCIÓN FALLIDA/CANCELADA
-- Demostración de: ATOMICITY
-- =====================================================

-- Paso 1: Verificar estado inicial
SELECT user_id, name, balance FROM users WHERE user_id IN (1, 2);

-- Paso 2: Iniciar transacción que será revertida
BEGIN;

    -- Operación 1: Descontar del emisor
    UPDATE users
    SET
        balance = balance - 5000.00,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = 1;

    -- Verificar cambio temporal
    SELECT user_id, name, balance FROM users WHERE user_id = 1;

    -- Operación 2: Acreditar al receptor
    UPDATE users
    SET
        balance = balance + 5000.00,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = 2;

    -- Operación 3: Registrar transacción
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
    VALUES (1, 2, 5000.00, 1, 'Transacción que será ROLLBACK');

    -- Verificar estado intermedio
    SELECT user_id, name, balance FROM users WHERE user_id IN (1, 2);

-- Paso 3: REVERTIR todos los cambios (ROLLBACK)
ROLLBACK;

-- Paso 4: Verificación - Los saldos deben estar IGUALES al estado inicial
SELECT
    user_id,
    name,
    balance AS balance_after_rollback
FROM users
WHERE user_id IN (1, 2);

-- Verificar que NO se registró la transacción
SELECT * FROM transactions WHERE description LIKE '%será ROLLBACK%';
-- Debería retornar 0 filas

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 2 COMPLETADO: Transacción revertida con ROLLBACK';
END $$;


-- =====================================================
-- ESCENARIO 3: ATOMICIDAD - TODO O NADA
-- Si UNA operación falla, TODAS se revierten automáticamente
-- Demostración de: ATOMICITY y CONSISTENCY
-- =====================================================

-- Paso 1: Verificar estado inicial
SELECT user_id, name, balance FROM users WHERE user_id IN (3, 4);

-- Paso 2: Intentar transacción que fallará
BEGIN;

    -- Operación 1: Descontar del emisor (OK)
    UPDATE users
    SET balance = balance - 100.00
    WHERE user_id = 3;

    -- Operación 2: Intentar crear saldo NEGATIVO en receptor (FALLARÁ)
    -- Esto violará el constraint CHECK (balance >= 0)
    UPDATE users
    SET balance = balance - 999999.00  -- Forzar saldo negativo
    WHERE user_id = 4;
    -- ERROR: el nuevo registro para la relación "users" viola la restricción «check» «chk_users_balance_positive»

    -- Operación 3: Registrar transacción (NO SE EJECUTARÁ debido al error anterior)
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
    VALUES (3, 4, 100.00, 3, 'Transacción que falla por constraint');

COMMIT; -- Intentar confirmar (NO se ejecutará debido al error)

-- En caso de error, PostgreSQL automáticamente hace ROLLBACK

-- Paso 3: Verificar que NADA cambió (atomicidad)
SELECT
    user_id,
    name,
    balance AS balance_unchanged
FROM users
WHERE user_id IN (3, 4);

-- Mensaje de confirmación
DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 3: Si una operación falla, todo se revierte automáticamente';
END $$;


-- =====================================================
-- ESCENARIO 4: CONSISTENCIA - VIOLACIÓN DE CONSTRAINTS CHECK
-- Demostración de: CONSISTENCY
-- =====================================================

-- Intento 1: Crear saldo negativo (viola CHECK constraint)
BEGIN;
    UPDATE users
    SET balance = -1000.00
    WHERE user_id = 7;
    -- ERROR: new row for relation "users" violates check constraint "users_balance_positive_ck"
ROLLBACK;

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 4.1: Constraint CHECK impide saldos negativos';
END $$;


-- Intento 2: Transferencia con mismo emisor y receptor (viola CHECK constraint)
BEGIN;
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
    VALUES (1, 1, 100.00, 1, 'Auto-transferencia no permitida');
    -- ERROR: violates check constraint "transactions_different_users_ck"
ROLLBACK;

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 4.2: Constraint CHECK impide auto-transferencias';
END $$;


-- Intento 3: Monto negativo o cero (viola CHECK constraint)
BEGIN;
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
    VALUES (1, 2, 0, 1, 'Monto cero no permitido');
    -- ERROR: violates check constraint "transactions_amount_positive_ck"
ROLLBACK;

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 4.3: Constraint CHECK impide montos <= 0';
END $$;


-- =====================================================
-- ESCENARIO 5: CONSISTENCIA - VIOLACIÓN DE FOREIGN KEY
-- Demostración de: CONSISTENCY
-- =====================================================

-- Intento 1: Insertar usuario con moneda inexistente
BEGIN;
    INSERT INTO users (name, email, password, balance, currency_id)
    VALUES ('Usuario con FK inválida', 'fk.invalid@test.com', 'HASH:test', 1000.00, 999);
    -- ERROR: insert or update on table "users" violates foreign key constraint
ROLLBACK;

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 5.1: Foreign Key impide monedas inexistentes';
END $$;


-- Intento 2: Transacción con usuario inexistente
BEGIN;
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
    VALUES (999, 1, 100.00, 1, 'Usuario inexistente');
    -- ERROR: violates foreign key constraint "transactions_sender_fk"
ROLLBACK;

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 5.2: Foreign Key impide usuarios inexistentes';
END $$;


-- Intento 3: Eliminar moneda que está siendo usada (ON DELETE RESTRICT)
BEGIN;
    DELETE FROM currencies WHERE currency_id = 1;
    -- ERROR: update or delete on table "currencies" violates foreign key constraint
    -- DETAIL: Key (currency_id)=(1) is still referenced from table "users"
ROLLBACK;

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 5.3: ON DELETE RESTRICT protege datos referenciados';
END $$;


-- =====================================================
-- ESCENARIO 6: AISLAMIENTO - NIVELES DE AISLAMIENTO
-- Demostración de: ISOLATION
-- =====================================================

-- Mostrar nivel de aislamiento actual
SHOW transaction_isolation;
-- Por defecto en PostgreSQL: "read committed"

-- Ejemplo de configuración de niveles de aislamiento
-- (Solo referencia, no necesario ejecutar)

-- Nivel 1: READ UNCOMMITTED (PostgreSQL lo trata como READ COMMITTED)
-- SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Nivel 2: READ COMMITTED (defecto en PostgreSQL)
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Nivel 3: REPEATABLE READ
-- SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Nivel 4: SERIALIZABLE (más estricto)
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 6: Nivel de aislamiento verificado';
END $$;


-- =====================================================
-- ESCENARIO 7: DURABILIDAD
-- Demostración de: DURABILITY
-- =====================================================

/*
La durabilidad se demuestra al reiniciar el servidor PostgreSQL:

1. Los datos guardados con COMMIT sobreviven al reinicio
2. Los datos no confirmados (sin COMMIT) se pierden
3. PostgreSQL usa Write-Ahead Logging (WAL) para garantizar esto

Para verificar:
1. Ejecutar una transacción con COMMIT
2. Reiniciar el servicio PostgreSQL:
   Windows: net stop postgresql-x64-17 && net start postgresql-x64-17
   Linux: sudo systemctl restart postgresql
3. Reconectar y verificar que los datos persisten

Esto NO se puede automatizar en un script, pero es el concepto de DURABILITY.
*/

-- Crear una transacción de prueba de durabilidad
BEGIN;
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
    VALUES (1, 2, 999.99, 1, 'TEST DE DURABILIDAD - Esta transacción debe sobrevivir reinicio')
    RETURNING transaction_id, transaction_date;
COMMIT;

-- Verificar que se guardó
SELECT * FROM transactions WHERE description LIKE '%TEST DE DURABILIDAD%';

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 7: Transacción guardada con COMMIT (sobrevivirá a reinicio del servidor)';
END $$;


-- =====================================================
-- ESCENARIO 8: TRANSACCIÓN COMPLEJA CON MÚLTIPLES OPERACIONES
-- Demostración combinada de todas las propiedades ACID
-- =====================================================

-- Escenario realista: Transferencia multi-paso con validaciones

-- Paso 1: Verificar saldo inicial
SELECT user_id, name, balance FROM users WHERE user_id = 1;

-- Paso 2: Iniciar transacción compleja
BEGIN;

    -- Operación 1: Descontar del emisor
    UPDATE users
    SET
        balance = balance - 3000.00,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = 1
    RETURNING user_id, name, balance;

    -- Operación 2: Acreditar al receptor
    UPDATE users
    SET
        balance = balance + 3000.00,
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = 2
    RETURNING user_id, name, balance;

    -- Operación 3: Registrar transacción
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description, transaction_type)
    VALUES (1, 2, 3000.00, 1, 'Transferencia compleja multi-paso ACID', 'transfer')
    RETURNING transaction_id, transaction_date, amount, description;

    -- Verificación intermedia: Balance aún positivo
    SELECT user_id, name, balance FROM users WHERE user_id IN (1, 2);

-- Paso 3: CONFIRMAR toda la transacción compleja
COMMIT;

-- Verificar resultado final
SELECT
    user_id,
    name,
    CONCAT(c.currency_symbol, ' ', balance) AS final_balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE user_id IN (1, 2);

DO $$
BEGIN
    RAISE NOTICE '✓ ESCENARIO 8 COMPLETADO: Transacción compleja exitosa';
END $$;


-- =====================================================
-- RESUMEN DE TRANSACCIONES ACID EJECUTADAS
-- =====================================================

SELECT
    transaction_id,
    TO_CHAR(transaction_date, 'DD/MM/YYYY HH24:MI:SS') AS date_time,
    sender_user_id,
    receiver_user_id,
    CONCAT(c.currency_symbol, ' ', amount) AS amount,
    description
FROM transactions t
INNER JOIN currencies c ON t.currency_id = c.currency_id
WHERE description LIKE '%ACID%'
   OR description LIKE '%TEST DE DURABILIDAD%'
   OR description LIKE '%Transferencia compleja%'
ORDER BY transaction_date DESC;


-- =====================================================
-- ESTADÍSTICAS DE INTEGRIDAD DE LA BASE DE DATOS
-- =====================================================

SELECT
    'Total Usuarios' AS metric,
    COUNT(*)::TEXT AS value
FROM users
UNION ALL
SELECT
    'Usuarios Activos',
    COUNT(*)::TEXT
FROM users
WHERE is_active = TRUE
UNION ALL
SELECT
    'Total Transacciones',
    COUNT(*)::TEXT
FROM transactions
UNION ALL
SELECT
    'Saldos Negativos (ERROR)',
    COUNT(*)::TEXT
FROM users
WHERE balance < 0
UNION ALL
SELECT
    'Emails Duplicados (ERROR)',
    COUNT(*)::TEXT
FROM (
    SELECT email FROM users GROUP BY email HAVING COUNT(*) > 1
) AS duplicates
UNION ALL
SELECT
    'Transacciones Auto-transferencia (ERROR)',
    COUNT(*)::TEXT
FROM transactions
WHERE sender_user_id = receiver_user_id;


-- =====================================================
-- MENSAJE FINAL
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '╔═══════════════════════════════════════════════════════════════════════════════╗';
    RAISE NOTICE '║                   PROPIEDADES ACID - ALKE WALLET                              ║';
    RAISE NOTICE '╠═══════════════════════════════════════════════════════════════════════════════╣';
    RAISE NOTICE '║                                                                               ║';
    RAISE NOTICE '║  ✓ ATOMICITY (Atomicidad):                                                    ║';
    RAISE NOTICE '║    • Escenario 1: COMMIT exitoso - Todas las operaciones confirmadas          ║';
    RAISE NOTICE '║    • Escenario 2: ROLLBACK - Todas las operaciones revertidas                 ║';
    RAISE NOTICE '║    • Escenario 3: Fallo parcial - Todo se revierte automáticamente            ║';
    RAISE NOTICE '║                                                                               ║';
    RAISE NOTICE '║  ✓ CONSISTENCY (Consistencia):                                                ║';
    RAISE NOTICE '║    • Escenario 4: CHECK constraints validados                                 ║';
    RAISE NOTICE '║    • Escenario 5: FOREIGN KEY constraints validados                           ║';
    RAISE NOTICE '║    • Balance >= 0, montos > 0, emails únicos, etc.                            ║';
    RAISE NOTICE '║                                                                               ║';
    RAISE NOTICE '║  ✓ ISOLATION (Aislamiento):                                                   ║';
    RAISE NOTICE '║    • Escenario 6: Nivel READ COMMITTED verificado                             ║';
    RAISE NOTICE '║    • Transacciones concurrentes aisladas entre sí                             ║';
    RAISE NOTICE '║                                                                               ║';
    RAISE NOTICE '║  ✓ DURABILITY (Durabilidad):                                                  ║';
    RAISE NOTICE '║    • Escenario 7: COMMIT persiste datos ante reinicio                         ║';
    RAISE NOTICE '║    • PostgreSQL usa WAL (Write-Ahead Logging)                                 ║';
    RAISE NOTICE '║                                                                               ║';
    RAISE NOTICE '║  ✓ ESCENARIO 8: Transacción compleja multi-paso ejecutada exitosamente        ║';
    RAISE NOTICE '║                                                                               ║';
    RAISE NOTICE '╚═══════════════════════════════════════════════════════════════════════════════╝';
    RAISE NOTICE '';
    RAISE NOTICE '🎓 RECOMENDACIÓN: Capturar pantallas de los COMMIT y ROLLBACK para el documento';
    RAISE NOTICE '';
END $$;

-- =====================================================
-- FIN DEL SCRIPT DE TRANSACCIONES ACID
-- =====================================================
