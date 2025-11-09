# Dynamic Data Masking API Documentation

## Overview

The DDM REST API provides programmatic access to OpenEdge Dynamic Data Masking functionality through PASOE webhandlers. This API enables integration with external applications and provides a foundation for web-based administration interfaces.

## Authorization Tag Format

DDM authorization tags must follow these rules:

- Must begin with `#DDM_See_` (case-insensitive)
- Maximum length: 64 characters total
- Allowed characters: A–Z, a–z, 0–9, and the following: `_ . - # $ % &`
- No spaces allowed
- Must include non-empty content after the required prefix

Examples: `#DDM_See_PII`, `#DDM_See_ContactInfo`, `#DDM_See_TopSecret`

Endpoints that accept an authorization tag (e.g., Create/Update/Delete Authorization Tag, Configure Field) expect values that adhere to this format. Requests with invalid values will be rejected with a 400 Bad Request.

## Mask Configurations

A mask is the format-string representation set up against the fields in a table. A mask configuration establishes how to hide the data from unauthorized users. You can define the following mask configurations:

- **D — Default mask:** Provided by the clients. Example: `D:`
- **N — Null mask:** Can be used for any data type. Example: `N:`
- **L — Literal mask:** For any data type except RAW and LOGICAL, provided the literal is compatible with the underlying data type. Example: `L:MASKED`
- **P — Partial mask:** Partially masks data (character data type only). Format: `P:start,maskChar,count`, for example `P:0,X,4`.

Note: The mask transformation must always result in the same datatype as the original value. For example, a numeric value such as `1234` cannot be converted to a non-numerical value such as `XXXX`.

### ABL Example: Default Mask (current API)

The following ABL example configures the default mask (`D:`) using the high-level `ConfigureFieldMasking` API and the `#DDM_SEE_ContactInfo` authorization tag for the `state` field of the `Customer` table:

```abl
USING ddm.DataAdminMaskingService FROM PROPATH.

DEFINE VARIABLE service AS DataAdminMaskingService NO-UNDO.
DEFINE VARIABLE lResult AS LOGICAL NO-UNDO.

service = NEW DataAdminMaskingService(LDBNAME("DICTDB")).
/* maskingType FULL with maskingValue 'D:' sets the default mask */
lResult = service:ConfigureFieldMasking(
    "Customer",   /* tableName */
    "state",      /* fieldName */
    "FULL",       /* maskingType: FULL | PARTIAL | CONDITIONAL */
    "D:",         /* maskingValue e.g., D:, N:, L:MASKED, P:0,X,4 */
    "#DDM_SEE_ContactInfo" /* authTag */
).
```

## Base URL

```
http://localhost:8080/api/masking
```

## Current REST endpoints

- **POST /configure-field**
  Configure field masking using `maskingType` and `maskingValue` with an `authTag`.

- **POST /unset-mask**
  Remove the mask configuration from a field.

- **POST /unset-auth-tag**
  Remove the authorization tag from a field.

- **POST /create-auth-tag**
  Create an authorization tag in a domain.

- **POST /update-auth-tag**
  Rename an existing authorization tag.

- **DELETE /delete-auth-tag**
  Delete an authorization tag from a domain.

- **POST /create-role**, **DELETE /delete-role**
  Manage security roles.

- **POST /grant-role**, **POST /grant-roles**, **DELETE /delete-granted-role**
  Grant one or many users a role; revoke a granted role by ID.

- **GET /roles**, **GET /roles-with-counts**
  Retrieve role lists; optionally with user counts per role.

- **GET /users**, **GET /auth-tags**, **GET /auth-tags-with-roles**, **GET /role-auth-tags**
  Retrieve users and authorization tag associations.

- **GET /mask-and-auth-tag**
  Retrieve mask and authorization tag info for a field (for display/diagnostics).

- **GET /user-role-grants**
  List role grants for a user.

## Authentication

Currently, the API uses basic authentication inherited from PASOE configuration. Future versions will support token-based authentication.

## Endpoints

### Health Check

**GET** `/health`

Check API service status and version information.

