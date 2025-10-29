# Scripts de Migração Oracle → SAP HANA

Este diretório contém os scripts necessários para realizar a migração completa de um banco de dados Oracle para SAP HANA.

## 📋 Ordem de Execução

Execute os scripts na seguinte ordem:

### 1. Análise (Oracle)
**Arquivo:** `01_analise_oracle.sql`
- Execute no banco Oracle
- Gera log com toda a estrutura do schema
- **OBS:** Substitua `&SCHEMA_NAME` pelo nome do seu schema antes de executar
- **Saída:** `analise_oracle_schema.log`

### 2. Mapeamento de Tipos
**Arquivo:** `02_mapeamento_tipos.md`
- Documentação de referência
- Revise este arquivo para entender conversões de tipos
- Use como guia ao converter DDLs

### 3. Criação de Schema (HANA)
**Arquivo:** `03_criar_schema_hana.sql`
- Template para criação do schema no HANA
- **AÇÃO NECESSÁRIA:** Adapte baseado na análise do passo 1
- Revise mapeamento de tipos antes de executar

### 4. Migração de Dados
**Arquivo:** `04_migrar_dados.sql`
- Scripts e métodos para migração de dados
- Escolha o método mais adequado ao seu ambiente
- **Recomendado:** SAP Data Services para grandes volumes

### 5. Migração de Objetos
**Arquivo:** `05_migrar_objetos.sql`
- Templates para converter procedures, views, triggers
- **ATENÇÃO:** Requer conversão manual significativa
- PL/SQL não é compatível com SQLScript do HANA

### 6. Validação
**Arquivo:** `06_validacao.sql`
- Scripts de validação pós-migração
- Execute todos os testes antes de considerar migração completa
- Compare resultados Oracle vs HANA

## 🚀 Início Rápido

1. **Analise o Oracle:**
   ```sql
   -- Edite 01_analise_oracle.sql e defina &SCHEMA_NAME
   sqlplus user/password @01_analise_oracle.sql
   ```

2. **Revise a análise:**
   ```bash
   cat analise_oracle_schema.log
   ```

3. **Mapeie os tipos:**
   - Abra `02_mapeamento_tipos.md`
   - Entenda as conversões necessárias

4. **Crie o schema no HANA:**
   - Baseado na análise, adapte `03_criar_schema_hana.sql`
   - Execute no SAP HANA Studio ou Database Explorer

5. **Migre os dados:**
   - Escolha método em `04_migrar_dados.sql`
   - Execute migração tabela por tabela

6. **Converta objetos:**
   - Use templates em `05_migrar_objetos.sql`
   - Adapte procedures/views/triggers manualmente

7. **Valide tudo:**
   - Execute `06_validacao.sql`
   - Corrija problemas encontrados

## ⚠️ Avisos Importantes

- **Backup sempre!** Faça backup completo antes de qualquer alteração
- **Ambiente de teste primeiro:** Teste toda migração em ambiente não-produtivo
- **Tempo estimado:** Migrações grandes podem levar dias ou semanas
- **Dependências:** Algumas conversões requerem conhecimento avançado de ambos sistemas
- **Procedures PL/SQL:** Requerem reescrita manual (não é conversão automática)

## 🛠️ Ferramentas Recomendadas

- **SAP HANA Studio** ou **HANA Database Explorer**
- **SAP Data Services** (para migração de dados)
- **SAP Migration Workbench** (se disponível)
- **SQL Developer** ou **SQL*Plus** (para Oracle)
- **Ferramentas de comparação** (WinMerge, Beyond Compare)

## 📝 Documentação Adicional

Consulte `../MIGRACAO_ORACLE_HANA.md` para documentação completa do processo.

## 🔗 Dependências

- Acesso ao banco Oracle (origem)
- Acesso ao banco SAP HANA (destino)
- Permissões adequadas em ambos os sistemas
- Espaço em disco suficiente no HANA

## 📞 Suporte

Para questões específicas sobre:
- **Oracle:** Consulte documentação Oracle Database
- **SAP HANA:** Consulte SAP Help Portal / SAP Notes
- **Migração:** Consulte SAP Migration Guides

---

**Boa sorte com sua migração!** 🚀
