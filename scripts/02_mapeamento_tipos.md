# Mapeamento de Tipos de Dados: Oracle → SAP HANA

Este documento detalha o mapeamento de tipos de dados do Oracle para SAP HANA, auxiliando na conversão de DDLs durante a migração.

## 📊 Tabela de Mapeamento Completo

| Oracle | Descrição | SAP HANA | Observações |
|--------|-----------|----------|-------------|
| **NUMBER** | Número genérico | DECIMAL(38,0) ou INTEGER | HANA não tem tipo NUMBER genérico |
| **NUMBER(p)** | Número inteiro com precisão | INTEGER (se p≤9) ou BIGINT (se p≤18) ou DECIMAL(p,0) | Escolha baseada no range esperado |
| **NUMBER(p,s)** | Número decimal | DECIMAL(p,s) | Mantém precisão e escala |
| **NUMBER(10)** | Integer de 10 dígitos | INTEGER | Range: -2,147,483,648 a 2,147,483,647 |
| **NUMBER(19)** | Integer grande | BIGINT | Range: -9,223,372,036,854,775,808 a 9,223,372,036,854,775,807 |
| **NUMBER(38)** | Número muito grande | DECIMAL(38,0) | Máximo permitido no HANA |
| **VARCHAR2(n)** | String variável | NVARCHAR(n) | Use NVARCHAR para Unicode completo |
| **VARCHAR2(n CHAR)** | String variável (chars) | NVARCHAR(n) | HANA sempre conta em caracteres Unicode |
| **VARCHAR2(n BYTE)** | String variável (bytes) | NVARCHAR(n) | Converter se necessário (UTF-8 pode usar mais bytes) |
| **CHAR(n)** | String fixa | NCHAR(n) | Recomendado NCHAR para Unicode |
| **NCHAR(n)** | String Unicode fixa | NCHAR(n) | Compatível |
| **NVARCHAR2(n)** | String Unicode variável | NVARCHAR(n) | Compatível |
| **DATE** | Data e hora | TIMESTAMP | HANA não tem tipo DATE, apenas TIMESTAMP |
| **TIMESTAMP** | Timestamp | TIMESTAMP | Compatível |
| **TIMESTAMP WITH TIME ZONE** | Timestamp com fuso | TIMESTAMP | HANA suporta timezone, mas sintaxe diferente |
| **TIMESTAMP WITH LOCAL TIME ZONE** | Timestamp local | TIMESTAMP | Converter conforme necessário |
| **INTERVAL YEAR TO MONTH** | Intervalo ano/mês | Não suportado diretamente | Usar cálculos com ADD_MONTHS() |
| **INTERVAL DAY TO SECOND** | Intervalo dia/segundo | Não suportado diretamente | Usar cálculos com DATEADD |
| **CLOB** | Character Large Object | NCLOB | Use NCLOB para suporte Unicode completo |
| **NCLOB** | Unicode CLOB | NCLOB | Compatível |
| **BLOB** | Binary Large Object | BLOB | Compatível |
| **RAW(n)** | Dados binários | VARBINARY(n) | Compatível |
| **LONG** | Texto longo (obsoleto) | NCLOB | Oracle LONG é obsoleto |
| **LONG RAW** | Binário longo (obsoleto) | BLOB | Oracle LONG RAW é obsoleto |
| **ROWID** | Identificador de linha | Não aplicável | HANA não usa ROWID |
| **UROWID** | ROWID Universal | Não aplicável | HANA não usa ROWID |
| **BINARY_FLOAT** | Float 32-bit | REAL | Compatível |
| **BINARY_DOUBLE** | Double 64-bit | DOUBLE | Compatível |
| **FLOAT** | Número ponto flutuante | DOUBLE | Compatível |

## 🔄 Conversões Especiais

### DATE → TIMESTAMP

**Oracle:**
```sql
DATE_COLUMN DATE
```

**HANA:**
```sql
"DATE_COLUMN" TIMESTAMP
```

**Nota:** Ao migrar dados, use:
```sql
CAST(ORACLE_DATE_COLUMN AS TIMESTAMP) AS HANA_TIMESTAMP_COLUMN
```

### VARCHAR2 → NVARCHAR

**Oracle:**
```sql
NAME VARCHAR2(100)
```

**HANA:**
```sql
"NAME" NVARCHAR(100)
```

**Importante:** HANA suporta até 5000 caracteres por coluna NVARCHAR. Se você tem VARCHAR2(4000) no Oracle, pode usar NVARCHAR(4000) no HANA.

### NUMBER sem Precisão → ?

Quando Oracle tem `NUMBER` sem precisão especificada, você precisa analisar os dados:

1. **Se todos os valores são inteiros pequenos:** Use `INTEGER`
2. **Se valores podem ter decimais:** Use `DECIMAL` com precisão adequada
3. **Se range é muito grande:** Use `DECIMAL(38,0)` ou `DECIMAL` com precisão específica
4. **Analise os dados reais** para determinar a melhor opção

