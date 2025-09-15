/*------------------------------------------------------------------------
    File        : MaskingAlgorithms.cls
    Purpose     : Collection of data masking algorithms
    Syntax      : 
    Description : Implements various masking techniques for different data types
    Author(s)   : Progress Developer
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS src.utils.MaskingAlgorithms:

    /*------------------------------------------------------------------------------
     Purpose: Mask Social Security Number
     Notes:   Format: XXX-XX-1234 (preserve last 4 digits)
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER MaskSSN(INPUT pcSSN AS CHARACTER):
        
        DEFINE VARIABLE cMasked AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClean AS CHARACTER NO-UNDO.
        
        /* Remove any formatting */
        cClean = REPLACE(REPLACE(pcSSN, "-", ""), " ", "").
        
        IF LENGTH(cClean) = 9 THEN
            cMasked = "XXX-XX-" + SUBSTRING(cClean, 6, 4).
        ELSE
            cMasked = "XXX-XX-XXXX".
            
        RETURN cMasked.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Mask Credit Card Number
     Notes:   Format: XXXX-XXXX-XXXX-1234 (preserve last 4 digits)
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER MaskCreditCard(INPUT pcCardNumber AS CHARACTER):
        
        DEFINE VARIABLE cMasked AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClean AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iLength AS INTEGER NO-UNDO.
        
        /* Remove any formatting */
        cClean = REPLACE(REPLACE(REPLACE(pcCardNumber, "-", ""), " ", ""), "*", "").
        iLength = LENGTH(cClean).
        
        IF iLength >= 13 AND iLength <= 19 THEN DO:
            /* Show first digit and last 4 digits */
            cMasked = SUBSTRING(cClean, 1, 1) + 
                     FILL("X", iLength - 5) + 
                     SUBSTRING(cClean, iLength - 3, 4).
            
            /* Add formatting for readability */
            IF iLength = 16 THEN
                cMasked = SUBSTRING(cMasked, 1, 4) + "-" +
                         SUBSTRING(cMasked, 5, 4) + "-" +
                         SUBSTRING(cMasked, 9, 4) + "-" +
                         SUBSTRING(cMasked, 13, 4).
        END.
        ELSE
            cMasked = FILL("X", iLength).
            
        RETURN cMasked.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Mask Email Address
     Notes:   Format: j***@example.com (preserve first char and domain)
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER MaskEmail(INPUT pcEmail AS CHARACTER):
        
        DEFINE VARIABLE cMasked AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cLocalPart AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cDomain AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iAtPos AS INTEGER NO-UNDO.
        
        iAtPos = INDEX(pcEmail, "@").
        
        IF iAtPos > 1 THEN DO:
            cLocalPart = SUBSTRING(pcEmail, 1, iAtPos - 1).
            cDomain = SUBSTRING(pcEmail, iAtPos).
            
            IF LENGTH(cLocalPart) > 1 THEN
                cMasked = SUBSTRING(cLocalPart, 1, 1) + 
                         FILL("*", LENGTH(cLocalPart) - 1) + 
                         cDomain.
            ELSE
                cMasked = "*" + cDomain.
        END.
        ELSE
            cMasked = FILL("*", LENGTH(pcEmail)).
            
        RETURN cMasked.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Mask Phone Number
     Notes:   Format: (XXX) XXX-1234 (preserve last 4 digits)
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER MaskPhone(INPUT pcPhone AS CHARACTER):
        
        DEFINE VARIABLE cMasked AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cClean AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iLength AS INTEGER NO-UNDO.
        
        /* Remove formatting */
        cClean = REPLACE(REPLACE(REPLACE(REPLACE(pcPhone, "(", ""), ")", ""), "-", ""), " ", "").
        iLength = LENGTH(cClean).
        
        IF iLength = 10 THEN
            cMasked = "(XXX) XXX-" + SUBSTRING(cClean, 7, 4).
        ELSE IF iLength = 11 AND SUBSTRING(cClean, 1, 1) = "1" THEN
            cMasked = "1 (XXX) XXX-" + SUBSTRING(cClean, 8, 4).
        ELSE
            cMasked = FILL("X", iLength).
            
        RETURN cMasked.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Generic masking for any string
     Notes:   Preserves length and some structure
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GenericMask(INPUT pcValue AS CHARACTER):
        
        DEFINE VARIABLE cMasked AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iChar AS INTEGER NO-UNDO.
        DEFINE VARIABLE cChar AS CHARACTER NO-UNDO.
        
        DO iChar = 1 TO LENGTH(pcValue):
            cChar = SUBSTRING(pcValue, iChar, 1).
            
            /* Preserve spaces, punctuation, and special characters */
            IF ASC(cChar) >= 48 AND ASC(cChar) <= 57 THEN /* Numbers */
                cMasked = cMasked + "X".
            ELSE IF (ASC(cChar) >= 65 AND ASC(cChar) <= 90) OR 
                    (ASC(cChar) >= 97 AND ASC(cChar) <= 122) THEN /* Letters */
                cMasked = cMasked + "*".
            ELSE
                cMasked = cMasked + cChar. /* Preserve special chars */
        END.
        
        RETURN cMasked.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Generate random string of specified length
     Notes:   Used for replacement masking
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER GenerateRandomString(INPUT piLength AS INTEGER):
        
        DEFINE VARIABLE cRandom AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cChars AS CHARACTER NO-UNDO INITIAL "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".
        DEFINE VARIABLE i AS INTEGER NO-UNDO.
        
        DO i = 1 TO piLength:
            cRandom = cRandom + SUBSTRING(cChars, RANDOM(1, LENGTH(cChars)), 1).
        END.
        
        RETURN cRandom.
        
    END METHOD.

    /*------------------------------------------------------------------------------
     Purpose: Format preserving encryption (simplified)
     Notes:   Maintains data format while changing content
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC CHARACTER FormatPreservingMask(INPUT pcValue AS CHARACTER,
                                                 INPUT pcPattern AS CHARACTER):
        
        DEFINE VARIABLE cMasked AS CHARACTER NO-UNDO.
        DEFINE VARIABLE iChar AS INTEGER NO-UNDO.
        DEFINE VARIABLE cPatternChar AS CHARACTER NO-UNDO.
        
        DO iChar = 1 TO LENGTH(pcValue):
            IF iChar <= LENGTH(pcPattern) THEN DO:
                cPatternChar = SUBSTRING(pcPattern, iChar, 1).
                
                CASE cPatternChar:
                    WHEN "9" THEN /* Numeric */
                        cMasked = cMasked + STRING(RANDOM(0, 9)).
                    WHEN "A" THEN /* Alphabetic */
                        cMasked = cMasked + CHR(RANDOM(65, 90)).
                    WHEN "X" THEN /* Alphanumeric */
                        IF RANDOM(1, 2) = 1 THEN
                            cMasked = cMasked + STRING(RANDOM(0, 9)).
                        ELSE
                            cMasked = cMasked + CHR(RANDOM(65, 90)).
                    OTHERWISE
                        cMasked = cMasked + cPatternChar.
                END CASE.
            END.
            ELSE
                cMasked = cMasked + SUBSTRING(pcValue, iChar, 1).
        END.
        
        RETURN cMasked.
        
    END METHOD.

END CLASS.
