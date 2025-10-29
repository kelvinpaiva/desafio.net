-- ============================================================
-- Script 06: Validação Pós-Migração
-- Objetivo: Validar integridade e consistência dos dados
-- migrados do Oracle para SAP HANA
-- ============================================================

-- ============================================================
-- 1. VALIDAÇÃO DE CONTAGEM DE REGISTROS
-- ============================================================

-- Criar tabela de validação
CREATE COLUMN TABLE "VALIDACAO_CONTAGEM" (
    "TABELA" NVARCHAR(255) NOT NULL,
    "REGISTROS_ORACLE" BIGINT,
    "REGISTROS_HANA" BIGINT,
    "DIFERENCA" BIGINT,
    "STATUS" NVARCHAR(50),
    "DATA_VALIDACAO" TIMESTAMP,
    PRIMARY KEY ("TABELA")
);

-- Template de validação (preencher manualmente ou via script)
/*
-- Para cada tabela, compare:
INSERT INTO "VALIDACAO_CONTAGEM" VALUES (
    'NOME_TABELA',
    (SELECT COUNT(*) FROM ORACLE_SCHEMA.TABELA),  -- Execute no Oracle
    (SELECT COUNT(*) FROM "HANA_SCHEMA"."TABELA"), -- Execute no HANA
    NULL,
    NULL,
    CURRENT_TIMESTAMP
);

-- Atualizar diferenças e status
UPDATE "VALIDACAO_CONTAGEM"
SET 
    "DIFERENCA" = ABS("REGISTROS_ORACLE" - "REGISTROS_HANA"),
    "STATUS" = CASE 
        WHEN ABS("REGISTROS_ORACLE" - "REGISTROS_HANA") = 0 THEN 'OK'
        ELSE 'DIVERGENTE'
    END;
*/

-- ============================================================
-- 2. VALIDAÇÃO DE INTEGRIDADE REFERENCIAL
-- ============================================================

-- Verificar Foreign Keys órfãs (registros sem referência)
/*
SELECT 
    'FK_NOME' AS CONSTRAINT_NAME,
    'TABELA_FILHA' AS TABLE_NAME,
    COUNT(*) AS REGISTROS_ORFAOS
FROM "TABELA_FILHA" F
LEFT JOIN "TABELA_PAI" P ON F."ID_PAI" = P."ID"
WHERE P."ID" IS NULL;
*/

-- ============================================================
-- 3. VALIDAÇÃO DE DADOS (VALORES ESPECÍFICOS)
-- ============================================================

-- Comparar sumários estatísticos
/*
-- Oracle (execute separadamente):
SELECT 
    COUNT(*) AS TOTAL,
    SUM(VALOR) AS SOMA_VALOR,
    AVG(VALOR) AS MEDIA_VALOR,
    MIN(VALOR) AS MIN_VALOR,
    MAX(VALOR) AS MAX_VALOR
FROM TABELA;

-- HANA:
SELECT 
    COUNT(*) AS TOTAL,
    SUM("VALOR") AS SOMA_VALOR,
    AVG("VALOR") AS MEDIA_VALOR,
    MIN("VALOR") AS MIN_VALOR,
    MAX("VALOR") AS MAX_VALOR
FROM "TABELA";
*/

-- Comparar amostras aleatórias
/*
-- Oracle:
SELECT * FROM (
    SELECT * FROM TABELA
    ORDER BY DBMS_RANDOM.VALUE
) WHERE ROWNUM <= 100;

-- HANA:
SELECT * FROM "TABELA"
ORDER BY RAND()
LIMIT 100;
*/

-- ============================================================
-- 4. VALIDAÇÃO DE CONSTRAINTS
-- ============================================================

-- Verificar se Primary Keys estão únicas
/*
SELECT 
    "COLUNA_PK",
    COUNT(*) AS CONTAGEM
FROM "TABELA"
GROUP BY "COLUNA_PK"
HAVING COUNT(*) > 1;
-- Resultado deve ser vazio
*/

-- Verificar valores NULL em colunas NOT NULL
/*
SELECT 
    COUNT(*) AS REGISTROS_COM_NULL
FROM "TABELA"
WHERE "COLUNA_NOT_NULL" IS NULL;
-- Resultado deve ser 0
*/

-- Verificar Check Constraints
/*
SELECT 
    COUNT(*) AS REGISTROS_INVALIDOS
FROM "TABELA"
WHERE "COLUNA" NOT IN ('VALOR1', 'VALOR2', 'VALOR3');
-- Ajustar conforme sua constraint
*/

-- ============================================================
-- 5. VALIDAÇÃO DE TIPOS E CONVERSÕES
-- ============================================================

-- Verificar conversões de data/timestamp
/*
SELECT 
    COUNT(*) AS REGISTROS_COM_DATA_INVALIDA
FROM "TABELA"
WHERE "DATA_COLUNA" IS NOT NULL
    AND ("DATA_COLUNA" < '1900-01-01' OR "DATA_COLUNA" > '2100-12-31');
*/

-- Verificar valores numéricos
/*
SELECT 
    COUNT(*) AS REGISTROS_COM_PRECISAO_EXCEDIDA
FROM "TABELA"
WHERE LENGTH(CAST("DECIMAL_COLUNA" AS NVARCHAR)) > 10;  -- Ajustar conforme precisão
*/

