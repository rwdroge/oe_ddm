/*------------------------------------------------------------------------
    File        : api_test_examples.p
    Purpose     : Test examples for DDM REST API endpoints
    Syntax      : 
    Description : Demonstrates how to test the complete DDM API using ABL HTTP client
    Author(s)   : Progress Developer
    Created     : 
    Notes       : Run this after starting PASOE with DDM API
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Net.HTTP.*.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE oHttpClient AS IHttpClient NO-UNDO.
DEFINE VARIABLE oRequest AS IHttpRequest NO-UNDO.
DEFINE VARIABLE oResponse AS IHttpResponse NO-UNDO.
DEFINE VARIABLE cBaseUrl AS CHARACTER NO-UNDO INITIAL "http://localhost:8080/api/masking".
DEFINE VARIABLE oJsonRequest AS JsonObject NO-UNDO.
DEFINE VARIABLE oJsonResponse AS JsonObject NO-UNDO.

/* Initialize HTTP client */
oHttpClient = ClientBuilder:Build():Client.

MESSAGE "=== Complete DDM REST API Test Examples ===" VIEW-AS ALERT-BOX.

/* Test 1: Health Check */
MESSAGE "=== Test 1: Health Check ===" VIEW-AS ALERT-BOX.

oRequest = RequestBuilder:Get(cBaseUrl + "/health"):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Health Check Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 2: Set DDM Configuration (DEPRECATED) */
/*
MESSAGE "=== Test 2: Set DDM Configuration ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("tableName", "Customer").
oJsonRequest:Add("fieldName", "CustNum").
oJsonRequest:Add("maskValue", "****").
oJsonRequest:Add("authTag", "SENSITIVE").

oRequest = RequestBuilder:Post(cBaseUrl + "/set-ddm-config", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Set DDM Config Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.
*/

/* Test 3: Configure Field Masking */
MESSAGE "=== Test 3: Configure Field Masking ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("tableName", "Customer").
oJsonRequest:Add("fieldName", "Name").
oJsonRequest:Add("maskingType", "PARTIAL").
oJsonRequest:Add("maskingValue", "XXXX").
oJsonRequest:Add("authTag", "PII").

