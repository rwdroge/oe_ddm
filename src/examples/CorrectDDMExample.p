/*------------------------------------------------------------------------
    File        : CorrectDDMExample.p
    Purpose     : Demonstrates correct usage of OpenEdge 12.8 DDM API methods
    
    Syntax      : RUN CorrectDDMExample.p.
    
    Description : Example showing how to use the actual DDM methods available
                  in OpenEdge 12.8: setDDMConfig, unsetDDMMask, unsetDDMAuthTag
    
    Author(s)   : 
    Created     : 
    Notes       : Requires OpenEdge 12.8 with OCTA-55313 patch for DDM support
  ----------------------------------------------------------------------*/

USING OpenEdge.DataAdmin.*.
USING ddm.*.

DEFINE VARIABLE oMaskingService AS DataAdminMaskingService NO-UNDO.
DEFINE VARIABLE lSuccess AS LOGICAL NO-UNDO.

/* Initialize the masking service for the current database */
oMaskingService = NEW DataAdminMaskingService("sports2000").

/* Example 1: Set DDM configuration for Customer.CustNum field */
MESSAGE "Setting DDM configuration for Customer.CustNum field...".

lSuccess = oMaskingService:SetFieldDDMConfig(
    "Customer",           /* Table name */
    "CustNum",           /* Field name */
    "****",              /* Mask value - replace with asterisks */
    "SENSITIVE"          /* Authorization tag */
).

IF lSuccess THEN
    MESSAGE "DDM configuration set successfully for Customer.CustNum".
ELSE
    MESSAGE "Failed to set DDM configuration for Customer.CustNum".

/* Example 2: Configure field masking using high-level method */
MESSAGE "Configuring field masking for Customer.Name field...".

lSuccess = oMaskingService:ConfigureFieldMasking(
    "Customer",          /* Table name */
    "Name",             /* Field name */
    "PARTIAL",          /* Masking type */
    "XXXX",             /* Mask value */
    "PII"               /* Authorization tag */
).

IF lSuccess THEN
    MESSAGE "Field masking configured successfully for Customer.Name".
ELSE
    MESSAGE "Failed to configure field masking for Customer.Name".

/* Example 3: Set DDM for Order.OrderNum with different mask */
MESSAGE "Setting DDM for Order.OrderNum field...".

lSuccess = oMaskingService:SetFieldDDMConfig(
    "Order",            /* Table name */
    "OrderNum",         /* Field name */
    "0000",             /* Mask value - replace with zeros */
    "BUSINESS"          /* Authorization tag */
).

IF lSuccess THEN
    MESSAGE "DDM set successfully for Order.OrderNum".
ELSE
    MESSAGE "Failed to set DDM for Order.OrderNum".

/* Example 4: Remove DDM configuration from a field */
MESSAGE "Removing DDM configuration from Customer.CustNum field...".

lSuccess = oMaskingService:RemoveFieldDDMConfig(
    "Customer",         /* Table name */
    "CustNum"          /* Field name */
).

IF lSuccess THEN
    MESSAGE "DDM configuration removed successfully from Customer.CustNum".
ELSE
    MESSAGE "Failed to remove DDM configuration from Customer.CustNum".

/* Clean up */
DELETE OBJECT oMaskingService.

MESSAGE "DDM configuration example completed.".
