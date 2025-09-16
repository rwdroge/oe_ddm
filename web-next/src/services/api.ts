import axios, { AxiosResponse } from 'axios';
import type {
  HealthResponse,
  DDMConfigRequest,
  DDMConfigResponse,
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
  DeleteGrantedRoleRequest,
  DeleteGrantedRoleResponse,
  CreateUserRequest,
  UserRequest,
  UserResponse,
  MaskAndAuthTagResponse,
  AuthTagRoleResponse,
  UserRoleGrantsResponse,
  OperationResponse,
  ErrorResponse,
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

  // DDM Configuration
  static async setDDMConfig(request: DDMConfigRequest): Promise<DDMConfigResponse> {
    const response: AxiosResponse<DDMConfigResponse> = await apiClient.post('/set-ddm-config', request);
    return response.data;
  }

  static async removeDDMConfig(request: FieldRequest): Promise<OperationResponse> {
    const response: AxiosResponse<OperationResponse> = await apiClient.delete('/remove-ddm-config', { data: request });
    return response.data;
  }

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

export default DDMApiService;
