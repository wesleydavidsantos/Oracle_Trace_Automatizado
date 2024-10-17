#!/bin/bash

#/--
#-- Esse script cria é responsável por processar um TRACE utilizando o TKPROF
#--
#-- Autor: Wesley David Santos
#-- Skype: wesleydavidsantos
#-- https://www.linkedin.com/in/wesleydavidsantos
#--
#--/


#--
#-- Como instalar esse Script.
#--
#-- Dentro do primeiro diretório definido para coleta de TRACE ( no manual na parte CONFIGURANDO O SCRIPT QUE COLETA O TRACE) crie o arquivo abaixo.
#-- Crie um arquivo com o nome: wds_identificar_novo_trace.sh
#-- Transforme o arquivo em executável com o comando: chmod +x wds_identificar_novo_trace.sh
#--
#-- Crie um arquivo em branco com o nome: trace_gerado.wds
#-- Use o comando: touch trace_gerado.wds
#--
#-- Crie um diretório no local atual do script ( no manual na parte CONFIGURANDO O SCRIPT QUE COLETA O TRACE é referente ao segundo diretório )
#-- Nome do diretório: trace
#-- Use o comando: mkdir trace
#--
#--
#-- Editar as variáveis definidas abaixo
#--




#--
#-- Editar as Variáveis abaixo
#--

#-- Informa se é para manter o arquivo de LOG gerado pelo banco de dados. Opções: Y / N
MANTER_ARQUIVO_LOG='N'

#-- Informa se é para manter localmente o arquivo de Trace que já foi processado. Opções: Y / N
MANTER_LOCALMENTE_TRACE_PROCESSADO='N'


#-- Informe o local de instalação do seu banco de dados ORACLE
#-- Não coloque a barra "/" no final do diretório
ORACLE_HOME="CAMINHO_COMPLETO_DA_INSTALACAO_ORACLE/dbhome"


#-- Informe o local onde o Oracle armazena os arquivos de Trace
#-- Não coloque a barra "/" no final do diretório
diretorio_trace="CAMINHO_COMPLETO_DIAG_ORACLE/trace"


#-- Informe o local onde foi criado o primeiro diretório referente ao manual na parte CONFIGURANDO O SCRIPT QUE COLETA O TRACE
#-- Não coloque a barra "/" no final do diretório
diretorio_atual="/dados/u01/aplic/wds_tdd_script"



#--
#-- Editar esse diretório. Informe o diretório correspondente
#-- Diretório que armanzena os Binários do servidor
#--
BIN='/usr/bin/'




#--
#--
#--
#-- ATENÇÃO
#--
#-- NÃO EDITAR NENHUM VALOR OU SCRIPT ABAIXO
#--
#--
#--






#--
#-- Não Editar
#-- Comandos a serem executados por esse script
#--
exe_ECHO=$BIN'echo'
exe_SED=$BIN'sed'
exe_FIND=$BIN'find'
exe_RM=$BIN'rm'
exe_CAT=$BIN'cat'





#--
#-- Não editar as variáveis abaixo
#--

TKPROF="$ORACLE_HOME/bin/tkprof"

diretorio_trace_processado="$diretorio_atual/trace"

destino_tkprof_trace="$diretorio_atual/wds_trace_processado_tkprof.trc"

prefixo_arquivo_log="SHELL_EXECUTAR_TKPROF_TRACE"

arquivo_original_trace="WDS_NOT_FOUND"

nome_original_trace="WDS_NOT_FOUND"

arquivo_trace_processado=''


#-- Informa se o processo de criação do Trace foi gerado com sucesso
SUCESSO_CRIAR_TRACE='N'


# Apaga o arquivo de log gerado pelo processamento da tabela externa
if [ "$MANTER_ARQUIVO_LOG" = 'N' ]; then
    
    for arquivo_log in "$diretorio_atual"/"$prefixo_arquivo_log"*".log"; do

        # Verifica se o arquivo existe
        if [ -e "$arquivo_log" ]; then

            $exe_RM "$arquivo_log"

        fi

    done

fi



# Apaga os arquivos de Trace já processados
if [ "$MANTER_LOCALMENTE_TRACE_PROCESSADO" = 'N' ]; then
    
    for arquivo_trace in "$diretorio_trace_processado"/*"WDS_T_"*".trc"; do

        # Verifica se o arquivo existe
        if [ -e "$arquivo_trace" ]; then

            $exe_RM "$arquivo_trace"

        fi

    done

fi





# Apaga os arquivos de TRACE terminados com .trm
for arquivo_trace_trm in "$diretorio_trace"/*"WDS_T_"*".trm"; do

    # Verifica se o arquivo existe
    if [ -e "$arquivo_trace_trm" ]; then
        
        $exe_RM $arquivo_trace_trm

    fi

done





# Pecorre a lista de arquivos de Trace
for arquivo_trace in "$diretorio_trace"/*"WDS_T_"*".trc"; do

    # Verifica se o arquivo existe
    if [ -e "$arquivo_trace" ]; then
        
        arquivo_original_trace="$arquivo_trace"

        break;

    fi

done



# Verifica se o arquivo de trace existe
if [ -e "$arquivo_original_trace" ]; then
    
    #--
    #-- Inicio Processamento do Trace
    #--


    #-- Coleta somente o nome original do arquivo de TRACE
    nome_original_trace="${arquivo_original_trace##*/}"


    # Arquivo final com o Trace processado
    arquivo_trace_processado="$diretorio_trace_processado/$nome_original_trace"


    # Verifica se o arquivo de trace existe
    if [ -e "$arquivo_original_trace" ]; then

        # Executa o processamento do TKPROF
        "$TKPROF" "$arquivo_original_trace" "$destino_tkprof_trace" > /dev/null 2>&1


        # Realiza um REPLACE nas linhas em branco
        $exe_SED 's/^$/[LINHA_EM_BRANCO]/' "$destino_tkprof_trace" > "$arquivo_trace_processado"


        #-- Informa que foi gerado com sucesso
        SUCESSO_CRIAR_TRACE='Y'


        # Verifica se o arquivo existe
        if [ -e "$arquivo_original_trace" ]; then
            
            # Apaga o arquivo original do Trace
            $exe_RM "$arquivo_original_trace"
        fi


        # Verifica se o arquivo existe
        if [ -e "$destino_tkprof_trace" ]; then
        
            # Apaga o arquivo processado pelo TKPROF
            $exe_RM "$destino_tkprof_trace"

        fi


    fi

fi


#-- Retorno sobre a criação do Trace
if [ "$SUCESSO_CRIAR_TRACE" = 'Y' ]; then

  $exe_ECHO 'SUCESSO'

  $exe_ECHO $nome_original_trace

else

    $exe_ECHO 'ERRO'

fi