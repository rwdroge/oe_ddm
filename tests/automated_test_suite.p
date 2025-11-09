/*------------------------------------------------------------------------
    File        : automated_test_suite.p
    Purpose     : Automated test suite for DDM API endpoints
    Syntax      : 
    Description : Comprehensive test suite that validates all DDM API endpoints
    Author(s)   : Progress Developer
    Created     : 2025-09-16
    Notes       : Run this program to execute all API tests automatically
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE VARIABLE hClient        AS HANDLE     NO-UNDO.
DEFINE VARIABLE cBaseUrl       AS CHARACTER  NO-UNDO INITIAL "http://localhost:8080/api/masking".
DEFINE VARIABLE iTestsPassed   AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iTestsFailed   AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE iTestsTotal    AS INTEGER    NO-UNDO INITIAL 0.
DEFINE VARIABLE lVerbose       AS LOGICAL    NO-UNDO INITIAL TRUE.

/* Test result tracking */
DEFINE TEMP-TABLE ttTestResults NO-UNDO
    FIELD testName    AS CHARACTER
    FIELD endpoint    AS CHARACTER
    FIELD method      AS CHARACTER
    FIELD expected    AS INTEGER
    FIELD actual      AS INTEGER
    FIELD passed      AS LOGICAL
    FIELD message     AS CHARACTER
    FIELD duration    AS DECIMAL
    INDEX idx1 testName.

/* ***************************  Main Block  *************************** */

MESSAGE "Starting DDM API Automated Test Suite...".
MESSAGE "Base URL: " + cBaseUrl.
MESSAGE "".

/* Initialize HTTP client */
CREATE "WinHttp.WinHttpRequest.5.1" hClient.

/* Run all test categories */
RUN TestHealthEndpoint.
RUN TestFieldOperationEndpoints.
RUN TestAuthTagEndpoints.
RUN TestRoleEndpoints.
RUN TestUserEndpoints.
RUN TestInformationEndpoints.
RUN TestErrorHandling.

/* Generate test report */
RUN GenerateTestReport.

/* Cleanup */
DELETE OBJECT hClient.

MESSAGE "".
MESSAGE "Test Suite Complete!".
MESSAGE "Total Tests: " + STRING(iTestsTotal).
MESSAGE "Passed: " + STRING(iTestsPassed).
MESSAGE "Failed: " + STRING(iTestsFailed).
MESSAGE "Success Rate: " + STRING(ROUND((iTestsPassed / iTestsTotal) * 100, 2)) + "%".

/* ***************************  Procedures  *************************** */

PROCEDURE TestHealthEndpoint:
    
    MESSAGE "Testing Health Endpoint...".
    
    RUN ExecuteTest(
        INPUT "Health Check",
        INPUT "/health",
        INPUT "GET",
        INPUT "",
        INPUT 200
    ).
    
END PROCEDURE.


PROCEDURE TestFieldOperationEndpoints:
    
    MESSAGE "Testing Field Operation Endpoints...".
    
    /* Test Configure Field */
    RUN ExecuteTest(
        INPUT "Configure Field",
        INPUT "/configure-field",
        INPUT "POST",
        INPUT '~{"tableName":"Customer","fieldName":"Name","maskingType":"PARTIAL","maskingValue":"XXXX","authTag":"PII"~}',
        INPUT 200
    ).
    
    /* Test Unset Mask */
    RUN ExecuteTest(
        INPUT "Unset Mask",
        INPUT "/unset-mask",
        INPUT "POST",
        INPUT '~{"tableName":"Customer","fieldName":"Name"~}',
        INPUT 200
    ).
    
    /* Test Unset Auth Tag */
    RUN ExecuteTest(
        INPUT "Unset Auth Tag",
        INPUT "/unset-auth-tag",
        INPUT "POST",
        INPUT '~{"tableName":"Customer","fieldName":"Name"~}',
        INPUT 200
    ).
    
END PROCEDURE.

PROCEDURE TestAuthTagEndpoints:
    
    MESSAGE "Testing Authorization Tag Endpoints...".
    
    /* Test Create Auth Tag */
    RUN ExecuteTest(
        INPUT "Create Auth Tag",
        INPUT "/create-auth-tag",
        INPUT "POST",
        INPUT '~{"domainName":"TestDomain","authTagName":"CONFIDENTIAL"~}',
        INPUT 201
    ).
    
    /* Test Update Auth Tag */
    RUN ExecuteTest(
        INPUT "Update Auth Tag",
        INPUT "/update-auth-tag",
        INPUT "POST",
        INPUT '~{"domainName":"TestDomain","authTagName":"CONFIDENTIAL","newName":"TOP_SECRET"~}',
        INPUT 200
    ).
    
    /* Test Delete Auth Tag */
    RUN ExecuteTest(
        INPUT "Delete Auth Tag",
        INPUT "/delete-auth-tag",
        INPUT "DELETE",
        INPUT '~{"domainName":"TestDomain","authTagName":"TOP_SECRET"~}',
        INPUT 200
    ).
    
