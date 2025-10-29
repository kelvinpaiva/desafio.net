-- ============================================================
-- Script 05: Migração de Objetos (Procedures, Views, Triggers)
-- Objetivo: Converter objetos Oracle para SAP HANA SQLScript
-- ============================================================

-- ============================================================
-- IMPORTANTE: Diferenças Críticas Oracle PL/SQL vs. HANA SQLScript
-- ============================================================
-- 1. HANA usa SQLScript, não PL/SQL
-- 2. Muitas funções Oracle não existem no HANA
-- 3. Triggers têm sintaxe diferente
-- 4. Packages não existem no HANA (substituir por procedures)
-- 5. Cursors implícitos têm tratamento diferente
-- 6. Exception handling é diferente

-- ============================================================
-- 1. VIEWS
-- ============================================================
-- Views são mais fáceis de converter, mas requerem atenção a:
-- - Funções Oracle específicas (NVL, DECODE, etc.)
-- - Hierarchical queries (CONNECT BY)
-- - ROWNUM

-- Exemplo de conversão de VIEW:

/*
-- ORACLE:
CREATE OR REPLACE VIEW VW_USUARIOS_ATIVOS AS
SELECT 
    ID,
    NOME,
    EMAIL,
    NVL(ATIVO, 'N') AS STATUS,
    ROWNUM AS LINHA
FROM USUARIOS
WHERE ATIVO = 'Y';

-- HANA:
CREATE VIEW "VW_USUARIOS_ATIVOS" AS
SELECT 
    "ID",
    "NOME",
    "EMAIL",
    COALESCE("ATIVO", 'N') AS "STATUS",
    ROW_NUMBER() OVER (ORDER BY "ID") AS "LINHA"
FROM "USUARIOS"
WHERE "ATIVO" = 'Y';
*/

-- Funções Oracle → HANA:
-- NVL() → COALESCE()
-- DECODE() → CASE WHEN
-- SYSDATE → CURRENT_TIMESTAMP
-- TO_CHAR() → TO_VARCHAR() ou TO_NVARCHAR()
-- TO_DATE() → TO_TIMESTAMP()
-- ROWNUM → ROW_NUMBER() OVER()

-- ============================================================
-- 2. PROCEDURES - TEMPLATE BÁSICO
-- ============================================================

/*
-- ORACLE PROCEDURE:
CREATE OR REPLACE PROCEDURE PROC_EXEMPLO (
    P_ID IN NUMBER,
    P_NOME OUT VARCHAR2
) AS
BEGIN
    SELECT NOME INTO P_NOME
    FROM USUARIOS
    WHERE ID = P_ID;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        P_NOME := 'NÃO ENCONTRADO';
END;

-- HANA SQLScript PROCEDURE:
CREATE PROCEDURE "PROC_EXEMPLO" (
    IN P_ID INTEGER,
    OUT P_NOME NVARCHAR(100)
)
LANGUAGE SQLSCRIPT
READS SQL DATA AS
BEGIN
    SELECT "NOME" INTO P_NOME
    FROM "USUARIOS"
    WHERE "ID" = P_ID;
    
    IF P_NOME IS NULL THEN
        P_NOME := 'NÃO ENCONTRADO';
    END IF;
END;
*/

-- ============================================================
-- 3. FUNCTIONS
-- ============================================================

/*
-- ORACLE FUNCTION:
CREATE OR REPLACE FUNCTION FUNC_SOMA (
    A NUMBER,
    B NUMBER
) RETURN NUMBER AS
BEGIN
    RETURN A + B;
END;

-- HANA FUNCTION:
CREATE FUNCTION "FUNC_SOMA" (
    A INTEGER,
    B INTEGER
) RETURNS INTEGER
LANGUAGE SQLSCRIPT
READS SQL DATA AS
BEGIN
    RETURN A + B;
END;
*/

-- ============================================================
-- 4. TRIGGERS
-- ============================================================
-- IMPORTANTE: Triggers no HANA têm limitações significativas
-- - Não podem executar DDL
-- - Limitações em triggers AFTER para tabelas colunares
-- - Considerar usar procedures ou aplicação no lugar

