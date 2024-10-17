--
-- Responsável por armazenar as informações dos Logs gerados
CREATE OR REPLACE PACKAGE LOG_GERENCIADOR AS
--
-- Responsável por armazenar as informações dos Logs gerados
--
-- Autor: Wesley David Santos
-- Skype: wesleydavidsantos		
-- https://www.linkedin.com/in/wesleydavidsantos
--
	
	--
	-- Realiza a execução do DBMS_OUTPUT com a mensagem de LOG
	SHOW_ERRO_DBMS_OUTPUT BOOLEAN := FALSE;
	
	--
	-- Retorna a mensagem do Log
	FUNCTION GET_MSG RETURN VARCHAR2;
	
	
	PROCEDURE ADD_INFO( p_CAMADA_LOG VARCHAR2, p_MSG_LOG VARCHAR2 );
	
	
	PROCEDURE ADD_SUCESSO( p_CAMADA_LOG VARCHAR2, p_MSG_LOG VARCHAR2 );
	
	
	PROCEDURE ADD_ALERTA( p_CAMADA_LOG VARCHAR2, p_MSG_LOG VARCHAR2 );
	
	
	PROCEDURE ADD_ERRO( p_CAMADA_LOG VARCHAR2, p_MSG_LOG VARCHAR2 );
	

END LOG_GERENCIADOR;
/