END PROCEDURE.

PROCEDURE TestRoleEndpoints:
    
    MESSAGE "Testing Role Management Endpoints...".
    
    /* Test Create Role */
    RUN ExecuteTest(
        INPUT "Create Role",
        INPUT "/create-role",
        INPUT "POST",
        INPUT '~{"roleName":"TestRole"~}',
        INPUT 201
    ).
    
    /* Test Grant Role */
    RUN ExecuteTest(
        INPUT "Grant Role",
        INPUT "/grant-role",
        INPUT "POST",
        INPUT '~{"userName":"testuser","roleName":"TestRole"~}',
        INPUT 200
    ).
    
    /* Test Delete Granted Role */
    RUN ExecuteTest(
        INPUT "Delete Granted Role",
        INPUT "/delete-granted-role",
        INPUT "DELETE",
        INPUT '~{"grantId":"test-grant-123"~}',
        INPUT 200
    ).
    
    /* Test Delete Role */
    RUN ExecuteTest(
        INPUT "Delete Role",
        INPUT "/delete-role",
        INPUT "DELETE",
        INPUT '~{"roleName":"TestRole"~}',
        INPUT 200
    ).
    
END PROCEDURE.

PROCEDURE TestUserEndpoints:
    
    MESSAGE "Testing User Management Endpoints...".
    
    /* Test Create User */
    RUN ExecuteTest(
        INPUT "Create User",
        INPUT "/create-user",
        INPUT "POST",
        INPUT '~{"userName":"testuser","password":"testpass123"~}',
        INPUT 201
    ).
    
    /* Test Delete User */
    RUN ExecuteTest(
        INPUT "Delete User",
        INPUT "/delete-user",
        INPUT "DELETE",
        INPUT '~{"userName":"testuser"~}',
        INPUT 200
    ).
    
END PROCEDURE.

PROCEDURE TestInformationEndpoints:
    
    MESSAGE "Testing Information Retrieval Endpoints...".
    
    /* Test Get Mask and Auth Tag */
    RUN ExecuteTest(
        INPUT "Get Mask and Auth Tag",
        INPUT "/mask-and-auth-tag?tableName=Customer&fieldName=CustNum",
        INPUT "GET",
        INPUT "",
        INPUT 200
    ).
    
    /* Test Get Auth Tag Role */
    RUN ExecuteTest(
        INPUT "Get Auth Tag Role",
        INPUT "/auth-tag-role?domainName=TestDomain&authTagName=SENSITIVE",
        INPUT "GET",
        INPUT "",
        INPUT 200
    ).
    
    /* Test Get User Role Grants */
    RUN ExecuteTest(
        INPUT "Get User Role Grants",
        INPUT "/user-role-grants?userName=testuser",
        INPUT "GET",
        INPUT "",
        INPUT 200
    ).
    
    /* Removed deprecated /ddm-config test */
    
END PROCEDURE.

PROCEDURE TestErrorHandling:
    
    MESSAGE "Testing Error Handling...".
    
    /* Removed deprecated /set-ddm-config error handling tests */
    
    /* Test non-existent endpoint */
    RUN ExecuteTest(
        INPUT "Non-existent Endpoint",
        INPUT "/invalid-endpoint",
        INPUT "GET",
        INPUT "",
        INPUT 404
    ).
    
END PROCEDURE.