/*
-- ORACLE TRIGGER:
CREATE OR REPLACE TRIGGER TRG_USUARIOS_BIU
BEFORE INSERT OR UPDATE ON USUARIOS
FOR EACH ROW
BEGIN
    :NEW.DATA_MODIFICACAO := SYSDATE;
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_USUARIOS.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;

-- HANA TRIGGER (sintaxe diferente):
CREATE TRIGGER "TRG_USUARIOS_BIU"
BEFORE INSERT OR UPDATE ON "USUARIOS"
REFERENCING NEW ROW AS NEW_ROW
FOR EACH ROW
BEGIN
    NEW_ROW."DATA_MODIFICACAO" := CURRENT_TIMESTAMP;
    IF NEW_ROW."ID" IS NULL THEN
        SELECT "SEQ_USUARIOS".NEXTVAL INTO NEW_ROW."ID" FROM DUMMY;
    END IF;
END;
*/

-- ============================================================
-- 5. PACKAGES - CONVERSÃO
-- ============================================================
-- HANA não suporta Packages Oracle
-- Opções:
-- 1. Converter cada procedure/function do package em objeto separado
-- 2. Prefixar nomes com nome do package
-- 3. Criar procedures wrapper que chamam outras procedures

/*
-- ORACLE PACKAGE:
CREATE PACKAGE PKG_USUARIOS AS
    PROCEDURE PROC_BUSCAR(ID IN NUMBER, RESULT OUT CURSOR);
    FUNCTION FUNC_CONTAR RETURN NUMBER;
END;

-- HANA: Converter em procedures/functions separadas
CREATE PROCEDURE "PKG_USUARIOS_PROC_BUSCAR" (
    IN ID INTEGER,
    OUT RESULT TABLE(...)
)
LANGUAGE SQLSCRIPT AS
BEGIN
    -- Implementação
END;

CREATE FUNCTION "PKG_USUARIOS_FUNC_CONTAR"()
RETURNS INTEGER
LANGUAGE SQLSCRIPT AS
BEGIN
    -- Implementação
END;
*/

-- ============================================================
-- 6. CURSORS
-- ============================================================

/*
-- ORACLE CURSOR:
DECLARE
    CURSOR C_USUARIOS IS
        SELECT ID, NOME FROM USUARIOS;
BEGIN
    FOR R IN C_USUARIOS LOOP
        DBMS_OUTPUT.PUT_LINE(R.NOME);
    END LOOP;
END;

-- HANA: Usar tabela temporária ou loop com variável
DO
BEGIN
    DECLARE C_USUARIOS TABLE (ID INTEGER, NOME NVARCHAR(100));
    DECLARE I INTEGER := 1;
    DECLARE TOTAL INTEGER;
    
    C_USUARIOS = SELECT "ID", "NOME" FROM "USUARIOS";
    SELECT COUNT(*) INTO TOTAL FROM :C_USUARIOS;
    
    WHILE I <= TOTAL DO
        -- Processar linha I
        I := I + 1;
    END WHILE;
END;
*/

-- ============================================================
-- 7. EXCEPTION HANDLING
-- ============================================================

/*
-- ORACLE:
BEGIN
    INSERT INTO TABELA VALUES (...);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Duplicado');
    WHEN OTHERS THEN
        RAISE;
END;

-- HANA:
BEGIN
    INSERT INTO "TABELA" VALUES (...);
EXCEPTION
    WHEN OTHER THEN
        -- HANA não tem exceções específicas como Oracle
        -- Verificar código de erro retornado
        -- ou usar variáveis de retorno
END;
*/

-- ============================================================
-- 8. FUNÇÕES ORACLE ESPECÍFICAS → HANA
-- ============================================================

