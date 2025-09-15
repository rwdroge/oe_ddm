/*------------------------------------------------------------------------
    File        : MaskingConfig.cls
    Purpose     : Configuration management for data masking rules
    Syntax      : 
    Description : Handles loading, storing and applying masking configurations
    Author(s)   : Progress Developer
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS src.config.MaskingConfig:

    DEFINE PRIVATE TEMP-TABLE ttMaskingRules NO-UNDO
        FIELD cTable AS CHARACTER
        FIELD cField AS CHARACTER
        FIELD cMaskType AS CHARACTER
        FIELD lPreserveFormat AS LOGICAL
        FIELD cCustomPattern AS CHARACTER
        INDEX idxTableField IS PRIMARY cTable cField.

    /*------------------------------------------------------------------------------
     Purpose: Add a masking rule
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID AddMaskingRule(INPUT pcTable AS CHARACTER,
                                     INPUT pcField AS CHARACTER,
                                     INPUT pcMaskType AS CHARACTER):
        
        CREATE ttMaskingRules.
        ASSIGN
            ttMaskingRules.cTable = pcTable
            ttMaskingRules.cField = pcField
            ttMaskingRules.cMaskType = pcMaskType
            ttMaskingRules.lPreserveFormat = TRUE.
            
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Check if table has masking rules defined
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL HasMaskingRules(INPUT pcTable AS CHARACTER):
        
        FIND FIRST ttMaskingRules WHERE ttMaskingRules.cTable = pcTable NO-ERROR.
        RETURN AVAILABLE ttMaskingRules.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Apply masking to entire table
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL ApplyTableMasking(INPUT pcTable AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO INITIAL TRUE.
        
        /* Implementation would iterate through table records */
        /* and apply field-level masking based on rules */
        
        FOR EACH ttMaskingRules WHERE ttMaskingRules.cTable = pcTable:
            /* Log masking operation */
            MESSAGE SUBSTITUTE("Applying &1 masking to &2.&3",
                             ttMaskingRules.cMaskType,
                             ttMaskingRules.cTable,
                             ttMaskingRules.cField).
        END.
        
        RETURN lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Load configuration from JSON file
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC VOID LoadFromFile(INPUT pcConfigFile AS CHARACTER):
        
        DEFINE VARIABLE oParser AS JsonParser NO-UNDO.
        DEFINE VARIABLE oJsonObject AS JsonObject NO-UNDO.
        
        oParser = NEW JsonParser().
        oJsonObject = CAST(oParser:ParseFile(pcConfigFile), JsonObject).
        
        /* Parse JSON configuration and populate temp-table */
        ParseJsonConfig(oJsonObject).
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to load config file &1: &2",
                          pcConfigFile, oError:GetMessage(1))).
        END CATCH.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Parse JSON configuration object
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID ParseJsonConfig(INPUT oJsonObject AS JsonObject):
        
        DEFINE VARIABLE oTables AS JsonObject NO-UNDO.
        DEFINE VARIABLE oTable AS JsonObject NO-UNDO.
        DEFINE VARIABLE oFields AS JsonObject NO-UNDO.
        DEFINE VARIABLE oField AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableNames AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldNames AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iTable AS INTEGER NO-UNDO.
        DEFINE VARIABLE iField AS INTEGER NO-UNDO.
        
        IF oJsonObject:Has("tables") THEN DO:
            oTables = oJsonObject:GetJsonObject("tables").
            cTableNames = oTables:GetNames().
            
            DO iTable = 1 TO NUM-ENTRIES(cTableNames):
                oTable = oTables:GetJsonObject(ENTRY(iTable, cTableNames)).
                
                IF oTable:Has("fields") THEN DO:
                    oFields = oTable:GetJsonObject("fields").
                    cFieldNames = oFields:GetNames().
                    
                    DO iField = 1 TO NUM-ENTRIES(cFieldNames):
                        oField = oFields:GetJsonObject(ENTRY(iField, cFieldNames)).
                        
                        CREATE ttMaskingRules.
                        ASSIGN
                            ttMaskingRules.cTable = ENTRY(iTable, cTableNames)
                            ttMaskingRules.cField = ENTRY(iField, cFieldNames)
                            ttMaskingRules.cMaskType = oField:GetCharacter("maskType")
                            ttMaskingRules.lPreserveFormat = oField:GetLogical("preserveFormat") WHEN oField:Has("preserveFormat")
                            ttMaskingRules.cCustomPattern = oField:GetCharacter("customPattern") WHEN oField:Has("customPattern").
                    END.
                END.
            END.
        END.
        
    END METHOD.

END CLASS.