-- ============================================================
-- 6. VALIDAÇÃO DE PERFORMANCE
-- ============================================================

-- Verificar estatísticas atualizadas
/*
SELECT 
    SCHEMA_NAME,
    TABLE_NAME,
    RECORD_COUNT,
    LAST_TIMESTAMP
FROM SYS.M_CS_TABLES
WHERE SCHEMA_NAME = 'SCHEMA_NAME'
ORDER BY LAST_TIMESTAMP DESC;
*/

-- Atualizar estatísticas se necessário
/*
UPDATE STATISTICS "SCHEMA"."TABELA" WITH FULL SCAN;
*/

-- ============================================================
-- 7. VALIDAÇÃO DE OBJETOS (PROCEDURES, VIEWS, ETC.)
-- ============================================================

-- Verificar se objetos foram criados
/*
SELECT 
    OBJECT_TYPE,
    COUNT(*) AS QUANTIDADE
FROM OBJECTS
WHERE SCHEMA_NAME = 'SCHEMA_NAME'
    AND OBJECT_TYPE IN ('VIEW', 'PROCEDURE', 'FUNCTION', 'TRIGGER')
GROUP BY OBJECT_TYPE;
*/

-- Verificar status de objetos (valid/invalid)
/*
SELECT 
    OBJECT_NAME,
    OBJECT_TYPE,
    STATUS
FROM OBJECTS
WHERE SCHEMA_NAME = 'SCHEMA_NAME'
    AND STATUS != 'VALID';
*/

-- ============================================================
-- 8. VALIDAÇÃO DE SEQUENCES
-- ============================================================

-- Comparar valores de sequences
/*
-- Oracle:
SELECT SEQUENCE_NAME, LAST_NUMBER FROM USER_SEQUENCES;

-- HANA:
SELECT SEQUENCE_NAME, CURRENT_VALUE FROM SEQUENCES 
WHERE SCHEMA_NAME = 'SCHEMA_NAME';

-- Ajustar sequences se necessário
ALTER SEQUENCE "SEQ_NOME" RESTART WITH valor_correto;
*/

-- ============================================================
-- 9. RELATÓRIO DE VALIDAÇÃO COMPLETO
-- ============================================================

-- Criar procedure para gerar relatório
/*
CREATE PROCEDURE "GERAR_RELATORIO_VALIDACAO"()
LANGUAGE SQLSCRIPT
READS SQL DATA AS
BEGIN
    DECLARE VALIDACOES TABLE (
        CATEGORIA NVARCHAR(100),
        TESTE NVARCHAR(255),
        STATUS NVARCHAR(50),
        DETALHES NCLOB
    );
    
    -- Executar todas as validações e inserir resultados
    -- ...
    
    SELECT * FROM :VALIDACOES ORDER BY CATEGORIA, TESTE;
END;
*/

-- ============================================================
-- 10. CHECKLIST DE VALIDAÇÃO
-- ============================================================
/*
VALIDAÇÕES OBRIGATÓRIAS:
[ ] Contagem de registros por tabela (100% match)
[ ] Verificação de Primary Keys (sem duplicatas)
[ ] Verificação de Foreign Keys (sem órfãos)
[ ] Validação de constraints (NOT NULL, CHECK, UNIQUE)
[ ] Comparação de sumários estatísticos (SUM, AVG, MIN, MAX)
[ ] Validação de conversões de tipos (datas, números)
[ ] Verificação de objetos criados (views, procedures, etc.)
[ ] Status de objetos (todos válidos)
[ ] Validação de sequences
[ ] Teste de procedures/functions principais
[ ] Performance básica (queries principais funcionando)
[ ] Backup e documentação completa

VALIDAÇÕES RECOMENDADAS:
[ ] Amostragem aleatória de dados
[ ] Validação de regras de negócio específicas
[ ] Teste de carga (se aplicável)
[ ] Comparação de resultados de queries complexas
[ ] Validação de encoding de caracteres
[ ] Teste de integração com aplicações
*/

-- ============================================================
-- 11. SCRIPT DE CORREÇÃO AUTOMÁTICA
-- ============================================================

-- Template para correções comuns
/*
-- Corrigir sequences
UPDATE STATISTICS "SCHEMA"."TABELA";

-- Recriar índices se necessário
DROP INDEX "IDX_NOME";
CREATE INDEX "IDX_NOME" ON "TABELA" ("COLUNA");

-- Corrigir dados inconsistentes (exemplo)
UPDATE "TABELA"
SET "COLUNA" = 'VALOR_CORRETO'
WHERE "COLUNA" = 'VALOR_INCORRETO';

-- Limpar dados órfãos (cuidado!)
-- DELETE FROM "TABELA_FILHA" WHERE "ID_PAI" NOT IN (SELECT "ID" FROM "TABELA_PAI");
*/

-- ============================================================
-- NOTAS FINAIS
-- ============================================================
-- 1. Execute todas as validações antes de considerar migração completa
-- 2. Documente todos os problemas encontrados
-- 3. Mantenha um log detalhado das validações
-- 4. Compare resultados lado a lado (Oracle vs HANA)
-- 5. Não prossiga para produção sem validação 100% bem-sucedida
-- 6. Considere período de paralelização (Oracle + HANA) antes de desligar Oracle
