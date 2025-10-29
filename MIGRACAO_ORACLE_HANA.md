# Guia de Migração: Oracle → SAP HANA

Este documento descreve o processo completo de migração de um banco de dados Oracle para SAP HANA em um ambiente SAP.

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Pré-requisitos](#pré-requisitos)
3. [Fases da Migração](#fases-da-migração)
4. [Mapeamento de Tipos de Dados](#mapeamento-de-tipos-de-dados)
5. [Execução da Migração](#execução-da-migração)
6. [Validação e Testes](#validação-e-testes)
7. [Troubleshooting](#troubleshooting)

## 🎯 Visão Geral

A migração do Oracle para SAP HANA envolve:
- Análise do schema atual no Oracle
- Conversão de tipos de dados
- Criação do schema no HANA
- Migração de dados
- Conversão de objetos (procedures, views, triggers)
- Validação e ajustes

## 🔧 Pré-requisitos

### Ambiente Oracle (Origem)
- Acesso ao banco Oracle com permissões de leitura
- SQL*Plus ou SQL Developer instalado
- Conhecimento do schema a ser migrado

### Ambiente SAP HANA (Destino)
- SAP HANA instalado e configurado
- SAP HANA Studio ou HANA Database Explorer
- Usuário com permissões DBA/DDL
- Espaço em disco suficiente (HANA requer mais espaço que Oracle)

### Ferramentas Adicionais
- SAP Data Services (opcional, para migração de dados)
- SAP Migration Workbench (recomendado para migrações complexas)

## 📊 Fases da Migração

### Fase 1: Análise do Ambiente Oracle
1. Extrair metadados do schema (tabelas, colunas, índices, constraints)
2. Identificar dependências entre objetos
3. Analisar volumes de dados
4. Identificar objetos específicos do Oracle que precisam ser convertidos

### Fase 2: Preparação do Ambiente HANA
1. Criar schema no HANA
2. Configurar parâmetros de memória se necessário
3. Preparar espaço de armazenamento

### Fase 3: Migração de Schema
1. Converter DDL do Oracle para HANA
2. Criar tabelas no HANA
3. Criar índices e constraints
4. Verificar integridade estrutural

### Fase 4: Migração de Dados
1. Extrair dados do Oracle
2. Converter dados conforme mapeamento de tipos
3. Importar dados no HANA
4. Validar integridade dos dados

### Fase 5: Migração de Objetos de Banco
1. Converter procedures e functions
2. Converter views
3. Converter triggers (com ajustes para HANA)
4. Converter sequences

### Fase 6: Ajustes Pós-Migração
1. Revisar performance
2. Criar índices adicionais se necessário
3. Atualizar estatísticas
4. Testar aplicações conectadas

## 🔄 Mapeamento de Tipos de Dados

| Oracle | SAP HANA | Observações |
|--------|----------|-------------|
| NUMBER | DECIMAL, INTEGER, BIGINT | HANA é mais específico com tipos numéricos |
| NUMBER(p,s) | DECIMAL(p,s) | Precisão e escala mantidas |
| VARCHAR2(n) | VARCHAR(n) ou NVARCHAR(n) | Use NVARCHAR para Unicode |
| CHAR(n) | CHAR(n) | Pode usar NCHAR para Unicode |
| DATE | TIMESTAMP | HANA não tem tipo DATE nativo |
| TIMESTAMP | TIMESTAMP | Compatível |
| CLOB | NCLOB | Use NCLOB para suporte Unicode completo |
| BLOB | BLOB | Compatível |
| LONG | CLOB/NCLOB | Oracle LONG é obsoleto |
| RAW(n) | VARBINARY(n) | Dados binários |
| ROWID | Não aplicável | HANA usa outros mecanismos |

## 🚀 Execução da Migração

Siga os scripts na seguinte ordem:

1. **01_analise_oracle.sql** - Análise do schema Oracle
2. **02_mapeamento_tipos.md** - Revisar mapeamento de tipos
3. **03_criar_schema_hana.sql** - Criação do schema no HANA
4. **04_migrar_dados.sql** - Scripts de migração de dados
5. **05_migrar_objetos.sql** - Migração de procedures, views, etc.
6. **06_validacao.sql** - Scripts de validação

## ✅ Validação e Testes

Após a migração, execute:
- Contagem de registros por tabela
- Validação de constraints
- Teste de integridade referencial
- Validação de valores calculados
- Performance testing

## 🔍 Troubleshooting

### Problemas Comuns

**Erro: Espaço insuficiente**
- HANA usa compressão de memória, mas ainda requer espaço adequado
- Verifique tabelas colunares vs. tabelas em linha

**Erro: Tipos de dados incompatíveis**
- Revise o mapeamento de tipos
- Use funções de conversão quando necessário

**Erro: Performance degradada**
- HANA é otimizado para tabelas colunares
- Considere converter tabelas grandes para formato colunar

**Erro: Procedures não funcionam**
- HANA usa SQLScript, não PL/SQL
- Muitas funções Oracle não existem no HANA
- Requer reescrita significativa

## 📝 Notas Importantes

1. **Tabelas Colunares**: HANA é otimizado para tabelas colunares. Considere usar este formato para tabelas grandes.

2. **Unicode**: SAP HANA usa UTF-8 por padrão. Use tipos NVARCHAR, NCHAR, NCLOB para dados Unicode.

3. **Procedures**: PL/SQL não é suportado no HANA. Use SQLScript, que é similar mas tem diferenças significativas.

4. **Sequences**: HANA suporta sequences mas com sintaxe diferente.

5. **Partitioning**: HANA tem diferentes opções de particionamento comparado ao Oracle.

## 🔗 Referências

- SAP HANA SQL Reference Guide
- SAP HANA Migration Guide
- SAP Note sobre migração Oracle → HANA

---

**Data de Criação**: 2024
**Versão**: 1.0
