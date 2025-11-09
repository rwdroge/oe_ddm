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
        oJsonResponse:Add("path", poRequest:PathInfo).
                cResponseBody = oJsonResponse:GetJsonText().
                oResponse:StatusCode = 200.
                oResponse:ContentType = "application/json".
                oResponse:ContentLength = LENGTH(cResponseBody).
            END.

            WHEN "tables" THEN DO:
                /* List all user tables in the connected database */
                HandleGetTables(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "fields" THEN DO:
                /* List fields for a given table */
                HandleGetFields(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "roles-with-counts" THEN DO:
                /* List all roles with their granted user counts */
                HandleGetRolesWithCounts(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "auth-tags-with-roles" THEN DO:
                /* List all authorization tags with associated roles */
                HandleGetAllAuthTagsWithRoles(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "grant-security-admin" THEN DO:
                /* Grant security administrator privileges to a user */
                HandleGrantSecurityAdmin(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "associate-auth-tag-role" THEN DO:
                /* Reassign an auth tag to a different role */
                HandleAssociateAuthTagRole(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "table-configs" THEN DO:
                /* Get all field configs for a table */
                HandleGetTableConfigs(poRequest, OUTPUT TABLE ttResponseData).
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
            
            WHEN "roles" THEN DO:
                /* List all roles */
                HandleGetRoles(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "users" THEN DO:
                /* List all users */
                HandleGetUsers(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "auth-tags" THEN DO:
                /* List all authorization tags */
                HandleGetAllAuthTags(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "role-auth-tags" THEN DO:
                /* List authorization tags for a given role */
                HandleGetRoleAuthTags(poRequest, OUTPUT TABLE ttResponseData).
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
     Purpose: Handle grant one role to multiple users
     Notes:   Accepts JSON: { roleName: "...", userNames: ["u1","u2",...] }
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGrantRoles(INPUT poRequest AS IWebRequest,
                                         OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonRequest  AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE oResults      AS JsonArray  NO-UNDO.
        DEFINE VARIABLE oUsers        AS JsonArray  NO-UNDO.
        DEFINE VARIABLE cRoleName     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cUser         AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i             AS INTEGER   NO-UNDO.
        DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.
        DEFINE VARIABLE iTotal        AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iOk           AS INTEGER   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        oJsonResponse = NEW JsonObject().
        oResults = NEW JsonArray().

        /* Parse request */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        cRoleName = oJsonRequest:GetCharacter("roleName").
        oUsers = oJsonRequest:GetJsonArray("userNames").

        IF cRoleName = "" OR cRoleName = ? OR NOT VALID-OBJECT(oUsers) OR oUsers:Length = 0 THEN DO:
            oJsonResponse:Add("error", "roleName and userNames[] are required").
            oJsonResponse:Add("success", FALSE).
            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.

        iTotal = oUsers:Length.
        iOk = 0.

        DO i = 1 TO oUsers:Length:
            cUser = oUsers:GetCharacter(i).
            IF cUser = ? THEN cUser = "".
            lSuccess = FALSE.
            IF cUser <> "" THEN DO ON ERROR UNDO, THROW:
                lSuccess = oMaskingService:GrantRoleToUser(cUser, cRoleName).
            END.
            IF lSuccess THEN iOk = iOk + 1.

            /* Per-user result */
            DEFINE VARIABLE oItem AS JsonObject NO-UNDO.
            oItem = NEW JsonObject().
            oItem:Add("userName", cUser).
            oItem:Add("roleName", cRoleName).
            oItem:Add("success", lSuccess).
            IF lSuccess THEN
                oItem:Add("message", SUBSTITUTE("Granted role '&1' to '&2'", cRoleName, cUser)).
            ELSE
                oItem:Add("error", SUBSTITUTE("Failed to grant role '&1' to '&2'", cRoleName, cUser)).
            oResults:Add(oItem).
        END.

        oJsonResponse:Add("roleName", cRoleName).
        oJsonResponse:Add("results", oResults).
        oJsonResponse:Add("success", iOk = iTotal).
        IF iOk = iTotal THEN
            oJsonResponse:Add("message", SUBSTITUTE("Granted role '&1' to &2 user(s)", cRoleName, iOk)).
        ELSE IF iOk = 0 THEN
            oJsonResponse:Add("message", SUBSTITUTE("Failed to grant role '&1' to all &2 user(s)", cRoleName, iTotal)).
        ELSE
            oJsonResponse:Add("message", SUBSTITUTE("Partially granted role '&1': &2/&3 succeeded", cRoleName, iOk, iTotal)).

        /* HTTP status: 200 all ok, 207 partial, 400 none */
        ttResponseData.statusCode = IF iOk = iTotal THEN 200 ELSE IF iOk = 0 THEN 400 ELSE 207.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = (iOk = iTotal).

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle get all field configs for a table
     Notes:   Aggregates existing per-field config data
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetTableConfigs(INPUT poRequest AS IWebRequest,
                                              OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonArray    AS JsonArray  NO-UNDO.
        DEFINE VARIABLE cTableName    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldsList   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i             AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cField        AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cResult       AS CHARACTER NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        /* Read tableName from query */
        cTableName = poRequest:URI:GetQueryValue("tableName").
        IF cTableName = "" OR cTableName = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "tableName is required").
            oJsonResponse:Add("success", FALSE).

            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.

        oJsonArray = NEW JsonArray().

        DO ON ERROR UNDO, THROW:
            cFieldsList = oMaskingService:GetFieldsForTable(cTableName).
            DO i = 1 TO NUM-ENTRIES(cFieldsList):
                cField = TRIM(ENTRY(i, cFieldsList)).
                IF cField = "" THEN NEXT.
                DEFINE VARIABLE cMaskVal  AS CHARACTER NO-UNDO.
                DEFINE VARIABLE cTag      AS CHARACTER NO-UNDO.
                DEFINE VARIABLE lOK       AS LOGICAL   NO-UNDO.
                lOK = oMaskingService:GetFieldDDMConfig(cTableName, cField, OUTPUT cMaskVal, OUTPUT cTag).
                IF lOK AND cMaskVal <> "" AND cTag <> "" THEN DO:
                    DEFINE VARIABLE oItem AS JsonObject NO-UNDO.
                    oItem = NEW JsonObject().
                    oItem:Add("fieldName", cField).
                    IF cMaskVal <> "" THEN oItem:Add("maskValue", cMaskVal).
                    IF cTag <> "" THEN oItem:Add("authTag", cTag).
                    /* Provide a simple details string as well */
                    oItem:Add("result", SUBSTITUTE("Mask: &1, Tag: &2", cMaskVal, cTag)).
                    oJsonArray:Add(oItem).
                END.
            END.
        END.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("items", oJsonArray).
        oJsonResponse:Add("success", TRUE).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = TRUE.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List all user tables from connected database
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetTables(INPUT poRequest AS IWebRequest,
                                        OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonArray    AS JsonArray  NO-UNDO.
        DEFINE VARIABLE cList         AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i             AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cItem         AS CHARACTER NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        oJsonArray = NEW JsonArray().

        DO ON ERROR UNDO, THROW:
            /* Use DataAdmin service to enumerate user tables (via ddm service) */
            cList = oMaskingService:GetAllTables().
            DO i = 1 TO NUM-ENTRIES(cList):
                cItem = TRIM(ENTRY(i, cList)).
                IF cItem <> "" THEN oJsonArray:Add(cItem).
            END.
        END.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tables", oJsonArray).
        oJsonResponse:Add("success", TRUE).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = TRUE.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List all fields for a given table name
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetFields(INPUT poRequest AS IWebRequest,
                                        OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonArray    AS JsonArray  NO-UNDO.
        DEFINE VARIABLE cTableName    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cList         AS CHARACTER NO-UNDO.
        DEFINE VARIABLE i             AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cItem         AS CHARACTER NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        /* Read tableName from query */
        cTableName = poRequest:URI:GetQueryValue("tableName").
        IF cTableName = "" OR cTableName = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "tableName is required").
            oJsonResponse:Add("success", FALSE).

            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.

        oJsonArray = NEW JsonArray().
        DEFINE VARIABLE oTypes AS JsonObject NO-UNDO.
        oTypes = NEW JsonObject().

        DO ON ERROR UNDO, THROW:
            /* Use DataAdmin service to enumerate fields (via ddm service) */
            cList = oMaskingService:GetFieldsForTable(cTableName).
            DO i = 1 TO NUM-ENTRIES(cList):
                cItem = TRIM(ENTRY(i, cList)).
                IF cItem <> "" THEN DO:
                    oJsonArray:Add(cItem).
                    /* Discover type via dynamic buffer */
                    DEFINE VARIABLE hBuf AS HANDLE NO-UNDO.
                    DEFINE VARIABLE hFld AS HANDLE NO-UNDO.
                    CREATE BUFFER hBuf FOR TABLE cTableName.
                    hFld = hBuf:BUFFER-FIELD(cItem) NO-ERROR.
                    IF VALID-HANDLE(hFld) THEN
                        oTypes:Add(cItem, hFld:DATA-TYPE).
                    DELETE OBJECT hBuf NO-ERROR.
                END.
            END.
        END.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("tableName", cTableName).
        oJsonResponse:Add("fields", oJsonArray).
        oJsonResponse:Add("fieldTypes", oTypes).
        oJsonResponse:Add("success", TRUE).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = TRUE.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
    END METHOD.
    /*------------------------------------------------------------------------------
     Purpose: Handle list roles with counts
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetRolesWithCounts(INPUT poRequest AS IWebRequest,
                                                 OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cResult       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        cResult = oMaskingService:GetRolesWithUserCounts().
        lSuccess = TRUE.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", lSuccess).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle list all auth tags with roles
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetAllAuthTagsWithRoles(INPUT poRequest AS IWebRequest,
                                                      OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cResult       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        cResult = oMaskingService:GetAllAuthTagsWithRoles().
        lSuccess = TRUE.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", lSuccess).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
    END METHOD.
    /*------------------------------------------------------------------------------
     Purpose: Handle associate (reassign) an authorization tag via POST body
     Notes:   Accepts JSON with currentRoleName, authTagName, newRoleName
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleAssociateAuthTagRolePost(INPUT poRequest AS IWebRequest,
                                                       OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonRequest   AS JsonObject NO-UNDO.
        DEFINE VARIABLE oJsonResponse  AS JsonObject NO-UNDO.
        DEFINE VARIABLE cCurrentRole   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTagName   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cNewRole       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess       AS LOGICAL   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        /* Parse request body */
        oJsonRequest = CAST(poRequest:Entity, JsonObject).
        cCurrentRole = oJsonRequest:GetCharacter("currentRoleName").
        cAuthTagName = oJsonRequest:GetCharacter("authTagName").
        cNewRole     = oJsonRequest:GetCharacter("newRoleName").

        IF cCurrentRole = "" OR cCurrentRole = ? OR
           cAuthTagName = "" OR cAuthTagName = ? OR
           cNewRole = "" OR cNewRole = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "currentRoleName, authTagName and newRoleName are required").
            oJsonResponse:Add("success", FALSE).

            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.

        /* Perform the association (reassignment) with error capture */
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:AssociateAuthTagToRole(cCurrentRole, cAuthTagName, cNewRole).
        END.

        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("currentRoleName", cCurrentRole).
        oJsonResponse:Add("authTagName", cAuthTagName).
        oJsonResponse:Add("newRoleName", cNewRole).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Authorization tag reassigned successfully"
                                           ELSE "Failed to reassign authorization tag").

        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.

        CATCH oError AS Progress.Lang.Error:
            /* Consolidated error handling for this method */
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("currentRoleName", cCurrentRole).
            oJsonResponse:Add("authTagName", cAuthTagName).
            oJsonResponse:Add("newRoleName", cNewRole).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle list all roles
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetRoles(INPUT poRequest AS IWebRequest,
                                       OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cResult       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        /* Wrap service call to ensure JSON 500 on errors */
        DO ON ERROR UNDO, THROW:
            cResult = oMaskingService:GetAllRoles().
        END.
        lSuccess = TRUE.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", lSuccess).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle list all authorization tags
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetAllAuthTags(INPUT poRequest AS IWebRequest,
                                             OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cResult       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        /* Wrap service call to ensure JSON 500 on errors */
        DO ON ERROR UNDO, THROW:
            cResult = oMaskingService:GetAllAuthTags().
        END.
        lSuccess = TRUE.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", lSuccess).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle list all users
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetUsers(INPUT poRequest AS IWebRequest,
                                       OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cResult       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        /* Wrap service call to ensure JSON 500 on errors */
        DO ON ERROR UNDO, THROW:
            cResult = oMaskingService:GetAllUsers().
        END.
        lSuccess = TRUE.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", lSuccess).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle list auth tags for a role
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetRoleAuthTags(INPUT poRequest AS IWebRequest,
                                              OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cRoleName     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cResult       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        cRoleName = poRequest:URI:GetQueryValue("roleName").
        IF cRoleName = "" OR cRoleName = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "roleName is required").
            oJsonResponse:Add("success", FALSE).
            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.

        /* Wrap service call to ensure JSON 500 on errors */
        DO ON ERROR UNDO, THROW:
            cResult = oMaskingService:GetAuthTagsForRole(cRoleName).
        END.
        lSuccess = TRUE.

        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("roleName", cRoleName).
        oJsonResponse:Add("result", cResult).
        oJsonResponse:Add("success", lSuccess).

        ttResponseData.statusCode = 200.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Handle grant security admin request
     Notes:   Uses DataAdminMaskingService:GrantSecurityAdmin
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGrantSecurityAdmin(INPUT poRequest AS IWebRequest,
                                                 OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cUserName     AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess      AS LOGICAL   NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Read from query parameters for GET endpoint */
        cUserName = poRequest:URI:GetQueryValue("userName").
        
        IF cUserName = "" OR cUserName = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "userName is required").
            oJsonResponse:Add("success", FALSE).
            
            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.
        
        /* Grant security admin */
        lSuccess = oMaskingService:GrantSecurityAdmin(cUserName).
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("userName", cUserName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Security admin granted" ELSE "Failed to grant security admin").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.
        
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

            WHEN "grant-roles" THEN DO:
                /* Grant one role to multiple users */
                HandleGrantRoles(poRequest, OUTPUT TABLE ttResponseData).
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

            WHEN "associate-auth-tag-role" THEN DO:
                /* Reassign an auth tag to a different role (POST) */
                HandleAssociateAuthTagRolePost(poRequest, OUTPUT TABLE ttResponseData).
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:ConfigureFieldMasking(cTableName, cFieldName, cMaskingType, cMaskingValue, cAuthTag).
        END.
        
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
     Purpose: Handle get mask and authorization tag for field request
     Notes:   Uses GetMaskAndAuthTagForField method
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleGetMaskAndAuthTag(INPUT poRequest AS IWebRequest,
                                                OUTPUT TABLE ttResponseData):
        
        DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cFieldName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cUserName AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Get parameters from query string via URI helper */
        cTableName = poRequest:URI:GetQueryValue("tableName").
        cFieldName = poRequest:URI:GetQueryValue("fieldName").
        cUserName  = poRequest:URI:GetQueryValue("userName").
        
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
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Get parameters from query string via URI helper */
        cDomainName = poRequest:URI:GetQueryValue("domainName").
        cAuthTagName = poRequest:URI:GetQueryValue("authTagName").
        
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
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        
        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.
        
        /* Get parameters from query string via URI helper */
        cUserName = poRequest:URI:GetQueryValue("userName").
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:UnsetMaskForField(cTableName, cFieldName).
        END.
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:UnsetAuthTagForField(cTableName, cFieldName).
        END.
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:CreateAuthorizationTag(cDomainName, cAuthTagName).
        END.
        
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

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("domainName", cDomainName).
            oJsonResponse:Add("authTagName", cAuthTagName).
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("errorType", oError:GetClass():TypeName).
            oJsonResponse:Add("timestamp", ISO-DATE(NOW)).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:UpdateAuthorizationTag(cDomainName, cAuthTagName, cNewName).
        END.
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:DeleteAuthorizationTag(cDomainName, cAuthTagName).
        END.
        
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

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("domainName", cDomainName).
            oJsonResponse:Add("authTagName", cAuthTagName).
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("errorType", oError:GetClass():TypeName).
            oJsonResponse:Add("timestamp", ISO-DATE(NOW)).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:CreateRole(cRoleName).
        END.

        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("roleName", cRoleName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Role created successfully" ELSE "Failed to create role").
        
        ttResponseData.statusCode = IF lSuccess THEN 201 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("roleName", cRoleName).
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
        
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
        
        DO ON ERROR UNDO, THROW:
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
        END.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("roleName", cRoleName).
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("errorType", oError:GetClass():TypeName).
            oJsonResponse:Add("timestamp", ISO-DATE(NOW)).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
        
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
        
        DO ON ERROR UNDO, THROW:
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
        END.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("userName", cUserName).
            oJsonResponse:Add("roleName", cRoleName).
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("errorType", oError:GetClass():TypeName).
            oJsonResponse:Add("timestamp", ISO-DATE(NOW)).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:DeleteGrantedRole(cGrantId).
        END.
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("grantId", cGrantId).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Granted role deleted successfully" ELSE "Failed to delete granted role").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("grantId", cGrantId).
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("errorType", oError:GetClass():TypeName).
            oJsonResponse:Add("timestamp", ISO-DATE(NOW)).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:CreateUser(cUserName, cPassword).
        END.
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("userName", cUserName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "User created successfully" ELSE "Failed to create user").
        
        ttResponseData.statusCode = IF lSuccess THEN 201 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("userName", cUserName).
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("errorType", oError:GetClass():TypeName).
            oJsonResponse:Add("timestamp", ISO-DATE(NOW)).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
        
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
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:DeleteUser(cUserName).
        END.
        
        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("userName", cUserName).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "User deleted successfully" ELSE "Failed to delete user").
        
        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("userName", cUserName).
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("errorType", oError:GetClass():TypeName).
            oJsonResponse:Add("timestamp", ISO-DATE(NOW)).

            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
        
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
        
        /* ConfigureFieldMasking */
        oMethod = NEW JsonObject().
        oMethod:Add("method", "ConfigureFieldMasking").
        oMethod:Add("description", "High-level field masking configuration").
        oMethod:Add("parameters", "tablename, fieldname, maskingtype, maskingvalue, authtag").
        oMethod:Add("endpoint", "POST /api/masking/configure-field").
        oMethods:Add(oMethod).
        
        /* UnsetMask */
        oMethod = NEW JsonObject().
        oMethod:Add("method", "UnsetMask").
        oMethod:Add("description", "Remove mask value for a field").
        oMethod:Add("parameters", "tablename, fieldname").
        oMethod:Add("endpoint", "POST /api/masking/unset-mask").
        oMethods:Add(oMethod).
        
        /* UnsetAuthTag */
        oMethod = NEW JsonObject().
        oMethod:Add("method", "UnsetAuthTag").
        oMethod:Add("description", "Remove authorization tag for a field").
        oMethod:Add("parameters", "tablename, fieldname").
        oMethod:Add("endpoint", "POST /api/masking/unset-auth-tag").
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
        
        
        /* Build error response with more detail */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("success", FALSE).
        oJsonResponse:Add("error", poError:GetMessage(1)).
        oJsonResponse:Add("errorType", poError:GetClass():TypeName).
        oJsonResponse:Add("timestamp", ISO-DATE(NOW)).

        /* Include additional chained messages when present */
        IF poError:NumMessages > 1 THEN DO:
            DEFINE VARIABLE i AS INTEGER NO-UNDO.
            DEFINE VARIABLE oDetails AS JsonArray NO-UNDO.
            oDetails = NEW JsonArray().
            DO i = 1 TO poError:NumMessages:
                oDetails:Add(poError:GetMessage(i)).
            END.
            oJsonResponse:Add("details", oDetails).
        END.
        
        oResponse:StatusCode = 500.
        oResponse:ContentType = "application/json".
        
        oWriter:Write(oJsonResponse:GetJsonText()).
        oWriter:Flush().
        oWriter:Close().
        
        RETURN 500.
    
    END METHOD.

        /*------------------------------------------------------------------------------
     Purpose: Handle associate (reassign) an authorization tag to a different role
     Notes:   Uses DataAdminMaskingService:AssociateAuthTagToRole
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE VOID HandleAssociateAuthTagRole(INPUT poRequest AS IWebRequest,
                                                   OUTPUT TABLE ttResponseData):
        DEFINE VARIABLE oJsonResponse  AS JsonObject NO-UNDO.
        DEFINE VARIABLE cCurrentRole   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTagName   AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cNewRole       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess       AS LOGICAL   NO-UNDO.

        EMPTY TEMP-TABLE ttResponseData.
        CREATE ttResponseData.

        /* Read from query parameters for GET endpoint */
        cCurrentRole = poRequest:URI:GetQueryValue("currentRole").
        cAuthTagName = poRequest:URI:GetQueryValue("authTagName").
        cNewRole     = poRequest:URI:GetQueryValue("newRole").

        IF cCurrentRole = "" OR cCurrentRole = ? OR
           cAuthTagName = "" OR cAuthTagName = ? OR
           cNewRole = "" OR cNewRole = ? THEN DO:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("error", "currentRole, authTagName and newRole are required").
            oJsonResponse:Add("success", FALSE).

            ttResponseData.statusCode = 400.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
            RETURN.
        END.

        /* Perform the association (reassignment) with error capture */
        DO ON ERROR UNDO, THROW:
            lSuccess = oMaskingService:AssociateAuthTagToRole(cCurrentRole, cAuthTagName, cNewRole).
        END.

        /* Build response */
        oJsonResponse = NEW JsonObject().
        oJsonResponse:Add("currentRole", cCurrentRole).
        oJsonResponse:Add("authTagName", cAuthTagName).
        oJsonResponse:Add("newRole", cNewRole).
        oJsonResponse:Add("success", lSuccess).
        oJsonResponse:Add("message", IF lSuccess THEN "Authorization tag reassigned successfully"
                                           ELSE "Failed to reassign authorization tag").

        ttResponseData.statusCode = IF lSuccess THEN 200 ELSE 400.
        ttResponseData.contentType = "application/json".
        ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
        ttResponseData.success = lSuccess.

        CATCH oError AS Progress.Lang.Error:
            oJsonResponse = NEW JsonObject().
            oJsonResponse:Add("success", FALSE).
            oJsonResponse:Add("error", oError:GetMessage(1)).
            oJsonResponse:Add("currentRole", cCurrentRole).
            oJsonResponse:Add("authTagName", cAuthTagName).
            oJsonResponse:Add("newRole", cNewRole).

            /* Internal errors should be 500 */
            ttResponseData.statusCode = 500.
            ttResponseData.contentType = "application/json".
            ttResponseData.jsonResponse = oJsonResponse:GetJsonText().
            ttResponseData.success = FALSE.
        END CATCH.
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
