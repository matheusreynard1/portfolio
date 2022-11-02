USE SFINANCE_GA
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id('dbo.P200090003'))
  DROP PROCEDURE dbo.P200090003
GO

SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO

CREATE PROCEDURE dbo.P200090003
/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
  :: EMPRESA    : Sinqia                                                       ::
  :: SISTEMA    : SQ Garantias (SQGA)                                          ::
  :: M�DULO     : Integra��o SQ Garantias com SGR de BH                        ::
  :: UTILIZ. POR: SQ Garantias e SGR (Sistema Gerenciador de Receb�veis)       ::
  :: OBSERVA��O : Procedure executada por JOB para atualizar a GA20 de acordo  :: 
  ::            : com view do SGR.                                             ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR:                                                              ::
  :: DATA       :                                              VERS�O SP:      ::
  :: ALTERA��O  :                                                              ::
  ::---------------------------------------------------------------------------::
  :: PROGRAMADOR: Matheus Reynard                                              ::
  :: DATA       : 27/08/2021                                   VERS�O SP:    1 ::
  :: ALTERA��O  : Primeira vers�o                                              ::
  ::              Jira: SD-29325 (SQCWB-18922)                                 ::
  :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
/*-------------------------------------------------------------------------------
  DESCRI��O DA FUNCIONALIDADE:

  Atualiza o saldo na GA20 de acordo com o saldo disponibilizado na view
  do Sistema Gerenciador de Receb�veis (SGR). � chamada por uma JOB do SQL
  Server Agent de hora em hora, no banco de dados do SQ Garantias.

---------------------------------------------------------------------------------*/
  @ENT_NR_VRS       VARCHAR(4)            , /* N�mero da vers�o da SP            */
  @ENT_CD_OPESIS    NUMERIC(9)            , /* Usu�rio que executou o processo   */
  @RET_ID_STATUS    NUMERIC(5)      OUTPUT, /* Vari�vel de retorno               */
  @RET_CD_ERRO      NUMERIC(9)      OUTPUT, /* C�digo de erro do SQL             */
  @RET_DS_ERRO      VARCHAR(255)    OUTPUT  /* Mensagem nativa de erro           */
  WITH ENCRYPTION
AS

/*--------------------------------------------------------------------------*/
/* Verifica se a vers�o do M�dulo � diferente da vers�o da Stored Procedure */
/*--------------------------------------------------------------------------*/
DECLARE @LOC_NR_RTCODE INTEGER
EXECUTE @LOC_NR_RTCODE = SP_CD0100002 @ENT_NR_VRS, '1', 'P200090003'
IF @LOC_NR_RTCODE = 99999 RETURN 99999

/*--------------------------------------------------------------------------*/
/* Tabela tempor�ria de mensagens de retorno                                */
/*--------------------------------------------------------------------------*/
CREATE TABLE #TBERROR_MSGS (
  TP_MSG       CHAR(1)      , /* E = Erro; I = Informa��o; O = Ok; A = Aviso. */
  DS_MSG       VARCHAR(MAX)
)

/*--------------------------------------------------------------------------*/
/* Declara��o de vari�veis                                                 */
/*--------------------------------------------------------------------------*/
DECLARE
  @ID_ERRO                  CHAR(1)      , 
  @CNTRAT_NUM_PREFIXO       NVARCHAR(18) ,
  @CNTRAT_NUM               NVARCHAR(18)

