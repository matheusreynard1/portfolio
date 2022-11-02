USE SFINANCEEM
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.P040000003'))
  DROP PROCEDURE dbo.P040000003
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

CREATE PROCEDURE dbo.P040000003
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  :: EMPRESA    : Sinqia                                                       ::
  :: SISTEMA    : SQ Crédito                                                   ::
  :: MÓDULO     : consome serviço de cartões BH para incluir contrato          ::                                                            
  :: UTILIZ. POR:                                                              ::
  :: OBSERVAÇÃO : Procedure chamada pelo WF de cliente integrado com módulo de ::
  ::              cartões BH.                                                  ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR:                                                              ::
  :: DATA       :                                              VERSÃO SP:      ::
  :: ALTERAÇÃO  :                                                              ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR: Matheus Reynard                                              ::
  :: DATA       : 30/06/2021                                   VERSÃO SP:    1 ::
  :: ALTERAÇÃO  : Primeira versão                                              ::
  ::              Jira: SD-51974                                               ::
  :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/*-------------------------------------------------------------------------------
    DESCRIÇÃO DA FUNCIONALIDADE:
    A procedure seleciona informações de contrato a partir dos parâmetros de
    entrada passados e consome o serviço de cartões BH com essas informações
    selecionadas, para atualizar o GRAVAME dos recebíveis junto à CIP, quando 
    ocorrer a seguinte situação: inclusão de contrato.
---------------------------------------------------------------------------------*/
  @ENT_NR_VRS       VARCHAR(4)            ,         /* Número da versão da SP            */
  @ENT_NR_INST      NUMERIC(9)            ,         /* Instituição                       */
  @ENT_NR_AGEN      NUMERIC(5)            ,         /* Agência                           */
  @ENT_NR_CONTRA    NUMERIC(18,0)         ,         /* Nr. de contrato                   */
  @ENT_CD_CLIENT    NUMERIC(11)           ,         /* Cód. Cliente                      */
  @ENT_CD_OPESIS    NUMERIC(9)            ,         /* Usuário que executou o processo   */
  @RET_ID_STATUS    NUMERIC(5)      OUTPUT,         /* Variável de retorno               */
  @RET_CD_ERRO      NUMERIC(9)      OUTPUT,         /* Código de erro do SQL             */
  @RET_DS_ERRO      VARCHAR(255)    OUTPUT          /* Mensagem nativa de erro           */
  WITH ENCRYPTION
AS

/*--------------------------------------------------------------------------*/
/* Verifica se a versão do Módulo é diferente da versão da Stored Procedure */
/*--------------------------------------------------------------------------*/
DECLARE @LOC_NR_RTCODE INTEGER
EXECUTE @LOC_NR_RTCODE = SP_CD0100002 @ENT_NR_VRS, '1', 'P040000003'
IF @LOC_NR_RTCODE = 99999 RETURN 99999
/*--------------------------------------------------------------------------*/

/*Tabela temporária de mensagens de retorno*/
CREATE TABLE #TBERROR_MSGS (
  TP_MSG       CHAR(1)      , /* E = Erro; I = Informação; O = Ok; A = Aviso. */
  DS_MSG       VARCHAR(MAX)
)

-------------------------------- DECLARAÇÃO DE VARIAVEIS --------------------------

DECLARE
  @XML            XML             ,
  @DS_XML         XML             , 
  @DS_XMLRES      XML             ,
  @XML_BODY       XML             ,     
  @ID_STATUS      NUMERIC(9)      ,
  @CD_ERRO        NUMERIC(9)      ,
  @DS_XML_OUT     VARCHAR(MAX)    ,
  @DS_USRWS       VARCHAR(MAX)    ,
  @DS_URLBAS      VARCHAR(MAX)    ,
  @DS_URLCT       VARCHAR(MAX)    ,
  @DS_XML_IN      VARCHAR(MAX)    ,
  @DS_MENSAG      VARCHAR(MAX)    ,
  @DS_URLAUTH     VARCHAR(MAX)    ,
  @DS_PWDWS       VARCHAR(MAX)    ,
  @DS_RESPONSE    VARCHAR(MAX)    ,
  @DS_ERRO        VARCHAR(255)    ,
  @DS_XMLSAI      VARCHAR(MAX)    ,
  @JSON_BODY      VARCHAR(MAX)    ,
  @JSON_AUTH      VARCHAR(MAX)    ,
  @AUTH_TOKEN     VARCHAR(MAX)    ,
  @DS_MSG         VARCHAR(255)    ,
  @ID_ERRO        CHAR(1)      

