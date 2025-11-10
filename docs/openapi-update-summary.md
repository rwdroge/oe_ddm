# OpenAPI Specification Update Summary

**Date**: November 10, 2025  
**File**: `/workspaces/oe_ddm/docs/openapi.yaml`

## Overview

Updated the OpenAPI specification to match the actual implementation in `MaskingApiHandler.cls`. The specification was missing several critical endpoints that are implemented and used by the Web UI.

## Added Endpoints

### Information Retrieval (GET)

1. **GET /tables**
   - List all user tables in the connected database
   - Response: `TablesResponse` with array of table names

2. **GET /fields**
   - List all fields for a specific table
   - Query parameter: `tableName` (required)
   - Response: `FieldsResponse` with field names and data types

3. **GET /table-configs**
   - Get DDM configuration for all fields in a table
   - Query parameter: `tableName` (required)
   - Response: `TableConfigsResponse` with mask and auth tag info per field

4. **GET /roles**
   - List all security roles
   - Response: `RolesResponse` with serialized role list

5. **GET /roles-with-counts**
   - List all roles with user grant counts
   - Response: `RolesWithCountsResponse` with role and count data

6. **GET /users**
   - List all users in the database
   - Response: `UsersResponse` with serialized user list

7. **GET /auth-tags**
   - List all authorization tags
   - Response: `AuthTagsResponse` with serialized tag list

8. **GET /auth-tags-with-roles**
   - List all authorization tags with associated role information
   - Response: `AuthTagsWithRolesResponse` with tag-role mappings

### Role Management (POST)

9. **POST /grant-roles**
   - Batch operation to grant a single role to multiple users
   - Request body: `GrantRolesRequest` with `roleName` and `userNames[]`
   - Response: `GrantRolesResponse` with per-user results
   - Status codes: 200 (all success), 207 (partial success), 400 (all failed)

### Authorization Tags (POST)

10. **POST /associate-auth-tag-role**
    - Alternative POST method for reassigning auth tags (in addition to existing GET)
    - Request body: `AssociateAuthTagRoleRequest`
    - Response: `AssociateAuthTagRoleResponse`

## Added Schema Definitions

### Request Schemas
- `AssociateAuthTagRoleRequest` - For POST version of auth tag reassignment
- `GrantRolesRequest` - For batch role granting

### Response Schemas
- `TablesResponse` - List of table names
- `FieldsResponse` - Field names and types for a table
- `TableConfigsResponse` - DDM configurations for table fields
- `RolesResponse` - List of roles
- `RolesWithCountsResponse` - Roles with user counts
- `UsersResponse` - List of users
- `AuthTagsResponse` - List of authorization tags
- `AuthTagsWithRolesResponse` - Auth tags with role associations
- `GrantRolesResponse` - Batch grant operation results

## Impact

These endpoints are critical for the Web UI functionality:
- **Table/Field Discovery**: UI needs to list tables and fields for configuration
- **Role Management**: UI displays roles with user counts
- **User Management**: UI lists users for role assignment
- **Auth Tag Management**: UI shows auth tags and their role associations
- **Batch Operations**: UI can grant roles to multiple users efficiently

## Validation

The OpenAPI specification now accurately reflects the REST API implementation in:
- `src/webhandlers/MaskingApiHandler.cls`
- All GET, POST, and DELETE methods are documented
- All request/response schemas are defined

## Next Steps

Consider:
1. Validating the OpenAPI spec with a validator tool
2. Generating API documentation from the spec
3. Using the spec for API client generation
4. Adding example responses for better documentation