CREATE OR REPLACE PACKAGE BODY LOG_GERENCIADOR AS
--
-- Autor: Wesley David Santos
-- Skype: wesleydavidsantos		
-- https://www.linkedin.com/in/wesleydavidsantos
--
	
	-- Mensagem de erro que será registrada
	MSG_LOG VARCHAR2(4000) DEFAULT NULL;

	
	-- Armazena a continuação de mensagens de erro acima de 3500 caracteres
	MSG_LOG_ERRO_CONTINUACAO VARCHAR2(30000) DEFAULT NULL;
	
	
	-- Registra a referência a parte da mensagem de continuação
	PARTE_CONTINUACAO_MSG_LOG_ERRO NUMBER DEFAULT 0;
	
	
	-- Código único para registrar uma sequência de processos executados
	CODIGO_LOG NUMBER DEFAULT NULL;

	
	-- Tipo de ação que vai ser registrada - 'INFO', 'SUCESSO', 'ALERTA', 'ERRO'
	TIPO VARCHAR2(20) DEFAULT NULL;
	
	
	-- Camada da geração do LOG
	CAMADA VARCHAR2(50) DEFAULT NULL;
	
	
	-- Código único para registrar uma sequência de processos executados
	CODIGO_PROCESSO NUMBER DEFAULT NULL;
	

	--
	-- Cria um objeto para armazenar os tipos de CAMADA de LOG permitidos
	TYPE LISTA_CAMADA_TIPOS IS TABLE OF VARCHAR2(50);
	
	
	--
	-- Tipos de CAMADAS existentes
	CAMADA_TIPOS_VALIDOS CONSTANT LISTA_CAMADA_TIPOS := LISTA_CAMADA_TIPOS( 
																			 'SISTEMA'
																			,'TESTE'
																			,'LOG_GERENCIADOR_FALHA_INTERNA'																			
																		  );
																		  
																		  
	
	
    FUNCTION GET_CODIGO_PROCESSO RETURN VARCHAR2 IS
	BEGIN
		RETURN CODIGO_PROCESSO;
	END;
	
	
	FUNCTION GET_TIPO RETURN VARCHAR2 IS
	BEGIN
		RETURN TIPO;
	END;


    FUNCTION GET_MSG RETURN VARCHAR2 IS
	BEGIN
		RETURN  GET_TIPO || ' - ' || GET_CODIGO_PROCESSO || ' - ' || MSG_LOG;
	END;


	PROCEDURE SET_MSG_LOG( p_MSG_LOG VARCHAR2 ) IS
		
		v_MSG VARCHAR2(30000);
	
	BEGIN
	
		-- Necessário porque o conteúdo da variável p_MSG_LOG milagrosamente desaparece dentro do ELSE
		v_MSG := p_MSG_LOG;
		
	
		MSG_LOG_ERRO_CONTINUACAO := NULL;
		
	
		IF LENGTH( p_MSG_LOG ) > 3500 THEN
			
			
			MSG_LOG := SUBSTR( p_MSG_LOG, 1, 3500);
								
			MSG_LOG_ERRO_CONTINUACAO := SUBSTR( p_MSG_LOG, 3501, LENGTH( p_MSG_LOG ) );
			
		ELSE
			
			MSG_LOG := v_MSG;
			
		END IF;
	
	END;
	
	
	
	PROCEDURE SET_CAMADA( p_CAMADA VARCHAR2 ) IS
		
		RAISE_ERRO_CAMADA_NAO_EXISTE EXCEPTION;
		
	BEGIN
	
		BEGIN
		
			CAMADA := NULL;
			
			
			FOR C IN CAMADA_TIPOS_VALIDOS.FIRST..CAMADA_TIPOS_VALIDOS.LAST LOOP
			

				IF CAMADA_TIPOS_VALIDOS( C ) = p_CAMADA THEN
			
					CAMADA := p_CAMADA;
					
					EXIT;
				
				END IF;

			END LOOP;
			
			
			
			IF CAMADA IS NULL THEN
				
				RAISE RAISE_ERRO_CAMADA_NAO_EXISTE;
				
			END IF;
		
		
		EXCEPTION
			
			WHEN RAISE_ERRO_CAMADA_NAO_EXISTE THEN

				LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Tipo de camada de LOG informado não existe. Tipo camada: ' || p_CAMADA );
				
				RAISE_APPLICATION_ERROR( -20555, 'Tipo de camada de LOG informado não existe. Tipo camada: ' || p_CAMADA );
				
			
			WHEN OTHERS THEN
			
				LOG_GERENCIADOR.ADD_ERRO( 'SISTEMA', 'Erro ao validar o tipo de camada de LOG informado. Tipo camada: ' || p_CAMADA );
				
				RAISE_APPLICATION_ERROR( -20555, 'Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
				
		END;
		
	
	END;


	
	PROCEDURE ENVIAR_CONTINUCAO_MSG_LOG IS
		
		v_MSG VARCHAR2(30000);
	
	BEGIN
		
		IF MSG_LOG_ERRO_CONTINUACAO IS NOT NULL THEN
		
			PARTE_CONTINUACAO_MSG_LOG_ERRO := PARTE_CONTINUACAO_MSG_LOG_ERRO + 1;
		
			v_MSG := 'Continuação erro parte ' || PARTE_CONTINUACAO_MSG_LOG_ERRO || ', codigo: ' || GET_CODIGO_PROCESSO || ' > ' || MSG_LOG_ERRO_CONTINUACAO;
							
		
			CASE 
			
				WHEN TIPO = 'ALERTA' THEN
					LOG_GERENCIADOR.ADD_ALERTA( CAMADA, v_MSG );
				
				WHEN TIPO = 'SUCESSO' THEN
					LOG_GERENCIADOR.ADD_SUCESSO( CAMADA, v_MSG );
					
				WHEN TIPO = 'ERRO' THEN
					LOG_GERENCIADOR.ADD_ERRO( CAMADA, v_MSG );
				
				ELSE
					LOG_GERENCIADOR.ADD_INFO( CAMADA, v_MSG );
					
			END CASE;		
			
		END IF;
		
		
		PARTE_CONTINUACAO_MSG_LOG_ERRO := 0;
	
	END;


	FUNCTION GET_CODIGO_UNICO_DO_PROCESSO_REALIZADO RETURN NUMBER AS
	BEGIN
	
		
		IF CODIGO_PROCESSO IS NULL THEN
	
			SELECT 
				( EXTRACT(DAY FROM(SYS_EXTRACT_UTC(SYSTIMESTAMP) - TO_TIMESTAMP('1970-01-01', 'YYYY-MM-DD'))) * 86400000 + TO_NUMBER(TO_CHAR(SYS_EXTRACT_UTC(SYSTIMESTAMP), 'SSSSSFF3')) )
					INTO CODIGO_PROCESSO
			FROM 
				DUAL;
			
		END IF;
		
		
		RETURN CODIGO_PROCESSO;
		
	END;




	-- Procedure com transação autônoma
	-- Registra o LOG no banco de dados
	-- @TIPO - Variável que armazena o TIPO de log que será registrado
	PROCEDURE REGISTRA_LOG( p_CAMADA VARCHAR2, p_CODIGO_PROCESSO NUMBER, p_TIPO VARCHAR2, p_MSG_LOG VARCHAR2 )  AS
	
		PRAGMA AUTONOMOUS_TRANSACTION;
		
	BEGIN
	
		-- Inicia o cadastro do Log no banco de dados
		BEGIN
		
			INSERT INTO LOG_INFO ( CAMADA, CODIGO_PROCESSO, TIPO, MSG_LOG ) VALUES ( p_CAMADA, p_CODIGO_PROCESSO, p_TIPO, p_MSG_LOG );
			
			COMMIT;
			
			DBMS_OUTPUT.PUT_LINE( 'Origem: ' || p_CAMADA || ' - Mensagem: ' || p_MSG_LOG );
			
		EXCEPTION
		
			WHEN OTHERS THEN
			
				-- Impede loop eterno
				IF CAMADA != 'LOG_GERENCIADOR_FALHA_INTERNA' THEN
			
					LOG_GERENCIADOR.ADD_ERRO( 'LOG_GERENCIADOR_FALHA_INTERNA', 'Falha de execução no próprio sistema de registro de LOG. Log com erro, ' || 'Código: ' || CODIGO_PROCESSO || ' - Camada: ' || CAMADA || ' - Tipo: ' || TIPO || ' - Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
					
				END IF;
			
				-- O próprio sistema de Log pode gerar um erro
				RAISE_APPLICATION_ERROR(-20001, 'Erro, não foi possível registrar o Log de Erro. Erro: ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
			
		END;
			
	
	END;
	


	-- Procedure de uso comum para registrar os logs gerados
	-- @CAMADA - Variável que armazena a CAMADA que será registrada no log
	PROCEDURE ADD_LOG AS
		
		RAISE_ERRO_SISTEMA_DESATIVADO EXCEPTION;
		
		RAISE_ERRO_MSG_IS_NULL EXCEPTION;
			
	BEGIN
	
	
		BEGIN		
					
	
			-- Registra o erro no banco de dados
			REGISTRA_LOG( CAMADA, GET_CODIGO_UNICO_DO_PROCESSO_REALIZADO, TIPO, MSG_LOG );
			
			
			ENVIAR_CONTINUCAO_MSG_LOG;
			
			
			IF SHOW_ERRO_DBMS_OUTPUT THEN
				
				-- Retorna via DBMS_OUTPUT as mensagens para o usuário
				dbms_output.put_line( '' );
				dbms_output.put_line( '-------- ///////////////////////////////' );
				dbms_output.put_line( 'Mensagem Informativa' );
				dbms_output.put_line( '' );
				dbms_output.put_line( 'COD: ' || GET_CODIGO_PROCESSO );
				dbms_output.put_line( 'Camada: ' || CAMADA );
				dbms_output.put_line( 'Tipo: ' || TIPO );
				dbms_output.put_line( 'Mensagem: ' || MSG_LOG );
				dbms_output.put_line( '' );
				dbms_output.put_line( '-------- ///////////////////////////////' );
				dbms_output.put_line( '' );
				
			END IF;
							
			
		EXCEPTION
		
			WHEN RAISE_ERRO_SISTEMA_DESATIVADO THEN
			
				NULL;
				
				
			WHEN RAISE_ERRO_MSG_IS_NULL THEN
			
				RAISE_APPLICATION_ERROR( -20555, 'Informe a mensagem de erro para ser registrado no LOG_GERENCIADOR' );
		
		
		END;
		
		
	END;


    PROCEDURE ADD_INFO( p_CAMADA_LOG VARCHAR2, p_MSG_LOG VARCHAR2 ) IS
	BEGIN
		
		TIPO := 'INFO';
		
		SET_CAMADA( p_CAMADA_LOG );
		
		SET_MSG_LOG( p_MSG_LOG );
		
		ADD_LOG;
		
	END;
		
	
    PROCEDURE ADD_SUCESSO( p_CAMADA_LOG VARCHAR2, p_MSG_LOG VARCHAR2 ) IS
	BEGIN
		
		TIPO := 'SUCESSO';
		
		SET_CAMADA( p_CAMADA_LOG );
		
		SET_MSG_LOG( p_MSG_LOG );
		
		ADD_LOG;
		
	END;	
	
	
    PROCEDURE ADD_ALERTA( p_CAMADA_LOG VARCHAR2, p_MSG_LOG VARCHAR2 ) IS
	BEGIN
		
		TIPO := 'ALERTA';
		
		SET_CAMADA( p_CAMADA_LOG );
		
		SET_MSG_LOG( p_MSG_LOG );
		
		ADD_LOG;
		
	END;	
	

	-- Public
    PROCEDURE ADD_ERRO( p_CAMADA_LOG VARCHAR2, p_MSG_LOG VARCHAR2 ) IS
	BEGIN
		
		TIPO := 'ERRO';
		
		SET_CAMADA( p_CAMADA_LOG );
		
		SET_MSG_LOG( p_MSG_LOG );
		
		ADD_LOG;
		
	END;		
	
	
END LOG_GERENCIADOR;
/