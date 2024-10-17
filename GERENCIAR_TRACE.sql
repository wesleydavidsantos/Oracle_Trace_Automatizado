--
-- Responsável por registrar as execuções dos testes
CREATE OR REPLACE PACKAGE GERENCIAR_TRACE AS
--
-- Responsável por registrar as execuções dos testes
--
-- Autor: Wesley David Santos
-- Skype: wesleydavidsantos		
-- https://www.linkedin.com/in/wesleydavidsantos
--

	FUNCTION GET_NOME_TRACE RETURN VARCHAR2;

	
	PROCEDURE ATIVAR;


	PROCEDURE DESATIVAR;
		
	
END GERENCIAR_TRACE;
/




CREATE OR REPLACE PACKAGE BODY GERENCIAR_TRACE AS
--
-- Autor: Wesley David Santos
-- Skype: wesleydavidsantos		
-- https://www.linkedin.com/in/wesleydavidsantos
--

	RAISE_ERRO_ENCONTRADO EXCEPTION;

	g_NOME_TRACE VARCHAR2(300);


	v_FLAG_TRACE_INICIADO BOOLEAN DEFAULT FALSE;


	TYPE SESSAO_INFO IS RECORD (
		 INST_ID NUMBER
		,SID NUMBER
		,SERIAL NUMBER
		,USERNAME VARCHAR2(100)
		,HOST_USER VARCHAR2(100)		
	);


	USER_INFO SESSAO_INFO;



	FUNCTION GET_NOME_TRACE RETURN VARCHAR2 IS
	BEGIN

		RETURN g_NOME_TRACE;

	END;


	FUNCTION GERAR_NOME_TRACE( p_PREFIXO_NOME_TRACE IN VARCHAR2 ) RETURN VARCHAR2 IS
	--
	-- Função que gera um novo nome para o arquivo de Trace
	--
	-- Autor: Wesley David Santos
	-- Skype: wesleydavidsantos		
	-- https://www.linkedin.com/in/wesleydavidsantos
	--

		v_NOME_TRACE VARCHAR2(100);

		v_DATA_FORMATADA VARCHAR2(100);
		
		--
		-- Informa o nome do par¿¿metro usado como prefixo para criar os nomes dos arquivos de trace
		PREFIXO_NOME_TRACEFILE_IDENTIFIER CONSTANT VARCHAR2(500) := 'WDS_T_{TESTE_ID}_{DATA_TESTE}';

		
	BEGIN

		SELECT TO_CHAR(SYSDATE, 'HH24"h"MI"m"SS"s"') INTO v_DATA_FORMATADA FROM DUAL;

		v_NOME_TRACE := REPLACE( PREFIXO_NOME_TRACEFILE_IDENTIFIER, '{TESTE_ID}', p_PREFIXO_NOME_TRACE );

		v_NOME_TRACE := REPLACE( v_NOME_TRACE, '{DATA_TESTE}', v_DATA_FORMATADA );

		RETURN v_NOME_TRACE;

	END;



	PROCEDURE SET_NOME_TRACE( p_NOME_TRACE IN VARCHAR2 ) AS
	BEGIN

		BEGIN
		
			-- Evita gerar o nome duas vezes para a mesma coleta
			IF g_NOME_TRACE IS NULL THEN
			
				g_NOME_TRACE := GERAR_NOME_TRACE( p_NOME_TRACE );
				
			END IF;

		EXCEPTION

			WHEN OTHERS THEN

				LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao setar o nome do Trace. Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

				RAISE RAISE_ERRO_ENCONTRADO;

		END;

	END;



	FUNCTION COLETA_INFO_USER RETURN BOOLEAN IS
	BEGIN

		BEGIN
							
			SELECT 
					 SYS_CONTEXT('USERENV', 'INSTANCE') AS INSTANCE  -- Identifica a instância no RAC
					,SYS_CONTEXT('USERENV', 'SID') AS SID
					,S.SERIAL# SERIAL
					,SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS USERNAME
					,SYS_CONTEXT('USERENV', 'HOST') AS HOST           -- Mostra o nó (host) do usuário					
				INTO
					 USER_INFO.INST_ID
					,USER_INFO.SID
					,USER_INFO.SERIAL
					,USER_INFO.USERNAME
					,USER_INFO.HOST_USER					
			FROM 
				SYS.GV_$SESSION S 
			WHERE 
				S.SID = SYS_CONTEXT('USERENV', 'SID')
				AND S.INST_ID = SYS_CONTEXT('USERENV', 'INSTANCE');
				
								

			RETURN TRUE;


		EXCEPTION

			WHEN OTHERS THEN
			
				LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao indentificar a sessão do usuário. Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
			
				RETURN FALSE;

		END;

	END;



	FUNCTION INICIAR_COLETA RETURN BOOLEAN IS

		RAISE_ERRO_TRACE_NAO_ATIVADO EXCEPTION;

		v_TRACE_EVENTS CONSTANT VARCHAR2(200) := 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT FOREVER, LEVEL 4''';

		v_TRACEFILE_IDENTIFIER CONSTANT VARCHAR2(200) := 'ALTER SESSION SET TRACEFILE_IDENTIFIER = {NOME_TRACEFILE_IDENTIFIER}'; 

		v_NOME_TRACEFILE_IDENTIFIER VARCHAR2(300);

	BEGIN

		BEGIN
		
			--
			-- Ativar trace - Parte 01
			BEGIN

				EXECUTE IMMEDIATE v_TRACE_EVENTS;


			EXCEPTION

				WHEN OTHERS THEN
				
					LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao executar o ALTER SESSION SET EVENTS para gerar o Trace. Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
				
					RETURN FALSE;

			END;




			--
			-- Ativar trace - Parte 02
			BEGIN


				v_NOME_TRACEFILE_IDENTIFIER := REPLACE( v_TRACEFILE_IDENTIFIER, '{NOME_TRACEFILE_IDENTIFIER}', DBMS_ASSERT.ENQUOTE_LITERAL( GET_NOME_TRACE ) );
			

				EXECUTE IMMEDIATE v_NOME_TRACEFILE_IDENTIFIER;


				RETURN TRUE;


			EXCEPTION

				WHEN OTHERS THEN
				
					LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao setar as informações de sessão para gerar o Trace ALTER SESSION SET TRACEFILE_IDENTIFIER - Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
				
					RETURN FALSE;

			END;


		EXCEPTION

			WHEN RAISE_ERRO_TRACE_NAO_ATIVADO THEN

				LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao ativar a coleta do Trace. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );


			WHEN OTHERS THEN
			
				LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao ativar a coleta do Trace. Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
			
		END;


		RETURN FALSE; 

	END;


	PROCEDURE DESATIVAR AS

		v_NOME_TRACE VARCHAR2(100);
		
	BEGIN
		
		BEGIN

			IF NOT v_FLAG_TRACE_INICIADO THEN

				BEGIN

					RAISE RAISE_ERRO_ENCONTRADO;

				EXCEPTION

					WHEN OTHERS THEN

						LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Necessário Ativar o Trace antes de realizar essa ação. ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

						RAISE RAISE_ERRO_ENCONTRADO;

				END;

			END IF;



			BEGIN

				EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT OFF''';


				v_NOME_TRACE := GET_NOME_TRACE;


				UPDATE 
					TRACE_METADADOS
				SET
					SITUACAO = 'COLETADO'
				WHERE
					ARQUIVO = v_NOME_TRACE;


				COMMIT;
				
				
				LOG_GERENCIADOR.ADD_SUCESSO( 'SISTEMA', 'Coleta de trace finalizada com sucesso. Nome arquivo trace: ' || v_NOME_TRACE );

			EXCEPTION

				WHEN OTHERS THEN
			
					LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao atualizar na tabela Trace as informações sobre a finalização da coleta. Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

					RAISE RAISE_ERRO_ENCONTRADO;

			END;


		EXCEPTION

			WHEN OTHERS THEN
			
				LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao desativar a coleta do Trace. Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

				RAISE RAISE_ERRO_ENCONTRADO;

		END;

	END;
	

	PROCEDURE ATIVAR AS

		V_NOME_TRACE_FORMATO CONSTANT VARCHAR2(100) := '{INST_ID}_{SID}_{SERIAL}';
		
		v_TESTE_PRIMARIO_ID NUMBER;

		v_ID_EXECUCAO NUMBER;

		v_NOME_TRACE VARCHAR2(100);

	BEGIN

		BEGIN
		
		
			
			IF v_FLAG_TRACE_INICIADO THEN
			
				LOG_GERENCIADOR.ADD_SUCESSO( 'SISTEMA', 'Já existe um trace ativado, desta forma  ele será desativado e iniciado uma nova coleta.' );
			
				DESATIVAR;
				
			END IF;
		
			
			-- Reseta a variável
			g_NOME_TRACE := NULL;
		
			v_FLAG_TRACE_INICIADO := FALSE;


			-- Coleta as informações do usuário
			IF NOT COLETA_INFO_USER THEN

				RAISE RAISE_ERRO_ENCONTRADO;

			END IF;
			
	
			-- Informações para gerar o nome do trace
			v_NOME_TRACE := REPLACE( V_NOME_TRACE_FORMATO, '{INST_ID}', USER_INFO.INST_ID );
			v_NOME_TRACE := REPLACE( v_NOME_TRACE, '{SID}', USER_INFO.SID );
			v_NOME_TRACE := REPLACE( v_NOME_TRACE, '{SERIAL}', USER_INFO.SERIAL );
			
						
			-- Gera o nome do trace
			SET_NOME_TRACE( v_NOME_TRACE );
			
			
			IF NOT INICIAR_COLETA THEN

				RAISE RAISE_ERRO_ENCONTRADO;

			END IF;



			BEGIN

				-- Recebe o nome final do trace
				v_NOME_TRACE := GET_NOME_TRACE;
			

				INSERT INTO TRACE_METADADOS 
					( 
						 DATA_SITUACAO_ALTERADO
						,ARQUIVO
						,SITUACAO
						,INST_ID
						,SID
						,SERIAL
						,USERNAME
						,HOST_USER
					)
				VALUES
					( 
						 SYSDATE
						,v_NOME_TRACE
						,'COLETANDO'
						,USER_INFO.INST_ID
						,USER_INFO.SID
						,USER_INFO.SERIAL
						,USER_INFO.USERNAME
						,USER_INFO.HOST_USER
					);
				
				COMMIT;


				v_FLAG_TRACE_INICIADO := TRUE;
				
				
				LOG_GERENCIADOR.ADD_SUCESSO( 'SISTEMA', 'Coleta iniciada com sucesso. Nome arquivo trace: ' || v_NOME_TRACE );
				

			EXCEPTION

				WHEN OTHERS THEN
			
					LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Falha ao registrar na tabela Trace as informações da coleta. Nome arquivo trace: ' || v_NOME_TRACE || ' - Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );

					RAISE RAISE_ERRO_ENCONTRADO;

			END;


		EXCEPTION

			WHEN OTHERS THEN
			
				RAISE RAISE_ERRO_ENCONTRADO;

		END;

	END;


END GERENCIAR_TRACE;
/