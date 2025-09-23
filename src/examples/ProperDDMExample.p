/*------------------------------------------------------------------------
    File        : ProperDDMExample.p
    Purpose     : Demonstrates proper OpenEdge Dynamic Data Masking using DataAdminService
    Syntax      : 
    Description : Shows how to use the DDM-specific API methods introduced in OpenEdge 12.8
    Author(s)   : Progress Developer
    Created     : 
    Notes       : Uses GetFieldDDMConfig and SetFieldDDMConfig methods
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING ddm.DataAdminMaskingService.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE oMaskingService AS DataAdminMaskingService NO-UNDO.
DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.
/* cCurrentConfig no longer used; replaced by cMaskValue/cAuthTag outputs */
DEFINE VARIABLE cMaskValue AS CHARACTER NO-UNDO.
DEFINE VARIABLE cAuthTag   AS CHARACTER NO-UNDO.

/* Initialize the masking service */
oMaskingService = NEW DataAdminMaskingService("sports2000").

/* Example 1: Configure full masking for sensitive customer data */
MESSAGE "Configuring DDM for Customer.CreditCard field...".

/* Set DDM configuration for credit card field - full masking */
lSuccess = oMaskingService:ConfigureFieldMasking(
    "Customer",           /* Table name */
    "CreditCard",         /* Field name */  
    "FULL",               /* Mask type */
    "XXXX-XXXX-XXXX-XXXX",/* Mask value */
    "PUBLIC"              /* Authorization tag */
).

IF lSuccess THEN
    MESSAGE "Successfully configured DDM for Customer.CreditCard".
ELSE
    MESSAGE "Failed to configure DDM for Customer.CreditCard".

/* Example 2: Configure partial masking for phone numbers */
MESSAGE "Configuring DDM for Customer.Phone field...".

lSuccess = oMaskingService:ConfigureFieldMasking(
    "Customer",           /* Table name */
    "Phone",              /* Field name */
    "PARTIAL",            /* Mask type */
    "(XXX) XXX-####",     /* Partial mask - show last 4 digits */
    "PUBLIC"              /* Authorization tag */
).

IF lSuccess THEN
    MESSAGE "Successfully configured DDM for Customer.Phone".
ELSE
    MESSAGE "Failed to configure DDM for Customer.Phone".

/* Example 3: Get current DDM configuration */
MESSAGE "Retrieving current DDM configuration...".

lSuccess = oMaskingService:GetFieldDDMConfig(
    "Customer",    /* Table name */
    "Address",     /* Field name */
    OUTPUT cMaskValue,
    OUTPUT cAuthTag
).
IF lSuccess THEN
    MESSAGE SUBSTITUTE("Current DDM config for Customer.Address: mask=&1, authTag=&2", cMaskValue, cAuthTag).
ELSE
    MESSAGE "No DDM configuration found for Customer.Address".

/* Example 4: Configure conditional masking based on user role */
MESSAGE "Configuring conditional DDM for Customer.SSN field...".

lSuccess = oMaskingService:ConfigureFieldMasking(
    "Customer",                    /* Table name */
    "SSN",                         /* Field name */
    "CONDITIONAL",                 /* Mask type */
    "XXX-XX-####",                 /* Show last 4 digits for managers */
    "MANAGER"                      /* Authorization tag */
).

IF lSuccess THEN
    MESSAGE "Successfully configured conditional DDM for Customer.SSN".
ELSE
    MESSAGE "Failed to configure conditional DDM for Customer.SSN".

/* Example 5: Direct DDM configuration using raw config string */
MESSAGE "Setting raw DDM configuration...".

lSuccess = oMaskingService:SetFieldDDMConfig(
    "Customer",                           /* Table name */
    "Email",                              /* Field name */
    "MASK_EMAIL=***@domain.com",          /* Raw DDM configuration (mask value) */
    "PUBLIC"                              /* Authorization tag */
).

IF lSuccess THEN
    MESSAGE "Successfully set raw DDM configuration for Customer.Email".
ELSE
    MESSAGE "Failed to set raw DDM configuration for Customer.Email".

MESSAGE "DDM configuration examples completed.".

CATCH oError AS Progress.Lang.Error:
    MESSAGE SUBSTITUTE("Error in DDM example: &1", oError:GetMessage(1)).
END CATCH.
