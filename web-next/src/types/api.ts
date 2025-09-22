// API Types based on OpenAPI specification

export interface HealthResponse {
  status: string;
  service: string;
  version: string;
  database: string;
  timestamp: string;
}

export interface DDMConfigRequest {
  tableName: string;
  fieldName: string;
  maskValue: string;
  authTag: string;
}

export interface DDMConfigResponse {
  tableName: string;
  fieldName: string;
  maskValue: string;
  authTag: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface ConfigureFieldRequest {
  tableName: string;
  fieldName: string;
  maskingType: 'FULL' | 'PARTIAL' | 'CONDITIONAL';
  maskingValue: string;
  authTag: string;
}

export interface ConfigureFieldResponse {
  tableName: string;
  fieldName: string;
  maskingType: string;
  maskingValue: string;
  authTag: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface FieldRequest {
  tableName: string;
  fieldName: string;
}

export interface AuthTagRequest {
  domainName: string;
  authTagName: string;
}

export interface AuthTagResponse {
  domainName: string;
  authTagName: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface UpdateAuthTagRequest {
  domainName: string;
  authTagName: string;
  newName: string;
}

export interface UpdateAuthTagResponse {
  domainName: string;
  authTagName: string;
  newName: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface RoleRequest {
  roleName: string;
}

export interface RoleResponse {
  roleName: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface GrantRoleRequest {
  userName: string;
  roleName: string;
}

export interface GrantRoleResponse {
  userName: string;
  roleName: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface DeleteGrantedRoleRequest {
  grantId: string;
}

export interface DeleteGrantedRoleResponse {
  grantId: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface CreateUserRequest {
  userName: string;
  password: string;
}

export interface UserRequest {
  userName: string;
}

export interface UserResponse {
  userName: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface MaskAndAuthTagResponse {
  tableName: string;
  fieldName: string;
  userName?: string;
  result: string;
  success: boolean;
  error?: string;
}

export interface AuthTagRoleResponse {
  domainName: string;
  authTagName: string;
  result: string;
  success: boolean;
  error?: string;
}

export interface UserRoleGrantsResponse {
  userName: string;
  result: string;
  success: boolean;
  error?: string;
}

export interface OperationResponse {
  tableName?: string;
  fieldName?: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface AssociateAuthTagRoleRequest {
  currentRoleName: string;
  authTagName: string;
  newRoleName: string;
}

export interface AssociateAuthTagRoleResponse {
  currentRoleName: string;
  authTagName: string;
  newRoleName: string;
  success: boolean;
  message: string;
  error?: string;
}

export interface RolesListResponse {
  result: string; // comma-separated role names
  success: boolean;
  error?: string;
}

export interface RoleAuthTagsListResponse {
  roleName: string;
  result: string; // comma-separated auth tag names for the role
  success: boolean;
  error?: string;
}

export interface UsersListResponse {
  result: string; // comma-separated user names
  success: boolean;
  error?: string;
}

export interface AuthTagsListResponse {
  result: string; // comma-separated authorization tag names
  success: boolean;
  error?: string;
}

export interface RolesWithCountsResponse {
  result: string; // comma-separated items: role|count
  success: boolean;
  error?: string;
}

export interface AuthTagsWithRolesResponse {
  result: string; // comma-separated items: tag|role
  success: boolean;
  error?: string;
}

export interface ErrorResponse {
  error: string;
  success: boolean;
  timestamp: string;
  path: string;
}

// UI-specific types
export interface TableField {
  tableName: string;
  fieldName: string;
  maskValue?: string;
  authTag?: string;
  maskingType?: 'FULL' | 'PARTIAL' | 'CONDITIONAL';
}

export interface AuthTag {
  domainName: string;
  authTagName: string;
}

export interface Role {
  roleName: string;
}

export interface User {
  userName: string;
}

export interface RoleGrant {
  grantId: string;
  userName: string;
  roleName: string;
}
