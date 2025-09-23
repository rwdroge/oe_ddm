import axios, { AxiosResponse } from 'axios';
import type {
  HealthResponse,
  ConfigureFieldRequest,
  ConfigureFieldResponse,
  FieldRequest,
  AuthTagRequest,
  AuthTagResponse,
  UpdateAuthTagRequest,
  UpdateAuthTagResponse,
  RoleRequest,
  RoleResponse,
  GrantRoleRequest,
  GrantRoleResponse,
  GrantRolesRequest,
  GrantRolesResponse,
  DeleteGrantedRoleRequest,
  DeleteGrantedRoleResponse,
  CreateUserRequest,
  UserRequest,
  UserResponse,
  AssociateAuthTagRoleRequest,
  AssociateAuthTagRoleResponse,
  MaskAndAuthTagResponse,
  AuthTagRoleResponse,
  UserRoleGrantsResponse,
  OperationResponse,
  ErrorResponse,
  RolesListResponse,
  RoleAuthTagsListResponse,
  UsersListResponse,
  AuthTagsListResponse,
  RolesWithCountsResponse,
  AuthTagsWithRolesResponse,
  TablesListResponse,
  FieldsListResponse,
  TableConfigsResponse,
} from '@/types/api';

const API_BASE_URL = '/api/masking';

// Create axios instance with default config
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Surface backend error messages (including HTTP 4xx/5xx) onto the error object
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    try {
      const backendMsg: string | undefined = error?.response?.data?.error;
      if (backendMsg) {
        // Preserve original but promote backend error for convenient access
        (error as any).backendError = backendMsg;
        if (!error.message || error.message === 'Network Error') {
          error.message = backendMsg;
        }
      }
    } catch (_) {
      // no-op
    }
    return Promise.reject(error);
  }
);