**Response:**
```json
{
  "status": "healthy",
  "service": "Dynamic Data Masking API",
  "version": "1.0",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Get Configuration

**GET** `/config`

Retrieve current masking configuration and available mask types.

**Response:**
```json
{
  "availableMaskTypes": [
    {
      "type": "SSN_MASK",
      "description": "Masks SSN preserving last 4 digits",
      "pattern": "XXX-XX-####"
    },
    {
      "type": "CREDIT_CARD_MASK",
      "description": "Masks credit card preserving first and last 4 digits",
      "pattern": "####-XXXX-XXXX-####"
    }
  ],
  "success": true
}
```

### Mask Single Value

**POST** `/mask-value`

Apply masking to a single value using specified algorithm.

**Request Body:**
```json
{
  "value": "123-45-6789",
  "maskType": "SSN_MASK"
}
```

**Response:**
```json
{
  "originalValue": "123-45-6789",
  "maskType": "SSN_MASK",
  "maskedValue": "XXX-XX-6789",
  "success": true
}
```

### Mask Table

**POST** `/mask-table`

Apply masking rules to an entire database table.

**Request Body:**
```json
{
  "tableName": "Customer"
}
```

**Response:**
```json
{
  "tableName": "Customer",
  "success": true,
  "message": "Table masking completed"
}
```

### Add Masking Rule

**POST** `/add-rule`

Add a new masking rule for a table field.

**Request Body:**
```json
{
  "tableName": "Employee",
  "fieldName": "SSN",
  "maskType": "SSN_MASK"
}
```

**Response:**
```json
{
  "tableName": "Employee",
  "fieldName": "SSN",
  "maskType": "SSN_MASK",
  "success": true,
  "message": "Masking rule added successfully"
}
```

### Load Configuration

**POST** `/load-config`

Load masking configuration from a JSON file.

**Request Body:**
```json
{
  "configFile": "conf/masking-config.json"
}
```

**Response:**
```json
{
  "configFile": "conf/masking-config.json",
  "success": true,
  "message": "Configuration loaded successfully"
}
```

### Get Audit Logs

**GET** `/logs`

Retrieve audit logs of masking operations.

**Response:**
```json
{
  "logs": [
    {
      "logId": 1,
      "logLevel": "INFO",
      "tableName": "Customer",
      "fieldName": "SSN",
      "recordId": "1001",
      "maskType": "SSN_MASK",
      "userId": "admin",
      "sessionId": "session_123",
      "logTime": "2024-01-15T10:30:00Z",
      "additionalInfo": "Single value masking operation"
    }
  ],
  "totalCount": 1,
  "success": true
}
```

## Error Handling

All endpoints return consistent error responses:

```json
{
  "success": false,
  "error": "Error message description",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

Common HTTP status codes:
- `200` - Success
- `400` - Bad Request (invalid parameters)
- `404` - Endpoint not found
- `500` - Internal server error

## Mask Types

### SSN_MASK
- **Pattern:** `XXX-XX-####`
- **Description:** Masks Social Security Number preserving last 4 digits
- **Example:** `123-45-6789` → `XXX-XX-6789`

### CREDIT_CARD_MASK
- **Pattern:** `####-XXXX-XXXX-####`
- **Description:** Masks credit card preserving first and last 4 digits
- **Example:** `4532-1234-5678-9012` → `4532-XXXX-XXXX-9012`

### EMAIL_MASK
- **Pattern:** `#***@domain.com`
- **Description:** Masks email preserving first character and domain
- **Example:** `john.doe@example.com` → `j***@example.com`

### PHONE_MASK
- **Pattern:** `(XXX) XXX-####`
- **Description:** Masks phone number preserving last 4 digits
- **Example:** `(555) 123-4567` → `(XXX) XXX-4567`

### GENERIC_MASK
- **Pattern:** User-defined
- **Description:** Generic masking with custom patterns
- **Example:** `SensitiveData` → `*************`

## Rate Limiting

Current implementation has no rate limiting. Production deployments should implement appropriate rate limiting at the PASOE or reverse proxy level.

## Security Considerations

1. **HTTPS Only:** Always use HTTPS in production
2. **Authentication:** Implement proper authentication mechanisms
3. **Input Validation:** All inputs are validated server-side
4. **Audit Logging:** All operations are logged for compliance
5. **Data Retention:** Configure appropriate log retention policies

## Client Examples

### JavaScript/Node.js

```javascript
const axios = require('axios');

const apiClient = axios.create({
  baseURL: 'http://localhost:8080/api/masking',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Mask a value
async function maskValue(value, maskType) {
  try {
    const response = await apiClient.post('/mask-value', {
      value: value,
      maskType: maskType
    });
    return response.data.maskedValue;
  } catch (error) {
    console.error('Masking failed:', error.response.data);
  }
}

// Usage
maskValue('123-45-6789', 'SSN_MASK').then(masked => {
  console.log('Masked SSN:', masked);
});
```

### Python

```python
import requests
import json

class DDMClient:
    def __init__(self, base_url='http://localhost:8080/api/masking'):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({'Content-Type': 'application/json'})
    
    def mask_value(self, value, mask_type):
        response = self.session.post(f'{self.base_url}/mask-value', 
                                   json={'value': value, 'maskType': mask_type})
        response.raise_for_status()
        return response.json()['maskedValue']
    
    def get_logs(self):
        response = self.session.get(f'{self.base_url}/logs')
        response.raise_for_status()
        return response.json()['logs']

# Usage
client = DDMClient()
masked_ssn = client.mask_value('123-45-6789', 'SSN_MASK')
print(f'Masked SSN: {masked_ssn}')
```

### cURL Examples

```bash
# Health check
curl -X GET http://localhost:8080/api/masking/health

# Mask a value
curl -X POST http://localhost:8080/api/masking/mask-value \
  -H "Content-Type: application/json" \
  -d '{"value": "123-45-6789", "maskType": "SSN_MASK"}'

# Add masking rule
curl -X POST http://localhost:8080/api/masking/add-rule \
  -H "Content-Type: application/json" \
  -d '{"tableName": "Customer", "fieldName": "SSN", "maskType": "SSN_MASK"}'

# Get audit logs
curl -X GET http://localhost:8080/api/masking/logs
```
