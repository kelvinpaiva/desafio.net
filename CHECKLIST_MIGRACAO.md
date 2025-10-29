# Checklist de Migração Oracle → SAP HANA

Use este checklist para garantir que todas as etapas da migração sejam realizadas corretamente.

## 📋 Pré-Migração

### Planejamento
- [ ] Definir escopo da migração (quais schemas/tabelas)
- [ ] Estimar tempo e recursos necessários
- [ ] Identificar janela de migração (quando fazer)
- [ ] Definir estratégia de rollback
- [ ] Documentar dependências de aplicações
- [ ] Identificar procedimentos críticos do negócio

### Ambiente
- [ ] Validar acesso ao Oracle (origem)
- [ ] Validar acesso ao SAP HANA (destino)
- [ ] Verificar espaço em disco no HANA
- [ ] Configurar ambiente de teste (se aplicável)
- [ ] Preparar ferramentas necessárias
- [ ] Configurar backups automáticos

### Análise
- [ ] Executar script `01_analise_oracle.sql`
- [ ] Revisar estrutura completa do schema
- [ ] Identificar tabelas críticas
- [ ] Identificar volumes de dados (estimativa)
- [ ] Listar todos os objetos (procedures, views, triggers, sequences)
- [ ] Mapear dependências entre objetos
- [ ] Identificar código PL/SQL complexo

## 🔄 Migração de Schema

### Preparação
- [ ] Revisar mapeamento de tipos (`02_mapeamento_tipos.md`)
- [ ] Definir estratégia de tabelas colunares vs. linha
- [ ] Preparar scripts DDL adaptados
- [ ] Revisar constraints e índices

### Criação
- [ ] Criar schema no HANA
- [ ] Criar todas as tabelas
- [ ] Criar todos os índices
- [ ] Criar todas as sequences
- [ ] Adicionar constraints (PK, FK, CHECK, UNIQUE)
- [ ] Validar estrutura criada

### Validação Inicial do Schema
- [ ] Contar tabelas criadas (deve bater com Oracle)
- [ ] Verificar nomes de colunas
- [ ] Verificar tipos de dados
- [ ] Verificar constraints criadas
- [ ] Verificar índices criados

## 📊 Migração de Dados

### Preparação
- [ ] Escolher método de migração (CSV, Data Services, ETL, etc.)
- [ ] Preparar scripts de extração (Oracle)
- [ ] Preparar scripts de importação (HANA)
- [ ] Testar em pequeno volume primeiro
- [ ] Definir ordem de migração (sem dependências primeiro)

### Execução
- [ ] Migrar tabelas de dimensão/lookup primeiro
- [ ] Migrar tabelas principais (fatos)
- [ ] Migrar tabelas dependentes
- [ ] Migrar dados históricos (se aplicável)
- [ ] Atualizar sequences com valores corretos

### Pós-Importação
- [ ] Atualizar estatísticas no HANA
- [ ] Recriar índices (se foram desabilitados durante import)
- [ ] Validar integridade referencial

## 🔧 Migração de Objetos

### Views
- [ ] Listar todas as views
- [ ] Converter sintaxe Oracle → HANA
- [ ] Substituir funções Oracle (NVL → COALESCE, etc.)
- [ ] Converter ROWNUM para ROW_NUMBER() OVER()
- [ ] Converter CONNECT BY (se houver)
- [ ] Testar cada view convertida
- [ ] Validar resultados vs. Oracle

### Procedures e Functions
- [ ] Listar todas as procedures
- [ ] Listar todas as functions
- [ ] Identificar dependências entre procedures
- [ ] Converter PL/SQL para SQLScript
- [ ] Adaptar tratamento de exceções
- [ ] Converter cursors (se houver)
- [ ] Testar cada procedure/function
- [ ] Validar outputs vs. Oracle

### Packages
- [ ] Listar todos os packages
- [ ] Decidir estratégia (procedures separadas ou wrapper)
- [ ] Converter package body
- [ ] Converter package spec
- [ ] Testar funcionalidade equivalente