------------------------- TABELA QUE RECEBE OS PARAMETROS PARA EXECUTAR A PROC DE CONSUMO DE SERVIÇO P040101009 ---------------

DECLARE @TBCONSOME_SERVICO TABLE (
  urlBase         VARCHAR(MAX),
  usrPwdBase64    VARCHAR(MAX),
  urlWebService   VARCHAR(MAX),
  requestBody     XML         ,
  requerAuth      CHAR(1)     ,
  metodo          VARCHAR(MAX),
  formatoRequest  VARCHAR(255),
  formatoResponse VARCHAR(255),
  SOAPAction      VARCHAR(255),
  authExtern      VARCHAR(MAX),
  idEmpotency     VARCHAR(MAX)
)

------------------------------------- TABELA DE VALORES PARA MONTAR O JSON-----------------------

DECLARE @TBJSON TABLE (
  codLegado                   NUMERIC(9,0) ,
  cpfCnpjUsuarioFinal         VARCHAR(14)  ,
  numeroContrato              NUMERIC(18,0),
  indicadorTpNegc             CHAR(2)      ,
  dataVencOperacao            DATETIME     ,
  valor                       NUMERIC(17,2),
  valorGarantia               NUMERIC(17,2),
  regraDivisao                CHAR(1)      ,
  cpfCnpjTitular              VARCHAR(14)  ,
  valorPercentualGarantia     NUMERIC(17,2),
  agencia                     NUMERIC(9,0) ,
  conta                       NUMERIC (9,0),
  tipoCnpj                    CHAR(1)      ,
  dataFimOperacao             DATETIME     ,
  tipoDominio                 CHAR(1)
)
/*********************************************************************************/
/* Críticas das informações de entrada                                           */
/*********************************************************************************/
BEGIN TRY
  INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
  SELECT
    'E',
    'Número da versão da SP obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, @ENT_NR_VRS), 'NULL') + '].'
  WHERE
    @ENT_NR_VRS IS NULL

  INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
  SELECT
    'E',
    'Número da instituição obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, @ENT_NR_INST), 'NULL') + '].'
  WHERE
    @ENT_NR_INST IS NULL

  INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
  SELECT
    'E',
    'Número do usuário que executou a ação obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, @ENT_CD_OPESIS), 'NULL') + '].'
  WHERE
    @ENT_CD_OPESIS IS NULL

  INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
  SELECT
    'E',
    'Código do cliente obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, @ENT_CD_CLIENT), 'NULL') + '].'
  WHERE
    @ENT_CD_CLIENT IS NULL

  INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
  SELECT
    'E',
    'Número do contrato obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, @ENT_NR_CONTRA), 'NULL') + '].'
  WHERE
    @ENT_NR_CONTRA IS NULL

  INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
  SELECT
    'E',
    'Número da agência obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, @ENT_NR_AGEN), 'NULL') + '].'
  WHERE
    @ENT_NR_AGEN IS NULL

  SELECT @ID_ERRO =
    CASE
      WHEN EXISTS (SELECT TOP 1 NULL FROM #TBERROR_MSGS WHERE TP_MSG = 'E')
        THEN 'S'
      ELSE 'N'
    END
END TRY
BEGIN CATCH
  SELECT
    @RET_ID_STATUS = -20,
    @RET_CD_ERRO   = ERROR_NUMBER(),
    @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

  RETURN @RET_ID_STATUS
END CATCH
-------------------------------- CAPTURA INFORMAÇÕES GENÉRICAS QUE SERÃO CONSUMIDAS PARA AS CHAMADAS DOS WSs   -------------------
BEGIN TRY
  IF @ID_ERRO = 'N'
  BEGIN

    -- PEGA A URL, USUÁRIO, SENHA DA TABELA CD21 
    SELECT 
      @DS_USRWS       = CD21_DS_USR, -- login de acesso ao serviço
      @DS_PWDWS       = SFINANCE_CD.dbo.FC_CD0100040(CD21_DS_PWD, 'D', (ASCII('C') * 1000 + ASCII('D')) % 100000),
      @DS_URLBAS      = CD21_DS_URL -- URL de acesso ao serviço
    FROM
      SFINANCE_CD..CD21
    WHERE
        CD21_NR_INST = @ENT_NR_INST
    AND CD21_CD_SERV = 53 -- Código do serviço de Cartões BH

      -- ADICIONA NAS VARIÁVEIS AS URLS DE AUTENTICAÇÃO E DE USO DA API
    SELECT 
      @DS_URLCT   = @DS_URLBAS + '/api/OperacaoFumaca', -- URL DO SERVIÇO
      @DS_URLAUTH = @DS_URLBAS + '/api/Login' -- URL DO LOGIN DO SERVIÇO

    ------------------------ GERA OS JSONS DE AUTENTICAÇÃO E DE CONSUMO DE SERVIÇO ------------------

    SELECT @JSON_AUTH = 
    '{
      "login": "'+@DS_USRWS+'",
      "accessKey": "'+@DS_PWDWS+'"
    }'
	INSERT INTO @TBJSON (
      codLegado               ,
      cpfCnpjUsuarioFinal     ,
      numeroContrato          ,
      indicadorTpNegc         ,
      dataVencOperacao        ,
      valor                   ,
      valorGarantia           ,
      regraDivisao            ,
      cpfCnpjTitular          ,
      valorPercentualGarantia ,
      agencia 		          ,		 
      conta 			      ,
      tipoCnpj 		          ,
      dataFimOperacao 	      ,
      tipoDominio 
    )
    SELECT
      1 ,/* codLegado */
      CL01_NR_CPFCNPJ, /* cpfCnpjUsuarioFinal */
      EM01_NR_CONTRA, /* numeroContrato */
      'OG', /* indicadorTpNegc */
	  CONVERT(DATETIME, CAST(EM01_DT_VCTULT AS VARCHAR), 101) , /* dataVencOperacao */    
      EM01_VL_SDODEV, /* valor */
      EM01_VL_SDODEV, /* valorGarantia */
      'V', /* regraDivisao */
      CL01_NR_CPFCNPJ, /* cpfCnpjTitular */
      EM01_VL_SDODEV, /* valorPercentualGarantia */
      CL05_NR_AGENC, /* agencia */ 
      CL05_NR_CONTA, /* conta */
      'C', /* tipoCnpj */
      CONVERT(DATETIME, CAST(EM01_DT_VCTULT AS VARCHAR), 101) , /* dataFimOperacao */
      'A' /* tipoDominio */
    FROM 
      EM01 INNER JOIN CL01 ON (
            EM01_NR_INST   = CL01_NR_INST
        AND EM01_CD_CLIENT = CL01_NR_CLIENT 
      ) INNER JOIN CL05 ON (
            EM01_NR_INST   = CL05_NR_INST
        AND EM01_CD_CLIENT = CL05_NR_CLIENT
        AND CL05_ST_CTPDR  = 'S'
      )
    WHERE
          EM01_NR_INST   = @ENT_NR_INST
      AND EM01_NR_AGEN   = @ENT_NR_AGEN
      AND EM01_CD_CLIENT = @ENT_CD_CLIENT
      AND EM01_NR_CONTRA = @ENT_NR_CONTRA

    --- VALIDAÇÕES
    BEGIN TRY
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
        'E',
        'Valor obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, valor), 'NULL') + '].'
      FROM 
        @TBJSON
      WHERE 
        valor IS NULL OR valor = 0.00
        
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
        'E',
        'Valor de garantia obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, valorGarantia), 'NULL') + '].'
      FROM 
        @TBJSON
      WHERE 
        valorGarantia IS NULL OR valorGarantia = 0.00

      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
        'E',
        'Valor percentual da garantia obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, valorPercentualGarantia), 'NULL') + '].'
      FROM 
        @TBJSON
      WHERE 
        valorPercentualGarantia IS NULL OR valorPercentualGarantia = 0.00

      SELECT @ID_ERRO =
        CASE
          WHEN EXISTS (SELECT TOP 1 NULL FROM #TBERROR_MSGS WHERE TP_MSG = 'E')
            THEN 'S'
          ELSE 'N'
        END
    END TRY
    BEGIN CATCH
      SELECT
        @RET_ID_STATUS = -20,
        @RET_CD_ERRO   = ERROR_NUMBER(),
        @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

      RETURN @RET_ID_STATUS
    END CATCH

  END -- END IF ID ERRO
  
  IF @ID_ERRO = 'N'
  BEGIN
    SELECT @JSON_BODY = 
    '{
      "codLegado": "'+(SELECT CONVERT(VARCHAR, codLegado) FROM @TBJSON)+'",
      "cpfCnpjUsuarioFinal": "'+(SELECT CONVERT(VARCHAR, cpfCnpjUsuarioFinal) FROM @TBJSON)+'",
      "numeroContrato": "'+(SELECT CONVERT(VARCHAR, numeroContrato) FROM @TBJSON)+'",
      "indicadorTpNegc": "'+(SELECT CONVERT(VARCHAR, indicadorTpNegc) FROM @TBJSON)+'",
      "dataVencOperacao": "'+(SELECT CONVERT(VARCHAR, CONVERT(DATE, CONVERT(VARCHAR, (SELECT TOP 1 dataVencOperacao FROM @TBJSON)), 111)))+'", 
      "valor": "'+(SELECT CONVERT(VARCHAR, valor) FROM @TBJSON)+'",
      "valorGarantia": "'+(SELECT CONVERT(VARCHAR, valorGarantia) FROM @TBJSON)+'",
      "regraDivisao": "'+(SELECT CONVERT(VARCHAR, regraDivisao) FROM @TBJSON)+'",
      "garantidores": [
        {
          "cpfCnpjTitular": "'+(SELECT CONVERT(VARCHAR, cpfCnpjTitular) FROM @TBJSON)+'",
          "valorPercentualGarantia": "'+(SELECT CONVERT(VARCHAR, valorPercentualGarantia) FROM @TBJSON)+'",
          "agencia": "'+(SELECT CONVERT(VARCHAR, agencia) FROM @TBJSON)+'",
          "conta": "'+(SELECT CONVERT(VARCHAR, conta) FROM @TBJSON)+'",
          "tipoCnpj": "'+(SELECT CONVERT(VARCHAR, tipoCnpj) FROM @TBJSON)+'",
          "dataFimOperacao": "'+(SELECT CONVERT(VARCHAR, CONVERT(DATE, CONVERT(VARCHAR, (SELECT TOP 1 dataFimOperacao FROM @TBJSON)), 111)))+'",
          "tipoDominio": "'+(SELECT CONVERT(VARCHAR, tipoDominio) FROM @TBJSON)+'"
        }
      ]
    }'
    ----------------- INSERE OS DADOS NA TABELA TEMPORÁRIA E CHAMA A PROC DE CONSUMIR SERVIÇO PARA FAZER LOGIN NA API ----------------------
	
    INSERT INTO @TBCONSOME_SERVICO (
      urlBase        ,
      usrPwdBase64   ,
      urlWebService  ,
      requestBody    ,
      requerAuth     ,
      metodo         ,
      formatoRequest ,
      formatoResponse,
      SOAPAction     ,
      authExtern     ,
      idEmpotency
    )
    VALUES (
      @DS_URLAUTH         ,  --- url de autenticação /api/login
      NULL                ,
      @DS_URLAUTH         ,  --- url de autenticação /api/login
      @JSON_AUTH          , -- json que tenha os parametros de autenticação usuário e senho
      'N'                 , 
      'POST'              , 
      'application/json'  , 
      'application/json'  ,
      NULL                ,
      NULL                , 
      NULL     
    )

    SELECT @DS_XML_IN = (
      SELECT
        urlBase        ,
        usrPwdBase64   ,
        urlWebService  ,
        requestBody    ,
        requerAuth     ,
        metodo         ,
        formatoRequest ,
        formatoResponse,
        SOAPAction     ,
        authExtern     ,
        idEmpotency
      FROM
        @TBCONSOME_SERVICO
      FOR XML PATH (''), ROOT('servico')
    )

    EXEC SFINANCEEM..P040101009
      @ENT_NR_VRS    = '1'           ,
      @ENT_NR_INST   = @ENT_NR_INST  ,
      @ENT_NR_AGEN   = @ENT_NR_AGEN  ,
      @ENT_DS_XML    = @DS_XML_IN    ,
      @ENT_CD_OPESIS = @ENT_CD_OPESIS,
      @RET_DS_XML    = @DS_XML_OUT OUTPUT,
      @RET_ID_STATUS = @ID_STATUS  OUTPUT,
      @RET_CD_ERRO   = @CD_ERRO    OUTPUT,
      @RET_DS_ERRO   = @DS_ERRO    OUTPUT

    /* Convert o response de VARCHAR(MAX) para XML */
    SELECT @XML        = CONVERT(XML, @DS_XML_OUT)
    /* Converte o JSON de retorno em XML */
    SELECT @XML_BODY   = SFINANCE_CD.dbo.F010199005(@XML.value('(RESPONSE/RESPONSE_BODY)[1]', 'VARCHAR(MAX)'))
    /* Tratamento de erros */
    
    IF @XML IS NULL AND @XML_BODY IS NULL
    BEGIN
      SELECT @ID_ERRO = 'S'
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
        SELECT
        'E',
        'Não houve resposta do serviço de autenticação. Verifique a conexão ou os dados de acesso.'
    END
    ELSE IF @XML.exist('//RESPONSE/RET_ID_STATUS') = 1
    BEGIN
      SELECT @ID_ERRO = 'S'
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
        SELECT
        'E',
        'Erro na resposta do serviço de autenticação do serviço de cartões, código [' + @XML.value('(RESPONSE/RET_CD_ERRO)[1]', 'VARCHAR(MAX)') + '].'
    END
    ELSE IF @ID_STATUS <> 0
    BEGIN
      SELECT @ID_ERRO = 'S'
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
      'E',
      'Cód. erro [' + CONVERT(VARCHAR, @CD_ERRO) + '], erro [' + @DS_ERRO + '],'
    END
    ELSE IF @XML.value('(RESPONSE/HTTP_CODE)[1]', 'VARCHAR(MAX)') = '200' OR @XML.value('(RESPONSE/HTTP_CODE)[1]', 'VARCHAR(MAX)') = '201'
    BEGIN
      /* Obtem o token para futuras consultas */
      SELECT @AUTH_TOKEN = @XML_BODY.value('(accessToken)[1]', 'VARCHAR(MAX)')
    END
    ELSE
    BEGIN
      SELECT @ID_ERRO = 'S'
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
        'E',
        'Erro ao tratar retorno do serviço de autenticação.'
    END
  END -- END DO IF DE ID_ERRO = N

  /* Deleta os registros nas tabelas temporárias para poder incluir novos registros */
  DELETE FROM @TBCONSOME_SERVICO
  DELETE FROM @TBJSON
