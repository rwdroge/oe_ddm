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
DEFINE VARIABLE cCurrentConfig AS CHARACTER NO-UNDO.

/* Initialize the masking service */
oMaskingService = NEW DataAdminMaskingService("sports2000").

/* Example 1: Configure full masking for sensitive customer data */
MESSAGE "Configuring DDM for Customer.CreditCard field...".

/* Set DDM configuration for credit card field - full masking */
lSuccess = oMaskingService:ConfigureFieldMasking(
    "Customer",           /* Table name */
    "CreditCard",         /* Field name */  
    "PUBLIC",             /* User/Role name */
    "FULL_MASK",          /* Mask type */
    "XXXX-XXXX-XXXX-XXXX" /* Mask value */
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
    "PUBLIC",             /* User/Role name */
    "PARTIAL_MASK",       /* Mask type */
    "(XXX) XXX-####"      /* Partial mask - show last 4 digits */
).

IF lSuccess THEN
    MESSAGE "Successfully configured DDM for Customer.Phone".
ELSE
    MESSAGE "Failed to configure DDM for Customer.Phone".

/* Example 3: Get current DDM configuration */
MESSAGE "Retrieving current DDM configuration...".

cCurrentConfig = oMaskingService:GetFieldDDMConfig(
    "Customer",    /* Table name */
    "CreditCard",  /* Field name */
    "PUBLIC"       /* User/Role name */
).

MESSAGE SUBSTITUTE("Current DDM config for Customer.CreditCard: &1", cCurrentConfig).

/* Example 4: Configure conditional masking based on user role */
MESSAGE "Configuring conditional DDM for Customer.SSN field...".

lSuccess = oMaskingService:ConfigureFieldMasking(
    "Customer",                    /* Table name */
    "SSN",                         /* Field name */
    "MANAGER",                     /* User/Role name */
    "CONDITIONAL_MASK",            /* Mask type */
    "XXX-XX-####"                  /* Show last 4 digits for managers */
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
    "PUBLIC",                             /* User/Role name */
    "MASK_EMAIL=***@domain.com"           /* Raw DDM configuration */
).

IF lSuccess THEN
    MESSAGE "Successfully set raw DDM configuration for Customer.Email".
ELSE
    MESSAGE "Failed to set raw DDM configuration for Customer.Email".

MESSAGE "DDM configuration examples completed.".

CATCH oError AS Progress.Lang.Error:
    MESSAGE SUBSTITUTE("Error in DDM example: &1", oError:GetMessage(1)).
END CATCH.
