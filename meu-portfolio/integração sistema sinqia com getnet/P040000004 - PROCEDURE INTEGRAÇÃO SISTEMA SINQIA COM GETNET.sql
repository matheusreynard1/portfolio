USE SFINANCEEM
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.P040000004'))
  DROP PROCEDURE dbo.P040000004
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

CREATE PROCEDURE dbo.P040000004
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  :: EMPRESA    : Sinqia                                                       ::
  :: SISTEMA    : SQ Crédito                                                   ::
  :: MÓDULO     : consome serviço de cartões BH para atualizar contrato        ::                                                            
  :: UTILIZ. POR:                                                              ::
  :: OBSERVAÇÃO : Procedure chamada por schedules da Getnet                    ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR:                                                              ::
  :: DATA       :                                              VERSÃO SP:      ::
  :: ALTERAÇÃO  :                                                              ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR: Matheus Reynard                                              ::
  :: DATA       : 08/07/2021                                   VERSÃO SP:    1 ::
  :: ALTERAÇÃO  : Primeira versão                                              ::
  ::              Jira: SD-52069 e 52073                                       ::
  :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/*-------------------------------------------------------------------------------
    DESCRIÇÃO DA FUNCIONALIDADE:
    A procedure seleciona informações de contrato a partir dos parâmetros de
    entrada passados e consome o serviço de cartões BH com essas informações
    selecionadas, para atualizar o GRAVAME dos recebíveis junto à CIP, quando 
    ocorrer a seguinte situação: liquidação parcial do valor da parcela;
    liquidação do valor total da parcela; atualização diária de saldo de 
    contrato vencido.
---------------------------------------------------------------------------------*/
  @ENT_NR_VRS       VARCHAR(4)            , /* Número da versão da SP            */
  @ENT_NR_INST      NUMERIC(9)            , /* Instituição                       */
  @ENT_NR_AGEN      NUMERIC(5)            , /* Agência                           */
  @ENT_CD_OPESIS    NUMERIC(9)            , /* Usuário que executou o processo   */
  @RET_ID_STATUS    NUMERIC(5)      OUTPUT, /* Variável de retorno               */
  @RET_CD_ERRO      NUMERIC(9)      OUTPUT, /* Código de erro do SQL             */
  @RET_DS_ERRO      VARCHAR(255)    OUTPUT  /* Mensagem nativa de erro           */
  WITH ENCRYPTION
AS

/*---------------------------------------------------------------------------*/
/* Verifica se a versão do módulo é diferente da versão da Stored Procedure  */
/*---------------------------------------------------------------------------*/
DECLARE @LOC_NR_RTCODE INTEGER
EXECUTE @LOC_NR_RTCODE = SP_CD0100002 @ENT_NR_VRS, '1', 'P040000004'
IF @LOC_NR_RTCODE = 99999 RETURN 99999
/*--------------------------------------------------------------------------*/


/*Tabela temporária de mensagens de retorno*/
CREATE TABLE #TBERROR_MSGS (
  TP_MSG       CHAR(1)      , /* E = Erro; I = Informação; O = Ok; A = Aviso. */
  DS_MSG       VARCHAR(MAX)
)

-------------------------------- DECLARAÇÃO DE VARIAVEIS --------------------------

DECLARE
  @XML              XML             ,
  @XML_BODY         XML             ,  
  @DS_XMLRES        XML             ,
  @DS_XML           XML             ,
  @TP_MSG           CHAR(1)         ,
  @DT_ATU           NUMERIC(8,0)    ,
  @DT_ANT           NUMERIC(8,0)    ,
  @NR_CONTRATO      NUMERIC(18,0)   ,   
  @CD_CLIENTE       NUMERIC(11)     ,              
  @CD_ERRO          NUMERIC(9)      , 
  @ID_STATUS        NUMERIC(9)      ,
  @VERIF_CONTRA_1   NUMERIC(18,0)   ,
  @VERIF_CONTRA_2   NUMERIC(18,0)   ,
  @DS_USRWS         VARCHAR(MAX)    ,
  @DS_URLBAS        VARCHAR(MAX)    ,
  @ID_EMPOTENCYID   VARCHAR(MAX)    ,
  @DS_URLCT         VARCHAR(MAX)    ,
  @DS_XML_IN        VARCHAR(MAX)    ,
  @DS_XML_OUT       VARCHAR(MAX)    ,
  @DS_MENSAG        VARCHAR(MAX)    ,
  @DS_URLAUTH       VARCHAR(MAX)    ,
  @DS_PWDWS         VARCHAR(MAX)    ,
  @DS_RESPONSE      VARCHAR(MAX)    ,
  @DS_ERRO          VARCHAR(255)    ,
  @JSON_BODY        VARCHAR(MAX)    ,
  @AUTH_TOKEN       VARCHAR(MAX)    ,
  @DS_XMLSAI        VARCHAR(MAX)    ,
  @JSON_AUTH        VARCHAR(MAX)    ,
  @DS_MSG           VARCHAR(255)    ,
  @ID_ERRO          CHAR(1)    

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

