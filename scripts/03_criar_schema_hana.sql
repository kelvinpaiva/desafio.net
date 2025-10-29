-- ============================================================
-- Script 03: Criação de Schema no SAP HANA
-- Objetivo: Criar estrutura de tabelas no HANA baseado
-- na análise do Oracle
-- ============================================================

-- IMPORTANTE: Este é um TEMPLATE. Você precisa adaptar baseado
-- na saída do script 01_analise_oracle.sql

-- ============================================================
-- CONFIGURAÇÕES INICIAIS
-- ============================================================

-- Criar schema se não existir
CREATE SCHEMA "MIGRADO_ORACLE" IF NOT EXISTS;

-- Definir schema padrão
SET SCHEMA "MIGRADO_ORACLE";

-- ============================================================
-- FUNÇÃO AUXILIAR: Converter tipos Oracle para HANA
-- ============================================================
-- Oracle NUMBER -> HANA DECIMAL/INTEGER/BIGINT
-- Oracle VARCHAR2 -> HANA NVARCHAR (para Unicode)
-- Oracle DATE -> HANA TIMESTAMP
-- Oracle CLOB -> HANA NCLOB
-- Oracle BLOB -> HANA BLOB

-- ============================================================
-- EXEMPLO DE CRIAÇÃO DE TABELAS
-- ============================================================
-- Adicione aqui suas tabelas baseadas na análise do Oracle

/*
EXEMPLO DE CONVERSÃO:

ORACLE:
CREATE TABLE USUARIOS (
    ID NUMBER(10) PRIMARY KEY,
    NOME VARCHAR2(100) NOT NULL,
    EMAIL VARCHAR2(255),
    DATA_CRIACAO DATE,
    ATIVO CHAR(1) DEFAULT 'Y'
);

HANA:
CREATE COLUMN TABLE "USUARIOS" (
    "ID" INTEGER NOT NULL,
    "NOME" NVARCHAR(100) NOT NULL,
    "EMAIL" NVARCHAR(255),
    "DATA_CRIACAO" TIMESTAMP,
    "ATIVO" NVARCHAR(1) DEFAULT 'Y',
    PRIMARY KEY ("ID")
);

-- ============================================================
-- IMPORTANTE: Tabelas Colunares vs. Tabelas em Linha
-- ============================================================
-- HANA suporta dois formatos:
-- 1. COLUMN TABLE: Otimizada para OLAP, queries analíticas (padrão recomendado)
-- 2. ROW TABLE: Otimizada para OLTP, alta concorrência de escrita

-- Use COLUMN TABLE para:
--   - Tabelas grandes (> 10 milhões de linhas)
--   - Tabelas principalmente para leitura
--   - Tabelas de fato em data warehouses
--   - Tabelas de histórico

-- Use ROW TABLE para:
--   - Tabelas pequenas (< 1 milhão de linhas)
--   - Tabelas com muita concorrência de escrita
--   - Tabelas de dimensão frequentemente atualizadas
--   - Tabelas com muitos índices

-- ============================================================
-- ESTRUTURA BASE PARA CADA TABELA
-- ============================================================
*/

-- Template genérico (remova e substitua pelos seus dados):
/*
CREATE COLUMN TABLE "NOME_TABELA" (
    -- Colunas com tipos HANA apropriados
    "COLUNA1" INTEGER NOT NULL,
    "COLUNA2" NVARCHAR(255),
    "COLUNA3" DECIMAL(10,2),
    "COLUNA4" TIMESTAMP,
    
    -- Primary Key
    PRIMARY KEY ("COLUNA1")
);
*/

-- ============================================================
-- CRIAR ÍNDICES
-- ============================================================
-- Índices no HANA são criados após a criação da tabela

/*
CREATE INDEX "IDX_NOME_TABELA_COLUNA" ON "NOME_TABELA" ("COLUNA");
*/

-- Índices únicos
/*
CREATE UNIQUE INDEX "IDX_UNIQUE_NOME_TABELA_COLUNA" ON "NOME_TABELA" ("COLUNA");
*/

-- ============================================================
-- CRIAR FOREIGN KEYS
-- ============================================================
-- NOTA: HANA suporta foreign keys, mas em tabelas colunares
-- pode haver limitações de performance

/*
ALTER TABLE "TABELA_FILHA" 
ADD CONSTRAINT "FK_TABELA_FILHA_PAI" 
FOREIGN KEY ("ID_PAI") 
REFERENCES "TABELA_PAI" ("ID");
*/

-- ============================================================
-- CRIAR SEQUENCES (SEQUÊNCIAS)
-- ============================================================
-- Sintaxe HANA para sequences é diferente do Oracle

/*
CREATE SEQUENCE "SEQ_NOME"
START WITH 1
INCREMENT BY 1
MAXVALUE 999999999
CYCLE;
*/

-- Para usar a sequence:
-- SELECT "SEQ_NOME".NEXTVAL FROM DUMMY;

-- ============================================================
-- CRIAR CHECK CONSTRAINTS
-- ============================================================
/*
ALTER TABLE "NOME_TABELA"
ADD CONSTRAINT "CHK_NOME_TABELA_VALOR"
CHECK ("COLUNA" IN ('VALOR1', 'VALOR2', 'VALOR3'));
*/

-- ============================================================
-- GRANTS (PERMISSÕES)
-- ============================================================
-- Conceder permissões ao schema/applicativo

/*
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA "MIGRADO_ORACLE" TO "USUARIO_APP";
*/

-- ============================================================
-- NOTAS IMPORTANTES:
-- ============================================================
-- 1. Use aspas duplas para nomes case-sensitive
-- 2. HANA é case-sensitive por padrão
-- 3. Use NVARCHAR em vez de VARCHAR para suporte Unicode completo
-- 4. DATE no Oracle vira TIMESTAMP no HANA
-- 5. NUMBER sem precisão no Oracle precisa ser mapeado manualmente
--    (DECIMAL, INTEGER, BIGINT, etc.)
-- 6. CLOB no Oracle vira NCLOB no HANA
-- 7. Considere usar tabelas colunares para melhor performance
-- 8. Não crie foreign keys desnecessárias em tabelas colunares grandes
-- ============================================================
