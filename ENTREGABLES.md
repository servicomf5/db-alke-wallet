# ✅ ENTREGABLES - Proyecto Alke Wallet

**Estado General:** ✅ COMPLETADO
**Módulo:** Fundamentos de Bases de Datos Relacionales
**Fecha de Entrega:** 11 de febrero de 2026
**Tecnología:** PostgreSQL 17.6

---

## 📄 Documento Principal

**Archivo:** `Alke_Wallet_Documentacion.docx`
**Ubicación:** `docs/`
**Estado:** ✅ COMPLETADO

### Contenido Incluido:

#### 1. Portada

- ✅ Título del proyecto: "Alke Wallet - Base de Datos PostgreSQL"
- ✅ Módulo: Fundamentos de Bases de Datos Relacionales
- ✅ Autor identificado
- ✅ Fecha de entrega: 11 de febrero de 2026

#### 2. Introducción

- [x] Descripción del proyecto Alke Wallet
- [x] Objetivos del sistema
- [x] Alcance funcional

#### 3. Análisis de Requerimientos

- [x] Requerimientos funcionales extraídos de la consigna
- [x] Entidades identificadas (Usuario, Transacción, Moneda)
- [x] Reglas de negocio documentadas

#### 4. Modelo Conceptual

- ✅ Diagrama Entidad-Relación exportado en formatos PNG y PDF
- ✅ Descripción de entidades y atributos
- ✅ Descripción de relaciones y cardinalidades
- ✅ Tabla de correspondencia ER → Relacional

#### 5. Normalización

- [x] Aplicación de 1FN (explicación)
- [x] Aplicación de 2FN (explicación)
- [x] Aplicación de 3FN (explicación)
- [x] Justificación de desnormalización (campo `balance`)

#### 6. Modelo Lógico

- [x] Descripción detallada tabla `currencies`
- [x] Descripción detallada tabla `users`
- [x] Descripción detallada tabla `transactions`
- [x] Relaciones entre tablas con diagramas
- [x] Integridad referencial (ON DELETE, ON UPDATE)

#### 7. Implementación DDL

- ✅ Script completo de creación (01_DDL_schema.sql)
- ✅ Captura de CREATE TABLE exitoso incluida
- ✅ Script de índices implementado
- ✅ Captura de verificación de tablas creadas

#### 8. Implementación DML

- ✅ Script de datos iniciales (02_DML_seed_data.sql)
- ✅ Captura de SELECT con datos insertados

#### 9. Consultas SQL Requeridas

- ✅ Consulta 1: Moneda de usuario (código SQL + captura)
- ✅ Consulta 2: Todas las transacciones (código SQL + captura)
- ✅ Consulta 3: Transacciones por usuario (código SQL + captura)

#### 10. Operaciones DML

- ✅ UPDATE email (código SQL + capturas antes/después)
- ✅ DELETE transacción (código SQL + captura de confirmación)

#### 11. Consultas Avanzadas (Tareas Plus)

- ✅ Vista Top 5 usuarios (código SQL + captura)
- ✅ Agregaciones y subconsultas (código SQL + capturas)

#### 12. Transacciones ACID

- ✅ Tabla explicativa de propiedades ACID
- ✅ Ejemplos de COMMIT (código SQL + captura)
- ✅ Ejemplos de ROLLBACK (código SQL + captura)

#### 13. Índices y Optimización

- ✅ Listado de índices creados (10+)
- ✅ Justificación de cada índice
- ✅ Evidencia de optimización con índices compuestos

#### 14. Conclusiones

- ✅ Cumplimiento de requerimientos documentado
- ✅ Decisiones técnicas justificadas
- ✅ Mejoras futuras propuestas

#### 15. Anexos

- ✅ Scripts SQL completos (7 archivos)
- ✅ Diagrama ER en alta resolución (PNG + PDF)

---

## 📁 Scripts SQL

### ✅ Scripts Obligatorios (Completados)

1. ✅ **01_DDL_schema.sql** - Creación de BD y tablas
   - Líneas: ~350
   - Tablas: 3 (currencies, users, transactions)
   - Constraints: 25+
   - Índices: 10+
   - Estado: ✅ Completado

2. ✅ **02_DML_seed_data.sql** - Datos de prueba
   - Líneas: ~210
   - Monedas: 6 registros
   - Usuarios: 10 registros
   - Transacciones: 20+ registros
   - Estado: ✅ Completado

