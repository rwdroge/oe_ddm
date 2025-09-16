import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  TextField,
  Button,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Grid,
  Alert,
  Paper,
  Divider,
  Chip,
  Tabs,
  Tab,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Tooltip
} from '@mui/material';
import {
  Security as SecurityIcon,
  Add as AddIcon,
  Delete as DeleteIcon,
  Edit as EditIcon,
  Search as SearchIcon,
  Visibility as ViewIcon,
  Save as SaveIcon,
  Clear as ClearIcon
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

function TabPanel({ children, value, index, ...other }) {
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`simple-tabpanel-${index}`}
      aria-labelledby={`simple-tab-${index}`}
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

function FieldMasking() {
  const [tabValue, setTabValue] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState('');

  // DDM Configuration State
  const [ddmConfig, setDdmConfig] = useState({
    tableName: '',
    fieldName: '',
    maskValue: '',
    authTag: ''
  });

  // Field Configuration State
  const [fieldConfig, setFieldConfig] = useState({
    tableName: '',
    fieldName: '',
    maskingType: 'FULL',
    maskingValue: '',
    authTag: ''
  });

  // Search/View State
  const [searchParams, setSearchParams] = useState({
    tableName: '',
    fieldName: '',
    userName: ''
  });
  const [searchResults, setSearchResults] = useState(null);

  // Dialog State
  const [openDialog, setOpenDialog] = useState(false);
  const [dialogType, setDialogType] = useState('');

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
    setError(null);
    setSuccess('');
  };

  // DDM Configuration Operations
  const handleSetDDMConfig = async () => {
    if (!ddmConfig.tableName || !ddmConfig.fieldName || !ddmConfig.maskValue || !ddmConfig.authTag) {
      setError('All fields are required for DDM configuration');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.setDDMConfig(ddmConfig);
      setSuccess('DDM configuration set successfully');
      
      // Reset form
      setDdmConfig({
        tableName: '',
        fieldName: '',
        maskValue: '',
        authTag: ''
      });
    } catch (err) {
      setError('Failed to set DDM configuration: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleRemoveDDMConfig = async () => {
    if (!ddmConfig.tableName || !ddmConfig.fieldName) {
      setError('Table name and field name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.removeDDMConfig({
        tableName: ddmConfig.tableName,
        fieldName: ddmConfig.fieldName
      });
      setSuccess('DDM configuration removed successfully');
    } catch (err) {
      setError('Failed to remove DDM configuration: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  // Field Configuration Operations
  const handleConfigureField = async () => {
    if (!fieldConfig.tableName || !fieldConfig.fieldName || !fieldConfig.maskingValue || !fieldConfig.authTag) {
      setError('All fields are required for field configuration');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.configureField(fieldConfig);
      setSuccess('Field masking configured successfully');
      
      // Reset form
      setFieldConfig({
        tableName: '',
        fieldName: '',
        maskingType: 'FULL',
        maskingValue: '',
        authTag: ''
      });
    } catch (err) {
      setError('Failed to configure field masking: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleUnsetMask = async () => {
    if (!fieldConfig.tableName || !fieldConfig.fieldName) {
      setError('Table name and field name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.unsetMask({
        tableName: fieldConfig.tableName,
        fieldName: fieldConfig.fieldName
      });
      setSuccess('Field mask unset successfully');
    } catch (err) {
      setError('Failed to unset field mask: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleUnsetAuthTag = async () => {
    if (!fieldConfig.tableName || !fieldConfig.fieldName) {
      setError('Table name and field name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.unsetAuthTag({
        tableName: fieldConfig.tableName,
        fieldName: fieldConfig.fieldName
      });
      setSuccess('Authorization tag unset successfully');
    } catch (err) {
      setError('Failed to unset authorization tag: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  // Search Operations
  const handleSearchMaskAndAuthTag = async () => {
    if (!searchParams.tableName || !searchParams.fieldName) {
      setError('Table name and field name are required for search');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      const response = await apiService.getMaskAndAuthTag(searchParams);
      setSearchResults({
        type: 'maskAndAuthTag',
        data: response.data
      });
      setSuccess('Search completed successfully');
    } catch (err) {
      setError('Search failed: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        <SecurityIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
        Field Masking Management
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        Configure field-level data masking, authorization tags, and view existing configurations.
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
          <Tabs value={tabValue} onChange={handleTabChange} aria-label="field masking tabs">
            <Tab label="DDM Configuration" />
            <Tab label="Field Operations" />
            <Tab label="View & Search" />
          </Tabs>
        </Box>

        {/* DDM Configuration Tab */}
        <TabPanel value={tabValue} index={0}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Set DDM Configuration
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Configure DDM settings for a specific field with mask value and authorization tag.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Table Name"
                    value={ddmConfig.tableName}
                    onChange={(e) => setDdmConfig({...ddmConfig, tableName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., Customer"
                  />

                  <TextField
                    fullWidth
                    label="Field Name"
                    value={ddmConfig.fieldName}
                    onChange={(e) => setDdmConfig({...ddmConfig, fieldName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., CustNum"
                  />

                  <TextField
                    fullWidth
                    label="Mask Value"
                    value={ddmConfig.maskValue}
                    onChange={(e) => setDdmConfig({...ddmConfig, maskValue: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., ****"
                  />

                  <TextField
                    fullWidth
                    label="Authorization Tag"
                    value={ddmConfig.authTag}
                    onChange={(e) => setDdmConfig({...ddmConfig, authTag: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., SENSITIVE"
                  />

                  <Box display="flex" gap={1}>
                    <Button
                      variant="contained"
                      onClick={handleSetDDMConfig}
                      disabled={loading}
                      startIcon={<SaveIcon />}
                      sx={{ flex: 1 }}
                    >
                      Set Configuration
                    </Button>
                    <Button
                      variant="outlined"
                      color="error"
                      onClick={handleRemoveDDMConfig}
                      disabled={loading}
                      startIcon={<DeleteIcon />}
                      sx={{ flex: 1 }}
                    >
                      Remove Configuration
                    </Button>
                  </Box>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Configuration Examples
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Common DDM configuration patterns:
                  </Typography>

                  <Paper elevation={1} sx={{ p: 2, mb: 2, bgcolor: 'grey.50' }}>
                    <Typography variant="subtitle2" gutterBottom>SSN Masking</Typography>
                    <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>
                      Table: Employee<br/>
                      Field: SSN<br/>
                      Mask: XXX-XX-****<br/>
                      Auth Tag: PII
                    </Typography>
                  </Paper>

                  <Paper elevation={1} sx={{ p: 2, mb: 2, bgcolor: 'grey.50' }}>
                    <Typography variant="subtitle2" gutterBottom>Credit Card Masking</Typography>
                    <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>
                      Table: Payment<br/>
                      Field: CardNumber<br/>
                      Mask: ****-****-****-1234<br/>
                      Auth Tag: FINANCIAL
                    </Typography>
                  </Paper>

                  <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                    <Typography variant="subtitle2" gutterBottom>Email Masking</Typography>
                    <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>
                      Table: Customer<br/>
                      Field: Email<br/>
                      Mask: ****@****.com<br/>
                      Auth Tag: CONTACT
                    </Typography>
                  </Paper>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* Field Operations Tab */}
        <TabPanel value={tabValue} index={1}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={8}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Configure Field Masking
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    High-level field masking configuration with masking type and value.
                  </Typography>

                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Table Name"
                        value={fieldConfig.tableName}
                        onChange={(e) => setFieldConfig({...fieldConfig, tableName: e.target.value})}
                        placeholder="e.g., Customer"
                      />
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Field Name"
                        value={fieldConfig.fieldName}
                        onChange={(e) => setFieldConfig({...fieldConfig, fieldName: e.target.value})}
                        placeholder="e.g., Name"
                      />
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <FormControl fullWidth>
                        <InputLabel>Masking Type</InputLabel>
                        <Select
                          value={fieldConfig.maskingType}
                          label="Masking Type"
                          onChange={(e) => setFieldConfig({...fieldConfig, maskingType: e.target.value})}
                        >
                          <MenuItem value="FULL">Full Masking</MenuItem>
                          <MenuItem value="PARTIAL">Partial Masking</MenuItem>
                          <MenuItem value="CONDITIONAL">Conditional Masking</MenuItem>
                        </Select>
                      </FormControl>
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Masking Value"
                        value={fieldConfig.maskingValue}
                        onChange={(e) => setFieldConfig({...fieldConfig, maskingValue: e.target.value})}
                        placeholder="e.g., XXXX"
                      />
                    </Grid>
                    <Grid item xs={12}>
                      <TextField
                        fullWidth
                        label="Authorization Tag"
                        value={fieldConfig.authTag}
                        onChange={(e) => setFieldConfig({...fieldConfig, authTag: e.target.value})}
                        placeholder="e.g., PII"
                      />
                    </Grid>
                  </Grid>

                  <Box display="flex" gap={1} sx={{ mt: 3 }}>
                    <Button
                      variant="contained"
                      onClick={handleConfigureField}
                      disabled={loading}
                      startIcon={<SaveIcon />}
                    >
                      Configure Field
                    </Button>
                    <Button
                      variant="outlined"
                      onClick={handleUnsetMask}
                      disabled={loading}
                      startIcon={<ClearIcon />}
                    >
                      Unset Mask
                    </Button>
                    <Button
                      variant="outlined"
                      onClick={handleUnsetAuthTag}
                      disabled={loading}
                      startIcon={<ClearIcon />}
                    >
                      Unset Auth Tag
                    </Button>
                  </Box>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={4}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Masking Types
                  </Typography>
                  
                  <Box sx={{ mb: 2 }}>
                    <Chip label="FULL" color="primary" size="small" sx={{ mr: 1, mb: 1 }} />
                    <Typography variant="body2" color="textSecondary">
                      Complete masking with specified mask value
                    </Typography>
                  </Box>

                  <Box sx={{ mb: 2 }}>
                    <Chip label="PARTIAL" color="secondary" size="small" sx={{ mr: 1, mb: 1 }} />
                    <Typography variant="body2" color="textSecondary">
                      Partial masking preserving some characters
                    </Typography>
                  </Box>

                  <Box sx={{ mb: 2 }}>
                    <Chip label="CONDITIONAL" color="info" size="small" sx={{ mr: 1, mb: 1 }} />
                    <Typography variant="body2" color="textSecondary">
                      Conditional masking based on user permissions
                    </Typography>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* View & Search Tab */}
        <TabPanel value={tabValue} index={2}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Search Field Configuration
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Retrieve mask and authorization tag information for specific fields.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Table Name"
                    value={searchParams.tableName}
                    onChange={(e) => setSearchParams({...searchParams, tableName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., Customer"
                  />

                  <TextField
                    fullWidth
                    label="Field Name"
                    value={searchParams.fieldName}
                    onChange={(e) => setSearchParams({...searchParams, fieldName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., CustNum"
                  />

                  <TextField
                    fullWidth
                    label="User Name (Optional)"
                    value={searchParams.userName}
                    onChange={(e) => setSearchParams({...searchParams, userName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., testuser"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleSearchMaskAndAuthTag}
                    disabled={loading}
                    startIcon={<SearchIcon />}
                  >
                    Search Configuration
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Search Results
                  </Typography>

                  {searchResults ? (
                    <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                      <Typography variant="subtitle2" gutterBottom>
                        Configuration Details:
                      </Typography>
                      <Typography variant="body2" sx={{ fontFamily: 'monospace', whiteSpace: 'pre-wrap' }}>
                        {JSON.stringify(searchResults.data, null, 2)}
                      </Typography>
                    </Paper>
                  ) : (
                    <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                      <Typography variant="body2" color="textSecondary" align="center">
                        No search results yet. Use the search form to retrieve field configuration details.
                      </Typography>
                    </Paper>
                  )}
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>
      </Card>
    </Box>
  );
}

export default FieldMasking;