### CLOB → NCLOB

**Oracle:**
```sql
DESCRIPTION CLOB
```

**HANA:**
```sql
"DESCRIPTION" NCLOB
```

**Nota:** NCLOB no HANA suporta dados Unicode completos, que é importante para texto multilíngue.

## ⚠️ Limitações e Considerações

### Tamanho Máximo de Strings

- **Oracle VARCHAR2:** Máximo 4000 bytes (Oracle 12c+ suporta até 32767 com VARCHAR2 extendido)
- **HANA NVARCHAR:** Máximo 5000 caracteres

**Ação:** Verifique se alguma coluna pode exceder 5000 caracteres. Se sim, use NCLOB.

### Precisão Numérica

- **Oracle NUMBER:** Máximo 38 dígitos de precisão
- **HANA DECIMAL:** Máximo 38 dígitos de precisão

**Compatível, mas verifique:** Se você usa precisão específica no Oracle, mantenha a mesma no HANA.

### Encoding

- **Oracle:** Depende da configuração (pode ser UTF-8, WE8ISO8859P1, etc.)
- **HANA:** Sempre UTF-8

**Importante:** Durante a migração, garanta que os dados sejam convertidos corretamente para UTF-8. Use NVARCHAR/NCHAR/NCLOB para garantir suporte Unicode completo.

## 📝 Exemplos Práticos

### Exemplo 1: Tabela de Usuários

**Oracle:**
```sql
CREATE TABLE USUARIOS (
    ID NUMBER(10) PRIMARY KEY,
    NOME VARCHAR2(100) NOT NULL,
    EMAIL VARCHAR2(255),
    SALARIO NUMBER(10,2),
    DATA_NASCIMENTO DATE,
    BIO CLOB,
    FOTO BLOB,
    ATIVO CHAR(1) DEFAULT 'Y'
);
```

**HANA:**
```sql
CREATE COLUMN TABLE "USUARIOS" (
    "ID" INTEGER NOT NULL,
    "NOME" NVARCHAR(100) NOT NULL,
    "EMAIL" NVARCHAR(255),
    "SALARIO" DECIMAL(10,2),
    "DATA_NASCIMENTO" TIMESTAMP,
    "BIO" NCLOB,
    "FOTO" BLOB,
    "ATIVO" NCHAR(1) DEFAULT 'Y',
    PRIMARY KEY ("ID")
);
```

### Exemplo 2: Tabela de Transações

**Oracle:**
```sql
CREATE TABLE TRANSACOES (
    ID NUMBER(38),
    VALOR NUMBER(15,2),
    MOEDA VARCHAR2(3),
    DATA_TRANSACAO TIMESTAMP,
    OBSERVACOES VARCHAR2(4000)
);
```

**HANA:**
```sql
CREATE COLUMN TABLE "TRANSACOES" (
    "ID" DECIMAL(38,0) NOT NULL,
    "VALOR" DECIMAL(15,2),
    "MOEDA" NVARCHAR(3),
    "DATA_TRANSACAO" TIMESTAMP,
    "OBSERVACOES" NVARCHAR(4000),
    PRIMARY KEY ("ID")
);
```

### Exemplo 3: Campos Numéricos Específicos

**Oracle:**
```sql
CREATE TABLE PRODUTOS (
    ID NUMBER(10),
    PRECO NUMBER(10,2),
    QUANTIDADE NUMBER(5),
    PERCENTUAL_DESCONTO NUMBER(5,2)
);
```

**HANA:**
```sql
CREATE COLUMN TABLE "PRODUTOS" (
    "ID" INTEGER NOT NULL,
    "PRECO" DECIMAL(10,2),
    "QUANTIDADE" INTEGER,  -- Number(5) cabe em INTEGER
    "PERCENTUAL_DESCONTO" DECIMAL(5,2),
    PRIMARY KEY ("ID")
);
```

## 🔍 Checklist de Conversão

Ao converter cada tabela, verifique:

- [ ] Todos os NUMBER foram mapeados corretamente (INTEGER/BIGINT/DECIMAL)?
- [ ] DATE foi convertido para TIMESTAMP?
- [ ] VARCHAR2/CHAR foi convertido para NVARCHAR/NCHAR?
- [ ] CLOB foi convertido para NCLOB?
- [ ] Tamanhos de colunas foram mantidos ou ajustados?
- [ ] Constraints (NOT NULL, DEFAULT) foram preservados?
- [ ] Tipos de tabela foram escolhidos (COLUMN vs ROW)?
- [ ] Encoding Unicode foi considerado (NVARCHAR vs VARCHAR)?

## 📚 Referências

- SAP HANA SQL Reference Guide - Data Types
- Oracle to SAP HANA Migration Guide
- SAP Note sobre migração de tipos de dados
