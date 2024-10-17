# Oracle_Trace_Automatizado
Sistema automatizado que permite ao próprio usuário de forma simples realizar a ativação e leitura de traces do Oracle


Este sistema faz parte de uma solução de TDD em Oracle que desenvolvi e publiquei no GitHub (wdsPLSQLtdd). [https://github.com/wdsPLSQLtdd/ProTddOracle]

O módulo de coleta de trace oferece aos desenvolvedores autonomia para gerar e ler quantos traces forem necessários, de forma rápida e simples.

Abaixo, destaco os principais benefícios do uso de trace no Oracle para diagnóstico e otimização de desempenho de aplicações:

1. Diagnóstico Detalhado: O trace captura execuções de SQL, tempos de CPU, leituras físicas e lógicas, ajudando a identificar consultas ineficientes.
2. Identificação de Gargalos: Detecta problemas como I/O elevado, contenções de locks e parsing excessivo, permitindo ajustes precisos.
3. Resolução de Problemas Complexos: Facilita a análise de deadlocks e falhas, auxiliando na correção rápida de incidentes.
4. Otimização de Consultas e PL/SQL: Fornece informações valiosas para ajustes de consultas SQL e melhorias na eficiência de rotinas PL/SQL.
5. Ajuste de Parâmetros: Auxilia na identificação de ajustes de parâmetros de sistema para otimizar a performance.
6. Auditoria e Monitoramento: Permite monitorar o comportamento de sessões e transações críticas.
7. Colaboração Entre Equipes: Facilita a troca de informações detalhadas entre desenvolvedores e DBAs.

O uso do trace em momentos críticos ajuda na identificação de baixo desempenho das aplicações e torna a solução de problemas mais eficiente.

A execução do sistema de coleta de trace é bastante simples: são necessárias apenas três procedures na sessão onde a coleta será realizada.

Seguem abaixo a lista de comandos.

```sql
-- Permite a visualização de mensagens do DBMS_OUTPUT
SET SERVEROUTPUT ON;

-- Realiza a ativação do trace
EXECUTE ATIVAR_TRACE;


-- Realiza a desativação do trace
EXECUTE DESATIVAR_TRACE;


-- Processa e gera o trace coletado
EXECUTE PROCESSAR_TRACE;
````

Seguem os SELECT para consultar os traces gerados. 

```sql
-- Apresenta a lista de traces gerados
SELECT * FROM WDS_TRACE.TRACE_METADADOS ORDER BY ID DESC;


-- Apresenta as informações do trace
SELECT CONTEUDO FROM WDS_TRACE.TRACE WHERE FK_ID_TRACE_METADADOS = :ID_COLETA_TRACE_METADADOS ORDER BY ID ASC;
```

Para facilitar na leitura dos trace, criei um Report no SqlDeveloper que lista todos os traces gerados e ao selecionar um trace é apresentado toda a informação do trace.

Import para o seu SqlDeveloper conforme exemplo na imagem abaixo.

![SqlDeveloper_Report_Trace](https://github.com/user-attachments/assets/26b7d902-efd0-469e-99c0-41852d9bee26)




