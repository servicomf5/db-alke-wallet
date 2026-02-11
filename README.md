# 🏦 Alke Wallet - Base de Datos PostgreSQL

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-17.6-blue.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-Educational-green.svg)]()
[![Status](https://img.shields.io/badge/Status-Complete-success.svg)]()

Sistema de gestión de wallet virtual con soporte multi-moneda, registro completo de transacciones y cumplimiento de principios ACID. Proyecto completo de base de datos relacional implementado en PostgreSQL.

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Arquitectura](#️-arquitectura)
- [Requisitos del Sistema](#-requisitos-del-sistema)
- [Instalación](#-instalación)
- [Estructura de Archivos](#-estructura-de-archivos)
- [Uso](#-uso)
- [Modelo de Datos](#️-modelo-de-datos)
- [Consultas Principales](#-consultas-principales)
- [Seguridad](#-seguridad)
- [Documentación Técnica](#-documentación-técnica)

---

## 📖 Descripción

**Alke Wallet** es un sistema de base de datos relacional completo diseñado para gestionar:

- ✅ Usuarios con saldos en múltiples monedas
- ✅ Transacciones financieras con trazabilidad completa
- ✅ Catálogo de monedas internacionales
- ✅ Historial de operaciones con integridad garantizada
- ✅ Principios ACID para transacciones seguras

El proyecto implementa las mejores prácticas en diseño de bases de datos relacionales:

- Normalización hasta 3FN
- Constraints de integridad referencial
- Índices para optimización de consultas
- Vistas para reportes frecuentes
- Transacciones ACID completas

---

## ✨ Características

### Técnicas

- **Motor:** PostgreSQL 17.x
- **Normalización:** Tercera Forma Normal (3FN)
- **Integridad:** 25+ constraints (PK, FK, UNIQUE, CHECK, NOT NULL)
- **Optimización:** 10+ índices estratégicos incluyendo compuestos
- **Auditoría:** Campos de timestamp para trazabilidad completa
- **ACID:** Transacciones completas con BEGIN/COMMIT/ROLLBACK

### Funcionales

- Gestión completa de usuarios con autenticación
- Soporte para 6+ monedas (CLP, USD, EUR, BTC, ARS, BRL)
- Registro de transacciones con validaciones
- Reportes y estadísticas avanzadas
- Historial completo de operaciones

---

## 🏗️ Arquitectura

### Diagrama Entidad-Relación

```
┌─────────────────┐
│   CURRENCIES    │
│─────────────────│
│ currency_id (PK)│◄──────────┐
│ currency_name   │           │
│ currency_symbol │           │ 1
│ currency_code   │           │
│ created_at      │           │
└─────────────────┘           │
                              │
                              │ N
                   ┌──────────┴──────────┐
                   │       USERS         │
                   │─────────────────────│
                   │ user_id (PK)        │◄────┐
                   │ name                │     │
                   │ email (UNIQUE)      │     │
                   │ password            │     │
                   │ balance             │     │ 1
                   │ currency_id (FK)    │     │
                   │ is_active           │     │
                   │ created_at          │     │
                   │ updated_at          │     │
                   └─────────────────────┘     │
                            ▲                  │
                            │                  │
                            │ 1                │
                            │                  │
                            │                  │ N
                   ┌────────┴──────────┐       │
                   │   TRANSACTIONS    │       │
                   │───────────────────│       │
                   │ transaction_id(PK)│       │
                   │ sender_user_id(FK)├───────┘
                   │ receiver_user_id  │
                   │ amount            │
                   │ currency_id (FK)  │
                   │ transaction_date  │
                   │ description       │
                   │ transaction_type  │
                   │ created_at        │
                   └───────────────────┘
```

### Relaciones

| Relación                            | Tipo | Cardinalidad                        | Descripción                       |
| ----------------------------------- | ---- | ----------------------------------- | --------------------------------- |
| **currencies → users**              | 1:N  | Una moneda, múltiples usuarios      | Moneda predeterminada del usuario |
| **users → transactions (sender)**   | 1:N  | Un usuario, múltiples envíos        | Transacciones enviadas            |
| **users → transactions (receiver)** | 1:N  | Un usuario, múltiples recepciones   | Transacciones recibidas           |
| **currencies → transactions**       | 1:N  | Una moneda, múltiples transacciones | Moneda de la transacción          |

---

## 💻 Requisitos del Sistema

### Software Requerido

- **PostgreSQL:** 12.x o superior (desarrollado en 17.6)
- **Cliente SQL:** DBeaver, pgAdmin 4, psql, o cualquier cliente compatible
- **Sistema Operativo:** Windows, Linux, o macOS
- **RAM:** 4GB mínimo (8GB recomendado)
- **Espacio en disco:** 1GB para PostgreSQL + datos

### Configuración Recomendada de PostgreSQL

```ini
port = 5432
max_connections = 100
shared_buffers = 128MB
encoding = UTF8
```

---

## 🚀 Instalación

### Opción 1: Instalación Completa (Recomendada)

#### Paso 1: Verificar PostgreSQL

```powershell
# Verificar versión instalada
psql --version
# Esperado: psql (PostgreSQL) 17.6
```

#### Paso 2: Crear la base de datos

```powershell
# Conectarse como superusuario
psql -U postgres

# Dentro de psql:
CREATE DATABASE alke_wallet;
\c alke_wallet
\q
```

#### Paso 3: Ejecutar scripts en orden

```bash
# Navegar a la carpeta del proyecto
cd ruta/al/proyecto

# 1. Crear estructura de tablas
psql -U postgres -d alke_wallet -f 01_DDL_schema.sql

# 2. Cargar datos iniciales
psql -U postgres -d alke_wallet -f 02_DML_seed_data.sql

# 3. (Opcional) Ejecutar consultas de prueba
psql -U postgres -d alke_wallet -f 03_queries.sql
```

#### Paso 4: Verificar instalación

```sql
-- Conectarse a la BD
\c alke_wallet

-- Verificar tablas creadas
\dt

-- Verificar datos insertados
SELECT COUNT(*) FROM currencies;
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM transactions;
```

### Opción 2: Instalación Usando DBeaver

1. Abrir DBeaver
2. Crear nueva conexión a PostgreSQL (localhost:5432)
3. Crear base de datos `alke_wallet` (clic derecho → Create → Database)
4. Abrir SQL Editor y ejecutar scripts en orden:
   - `01_DDL_schema.sql`
   - `02_DML_seed_data.sql`
   - `03_queries.sql`
5. Verificar en el Data Viewer

---

## 📁 Estructura de Archivos

```
proyecto/
├── 📄 README.md                      # Este archivo (documentación principal)
├── 📄 ENTREGABLES.md                 # Checklist de entregables del proyecto
├── 📄 INICIO_RAPIDO.md               # Instrucciones paso a paso
│
├── 🗄️ Scripts SQL (ejecutar en orden):
│   ├── 01_DDL_schema.sql            # PASO 1: Creación de BD, tablas e índices
│   ├── 02_DML_seed_data.sql         # PASO 2: Datos iniciales de prueba
│   ├── 03_queries.sql               # PASO 3: Consultas requeridas (3 obligatorias)
│   ├── 04_DML_operations.sql        # PASO 4: UPDATE, DELETE requeridos
│   ├── 05_advanced_queries.sql      # PASO 5: Vistas, agregaciones, análisis
│   ├── 06_transactions_ACID.sql     # PASO 6: Demostraciones ACID
│   └── 07_validations.sql           # PASO 7: Tests de integridad (34 tests)
│
├── 📂 docs/                             # Documentación completa del proyecto
│   └── Alke_Wallet_Documentacion.docx   # Documentación técnica detallada
│
├── 📂 diagrams/                      # Diagramas ER del sistema
│   ├── ERD_AlkeWallet.png           # Diagrama Entidad-Relación en PNG
│   └── ERD_AlkeWallet.pdf           # Diagrama Entidad-Relación en PDF
│
└── 📂 screenshots/                   # Capturas de evidencia de ejecución
    ├── 01_create_database.png       # Creación de base de datos
    ├── 02_create_tables.png         # Verificación de tablas creadas
    ├── 03_describe_currencies.png   # Estructura de tabla currencies
    ├── 04_insert_data.png           # Datos insertados
    ├── 05_query_user_currency.png   # Consulta SQL #1
    ├── 06_query_all_transactions.png # Consulta SQL #2
    ├── 07_query_user_transactions.png # Consulta SQL #3
    ├── 08_update_email_before.png   # UPDATE - Antes
    ├── 09_update_email_after.png    # UPDATE - Después
    ├── 10_delete_transaction.png    # DELETE - Verificación
    └── 11_transaction_commit.png    # Transacción ACID exitosa
```

---

## 🎯 Uso

### Consultas Básicas

#### 1. Ver la moneda de un usuario

```sql
-- Consulta requerida #1
SELECT
    u.name,
    c.currency_name,
    c.currency_symbol,
    u.balance
FROM users u
INNER JOIN currencies c ON u.currency_id = c.currency_id
WHERE u.user_id = 1;
```

#### 2. Ver todas las transacciones

```sql
-- Consulta requerida #2
SELECT
    t.transaction_id,
    sender.name AS from_user,
    receiver.name AS to_user,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.transaction_date
FROM transactions t
INNER JOIN users sender ON t.sender_user_id = sender.user_id
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
ORDER BY t.transaction_date DESC;
```

#### 3. Ver transacciones de un usuario específico

```sql
-- Consulta requerida #3
SELECT
    t.transaction_id,
    receiver.name AS sent_to,
    CONCAT(c.currency_symbol, ' ', t.amount) AS amount,
    t.description
FROM transactions t
INNER JOIN users receiver ON t.receiver_user_id = receiver.user_id
INNER JOIN currencies c ON t.currency_id = c.currency_id
WHERE t.sender_user_id = 1
ORDER BY t.transaction_date DESC;
```

### Operaciones DML

#### Modificar email de usuario

```sql
-- Operación requerida UPDATE
UPDATE users
SET
    email = 'nuevo.email@alkewallet.com',
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = 1
RETURNING user_id, name, email;
```

#### Eliminar transacción

```sql
-- Operación requerida DELETE
DELETE FROM transactions
WHERE transaction_id = 20
RETURNING transaction_id, amount, description;
```

### Realizar una Transferencia (ACID)

```sql
-- Transferencia segura con ACID
BEGIN;
    -- 1. Descontar del emisor
    UPDATE users SET balance = balance - 1000 WHERE user_id = 1;

    -- 2. Acreditar al receptor
    UPDATE users SET balance = balance + 1000 WHERE user_id = 2;

    -- 3. Registrar transacción
    INSERT INTO transactions (sender_user_id, receiver_user_id, amount, currency_id, description)
    VALUES (1, 2, 1000, 1, 'Transferencia con ACID');

    -- 4. Confirmar cambios
COMMIT;
-- O usar ROLLBACK; para deshacer
```

### Usar Vistas

```sql
-- Top 5 usuarios con mayor saldo
SELECT * FROM vw_top_users_by_balance;

-- Resumen de transacciones por usuario
SELECT * FROM vw_user_transaction_summary;

-- Últimas 20 transacciones
SELECT * FROM vw_recent_transactions;
```

---

## 🗄️ Modelo de Datos

### Tabla: `currencies`

Catálogo de monedas disponibles en la wallet.

| Campo             | Tipo        | Constraints             | Descripción                          |
| ----------------- | ----------- | ----------------------- | ------------------------------------ |
| `currency_id`     | SERIAL      | PK                      | ID único autoincremental             |
| `currency_name`   | VARCHAR(50) | NOT NULL, UNIQUE        | Nombre completo (ej: "Peso Chileno") |
| `currency_symbol` | VARCHAR(10) | NOT NULL                | Símbolo (ej: "$", "€", "₿")          |
| `currency_code`   | CHAR(3)     | NOT NULL, UNIQUE, CHECK | Código ISO 4217 (ej: "CLP", "USD")   |
| `created_at`      | TIMESTAMP   | DEFAULT NOW()           | Fecha de creación                    |

**Constraints:**

- CHECK: `LENGTH(currency_code) = 3`
- UNIQUE: `currency_name`, `currency_code`

---

### Tabla: `users`

Usuarios registrados en la plataforma.

| Campo         | Tipo          | Constraints                | Descripción                  |
| ------------- | ------------- | -------------------------- | ---------------------------- |
| `user_id`     | SERIAL        | PK                         | ID único autoincremental     |
| `name`        | VARCHAR(100)  | NOT NULL, CHECK            | Nombre completo del usuario  |
| `email`       | VARCHAR(255)  | NOT NULL, UNIQUE, CHECK    | Email (para login)           |
| `password`    | VARCHAR(255)  | NOT NULL, CHECK            | Contraseña hasheada (bcrypt) |
| `balance`     | DECIMAL(15,2) | NOT NULL, DEFAULT 0, CHECK | Saldo actual                 |
| `currency_id` | INTEGER       | NOT NULL, FK → currencies  | Moneda predeterminada        |
| `is_active`   | BOOLEAN       | DEFAULT TRUE               | Usuario activo/inactivo      |
| `created_at`  | TIMESTAMP     | DEFAULT NOW()              | Fecha de registro            |
| `updated_at`  | TIMESTAMP     | DEFAULT NOW()              | Última modificación          |

**Constraints:**

- CHECK: `balance >= 0`
- CHECK: `email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'`
- CHECK: `LENGTH(password) >= 6`
- CHECK: `LENGTH(TRIM(name)) > 0`
- FK: `currency_id` REFERENCES `currencies(currency_id)` ON DELETE RESTRICT ON UPDATE CASCADE

**Índices:**

- `idx_users_email` (UNIQUE automático)
- `idx_users_currency`
- `idx_users_active` (WHERE is_active = TRUE)

---

### Tabla: `transactions`

Registro histórico de todas las transacciones financieras.

| Campo              | Tipo          | Constraints                 | Descripción                    |
| ------------------ | ------------- | --------------------------- | ------------------------------ |
| `transaction_id`   | SERIAL        | PK                          | ID único autoincremental       |
| `sender_user_id`   | INTEGER       | NOT NULL, FK → users        | Usuario emisor                 |
| `receiver_user_id` | INTEGER       | NOT NULL, FK → users, CHECK | Usuario receptor               |
| `amount`           | DECIMAL(15,2) | NOT NULL, CHECK             | Monto de la transacción        |
| `currency_id`      | INTEGER       | NOT NULL, FK → currencies   | Moneda de la transacción       |
| `transaction_date` | TIMESTAMP     | DEFAULT NOW()               | Fecha y hora de ejecución      |
| `description`      | VARCHAR(255)  | NULL                        | Descripción opcional           |
| `transaction_type` | VARCHAR(20)   | DEFAULT 'transfer', CHECK   | Tipo de transacción            |
| `created_at`       | TIMESTAMP     | DEFAULT NOW()               | Fecha de creación del registro |

**Constraints:**

- CHECK: `amount > 0`
- CHECK: `sender_user_id <> receiver_user_id`
- CHECK: `transaction_type IN ('transfer', 'deposit', 'withdrawal')`
- FK: `sender_user_id`, `receiver_user_id` REFERENCES `users(user_id)` ON DELETE RESTRICT
- FK: `currency_id` REFERENCES `currencies(currency_id)` ON DELETE RESTRICT

**Índices:**

- `idx_transactions_sender`
- `idx_transactions_receiver`
- `idx_transactions_date` (DESC)
- `idx_transactions_currency`
- `idx_transactions_sender_date` (compuesto)
- `idx_transactions_receiver_date` (compuesto)

---

## 🔍 Consultas Principales

### Reportes Estadísticos

```sql
-- Balance de transacciones por usuario
SELECT
    u.name,
    COALESCE(sent.total_sent, 0) AS total_enviado,
    COALESCE(received.total_received, 0) AS total_recibido,
    COALESCE(received.total_received, 0) - COALESCE(sent.total_sent, 0) AS balance_neto
FROM users u
LEFT JOIN (
    SELECT sender_user_id, SUM(amount) AS total_sent
    FROM transactions GROUP BY sender_user_id
) sent ON u.user_id = sent.sender_user_id
LEFT JOIN (
    SELECT receiver_user_id, SUM(amount) AS total_received
    FROM transactions GROUP BY receiver_user_id
) received ON u.user_id = received.receiver_user_id;
```

```sql
-- Volumen de transacciones por moneda
SELECT
    c.currency_name,
    COUNT(t.transaction_id) AS total_transacciones,
    SUM(t.amount) AS volumen_total,
    AVG(t.amount) AS monto_promedio
FROM currencies c
LEFT JOIN transactions t ON c.currency_id = t.currency_id
GROUP BY c.currency_id, c.currency_name
ORDER BY volumen_total DESC;
```

---

## 🔐 Seguridad

### Protecciones Implementadas

1. **Integridad Referencial:**
   - Todas las FK con ON DELETE RESTRICT
   - Evita eliminación de datos con dependencias

2. **Validaciones de Negocio:**
   - Balance siempre >= 0
   - Montos siempre > 0
   - No auto-transferencias
   - Emails con formato válido

3. **Contraseñas:**
   - Campo `password` preparado para bcrypt
   - Longitud mínima 6 caracteres
   - En producción: usar `pgcrypto` o hash desde aplicación

4. **Auditoría:**
   - `created_at` en todas las tablas
   - `updated_at` en tabla users
   - Trazabilidad completa de transacciones

### Recomendaciones para Producción

```sql
-- Crear usuario limitado (no usar postgres)
CREATE USER alkewallet_app WITH PASSWORD 'secure_password_here';
GRANT CONNECT ON DATABASE alke_wallet TO alkewallet_app;
GRANT USAGE ON SCHEMA public TO alkewallet_app;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO alkewallet_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO alkewallet_app;
```

---

## 📚 Documentación Técnica

### Scripts SQL Incluidos

| Archivo                    | Descripción                      | Líneas | Tipo          |
| -------------------------- | -------------------------------- | ------ | ------------- |
| `01_DDL_schema.sql`        | Creación de BD, tablas e índices | ~350   | DDL           |
| `02_DML_seed_data.sql`     | Datos iniciales de prueba        | ~210   | DML           |
| `03_queries.sql`           | Consultas SQL requeridas         | ~280   | DQL           |
| `04_DML_operations.sql`    | Operaciones UPDATE y DELETE      | ~320   | DML           |
| `05_advanced_queries.sql`  | Vistas, agregaciones, análisis   | ~410   | DQL Avanzado  |
| `06_transactions_ACID.sql` | Demostración propiedades ACID    | ~450   | Transaccional |
| `07_validations.sql`       | Tests automatizados (34 tests)   | ~570   | Testing/QA    |

### Características Avanzadas Implementadas

- ✅ Vista `vw_top_users_by_balance` con ranking de usuarios
- ✅ Campos de auditoría temporal en todas las entidades
- ✅ 8 escenarios de demostración ACID completos
- ✅ 34 tests de validación de integridad automatizados
- ✅ Índices simples y compuestos para optimización de queries
- ✅ Window functions (ROW_NUMBER, RANK, DENSE_RANK)
- ✅ Common Table Expressions (CTEs) para queries complejas
- ✅ Validaciones CHECK con expresiones regulares

---

## 📊 Estadísticas del Proyecto

```
📁 Total de archivos SQL:       7
📝 Total de líneas de código:   ~2,590
🗄️ Tablas creadas:              3 (currencies, users, transactions)
🔗 Relaciones (FKs):            4
✅ Constraints totales:         25+
📈 Índices creados:             10+
👁️ Vistas creadas:              3
🧪 Tests de validación:         34
```

---

## � Métricas del Proyecto

- **Líneas de código SQL:** ~2,590
- **Tablas:** 3 (currencies, users, transactions)
- **Constraints:** 25+ (PK, FK, UNIQUE, CHECK, NOT NULL)
- **Índices:** 10+ (simples y compuestos)
- **Vistas:** 3 (reportes y análisis)
- **Tests de validación:** 34 automatizados
- **Escenarios ACID:** 8 demostrados

---

## 📄 Licencia

Este proyecto es material educativo desarrollado como parte del aprendizaje de Fundamentos de Bases de Datos Relacionales.

---

## 🆘 Resolución de Problemas Comunes

### Error de conexión a PostgreSQL

**Windows:**

```powershell
# Verificar estado del servicio
Get-Service postgresql*

# Iniciar servicio
Start-Service postgresql-x64-*
```

**Linux/macOS:**

```bash
# Verificar estado
sudo systemctl status postgresql

# Iniciar servicio
sudo systemctl start postgresql
```

### Problema: Base de datos ya existe

```sql
-- Eliminar y recrear
DROP DATABASE IF EXISTS alke_wallet;
CREATE DATABASE alke_wallet;
```

### Violación de Constraints

```sql
-- Ver todos los constraints de una tabla
\d+ users
\d+ transactions

-- Verificar integridad manualmente
SELECT * FROM users WHERE balance < 0;  -- Debe retornar 0 filas
SELECT * FROM transactions WHERE sender_user_id = receiver_user_id;  -- Debe retornar 0 filas
```

---

## 🤝 Contribuciones

Este es un proyecto educativo. Si encuentras mejoras o sugerencias, puedes abrir un issue o proponer cambios.

---

**Desarrollado con 💙 y PostgreSQL**