/*-------------------------------------------------------------------------------*/
/* Cr�ticas das informa��es de entrada                                           */
/*-------------------------------------------------------------------------------*/
BEGIN TRY
  INSERT INTO #TBERROR_MSGS (TP_MSG, DS_MSG)
  SELECT
    'E',
    'N�mero da vers�o da SP obrigat�rio. Valor informado: [' + COALESCE(CONVERT(VARCHAR, @ENT_NR_VRS), 'NULL') + '].'
  WHERE
    @ENT_NR_VRS IS NULL

  SELECT @ID_ERRO =
    CASE
      WHEN EXISTS (SELECT TOP 1 NULL FROM #TBERROR_MSGS WHERE TP_MSG = 'E')
        THEN 'S'
      ELSE 'N'
    END
END TRY
BEGIN CATCH
  SELECT
    @RET_ID_STATUS = -10,
    @RET_CD_ERRO   = ERROR_NUMBER(),
    @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

    RETURN
END CATCH

IF @ID_ERRO = 'N'
BEGIN
  BEGIN TRY 
    /*==========================================================================*/
    /*  Cria��o da transa��o                                                    */
    /*==========================================================================*/
    DECLARE @QT_TRINIC  NUMERIC(9)
    SELECT  @QT_TRINIC = @@TRANCOUNT

    IF @QT_TRINIC = 0
      BEGIN TRANSACTION TR_SP_P200090003
    ELSE
      SAVE TRANSACTION TR_SP_P200090003

    /* Para que o processo seja utilizado � necess�rio criar um Sin�nimo apontando para a base do 
     SGR conforme exemplo abaixo:

     DROP SYNONYM SCGVIWSGR_SYNONYM
     CREATE SYNONYM SCGVIWSGR_SYNONYM FOR TDS_FINSGRDBS08..SCGVIWSGR
     */
  
    /* VERIFICA SE A VIEW SCGVIWSGR EXISTE NA BASE TDS_FINSGRDBS08 */
    IF NOT EXISTS (SELECT * FROM TDS_FINSGRDBS08..sysobjects WHERE name = 'SCGVIWSGR')
    BEGIN
      SELECT @RET_ID_STATUS = - 20,
             @RET_CD_ERRO   = - 20,
             @RET_DS_ERRO   = 'N�o foi encontrada a view SCGVIWSGR na base especificada.'
      RETURN
    END  
    
    /* VERIFICA SE O SYNONYM SCGVIWSGR_SYNONYM EXISTE NA BASE SFINANCE_GA */
    IF NOT EXISTS (SELECT * FROM SFINANCE_GA..sysobjects WHERE name = 'SCGVIWSGR_SYNONYM')
    BEGIN
      SELECT @RET_ID_STATUS = - 30,
             @RET_CD_ERRO   = - 30,
             @RET_DS_ERRO   = 'N�o foi encontrada o synonym SCGVIWSGR_SYNONYM na base especificada.'
      RETURN
    END  

  /*-------------------------------------------------------------------------------*/
  /* ATUALIZA O SALDO DA GARANTIA NA GA20                                          */
  /*-------------------------------------------------------------------------------*/

    UPDATE GA20
      SET GA20_VL_BEM    = V.OPEVALORI,
          GA20_CD_OPESIS = @ENT_CD_OPESIS,
          GA20_DT_ATUSIS = GETDATE()
    FROM 
      GA20 INNER JOIN SCGVIWSGR_SYNONYM V ON (
            GA20_NR_INST                 = V.OPEINSTITUICAO
        AND GA20_NR_AGEN                 = V.OPECODAGN
        AND GA20_CD_CLIENT               = V.OPECODPES
        AND GA20_NR_CONTRA               = V.OPENUMEXTERNO         -- N�mero do contrato inteiro
        AND V.OPECOD                     = (SELECT LEFT(cast(GA20_NR_CONTRA as numeric), 9)) -- N�mero do contrato prefixo
        AND GA20_CD_SIST                 = 4
      ) INNER JOIN CD00 C ON (   
              C.CD00_NR_INST             = GA20_NR_INST  
      )
    WHERE
        GA20_VL_BEM                     <> V.OPEVALORI
        AND COALESCE( CD00_ID_INTSGR, 2) = 1

  /*-------------------------------------------------------------------------------*/
  /* ATUALIZA O SALDO DA GARANTIA NA GA03                                          */
  /*-------------------------------------------------------------------------------*/
    UPDATE GA03
      SET GA03_VL_GARANT = GA20_VL_BEM,
          GA03_CD_OPESIS = @ENT_CD_OPESIS,
          GA03_DT_ATUSIS = GETDATE()
    FROM 
      GA03 INNER JOIN GA20 ON (
            GA03_NR_INST                 = GA20_NR_INST
        AND GA03_NR_AGEN                 = GA20_NR_AGEN 
        AND GA03_CD_CLIENT               = GA20_CD_CLIENT
        AND GA03_NR_CONTRA               = GA20_NR_CONTRA
        AND GA03_NR_GARANT               = GA20_NR_GARANT
        AND GA03_CD_SIST                 = 4
      ) INNER JOIN CD00 C ON (   
              C.CD00_NR_INST             = GA03_NR_INST  
      )
    WHERE
        GA03_VL_GARANT                  <> GA20_VL_BEM
        AND COALESCE( CD00_ID_INTSGR, 2) = 1

    SELECT
      @RET_ID_STATUS                       = 0,
      @RET_CD_ERRO                         = 0,
      @RET_DS_ERRO                         = 'Sucesso!!'

  END TRY
  BEGIN CATCH
    /*========================================================================*/
    /*= Exce��o - Rollback de transa��o                                      =*/
    /*========================================================================*/
    IF @@TRANCOUNT > 0 AND (XACT_STATE() = 1 OR @QT_TRINIC = 0)
        ROLLBACK TRANSACTION TR_SP_P200090003
    /*------------------------------------------------------------------------*/
    SELECT @RET_ID_STATUS = -40, 
           @RET_CD_ERRO   = ERROR_NUMBER(), 
           @RET_DS_ERRO   = 'Erro ao fazer update na GA20: ' + ERROR_MESSAGE()
    RETURN
  END CATCH
  BEGIN TRY
    IF XACT_STATE() = 1 AND @QT_TRINIC = 0  /* EXISTE TRANSA��O E � A PRINCIPAL */
      COMMIT TRANSACTION TR_P200090003
    ELSE IF XACT_STATE() = - 1 AND @QT_TRINIC = 0  /* A TRANSA��O N�O � COMIT�VEL E � A PRINCIPAL */
      BEGIN
        ROLLBACK TRANSACTION TR_P200090003
        SELECT @RET_ID_STATUS = -50, 
               @RET_CD_ERRO   = ERROR_NUMBER(),
               @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): Erro ao comitar transa��o.'
              RETURN
      END
  END TRY
  BEGIN CATCH
    /*-----------------------------------------------------------------------------*/
    /* ROLLBACK DE TRANSA��O                                                       */
    /*-----------------------------------------------------------------------------*/
    IF XACT_STATE() <> 0  /* EXISTE TRANSA��O */
      IF (@QT_TRINIC = 0) OR (@QT_TRINIC > 0 AND XACT_STATE() = 1)   /* � A PRINCIPAL OU UM SAVE POINT COM TRANSA��O V�LIDA */
        ROLLBACK TRANSACTION TR_P200090003
    /*-----------------------------------------------------------------------------*/
    SELECT @RET_ID_STATUS = -60, 
           @RET_CD_ERRO   = ERROR_NUMBER(),
           @RET_DS_ERRO   = OBJECT_NAME(@@PROCID) + '(' + CONVERT(VARCHAR(5), @RET_ID_STATUS) + '): ' + ERROR_MESSAGE()

           RETURN
  END CATCH
END /* Fim do IF de ID Erro */

/*-------------------------------------------------------------------------------
  RESULT SET:                     
 
-------------------------------------------------------------------------------*/

GO