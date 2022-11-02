USE SFINANCEEM
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.P040100021'))
  DROP PROCEDURE dbo.P040100021
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

CREATE PROCEDURE dbo.P040100021
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  :: EMPRESA    : Sinqia                                                       ::
  :: SISTEMA    : SQ Crédito                                                   ::
  :: MÓDULO     : Integração SQ Crédito com SGR de BH                          ::
  :: UTILIZ. POR: Telas do sistema de SQ Crédito                               ::
  :: OBSERVAÇÃO : Procedure chamada pelo SQ Crédito, que por sua vez chama a   ::
  ::            : proc. do SGR para integrar com módulo de recebíveis de BH.   ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR:                                                              ::
  :: DATA       :                                              VERSÃO SP:      ::
  :: ALTERAÇÃO  :                                                              ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR: Matheus Reynard                                              ::
  :: DATA       : 13/11/2021                                   VERSÃO SP:    3 ::
  :: ALTERAÇÃO  : Adicionado select do código cedente a partir do código       ::
  ::              cliente.                                                     ::
  ::              Jira: SD-29325 - Integração Crédito -> SQ Recebiveis (BH)    ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR: Matheus Reynard                                              ::
  :: DATA       : 26/10/2021                                   VERSÃO SP:    2 ::
  :: ALTERAÇÃO  : Alterado o número de contrato fixo para variável na busca de ::
  ::              instituição a partir do número de contrato informado         ::
  ::              Jira: SD-29325 - Integração Crédito -> SQ Recebiveis (BH)    ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR: Matheus Reynard                                              ::
  :: DATA       : 25/08/2021                                   VERSÃO SP:    1 ::
  :: ALTERAÇÃO  : Primeira versão                                              ::
  ::              Jira: SD-29325 - Integração Crédito -> SQ Recebiveis (BH)    ::
  :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/*-------------------------------------------------------------------------------
  DESCRIÇÃO DA FUNCIONALIDADE:

  Chama a procedure "sgrstpincluircontratomae" para incluir um contrato no SGR,
  caso este esteja parametrizado para relacionar o contrato do Crédito com o SGR. 
  Caso negativo, a "sgrstpincluircontratomae" é chamada mas como está parametrizado
  para não incluir no SGR, a chamada "sgrstpincluircontratomae" não faz nada.

---------------------------------------------------------------------------------*/
  @ENT_NR_VRS       VARCHAR(4)            , /* Número da versão da SP            */
  @ENT_NR_CONTRA    NUMERIC(18,0)         , /* Número do contrato                */
  @RET_ID_STATUS    NUMERIC(5)      OUTPUT, /* Variável de retorno               */
  @RET_CD_ERRO      NUMERIC(9)      OUTPUT, /* Código de erro do SQL             */
  @RET_DS_ERRO      VARCHAR(255)    OUTPUT  /* Mensagem nativa de erro           */
  WITH ENCRYPTION
AS

/*--------------------------------------------------------------------------*/
/* Verifica se a versão do Módulo é diferente da versão da Stored Procedure */
/*--------------------------------------------------------------------------*/
DECLARE @LOC_NR_RTCODE INTEGER
EXECUTE @LOC_NR_RTCODE = SP_CD0100002 @ENT_NR_VRS, '1', 'P040100021'
IF @LOC_NR_RTCODE = 99999 RETURN 99999

/*--------------------------------------------------------------------------*/
/* Tabela temporária de mensagens de retorno                                */
/*--------------------------------------------------------------------------*/
CREATE TABLE #TBERROR_MSGS (
  TP_MSG       CHAR(1)      , /* E = Erro; I = Informação; O = Ok; A = Aviso. */
  DS_MSG       VARCHAR(MAX)
)

