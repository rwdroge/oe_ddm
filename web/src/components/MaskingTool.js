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
  Chip
} from '@mui/material';
import {
  Security as SecurityIcon,
  PlayArrow as PlayIcon,
  ContentCopy as CopyIcon
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

function MaskingTool() {
  const [inputValue, setInputValue] = useState('');
  const [maskType, setMaskType] = useState('SSN_MASK');
  const [maskedResult, setMaskedResult] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);
  const [availableMaskTypes, setAvailableMaskTypes] = useState([]);

  useEffect(() => {
    loadMaskTypes();
  }, []);

  const loadMaskTypes = async () => {
    try {
      const response = await apiService.getConfiguration();
      setAvailableMaskTypes(response.data.availableMaskTypes || []);
    } catch (err) {
      console.error('Failed to load mask types:', err);
    }
  };

  const handleMaskValue = async () => {
    if (!inputValue.trim()) {
      setError('Please enter a value to mask');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      setSuccess(false);

      const response = await apiService.maskValue({
        value: inputValue,
        maskType: maskType
      });

      setMaskedResult(response.data.maskedValue);
      setSuccess(true);
    } catch (err) {
      setError('Failed to mask value: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleCopyResult = () => {
    navigator.clipboard.writeText(maskedResult);
  };

  const exampleValues = {
    'SSN_MASK': '123-45-6789',
    'CREDIT_CARD_MASK': '4532-1234-5678-9012',
    'EMAIL_MASK': 'john.doe@example.com',
    'PHONE_MASK': '(555) 123-4567',
    'GENERIC_MASK': 'SensitiveData123'
  };

  const handleUseExample = () => {
    const example = exampleValues[maskType];
    if (example) {
      setInputValue(example);
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Data Masking Tool
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        Test individual value masking with different algorithms. Enter a value below and select a masking type to see the result.
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                <SecurityIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                Input Configuration
              </Typography>

              <Box sx={{ mb: 3 }}>
                <TextField
                  fullWidth
                  label="Value to Mask"
                  value={inputValue}
                  onChange={(e) => setInputValue(e.target.value)}
                  placeholder="Enter sensitive data to mask..."
                  variant="outlined"
                  sx={{ mb: 2 }}
                />

                <FormControl fullWidth sx={{ mb: 2 }}>
                  <InputLabel>Masking Type</InputLabel>
                  <Select
                    value={maskType}
                    label="Masking Type"
                    onChange={(e) => setMaskType(e.target.value)}
                  >
                    {availableMaskTypes.map((type) => (
                      <MenuItem key={type.type} value={type.type}>
                        {type.type} - {type.description}
                      </MenuItem>
                    ))}
                  </Select>
                </FormControl>

                <Box sx={{ mb: 2 }}>
                  <Button
                    variant="outlined"
                    size="small"
                    onClick={handleUseExample}
                    sx={{ mr: 1 }}
                  >
                    Use Example
                  </Button>
                  {exampleValues[maskType] && (
                    <Chip 
                      label={`Example: ${exampleValues[maskType]}`}
                      size="small"
                      variant="outlined"
                    />
                  )}
                </Box>

                <Button
                  variant="contained"
                  fullWidth
                  onClick={handleMaskValue}
                  disabled={loading || !inputValue.trim()}
                  startIcon={<PlayIcon />}
                  size="large"
                >
                  {loading ? 'Masking...' : 'Apply Masking'}
                </Button>
              </Box>

              {error && (
                <Alert severity="error" sx={{ mb: 2 }}>
                  {error}
                </Alert>
              )}

              {success && (
                <Alert severity="success" sx={{ mb: 2 }}>
                  Value masked successfully!
                </Alert>
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Masking Result
              </Typography>

              <Paper elevation={1} sx={{ p: 2, mb: 2, bgcolor: 'grey.50' }}>
                <Typography variant="subtitle2" color="textSecondary">
                  Original Value:
                </Typography>
                <Typography variant="body1" sx={{ fontFamily: 'monospace', mb: 2 }}>
                  {inputValue || 'No input provided'}
                </Typography>

                <Divider sx={{ my: 1 }} />

                <Typography variant="subtitle2" color="textSecondary">
                  Masked Value:
                </Typography>
                <Box display="flex" alignItems="center" gap={1}>
                  <Typography 
                    variant="body1" 
                    sx={{ 
                      fontFamily: 'monospace',
                      fontWeight: 'bold',
                      color: maskedResult ? 'primary.main' : 'text.disabled'
                    }}
                  >
                    {maskedResult || 'Click "Apply Masking" to see result'}
                  </Typography>
                  {maskedResult && (
                    <Button
                      size="small"
                      variant="outlined"
                      startIcon={<CopyIcon />}
                      onClick={handleCopyResult}
                    >
                      Copy
                    </Button>
                  )}
                </Box>
              </Paper>

              {maskType && availableMaskTypes.length > 0 && (
                <Box>
                  <Typography variant="subtitle2" gutterBottom>
                    Selected Masking Type Details:
                  </Typography>
                  {availableMaskTypes
                    .filter(type => type.type === maskType)
                    .map(type => (
                      <Box key={type.type}>
                        <Typography variant="body2" color="textSecondary">
                          <strong>Pattern:</strong> {type.pattern}
                        </Typography>
                        <Typography variant="body2" color="textSecondary">
                          <strong>Description:</strong> {type.description}
                        </Typography>
                      </Box>
                    ))
                  }
                </Box>
              )}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Available Masking Types
              </Typography>
              <Grid container spacing={2}>
                {availableMaskTypes.map((type) => (
                  <Grid item xs={12} sm={6} md={4} key={type.type}>
                    <Paper 
                      elevation={1} 
                      sx={{ 
                        p: 2, 
                        cursor: 'pointer',
                        border: maskType === type.type ? 2 : 0,
                        borderColor: 'primary.main'
                      }}
                      onClick={() => setMaskType(type.type)}
                    >
                      <Typography variant="subtitle1" fontWeight="bold">
                        {type.type}
                      </Typography>
                      <Typography variant="body2" color="textSecondary">
                        {type.description}
                      </Typography>
                      <Typography variant="caption" sx={{ fontFamily: 'monospace' }}>
                        Pattern: {type.pattern}
                      </Typography>
                    </Paper>
                  </Grid>
                ))}
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

export default MaskingTool;
