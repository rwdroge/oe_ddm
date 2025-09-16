import React, { useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  TextField,
  Button,
  Grid,
  Alert,
  Paper,
  Tabs,
  Tab,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Chip,
  Accordion,
  AccordionSummary,
  AccordionDetails
} from '@mui/material';
import {
  Info as InfoIcon,
  Search as SearchIcon,
  Visibility as VisibilityIcon,
  Assessment as AssessmentIcon,
  ExpandMore as ExpandMoreIcon,
  TableChart as TableIcon,
  Security as SecurityIcon,
  Person as PersonIcon
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

function TabPanel({ children, value, index, ...other }) {
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`info-tabpanel-${index}`}
      aria-labelledby={`info-tab-${index}`}
      {...other}
    >
      {value === index && (
        <Box sx={{ p: 3 }}>
          {children}
        </Box>
      )}
    </div>
  );
}

function InformationMonitoring() {
  const [tabValue, setTabValue] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState('');

  // Field Configuration Search
  const [fieldSearch, setFieldSearch] = useState({
    tableName: '',
    fieldName: '',
    userName: ''
  });
  const [fieldResults, setFieldResults] = useState(null);

  // Authorization Tag Search
  const [authTagSearch, setAuthTagSearch] = useState({
    domainName: '',
    authTagName: ''
  });
  const [authTagResults, setAuthTagResults] = useState(null);

  // User Role Search
  const [userRoleSearch, setUserRoleSearch] = useState({
    userName: ''
  });
  const [userRoleResults, setUserRoleResults] = useState(null);

  // DDM Config Search
  const [ddmConfigSearch, setDdmConfigSearch] = useState({
    tableName: '',
    fieldName: '',
    userName: ''
  });
  const [ddmConfigResults, setDdmConfigResults] = useState(null);

  // System Health
  const [healthStatus, setHealthStatus] = useState(null);

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
    setError(null);
    setSuccess('');
  };

  const handleFieldConfigSearch = async () => {
    if (!fieldSearch.tableName || !fieldSearch.fieldName) {
      setError('Table name and field name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      const response = await apiService.getMaskAndAuthTag(fieldSearch);
      setFieldResults(response.data);
      setSuccess('Field configuration retrieved successfully');
    } catch (err) {
      setError('Search failed: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleAuthTagSearch = async () => {
    if (!authTagSearch.domainName || !authTagSearch.authTagName) {
      setError('Domain name and authorization tag name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      const response = await apiService.getAuthTagRole(authTagSearch);
      setAuthTagResults(response.data);
      setSuccess('Authorization tag information retrieved successfully');
    } catch (err) {
      setError('Search failed: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleUserRoleSearch = async () => {
    if (!userRoleSearch.userName) {
      setError('Username is required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      const response = await apiService.getUserRoleGrants(userRoleSearch);
      setUserRoleResults(response.data);
      setSuccess('User role grants retrieved successfully');
    } catch (err) {
      setError('Search failed: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleDDMConfigSearch = async () => {
    if (!ddmConfigSearch.tableName || !ddmConfigSearch.fieldName) {
      setError('Table name and field name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      const response = await apiService.getDDMConfig(ddmConfigSearch);
      setDdmConfigResults(response.data);
      setSuccess('DDM configuration retrieved successfully');
    } catch (err) {
      if (err.response?.status === 501) {
        setError('DDM configuration retrieval is not implemented in OpenEdge 12.8 - use field configuration search instead');
      } else {
        setError('Search failed: ' + (err.response?.data?.error || err.message));
      }
    } finally {
      setLoading(false);
    }
  };

  const handleHealthCheck = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await apiService.checkHealth();
      setHealthStatus(response.data);
      setSuccess('System health check completed');
    } catch (err) {
      setError('Health check failed: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const ResultDisplay = ({ title, data, icon }) => (
    <Card variant="outlined" sx={{ mt: 2 }}>
      <CardContent>
        <Typography variant="h6" gutterBottom>
          {icon}
          {title}
        </Typography>
        {data ? (
          <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
            <Typography variant="body2" sx={{ fontFamily: 'monospace', whiteSpace: 'pre-wrap' }}>
              {typeof data === 'string' ? data : JSON.stringify(data, null, 2)}
            </Typography>
          </Paper>
        ) : (
          <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
            <Typography variant="body2" color="textSecondary" align="center">
              No results available. Perform a search to see data here.
            </Typography>
          </Paper>
        )}
      </CardContent>
    </Card>
  );

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        <InfoIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
        Information & Monitoring
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        View DDM configurations, monitor system health, and retrieve detailed information about fields, users, and roles.
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {success && (
        <Alert severity="success" sx={{ mb: 3 }}>
          {success}
        </Alert>
      )}

      <Card>
        <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
          <Tabs value={tabValue} onChange={handleTabChange} aria-label="information monitoring tabs">
            <Tab label="Field Information" />
            <Tab label="Authorization Tags" />
            <Tab label="User Roles" />
            <Tab label="System Health" />
          </Tabs>
        </Box>

        {/* Field Information Tab */}
        <TabPanel value={tabValue} index={0}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <TableIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Field Configuration Search
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Retrieve mask and authorization tag information for specific fields.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Table Name"
                    value={fieldSearch.tableName}
                    onChange={(e) => setFieldSearch({...fieldSearch, tableName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., Customer"
                  />

                  <TextField
                    fullWidth
                    label="Field Name"
                    value={fieldSearch.fieldName}
                    onChange={(e) => setFieldSearch({...fieldSearch, fieldName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., CustNum"
                  />

                  <TextField
                    fullWidth
                    label="User Name (Optional)"
                    value={fieldSearch.userName}
                    onChange={(e) => setFieldSearch({...fieldSearch, userName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., testuser"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleFieldConfigSearch}
                    disabled={loading}
                    startIcon={<SearchIcon />}
                    size="large"
                  >
                    Search Field Configuration
                  </Button>
                </CardContent>
              </Card>

              <Accordion sx={{ mt: 2 }}>
                <AccordionSummary expandIcon={<ExpandMoreIcon />}>
                  <Typography variant="h6">DDM Configuration Search (Limited)</Typography>
                </AccordionSummary>
                <AccordionDetails>
                  <Alert severity="info" sx={{ mb: 2 }}>
                    This endpoint returns "Not Implemented" in OpenEdge 12.8. Use Field Configuration Search instead.
                  </Alert>
                  
                  <TextField
                    fullWidth
                    label="Table Name"
                    value={ddmConfigSearch.tableName}
                    onChange={(e) => setDdmConfigSearch({...ddmConfigSearch, tableName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., Customer"
                  />

                  <TextField
                    fullWidth
                    label="Field Name"
                    value={ddmConfigSearch.fieldName}
                    onChange={(e) => setDdmConfigSearch({...ddmConfigSearch, fieldName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., CustNum"
                  />

                  <TextField
                    fullWidth
                    label="User Name (Optional)"
                    value={ddmConfigSearch.userName}
                    onChange={(e) => setDdmConfigSearch({...ddmConfigSearch, userName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., testuser"
                  />

                  <Button
                    variant="outlined"
                    fullWidth
                    onClick={handleDDMConfigSearch}
                    disabled={loading}
                    startIcon={<SearchIcon />}
                  >
                    Try DDM Config Search
                  </Button>
                </AccordionDetails>
              </Accordion>
            </Grid>

            <Grid item xs={12} md={6}>
              <ResultDisplay 
                title="Field Configuration Results"
                data={fieldResults}
                icon={<VisibilityIcon sx={{ mr: 1, verticalAlign: 'middle' }} />}
              />
              
              {ddmConfigResults && (
                <ResultDisplay 
                  title="DDM Configuration Results"
                  data={ddmConfigResults}
                  icon={<SecurityIcon sx={{ mr: 1, verticalAlign: 'middle' }} />}
                />
              )}
            </Grid>
          </Grid>
        </TabPanel>

        {/* Authorization Tags Tab */}
        <TabPanel value={tabValue} index={1}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <SecurityIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Authorization Tag & Role Search
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Retrieve authorization tag and its associated role information.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Domain Name"
                    value={authTagSearch.domainName}
                    onChange={(e) => setAuthTagSearch({...authTagSearch, domainName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., TestDomain"
                  />

                  <TextField
                    fullWidth
                    label="Authorization Tag Name"
                    value={authTagSearch.authTagName}
                    onChange={(e) => setAuthTagSearch({...authTagSearch, authTagName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., SENSITIVE"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleAuthTagSearch}
                    disabled={loading}
                    startIcon={<SearchIcon />}
                    size="large"
                  >
                    Search Authorization Tag
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <ResultDisplay 
                title="Authorization Tag & Role Results"
                data={authTagResults}
                icon={<SecurityIcon sx={{ mr: 1, verticalAlign: 'middle' }} />}
              />
            </Grid>

            <Grid item xs={12}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Common Authorization Tag Patterns
                  </Typography>
                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2, bgcolor: 'error.50' }}>
                        <Chip label="PII" color="error" size="small" sx={{ mb: 1 }} />
                        <Typography variant="body2">
                          Personally Identifiable Information - highest security level
                        </Typography>
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2, bgcolor: 'warning.50' }}>
                        <Chip label="FINANCIAL" color="warning" size="small" sx={{ mb: 1 }} />
                        <Typography variant="body2">
                          Financial data requiring special handling
                        </Typography>
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2, bgcolor: 'info.50' }}>
                        <Chip label="CONFIDENTIAL" color="info" size="small" sx={{ mb: 1 }} />
                        <Typography variant="body2">
                          Confidential business information
                        </Typography>
                      </Paper>
                    </Grid>
                  </Grid>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* User Roles Tab */}
        <TabPanel value={tabValue} index={2}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <PersonIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    User Role Grants Search
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Retrieve all role grants for a specific user.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Username"
                    value={userRoleSearch.userName}
                    onChange={(e) => setUserRoleSearch({...userRoleSearch, userName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., testuser"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleUserRoleSearch}
                    disabled={loading}
                    startIcon={<SearchIcon />}
                    size="large"
                  >
                    Search User Role Grants
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <ResultDisplay 
                title="User Role Grants Results"
                data={userRoleResults}
                icon={<PersonIcon sx={{ mr: 1, verticalAlign: 'middle' }} />}
              />
            </Grid>
          </Grid>
        </TabPanel>

        {/* System Health Tab */}
        <TabPanel value={tabValue} index={3}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <AssessmentIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    System Health Check
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Check the health status of the DDM API service and system components.
                  </Typography>

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleHealthCheck}
                    disabled={loading}
                    startIcon={<AssessmentIcon />}
                    size="large"
                  >
                    Run Health Check
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    System Status
                  </Typography>
                  {healthStatus ? (
                    <Box>
                      <Alert severity="success" sx={{ mb: 2 }}>
                        API Status: {healthStatus.status}
                      </Alert>
                      <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                        <Typography variant="body2">
                          <strong>Service:</strong> {healthStatus.service}<br/>
                          <strong>Version:</strong> {healthStatus.version}<br/>
                          <strong>Database:</strong> {healthStatus.database}<br/>
                          <strong>Timestamp:</strong> {healthStatus.timestamp}
                        </Typography>
                      </Paper>
                    </Box>
                  ) : (
                    <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                      <Typography variant="body2" color="textSecondary" align="center">
                        Click "Run Health Check" to see system status information.
                      </Typography>
                    </Paper>
                  )}
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Available API Endpoints
                  </Typography>
                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2 }}>
                        <Typography variant="subtitle2" gutterBottom>Health & System</Typography>
                        <Chip label="GET /health" size="small" color="success" />
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2 }}>
                        <Typography variant="subtitle2" gutterBottom>DDM Configuration</Typography>
                        <Box display="flex" flexDirection="column" gap={0.5}>
                          <Chip label="POST /set-ddm-config" size="small" color="primary" />
                          <Chip label="DELETE /remove-ddm-config" size="small" color="error" />
                        </Box>
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2 }}>
                        <Typography variant="subtitle2" gutterBottom>Field Operations</Typography>
                        <Box display="flex" flexDirection="column" gap={0.5}>
                          <Chip label="POST /configure-field" size="small" color="primary" />
                          <Chip label="POST /unset-mask" size="small" color="warning" />
                          <Chip label="POST /unset-auth-tag" size="small" color="warning" />
                        </Box>
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2 }}>
                        <Typography variant="subtitle2" gutterBottom>Authorization Tags</Typography>
                        <Box display="flex" flexDirection="column" gap={0.5}>
                          <Chip label="POST /create-auth-tag" size="small" color="primary" />
                          <Chip label="POST /update-auth-tag" size="small" color="info" />
                          <Chip label="DELETE /delete-auth-tag" size="small" color="error" />
                        </Box>
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2 }}>
                        <Typography variant="subtitle2" gutterBottom>Role Management</Typography>
                        <Box display="flex" flexDirection="column" gap={0.5}>
                          <Chip label="POST /create-role" size="small" color="primary" />
                          <Chip label="DELETE /delete-role" size="small" color="error" />
                          <Chip label="POST /grant-role" size="small" color="success" />
                          <Chip label="DELETE /delete-granted-role" size="small" color="error" />
                        </Box>
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={6} md={4}>
                      <Paper elevation={1} sx={{ p: 2 }}>
                        <Typography variant="subtitle2" gutterBottom>User Management</Typography>
                        <Box display="flex" flexDirection="column" gap={0.5}>
                          <Chip label="POST /create-user" size="small" color="primary" />
                          <Chip label="DELETE /delete-user" size="small" color="error" />
                        </Box>
                      </Paper>
                    </Grid>
                  </Grid>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>
      </Card>
    </Box>
  );
}

export default InformationMonitoring;
