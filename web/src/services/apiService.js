import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || '/api/masking';

class ApiService {
  constructor() {
    this.client = axios.create({
      baseURL: API_BASE_URL,
      headers: {
        'Content-Type': 'application/json',
      },
      timeout: 10000,
    });

    // Request interceptor
    this.client.interceptors.request.use(
      (config) => {
        console.log(`API Request: ${config.method?.toUpperCase()} ${config.url}`);
        return config;
      },
      (error) => {
        return Promise.reject(error);
      }
    );

    // Response interceptor
    this.client.interceptors.response.use(
      (response) => {
        console.log(`API Response: ${response.status} ${response.config.url}`);
        return response;
      },
      (error) => {
        console.error('API Error:', error.response?.data || error.message);
        return Promise.reject(error);
      }
    );
  }

  // ============ HEALTH & SYSTEM ============
  async checkHealth() {
    return this.client.get('/health');
  }

  // ============ DDM CONFIGURATION ============
  async setDDMConfig(data) {
    return this.client.post('/set-ddm-config', data);
  }

  async removeDDMConfig(data) {
    return this.client.delete('/remove-ddm-config', { data });
  }

  // ============ FIELD OPERATIONS ============
  async configureField(data) {
    return this.client.post('/configure-field', data);
  }

  async unsetMask(data) {
    return this.client.post('/unset-mask', data);
  }

  async unsetAuthTag(data) {
    return this.client.post('/unset-auth-tag', data);
  }

  // ============ AUTHORIZATION TAGS ============
  async createAuthTag(data) {
    return this.client.post('/create-auth-tag', data);
  }

  async updateAuthTag(data) {
    return this.client.post('/update-auth-tag', data);
  }

  async deleteAuthTag(data) {
    return this.client.delete('/delete-auth-tag', { data });
  }

  // ============ ROLE MANAGEMENT ============
  async createRole(data) {
    return this.client.post('/create-role', data);
  }

  async deleteRole(data) {
    return this.client.delete('/delete-role', { data });
  }

  async grantRole(data) {
    return this.client.post('/grant-role', data);
  }

  async deleteGrantedRole(data) {
    return this.client.delete('/delete-granted-role', { data });
  }

  // ============ USER MANAGEMENT ============
  async createUser(data) {
    return this.client.post('/create-user', data);
  }

  async deleteUser(data) {
    return this.client.delete('/delete-user', { data });
  }

  // ============ INFORMATION RETRIEVAL ============
  async getMaskAndAuthTag(params) {
    return this.client.get('/mask-and-auth-tag', { params });
  }

  async getAuthTagRole(params) {
    return this.client.get('/auth-tag-role', { params });
  }

  async getUserRoleGrants(params) {
    return this.client.get('/user-role-grants', { params });
  }

  async getDDMConfig(params) {
    return this.client.get('/ddm-config', { params });
  }

  // ============ LEGACY METHODS (for backward compatibility) ============
  async maskValue(data) {
    return this.configureField(data);
  }

  async maskTable(data) {
    return this.setDDMConfig(data);
  }

  async addRule(data) {
    return this.setDDMConfig(data);
  }

  async loadConfiguration(data) {
    return this.setDDMConfig(data);
  }

  async getConfiguration() {
    return this.checkHealth();
  }

  async getAuditLogs() {
    return this.getUserRoleGrants({ userName: 'system' });
  }
}

export const apiService = new ApiService();