3. ✅ **03_queries.sql** - 3 consultas requeridas
   - Líneas: ~280
   - Consultas obligatorias: 3
   - Consultas adicionales: 5+
   - Estado: ✅ Completado

4. ✅ **04_DML_operations.sql** - UPDATE email, DELETE transacción
   - Líneas: ~320
   - Operaciones UPDATE: 6 variantes
   - Operaciones DELETE: 3 variantes
   - Estado: ✅ Completado

### 💡 Scripts Adicionales (Tareas Plus)

5. ✅ **05_advanced_queries.sql** - Vistas, agregaciones
   - Líneas: ~410
   - Vistas creadas: 3
   - Window functions: Sí
   - CTEs: Sí
   - Estado: ✅ Completado

6. ✅ **06_transactions_ACID.sql** - Demostración ACID
   - Líneas: ~450
   - Escenarios ACID: 8
   - Tabla explicativa: Sí
   - Estado: ✅ Completado

7. ✅ **07_validations.sql** - Tests de constraints
   - Líneas: ~570
   - Tests ejecutados: 34
   - Categorías: 6
   - Estado: ✅ Completado

---

## 🖼️ Capturas de Pantalla

**Ubicación:** `screenshots/`
**Estado:** ✅ COMPLETADAS (11 capturas)

### Capturas Incluidas:

- ✅ **01_create_database.png** - Creación de base de datos exitosa
- ✅ **02_create_tables.png** - Verificación de las 3 tablas
- ✅ **03_describe_currencies.png** - Estructura de tabla currencies
- ✅ **04_insert_data.png** - Datos insertados (conteo por tabla)
- ✅ **05_query_user_currency.png** - Resultado consulta 1 (moneda de usuario)
- ✅ **06_query_all_transactions.png** - Resultado consulta 2 (todas las transacciones)
- ✅ **07_query_user_transactions.png** - Resultado consulta 3 (transacciones por usuario)
- ✅ **08_update_email_before.png** - Estado ANTES del UPDATE
- ✅ **09_update_email_after.png** - Estado DESPUÉS del UPDATE
- ✅ **10_delete_transaction.png** - Confirmación de DELETE
- ✅ **11_transaction_commit.png** - Transacción ACID exitosa (COMMIT)

---

## 📊 Diagrama ER

**Ubicación:** `diagrams/`
**Estado:** ✅ COMPLETADO

### Archivos Incluidos:

- ✅ **ERD_AlkeWallet.png** - Diagrama en formato PNG (alta calidad)
- ✅ **ERD_AlkeWallet.pdf** - Diagrama en formato PDF (vectorial)

### Contenido del Diagrama:

- ✅ 3 tablas (currencies, users, transactions)
- ✅ Todos los campos con tipos de datos especificados
- ✅ Claves primarias (PK) claramente marcadas
- ✅ Claves foráneas (FK) con flechas direccionales
- ✅ Cardinalidades (1:N) indicadas en relaciones
- ✅ Notación estándar Crow's Foot

**Herramienta utilizada:** dbdiagram.io

---

## 📋 Checklist de Cumplimiento

### Requerimientos de la Consigna

#### ✅ Aspectos Técnicos (Completados)

- [x] Diseño normalizado hasta 3FN
- [x] Identificadores únicos (PKs) en todas las tablas
- [x] Integridad referencial (FKs) configurada correctamente
- [x] Constraints: CHECK, UNIQUE, NOT NULL
- [x] Índices para optimización de consultas
- [x] Tipos de datos PostgreSQL apropiados
- [x] Nomenclatura en inglés consistente

#### ✅ Aspectos Estructurales (ACID)

- [x] **Atomicidad** - Demostrada con ROLLBACK
- [x] **Consistencia** - Constraints activos y validados
- [x] **Aislamiento** - Transacciones BEGIN/COMMIT documentadas
- [x] **Durabilidad** - COMMIT persiste datos (explicado)

#### ✅ Consultas SQL Requeridas

- [x] Consulta 1: Nombre de moneda de usuario específico
- [x] Consulta 2: Todas las transacciones registradas
- [x] Consulta 3: Transacciones realizadas por usuario específico
- [x] UPDATE: Modificar correo electrónico
- [x] DELETE: Eliminar transacción completa

#### 💡 Tareas Plus Completadas