/*
LISTA DE CONVERSÕES COMUNS:

Oracle                    →  HANA
----------------------------------------------------------
SYSDATE                   →  CURRENT_TIMESTAMP
TRUNC(SYSDATE)            →  CURRENT_DATE
NEXT_DAY()                →  ADD_DAYS() + cálculos
ADD_MONTHS()              →  ADD_MONTHS() (suportado)
MONTHS_BETWEEN()          →  DAYS_BETWEEN() / 30
TO_CHAR()                 →  TO_VARCHAR() / TO_NVARCHAR()
TO_NUMBER()               →  CAST() ou TO_INTEGER()
SUBSTR()                  →  SUBSTRING()
INSTR()                   →  LOCATE()
LPAD() / RPAD()           →  LPAD() / RPAD() (suportado)
REPLACE()                 →  REPLACE() (suportado)
ROWNUM                    →  ROW_NUMBER() OVER()
RANK()                    →  RANK() OVER() (similar)
DENSE_RANK()              →  DENSE_RANK() OVER()
LISTAGG()                 →  STRING_AGG()
CONNECT BY                →  Hierarchical queries (sintaxe diferente)
REGEXP_LIKE()             →  LIKE_REGEXPR()
DBMS_OUTPUT.PUT_LINE()    →  Não existe (usar SELECT ou log)
*/

-- ============================================================
-- 9. HIERARCHICAL QUERIES (CONNECT BY)
-- ============================================================

/*
-- ORACLE CONNECT BY:
SELECT LEVEL, ID, NOME, PAI_ID
FROM ESTRUTURA
START WITH PAI_ID IS NULL
CONNECT BY PRIOR ID = PAI_ID;

-- HANA Hierarchical Query:
SELECT 
    PATH.NODE_LEVEL AS LEVEL,
    PATH.NODE_ID AS ID,
    T."NOME",
    T."PAI_ID"
FROM HIERARCHY (
    SOURCE (
        SELECT "ID", "NOME", "PAI_ID"
        FROM "ESTRUTURA"
    )
    START WHERE "PAI_ID" IS NULL
    JOIN PARENT "ID" ON CHILD "PAI_ID"
) AS PATH
JOIN "ESTRUTURA" AS T ON PATH.NODE_ID = T."ID";
*/

-- ============================================================
-- 10. TEMPLATE PARA MIGRAÇÃO DE PROCEDURE
-- ============================================================

/*
-- Passos para converter uma procedure Oracle:
-- 1. Identificar todos os parâmetros e tipos
-- 2. Converter tipos Oracle para HANA
-- 3. Substituir funções Oracle por equivalentes HANA
-- 4. Converter tratamento de exceções
-- 5. Converter cursors se houver
-- 6. Testar procedure convertida

-- Template:
CREATE PROCEDURE "NOME_PROCEDURE" (
    IN PARAM1 INTEGER,
    INOUT PARAM2 NVARCHAR(255),
    OUT PARAM3 TABLE(...)
)
LANGUAGE SQLSCRIPT
READS SQL DATA  -- ou WRITES SQL DATA, ou DETERMINISTIC
AS
BEGIN
    -- Variáveis locais
    DECLARE VAR1 INTEGER;
    DECLARE VAR2 NVARCHAR(100);
    
    -- Lógica da procedure
    -- ...
    
    -- Retorno (se necessário)
    PARAM3 = SELECT ... FROM ...;
END;
*/

-- ============================================================
-- CHECKLIST DE MIGRAÇÃO DE OBJETOS
-- ============================================================
/*
[ ] Identificar todos os objetos a migrar
[ ] Documentar dependências entre objetos
[ ] Converter tipos de dados
[ ] Substituir funções Oracle por equivalentes HANA
[ ] Converter sintaxe de triggers
[ ] Converter packages em procedures/functions separadas
[ ] Testar cada objeto convertido
[ ] Validar resultados (comparar outputs Oracle vs HANA)
[ ] Documentar limitações encontradas
[ ] Criar procedimentos alternativos se necessário
*/

-- ============================================================
-- FERRAMENTAS ÚTEIS
-- ============================================================
-- 1. SAP HANA Migration Workbench (se disponível)
-- 2. Scripts de análise de dependências
-- 3. Ferramentas de teste automatizado
-- 4. Documentação de migração mantida atualizada
