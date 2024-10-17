
-------------------------------------------------------------------------------------------------
------------------------------------- INTRODUÇÃO ------------------------------------------------
-------------------------------------------------------------------------------------------------
--
-- Todas as ações realizadas no ambiente são registradas em uma tabela de LOG
-- Essa tabela de Log identifica a camada da ação, a origem da ação, o tipo de Log e a mensagem do LOG
--
-- As camadas são usadas para agrupar um conjunto de Logs referentes a determinadas partes do sistema
--
-- Os tipos de Log são -> INFO
--					   -> SUCESSO
--					   -> ALERTA
--					   -> ERRO
--


--
--
-------------------------------------------------------------------------------------------------
------------------------------------- INICIO CRIAÇÃO DOS OBJETOS --------------------------------
-------------------------------------------------------------------------------------------------


--
--
--
-- Sequence usada pela tabela LOG_INFO
CREATE SEQUENCE SEQ_LOG_INFO INCREMENT BY 1 START WITH 1 CACHE 20;


--
--
--
-- Armazena os logs gerados pelo sistema
CREATE TABLE LOG_INFO
(
  ID NUMBER(11) DEFAULT SEQ_LOG_INFO.NEXTVAL NOT NULL
, CODIGO_PROCESSO NUMBER(16) NOT NULL
, DATA_REGISTRO DATE DEFAULT SYSDATE NOT NULL
, CAMADA VARCHAR2(50) NOT NULL
, TIPO VARCHAR2(50) NOT NULL
, MSG_LOG VARCHAR2(4000)
, CONSTRAINT cons_LOG_SISTEMA_ENUM CHECK (TIPO IN ('INFO', 'SUCESSO', 'ALERTA', 'ERRO'))
, CONSTRAINT cons_LOG_SISTEMA_PK PRIMARY KEY 
  (
    ID 
  )
  ENABLE 
);



COMMENT ON TABLE LOG_INFO IS '--

-- Armazena os logs gerados pelo gerenciador.
--
-- Autor: Wesley David Santos
-- Skype: wesleydavidsantos		
-- https://www.linkedin.com/in/wesleydavidsantos
--';


COMMENT ON COLUMN LOG_INFO.ID IS 'Identificador único do log';

COMMENT ON COLUMN LOG_INFO.CODIGO_PROCESSO IS 'Código único usado para identificar um combo de ações de um processo';

COMMENT ON COLUMN LOG_INFO.DATA_REGISTRO IS 'Data e hora em que o log foi registrado';

COMMENT ON COLUMN LOG_INFO.CAMADA IS 'Camada do processo que registrou o log. SISTEMA ou CARGA';

COMMENT ON COLUMN LOG_INFO.TIPO IS 'Tipo de log gerado';

COMMENT ON COLUMN LOG_INFO.MSG_LOG IS 'Informações descritivas do log';