- ✅ Vista `vw_top_users_by_balance` (Lección 2)
- ✅ Campos de auditoría `created_at`, `updated_at` (Lección 4)
- ✅ Demostración completa ACID con 8 escenarios (Lección 3)
- ✅ Subconsultas y agregaciones avanzadas (Lección 2)
- ✅ 34 tests de validación automatizados
- ✅ Índices compuestos para optimización
- ✅ Diagrama ERD exportado en PNG y PDF (Lección 5)

---

## 📦 Estructura Final del Proyecto

```
proyecto/
├── docs/
│   ├── ✅ Alke_Wallet_Documentacion.docx  ⭐ ENTREGABLE PRINCIPAL
│
├── diagrams/
│   ├── ✅ ERD_AlkeWallet.png
│   └── ✅ ERD_AlkeWallet.pdf
│
├── screenshots/
│   ├── ✅ 01_create_database.png
│   ├── ✅ 02_create_tables.png
│   ├── ✅ 03_describe_currencies.png
│   ├── ✅ 04_insert_data.png
│   ├── ✅ 05_query_user_currency.png
│   ├── ✅ 06_query_all_transactions.png
│   ├── ✅ 07_query_user_transactions.png
│   ├── ✅ 08_update_email_before.png
│   ├── ✅ 09_update_email_after.png
│   ├── ✅ 10_delete_transaction.png
│   └── ✅ 11_transaction_commit.png
│
├── ✅ 01_DDL_schema.sql
├── ✅ 02_DML_seed_data.sql
├── ✅ 03_queries.sql
├── ✅ 04_DML_operations.sql
├── ✅ 05_advanced_queries.sql
├── ✅ 06_transactions_ACID.sql
├── ✅ 07_validations.sql
├── ✅ README.md
├── ✅ ENTREGABLES.md
└── ✅ INICIO_RAPIDO.md
```

---

## 🎯 Resumen de Estado

### 🟢 Completado (100%)

| Componente           | Archivos | Estado        |
| -------------------- | -------- | ------------- |
| Scripts SQL          | 7        | ✅ Completado |
| Documentación        | 3        | ✅ Completado |
| Diagrama ER          | 2        | ✅ Completado |
| Capturas de pantalla | 11       | ✅ Completado |
| Documento Word       | 1        | ✅ Completado |

### 📊 Progreso Total: 100% ✅

---

## 🆗 Extras Implementados

### Características Adicionales:

- ✅ Campos de auditoría temporal en todas las tablas
- ✅ Validación de email con expresiones regulares PostgreSQL
- ✅ Soft delete mediante campo `is_active` en users
- ✅ Índices compuestos para optimización de consultas complejas
- ✅ Comentarios (COMMENT ON) en tablas y columnas
- ✅ Transacciones complejas multi-paso con validaciones
- ✅ 3 vistas para reportes frecuentes
- ✅ Window functions (ROW_NUMBER, RANK, SUM OVER)
- ✅ CTEs (Common Table Expressions) para consultas complejas
- ✅ 34 tests de validación automatizados con manejo de excepciones
- ✅ Mensajes informativos con RAISE NOTICE
- ✅ Documentación completa en formato Markdown y Word

---

## ✅ Criterios de Evaluación - CUMPLIDOS

### Requerimientos Obligatorios

| Criterio                        | Estado | Evidencia                       |
| ------------------------------- | ------ | ------------------------------- |
| Base de datos creada            | ✅     | Screenshot 01                   |
| 3 entidades implementadas       | ✅     | currencies, users, transactions |
| Claves primarias                | ✅     | SERIAL en todas las tablas      |
| Claves foráneas                 | ✅     | 4 FKs con ON DELETE RESTRICT    |
| Constraints de validación       | ✅     | 25+ constraints                 |
| Consulta SQL #1 (moneda)        | ✅     | 03_queries.sql + Screenshot 05  |
| Consulta SQL #2 (transacciones) | ✅     | 03_queries.sql + Screenshot 06  |
| Consulta SQL #3 (por usuario)   | ✅     | 03_queries.sql + Screenshot 07  |
| UPDATE email                    | ✅     | Screenshots 08, 09              |
| DELETE transacción              | ✅     | Screenshot 10                   |
| Normalización 3FN               | ✅     | Documentado en entregable       |
| Principios ACID                 | ✅     | 8 escenarios + Screenshot 11    |
| Diagrama ER                     | ✅     | PNG + PDF en diagrams/          |
| Documento final                 | ✅     | DOCX + MD en docs/              |

