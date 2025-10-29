-- ============================================================
-- Script 01: Análise do Schema Oracle
-- Objetivo: Extrair metadados completos do banco Oracle
-- para planejamento da migração para SAP HANA
-- ============================================================

-- Configurar formato de saída
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING ON
SET LINESIZE 200

SPOOL analise_oracle_schema.log

-- ============================================================
-- 1. LISTA DE TABELAS NO SCHEMA
-- ============================================================
PROMPT ============================================================
PROMPT 1. LISTA DE TABELAS
PROMPT ============================================================

SELECT 
    OWNER,
    TABLE_NAME,
    NUM_ROWS,
    ROUND(BLOCKS * 8192 / 1024 / 1024, 2) AS SIZE_MB,
    LAST_ANALYZED
FROM DBA_TABLES
WHERE OWNER = UPPER('&SCHEMA_NAME')
ORDER BY TABLE_NAME;

-- ============================================================
-- 2. ESTRUTURA DAS TABELAS (COLUNAS E TIPOS)
-- ============================================================
PROMPT ============================================================
PROMPT 2. ESTRUTURA DAS COLUNAS
PROMPT ============================================================

SELECT 
    T.OWNER,
    T.TABLE_NAME,
    T.COLUMN_NAME,
    T.DATA_TYPE,
    T.DATA_LENGTH,
    T.DATA_PRECISION,
    T.DATA_SCALE,
    T.NULLABLE,
    T.DATA_DEFAULT,
    T.CHAR_LENGTH
FROM DBA_TAB_COLUMNS T
WHERE T.OWNER = UPPER('&SCHEMA_NAME')
ORDER BY T.TABLE_NAME, T.COLUMN_ID;

-- ============================================================
-- 3. CONSTRAINTS (PK, FK, CHECK, UNIQUE)
-- ============================================================
PROMPT ============================================================
PROMPT 3. CONSTRAINTS
PROMPT ============================================================

-- Primary Keys
SELECT 
    C.OWNER,
    C.TABLE_NAME,
    C.CONSTRAINT_NAME,
    C.CONSTRAINT_TYPE,
    LISTAGG(CC.COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY CC.POSITION) AS COLUMNS
FROM DBA_CONSTRAINTS C
JOIN DBA_CONS_COLUMNS CC ON C.OWNER = CC.OWNER 
    AND C.CONSTRAINT_NAME = CC.CONSTRAINT_NAME
WHERE C.OWNER = UPPER('&SCHEMA_NAME')
    AND C.CONSTRAINT_TYPE IN ('P', 'U', 'R', 'C')
GROUP BY C.OWNER, C.TABLE_NAME, C.CONSTRAINT_NAME, C.CONSTRAINT_TYPE
ORDER BY C.TABLE_NAME, C.CONSTRAINT_TYPE;

-- Foreign Keys com detalhes
SELECT 
    FK.OWNER,
    FK.TABLE_NAME AS FK_TABLE,
    FK.CONSTRAINT_NAME AS FK_NAME,
    PK.TABLE_NAME AS PK_TABLE,
    PK.CONSTRAINT_NAME AS PK_NAME,
    LISTAGG(FK_CC.COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY FK_CC.POSITION) AS FK_COLUMNS,
    LISTAGG(PK_CC.COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY PK_CC.POSITION) AS PK_COLUMNS
FROM DBA_CONSTRAINTS FK
JOIN DBA_CONSTRAINTS PK ON FK.R_OWNER = PK.OWNER AND FK.R_CONSTRAINT_NAME = PK.CONSTRAINT_NAME
JOIN DBA_CONS_COLUMNS FK_CC ON FK.OWNER = FK_CC.OWNER AND FK.CONSTRAINT_NAME = FK_CC.CONSTRAINT_NAME
JOIN DBA_CONS_COLUMNS PK_CC ON PK.OWNER = PK_CC.OWNER AND PK.CONSTRAINT_NAME = PK_CC.CONSTRAINT_NAME
WHERE FK.OWNER = UPPER('&SCHEMA_NAME')
    AND FK.CONSTRAINT_TYPE = 'R'
GROUP BY FK.OWNER, FK.TABLE_NAME, FK.CONSTRAINT_NAME, PK.TABLE_NAME, PK.CONSTRAINT_NAME
ORDER BY FK.TABLE_NAME;

-- ============================================================
-- 4. ÍNDICES
-- ============================================================
PROMPT ============================================================
PROMPT 4. ÍNDICES
PROMPT ============================================================

SELECT 
    I.OWNER,
    I.TABLE_NAME,
    I.INDEX_NAME,
    I.INDEX_TYPE,
    I.UNIQUENESS,
    I.TABLESPACE_NAME,
    LISTAGG(IC.COLUMN_NAME, ', ') WITHIN GROUP (ORDER BY IC.COLUMN_POSITION) AS COLUMNS,
    I.STATUS
FROM DBA_INDEXES I
JOIN DBA_IND_COLUMNS IC ON I.OWNER = IC.INDEX_OWNER 
    AND I.INDEX_NAME = IC.INDEX_NAME
WHERE I.OWNER = UPPER('&SCHEMA_NAME')
    AND I.TABLE_OWNER = UPPER('&SCHEMA_NAME')
