# 🚀 Guía Rápida de Ejecución - Alke Wallet

## 📌 Inicio Rápido (5 minutos)

### Paso 1: Abrir PostgreSQL

**Opción A: Usando psql (Línea de comandos)**

```powershell
# Abrir PowerShell como Administrador
psql -U postgres
```

**Opción B: Usando DBeaver**

1. Abrir DBeaver
2. Conectarse a PostgreSQL (localhost:5432)
3. Usuario: `postgres`
4. Abrir SQL Editor

---

### Paso 2: Crear la Base de Datos

```sql
-- Ejecutar en psql o DBeaver
CREATE DATABASE alke_wallet
    WITH
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Spain.1252'
    LC_CTYPE = 'Spanish_Spain.1252';

-- Conectarse a la nueva base de datos
\c alke_wallet
-- En DBeaver: seleccionar alke_wallet del dropdown
```

---

### Paso 3: Ejecutar Scripts en Orden

#### 3.1 Crear Tablas e Índices

```powershell
# Desde PowerShell en la carpeta del proyecto
cd C:\Users\eduar\OneDrive\EM_Cursos\TD_Python_Trainee\M5\proyecto

psql -U postgres -d alke_wallet -f 01_DDL_schema.sql
```

**O en DBeaver:**

1. Abrir `01_DDL_schema.sql`
2. Seleccionar todo (Ctrl+A)
3. Ejecutar (Ctrl+Enter o F5)

**Resultado esperado:**

```
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX
...
```

---

#### 3.2 Cargar Datos Iniciales

```powershell
psql -U postgres -d alke_wallet -f 02_DML_seed_data.sql
```

**Resultado esperado:**

```
INSERT 0 6   (currencies)
INSERT 0 10  (users)
INSERT 0 20  (transactions)
```

---

#### 3.3 Probar Consultas

```powershell
psql -U postgres -d alke_wallet -f 03_queries.sql
```

**Resultado esperado:**

- Listado de usuarios con sus monedas
- Todas las transacciones
- Transacciones por usuario

---

### Paso 4: Verificar Instalación

```sql
-- Verificar tablas creadas
\dt

-- Contar registros
SELECT 'Monedas' AS tabla, COUNT(*) FROM currencies
UNION ALL
SELECT 'Usuarios', COUNT(*) FROM users
UNION ALL
SELECT 'Transacciones', COUNT(*) FROM transactions;
```

**Resultado esperado:**

```
    tabla      | count
---------------+-------
 Monedas       |     6
 Usuarios      |    10
 Transacciones |    20
```

---

## 🎯 Orden de Ejecución de Scripts

| #   | Archivo                    | Descripción         | ¿Obligatorio? |
| --- | -------------------------- | ------------------- | ------------- |
| 1️⃣  | `01_DDL_schema.sql`        | Crear BD y tablas   | ✅ SÍ         |
| 2️⃣  | `02_DML_seed_data.sql`     | Cargar datos        | ✅ SÍ         |
| 3️⃣  | `03_queries.sql`           | Probar consultas    | ✅ SÍ         |
| 4️⃣  | `04_DML_operations.sql`    | UPDATE/DELETE       | ✅ SÍ         |
| 5️⃣  | `05_advanced_queries.sql`  | Vistas y análisis   | 💡 Plus       |
| 6️⃣  | `06_transactions_ACID.sql` | Demostraciones ACID | 💡 Plus       |
| 7️⃣  | `07_validations.sql`       | Tests de integridad | 💡 Plus       |

---

## 📸 Capturas de Pantalla para el Documento Word

### Lista de Capturas Necesarias:

#### En DBeaver/pgAdmin:

**1. Creación de Base de Datos** (`01_create_database.png`)

```sql
CREATE DATABASE alke_wallet;
-- Captura: pantalla mostrando "CREATE DATABASE" exitoso
```

**2. Tablas Creadas** (`02_create_tables.png`)

```sql
\dt
-- o en DBeaver: ver lista de tablas
```

**3. Consulta 1 - Moneda de Usuario** (`03_query_user_currency.png`)

```sql
SELECT u.name, c.currency_name, u.balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE u.user_id = 1;
```

**4. Consulta 2 - Todas las Transacciones** (`04_query_all_trans.png`)

```sql
SELECT
    sender.name AS from_user,
    receiver.name AS to_user,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
LIMIT 10;
```

**5. Consulta 3 - Transacciones por Usuario** (`05_query_user_trans.png`)

```sql
SELECT
    receiver.name AS sent_to,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.description
FROM transactions t
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
WHERE t.sender_user_id = 1;
```

**6. UPDATE Email - Antes** (`06_update_before.png`)

```sql
SELECT user_id, name, email FROM users WHERE user_id = 1;
-- Captura ANTES de modificar
```

**7. UPDATE Email - Después** (`06_update_after.png`)

```sql
UPDATE users
SET email = 'nuevo.email@alkewallet.com', updated_at = CURRENT_TIMESTAMP
WHERE user_id = 1;

SELECT user_id, name, email FROM users WHERE user_id = 1;
-- Captura DESPUÉS de modificar
```

**8. DELETE Transacción** (`07_delete_transaction.png`)

```sql
SELECT * FROM transactions WHERE transaction_id = 20;
DELETE FROM transactions WHERE transaction_id = 20;
SELECT COUNT(*) FROM transactions;
-- Captura mostrando confirmación
```

