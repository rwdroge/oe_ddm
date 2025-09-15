/*------------------------------------------------------------------------
    File        : MaskingExample.p
    Purpose     : Example program demonstrating data masking functionality
    Syntax      : 
    Description : Shows how to use the DataMaskingEngine for various scenarios
    Author(s)   : Progress Developer
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/

USING src.ddm.DataMaskingEngine.
USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE oMaskingEngine AS DataMaskingEngine NO-UNDO.
DEFINE VARIABLE cMaskedValue AS CHARACTER NO-UNDO.

/* Initialize the masking engine */
oMaskingEngine = NEW DataMaskingEngine().

/* Example 1: Mask individual values */
MESSAGE "=== Individual Value Masking Examples ===" VIEW-AS ALERT-BOX.

/* SSN Masking */
cMaskedValue = oMaskingEngine:MaskValue("123-45-6789", "SSN_MASK").
MESSAGE SUBSTITUTE("Original SSN: 123-45-6789~nMasked SSN: &1", cMaskedValue) VIEW-AS ALERT-BOX.

/* Credit Card Masking */
cMaskedValue = oMaskingEngine:MaskValue("4532-1234-5678-9012", "CREDIT_CARD_MASK").
MESSAGE SUBSTITUTE("Original CC: 4532-1234-5678-9012~nMasked CC: &1", cMaskedValue) VIEW-AS ALERT-BOX.

/* Email Masking */
cMaskedValue = oMaskingEngine:MaskValue("john.doe@example.com", "EMAIL_MASK").
MESSAGE SUBSTITUTE("Original Email: john.doe@example.com~nMasked Email: &1", cMaskedValue) VIEW-AS ALERT-BOX.

/* Phone Masking */
cMaskedValue = oMaskingEngine:MaskValue("(555) 123-4567", "PHONE_MASK").
MESSAGE SUBSTITUTE("Original Phone: (555) 123-4567~nMasked Phone: &1", cMaskedValue) VIEW-AS ALERT-BOX.

/* Example 2: Configure masking rules for tables */
MESSAGE "=== Table Masking Configuration ===" VIEW-AS ALERT-BOX.

/* Add masking rules for a customer table */
oMaskingEngine:AddRule("Customer", "SSN", "SSN_MASK").
oMaskingEngine:AddRule("Customer", "CreditCard", "CREDIT_CARD_MASK").
oMaskingEngine:AddRule("Customer", "Email", "EMAIL_MASK").
oMaskingEngine:AddRule("Customer", "Phone", "PHONE_MASK").

MESSAGE "Masking rules added for Customer table:~n" +
        "- SSN field: SSN_MASK~n" +
        "- CreditCard field: CREDIT_CARD_MASK~n" +
        "- Email field: EMAIL_MASK~n" +
        "- Phone field: PHONE_MASK" VIEW-AS ALERT-BOX.

/* Example 3: Load configuration from file (commented out - requires config file) */
/*
MESSAGE "=== Loading Configuration from File ===" VIEW-AS ALERT-BOX.
oMaskingEngine:LoadConfiguration("conf/masking-config.json").
MESSAGE "Configuration loaded from file successfully!" VIEW-AS ALERT-BOX.
*/

/* Example 4: Apply table-level masking (would require actual database connection) */
/*
MESSAGE "=== Applying Table Masking ===" VIEW-AS ALERT-BOX.
IF oMaskingEngine:MaskTable("Customer") THEN
    MESSAGE "Customer table masking completed successfully!" VIEW-AS ALERT-BOX.
ELSE
    MESSAGE "Customer table masking failed!" VIEW-AS ALERT-BOX.
*/

MESSAGE "Data masking examples completed!" VIEW-AS ALERT-BOX.

CATCH oError AS Progress.Lang.Error:
    MESSAGE SUBSTITUTE("Error occurred: &1", oError:GetMessage(1)) VIEW-AS ALERT-BOX.
END CATCH.
