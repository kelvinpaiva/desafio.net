-- ============================================================
-- Script 04: Migração de Dados Oracle → SAP HANA
-- Objetivo: Extrair dados do Oracle e importar no HANA
-- ============================================================

-- ============================================================
-- ESTRATÉGIAS DE MIGRAÇÃO DE DADOS
-- ============================================================

-- Opção 1: Export/Import via arquivos CSV/TSV
-- Opção 2: Usar SAP Data Services
-- Opção 3: Usar ETL tools (SAP BODS, Informatica, etc.)
-- Opção 4: Scripts SQL com conexão dual-database
-- Opção 5: Export do Oracle (expdp) e conversão para HANA

-- ============================================================
-- MÉTODO 1: EXPORT CSV DO ORACLE
-- ============================================================
-- Execute no Oracle para exportar cada tabela:

/*
-- SQL*Plus script para exportar tabela para CSV
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET PAGESIZE 0
SET LINESIZE 32767
SET TRIMSPOOL ON
SET COLSEP ','

SPOOL nome_tabela.csv

SELECT * FROM schema.nome_tabela;

SPOOL OFF
*/

-- ============================================================
-- MÉTODO 2: IMPORT CSV NO HANA VIA SQL
-- ============================================================
-- Usando IMPORT FROM na sessão HANA

/*
IMPORT FROM CSV FILE 'path/to/nome_tabela.csv'
INTO "NOME_TABELA"
WITH
    RECORD DELIMITED BY '\n'
    FIELD DELIMITED BY ','
    OPTIONALLY ENCLOSED BY '"'
    SKIP FIRST 1 ROW  -- pular header se houver
    ERROR LOG 'import_errors.log';
*/

-- ============================================================
-- MÉTODO 3: MIGRAÇÃO TABELA POR TABELA (EXEMPLO)
-- ============================================================
-- Este método requer conexão simultânea aos dois bancos
-- ou uso de ferramenta intermediária

/*
-- Exemplo genérico de migração
-- Adapte conforme suas tabelas

INSERT INTO HANA_SCHEMA."TABELA_DESTINO" 
(
    "COLUNA1",
    "COLUNA2",
    "COLUNA3",
    "DATA_CRIACAO"
)
SELECT 
    COLUNA1,
    COLUNA2,
    COLUNA3,
    CAST(DATA_CRIACAO AS TIMESTAMP) AS DATA_CRIACAO  -- Converter DATE para TIMESTAMP
FROM ORACLE_LINK."TABELA_ORIGEM"
WHERE ROWNUM <= 10000;  -- Migrar em lotes
*/

-- ============================================================
-- MÉTODO 4: USANDO SAP DATA SERVICES
-- ============================================================
-- Melhor opção para migrações grandes e complexas
-- Requer SAP Data Services instalado e configurado
-- Interface gráfica facilita transformações de dados

-- ============================================================
-- CONVERSÕES DE DADOS COMUNS
-- ============================================================

-- Conversão de DATE Oracle para TIMESTAMP HANA
/*
SELECT 
    CAST(TO_DATE('2024-01-01', 'YYYY-MM-DD') AS TIMESTAMP) AS DATA_HANA
FROM DUAL;
*/

-- Conversão de NUMBER para DECIMAL específico
/*
SELECT 
    CAST(NUMERO AS DECIMAL(10,2)) AS DECIMAL_HANA
FROM TABELA_ORIGEM;
*/

-- Tratamento de NULLs e valores default
/*
INSERT INTO HANA_TABLE
SELECT 
    COALESCE(COLUNA_NULL, 'VALOR_DEFAULT') AS COLUNA,
    NVL(COLUNA_ORACLE, 0) AS COLUNA_COM_NULL
FROM ORACLE_TABLE;
*/

-- ============================================================
-- SCRIPT DE MIGRAÇÃO EM LOTES
-- ============================================================
-- Para tabelas grandes, migre em lotes para:
-- 1. Reduzir uso de memória
-- 2. Permitir controle de progresso
-- 3. Facilitar rollback se necessário

/*
-- Template para migração em lotes
DO
BEGIN
    DECLARE l_offset INTEGER := 0;
    DECLARE l_batch_size INTEGER := 10000;
    DECLARE l_count INTEGER := 0;
    
    WHILE l_count = l_batch_size DO
        INSERT INTO HANA_TABLE
        SELECT * FROM ORACLE_TABLE
        WHERE ROWNUM BETWEEN l_offset AND l_offset + l_batch_size;
        
        l_count := ROWCOUNT;
        l_offset := l_offset + l_batch_size;
        
        -- Commit a cada lote
        COMMIT;
    END WHILE;
END;
*/

-- ============================================================
-- VALIDAÇÃO PÓS-MIGRAÇÃO
-- ============================================================
-- Compare contagens entre Oracle e HANA

/*
-- Oracle
SELECT COUNT(*) FROM schema.tabela;

-- HANA
SELECT COUNT(*) FROM "schema"."tabela";

-- Comparar valores específicos
SELECT 
    SUM("VALOR") AS TOTAL_HANA
FROM "TABELA"
WHERE "DATA" BETWEEN '2024-01-01' AND '2024-12-31';

-- Comparar com mesmo SELECT no Oracle
*/

-- ============================================================
-- TRATAMENTO DE ERROS COMUNS
-- ============================================================

-- 1. Erro de encoding (Oracle usa diferente do HANA UTF-8)
--    Solução: Garantir que export está em UTF-8

-- 2. Erro de precisão decimal
--    Solução: Verificar mapeamento NUMBER -> DECIMAL

-- 3. Erro de tamanho de campo
--    Solução: Verificar VARCHAR2(4000) -> NVARCHAR (HANA suporta até 5000)

-- 4. Erro de data/timestamp
--    Solução: Converter DATE para TIMESTAMP explicitamente

-- 5. Erro de constraint (foreign key, unique, etc.)
--    Solução: Migrar tabelas em ordem de dependência
--             Ou desabilitar constraints temporariamente

-- ============================================================
-- ORDEM RECOMENDADA DE MIGRAÇÃO
-- ============================================================
-- 1. Tabelas sem dependências (dimensões)
-- 2. Tabelas dependentes (fatos)
-- 3. Dados de lookup/referência
-- 4. Dados históricos
-- 5. Dados transacionais recentes

-- ============================================================
-- PERFORMANCE TIPS
-- ============================================================
-- 1. Desabilite índices antes de importar grandes volumes
-- 2. Importe em paralelo múltiplas tabelas (se possível)
-- 3. Use import nativo do HANA quando disponível
-- 4. Considere usar PARTITIONING para tabelas muito grandes
-- 5. Após migração, execute UPDATE STATISTICS

/*
-- Atualizar estatísticas após migração
UPDATE STATISTICS ON "SCHEMA"."TABELA";
*/

-- ============================================================
-- LOG DE MIGRAÇÃO
-- ============================================================
-- Mantenha um log de:
-- - Tabelas migradas com sucesso
-- - Quantidade de registros
-- - Erros encontrados
-- - Tempo de execução

/*
-- Exemplo de tabela de log
CREATE COLUMN TABLE "MIGRATION_LOG" (
    "TABELA" NVARCHAR(255),
    "REGISTROS_ORIGEM" BIGINT,
    "REGISTROS_DESTINO" BIGINT,
    "DATA_MIGRACAO" TIMESTAMP,
    "STATUS" NVARCHAR(50),
    "OBSERVACOES" NCLOB
);
*/
