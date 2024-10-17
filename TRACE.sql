

-- Tabela: TRACE
-- Descrição: Armazena todo o conteúdo do arquivo do Trace após ele ser processsado pelo TKPROF


--
-- Sequence para a definição do ID
CREATE SEQUENCE SEQ_TRACE START WITH 1 INCREMENT BY 1 CACHE 50 NOCYCLE;



CREATE TABLE TRACE
(
  ID NUMBER DEFAULT SEQ_TRACE.NEXTVAL NOT NULL
, FK_ID_TRACE_METADADOS NUMBER NOT NULL 
, NOME VARCHAR2(100) NOT NULL
, CONTEUDO VARCHAR2(4000)
, CONSTRAINT PK_TRACE PRIMARY KEY ( ID ) USING INDEX ( 
                                                        CREATE UNIQUE INDEX TRACE_PK ON TRACE ( ID ASC ) 
                                                     ) ENABLE 
);

ALTER TABLE TRACE ADD CONSTRAINT FK_TRACE_METADADOS_ID FOREIGN KEY ( FK_ID_TRACE_METADADOS ) REFERENCES TRACE_METADADOS ( ID ) ENABLE;


COMMENT ON TABLE TRACE IS '--

-- Armazena todo o conteúdo do arquivo do Trace após ele ser processsado pelo TKPROF
--
-- Autor: Wesley David Santos
-- Skype: wesleydavidsantos		
-- https://www.linkedin.com/in/wesleydavidsantos
--';


COMMENT ON COLUMN TRACE.ID IS 'Identificador auto-incremento do TRACE';

COMMENT ON COLUMN TRACE.FK_ID_TRACE_METADADOS IS 'Foreign Key da tabela TRACE_METADADOS';

COMMENT ON COLUMN TRACE.NOME IS 'Nome do arquivo sobre qual o TRACE foi criado';

COMMENT ON COLUMN TRACE.CONTEUDO IS 'Conteúdo gerado pelo Trace após passar pelo TKPROF';