oRequest = RequestBuilder:Post(cBaseUrl + "/configure-field", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Configure Field Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 4: Get Mask and Auth Tag for Field */
MESSAGE "=== Test 4: Get Mask and Auth Tag ===" VIEW-AS ALERT-BOX.

oRequest = RequestBuilder:Get(cBaseUrl + "/mask-and-auth-tag?tableName=Customer&fieldName=CustNum&userName=testuser"):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Get Mask/Auth Tag Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 5: Create Authorization Tag */
MESSAGE "=== Test 5: Create Authorization Tag ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("domainName", "TestDomain").
oJsonRequest:Add("authTagName", "CONFIDENTIAL").

oRequest = RequestBuilder:Post(cBaseUrl + "/create-auth-tag", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Create Auth Tag Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 6: Create Role */
MESSAGE "=== Test 6: Create Role ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("roleName", "DataAnalyst").

oRequest = RequestBuilder:Post(cBaseUrl + "/create-role", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Create Role Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 6b: Create Another Role (for reassignment scenarios) */
MESSAGE "=== Test 6b: Create Role (DataReviewer) ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("roleName", "DataReviewer").

oRequest = RequestBuilder:Post(cBaseUrl + "/create-role", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Create Role (Reviewer) Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 7: Create User */
MESSAGE "=== Test 7: Create User ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("userName", "testuser").
oJsonRequest:Add("password", "testpass123").

oRequest = RequestBuilder:Post(cBaseUrl + "/create-user", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Create User Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 8: Grant Role to User */
MESSAGE "=== Test 8: Grant Role to User ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("userName", "testuser").
oJsonRequest:Add("roleName", "DataAnalyst").

oRequest = RequestBuilder:Post(cBaseUrl + "/grant-role", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Grant Role Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 8b: Grant Role to Multiple Users */
MESSAGE "=== Test 8b: Grant Role to Multiple Users ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
/* Example users; adjust as needed */
DEFINE VARIABLE oUsers AS JsonArray NO-UNDO.
oUsers = NEW JsonArray().
oUsers:Add("testuser").
oUsers:Add("anotheruser").
oJsonRequest:Add("userNames", oUsers).
oJsonRequest:Add("roleName", "DataAnalyst").

oRequest = RequestBuilder:Post(cBaseUrl + "/grant-roles", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Grant Roles Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 9: Get User Role Grants */
MESSAGE "=== Test 9: Get User Role Grants ===" VIEW-AS ALERT-BOX.

oRequest = RequestBuilder:Get(cBaseUrl + "/user-role-grants?userName=testuser"):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("User Role Grants Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 9b: Grant Security Admin (GET) */
MESSAGE "=== Test 9b: Grant Security Admin ===" VIEW-AS ALERT-BOX.

oRequest = RequestBuilder:Get(cBaseUrl + "/grant-security-admin?userName=testuser"):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Grant Security Admin Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 10: Get Auth Tag and Role */
MESSAGE "=== Test 10: Get Auth Tag and Role ===" VIEW-AS ALERT-BOX.

oRequest = RequestBuilder:Get(cBaseUrl + "/auth-tag-role?domainName=TestDomain&authTagName=CONFIDENTIAL"):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Auth Tag Role Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 10b: Get Role Auth Tags */
MESSAGE "=== Test 10b: Get Role Auth Tags ===" VIEW-AS ALERT-BOX.

oRequest = RequestBuilder:Get(cBaseUrl + "/role-auth-tags?roleName=DataAnalyst"):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Role Auth Tags Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 11: Unset Mask */
MESSAGE "=== Test 11: Unset Mask ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("tableName", "Customer").
oJsonRequest:Add("fieldName", "CustNum").

oRequest = RequestBuilder:Post(cBaseUrl + "/unset-mask", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Unset Mask Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 12: Unset Auth Tag */
MESSAGE "=== Test 12: Unset Auth Tag ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("tableName", "Customer").
oJsonRequest:Add("fieldName", "Name").

oRequest = RequestBuilder:Post(cBaseUrl + "/unset-auth-tag", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Unset Auth Tag Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 13: Update Authorization Tag */
MESSAGE "=== Test 13: Update Authorization Tag ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("domainName", "TestDomain").
oJsonRequest:Add("authTagName", "CONFIDENTIAL").
oJsonRequest:Add("newName", "TOP_SECRET").

oRequest = RequestBuilder:Post(cBaseUrl + "/update-auth-tag", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Update Auth Tag Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 14: Remove DDM Configuration (DEPRECATED) */
/*
MESSAGE "=== Test 14: Remove DDM Configuration ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("tableName", "Customer").
oJsonRequest:Add("fieldName", "Name").

oRequest = RequestBuilder:Delete(cBaseUrl + "/remove-ddm-config", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Remove DDM Config Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.
*/

/* Test 15: Delete Role */
MESSAGE "=== Test 15: Delete Role ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("roleName", "DataAnalyst").

oRequest = RequestBuilder:Delete(cBaseUrl + "/delete-role", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Delete Role Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 16: Delete Authorization Tag */
MESSAGE "=== Test 16: Delete Authorization Tag ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("domainName", "TestDomain").
oJsonRequest:Add("authTagName", "TOP_SECRET").

oRequest = RequestBuilder:Delete(cBaseUrl + "/delete-auth-tag", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Delete Auth Tag Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 17: Delete User */
MESSAGE "=== Test 17: Delete User ===" VIEW-AS ALERT-BOX.

oJsonRequest = NEW JsonObject().
oJsonRequest:Add("userName", "testuser").

oRequest = RequestBuilder:Delete(cBaseUrl + "/delete-user", oJsonRequest):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Delete User Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 19: Associate Auth Tag to New Role */
MESSAGE "=== Test 19: Associate Auth Tag to New Role ===" VIEW-AS ALERT-BOX.

/* This reassigns the 'CONFIDENTIAL' tag in 'TestDomain' from DataAnalyst to DataReviewer. */
oRequest = RequestBuilder:Get(cBaseUrl + "/associate-auth-tag-role?currentRole=DataAnalyst&authTagName=CONFIDENTIAL&newRole=DataReviewer"):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Associate Auth Tag Role Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

/* Test 18: Error Handling - Invalid Endpoint */
MESSAGE "=== Test 18: Error Handling - Invalid Endpoint ===" VIEW-AS ALERT-BOX.

oRequest = RequestBuilder:Get(cBaseUrl + "/invalid-endpoint"):Request.
oResponse = oHttpClient:Execute(oRequest).

MESSAGE SUBSTITUTE("Invalid Endpoint Response:~nStatus: &1~nContent: &2",
                  oResponse:StatusCode,
                  oResponse:Entity:ToString()) VIEW-AS ALERT-BOX.

MESSAGE "Complete DDM API testing completed! All endpoints have been tested." VIEW-AS ALERT-BOX.

CATCH oError AS Progress.Lang.Error:
    MESSAGE SUBSTITUTE("API Test Error: &1", oError:GetMessage(1)) VIEW-AS ALERT-BOX.
END CATCH.