---

## 📊 Métricas del Proyecto

### Código SQL

| Métrica                  | Valor  |
| ------------------------ | ------ |
| Total archivos SQL       | 7      |
| Total líneas de código   | ~2,590 |
| Comentarios explicativos | 400+   |
| Queries ejecutables      | 100+   |

### Base de Datos

| Métrica             | Valor |
| ------------------- | ----- |
| Tablas              | 3     |
| Relaciones (FKs)    | 4     |
| Constraints totales | 25+   |
| Índices             | 10+   |
| Vistas              | 3     |

### Testing y Validación

| Métrica             | Valor |
| ------------------- | ----- |
| Tests de validación | 34    |
| Escenarios ACID     | 8     |
| Categorías de tests | 6     |

---

## 🎓 Lecciones Aplicadas (Módulo Completo)

### Lección 1: Bases de Datos Relacionales ✅

- ✅ Creación de BD con `CREATE DATABASE`
- ✅ Conexión y exploración con comandos `\`, `\dt`, `\d table`
- ✅ Comprensión de arquitectura cliente-servidor

### Lección 2: Consultas a Varias Tablas ✅

- ✅ SELECT con INNER JOIN múltiples
- ✅ Filtros con WHERE y condiciones complejas
- ✅ Agregaciones (COUNT, SUM, AVG, MIN, MAX)
- ✅ GROUP BY y HAVING
- ✅ **Tarea Plus:** Vista top-5 usuarios por saldo

### Lección 3: Manipulación de Datos y Transaccionalidad ✅

- ✅ INSERT múltiple con ON CONFLICT
- ✅ UPDATE con condiciones y RETURNING
- ✅ DELETE con verificaciones
- ✅ BEGIN, COMMIT, ROLLBACK
- ✅ **Tarea Plus:** Demostración completa de las 4 propiedades ACID

### Lección 4: Definición de Tablas (DDL) ✅

- ✅ CREATE TABLE con tipos de datos PostgreSQL apropiados
- ✅ PRIMARY KEY y FOREIGN KEY con políticas de integridad
- ✅ Constraints NOT NULL, UNIQUE, CHECK con validaciones complejas
- ✅ CREATE INDEX simple y compuesto
- ✅ **Tarea Plus:** Campos de auditoría (created_at, updated_at)

### Lección 5: Modelo Entidad-Relación ✅

- ✅ Identificación de entidades, atributos y relaciones
- ✅ Definición de cardinalidades (1:1, 1:N, N:M)
- ✅ Normalización hasta 3FN con justificación
- ✅ Generación de script DDL completo desde modelo
- ✅ **Tarea Plus:** Diagrama ERD exportado en formatos múltiples (PNG + PDF)

---

## 🔍 Observaciones para Evaluación

### Puntos Destacados:

1. **Normalización Aplicada:** El proyecto cumple con 3FN. La desnormalización del campo `balance` está justificada por rendimiento y documentada apropiadamente.

2. **Validaciones Completas:** Se implementaron 25+ constraints incluyendo CHECK con expresiones regulares para validación de email, garantizando integridad de datos a nivel de base de datos.

3. **ACID Demostrado:** Se desarrollaron 8 escenarios diferentes que demuestran cada una de las propiedades ACID, no solo con código sino con explicaciones detalladas.

4. **Optimización:** Los índices compuestos (ej: `idx_transactions_sender_date`) están estratégicamente colocados para optimizar las consultas más frecuentes del sistema.

5. **Testing Automatizado:** Los 34 tests en `07_validations.sql` validan automáticamente todos los constraints usando bloques DO con manejo de excepciones.

6. **Documentación Profesional:** Comentarios en código SQL, README completo, y documento Word con capturas y explicaciones detalladas.

### Decisiones Técnicas Importantes:

- **Nomenclatura en inglés:** Facilita portabilidad y estándares internacionales
- **ON DELETE RESTRICT:** Protege integridad referencial, evitando eliminaciones accidentales en cascada
- **Campos de auditoría:** Permiten trazabilidad completa de cambios
- **Soft delete:** Campo `is_active` permite "eliminación lógica" sin pérdida de datos históricos

---

**Proyecto desarrollado para el módulo "Fundamentos de Bases de Datos Relacionales"**
**Tecnología:** PostgreSQL 17.6
**Fecha de Entrega:** 11 de febrero de 2026
**Estado:** ✅ COMPLETADO AL 100%
