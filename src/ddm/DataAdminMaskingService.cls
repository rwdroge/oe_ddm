/*------------------------------------------------------------------------
    File        : DataAdminMaskingService.cls
    Purpose     : Proper OpenEdge DataAdmin-based DDM service
    Syntax      : 
    Description : Uses OpenEdge.DataAdmin.DataAdminService DDM API methods
    Author(s)   : Progress Developer
    Created     : 
    Notes       : Clean implementation using only DDM-specific API methods
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.DataAdmin.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS ddm.DataAdminMaskingService:

    DEFINE PRIVATE VARIABLE oDataAdminService AS DataAdminService NO-UNDO.
    DEFINE PRIVATE VARIABLE cDatabaseName AS CHARACTER NO-UNDO.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor - Initialize DataAdmin service
     Notes:   
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC DataAdminMaskingService(INPUT pcDatabaseName AS CHARACTER):
        
        cDatabaseName = pcDatabaseName.
        
        /* Create DataAdminService for DDM operations */
        oDataAdminService = NEW DataAdminService(cDatabaseName).
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to initialize DataAdmin service for database &1: &2", 
                          cDatabaseName, oError:GetMessage(1))).
        END CATCH.
        
    END CONSTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: Get DDM config (mask and auth tag) for a field using DataAdmin
     Notes:   Returns TRUE if values were retrieved, with outputs populated
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL GetFieldDDMConfig(INPUT pcTableName AS CHARACTER,
                                               INPUT pcFieldName AS CHARACTER,
                                               OUTPUT pcMaskValue AS CHARACTER,
                                               OUTPUT pcAuthTag AS CHARACTER):
        DEFINE VARIABLE cMask AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cTag  AS CHARACTER NO-UNDO.

        pcMaskValue = "".
        pcAuthTag   = "".

        DO ON ERROR UNDO, THROW:
            /* OpenEdge 12.8 adds GetFieldDDMConfig to DataAdminService */
            oDataAdminService:GetFieldDDMConfig(pcTableName, pcFieldName, OUTPUT cMask, OUTPUT cTag) NO-ERROR.
            IF ERROR-STATUS:ERROR THEN RETURN FALSE.
            IF cMask = ? THEN cMask = "".
            IF cTag  = ? THEN cTag  = "".
            pcMaskValue = TRIM(cMask).
            pcAuthTag   = TRIM(cTag).
            RETURN TRUE.
        END.

        CATCH oError AS Progress.Lang.Error:
            RETURN FALSE.
        END CATCH.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List all user tables as a comma-separated string (user tables only)
     Notes:   Interface intended for DataAdmin-backed enumeration; current
              implementation uses metaschema for compatibility and will be
              refactored to DataAdmin-specific APIs without changing signature.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetAllTables():
        DEFINE VARIABLE cResult    AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cTableName AS CHARACTER NO-UNDO.

        FOR EACH _File NO-LOCK WHERE _File._tbl-type = "T" AND _File._hidden = FALSE:
            cTableName = _File._File-Name.
            IF cResult = "" THEN cResult = cTableName.
            ELSE cResult = cResult + ", " + cTableName.
        END.

        RETURN cResult.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List all fields for a given table as a comma-separated string
     Notes:   Interface intended for DataAdmin-backed enumeration; current
              implementation uses dynamic buffer and will be refactored to
              DataAdmin-specific APIs without changing signature.
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetFieldsForTable(INPUT pcTableName AS CHARACTER):
        DEFINE VARIABLE cResult  AS CHARACTER NO-UNDO.
        DEFINE VARIABLE hBuffer  AS HANDLE    NO-UNDO.
        DEFINE VARIABLE i        AS INTEGER   NO-UNDO.
        DEFINE VARIABLE hField   AS HANDLE    NO-UNDO.

        IF pcTableName = "" OR pcTableName = ? THEN
            RETURN "".

        CREATE BUFFER hBuffer FOR TABLE pcTableName.
        DO i = 1 TO hBuffer:NUM-FIELDS:
            hField = hBuffer:BUFFER-FIELD(i).
            IF cResult = "" THEN cResult = hField:NAME.
            ELSE cResult = cResult + ", " + hField:NAME.
        END.
        DELETE OBJECT hBuffer NO-ERROR.

        RETURN cResult.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List roles with number of granted users as role|count comma-separated
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetRolesWithUserCounts():
        DEFINE VARIABLE oRoles     AS OpenEdge.DataAdmin.IRoleSet NO-UNDO.
        DEFINE VARIABLE oRole      AS OpenEdge.DataAdmin.IRole NO-UNDO.
        DEFINE VARIABLE oIterator  AS OpenEdge.DataAdmin.Lang.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE oGrants    AS OpenEdge.DataAdmin.IGrantedRoleSet NO-UNDO.
        DEFINE VARIABLE oIter2     AS OpenEdge.DataAdmin.Lang.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE iCount     AS INTEGER NO-UNDO.
        DEFINE VARIABLE cResult    AS CHARACTER NO-UNDO.

        /* Only list DDM roles */
        oRoles = oDataAdminService:GetRoles("IsDDM eq 'true'").
        IF VALID-OBJECT(oRoles) THEN DO:
            oIterator = oRoles:Iterator().
            DO WHILE oIterator:HasNext():
                oRole = CAST(oIterator:Next(), OpenEdge.DataAdmin.IRole).
                IF VALID-OBJECT(oRole) THEN DO:
                    iCount = 0.
                    oGrants = oDataAdminService:GetGrantedRoles(SUBSTITUTE("RoleName eq '&1'", oRole:Name)).
                    IF VALID-OBJECT(oGrants) THEN DO:
                        oIter2 = oGrants:Iterator().
                        DO WHILE oIter2:HasNext():
                            /* iterate to count */
                            oIter2:Next().
                            iCount = iCount + 1.
                        END.
                    END.
                    IF cResult = "" THEN cResult = SUBSTITUTE("&1|&2", oRole:Name, iCount).
                    ELSE cResult = cResult + ", " + SUBSTITUTE("&1|&2", oRole:Name, iCount).
                END.
            END.
        END.
        RETURN cResult.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List all authorization tags with their role as tag|role comma-separated
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetAllAuthTagsWithRoles():
        DEFINE VARIABLE oTags     AS OpenEdge.DataAdmin.IAuthTagSet NO-UNDO.
        DEFINE VARIABLE oTag      AS OpenEdge.DataAdmin.IAuthTag NO-UNDO.
        DEFINE VARIABLE oIterator AS OpenEdge.DataAdmin.Lang.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE cResult   AS CHARACTER NO-UNDO.

        oTags = oDataAdminService:GetAuthTags("").
        IF VALID-OBJECT(oTags) THEN DO:
            oIterator = oTags:Iterator().
            DO WHILE oIterator:HasNext():
                oTag = CAST(oIterator:Next(), OpenEdge.DataAdmin.IAuthTag).
                IF VALID-OBJECT(oTag) THEN DO:
                    IF cResult = "" THEN cResult = SUBSTITUTE("&1|&2", oTag:Name, oTag:RoleName).
                    ELSE cResult = cResult + ", " + SUBSTITUTE("&1|&2", oTag:Name, oTag:RoleName).
                END.
            END.
        END.

        RETURN cResult.
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Associate an existing authorization tag to a new role (reassign)
     Notes:   Deletes the tag from current role and recreates under the new role
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL AssociateAuthTagToRole(INPUT pcCurrentRole AS CHARACTER,
                                                 INPUT pcAuthTagName AS CHARACTER,
                                                 INPUT pcNewRole     AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        DEFINE VARIABLE oTag     AS OpenEdge.DataAdmin.IAuthTag NO-UNDO.
        
        /* Get the tag under the current role */
        oTag = oDataAdminService:GetAuthTag(pcCurrentRole, pcAuthTagName).
        
        IF NOT VALID-OBJECT(oTag) THEN
            RETURN FALSE.
        
        /* Remove existing */
        lSuccess = oDataAdminService:DeleteAuthTag(pcCurrentRole, pcAuthTagName).
        IF NOT lSuccess THEN RETURN FALSE.
        
        /* Create new tag under new role */
        oTag = oDataAdminService:NewAuthTag(pcAuthTagName).
        oTag:RoleName = pcNewRole.
        lSuccess = oDataAdminService:CreateAuthTag(oTag).
        
        RETURN lSuccess.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to associate tag &1 from role &2 to &3: &4",
                          pcAuthTagName, pcCurrentRole, pcNewRole, oError:GetMessage(1))).
        END CATCH.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Grant security administrator privileges to a user
     Notes:   Uses DataAdminService:getAdministrator and updateAdministrator
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL GrantSecurityAdmin(INPUT pcUserName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess        AS LOGICAL        NO-UNDO.
        DEFINE VARIABLE oAdministrator  AS OpenEdge.DataAdmin.IAdministrator NO-UNDO.
        
        /* Get current administrator config */
        oAdministrator = oDataAdminService:getAdministrator().
        
        IF NOT VALID-OBJECT(oAdministrator) THEN
            UNDO, THROW NEW Progress.Lang.AppError("Unable to retrieve administrator configuration").
        
        /* Assign the given user as a security admin */
        oAdministrator:administrators = pcUserName.
        
        lSuccess = oDataAdminService:updateAdministrator(oAdministrator).
        
        RETURN lSuccess.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to grant security admin to &1: &2", 
                          pcUserName, oError:GetMessage(1))).
        END CATCH.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Set DDM configuration for a specific field
     Notes:   Uses OpenEdge 12.8 setDDMConfig method - signature: (table, field, maskval, authtag)
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL SetFieldDDMConfig(INPUT pcTableName AS CHARACTER,
                                            INPUT pcFieldName AS CHARACTER,
                                            INPUT pcMaskValue AS CHARACTER,
                                            INPUT pcAuthTag AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Use the actual DDM API method from OpenEdge 12.8 */
        lSuccess = oDataAdminService:setDDMConfig(pcTableName, pcFieldName, pcMaskValue, pcAuthTag).
        
        RETURN lSuccess.
        
        
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Configure field masking with different masking types
     Notes:   High-level method that calls setDDMConfig with mask value and auth tag
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL ConfigureFieldMasking(INPUT pcTableName AS CHARACTER,
                                               INPUT pcFieldName AS CHARACTER,
                                               INPUT pcMaskingType AS CHARACTER,
                                               INPUT pcMaskingValue AS CHARACTER,
                                               INPUT pcAuthTag AS CHARACTER):
        
        DEFINE VARIABLE cMaskValue AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Build mask value based on masking type */
        CASE pcMaskingType:
            WHEN "FULL" THEN
                cMaskValue = pcMaskingValue. /* Use the mask value directly */
            WHEN "PARTIAL" THEN
                cMaskValue = pcMaskingValue. /* Use the mask value directly */
            WHEN "CONDITIONAL" THEN
                cMaskValue = pcMaskingValue. /* Use the mask value directly */
            OTHERWISE
                cMaskValue = pcMaskingValue. /* Use as-is */
        END CASE.
        
        /* Apply the DDM configuration using the actual OpenEdge API */
        lSuccess = SetFieldDDMConfig(pcTableName, pcFieldName, cMaskValue, pcAuthTag).
        
        RETURN lSuccess.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to configure field masking for &1.&2: &3", 
                          pcTableName, pcFieldName, oError:GetMessage(1))).
        END CATCH.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Remove DDM configuration from a specific field
     Notes:   Uses OpenEdge 12.8 unsetDDMMask and unsetDDMAuthTag methods
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL RemoveFieldDDMConfig(INPUT pcTableName AS CHARACTER,
                                               INPUT pcFieldName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        DEFINE VARIABLE lMaskRemoved AS LOGICAL NO-UNDO.
        DEFINE VARIABLE lAuthTagRemoved AS LOGICAL NO-UNDO.
        
        /* Remove the mask value using unsetDDMMask */
        lMaskRemoved = oDataAdminService:unsetDDMMask(pcTableName, pcFieldName).
        
        /* Remove the authorization tag using unsetDDMAuthTag */
        lAuthTagRemoved = oDataAdminService:unsetDDMAuthTag(pcTableName, pcFieldName).
        
        /* Consider successful if either operation succeeded */
        lSuccess = lMaskRemoved OR lAuthTagRemoved.
        
        RETURN lSuccess.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to remove DDM config for field &1.&2: &3", 
                          pcTableName, pcFieldName, oError:GetMessage(1))).
        END CATCH.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Unset mask for a field
     Notes:   Uses OpenEdge 12.8 unsetDDMMask method
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL UnsetMaskForField(INPUT pcTableName AS CHARACTER,
                                            INPUT pcFieldName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Remove the mask value using unsetDDMMask */
        lSuccess = oDataAdminService:unsetDDMMask(pcTableName, pcFieldName).
        
        RETURN lSuccess.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to unset mask for field &1.&2: &3", 
                          pcTableName, pcFieldName, oError:GetMessage(1))).
        END CATCH.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Unset authorization tag for a field
     Notes:   Uses OpenEdge 12.8 unsetDDMAuthTag method
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL UnsetAuthTagForField(INPUT pcTableName AS CHARACTER,
                                               INPUT pcFieldName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Remove the authorization tag using unsetDDMAuthTag */
        lSuccess = oDataAdminService:unsetDDMAuthTag(pcTableName, pcFieldName).
        
        RETURN lSuccess.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to unset auth tag for field &1.&2: &3", 
                          pcTableName, pcFieldName, oError:GetMessage(1))).
        END CATCH.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Create authorization tag using OpenEdge.DataAdmin.*
     Notes:   Uses NewAuthTag and CreateAuthTag methods from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL CreateAuthorizationTag(INPUT pcDomainName AS CHARACTER,
                                                  INPUT pcAuthTagName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        DEFINE VARIABLE oAuthTag AS IAuthTag NO-UNDO.
        
        /* Create new AuthTag object using the service's factory method */
        oAuthTag = oDataAdminService:NewAuthTag(pcAuthTagName).
        oAuthTag:RoleName = pcDomainName.
        
        /* Create the authorization tag */
        lSuccess = oDataAdminService:CreateAuthTag(oAuthTag).
        
        RETURN lSuccess.
        
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Delete authorization tag
     Notes:   Uses DeleteAuthTag method from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL DeleteAuthorizationTag(INPUT pcDomainName AS CHARACTER,
                                                  INPUT pcAuthTagName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Delete the authorization tag */
        lSuccess = oDataAdminService:DeleteAuthTag(pcDomainName, pcAuthTagName).
        
        RETURN lSuccess.
        
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Update authorization tag
     Notes:   Gets existing tag, updates properties, and saves changes
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL UpdateAuthorizationTag(INPUT pcDomainName AS CHARACTER,
                                                  INPUT pcAuthTagName AS CHARACTER,
                                                  INPUT pcNewName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        DEFINE VARIABLE oAuthTag AS IAuthTag NO-UNDO.
        
        /* Get existing authorization tag */
        oAuthTag = oDataAdminService:GetAuthTag(pcDomainName, pcAuthTagName).
        
        IF VALID-OBJECT(oAuthTag) THEN DO:
            /* Update the tag name */
            oAuthTag:Name = pcNewName.
            
            /* Save changes - Note: OpenEdge DataAdmin may require delete/recreate */
            lSuccess = oDataAdminService:DeleteAuthTag(pcDomainName, pcAuthTagName).
            IF lSuccess THEN
                lSuccess = oDataAdminService:CreateAuthTag(oAuthTag).
        END.
        ELSE
            lSuccess = FALSE.
        
        RETURN lSuccess.
       
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Create role using OpenEdge.DataAdmin.*
     Notes:   Uses NewRole and CreateRole methods from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL CreateRole(INPUT pcRoleName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        DEFINE VARIABLE oRole AS IRole NO-UNDO.
        
        /* Create new Role object using the service's factory method */
        oRole = oDataAdminService:NewRole(pcRoleName).
        /* Mark as DDM role */
        IF VALID-OBJECT(oRole) THEN DO:
            /* Some OpenEdge versions expose IsDDM on IRole */
            oRole:IsDDM = TRUE.
        END.
        
        /* Create the role */
        lSuccess = oDataAdminService:CreateRole(oRole).
        
        RETURN lSuccess.
        
        
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Delete role using OpenEdge.DataAdmin.*
     Notes:   Uses DeleteRole method from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL DeleteRole(INPUT pcRoleName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Delete the role */
        lSuccess = oDataAdminService:DeleteRole(pcRoleName).
        
        RETURN lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Grant role to a user using OpenEdge.DataAdmin.*
     Notes:   Uses NewGrantedRole and CreateGrantedRole methods from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL GrantRoleToUser(INPUT pcUserName AS CHARACTER,
                                          INPUT pcRoleName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        DEFINE VARIABLE oGrantedRole AS IGrantedRole NO-UNDO.
        DEFINE VARIABLE oRole AS IRole NO-UNDO.
        
        /* Get the role first */
        oRole = oDataAdminService:GetRole(pcRoleName).
        
        IF VALID-OBJECT(oRole) THEN DO:
            /* Create new GrantedRole object using the service's factory method */
            oGrantedRole = oDataAdminService:NewGrantedRole().
            oGrantedRole:Grantee = pcUserName.
            oGrantedRole:Role = oRole.
            
            /* Grant the role */
            lSuccess = oDataAdminService:CreateGrantedRole(oGrantedRole).
        END.
        ELSE
            lSuccess = FALSE.
        
        RETURN lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Delete granted role using OpenEdge.DataAdmin.*
     Notes:   Uses DeleteGrantedRole method from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL DeleteGrantedRole(INPUT pcGrantId AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Delete the granted role */
        lSuccess = oDataAdminService:DeleteGrantedRole(pcGrantId).
        
        RETURN lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Create user using OpenEdge.DataAdmin.*
     Notes:   Uses User constructor and CreateUser methods from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL CreateUser(INPUT pcUserName AS CHARACTER,
                                     INPUT pcPassword AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        DEFINE VARIABLE oUser AS IUser NO-UNDO.
        
        /* Create new User object using direct constructor */
        oUser = NEW User(pcUserName).
        
        /* Note: Password setting may require additional configuration */
        /* depending on the authentication system being used */
        
        /* Create the user */
        lSuccess = oDataAdminService:CreateUser(oUser).
        
        RETURN lSuccess.
        /*
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to create user &1: &2", 
                          pcUserName, oError:GetMessage(1))).
        END CATCH.
        */
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Delete user using OpenEdge.DataAdmin.*
     Notes:   Uses DeleteUser method from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL DeleteUser(INPUT pcUserName AS CHARACTER):
        
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Delete the user */
        lSuccess = oDataAdminService:DeleteUser(pcUserName).
        
        RETURN lSuccess.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Get mask and authorization tag for any field in a table
     Notes:   Uses GetFieldDDMConfig method from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetMaskAndAuthTagForField(INPUT pcTableName AS CHARACTER,
                                                       INPUT pcFieldName AS CHARACTER,
                                                       INPUT pcUserName AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cMaskValue AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cAuthTag AS CHARACTER NO-UNDO.
        DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
        
        /* Use the GetFieldDDMConfig method to retrieve mask and auth tag */
        lSuccess = GetFieldDDMConfig(pcTableName, pcFieldName, OUTPUT cMaskValue, OUTPUT cAuthTag).
        
        IF lSuccess THEN DO:
            /* Format the result to show both mask value and authorization tag */
            cResult = "Mask: " + (IF cMaskValue <> "" THEN cMaskValue ELSE "(none)") + 
                     ", AuthTag: " + (IF cAuthTag <> "" THEN cAuthTag ELSE "(none)").
        END.
        ELSE DO:
            cResult = "No DDM configuration found for field '" + pcFieldName + 
                     "' in table '" + pcTableName + "'".
        END.
        
        /* Note: pcUserName parameter is currently not used in the underlying API */
        /* Future enhancement: filter results based on user permissions */
        
        RETURN cResult.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Get authorization tag and associated user-defined role
     Notes:   Uses GetAuthTag method from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetAuthTagAndRole(INPUT pcDomainName AS CHARACTER,
                                              INPUT pcAuthTagName AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oAuthTag AS IAuthTag NO-UNDO.
        
        /* Get the authorization tag */
        oAuthTag = oDataAdminService:GetAuthTag(pcDomainName, pcAuthTagName).
        
        IF VALID-OBJECT(oAuthTag) THEN DO:
            cResult = SUBSTITUTE("AuthTag: &1, Role: &2", oAuthTag:Name, oAuthTag:RoleName).
        END.
        ELSE
            cResult = "AuthTag not found".
        
        RETURN cResult.
        
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Get role grants for a user
     Notes:   Uses GetGrantedRoles method from IDataAdminService
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetRoleGrantsForUser(INPUT pcUserName AS CHARACTER):
        
        DEFINE VARIABLE cResult AS CHARACTER NO-UNDO.
        DEFINE VARIABLE oGrantedRoles AS IGrantedRoleSet NO-UNDO.
        DEFINE VARIABLE oGrantedRole AS IGrantedRole NO-UNDO.
        DEFINE VARIABLE oIterator AS OpenEdge.DataAdmin.Lang.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE iCount AS INTEGER NO-UNDO.
        
        /* Get granted roles with filter for specific user */
        oGrantedRoles = oDataAdminService:GetGrantedRoles(SUBSTITUTE("Userid eq '&1'", pcUserName)).
        
        IF VALID-OBJECT(oGrantedRoles) THEN DO:
            cResult = "Granted Roles: ".
            oIterator = oGrantedRoles:Iterator().
            DO WHILE oIterator:HasNext():
                oGrantedRole = CAST(oIterator:Next(), IGrantedRole).
                IF VALID-OBJECT(oGrantedRole) AND VALID-OBJECT(oGrantedRole:Role) THEN
                    cResult = cResult + oGrantedRole:Role:Name + ", ".
            END.
            /* Remove trailing comma */
            IF LENGTH(cResult) > 16 THEN
                cResult = SUBSTRING(cResult, 1, LENGTH(cResult) - 2).
        END.
        ELSE
            cResult = "No granted roles found".
        
        RETURN cResult.
        
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Cleanup resources
     Notes:   
    ------------------------------------------------------------------------------*/
    DESTRUCTOR PUBLIC DataAdminMaskingService():
        
        IF VALID-OBJECT(oDataAdminService) THEN
            DELETE OBJECT oDataAdminService.
            
    END DESTRUCTOR.

    /*------------------------------------------------------------------------------
     Purpose: List all roles as a comma-separated string
     Notes:   Iterates IRoleSet and concatenates names
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetAllRoles():
        DEFINE VARIABLE oRoles     AS OpenEdge.DataAdmin.IRoleSet NO-UNDO.
        DEFINE VARIABLE oRole      AS OpenEdge.DataAdmin.IRole NO-UNDO.
        DEFINE VARIABLE oIterator  AS OpenEdge.DataAdmin.Lang.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE cResult    AS CHARACTER NO-UNDO.

        /* Only list DDM roles */
        oRoles = oDataAdminService:GetRoles("IsDDM='true'").
        IF VALID-OBJECT(oRoles) THEN DO:
            oIterator = oRoles:Iterator().
            DO WHILE oIterator:HasNext():
                oRole = CAST(oIterator:Next(), OpenEdge.DataAdmin.IRole).
                IF VALID-OBJECT(oRole) THEN DO:
                    IF cResult = "" THEN cResult = oRole:Name.
                    ELSE cResult = cResult + ", " + oRole:Name.
                END.
            END.
        END.
        RETURN cResult.

        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List all authorization tags across all roles as a comma-separated string
     Notes:   Iterates IAuthTagSet with no filter
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetAllAuthTags():
        DEFINE VARIABLE oTags     AS OpenEdge.DataAdmin.IAuthTagSet NO-UNDO.
        DEFINE VARIABLE oTag      AS OpenEdge.DataAdmin.IAuthTag NO-UNDO.
        DEFINE VARIABLE oIterator AS OpenEdge.DataAdmin.Lang.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE cResult   AS CHARACTER NO-UNDO.

        oTags = oDataAdminService:GetAuthTags("").
        IF VALID-OBJECT(oTags) THEN DO:
            oIterator = oTags:Iterator().
            DO WHILE oIterator:HasNext():
                oTag = CAST(oIterator:Next(), OpenEdge.DataAdmin.IAuthTag).
                IF VALID-OBJECT(oTag) THEN DO:
                    IF cResult = "" THEN cResult = oTag:Name.
                    ELSE cResult = cResult + ", " + oTag:Name.
                END.
            END.
        END.

        RETURN cResult.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List all users as a comma-separated string
     Notes:   Iterates IUserSet and concatenates names
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetAllUsers():
        DEFINE VARIABLE oUsers     AS OpenEdge.DataAdmin.IUserSet NO-UNDO.
        DEFINE VARIABLE oUser      AS OpenEdge.DataAdmin.IUser NO-UNDO.
        DEFINE VARIABLE oIterator  AS OpenEdge.DataAdmin.Lang.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE cResult    AS CHARACTER NO-UNDO.

        oUsers = oDataAdminService:GetUsers("").
        IF VALID-OBJECT(oUsers) THEN DO:
            oIterator = oUsers:Iterator().
            DO WHILE oIterator:HasNext():
                oUser = CAST(oIterator:Next(), OpenEdge.DataAdmin.IUser).
                IF VALID-OBJECT(oUser) THEN DO:
                    IF cResult = "" THEN cResult = oUser:Name.
                    ELSE cResult = cResult + ", " + oUser:Name.
                END.
            END.
        END.
        RETURN cResult.

    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: List auth tags for a role as a comma-separated string
     Notes:   Iterates IAuthTagSet
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetAuthTagsForRole(INPUT pcRoleName AS CHARACTER):
        DEFINE VARIABLE oTags     AS OpenEdge.DataAdmin.IAuthTagSet NO-UNDO.
        DEFINE VARIABLE oTag      AS OpenEdge.DataAdmin.IAuthTag NO-UNDO.
        DEFINE VARIABLE oIterator AS OpenEdge.DataAdmin.Lang.Collections.IIterator NO-UNDO.
        DEFINE VARIABLE cResult   AS CHARACTER NO-UNDO.

        /* filter by RoleName eq 'pcRoleName' */
        oTags = oDataAdminService:GetAuthTags(SUBSTITUTE("RoleName eq '&1'", pcRoleName)).

        IF VALID-OBJECT(oTags) THEN DO:
            oIterator = oTags:Iterator().
            DO WHILE oIterator:HasNext():
                oTag = CAST(oIterator:Next(), OpenEdge.DataAdmin.IAuthTag).
                IF VALID-OBJECT(oTag) THEN DO:
                    IF cResult = "" THEN cResult = oTag:Name.
                    ELSE cResult = cResult + ", " + oTag:Name.
                END.
            END.
        END.

        RETURN cResult.

        
    END METHOD.

END CLASS.
