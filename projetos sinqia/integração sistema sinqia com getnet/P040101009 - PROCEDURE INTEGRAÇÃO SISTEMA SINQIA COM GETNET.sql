USE SFINANCEEM
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.P040101009'))
  DROP PROCEDURE dbo.P040101009
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

CREATE PROCEDURE dbo.P040101009
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  :: EMPRESA    : Sinqia                                                       ::
  :: SISTEMA    : SQ Crédito                                                   ::
  :: MÓDULO     : Rotina para consumo de WebService Parametrizado              ::
  :: UTILIZ. POR: P040000003, P040000004, P040000005                           ::
  :: OBSERVAÇÃO :                                                              ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR:                                                              ::
  :: DATA       :                                              VERSÃO SP:      ::
  :: ALTERAÇÃO  :                                                              ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR: Matheus Reynard                                              ::
  :: DATA       : 27/06/2021                                   VERSÃO SP:    1 ::
  :: ALTERAÇÃO  : Primeira versão                                              ::
  :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/*-------------------------------------------------------------------------------
  DESCRIÇÃO DA FUNCIONALIDADE:

  SP para chamar um serviço Rest padrão da Sinqia
  -------------------------------------------------------------------------------*/
  @ENT_NR_VRS      VARCHAR(4)           , /* Número da versão                    */
  @ENT_NR_INST     NUMERIC(9)           , /* Nr. Instituição                     */ 
  @ENT_NR_AGEN     NUMERIC(9)           , /* Número da agencia                   */
  @ENT_DS_XML      VARCHAR(MAX)         , /* XML de Entrada                      */
  @ENT_CD_OPESIS   NUMERIC(9)           , /* Usuário que executou o processo     */
  @RET_DS_XML      VARCHAR(MAX)  OUTPUT , /* XML de Saída                        */ 
  @RET_ID_STATUS   NUMERIC(5)    OUTPUT , /* Variável de retorno (0 = Sucesso)   */
  @RET_CD_ERRO     NUMERIC(9)    OUTPUT , /* Código de erro do SQL               */
  @RET_DS_ERRO     VARCHAR(255)  OUTPUT   /* Mensagem de erro                    */
  WITH ENCRYPTION
AS

/*--------------------------------------------------------------------------*/
/* Verifica se a versão do Módulo é diferente da versão da Stored Procedure */
/*--------------------------------------------------------------------------*/
DECLARE @LOC_NR_RTCODE INTEGER
EXECUTE @LOC_NR_RTCODE = SP_CD0100002 @ENT_NR_VRS, '1', 'P040101009'
IF @LOC_NR_RTCODE = 99999 RETURN 99999

/*--------------------------------------------------------------------------*/
/* DECLARAÇÃO DE VARIÁVEIS E TABELAS                                        */
/*--------------------------------------------------------------------------*/
DECLARE
  @DS_XML          XML          ,
  @DS_URLBAS       VARCHAR(MAX) , /* URL base                                 */
  @DS_USRB64       VARCHAR(255) , /* Usuário:senha em Base64                  */
  @DS_URLWS        VARCHAR(255) , /* URL WebService                           */
  @DS_BODY         XML          , /* Request Body                             */
  @ID_AUTH         CHAR(1)      ,
  @DS_METODO       VARCHAR(MAX) ,
  @DS_FMTREQ       VARCHAR(MAX) ,
  @DS_FMTRSP       VARCHAR(MAX) ,
  @DS_SOAPAC       VARCHAR(MAX) ,
  @OBJ             INT          ,
  @RESPONSE_BODY   VARCHAR(MAX) ,
  @RESPONSE_HEADER VARCHAR(8000),
  @RESP_BODY_XML   XML          ,
  @URL_LOGIN       VARCHAR(MAX) ,
  @LOGINSTR        VARCHAR(255) ,
  @URL_PATH        VARCHAR(MAX) ,
  @BODY_PATH       VARCHAR(MAX) ,
  @HTTPSTATUS      INT          ,
  @AUTH_TOKEN      VARCHAR(8000),
  @CONTENT_TYPE    VARCHAR(MAX) ,
  @DS_GUID         VARCHAR(50)  ,
  @DT_ATUAL        VARCHAR(8)   ,
  @AUTH_EXTERN     VARCHAR(8000), /* Caso a autenticação seja feita de forma externa / via outro serviço oauth */
  @ID_EMPOTENCY    VARCHAR(MAX)   /* Caso o serviço consumido tenha controle de idempotency nas requisições    */

