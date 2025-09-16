/*------------------------------------------------------------------------
    File        : MaskingApiHandler.cls
    Purpose     : REST API handler for Dynamic Data Masking operations
    Syntax      : 
    Description : PASOE WebHandler for DDM administration via REST API
    Author(s)   : Progress Developer
    Created     : 
    Notes       : Handles HTTP requests for masking operations
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Web.WebHandler.
USING OpenEdge.Net.HTTP.*.
USING OpenEdge.Web.IWebRequest.
USING OpenEdge.Web.WebResponse.
USING OpenEdge.Web.WebResponseWriter.
USING Progress.Json.ObjectModel.*.
USING ddm.DataAdminMaskingService.
USING OpenEdge.DataAdmin.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS webhandlers.MaskingApiHandler INHERITS WebHandler:

    DEFINE PRIVATE VARIABLE oMaskingService AS DataAdminMaskingService NO-UNDO.
    DEFINE PRIVATE VARIABLE cDatabaseName AS CHARACTER NO-UNDO INITIAL "sports2020".
    
    /* Response data structure for sub-methods */
    DEFINE TEMP-TABLE ttResponseData NO-UNDO
        FIELD statusCode AS INTEGER
        FIELD contentType AS CHARACTER
        FIELD jsonResponse AS CHARACTER
        FIELD success AS LOGICAL.

    /*------------------------------------------------------------------------------
     Purpose: Constructor - Initialize components
     Notes:   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC MaskingApiHandler():
        SUPER().
        oMaskingService = NEW DataAdminMaskingService(cDatabaseName).
        

    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Handle GET requests
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PROTECTED INTEGER HandleGet(INPUT poRequest AS IWebRequest):
        
        DEFINE VARIABLE cPath AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE oResponse AS WebResponse NO-UNDO.
        DEFINE VARIABLE oWriter AS WebResponseWriter NO-UNDO.
        DEFINE VARIABLE cResponseBody AS LONGCHAR NO-UNDO.

        oResponse = NEW WebResponse().
        oWriter = NEW WebResponseWriter(oResponse).
        cPath = poRequest:GetPathParameter("action").
        
        CASE cPath:
            WHEN "health" THEN DO:
                /* Health check endpoint */
                oJsonResponse = NEW JsonObject().
                oJsonResponse:Add("status", "healthy").
                oJsonResponse:Add("service", "Dynamic Data Masking API").
                oJsonResponse:Add("version", "1.0").
                oJsonResponse:Add("database", cDatabaseName).
                oJsonResponse:Add("timestamp", ISO-DATE(NOW)).
                cResponseBody = oJsonResponse:GetJsonText().
                oResponse:StatusCode = 200.
                oResponse:ContentType = "application/json".
                oResponse:ContentLength = LENGTH(cResponseBody).
            END.
            
            WHEN "ddm-config" THEN DO:
                /* Get DDM configuration for a specific field */
                HandleGetDDMConfig(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    oResponse:ContentLength = LENGTH(ttResponseData.jsonResponse).
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                    oResponse:ContentLength = LENGTH(cResponseBody).
                END.
            END.
            
            WHEN "mask-and-auth-tag" THEN DO:
                /* Get mask and authorization tag for a field */
                HandleGetMaskAndAuthTag(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    oResponse:ContentLength = LENGTH(ttResponseData.jsonResponse).
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                    oResponse:ContentLength = LENGTH(cResponseBody).
                END.
            END.
            
            WHEN "auth-tag-role" THEN DO:
                /* Get authorization tag and associated role */
                HandleGetAuthTagRole(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    oResponse:ContentLength = LENGTH(ttResponseData.jsonResponse).
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                    oResponse:ContentLength = LENGTH(cResponseBody).
                END.
            END.
            
            WHEN "user-role-grants" THEN DO:
                /* Get role grants for a user */
                HandleGetUserRoleGrants(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    oResponse:ContentLength = LENGTH(ttResponseData.jsonResponse).
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                    oResponse:ContentLength = LENGTH(cResponseBody).
                END.
            END.
            
            OTHERWISE DO:
                /* Invalid endpoint */
                oJsonResponse = NEW JsonObject().
                oJsonResponse:Add("error", "Endpoint not found").
                oJsonResponse:Add("path", cPath).
                cResponseBody = oJsonResponse:GetJsonText().
                oResponse:StatusCode = 404.
                oResponse:ContentType = "application/json".
            END.
        END CASE.
        
        oResponse:ContentLength = LENGTH(cResponseBody).
        oWriter:Write(cResponseBody).
        oWriter:Flush().
        oWriter:Close().
        
        RETURN oResponse:StatusCode.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle POST requests
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PROTECTED INTEGER HandlePost(INPUT poRequest AS IWebRequest):
        
        DEFINE VARIABLE cPath AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oResponse AS WebResponse NO-UNDO.
        DEFINE VARIABLE oWriter AS WebResponseWriter NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cResponseBody AS LONGCHAR NO-UNDO.
        
        oResponse = NEW WebResponse().
        oWriter = NEW WebResponseWriter(oResponse).
        cPath = poRequest:GetPathParameter("action").
        
        CASE cPath:
            WHEN "set-ddm-config" THEN DO:
                /* Set DDM configuration for a field */
                HandleSetDDMConfig(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "configure-field" THEN DO:
                /* Configure field masking */
                HandleConfigureField(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "unset-mask" THEN DO:
                /* Unset mask for a field */
                HandleUnsetMask(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "unset-auth-tag" THEN DO:
                /* Unset authorization tag for a field */
                HandleUnsetAuthTag(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "create-auth-tag" THEN DO:
                /* Create authorization tag */
                HandleCreateAuthTag(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "update-auth-tag" THEN DO:
                /* Update authorization tag */
                HandleUpdateAuthTag(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "create-role" THEN DO:
                /* Create role */
                HandleCreateRole(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "grant-role" THEN DO:
                /* Grant role to user */
                HandleGrantRole(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "create-user" THEN DO:
                /* Create user */
                HandleCreateUser(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            OTHERWISE DO:
                /* Invalid endpoint */
                oJsonResponse = NEW JsonObject().
                oJsonResponse:Add("error", "Endpoint not found").
                oJsonResponse:Add("path", cPath).
                cResponseBody = oJsonResponse:GetJsonText().
                oResponse:StatusCode = 404.
                oResponse:ContentType = "application/json".
            END.
        END CASE.
        
        oResponse:ContentLength = LENGTH(cResponseBody).
        oWriter:Write(cResponseBody).
        oWriter:Flush().
        oWriter:Close().
        
        RETURN oResponse:StatusCode.
        
        CATCH oError AS Progress.Lang.Error:
            RETURN HandleError(poRequest, oError).
        END CATCH.
        
        FINALLY:
            DELETE OBJECT oJsonResponse NO-ERROR.
            DELETE OBJECT oResponse NO-ERROR.
            DELETE OBJECT oWriter NO-ERROR.
        END FINALLY.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle DELETE requests
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PROTECTED INTEGER HandleDelete(INPUT poRequest AS IWebRequest):
        
        DEFINE VARIABLE cPath AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oResponse AS WebResponse NO-UNDO.
        DEFINE VARIABLE oWriter AS WebResponseWriter NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cResponseBody AS LONGCHAR NO-UNDO.
        
        oResponse = NEW WebResponse().
        oWriter = NEW WebResponseWriter(oResponse).
        cPath = poRequest:GetPathParameter("action").
        
        CASE cPath:
            WHEN "remove-ddm-config" THEN DO:
                /* Remove DDM configuration from a field */
                HandleRemoveDDMConfig(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "delete-auth-tag" THEN DO:
                /* Delete authorization tag */
                HandleDeleteAuthTag(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "delete-role" THEN DO:
                /* Delete role */
                HandleDeleteRole(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "delete-granted-role" THEN DO:
                /* Delete granted role */
                HandleDeleteGrantedRole(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            WHEN "delete-user" THEN DO:
                /* Delete user */
                HandleDeleteUser(poRequest, OUTPUT TABLE ttResponseData).
                FIND FIRST ttResponseData NO-ERROR.
                IF AVAILABLE ttResponseData THEN DO:
                    oResponse:StatusCode = ttResponseData.statusCode.
                    oResponse:ContentType = ttResponseData.contentType.
                    cResponseBody = ttResponseData.jsonResponse.
                END.
                ELSE DO:
                    oResponse:StatusCode = 500.
                    oResponse:ContentType = "application/json".
                    cResponseBody = '~{"error":"Internal server error","success":false}'.
                END.
            END.
            
            OTHERWISE DO:
                /* Invalid endpoint */
                oJsonResponse = NEW JsonObject().
                oJsonResponse:Add("error", "Endpoint not found").
                oJsonResponse:Add("path", cPath).
                cResponseBody = oJsonResponse:GetJsonText().
                oResponse:StatusCode = 404.
                oResponse:ContentType = "application/json".
            END.
        END CASE.
        
        oResponse:ContentLength = LENGTH(cResponseBody).
        oWriter:Write(cResponseBody).
        oWriter:Flush().
        oWriter:Close().
        
        RETURN oResponse:StatusCode.
        
        CATCH oError AS Progress.Lang.Error:
            RETURN HandleError(poRequest, oError).
        END CATCH.
        
        FINALLY:
            DELETE OBJECT oJsonResponse NO-ERROR.
            DELETE OBJECT oResponse NO-ERROR.
            DELETE OBJECT oWriter NO-ERROR.
        END FINALLY.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle set DDM configuration request
     Notes:   Uses the actual OpenEdge 12.8 DDM API
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleSetDDMConfig(INPUT poRequest AS IWebRequest,
                                           OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cMaskValue AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTag AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cTableName = oJsonRequest:GetCharacter("tableName").
        cFieldName = oJsonRequest:GetCharacter("fieldName").
        cMaskValue = oJsonRequest:GetCharacter("maskValue").
        cAuthTag = oJsonRequest:GetCharacter("authTag").
        
        /* Set DDM configuration using the actual OpenEdge API */
        lSuccess = oMaskingService:SetFieldDDMConfig(cTableName, cFieldName, cMaskValue, cAuthTag).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("fieldName", cFieldName).
        oJsonResponse:Add("maskValue", cMaskValue).
        oJsonResponse:Add("authTag", cAuthTag).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "DDM configuration set successfully" ELSE "Failed to set DDM configuration").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle configure field masking request
     Notes:   Uses high-level ConfigureFieldMasking method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleConfigureField(INPUT poRequest AS IWebRequest,
                                             OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cMaskingType AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cMaskingValue AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTag AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cTableName = oJsonRequest:GetCharacter("tableName").
        cFieldName = oJsonRequest:GetCharacter("fieldName").
        cMaskingType = oJsonRequest:GetCharacter("maskingType").
        cMaskingValue = oJsonRequest:GetCharacter("maskingValue").
        cAuthTag = oJsonRequest:GetCharacter("authTag").
        
        /* Configure field masking */
        lSuccess = oMaskingService:ConfigureFieldMasking(cTableName, cFieldName, cMaskingType, cMaskingValue, cAuthTag).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("fieldName", cFieldName).
        oJsonResponse:Add("maskingType", cMaskingType).
        oJsonResponse:Add("maskingValue", cMaskingValue).
        oJsonResponse:Add("authTag", cAuthTag).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Field masking configured successfully" ELSE "Failed to configure field masking").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle remove DDM configuration request
     Notes:   Uses RemoveFieldDDMConfig method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleRemoveDDMConfig(INPUT poRequest AS IWebRequest,
                                              OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cTableName = oJsonRequest:GetCharacter("tableName").
        cFieldName = oJsonRequest:GetCharacter("fieldName").
        
        /* Remove DDM configuration */
        lSuccess = oMaskingService:RemoveFieldDDMConfig(cTableName, cFieldName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("fieldName", cFieldName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "DDM configuration removed successfully" ELSE "Failed to remove DDM configuration").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle get DDM configuration request
     Notes:   Note: OpenEdge 12.8 doesn't provide direct getter, this is a placeholder
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetDDMConfig(INPUT poRequest AS IWebRequest,
                                           OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cUserName AS CHARACTER NO-UNDO.
        define variable cQueryString as character no-undo.
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Get parameters from query string */
        
        cQueryString = poRequest:GetContextValue("QUERY_STRING").
        DEFINE VARIABLE cPair       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE ix          AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cKey        AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cValue      AS CHARACTER NO-UNDO. 


      REPEAT ix = 1 TO NUM-ENTRIES(cQueryString,'&'):
          cPair = ENTRY(ix,cQueryString,'&').
          cKey = ENTRY(1,cPair,'=').
          cValue = ENTRY(2,cPair,'=').
        
          if cKey = "tableName" 
          then 
            cTableName = cValue.
          else if cKey = "fieldName" 
          then 
            cFieldName = cValue.
          else if cKey = "userName" 
          then 
            cUserName = cValue.
        end.
        IF cTableName = "" OR cTableName = ? OR cFieldName = "" OR cFieldName = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "tableName and fieldName parameters required").
            oJsonResponse:Add("success", FALSE).
            
            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.
        
        /* Build response - Note: Actual implementation would need field permission queries */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("fieldName", cFieldName).
        oJsonResponse:Add("message", "DDM configuration retrieval not directly supported by OpenEdge 12.8 API. Use field permissions or DataAdmin queries.").
        oJsonResponse:Add("success", FALSE).
        
        ttResponseData.statusCode = 501. /* Not Implemented */
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = FALSE.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle get mask and authorization tag for field request
     Notes:   Uses GetMaskAndAuthTagForField method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetMaskAndAuthTag(INPUT poRequest AS IWebRequest,
                                                OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cUserName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cQueryString AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Get parameters from query string */
        cQueryString = poRequest:GetContextValue("QUERY_STRING").
        DEFINE VARIABLE cPair AS CHARACTER NO-UNDO.
        DEFINE VARIABLE ix AS INTEGER NO-UNDO.
        DEFINE VARIABLE cKey AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cValue AS CHARACTER NO-UNDO.

        REPEAT ix = 1 TO NUM-ENTRIES(cQueryString,'&'):
            cPair = ENTRY(ix,cQueryString,'&').
            cKey = ENTRY(1,cPair,'=').
            cValue = ENTRY(2,cPair,'=').
            
            IF cKey = "tableName" THEN 
                cTableName = cValue.
            ELSE IF cKey = "fieldName" THEN 
                cFieldName = cValue.
            ELSE IF cKey = "userName" THEN 
                cUserName = cValue.
        END.
        
        IF cTableName = "" OR cTableName = ? OR cFieldName = "" OR cFieldName = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "tableName and fieldName parameters required").
            oJsonResponse:Add("success", FALSE).
            
            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.
        
        /* Get mask and auth tag information */
        cResult = oMaskingService:GetMaskAndAuthTagForField(cTableName, cFieldName, cUserName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("fieldName", cFieldName).
        oJsonResponse:Add("userName", cUserName).
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", TRUE).
        
        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = TRUE.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle get authorization tag and role request
     Notes:   Uses GetAuthTagAndRole method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetAuthTagRole(INPUT poRequest AS IWebRequest,
                                             OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cDomainName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTagName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cQueryString AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Get parameters from query string */
        cQueryString = poRequest:GetContextValue("QUERY_STRING").
        DEFINE VARIABLE cPair AS CHARACTER NO-UNDO.
        DEFINE VARIABLE ix AS INTEGER NO-UNDO.
        DEFINE VARIABLE cKey AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cValue AS CHARACTER NO-UNDO.

        REPEAT ix = 1 TO NUM-ENTRIES(cQueryString,'&'):
            cPair = ENTRY(ix,cQueryString,'&').
            cKey = ENTRY(1,cPair,'=').
            cValue = ENTRY(2,cPair,'=').
            
            IF cKey = "domainName" THEN 
                cDomainName = cValue.
            ELSE IF cKey = "authTagName" THEN 
                cAuthTagName = cValue.
        END.
        
        IF cDomainName = "" OR cDomainName = ? OR cAuthTagName = "" OR cAuthTagName = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "domainName and authTagName parameters required").
            oJsonResponse:Add("success", FALSE).
            
            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.
        
        /* Get auth tag and role information */
        cResult = oMaskingService:GetAuthTagAndRole(cDomainName, cAuthTagName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("domainName", cDomainName).
        oJsonResponse:Add("authTagName", cAuthTagName).
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", TRUE).
        
        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = TRUE.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle get user role grants request
     Notes:   Uses GetRoleGrantsForUser method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetUserRoleGrants(INPUT poRequest AS IWebRequest,
                                                OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cUserName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cQueryString AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Get parameters from query string */
        cQueryString = poRequest:GetContextValue("QUERY_STRING").
        DEFINE VARIABLE cPair AS CHARACTER NO-UNDO.
        DEFINE VARIABLE ix AS INTEGER NO-UNDO.
        DEFINE VARIABLE cKey AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cValue AS CHARACTER NO-UNDO.

        REPEAT ix = 1 TO NUM-ENTRIES(cQueryString,'&'):
            cPair = ENTRY(ix,cQueryString,'&').
            cKey = ENTRY(1,cPair,'=').
            cValue = ENTRY(2,cPair,'=').
            
            IF cKey = "userName" THEN 
                cUserName = cValue.
        END.
        
        IF cUserName = "" OR cUserName = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "userName parameter required").
            oJsonResponse:Add("success", FALSE).
            
            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.
        
        /* Get user role grants */
        cResult = oMaskingService:GetRoleGrantsForUser(cUserName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("userName", cUserName).
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", TRUE).
        
        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = TRUE.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle unset mask request
     Notes:   Uses UnsetMaskForField method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleUnsetMask(INPUT poRequest AS IWebRequest,
                                        OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cTableName = oJsonRequest:GetCharacter("tableName").
        cFieldName = oJsonRequest:GetCharacter("fieldName").
        
        /* Unset mask */
        lSuccess = oMaskingService:UnsetMaskForField(cTableName, cFieldName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("fieldName", cFieldName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Mask unset successfully" ELSE "Failed to unset mask").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle unset authorization tag request
     Notes:   Uses UnsetAuthTagForField method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleUnsetAuthTag(INPUT poRequest AS IWebRequest,
                                           OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cTableName = oJsonRequest:GetCharacter("tableName").
        cFieldName = oJsonRequest:GetCharacter("fieldName").
        
        /* Unset authorization tag */
        lSuccess = oMaskingService:UnsetAuthTagForField(cTableName, cFieldName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("fieldName", cFieldName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Authorization tag unset successfully" ELSE "Failed to unset authorization tag").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle create authorization tag request
     Notes:   Uses CreateAuthorizationTag method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleCreateAuthTag(INPUT poRequest AS IWebRequest,
                                            OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cDomainName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTagName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cDomainName = oJsonRequest:GetCharacter("domainName").
        cAuthTagName = oJsonRequest:GetCharacter("authTagName").
        
        /* Create authorization tag */
        lSuccess = oMaskingService:CreateAuthorizationTag(cDomainName, cAuthTagName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("domainName", cDomainName).
        oJsonResponse:Add("authTagName", cAuthTagName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Authorization tag created successfully" ELSE "Failed to create authorization tag").
        
        ttResponseData.statusCode = IF lSuccess THEN 201 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle update authorization tag request
     Notes:   Uses UpdateAuthorizationTag method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleUpdateAuthTag(INPUT poRequest AS IWebRequest,
                                            OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cDomainName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTagName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cNewName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cDomainName = oJsonRequest:GetCharacter("domainName").
        cAuthTagName = oJsonRequest:GetCharacter("authTagName").
        cNewName = oJsonRequest:GetCharacter("newName").
        
        /* Update authorization tag */
        lSuccess = oMaskingService:UpdateAuthorizationTag(cDomainName, cAuthTagName, cNewName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("domainName", cDomainName).
        oJsonResponse:Add("authTagName", cAuthTagName).
        oJsonResponse:Add("newName", cNewName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Authorization tag updated successfully" ELSE "Failed to update authorization tag").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle delete authorization tag request
     Notes:   Uses DeleteAuthorizationTag method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleDeleteAuthTag(INPUT poRequest AS IWebRequest,
                                            OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cDomainName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTagName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cDomainName = oJsonRequest:GetCharacter("domainName").
        cAuthTagName = oJsonRequest:GetCharacter("authTagName").
        
        /* Delete authorization tag */
        lSuccess = oMaskingService:DeleteAuthorizationTag(cDomainName, cAuthTagName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("domainName", cDomainName).
        oJsonResponse:Add("authTagName", cAuthTagName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Authorization tag deleted successfully" ELSE "Failed to delete authorization tag").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle create role request
     Notes:   Uses CreateRole method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleCreateRole(INPUT poRequest AS IWebRequest,
                                         OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cRoleName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cRoleName = oJsonRequest:GetCharacter("roleName").
        
        /* Create role */
        lSuccess = oMaskingService:CreateRole(cRoleName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("roleName", cRoleName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Role created successfully" ELSE "Failed to create role").
        
        ttResponseData.statusCode = IF lSuccess THEN 201 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle delete role request
     Notes:   Uses DeleteRole method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleDeleteRole(INPUT poRequest AS IWebRequest,
                                         OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cRoleName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cRoleName = oJsonRequest:GetCharacter("roleName").
        
        /* Delete role */
        lSuccess = oMaskingService:DeleteRole(cRoleName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("roleName", cRoleName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Role deleted successfully" ELSE "Failed to delete role").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle grant role request
     Notes:   Uses GrantRoleToUser method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGrantRole(INPUT poRequest AS IWebRequest,
                                        OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cUserName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cRoleName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cUserName = oJsonRequest:GetCharacter("userName").
        cRoleName = oJsonRequest:GetCharacter("roleName").
        
        /* Grant role to user */
        lSuccess = oMaskingService:GrantRoleToUser(cUserName, cRoleName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("userName", cUserName).
        oJsonResponse:Add("roleName", cRoleName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Role granted successfully" ELSE "Failed to grant role").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle delete granted role request
     Notes:   Uses DeleteGrantedRole method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleDeleteGrantedRole(INPUT poRequest AS IWebRequest,
                                                OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cGrantId AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cGrantId = oJsonRequest:GetCharacter("grantId").
        
        /* Delete granted role */
        lSuccess = oMaskingService:DeleteGrantedRole(cGrantId).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("grantId", cGrantId).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Granted role deleted successfully" ELSE "Failed to delete granted role").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle create user request
     Notes:   Uses CreateUser method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleCreateUser(INPUT poRequest AS IWebRequest,
                                         OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cUserName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cPassword AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cUserName = oJsonRequest:GetCharacter("userName").
        cPassword = oJsonRequest:GetCharacter("password").
        
        /* Create user */
        lSuccess = oMaskingService:CreateUser(cUserName, cPassword).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("userName", cUserName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "User created successfully" ELSE "Failed to create user").
        
        ttResponseData.statusCode = IF lSuccess THEN 201 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle delete user request
     Notes:   Uses DeleteUser method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleDeleteUser(INPUT poRequest AS IWebRequest,
                                         OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cUserName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        
        cUserName = oJsonRequest:GetCharacter("userName").
        
        /* Delete user */
        lSuccess = oMaskingService:DeleteUser(cUserName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("userName", cUserName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "User deleted successfully" ELSE "Failed to delete user").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle mask value request
     Notes:   
    ------------------------------------------------------------------------------*/
    /* Removed HandleMaskValue - not aligned with current DDM service capabilities */

    /* Removed HandleMaskTable - not aligned with current DDM service capabilities */

    /* Removed HandleAddRule - replaced with HandleSetDDMConfig and HandleConfigureField */

    /* Removed HandleLoadConfig - not aligned with current DDM service capabilities */

    /*------------------------------------------------------------------------------
     Purpose: Validate required JSON parameters
     Notes:   Returns TRUE if all required parameters are present and valid
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE LOGICAL ValidateJsonParameters(INPUT oJsonData AS JsonObject,
                                                  INPUT cRequiredParams AS CHARACTER,
                                                  OUTPUT cErrorMessage AS CHARACTER):
        
        DEFINE VARIABLE iParam AS INTEGER NO-UNDO.
        DEFINE VARIABLE cParam AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lValid AS LOGICAL NO-UNDO INITIAL TRUE.
        
        cErrorMessage = "".
        
        IF NOT VALID-OBJECT(oJsonData) THEN DO:
            cErrorMessage = "Invalid or missing JSON data".
            RETURN FALSE.
        END.
        
        DO iParam = 1 TO NUM-ENTRIES(cRequiredParams):
            cParam = ENTRY(iParam, cRequiredParams).
            
            IF NOT oJsonData:Has(cParam) THEN DO:
                cErrorMessage = cErrorMessage + 
                    (IF cErrorMessage = "" THEN "" ELSE "; ") +
                    "Missing required parameter: " + cParam.
                lValid = FALSE.
            END.
            ELSE IF oJsonData:GetType(cParam) = JsonDataType:NULL THEN DO:
                cErrorMessage = cErrorMessage + 
                    (IF cErrorMessage = "" THEN "" ELSE "; ") +
                    "Parameter cannot be null: " + cParam.
                lValid = FALSE.
            END.
            ELSE IF TRIM(oJsonData:GetCharacter(cParam)) = "" THEN DO:
                cErrorMessage = cErrorMessage + 
                    (IF cErrorMessage = "" THEN "" ELSE "; ") +
                    "Parameter cannot be empty: " + cParam.
                lValid = FALSE.
            END.
        END.
        
        RETURN lValid.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Build standardized error response
     Notes:   Creates consistent error response format
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID BuildErrorResponse(INPUT poResponse AS WebResponse,
                                          INPUT poWriter AS WebResponseWriter,
                                          INPUT iStatusCode AS INTEGER,
                                          INPUT cErrorMessage AS CHARACTER,
                                          INPUT cPath AS CHARACTER):
        
        DEFINE VARIABLE oJsonError AS JsonObject NO-UNDO.
        
        oJsonError = NEW JsonObject().
        oJsonError:Add("error", cErrorMessage).
        oJsonError:Add("success", FALSE).
        oJsonError:Add("timestamp", ISO-DATE(NOW)).
        oJsonError:Add("path", cPath).
        
        poResponse:StatusCode = iStatusCode.
        poResponse:ContentType = "application/json".
        
        poWriter:Write(oJsonError:GetJsonText()).
        poWriter:Flush().
        poWriter:Close().
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle get configuration request
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetConfiguration(INPUT poResponse AS WebResponse,
                                              INPUT poWriter AS WebResponseWriter):
        
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        
        /* Build configuration response with DataAdmin info */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("availableMaskTypes", GetAvailableMaskTypes()).
        oJsonResponse:Add("availableAuthTags", GetAvailableAuthTags()).
        oJsonResponse:Add("database", cDatabaseName).
        oJsonResponse:Add("ddmApiVersion", "OpenEdge 12.8").
        oJsonResponse:Add("supportedMethods", GetSupportedMethods()).
        oJsonResponse:Add("success", TRUE).
        
        poResponse:StatusCode = 200.
        poResponse:ContentType = "application/json".
        
        poWriter:Write(oJsonResponse:GetJsonText()).
        poWriter:Flush().
        poWriter:Close().
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Get available mask types for DDM configuration
     Notes:   Based on OpenEdge 12.8 DDM capabilities
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE JsonArray GetAvailableMaskTypes():
        
        DEFINE VARIABLE oMaskTypes AS JsonArray NO-UNDO.
        DEFINE VARIABLE oMaskType AS JsonObject NO-UNDO.
        
        oMaskTypes = NEW JsonArray().
        
        /* Full Masking */
        oMaskType = NEW JsonObject().
        oMaskType:Add("type", "FULL").
        oMaskType:Add("description", "Complete masking with specified mask value").
        oMaskType:Add("example", "****").
        oMaskType:Add("usage", "Replace entire field value with mask").
        oMaskTypes:Add(oMaskType).
        
        /* Partial Masking */
        oMaskType = NEW JsonObject().
        oMaskType:Add("type", "PARTIAL").
        oMaskType:Add("description", "Partial masking preserving some characters").
        oMaskType:Add("example", "XXXX").
        oMaskType:Add("usage", "Mask part of the field value").
        oMaskTypes:Add(oMaskType).
        
        /* Conditional Masking */
        oMaskType = NEW JsonObject().
        oMaskType:Add("type", "CONDITIONAL").
        oMaskType:Add("description", "Conditional masking based on authorization tag").
        oMaskType:Add("example", "0000").
        oMaskType:Add("usage", "Apply mask based on user authorization").
        oMaskTypes:Add(oMaskType).
        
        RETURN oMaskTypes.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Get available authorization tags
     Notes:   Common authorization tags for DDM
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE JsonArray GetAvailableAuthTags():
        
        DEFINE VARIABLE oAuthTags AS JsonArray NO-UNDO.
        DEFINE VARIABLE oAuthTag AS JsonObject NO-UNDO.
        
        oAuthTags = NEW JsonArray().
        
        /* Sensitive Data */
        oAuthTag = NEW JsonObject().
        oAuthTag:Add("tag", "SENSITIVE").
        oAuthTag:Add("description", "Sensitive personal information").
        oAuthTags:Add(oAuthTag).
        
        /* PII */
        oAuthTag = NEW JsonObject().
        oAuthTag:Add("tag", "PII").
        oAuthTag:Add("description", "Personally Identifiable Information").
        oAuthTags:Add(oAuthTag).
        
        /* Business */
        oAuthTag = NEW JsonObject().
        oAuthTag:Add("tag", "BUSINESS").
        oAuthTag:Add("description", "Business sensitive data").
        oAuthTags:Add(oAuthTag).
        
        /* Financial */
        oAuthTag = NEW JsonObject().
        oAuthTag:Add("tag", "FINANCIAL").
        oAuthTag:Add("description", "Financial information").
        oAuthTags:Add(oAuthTag).
        
        RETURN oAuthTags.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Get supported DDM methods
     Notes:   Lists the actual OpenEdge 12.8 DDM API methods available
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE JsonArray GetSupportedMethods():
        
        DEFINE VARIABLE oMethods AS JsonArray NO-UNDO.
        DEFINE VARIABLE oMethod AS JsonObject NO-UNDO.
        
        oMethods = NEW JsonArray().
        
        /* setDDMConfig */
        oMethod = NEW JsonObject().
        oMethod:Add("method", "setDDMConfig").
        oMethod:Add("description", "Set DDM configuration with mask value and authorization tag").
        oMethod:Add("parameters", "tablename, fieldname, maskval, authtag").
        oMethod:Add("endpoint", "POST /api/masking/set-ddm-config").
        oMethods:Add(oMethod).
        
        /* unsetDDMMask */
        oMethod = NEW JsonObject().
        oMethod:Add("method", "unsetDDMMask").
        oMethod:Add("description", "Remove mask value for a field").
        oMethod:Add("parameters", "tablename, fieldname").
        oMethod:Add("endpoint", "DELETE /api/masking/remove-ddm-config").
        oMethods:Add(oMethod).
        
        /* unsetDDMAuthTag */
        oMethod = NEW JsonObject().
        oMethod:Add("method", "unsetDDMAuthTag").
        oMethod:Add("description", "Remove authorization tag for a field").
        oMethod:Add("parameters", "tablename, fieldname").
        oMethod:Add("endpoint", "DELETE /api/masking/remove-ddm-config").
        oMethods:Add(oMethod).
        
        /* ConfigureFieldMasking */
        oMethod = NEW JsonObject().
        oMethod:Add("method", "ConfigureFieldMasking").
        oMethod:Add("description", "High-level field masking configuration").
        oMethod:Add("parameters", "tablename, fieldname, maskingtype, maskingvalue, authtag").
        oMethod:Add("endpoint", "POST /api/masking/configure-field").
        oMethods:Add(oMethod).
        
        RETURN oMethods.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle errors
     Notes:   
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE INTEGER HandleError(INPUT poRequest AS IWebRequest,
                                      INPUT poError AS Progress.Lang.Error):
        
        DEFINE VARIABLE oResponse AS WebResponse NO-UNDO.
        DEFINE VARIABLE oWriter AS WebResponseWriter NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        
        oResponse = NEW WebResponse().
        oWriter = NEW WebResponseWriter(oResponse).
        
        
        /* Build error response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("success", FALSE).
        oJsonResponse:Add("error", poError:GetMessage(1)).
        oJsonResponse:Add("timestamp", ISO-DATE(NOW)).
        
        oResponse:StatusCode = 500.
        oResponse:ContentType = "application/json".
        
        oWriter:Write(oJsonResponse:GetJsonText()).
        oWriter:Flush().
        oWriter:Close().
        
        RETURN 0.
        
    END METHOD.

    
   
    /*------------------------------------------------------------------------------
     Purpose: Handle unsupported HTTP methods
     Notes:   Required abstract method implementation for WebHandler
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod(INPUT poRequest AS IWebRequest):
        
        DEFINE VARIABLE oResponse AS WebResponse NO-UNDO.
        DEFINE VARIABLE oWriter AS WebResponseWriter NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        
        oResponse = NEW WebResponse().
        oWriter = NEW WebResponseWriter(oResponse).
        
        /* Build method not allowed response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("error", "Method not allowed").
        oJsonResponse:Add("method", poRequest:Method).
        oJsonResponse:Add("path", poRequest:PathInfo).
        oJsonResponse:Add("allowedMethods", "GET, POST, DELETE").
        oJsonResponse:Add("success", FALSE).
        
        oResponse:StatusCode = 405. /* Method Not Allowed */
        oResponse:ContentType = "application/json".
        oResponse:SetHeader("Allow", "GET, POST, DELETE").
        
        oWriter:Write(oJsonResponse:GetJsonText()).
        oWriter:Flush().
        oWriter:Close().
        
        RETURN 405.
        
        CATCH oError AS Progress.Lang.Error:
            RETURN HandleError(poRequest, oError).
        END CATCH.
        
        FINALLY:
            DELETE OBJECT oJsonResponse NO-ERROR.
            DELETE OBJECT oResponse NO-ERROR.
            DELETE OBJECT oWriter NO-ERROR.
        END FINALLY.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle not implemented HTTP methods
     Notes:   Required abstract method implementation for WebHandler
    ------------------------------------------------------------------------------*/
    METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented(INPUT poRequest AS IWebRequest):
        
        DEFINE VARIABLE oResponse AS WebResponse NO-UNDO.
        DEFINE VARIABLE oWriter AS WebResponseWriter NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        
        oResponse = NEW WebResponse().
        oWriter = NEW WebResponseWriter(oResponse).
        
        /* Build not implemented response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("error", "Method not implemented").
        oJsonResponse:Add("method", poRequest:Method).
        oJsonResponse:Add("path", poRequest:PathInfo).
        oJsonResponse:Add("message", "This HTTP method is not implemented for this endpoint").
        oJsonResponse:Add("success", FALSE).
        
        oResponse:StatusCode = 501. /* Not Implemented */
        oResponse:ContentType = "application/json".
        
        oWriter:Write(oJsonResponse:GetJsonText()).
        oWriter:Flush().
        oWriter:Close().
        
        RETURN 501.
        
        CATCH oError AS Progress.Lang.Error:
            RETURN HandleError(poRequest, oError).
        END CATCH.
        
        FINALLY:
            DELETE OBJECT oJsonResponse NO-ERROR.
            DELETE OBJECT oResponse NO-ERROR.
            DELETE OBJECT oWriter NO-ERROR.
        END FINALLY.
        
    END METHOD.

END CLASS.