-------------------- // CRIA A TABELA TEMPORÁRIA PARA CALCULAR O SALDO // -----------------

CREATE TABLE #TB_CALC_SALDO (
  EM01_TP_FRMPAG      VARCHAR(3)   ,
  EM01_NR_INST        NUMERIC( 5,0),
  EM01_NR_AGEN        NUMERIC( 5,0),
  EM01_CD_CLIENT      NUMERIC(11,0),
  CL01_NM_CLIENT      VARCHAR(120) ,
  EM01_NR_CONTRA      NUMERIC(15,0),
  EM06_NR_PRESTA      NUMERIC(5,0) ,
  EM06_DT_VCTPRE      NUMERIC(8,0) ,
  EM06_DT_VCTNEW      NUMERIC(8,0) ,
  EM06_VL_PRESTA      NUMERIC(17,2),
  EM06_VL_MULTA       NUMERIC(17,2),
  EM06_VL_JURVCD      NUMERIC(17,2),
  EM06_VL_DESCON      NUMERIC(17,2),
  EM06_VL_IOF         NUMERIC(17,2),
  EM06_VL_PRECOB      NUMERIC(17,2),
  EM01_CD_CLISAC      NUMERIC(11,0),
  CL01_NM_CLISAC      VARCHAR(255) ,
  CL01_NM_EMAIL       VARCHAR(255) ,
  EM30_VL_TARIFA      NUMERIC(17,2),
  EM179_NR_BANCO      NUMERIC(5,0) ,
  EM179_NR_AGESFN     NUMERIC(5,0) ,
  EM179_NR_CTACOR     NUMERIC(9,0) ,
  EM179_DG_CTACOR     NUMERIC(2,0) ,
  EM01_TP_PGMTO       VARCHAR(3)
)

------------------------------------- TABELA DE VALORES PARA MONTAR O JSON-----------------------