**9. COMMIT Exitoso** (`08_commit.png`)

```sql
BEGIN;
-- ... operaciones ...
COMMIT;
-- Captura mostrando mensaje "COMMIT"
```

**10. ROLLBACK** (`09_rollback.png`)

```sql
BEGIN;
-- ... operaciones ...
ROLLBACK;
-- Captura mostrando mensaje "ROLLBACK"
```

---

## 🎨 Crear Diagrama ER

### Herramienta Recomendada: dbdiagram.io

1. **Ir a:** https://dbdiagram.io/
2. **Crear cuenta gratis** (con Google/GitHub)
3. **Copiar este código DBML:**

```dbml
Table currencies {
  currency_id serial [pk, increment]
  currency_name varchar(50) [not null, unique]
  currency_symbol varchar(10) [not null]
  currency_code char(3) [not null, unique]
  created_at timestamp [default: `now()`]
}

Table users {
  user_id serial [pk, increment]
  name varchar(100) [not null]
  email varchar(255) [not null, unique]
  password varchar(255) [not null]
  balance decimal(15,2) [not null, default: 0]
  currency_id integer [not null, ref: > currencies.currency_id]
  is_active boolean [default: true]
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
}

Table transactions {
  transaction_id serial [pk, increment]
  sender_user_id integer [not null, ref: > users.user_id]
  receiver_user_id integer [not null, ref: > users.user_id]
  amount decimal(15,2) [not null]
  currency_id integer [not null, ref: > currencies.currency_id]
  transaction_date timestamp [default: `now()`]
  description varchar(255)
  transaction_type varchar(20) [default: 'transfer']
  created_at timestamp [default: `now()`]
}
```

4. **El diagrama se genera automáticamente**
5. **Exportar:**
   - Clic en "Export" (arriba derecha)
   - Descargar como PNG (para insertar en Word)
   - Descargar como PDF (alta calidad)
6. **Guardar en:** `diagrams/ERD_AlkeWallet.png` y `.pdf`

---

## ⚡ Comandos Útiles PostgreSQL

### Ver Información de la BD

```sql
-- Ver todas las bases de datos
\l

-- Conectarse a alke_wallet
\c alke_wallet

-- Ver todas las tablas
\dt

-- Ver estructura de una tabla
\d users
\d currencies
\d transactions

-- Ver todas las constraints
SELECT
    constraint_name,
    table_name,
    constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public';

-- Ver todos los índices
SELECT
    tablename,
    indexname
FROM pg_indexes
WHERE schemaname = 'public';

-- Ver todas las vistas
\dv
```

### Limpiar y Reiniciar

```sql
-- Eliminar todas las tablas (CUIDADO!)
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS currencies CASCADE;

-- Eliminar base de datos completa (CUIDADO!)
\c postgres
DROP DATABASE IF EXISTS alke_wallet;
```

---

## 🔧 Solución de Problemas

### Error: "database alke_wallet already exists"

```sql
-- Opción 1: Conectarse a la existente
\c alke_wallet

-- Opción 2: Eliminar y recrear
DROP DATABASE alke_wallet;
CREATE DATABASE alke_wallet;
```

### Error: "permission denied"

```powershell
# Ejecutar PowerShell como Administrador
# Luego ejecutar psql
```

### Error: "relation already exists"

```sql
-- Las tablas ya fueron creadas
-- Eliminarlas primero:
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS currencies CASCADE;

-- Luego ejecutar 01_DDL_schema.sql nuevamente
```

### Error: Encoding UTF8

```sql
-- Verificar encoding actual
SHOW SERVER_ENCODING;

-- Al crear BD, especificar encoding
CREATE DATABASE alke_wallet WITH ENCODING 'UTF8';
```

---

## 📝 Notas Importantes

1. **Orden de Ejecución:** Siempre respetar el orden numérico (01, 02, 03...)
2. **Constraints:** Las Foreign Keys requieren que las tablas padre existan primero
3. **Datos:** No ejecutar `02_DML_seed_data.sql` dos veces (duplicaría datos)
4. **Tests:** El archivo `07_validations.sql` contiene tests que DEBEN FALLAR (es normal)
5. **ACID:** Los ejemplos de ROLLBACK NO guardan cambios (es intencional)

---

## ✅ Checklist de Verificación

- [ ] Base de datos `alke_wallet` creada
- [ ] 3 tablas creadas (currencies, users, transactions)
- [ ] Datos insertados correctamente (6 monedas, 10 usuarios, 20+ transacciones)
- [ ] 3 consultas SQL ejecutadas exitosamente
- [ ] UPDATE de email funcional
- [ ] DELETE de transacción funcional
- [ ] Todas las capturas de pantalla tomadas (mínimo 10)
- [ ] Diagrama ER creado y exportado (PNG + PDF)
- [ ] Documento Word iniciado
- [ ] Scripts SQL documentados con comentarios

---

## 🎓 Recursos Adicionales

- [Documentación PostgreSQL](https://www.postgresql.org/docs/17/)
- [dbdiagram.io - ER Diagrams](https://dbdiagram.io/)
- [DBeaver - Universal Database Tool](https://dbeaver.io/)
- [SQL Cheat Sheet](https://www.postgresqltutorial.com/postgresql-cheat-sheet/)