CREATE TABLE #TB210501020_RESPONSE (
  RESPONSE_BODY    VARCHAR(MAX)
)

BEGIN TRY
  BEGIN TRY
  /* Leitura XML de entrada */
    SELECT @DS_XML = CONVERT(XML, @ENT_DS_XML)

    SELECT 
      @DS_URLBAS    = T.C.value('./urlBase[1]'        , 'varchar(max)'),
      @DS_USRB64    = T.C.value('./usrPwdBase64[1]'   , 'varchar(max)'),
      @DS_URLWS     = T.C.value('./urlWebService[1]'  , 'varchar(max)'),
      @DS_BODY      = T.C.query('./requestBody[1]'),
      @ID_AUTH      = T.C.value('./requerAuth[1]'     , 'varchar(max)'), -- N (Não), S (Sim), P (Autenticação parametrizada)
      @DS_METODO    = T.C.value('./metodo[1]'         , 'varchar(max)'),
      @DS_FMTREQ    = T.C.value('./formatoRequest[1]' , 'varchar(max)'),
      @DS_FMTRSP    = T.C.value('./formatoResponse[1]', 'varchar(max)'),
      @DS_SOAPAC    = T.C.value('./SOAPAction[1]'     , 'varchar(max)'),
      @AUTH_TOKEN   = T.C.value('./authToken[1]'      , 'varchar(max)'), -- Caso requerAuth for P é necessário que tenha uma autenticação
      @AUTH_EXTERN  = T.C.value('./authExtern[1]'     , 'varchar(max)'), 
      @ID_EMPOTENCY = T.C.value('./idEmpotency[1]'    , 'varchar(max)')
    FROM
      @DS_XML.nodes('/servico') AS T(C)
      
    IF @DS_BODY.exist('requestBody/*') = 1
      SELECT @DS_BODY = T.C.query('.') FROM @DS_BODY.nodes('/requestBody/*') T(C)
    ELSE
      SELECT @DS_BODY = @DS_BODY.value('/requestBody[1]', 'varchar(max)')

  /* Verifica se foi solicitado acesso ao WebService de Login */
    IF UPPER(COALESCE(@ID_AUTH, 'N')) = 'S'
    BEGIN 
      SELECT @URL_LOGIN = @DS_URLBAS + '/user'
      SELECT @LOGINSTR  = 'Basic ' + @DS_USRB64

      EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @OBJ OUTPUT
      EXEC sp_OAMethod @OBJ, 'open', NULL, 'get', @URL_LOGIN, 'false'
      EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'Authorization', @LOGINSTR
      EXEC sp_OAMethod @OBJ, 'send'

      SELECT @HTTPSTATUS = NULL
      EXEC sp_OAGetProperty @OBJ, 'status', @HTTPSTATUS OUTPUT 

      SELECT @RESPONSE_BODY = NULL
      EXEC sp_OAMethod @OBJ, 'responseText', @RESPONSE_BODY OUTPUT

      SELECT @RESPONSE_HEADER = NULL
      EXEC sp_OAMethod @OBJ, 'getResponseHeader', @RESPONSE_HEADER OUTPUT, 'auth'
      EXEC sp_OADestroy @OBJ
      
      IF @HTTPSTATUS <> 200
      BEGIN
        IF @HTTPSTATUS = 404
        BEGIN
          SELECT @RET_ID_STATUS = -11
          SELECT @RET_CD_ERRO   = @HTTPSTATUS
          SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): Page not found. URL: ' + COALESCE(@URL_LOGIN, 'NULL')
        END
        ELSE
        BEGIN
          SELECT @RET_ID_STATUS = -12
          SELECT @RET_CD_ERRO   = @HTTPSTATUS
          SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + COALESCE(@RESPONSE_BODY, 'Sem BODY')
        END
        
        SELECT @RET_DS_XML = CONVERT(VARCHAR(MAX), (
        SELECT
          CONVERT(VARCHAR(255), @RET_ID_STATUS) RET_ID_STATUS,
          CONVERT(VARCHAR(255), @RET_CD_ERRO)   RET_CD_ERRO  ,
          @RET_DS_ERRO                          RET_DS_ERRO
        FOR XML PATH ('RESPONSE'), TYPE
        ))

        /* GUID de controle */
        SELECT 
          @DS_GUID  = NEWID(),
          @DT_ATUAL = CONVERT(VARCHAR(8), GETDATE(), 112)
        /* Monta log */
        EXEC dbo.P040000990
          @ENT_NR_VRS    = '1'                ,       
          @ENT_ID_GUID   = @DS_GUID           , 
          @ENT_NR_INST   = @ENT_NR_INST       ,
          @ENT_NR_AGEN   = @ENT_NR_AGEN       ,
          @ENT_DT_MVTO   = @DT_ATUAL          , 
          @ENT_NM_WS     = @URL_LOGIN         ,
          @ENT_NM_METODO = @DS_METODO         ,
          @ENT_NR_IP     = @DS_URLBAS         ,
          @ENT_TP_REQUIS = 'S'                ,
          @ENT_DS_REQUIS = @ENT_DS_XML        ,
          @ENT_DS_RETORN = @RET_DS_XML        ,
          @ENT_DS_ERRO   = @RET_DS_ERRO       ,
          @ENT_DS_COMENT = 'Login realizado pela rotina de consumo de webservices.',
          @ENT_CD_OPESIS = @ENT_CD_OPESIS     ,
          @ENT_ID_RESULT = 'N'

        RETURN @RET_ID_STATUS
      END
      SELECT @AUTH_TOKEN = 'Bearer ' + @RESPONSE_HEADER
    END -- IF UPPER(COALESCE(@ID_AUTH, 'N')) = 'S'

  /* Método GET */
    IF UPPER(@DS_METODO) = 'GET'
    BEGIN 
      EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @OBJ OUTPUT
      EXEC sp_OAMethod @OBJ, 'open', NULL, @DS_METODO, @DS_URLWS, 'false'

      IF UPPER(COALESCE(@ID_AUTH, 'N')) = 'S' OR UPPER(COALESCE(@ID_AUTH, 'N')) = 'P'
        EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'Authorization', @AUTH_TOKEN

      IF @DS_FMTRSP IS NOT NULL
        EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'Accept', @DS_FMTRSP

      EXEC sp_OAMethod @OBJ, 'send'

      SELECT @HTTPSTATUS = NULL
      EXEC sp_OAGetProperty @OBJ, 'status', @HTTPSTATUS OUTPUT

      INSERT #TB210501020_RESPONSE (RESPONSE_BODY)
      EXEC sp_OAMethod @OBJ, 'responseText'
      
      EXEC sp_OADestroy @OBJ

      IF @HTTPSTATUS >= 300
      BEGIN
        IF @HTTPSTATUS = 404
        BEGIN
          SELECT @RET_ID_STATUS = -13
          SELECT @RET_CD_ERRO   = @HTTPSTATUS
          SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): Page not found. URL: ' + COALESCE(@DS_URLWS, 'NULL')
        END
        ELSE
        BEGIN
          SELECT @RET_ID_STATUS = -14
          SELECT @RET_CD_ERRO   = @HTTPSTATUS
          SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + COALESCE((SELECT TOP 1 RESPONSE_BODY FROM #TB210501020_RESPONSE), 'NULL')
          SELECT @RESPONSE_BODY = ''
          SELECT
            @RESPONSE_BODY = @RESPONSE_BODY + RESPONSE_BODY
          FROM
            #TB210501020_RESPONSE
        END

        /* Trata formato do retorno do serviço */
        IF CHARINDEX('XML', UPPER(@DS_FMTRSP), 1) > 0
          SELECT @RESP_BODY_XML = CONVERT(XML, REPLACE(@RESPONSE_BODY, '<?xml version="1.0" encoding="utf-8"?>', ''))

        SELECT @RET_DS_XML = CONVERT(VARCHAR(MAX), (
        SELECT
          CONVERT(VARCHAR(255), @RET_ID_STATUS) RET_ID_STATUS,
          CONVERT(VARCHAR(255), @RET_CD_ERRO)   RET_CD_ERRO  ,
          @RET_DS_ERRO                          RET_DS_ERRO  ,
          COALESCE(@RESP_BODY_XML, COALESCE(@RESPONSE_BODY, '')) RESPONSE_BODY
        FOR XML PATH ('RESPONSE'), TYPE
        ))

        /* GUID de controle */
        SELECT 
          @DS_GUID  = NEWID(),
          @DT_ATUAL = CONVERT(VARCHAR(8), GETDATE(), 112)
        /* Monta log */
        EXEC dbo.P040000990
          @ENT_NR_VRS    = '1'                ,       
          @ENT_ID_GUID   = @DS_GUID           , 
          @ENT_NR_INST   = @ENT_NR_INST       ,
          @ENT_NR_AGEN   = @ENT_NR_AGEN       ,
          @ENT_DT_MVTO   = @DT_ATUAL          , 
          @ENT_NM_WS     = @DS_URLWS          ,
          @ENT_NM_METODO = @DS_METODO         ,
          @ENT_NR_IP     = @DS_URLBAS         ,
          @ENT_TP_REQUIS = 'S'                ,
          @ENT_DS_REQUIS = @ENT_DS_XML        ,
          @ENT_DS_RETORN = @RET_DS_XML        ,
          @ENT_DS_ERRO   = @RET_DS_ERRO       ,
          @ENT_DS_COMENT = 'Envio realizado pela rotina de consumo de webservices.',
          @ENT_CD_OPESIS = @ENT_CD_OPESIS     ,
          @ENT_ID_RESULT = 'N'

        RETURN @RET_ID_STATUS
      END
    END -- IF UPPER(@DS_METODO) = 'GET'

  /* Método POST */
    IF UPPER(@DS_METODO) = 'POST' OR UPPER(@DS_METODO) = 'PUT'
    BEGIN 
      EXEC sp_OACreate 'MSXML2.ServerXMLHTTP', @OBJ OUTPUT
      EXEC sp_OASetProperty @OBJ, 'setTimeouts', '75000', '75000', '75000', '75000'
      EXEC sp_OAMethod @OBJ, 'open', NULL, @DS_METODO, @DS_URLWS, 'false'

      IF UPPER(COALESCE(@ID_AUTH, 'N')) = 'S' OR UPPER(COALESCE(@ID_AUTH, 'N')) = 'P'
        EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'Authorization', @AUTH_TOKEN
      
      IF NOT @AUTH_EXTERN IS NULL AND UPPER(COALESCE(@ID_AUTH, 'N')) = 'N'
        EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'Authorization', @AUTH_EXTERN

      IF NOT @ID_EMPOTENCY IS NULL 
        EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'Idempotency-id', @ID_EMPOTENCY

      EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'Content-Type', @DS_FMTREQ
      
      IF @DS_FMTRSP IS NOT NULL
        EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'Accept', @DS_FMTRSP

      IF NOT @DS_SOAPAC IS NULL
        EXEC sp_OAMethod @OBJ, 'setRequestHeader', null, 'SOAPAction', @DS_SOAPAC

      EXEC sp_OAMethod @OBJ, 'send', null, @DS_BODY

      SELECT @HTTPSTATUS = NULL
      EXEC sp_OAGetProperty @OBJ, 'status', @HTTPSTATUS OUTPUT

      SELECT @RESPONSE_HEADER = NULL
      EXEC sp_OAMethod @OBJ, 'getAllResponseHeaders', @RESPONSE_HEADER OUTPUT

      INSERT #TB210501020_RESPONSE (RESPONSE_BODY)
      EXEC sp_OAMethod @OBJ, 'responseText'

      EXEC sp_OADestroy @OBJ

      IF @HTTPSTATUS <> 200 AND @HTTPSTATUS <> 204 AND @HTTPSTATUS <> 201
      BEGIN
        IF @HTTPSTATUS = 404 
        BEGIN
          SELECT @RET_ID_STATUS = -15
          SELECT @RET_CD_ERRO   = @HTTPSTATUS
          SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): Page not found. URL: ' + COALESCE(@DS_URLWS, 'NULL')
        END
        ELSE
        BEGIN
          SELECT @RET_ID_STATUS = -16
          SELECT @RET_CD_ERRO   = @HTTPSTATUS
          SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + COALESCE((SELECT TOP 1 RESPONSE_BODY FROM #TB210501020_RESPONSE), 'NULL')
          SELECT @RESPONSE_BODY = ''
          SELECT
            @RESPONSE_BODY = @RESPONSE_BODY + RESPONSE_BODY
          FROM
            #TB210501020_RESPONSE
        END

        /* Trata formato do retorno do serviço */
        IF CHARINDEX('XML', UPPER(@DS_FMTRSP), 1) > 0
          SELECT @RESP_BODY_XML = CONVERT(XML, REPLACE(@RESPONSE_BODY, '<?xml version="1.0" encoding="utf-8"?>', ''))

        SELECT @RET_DS_XML = CONVERT(VARCHAR(MAX), (
        SELECT
          CONVERT(VARCHAR(255), @RET_ID_STATUS) RET_ID_STATUS,
          CONVERT(VARCHAR(255), @RET_CD_ERRO)   RET_CD_ERRO  ,
          @RET_DS_ERRO                          RET_DS_ERRO  ,
          COALESCE(@RESP_BODY_XML, COALESCE(@RESPONSE_BODY, '')) RESPONSE_BODY
        FOR XML PATH ('RESPONSE'), TYPE
        ))

        /* GUID de controle */
        SELECT 
          @DS_GUID  = NEWID(),
          @DT_ATUAL = CONVERT(VARCHAR(8), GETDATE(), 112)
        /* Monta log */
        EXEC dbo.P040000990
          @ENT_NR_VRS    = '1'                ,       
          @ENT_ID_GUID   = @DS_GUID           , 
          @ENT_NR_INST   = @ENT_NR_INST       ,
          @ENT_NR_AGEN   = @ENT_NR_AGEN       ,
          @ENT_DT_MVTO   = @DT_ATUAL          , 
          @ENT_NM_WS     = @DS_URLWS          ,
          @ENT_NM_METODO = @DS_METODO         ,
          @ENT_NR_IP     = @DS_URLBAS         ,
          @ENT_TP_REQUIS = 'S'                ,
          @ENT_DS_REQUIS = @ENT_DS_XML        ,
          @ENT_DS_RETORN = @RET_DS_XML        ,
          @ENT_DS_ERRO   = @RET_DS_ERRO       ,
          @ENT_DS_COMENT = 'Envio realizado pela rotina de consumo de webservices.',
          @ENT_CD_OPESIS = @ENT_CD_OPESIS     ,
          @ENT_ID_RESULT = 'N'

        RETURN @RET_ID_STATUS
      END
    END -- IF UPPER(@DS_METODO) = 'POST'
  END TRY
  BEGIN CATCH
    SELECT @RET_ID_STATUS = -10
    SELECT @RET_CD_ERRO   = ERROR_NUMBER()
    SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

    RETURN @RET_ID_STATUS
  END CATCH
  BEGIN TRY
    /*==================================================================*/
    /* RESULT FINAL                                                     */
    /*==================================================================*/
    SELECT @RESPONSE_BODY = ''
    SELECT
      @RESPONSE_BODY = @RESPONSE_BODY + RESPONSE_BODY
    FROM
      #TB210501020_RESPONSE

    /* Trata formato do retorno do serviço */
    IF CHARINDEX('XML', UPPER(@DS_FMTRSP), 1) > 0
    BEGIN
      SELECT @RESP_BODY_XML = CONVERT(XML, REPLACE(@RESPONSE_BODY, '<?xml version="1.0" encoding="utf-8"?>', ''))
      SELECT @RET_DS_XML = CONVERT(VARCHAR(MAX), (
        SELECT
          @RESPONSE_HEADER                 RESPONSE_HEADER,
          @RESP_BODY_XML                   RESPONSE_BODY  ,
          CONVERT(VARCHAR(5), @HTTPSTATUS) HTTP_CODE
        FOR XML PATH ('RESPONSE'), TYPE
      ))
    END
    ELSE
    BEGIN
      SELECT @RET_DS_XML = CONVERT(VARCHAR(MAX), (
      SELECT
        @RESPONSE_HEADER                 RESPONSE_HEADER,
        @RESPONSE_BODY                   RESPONSE_BODY  ,
        CONVERT(VARCHAR(5), @HTTPSTATUS) HTTP_CODE
      FOR XML PATH ('RESPONSE'), TYPE
      ))
    END

    SELECT @RET_ID_STATUS = 0
    SELECT @RET_CD_ERRO   = NULL
    SELECT @RET_DS_ERRO   = NULL

    /* GUID de controle */
    SELECT 
      @DS_GUID  = NEWID(),
      @DT_ATUAL = CONVERT(VARCHAR(8), GETDATE(), 112)
    /* Monta log */
    EXEC dbo.P040000990
      @ENT_NR_VRS    = '1'                ,       
      @ENT_ID_GUID   = @DS_GUID           , 
      @ENT_NR_INST   = @ENT_NR_INST       ,
      @ENT_NR_AGEN   = @ENT_NR_AGEN       ,
      @ENT_DT_MVTO   = @DT_ATUAL          , 
      @ENT_NM_WS     = @DS_URLWS          ,
      @ENT_NM_METODO = @DS_METODO         ,
      @ENT_NR_IP     = @DS_URLBAS         ,
      @ENT_TP_REQUIS = 'S'                ,
      @ENT_DS_REQUIS = @ENT_DS_XML        ,
      @ENT_DS_RETORN = @RET_DS_XML        ,
      @ENT_DS_ERRO   = @RET_DS_ERRO       ,
      @ENT_DS_COMENT = 'Envio realizado pela rotina de consumo de webservices.',
      @ENT_CD_OPESIS = @ENT_CD_OPESIS     ,
      @ENT_ID_RESULT = 'N'

    RETURN @RET_ID_STATUS
  END TRY
  BEGIN CATCH
    SELECT @RET_ID_STATUS = -999
    SELECT @RET_CD_ERRO   = ERROR_NUMBER()
    SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

    RETURN @RET_ID_STATUS
  END CATCH
END TRY
BEGIN CATCH
  SELECT @RET_ID_STATUS = -9999
  SELECT @RET_CD_ERRO   = ERROR_NUMBER()
  SELECT @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

  RETURN @RET_ID_STATUS
END CATCH

GO