/*--------------------------*/
/* Declaração das variáveis-*/
/*--------------------------*/
DECLARE
  @CD_CLIENT                NUMERIC(11)  ,
  @CD_CEDNTE                NUMERIC(11)  ,
  @EMP_COD_TEMP             NVARCHAR(5)  ,
  @CNTRAT_NUM_PREFIXO       NVARCHAR(18) ,
  @ID_ERRO                  CHAR(1)      ,
  @EMP_COD                  NUMERIC(5)   , 
  @CNTRAT_NUM               NUMERIC(13)  , 
  @CEDNTE_CEDN              NUMERIC(15)  , 
  @CTLCART_COD              NUMERIC(4)   ,
  @CNTRAT_ORIG              NUMERIC(3)   ,
  @CNTRAT_DAT_INI           DATETIME     ,
  @CNTRAT_VLR               NUMERIC(15,2),
  @CNTRAT_PCT_GARANTIA      NUMERIC(5,2) ,
  @CNTRAT_ABV_EMPRESA       VARCHAR(60)  ,
  @CNTRAT_DAT_VALIDADE      DATETIME     ,                                         
  @CNTRAT_NUM_EXTERNO       CHAR(20)     ,
  @CNTRAT_STATUS            CHAR(1)   

/*-------------------------------------------------------------------------------*/
/* Críticas das informações de entrada                                           */
/*-------------------------------------------------------------------------------*/
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
    'Número do contrato obrigatório. Valor informado: [' + COALESCE(CONVERT(VARCHAR, @ENT_NR_CONTRA), 'NULL') + '].'
  WHERE
    @ENT_NR_CONTRA IS NULL

  IF EXISTS(SELECT DS_MSG FROM #TBERROR_MSGS WHERE TP_MSG = 'E')
  BEGIN
    SELECT
      @RET_ID_STATUS = -10,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = DS_MSG FROM #TBERROR_MSGS WHERE TP_MSG = 'E'
      RETURN
  END
END TRY
BEGIN CATCH
  SELECT
    @RET_ID_STATUS = -20,
    @RET_CD_ERRO   = ERROR_NUMBER(),
    @RET_DS_ERRO   = 'Houve um erro ao validar os campos obrigatórios. Erro: ' + ERROR_MESSAGE()
    RETURN
END CATCH
BEGIN TRY 

  /*-------------------------------------------------------------------------------------------------------------------*/
  /*-- USA A VARIÁVEL TEMPORÁRIA EMP_COD_TEMP PARA RECEBER OS 4 PRIMEIROS NÚMEROS DA INSTITUIÇÃO NO FORMATO NVARCHAR --*/
  /*-------------------------------------------------------------------------------------------------------------------*/

  SELECT
    @EMP_COD        = EM01_NR_INST
  FROM
    EM01
  WHERE
    EM01_NR_CONTRA  = @ENT_NR_CONTRA

  SET @EMP_COD_TEMP = (SELECT LEFT(CAST(@EMP_COD AS NUMERIC), 4)) 

  /*-----------------------------------------------------------------------------------------------------------------------*/
  /*-- USA A VARIÁVEL TEMPORÁRIA @CNTRAT_NUM_PREFIXO PARA RECEBER OS 9 PRIMEIROS NÚMEROS DO CONTRATO NO FORMATO NVARCHAR --*/
  /*-----------------------------------------------------------------------------------------------------------------------*/

  SELECT
    @CNTRAT_NUM           = @ENT_NR_CONTRA
  FROM
    EM01
  WHERE
    EM01_NR_CONTRA        = @ENT_NR_CONTRA

  SET @CNTRAT_NUM_PREFIXO = (SELECT LEFT(CAST(@CNTRAT_NUM AS NUMERIC), 9))

  /*---------------------------------------------------------------*/
  /*-- PEGA OS 18 PRIMEIROS CARACTERES DO CAMPO CL01_NM_CLIENT ----*/
  /*---------------------------------------------------------------*/

  SELECT
    @CNTRAT_ABV_EMPRESA         = CL01_NM_CLIENT
  FROM 
    CL01 INNER JOIN EM01 ON (
        EM01_CD_CLIENT          = CL01_NR_CLIENT
    AND EM01_NR_INST            = CL01_NR_INST
    )
  WHERE
    EM01_NR_CONTRA              = @ENT_NR_CONTRA

  SET @CNTRAT_ABV_EMPRESA       = SUBSTRING(@CNTRAT_ABV_EMPRESA, 1, 18) 

  /*---------------------------------------------------------------*/
  /*-- PEGA O CÓDIGO DO CEDENTE A PARTIR DO CÓDIGO DO CLIENTE --- -*/
  /* --------------------------------------------------------------*/
    /* Para que o processo seja utilizado é necessário criar um Sinônimo apontando para a base do 
     SGR conforme exemplo abaixo:

     USE SFINANCEEM
     DROP SYNONYM SGRVIWCEDENTECLIENTE_SYNONYM
     CREATE SYNONYM SGRVIWCEDENTECLIENTE_SYNONYM FOR FINSGRDBS..SgrViwCedenteCliente
  */

  IF NOT EXISTS (SELECT * FROM SFINANCEEM..sysobjects WHERE name = 'SGRVIWCEDENTECLIENTE_SYNONYM')
  BEGIN
    SELECT 
      @RET_ID_STATUS = - 30,
      @RET_CD_ERRO   = - 30,
      @RET_DS_ERRO   = 'Não foi encontrado o synonym SGRVIWCEDENTECLIENTE_SYNONYM na base especificada.'
      RETURN
  END

  SELECT
    @CD_CLIENT        =  EM01_CD_CLIENT
  FROM
    EM01
  WHERE
    EM01_NR_CONTRA    =  @ENT_NR_CONTRA
    
  SELECT
    @CD_CEDNTE        =  MAX(CODIGO_CEDENTE)
  FROM
    SGRVIWCEDENTECLIENTE_SYNONYM
  WHERE
    CODIGO_CLIENTE    = @CD_CLIENT

  /*-------------------------------------------------------------------------------*/
  /* Faz o select para chamar a procedure "sgrstpincluircontratomae" do SGR        */
  /*-------------------------------------------------------------------------------*/
  SELECT
    @EMP_COD             = @EMP_COD_TEMP,                                           /* Código da Empresa */
    @CNTRAT_NUM          = @CNTRAT_NUM_PREFIXO,                                     /* Número do Contrato */ -- NUM CONTRATO PREFIXO 
    @CEDNTE_CEDN         = @CD_CEDNTE,                                              /* Código do Cedente cadastrado no SGR */
    @CTLCART_COD         = 41,                                                      /* Carteira - Fixo 41 */
    @CNTRAT_ORIG         = 1,                                                       /* Origem do Contrato - Geralmente 1 */
    @CNTRAT_DAT_INI      = CONVERT(DATETIME, CAST(EM01_DT_CONTRA AS VARCHAR), 101), /* Data Início do Contrato */
    @CNTRAT_VLR          = EM01_VL_CONTRA,                                          /* Valor do Contrato */
    @CNTRAT_PCT_GARANTIA = GA20_PC_GARANT,                                          /* % exigido para garantia */
    @CNTRAT_ABV_EMPRESA  = @CNTRAT_ABV_EMPRESA,                                     /* Nome do cliente abreviado - com até 18 caracteres */
    @CNTRAT_DAT_VALIDADE = CONVERT(DATETIME, CAST(EM01_DT_VCTULT AS VARCHAR), 101), /* Data de vencimento do contrato */
    @CNTRAT_NUM_EXTERNO  = @ENT_NR_CONTRA,                                          /* Número do contrato externo */ -- NUM CONTRATO INTEIRO 
    @CNTRAT_STATUS       = 'A'                                                      /* Status - Fixo A */
  FROM 
    EM01 INNER JOIN GA20 ON (
        EM01_NR_CONTRA             = GA20_NR_CONTRA
    AND EM01_CD_CLIENT             = GA20_CD_CLIENT 
    AND EM01_NR_INST               = GA20_NR_INST
    AND EM01_NR_AGEN               = GA20_NR_AGEN
    ) INNER JOIN CL01 ON (
        EM01_CD_CLIENT             = CL01_NR_CLIENT
    AND EM01_NR_INST               = CL01_NR_INST
    ) INNER JOIN CD00 ON (
        EM01_NR_INST               = CD00_NR_INST
    )
  WHERE
      EM01_NR_CONTRA               = @ENT_NR_CONTRA
  --AND GA20_CD_SIST                 = 4
  AND COALESCE( CD00_ID_INTSGR, 2) = 1  

  IF (@EMP_COD IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -40,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Código da Empresa'
      RETURN
  END
  ELSE IF (@CNTRAT_NUM IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -50,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Número do Contrato'
      RETURN
  END
  ELSE IF (@CEDNTE_CEDN IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -60,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Código do Cedente cadastrado no SGR'
      RETURN
  END
  ELSE IF (@CTLCART_COD IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -70,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Carteira '
      RETURN
  END
  ELSE IF (@CNTRAT_ORIG IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -80,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Origem do Contrato '
      RETURN
  END
  ELSE IF (@CNTRAT_DAT_INI IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -90,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Data Início do Contrato'
      RETURN
  END
  ELSE IF (@CNTRAT_VLR IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -100,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Valor do Contrato'
      RETURN
  END
  ELSE IF (@CNTRAT_PCT_GARANTIA IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -110,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: % exigido para garantia'
      RETURN
  END
  ELSE IF (@CNTRAT_ABV_EMPRESA IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -120,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Nome do cliente abreviado '
      RETURN
  END
  ELSE IF (@CNTRAT_DAT_VALIDADE IS NULL)
  BEGIN
    SELECT
      @RET_ID_STATUS = -130,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'O campo não pode ser NULL. Campo: Data de vencimento do contrato'
      RETURN
  END

  /*-------------------------------------------------------------------------------------------------*/
  /* Aqui chama a procedure "sgrstpincluircontratomae" do SGR passando como parametro o select acima */
  /* ------------------------------------------------------------------------------------------------*/
    /* Para que o processo seja utilizado é necessário criar um Sinônimo apontando para a base do 
     SGR conforme exemplo abaixo:

     USE SFINANCEEM
     DROP SYNONYM SGRSTPINCLUIRCONTRATOMAE_SYNONYM
     CREATE SYNONYM SGRSTPINCLUIRCONTRATOMAE_SYNONYM FOR FINSGRDBS..dbo.sgrstpincluircontratomae
  */
  
  IF NOT EXISTS (SELECT * FROM SFINANCEEM..sysobjects WHERE name = 'SGRSTPINCLUIRCONTRATOMAE_SYNONYM')
  BEGIN
    SELECT 
      @RET_ID_STATUS = -140,
      @RET_CD_ERRO   = ERROR_NUMBER(),
      @RET_DS_ERRO   = 'Não foi encontrada o synonym SGRSTPINCLUIRCONTRATOMAE_SYNONYM na base especificada.'
      RETURN
  END

  EXEC SFINANCEEM..sgrstpincluircontratomae
    @EMP_COD             = @EMP_COD            ,
    @CNTRAT_NUM          = @CNTRAT_NUM         ,
    @CEDNTE_CEDN         = @CEDNTE_CEDN        ,
    @CTLCART_COD         = @CTLCART_COD        ,
    @CNTRAT_ORIG         = @CNTRAT_ORIG        ,
    @CNTRAT_DAT_INI      = @CNTRAT_DAT_INI     ,
    @CNTRAT_VLR          = @CNTRAT_VLR         ,
    @CNTRAT_PCT_GARANTIA = @CNTRAT_PCT_GARANTIA, 
    @CNTRAT_ABV_EMPRESA  = @CNTRAT_ABV_EMPRESA ,
    @CNTRAT_DAT_VALIDADE = @CNTRAT_DAT_VALIDADE,
    @CNTRAT_NUM_EXTERNO  = @CNTRAT_NUM_EXTERNO ,
    @CNTRAT_STATUS       = @CNTRAT_STATUS

  SELECT
    @RET_ID_STATUS = 0,
    @RET_CD_ERRO   = 0,
    @RET_DS_ERRO   = 'Sucesso!!'

END TRY
BEGIN CATCH

  SELECT
    @RET_ID_STATUS = -150,
    @RET_CD_ERRO   = ERROR_NUMBER(),
    @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + ') Erro ao executar a procedure: ' + ERROR_MESSAGE()
    RETURN

END CATCH

GO