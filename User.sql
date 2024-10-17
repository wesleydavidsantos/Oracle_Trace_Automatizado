
--
-- Criação de usuário e grants

CREATE USER WDS_TRACE IDENTIFIED BY WDS_TRACE;

GRANT CREATE SESSION TO WDS_TRACE;
GRANT UNLIMITED TABLESPACE TO WDS_TRACE;
GRANT CREATE ANY DIRECTORY TO WDS_TRACE;
GRANT CREATE SEQUENCE TO WDS_TRACE;
GRANT CREATE TABLE TO WDS_TRACE;
GRANT CREATE PROCEDURE TO WDS_TRACE;
GRANT CREATE PUBLIC SYNONYM TO WDS_TRACE;
GRANT EXECUTE ON SYS.UTL_FILE TO WDS_TRACE;



-- Com usuário o SYS
GRANT SELECT ON SYS.GV_$SESSION TO WDS_TRACE; 
GRANT ALTER SESSION TO WDS_TRACE;


-- Com usuário o SYS
GRANT ALTER SESSION TO {USERNAME_DO_USUARIO_QUE_ESTA_USANDO_O_SISTEMA_DE_TRACE};


-- Após realizar a criação dos diretórios logado com o usuário WDS_TRACE
GRANT READ, WRITE ON DIRECTORY WDS_TRACE_SCRIPT TO WDS_TRACE;
GRANT READ, WRITE ON DIRECTORY WDS_TRACE_TKPROF TO WDS_TRACE;




--
--
-- Criar os diretórios usando o usuário WDS_TRACE


-- Specify the full path of the first directory defined in the "Installation - Configuring the TRACE Collection Script" section
-- Do not include a trailing "/" at the end of the directory
CREATE DIRECTORY WDS_TRACE_SCRIPT AS '/u01/aplic/wds_tdd_script';

-- Specify the full path of the second directory defined in the "Installation - Configuring the TRACE Collection Script" section
-- Do not include a trailing "/" at the end of the directory
CREATE DIRECTORY WDS_TRACE_TKPROF AS '/u01/aplic/wds_tdd_script/trace';