END TRY 
BEGIN CATCH
  SELECT
    @RET_ID_STATUS = -30,
    @RET_CD_ERRO   = ERROR_NUMBER(),
    @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

  RETURN @RET_ID_STATUS
END CATCH

  ------------------ INSERE OS DADOS NA TABELA TEMPORÁRIA E CHAMA A PROC DE CONSUMIR SERVIÇO PARA RODAR A API -----------------------
BEGIN TRY
  IF @ID_ERRO = 'N'
  BEGIN
    INSERT INTO @TBCONSOME_SERVICO (
      urlBase        ,
      usrPwdBase64   ,
      urlWebService  ,
      requestBody    ,
      requerAuth     ,
      metodo         ,
      formatoRequest ,
      formatoResponse,
      SOAPAction     ,
      authExtern     ,
      idEmpotency
    )
    VALUES (
      @DS_URLCT         ,  --- url do serviço
      NULL              ,
      @DS_URLCT         ,  --- url do serviço
      @JSON_BODY        , -- json do serviço
      'N'               , 
      'POST'            , 
      'application/json', 
      'application/json',
      NULL              ,
      'Bearer ' + @AUTH_TOKEN       , -- token que recebeu na chamada anterior
      NULL     
    )

    SELECT @DS_XML_IN = (
      SELECT
        urlBase        ,
        usrPwdBase64   ,
        urlWebService  ,
        requestBody    ,
        requerAuth     ,
        metodo         ,
        formatoRequest ,
        formatoResponse,
        SOAPAction     ,
        authExtern     ,
        idEmpotency
      FROM
        @TBCONSOME_SERVICO
      FOR XML PATH (''), ROOT('servico')
    )

    EXEC SFINANCEEM..P040101009
      @ENT_NR_VRS    = '1'           ,
      @ENT_NR_INST   = @ENT_NR_INST  ,
      @ENT_NR_AGEN   = @ENT_NR_AGEN  ,
      @ENT_DS_XML    = @DS_XML_IN    ,
      @ENT_CD_OPESIS = @ENT_CD_OPESIS,
      @RET_DS_XML    = @DS_XML_OUT OUTPUT,
      @RET_ID_STATUS = @ID_STATUS  OUTPUT,
      @RET_CD_ERRO   = @CD_ERRO    OUTPUT,
      @RET_DS_ERRO   = @DS_ERRO    OUTPUT
	 
    /* Convert o response de VARCHAR(MAX) para XML */
    SELECT @XML        = CONVERT(XML, @DS_XML_OUT)

	/* Converte o JSON de retorno em XML */
    SELECT @XML_BODY   = SFINANCE_CD.dbo.F010199005(@XML.value('(RESPONSE/RESPONSE_BODY)[1]', 'VARCHAR(MAX)'))
	
	/* Tratamento de erros */
    IF @XML IS NULL AND @XML_BODY IS NULL
    BEGIN         
      SELECT 
        @ID_ERRO = 'S',
        @DS_ERRO  = 'Erro no contrato ' + CONVERT(VARCHAR, @ENT_NR_CONTRA) + ', não houve resposta do webservice.'

      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
		'E',
		@DS_ERRO
      
    END
    ELSE IF @XML.exist('//RESPONSE/RET_ID_STATUS') = 1
    BEGIN
      SELECT 
        @ID_ERRO = 'S',
        @DS_ERRO  = 'Erro no contrato ' + CONVERT(VARCHAR, @ENT_NR_CONTRA) + ', webservice retornou "' + 
          CASE 
            WHEN @XML_BODY.exist('//mensagem') = 1 THEN @XML_BODY.value('(mensagem)[1]', 'VARCHAR(MAX)')
            WHEN @XML_BODY.exist('//message')      = 1 THEN @XML_BODY.value('(message)[1]'     , 'VARCHAR(MAX)')
          END  
          + '".'

      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
        'E',
        @DS_ERRO
    END
    ELSE IF @XML.value('(RESPONSE/HTTP_CODE)[1]', 'VARCHAR(MAX)') = '200' OR @XML.value('(RESPONSE/HTTP_CODE)[1]', 'VARCHAR(MAX)') = '201'
    BEGIN
      PRINT ('SUCESSO!!!')
    END
  END -- END DO IF DE ID_ERRO = N

  /* Deleta os registros nas tabelas temporárias para poder incluir novos registros */
  DELETE FROM @TBCONSOME_SERVICO
  DELETE FROM @TBJSON
END TRY 
BEGIN CATCH
  SELECT
    @RET_ID_STATUS = -40,
    @RET_CD_ERRO   = ERROR_NUMBER(),
    @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

  RETURN @RET_ID_STATUS
END CATCH

GO