PROCEDURE ExecuteTest:
    DEFINE INPUT PARAMETER pcTestName   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pcEndpoint   AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pcMethod     AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER pcBody       AS CHARACTER NO-UNDO.
    DEFINE INPUT PARAMETER piExpected   AS INTEGER   NO-UNDO.
    
    DEFINE VARIABLE cUrl        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE iStatus     AS INTEGER   NO-UNDO.
    DEFINE VARIABLE cResponse   AS CHARACTER NO-UNDO.
    DEFINE VARIABLE lPassed     AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE cMessage    AS CHARACTER NO-UNDO.
    DEFINE VARIABLE dStartTime  AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE dEndTime    AS DECIMAL   NO-UNDO.
    DEFINE VARIABLE dDuration   AS DECIMAL   NO-UNDO.
    
    /* Record start time */
    dStartTime = ETIME(TRUE).
    
    /* Build full URL */
    cUrl = cBaseUrl + pcEndpoint.
    
    /* Execute HTTP request */
    DO ON ERROR UNDO, LEAVE:
        
        hClient:Open(pcMethod, cUrl, FALSE).
        
        IF pcMethod = "POST" OR pcMethod = "DELETE" THEN DO:
            hClient:SetRequestHeader("Content-Type", "application/json").
            IF pcBody <> "" THEN
                hClient:Send(pcBody).
            ELSE
                hClient:Send().
        END.
        ELSE DO:
            hClient:Send().
        END.
        
        /* Get response */
        iStatus = hClient:Status.
        cResponse = hClient:ResponseText.
        
    END. /* DO ON ERROR */
    
    /* Record end time and calculate duration */
    dEndTime = ETIME(TRUE).
    dDuration = dEndTime - dStartTime.
    
    /* Evaluate test result */
    lPassed = (iStatus = piExpected).
    
    IF lPassed THEN DO:
        iTestsPassed = iTestsPassed + 1.
        cMessage = "PASSED".
    END.
    ELSE DO:
        iTestsFailed = iTestsFailed + 1.
        cMessage = "FAILED - Expected: " + STRING(piExpected) + ", Got: " + STRING(iStatus).
    END.
    
    iTestsTotal = iTestsTotal + 1.
    
    /* Store test result */
    CREATE ttTestResults.
    ASSIGN
        ttTestResults.testName = pcTestName
        ttTestResults.endpoint = pcEndpoint
        ttTestResults.method   = pcMethod
        ttTestResults.expected = piExpected
        ttTestResults.actual   = iStatus
        ttTestResults.passed   = lPassed
        ttTestResults.message  = cMessage
        ttTestResults.duration = dDuration.
    
    /* Output result if verbose */
    IF lVerbose THEN DO:
        MESSAGE "  " + pcTestName + ": " + cMessage + " (" + STRING(dDuration, ">>9.999") + "ms)".
    END.
    
    CATCH eError AS Progress.Lang.Error:
        iTestsFailed = iTestsFailed + 1.
        iTestsTotal = iTestsTotal + 1.
        
        CREATE ttTestResults.
        ASSIGN
            ttTestResults.testName = pcTestName
            ttTestResults.endpoint = pcEndpoint
            ttTestResults.method   = pcMethod
            ttTestResults.expected = piExpected
            ttTestResults.actual   = 0
            ttTestResults.passed   = FALSE
            ttTestResults.message  = "ERROR: " + eError:GetMessage(1)
            ttTestResults.duration = 0.
        
        IF lVerbose THEN DO:
            MESSAGE "  " + pcTestName + ": ERROR - " + eError:GetMessage(1).
        END.
    END CATCH.
    
END PROCEDURE.

PROCEDURE GenerateTestReport:
    
    DEFINE VARIABLE cReportFile AS CHARACTER NO-UNDO.
    DEFINE VARIABLE cTimestamp  AS CHARACTER NO-UNDO.
    
    /* Generate timestamp for report filename */
    cTimestamp = STRING(TODAY, "99/99/9999") + "_" + STRING(TIME, "HH:MM:SS").
    cTimestamp = REPLACE(cTimestamp, "/", "-").
    cTimestamp = REPLACE(cTimestamp, ":", "-").
    cReportFile = "test_report_" + cTimestamp + ".txt".
    
    MESSAGE "".
    MESSAGE "Generating detailed test report: " + cReportFile.
    
    OUTPUT TO VALUE(cReportFile).
    
    PUT UNFORMATTED 
        "DDM API Test Suite Report" SKIP
        "=========================" SKIP
        "Generated: " + STRING(NOW, "99/99/9999 HH:MM:SS") SKIP
        "Base URL: " + cBaseUrl SKIP
        "" SKIP
        "Summary:" SKIP
        "--------" SKIP
        "Total Tests: " + STRING(iTestsTotal) SKIP
        "Passed: " + STRING(iTestsPassed) SKIP
        "Failed: " + STRING(iTestsFailed) SKIP
        "Success Rate: " + STRING(ROUND((iTestsPassed / iTestsTotal) * 100, 2)) + "%" SKIP
        "" SKIP
        "Detailed Results:" SKIP
        "----------------" SKIP.
    
    FOR EACH ttTestResults BY ttTestResults.testName:
        PUT UNFORMATTED
            ttTestResults.testName FORMAT "X(30)" " | "
            ttTestResults.method FORMAT "X(6)" " | "
            ttTestResults.endpoint FORMAT "X(25)" " | "
            "Expected: " + STRING(ttTestResults.expected, "999") " | "
            "Actual: " + STRING(ttTestResults.actual, "999") " | "
            (IF ttTestResults.passed THEN "PASS" ELSE "FAIL") FORMAT "X(4)" " | "
            STRING(ttTestResults.duration, ">>9.999") + "ms" SKIP.
    END.
    
    PUT UNFORMATTED "" SKIP "Failed Tests Details:" SKIP "--------------------" SKIP.
    
    FOR EACH ttTestResults WHERE NOT ttTestResults.passed BY ttTestResults.testName:
        PUT UNFORMATTED
            ttTestResults.testName + ": " + ttTestResults.message SKIP.
    END.
    
    OUTPUT CLOSE.
    
END PROCEDURE.