GROUP BY I.OWNER, I.TABLE_NAME, I.INDEX_NAME, I.INDEX_TYPE, 
    I.UNIQUENESS, I.TABLESPACE_NAME, I.STATUS
ORDER BY I.TABLE_NAME, I.INDEX_NAME;

-- ============================================================
-- 5. SEQUENCES
-- ============================================================
PROMPT ============================================================
PROMPT 5. SEQUENCES
PROMPT ============================================================

SELECT 
    SEQUENCE_OWNER,
    SEQUENCE_NAME,
    MIN_VALUE,
    MAX_VALUE,
    INCREMENT_BY,
    CYCLE_FLAG,
    ORDER_FLAG,
    CACHE_SIZE,
    LAST_NUMBER
FROM DBA_SEQUENCES
WHERE SEQUENCE_OWNER = UPPER('&SCHEMA_NAME')
ORDER BY SEQUENCE_NAME;

-- ============================================================
-- 6. VIEWS
-- ============================================================
PROMPT ============================================================
PROMPT 6. VIEWS
PROMPT ============================================================

SELECT 
    OWNER,
    VIEW_NAME,
    TEXT_LENGTH,
    READ_ONLY
FROM DBA_VIEWS
WHERE OWNER = UPPER('&SCHEMA_NAME')
ORDER BY VIEW_NAME;

-- Obter o texto completo das views (pode ser muito grande)
SELECT 
    OWNER,
    VIEW_NAME,
    TEXT
FROM DBA_VIEWS
WHERE OWNER = UPPER('&SCHEMA_NAME')
ORDER BY VIEW_NAME;

-- ============================================================
-- 7. PROCEDURES E FUNCTIONS
-- ============================================================
PROMPT ============================================================
PROMPT 7. PROCEDURES E FUNCTIONS
PROMPT ============================================================

SELECT 
    OWNER,
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS,
    CREATED,
    LAST_DDL_TIME
FROM DBA_OBJECTS
WHERE OWNER = UPPER('&SCHEMA_NAME')
    AND OBJECT_TYPE IN ('PROCEDURE', 'FUNCTION', 'PACKAGE', 'PACKAGE BODY')
ORDER BY OBJECT_TYPE, OBJECT_NAME;

-- ============================================================
-- 8. TRIGGERS
-- ============================================================
PROMPT ============================================================
PROMPT 8. TRIGGERS
PROMPT ============================================================

SELECT 
    OWNER,
    TRIGGER_NAME,
    TABLE_NAME,
    TRIGGER_TYPE,
    TRIGGERING_EVENT,
    STATUS,
    BASE_OBJECT_TYPE
FROM DBA_TRIGGERS
WHERE OWNER = UPPER('&SCHEMA_NAME')
ORDER BY TABLE_NAME, TRIGGER_NAME;

-- ============================================================
-- 9. ESTATÍSTICAS DE USO (TABELAS MAIS ACESSADAS)
-- ============================================================
PROMPT ============================================================
PROMPT 9. ESTATÍSTICAS DE DADOS
PROMPT ============================================================

SELECT 
    OWNER,
    TABLE_NAME,
    NUM_ROWS,
    BLOCKS,
    EMPTY_BLOCKS,
    AVG_ROW_LEN,
    LAST_ANALYZED
FROM DBA_TABLES
WHERE OWNER = UPPER('&SCHEMA_NAME')
    AND NUM_ROWS IS NOT NULL
ORDER BY NUM_ROWS DESC;

-- ============================================================
-- 10. RESUMO DE VOLUME DE DADOS
-- ============================================================
PROMPT ============================================================
PROMPT 10. RESUMO GERAL
PROMPT ============================================================

SELECT 
    'Tabelas' AS TIPO,
    COUNT(*) AS QUANTIDADE
FROM DBA_TABLES
WHERE OWNER = UPPER('&SCHEMA_NAME')
UNION ALL
SELECT 
    'Views' AS TIPO,
    COUNT(*) AS QUANTIDADE
FROM DBA_VIEWS
WHERE OWNER = UPPER('&SCHEMA_NAME')
UNION ALL
SELECT 
    'Procedures' AS TIPO,
    COUNT(*) AS QUANTIDADE
FROM DBA_OBJECTS
WHERE OWNER = UPPER('&SCHEMA_NAME')
    AND OBJECT_TYPE = 'PROCEDURE'
UNION ALL
SELECT 
    'Functions' AS TIPO,
    COUNT(*) AS QUANTIDADE
FROM DBA_OBJECTS
WHERE OWNER = UPPER('&SCHEMA_NAME')
    AND OBJECT_TYPE = 'FUNCTION'
UNION ALL
SELECT 
    'Triggers' AS TIPO,
    COUNT(*) AS QUANTIDADE
FROM DBA_TRIGGERS
WHERE OWNER = UPPER('&SCHEMA_NAME')
UNION ALL
SELECT 
    'Sequences' AS TIPO,
    COUNT(*) AS QUANTIDADE
FROM DBA_SEQUENCES
WHERE SEQUENCE_OWNER = UPPER('&SCHEMA_NAME');

SPOOL OFF

-- ============================================================
-- INSTRUÇÕES:
-- 1. Substitua &SCHEMA_NAME pelo nome do schema Oracle
-- 2. Execute este script com permissões DBA ou do proprietário do schema
-- 3. Revise o arquivo analise_oracle_schema.log gerado
-- ============================================================