DECLARE @TBJSON TABLE (
  codLegado                  NUMERIC(9,0) ,  
  cpfCnpjUsuarioFinal        VARCHAR(14)  ,
  numeroContrato             NUMERIC(18,0),
  indicadorTpNegc            CHAR(2)      ,
  dataVencOperacao           DATETIME     ,
  valor                      NUMERIC(17,2),
  valorGarantia              NUMERIC(17,2),
  regraDivisao               CHAR(1)      ,
  cpfCnpjTitular             VARCHAR(14)  ,
  valorPercentualGarantia    NUMERIC(17,2),
  agencia                    NUMERIC(9,0) ,
  conta                      NUMERIC (9,0),
  tipoCnpj                   CHAR(1)      ,
  dataFimOperacao            DATETIME     ,
  tipoDominio                CHAR(1)
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

    -- PEGA A URL, USUÁRIO E SENHA DA TABELA CD21 
    SELECT 
      @DS_USRWS       = CD21_DS_USR, -- login de acesso ao serviço
      @DS_PWDWS       = SFINANCE_CD.dbo.FC_CD0100040(CD21_DS_PWD, 'D', (ASCII('C') * 1000 + ASCII('D')) % 100000),
      @DS_URLBAS      = CD21_DS_URL -- URL de acesso ao serviço
    FROM
      SFINANCE_CD..CD21
    WHERE
          CD21_NR_INST = @ENT_NR_INST
      AND CD21_CD_SERV = 53 -- Código do serviço de Cartões BH

      -- ADICIONA NAS VARIÁVEIS AS URLS DE AUTENTICAÇÃO E DE CADASTRO DO CONTABIL
    SELECT 
      @DS_URLCT   = @DS_URLBAS + '/api/OperacaoFumaca', -- URL DO SERVIÇO
      @DS_URLAUTH = @DS_URLBAS + '/api/Login' -- URL DO LOGIN DO SERVIÇO

  --------------- MONTA O JSON DE AUTENTICAÇÃO --------------------

  SELECT @JSON_AUTH = 
  '{
    "login": "'+@DS_USRWS+'",
    "accessKey": "'+@DS_PWDWS+'"
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

  END -- FIM DO IF ID ERRO

  /* Deleta o registro de "login da API" da tabela temporária para poder inserir o JSON de "consumo da API" */
  DELETE FROM @TBCONSOME_SERVICO

END TRY
BEGIN CATCH
  SELECT
    @RET_ID_STATUS = -30,
    @RET_CD_ERRO   = ERROR_NUMBER(),
    @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

  RETURN @RET_ID_STATUS
END CATCH

IF @ID_ERRO = 'N'
BEGIN
----------- CALCULA DT_ATU PARA CALCULAR O SALDO ----------
  SELECT
    @DT_ANT = EM700_DT_ANT,
    @DT_ATU = EM700_DT_ATU
  FROM
    EM700
  WHERE
      EM700_NR_INST = @ENT_NR_INST
  AND EM700_NR_AGEN = @ENT_NR_AGEN  

  ---------------// SELECIONA OS PARÂMETROS PARA EXECUTAR A PROC QUE CALCULA O SALDO E INICIA O CURSOR // ------------------------------

  DECLARE CURSOR_1 CURSOR LOCAL READ_ONLY FAST_FORWARD FOR
    SELECT
          EM01_CD_CLIENT,
          EM01_NR_CONTRA
    FROM 
          EM01
    WHERE
        EM01_ID_SITUAC < 8 
    AND EM01_NR_INST   = @ENT_NR_INST
    AND EM01_NR_AGEN   = @ENT_NR_AGEN
    AND EXISTS (SELECT
                  NULL
                FROM
                  SFINANCE_GA..GA03
                WHERE
                    GA03_NR_INST =   EM01_NR_INST
                AND GA03_NR_AGEN =   EM01_NR_AGEN
                AND GA03_CD_CLIENT = EM01_CD_CLIENT
                AND GA03_NR_CONTRA = EM01_NR_CONTRA
                AND GA03_CD_SIST   = 4
                AND GA03_TP_GARDEF = 100 )            -- Garantia 100 foi criada na GET para tipo de recebíveis de cartões
    AND EXISTS (
        SELECT
          NULL
        FROM
          EM07 A
        WHERE
            A.EM07_NR_INST =   EM01_NR_INST
        AND A.EM07_NR_AGEN =   EM01_NR_AGEN
        AND A.EM07_CD_CLIENT = EM01_CD_CLIENT
        AND A.EM07_NR_CONTRA = EM01_NR_CONTRA
        AND A.EM07_DT_MOVIME BETWEEN @DT_ANT AND @DT_ATU)       
      UNION
      SELECT
            EM01_CD_CLIENT,
            EM01_NR_CONTRA
      FROM 
            EM01
      WHERE
          EM01_ID_SITUAC IN (1, 2, 3, 4) 
      AND EM01_NR_INST   = @ENT_NR_INST
      AND EM01_NR_AGEN   = @ENT_NR_AGEN
      AND EXISTS (SELECT
                    NULL
                  FROM
                    SFINANCE_GA..GA03
                  WHERE
                      GA03_NR_INST =   EM01_NR_INST
                  AND GA03_NR_AGEN =   EM01_NR_AGEN
                  AND GA03_CD_CLIENT = EM01_CD_CLIENT
                  AND GA03_NR_CONTRA = EM01_NR_CONTRA
                  AND GA03_CD_SIST   = 4
                  AND GA03_TP_GARDEF = 100 )            -- Garantia 100 foi criada na GET para tipo de recebíveis de cartões
     

  --Abrindo Cursor
  OPEN CURSOR_1
  
    -- Lendo a próxima linha
  FETCH NEXT FROM CURSOR_1 INTO @CD_CLIENTE, @NR_CONTRATO

  -- Percorrendo linhas do cursor (enquanto houverem)
  WHILE @@FETCH_STATUS = 0
  BEGIN
    --------------------------- // EXECUTA A PROC PARA CALCULAR O SALDO E SALVA EM UM XML // ----------------

    EXEC P040016052
      @ENT_NR_VRS     = '1' ,
      @ENT_NR_INST    = @ENT_NR_INST ,
      @ENT_NR_AGEN    = @ENT_NR_AGEN ,
      @ENT_ID_FINEMP  = NULL ,
      @ENT_CD_GRPPRO  = NULL ,
      @ENT_CD_PRODUT  = NULL ,
      @ENT_CD_CLIENT  = @CD_CLIENTE,
      @ENT_NR_PREST   = NULL ,
      @ENT_NR_CONTRA  = @NR_CONTRATO,
      @ENT_DT_VCTINI  = 20001201 ,
      @ENT_DT_VCTFIM  = 25001201 ,
      @ENT_NR_DIAVCT  = NULL ,
      @ENT_TP_DIAS    = 0 ,
      @ENT_DT_VCTBOL  = @DT_ATU, -- Data do Saldo
      @ENT_CD_TIPINT  = NULL ,
      @ENT_DT_ATU     = @DT_ATU, -- filtro inst e agen
      @ENT_ID_USRVTO  = 'N' ,
      @ENT_TP_FRMPAG  = 'B' ,
      @ENT_NR_BANCO   = NULL ,
      @ENT_DD_DEB     = NULL ,
      @ENT_TP_VCTDEB  = NULL ,
      @ENT_NR_SITUAC  = 31 ,
      @ENT_ID_PRESTA  = NULL ,
      @ENT_ID_BOLCON  = NULL ,
      @ENT_ID_LSTBLO  = 'N' ,
      @ENT_ID_BOLSAC  = NULL ,
      @ENT_ID_RESULT  = 'N' ,	
      @RET_DS_XMLSAI  = @DS_XMLSAI OUTPUT
	
    SELECT @DS_XMLRES = CONVERT(XML, @DS_XMLSAI)

    --------------------------------- // INSERE OS VALORES DO XML NA TABELA TEMPORÁRIA // ---------------------------

    INSERT INTO #TB_CALC_SALDO
    SELECT
     T.C.value('EM01_TP_FRMPAG[1]' , 'CHAR(1)' ) EM01_TP_FRMPAG ,
     T.C.value('EM01_NR_INST[1]' , 'NUMERIC(9)' ) EM01_NR_INST ,
     T.C.value('EM01_NR_AGEN[1]' , 'NUMERIC(5)' ) EM01_NR_AGEN ,
     T.C.value('EM01_CD_CLIENT[1]' , 'NUMERIC(11)' ) EM01_CD_CLIENT ,
     T.C.value('CL01_NM_CLIENT[1]' , 'VARCHAR(60)' ) CL01_NM_CLIENT ,
     T.C.value('EM01_NR_CONTRA[1]' , 'NUMERIC(13)' ) EM01_NR_CONTRA ,
     T.C.value('EM06_NR_PRESTA[1]' , 'NUMERIC(5)' ) EM06_NR_PRESTA ,
     T.C.value('EM06_DT_VCTPRE[1]' , 'NUMERIC(8)' ) EM06_DT_VCTPRE ,
     T.C.value('EM06_DT_VCTNEW[1]' , 'NUMERIC(8)' ) EM06_DT_VCTNEW ,
     T.C.value('EM06_VL_PRESTA[1]' , 'NUMERIC(17,2)') EM06_VL_PRESTA ,
     T.C.value('EM06_VL_MULTA[1]' , 'NUMERIC(17,2)') EM06_VL_MULTA ,
     T.C.value('EM06_VL_JURVCD[1]' , 'NUMERIC(17,2)') EM06_VL_JURVCD ,
     T.C.value('EM06_VL_DESCON[1]' , 'NUMERIC(17,2)') EM06_VL_DESCON ,
     T.C.value('EM06_VL_IOF[1]' , 'NUMERIC(17,2)') EM06_VL_IOF ,
     T.C.value('EM06_VL_PRECOB[1]' , 'NUMERIC(17,2)') EM06_VL_PRECOB ,
     T.C.value('EM01_CD_CLISAC[1]' , 'NUMERIC(11)' ) EM01_CD_CLISAC ,
     T.C.value('CL01_NM_CLISAC[1]' , 'VARCHAR(60)' ) CL01_NM_CLISAC ,
     T.C.value('CL01_NM_EMAIL[1]' , 'VARCHAR(300)' ) CL01_NM_EMAIL ,
     T.C.value('EM30_VL_TARIFA[1]' , 'NUMERIC(17,2)') EM30_VL_TARIFA ,
     T.C.value('EM179_NR_BANCO[1]' , 'NUMERIC(5)' ) EM179_NR_BANCO ,
     T.C.value('EM179_NR_AGESFN[1]' , 'NUMERIC(5)' ) EM179_NR_AGESFN,
     T.C.value('EM179_NR_CTACOR[1]' , 'NUMERIC(12)' ) EM179_NR_CTACOR,
     T.C.value('EM179_DG_CTACOR[1]' , 'VARCHAR(2)' ) EM179_DG_CTACOR,
     T.C.value('EM01_TP_PGTSAS[1]' , 'VARCHAR(2)' ) EM01_TP_PGTSAS
    FROM
      @DS_XMLRES.nodes('/P040016052/reg') T(C)  
	
     ------------------------ GERA O JSON DE CONSUMO DE SERVIÇO ------------------

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
      agencia 		            ,		 
      conta 			            ,
      tipoCnpj 		            ,
      dataFimOperacao 	      ,
      tipoDominio 
    )
    SELECT
      1, /* codLegado */
      CL01_NR_CPFCNPJ, /* cpfCnpjUsuarioFinal */
      EM01_NR_CONTRA, /* numeroContrato */
      'OG', /* indicadorTpNegc */
      CONVERT(DATETIME, CAST(EM01_DT_VCTULT AS VARCHAR), 101), /* dataVencOperacao */   
      (SELECT sum(EM06_VL_PRECOB + EM06_VL_DESCON) FROM #TB_CALC_SALDO), /* valor */
      (SELECT sum(EM06_VL_PRECOB + EM06_VL_DESCON) FROM #TB_CALC_SALDO), /* valorGarantia */
      'V', /* regraDivisao */
      CL01_NR_CPFCNPJ, /* cpfCnpjTitular */
      (SELECT sum(EM06_VL_PRECOB + EM06_VL_DESCON) FROM #TB_CALC_SALDO), /* valorPercentualGarantia */
      CL05_NR_AGENC, /* agencia */ 
      CL05_NR_CONTA, /* conta */
      'C', /* tipoCnpj */
      CONVERT(DATETIME, CAST(EM01_DT_VCTULT AS VARCHAR), 101), /* dataFimOperacao */
      'A' /* tipoDominio */
    FROM 
      EM01 INNER JOIN CL01 ON (
            EM01_NR_INST   = CL01_NR_INST
        AND EM01_CD_CLIENT = CL01_NR_CLIENT 
      ) INNER JOIN CL05 ON (
            EM01_NR_INST   = CL05_NR_INST
        AND EM01_CD_CLIENT = CL05_NR_CLIENT
        AND CL05_ST_CTPDR = 'S'
      )
    WHERE
          EM01_ID_SITUAC < 8 
      AND EM01_NR_INST   = @ENT_NR_INST
      AND EM01_NR_AGEN   = @ENT_NR_AGEN
      AND EM01_CD_CLIENT = @CD_CLIENTE
      AND EM01_NR_CONTRA = @NR_CONTRATO
      AND EM01_DT_CONTRA <= @DT_ATU
    
  

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
          "tipoDominio": "'+(SELECT CONVERT(VARCHAR, tipoDominio) FROM @TBJSON)+'",
        }
      ]
    }'

    ------------------ INSERE OS DADOS NA TABELA TEMPORÁRIA E CHAMA A PROC DE CONSUMIR SERVIÇO PARA RODAR A API -----------------------

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
      'PUT'            , 
      'application/json', 
      'application/json',
      NULL              ,
      'Bearer ' + @AUTH_TOKEN, -- token que recebeu na chamada anterior
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
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
      'E',
      'Erro no contrato ' + CONVERT(VARCHAR, @NR_CONTRATO) + ', não houve resposta do webservice.'
    END
    ELSE IF @XML.exist('//RESPONSE/RET_ID_STATUS') = 1
    BEGIN
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
        'E',
        'Erro no contrato ' + CONVERT(VARCHAR, @NR_CONTRATO) + ', webservice retornou "' + 
          CASE 
            WHEN @XML_BODY.exist('//mensagem') = 1 THEN @XML_BODY.value('(mensagem)[1]', 'VARCHAR(MAX)')
            WHEN @XML_BODY.exist('//message')      = 1 THEN @XML_BODY.value('(message)[1]'     , 'VARCHAR(MAX)')
          END  
          + '".'
    END
    ELSE IF @XML.value('(RESPONSE/HTTP_CODE)[1]', 'VARCHAR(MAX)') = '200' OR @XML.value('(RESPONSE/HTTP_CODE)[1]', 'VARCHAR(MAX)') = '201'
    BEGIN
      INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
      SELECT
        'O',
        'Sucesso ao enviar o contrato ' + CONVERT(VARCHAR, @NR_CONTRATO) + ', para o webservice.'
    END

    /* Deleta os registros nas tabelas temporárias para poder incluir novos registros */
    DELETE FROM @TBCONSOME_SERVICO
    DELETE FROM @TBJSON
    DELETE FROM #TB_CALC_SALDO

    FETCH NEXT FROM CURSOR_1 INTO @CD_CLIENTE, @NR_CONTRATO

  END -- FIM DO WHILE

  CLOSE CURSOR_1
  DEALLOCATE CURSOR_1

END -- FIM DO IF DE ID ERRO

GO