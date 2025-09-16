import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  TextField,
  Button,
  Grid,
  Alert,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  IconButton,
  Chip
} from '@mui/material';
import {
  Add as AddIcon,
  Delete as DeleteIcon,
  Edit as EditIcon,
  Upload as UploadIcon,
  Download as DownloadIcon
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

function ConfigurationManager() {
  const [rules, setRules] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);
  const [openDialog, setOpenDialog] = useState(false);
  const [newRule, setNewRule] = useState({
    tableName: '',
    fieldName: '',
    maskType: 'SSN_MASK'
  });
  const [availableMaskTypes, setAvailableMaskTypes] = useState([]);

  useEffect(() => {
    loadConfiguration();
  }, []);

  const loadConfiguration = async () => {
    try {
      setLoading(true);
      const response = await apiService.getConfiguration();
      setAvailableMaskTypes(response.data.availableMaskTypes || []);
      // Mock rules data since we don't have a get rules endpoint yet
      setRules([
        { id: 1, tableName: 'Customer', fieldName: 'SSN', maskType: 'SSN_MASK' },
        { id: 2, tableName: 'Customer', fieldName: 'CreditCard', maskType: 'CREDIT_CARD_MASK' },
        { id: 3, tableName: 'Customer', fieldName: 'Email', maskType: 'EMAIL_MASK' },
        { id: 4, tableName: 'Employee', fieldName: 'SSN', maskType: 'SSN_MASK' },
        { id: 5, tableName: 'Employee', fieldName: 'Phone', maskType: 'PHONE_MASK' }
      ]);
      setError(null);
    } catch (err) {
      setError('Failed to load configuration: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleAddRule = async () => {
    if (!newRule.tableName || !newRule.fieldName) {
      setError('Please fill in all required fields');
      return;
    }

    try {
      setLoading(true);
      await apiService.addRule(newRule);
      
      // Add to local state
      const newId = Math.max(...rules.map(r => r.id), 0) + 1;
      setRules([...rules, { ...newRule, id: newId }]);
      
      setOpenDialog(false);
      setNewRule({ tableName: '', fieldName: '', maskType: 'SSN_MASK' });
      setSuccess(true);
      setError(null);
    } catch (err) {
      setError('Failed to add rule: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteRule = (ruleId) => {
    setRules(rules.filter(rule => rule.id !== ruleId));
    setSuccess(true);
  };

  const handleLoadConfigFile = async () => {
    try {
      setLoading(true);
      await apiService.loadConfiguration({ configFile: 'conf/masking-config.json' });
      await loadConfiguration();
      setSuccess(true);
      setError(null);
    } catch (err) {
      setError('Failed to load config file: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const getMaskTypeColor = (maskType) => {
    const colors = {
      'SSN_MASK': 'primary',
      'CREDIT_CARD_MASK': 'secondary',
      'EMAIL_MASK': 'success',
      'PHONE_MASK': 'warning',
      'GENERIC_MASK': 'info'
    };
    return colors[maskType] || 'default';
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Configuration Manager
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        Manage masking rules and configuration settings for your data protection policies.
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {success && (
        <Alert severity="success" sx={{ mb: 3 }}>
          Configuration updated successfully!
        </Alert>
      )}

      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
                <Typography variant="h6">
                  Masking Rules
                </Typography>
                <Box>
                  <Button
                    variant="outlined"
                    startIcon={<UploadIcon />}
                    onClick={handleLoadConfigFile}
                    sx={{ mr: 1 }}
                    disabled={loading}
                  >
                    Load Config File
                  </Button>
                  <Button
                    variant="contained"
                    startIcon={<AddIcon />}
                    onClick={() => setOpenDialog(true)}
                  >
                    Add Rule
                  </Button>
                </Box>
              </Box>

              <TableContainer component={Paper} variant="outlined">
                <Table>
                  <TableHead>
                    <TableRow>
                      <TableCell>Table Name</TableCell>
                      <TableCell>Field Name</TableCell>
                      <TableCell>Mask Type</TableCell>
                      <TableCell align="right">Actions</TableCell>
                    </TableRow>
                  </TableHead>
                  <TableBody>
                    {rules.map((rule) => (
                      <TableRow key={rule.id}>
                        <TableCell>
                          <Typography variant="body2" fontWeight="medium">
                            {rule.tableName}
                          </Typography>
                        </TableCell>
                        <TableCell>{rule.fieldName}</TableCell>
                        <TableCell>
                          <Chip 
                            label={rule.maskType}
                            color={getMaskTypeColor(rule.maskType)}
                            size="small"
                          />
                        </TableCell>
                        <TableCell align="right">
                          <IconButton
                            size="small"
                            onClick={() => handleDeleteRule(rule.id)}
                            color="error"
                          >
                            <DeleteIcon />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    ))}
                    {rules.length === 0 && (
                      <TableRow>
                        <TableCell colSpan={4} align="center">
                          <Typography color="textSecondary">
                            No masking rules configured. Click "Add Rule" to get started.
                          </Typography>
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </TableContainer>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Configuration Summary
              </Typography>
              <Typography variant="body2" color="textSecondary" paragraph>
                Current configuration statistics and settings.
              </Typography>
              
              <Box sx={{ mb: 2 }}>
                <Typography variant="body2">
                  <strong>Total Rules:</strong> {rules.length}
                </Typography>
                <Typography variant="body2">
                  <strong>Protected Tables:</strong> {new Set(rules.map(r => r.tableName)).size}
                </Typography>
                <Typography variant="body2">
                  <strong>Most Used Mask Type:</strong> SSN_MASK
                </Typography>
              </Box>

              <Button
                variant="outlined"
                startIcon={<DownloadIcon />}
                fullWidth
                disabled
              >
                Export Configuration (Coming Soon)
              </Button>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Available Mask Types
              </Typography>
              <Typography variant="body2" color="textSecondary" paragraph>
                Supported masking algorithms in your system.
              </Typography>
              
              <Box display="flex" flexDirection="column" gap={1}>
                {availableMaskTypes.map((type) => (
                  <Box key={type.type} sx={{ p: 1, border: 1, borderColor: 'grey.300', borderRadius: 1 }}>
                    <Typography variant="body2" fontWeight="medium">
                      {type.type}
                    </Typography>
                    <Typography variant="caption" color="textSecondary">
                      {type.description}
                    </Typography>
                  </Box>
                ))}
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Add Rule Dialog */}
      <Dialog open={openDialog} onClose={() => setOpenDialog(false)} maxWidth="sm" fullWidth>
        <DialogTitle>Add New Masking Rule</DialogTitle>
        <DialogContent>
          <Box sx={{ pt: 1 }}>
            <TextField
              fullWidth
              label="Table Name"
              value={newRule.tableName}
              onChange={(e) => setNewRule({ ...newRule, tableName: e.target.value })}
              sx={{ mb: 2 }}
              placeholder="e.g., Customer, Employee"
            />
            
            <TextField
              fullWidth
              label="Field Name"
              value={newRule.fieldName}
              onChange={(e) => setNewRule({ ...newRule, fieldName: e.target.value })}
              sx={{ mb: 2 }}
              placeholder="e.g., SSN, CreditCard, Email"
            />
            
            <FormControl fullWidth>
              <InputLabel>Mask Type</InputLabel>
              <Select
                value={newRule.maskType}
                label="Mask Type"
                onChange={(e) => setNewRule({ ...newRule, maskType: e.target.value })}
              >
                {availableMaskTypes.map((type) => (
                  <MenuItem key={type.type} value={type.type}>
                    {type.type} - {type.description}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Cancel</Button>
          <Button 
            onClick={handleAddRule} 
            variant="contained"
            disabled={loading || !newRule.tableName || !newRule.fieldName}
          >
            Add Rule
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default ConfigurationManager;
