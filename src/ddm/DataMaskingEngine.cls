/*------------------------------------------------------------------------
    File        : DataMaskingEngine.cls
    Purpose     : Core engine for dynamic data masking operations
    Syntax      : 
    Description : Main class that orchestrates data masking operations
    Author(s)   : Progress Developer
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING src.config.MaskingConfig.
USING src.utils.MaskingAlgorithms.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS src.ddm.DataMaskingEngine:

    DEFINE PRIVATE VARIABLE oConfig AS MaskingConfig NO-UNDO.
    DEFINE PRIVATE VARIABLE oAlgorithms AS MaskingAlgorithms NO-UNDO.
    
    CONSTRUCTOR PUBLIC DataMaskingEngine():
        oConfig = NEW MaskingConfig().
        oAlgorithms = NEW MaskingAlgorithms().
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Add a masking rule for a specific table and field
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID AddRule(INPUT pcTable AS CHARACTER, 
                              INPUT pcField AS CHARACTER, 
                              INPUT pcMaskType AS CHARACTER):
        
        oConfig:AddMaskingRule(pcTable, pcField, pcMaskType).
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to add masking rule for &1.&2: &3", 
                          pcTable, pcField, oError:GetMessage(1))).
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Apply masking to an entire table
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL MaskTable(INPUT pcTable AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO INITIAL TRUE.
        
        /* Validate table exists and has masking rules */
        IF NOT oConfig:HasMaskingRules(pcTable) THEN DO:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("No masking rules defined for table: &1", pcTable)).
        END.
        
        /* Apply masking rules */
        lSuccess = oConfig:ApplyTableMasking(pcTable).
        
        RETURN lSuccess.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to mask table &1: &2", 
                          pcTable, oError:GetMessage(1))).
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Mask a specific field value
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER MaskValue(INPUT pcValue AS CHARACTER, 
                                     INPUT pcMaskType AS CHARACTER):
        
        DEFINE VARIABLE cMaskedValue AS CHARACTER NO-UNDO.
        
        CASE pcMaskType:
            WHEN "SSN_MASK" THEN
                cMaskedValue = oAlgorithms:MaskSSN(pcValue).
            WHEN "CREDIT_CARD_MASK" THEN
                cMaskedValue = oAlgorithms:MaskCreditCard(pcValue).
            WHEN "EMAIL_MASK" THEN
                cMaskedValue = oAlgorithms:MaskEmail(pcValue).
            WHEN "PHONE_MASK" THEN
                cMaskedValue = oAlgorithms:MaskPhone(pcValue).
            OTHERWISE
                cMaskedValue = oAlgorithms:GenericMask(pcValue).
        END CASE.
        
        RETURN cMaskedValue.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to mask value with type &1: &2", 
                          pcMaskType, oError:GetMessage(1))).
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Load masking configuration from file
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID LoadConfiguration(INPUT pcConfigFile AS CHARACTER):
        
        oConfig:LoadFromFile(pcConfigFile).
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to load configuration from &1: &2", 
                          pcConfigFile, oError:GetMessage(1))).
        END CATCH.
    END METHOD.

END CLASS.
