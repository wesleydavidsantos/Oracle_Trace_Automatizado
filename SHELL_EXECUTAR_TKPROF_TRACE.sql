


-- Tabela: SHELL_EXECUTAR_TKPROF_TRACE
-- Descrição: Tabela de acesso externo que realiza a chamada de um script em Shell que processa a execução de um TKPROF sobre um Trace
--
-- Para utilizar essa chamada é necessário realizar a instalação e configuração do script em Shell dentro do Servidor
-- As informações sobre instalação e configuração está junto ao arquivo do script
--


CREATE TABLE SHELL_EXECUTAR_TKPROF_TRACE 
(	
    OUTPUT VARCHAR2(4000 BYTE)
) 
ORGANIZATION EXTERNAL 
( TYPE ORACLE_LOADER
    DEFAULT DIRECTORY "WDS_TRACE_SCRIPT"
    ACCESS PARAMETERS
    (   
        records delimited by newline
        preprocessor WDS_TRACE_SCRIPT:'wds_identificar_novo_trace.sh'
    )
    LOCATION
    ( 
        "WDS_TRACE_SCRIPT":'trace_gerado.wds'
    )
)
REJECT LIMIT UNLIMITED ;