### Triggers
- [ ] Listar todos os triggers
- [ ] Converter sintaxe Oracle → HANA
- [ ] Adaptar para limitações do HANA
- [ ] Testar triggers (se possível)
- [ ] Considerar alternativas (procedures, aplicação)

### Sequences
- [ ] Listar todas as sequences
- [ ] Criar sequences no HANA
- [ ] Ajustar valores iniciais
- [ ] Validar funcionamento

## ✅ Validação Completa

### Contagem de Dados
- [ ] Comparar contagem de registros por tabela
- [ ] Todas as tabelas com contagem idêntica?
- [ ] Documentar divergências (se houver)

### Integridade
- [ ] Verificar Primary Keys (sem duplicatas)
- [ ] Verificar Foreign Keys (sem órfãos)
- [ ] Verificar constraints NOT NULL
- [ ] Verificar constraints CHECK
- [ ] Verificar constraints UNIQUE

### Validação de Dados
- [ ] Comparar sumários estatísticos (SUM, AVG, MIN, MAX)
- [ ] Amostragem aleatória de registros
- [ ] Validar conversões de tipos (datas, números)
- [ ] Verificar encoding de caracteres

### Validação de Objetos
- [ ] Todas as views criadas e funcionando?
- [ ] Todas as procedures criadas e funcionando?
- [ ] Todas as functions criadas e funcionando?
- [ ] Triggers funcionando (se aplicável)?
- [ ] Sequences funcionando?

### Performance
- [ ] Executar queries principais
- [ ] Comparar tempos de execução (se possível)
- [ ] Verificar uso de índices
- [ ] Otimizar queries lentas (se necessário)

### Testes de Aplicação
- [ ] Testar conexão da aplicação
- [ ] Testar queries principais da aplicação
- [ ] Testar procedures/functions usadas pela aplicação
- [ ] Validar regras de negócio
- [ ] Teste de carga (se aplicável)

## 📚 Documentação

### Técnica
- [ ] Documentar todas as conversões realizadas
- [ ] Documentar limitações encontradas
- [ ] Documentar objetos não migrados (se houver)
- [ ] Criar diagrama de dependências
- [ ] Atualizar documentação do sistema

### Operacional
- [ ] Documentar procedimentos de backup/restore
- [ ] Documentar procedimentos de manutenção
- [ ] Criar guia de troubleshooting
- [ ] Documentar mudanças para usuários finais
- [ ] Criar plano de treinamento (se necessário)

## 🚀 Pós-Migração

### Go-Live
- [ ] Planejar janela de migração em produção
- [ ] Comunicar stakeholders
- [ ] Executar backup completo do Oracle
- [ ] Executar migração em produção
- [ ] Validar migração em produção
- [ ] Monitorar sistema pós-migração
- [ ] Ter plano de rollback pronto (se necessário)

### Monitoramento
- [ ] Monitorar performance por 1-2 semanas
- [ ] Coletar feedback dos usuários
- [ ] Ajustar configurações se necessário
- [ ] Otimizar queries/objetos se necessário

### Limpeza
- [ ] Documentar aprendizado
- [ ] Arquivar scripts de migração
- [ ] Fechar tickets/documentação
- [ ] Celebrar sucesso! 🎉

## 🔍 Problemas Comuns a Verificar

- [ ] Tipos de dados não convertidos corretamente
- [ ] Procedures com erros de sintaxe SQLScript
- [ ] Views retornando resultados diferentes
- [ ] Sequences com valores incorretos
- [ ] Problemas de encoding (caracteres especiais)
- [ ] Performance degradada em queries específicas
- [ ] Constraints não criadas corretamente
- [ ] Dados truncados em migração
- [ ] Erros de precisão em cálculos numéricos

## 📞 Contatos e Recursos

- **Equipe de Banco de Dados Oracle:** _______________
- **Equipe de SAP HANA:** _______________
- **Equipe de Aplicação:** _______________
- **Documentação Oracle:** Oracle Database Documentation
- **Documentação SAP HANA:** SAP Help Portal
- **SAP Notes relevantes:** _______________

---

**Data de Início:** _______________  
**Data Prevista de Conclusão:** _______________  
**Responsável:** _______________  
**Status Atual:** _______________