// Request interceptor for auth
apiClient.interceptors.request.use((config) => {
  // Add basic auth if credentials are available
  const auth = localStorage.getItem('ddm-auth');
  if (auth) {
    const { username, password } = JSON.parse(auth);
    config.auth = { username, password };
  }
  return config;
});

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('ddm-auth');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export class DDMApiService {
  // Health check
  static async getHealth(): Promise<HealthResponse> {
    const response: AxiosResponse<HealthResponse> = await apiClient.get('/health');
    return response.data;
  }

  // DDM Configuration (removed legacy direct config endpoints in favor of Field Masking)

  // Field Operations
  static async configureField(request: ConfigureFieldRequest): Promise<ConfigureFieldResponse> {
    const response: AxiosResponse<ConfigureFieldResponse> = await apiClient.post('/configure-field', request);
    return response.data;
  }

  static async unsetMask(request: FieldRequest): Promise<OperationResponse> {
    const response: AxiosResponse<OperationResponse> = await apiClient.post('/unset-mask', request);
    return response.data;
  }

  static async unsetAuthTag(request: FieldRequest): Promise<OperationResponse> {
    const response: AxiosResponse<OperationResponse> = await apiClient.post('/unset-auth-tag', request);
    return response.data;
  }

  // Authorization Tags
  static async createAuthTag(request: AuthTagRequest): Promise<AuthTagResponse> {
    const response: AxiosResponse<AuthTagResponse> = await apiClient.post('/create-auth-tag', request);
    return response.data;
  }

  static async updateAuthTag(request: UpdateAuthTagRequest): Promise<UpdateAuthTagResponse> {
    const response: AxiosResponse<UpdateAuthTagResponse> = await apiClient.post('/update-auth-tag', request);
    return response.data;
  }

  static async deleteAuthTag(request: AuthTagRequest): Promise<AuthTagResponse> {
    const response: AxiosResponse<AuthTagResponse> = await apiClient.delete('/delete-auth-tag', { data: request });
    return response.data;
  }

  // Role Management
  static async createRole(request: RoleRequest): Promise<RoleResponse> {
    const response: AxiosResponse<RoleResponse> = await apiClient.post('/create-role', request);
    return response.data;
  }

  static async deleteRole(request: RoleRequest): Promise<RoleResponse> {
    const response: AxiosResponse<RoleResponse> = await apiClient.delete('/delete-role', { data: request });
    return response.data;
  }

  static async grantRole(request: GrantRoleRequest): Promise<GrantRoleResponse> {
    const response: AxiosResponse<GrantRoleResponse> = await apiClient.post('/grant-role', request);
    return response.data;
  }

  static async grantRoles(request: GrantRolesRequest): Promise<GrantRolesResponse> {
    const response: AxiosResponse<GrantRolesResponse> = await apiClient.post('/grant-roles', request);
    return response.data;
  }

  static async deleteGrantedRole(request: DeleteGrantedRoleRequest): Promise<DeleteGrantedRoleResponse> {
    const response: AxiosResponse<DeleteGrantedRoleResponse> = await apiClient.delete('/delete-granted-role', { data: request });
    return response.data;
  }

  // User Management
  static async createUser(request: CreateUserRequest): Promise<UserResponse> {
    const response: AxiosResponse<UserResponse> = await apiClient.post('/create-user', request);
    return response.data;
  }

  static async deleteUser(request: UserRequest): Promise<UserResponse> {
    const response: AxiosResponse<UserResponse> = await apiClient.delete('/delete-user', { data: request });
    return response.data;
  }

  // Security Admin
  static async grantSecurityAdmin(request: UserRequest): Promise<UserResponse> {
    const response: AxiosResponse<UserResponse> = await apiClient.post('/grant-security-admin', request);
    return response.data;
  }

  // Authorization Tag to Role Association
  static async associateAuthTagRole(request: AssociateAuthTagRoleRequest): Promise<AssociateAuthTagRoleResponse> {
    const response: AxiosResponse<AssociateAuthTagRoleResponse> = await apiClient.post('/associate-auth-tag-role', request);
    return response.data;
  }

  // Information Retrieval
  static async getMaskAndAuthTag(
    tableName: string,
    fieldName: string,
    userName?: string
  ): Promise<MaskAndAuthTagResponse> {
    const params = new URLSearchParams({ tableName, fieldName });
    if (userName) params.append('userName', userName);
    
    const response: AxiosResponse<MaskAndAuthTagResponse> = await apiClient.get(`/mask-and-auth-tag?${params}`);
    return response.data;
  }

  static async getAuthTagRole(domainName: string, authTagName: string): Promise<AuthTagRoleResponse> {
    const params = new URLSearchParams({ domainName, authTagName });
    const response: AxiosResponse<AuthTagRoleResponse> = await apiClient.get(`/auth-tag-role?${params}`);
    return response.data;
  }

  static async getUserRoleGrants(userName: string): Promise<UserRoleGrantsResponse> {
    const params = new URLSearchParams({ userName });
    const response: AxiosResponse<UserRoleGrantsResponse> = await apiClient.get(`/user-role-grants?${params}`);
    return response.data;
  }

  // Lists
  static async getRoles(): Promise<RolesListResponse> {
    const response: AxiosResponse<RolesListResponse> = await apiClient.get('/roles');
    return response.data;
  }

  static async getRoleAuthTags(roleName: string): Promise<RoleAuthTagsListResponse> {
    const params = new URLSearchParams({ roleName });
    const response: AxiosResponse<RoleAuthTagsListResponse> = await apiClient.get(`/role-auth-tags?${params}`);
    return response.data;
  }

  static async getUsers(): Promise<UsersListResponse> {
    const response: AxiosResponse<UsersListResponse> = await apiClient.get('/users');
    return response.data;
  }

  static async getAuthTags(): Promise<AuthTagsListResponse> {
    const response: AxiosResponse<AuthTagsListResponse> = await apiClient.get('/auth-tags');
    return response.data;
  }

  static async getRolesWithCounts(): Promise<RolesWithCountsResponse> {
    const response: AxiosResponse<RolesWithCountsResponse> = await apiClient.get('/roles-with-counts');
    return response.data;
  }

  static async getAuthTagsWithRoles(): Promise<AuthTagsWithRolesResponse> {
    const response: AxiosResponse<AuthTagsWithRolesResponse> = await apiClient.get('/auth-tags-with-roles');
    return response.data;
  }

  // Schema: Tables and Fields
  static async getTables(): Promise<TablesListResponse> {
    const response: AxiosResponse<TablesListResponse> = await apiClient.get('/tables');
    return response.data;
  }

  static async getFields(tableName: string): Promise<FieldsListResponse> {
    const params = new URLSearchParams({ tableName });
    const response: AxiosResponse<FieldsListResponse> = await apiClient.get(`/fields?${params}`);
    return response.data;
  }

  static async getTableConfigs(tableName: string): Promise<TableConfigsResponse> {
    const params = new URLSearchParams({ tableName });
    const response: AxiosResponse<TableConfigsResponse> = await apiClient.get(`/table-configs?${params}`);
    return response.data;
  }

  // Authentication helpers
  static setAuth(username: string, password: string): void {
    localStorage.setItem('ddm-auth', JSON.stringify({ username, password }));
  }

  static clearAuth(): void {
    localStorage.removeItem('ddm-auth');
  }

  static getAuth(): { username: string; password: string } | null {
    const auth = localStorage.getItem('ddm-auth');
    return auth ? JSON.parse(auth) : null;
  }
}

// Helper to extract a meaningful error message from Axios errors consistently
export function getApiErrorMessage(err: any, fallback: string = 'Request failed'): string {
  const backend = err?.backendError || err?.response?.data?.error
  if (backend && typeof backend === 'string') return backend
  const msg = err?.message
  if (msg && typeof msg === 'string') return msg
  return fallback
}

// Helper to extract error string from non-success API responses
export function getResponseErrorMessage(res: { error?: string; message?: string }, fallback: string): string {
  if (res?.error && typeof res.error === 'string' && res.error.trim().length > 0) return res.error
  if (res?.message && typeof res.message === 'string' && res.message.trim().length > 0) return res.message
  return fallback
}

export default DDMApiService;
