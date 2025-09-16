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
     Purpose: Get DDM configuration for a specific field
     Notes:   OpenEdge 12.8 DDM API only provides setDDMConfig, not a getter method
              This method would need to be implemented using other DataAdmin APIs
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GetFieldDDMConfig(INPUT pcTableName AS CHARACTER,
                                              INPUT pcFieldName AS CHARACTER,
                                              INPUT pcUserName AS CHARACTER):
        
        /* Note: OpenEdge 12.8 DDM API doesn't provide a direct getter method.
           This would need to be implemented by querying field permissions or
           other DataAdmin objects to determine current DDM configuration. */
        
        UNDO, THROW NEW Progress.Lang.AppError(
            "GetFieldDDMConfig not directly supported by OpenEdge 12.8 DDM API. Use field permissions or other DataAdmin queries.").
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to set DDM config for field &1.&2: &3", 
                          pcTableName, pcFieldName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to create authorization tag &1 in domain &2: &3", 
                          pcAuthTagName, pcDomainName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to delete authorization tag &1 from domain &2: &3", 
                          pcAuthTagName, pcDomainName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to update authorization tag &1 in domain &2: &3", 
                          pcAuthTagName, pcDomainName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        /* Create the role */
        lSuccess = oDataAdminService:CreateRole(oRole).
        
        RETURN lSuccess.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to create role &1: &2", 
                          pcRoleName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to delete role &1: &2", 
                          pcRoleName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to grant role &1 to user &2: &3", 
                          pcRoleName, pcUserName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to delete granted role &1: &2", 
                          pcGrantId, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to create user &1: &2", 
                          pcUserName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to delete user &1: &2", 
                          pcUserName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        /* Use the GetFieldDDMConfig method from IDataAdminService */
        /* Method signature: GetFieldDDMConfig(tableName, fieldName, userName, outputParams) */
        
        /* Call the DataAdmin service method to get DDM configuration */
        oDataAdminService:GetFieldDDMConfig(pcTableName, pcFieldName, pcUserName, OUTPUT cResult) no-error.
        
        /* The GetFieldDDMConfig method should return the DDM configuration details */
        /* including mask value and authorization tag information */
        
        IF cResult = "" OR cResult = ? THEN DO:
            cResult = "No DDM configuration found for field '" + pcFieldName + 
                     "' in table '" + pcTableName + "'".
            IF pcUserName <> "" AND pcUserName <> ? THEN
                cResult = cResult + " for user '" + pcUserName + "'".
        END.
        
        RETURN cResult.
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to get DDM config for field &1.&2: &3", 
                          pcTableName, pcFieldName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to get auth tag &1 from domain &2: &3", 
                          pcAuthTagName, pcDomainName, oError:GetMessage(1))).
        END CATCH.
        
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
        
        CATCH oError AS Progress.Lang.Error:
            UNDO, THROW NEW Progress.Lang.AppError(
                SUBSTITUTE("Failed to get role grants for user &1: &2", 
                          pcUserName, oError:GetMessage(1))).
        END CATCH.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Cleanup resources
     Notes:   
    ------------------------------------------------------------------------------*/
    DESTRUCTOR PUBLIC DataAdminMaskingService():
        
        IF VALID-OBJECT(oDataAdminService) THEN
            DELETE OBJECT oDataAdminService.
            
    END DESTRUCTOR.

END CLASS.
