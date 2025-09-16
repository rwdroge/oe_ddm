import React, { useState, useEffect } from 'react';
import {
  Box,
  Card,
  CardContent,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  TextField,
  Button,
  Grid,
  Alert,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  IconButton,
  Tooltip
} from '@mui/material';
import {
  Refresh as RefreshIcon,
  Download as DownloadIcon,
  FilterList as FilterIcon,
  Search as SearchIcon
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

function AuditLogs() {
  const [logs, setLogs] = useState([]);
  const [filteredLogs, setFilteredLogs] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [logLevelFilter, setLogLevelFilter] = useState('ALL');
  const [tableFilter, setTableFilter] = useState('ALL');

  useEffect(() => {
    loadAuditLogs();
  }, []);

  useEffect(() => {
    filterLogs();
  }, [logs, searchTerm, logLevelFilter, tableFilter]);

  const loadAuditLogs = async () => {
    try {
      setLoading(true);
      const response = await apiService.getAuditLogs();
      const logsData = response.data.logs || [];
      
      // Add some mock data if no logs are returned
      const mockLogs = logsData.length === 0 ? [
        {
          logId: 1,
          logLevel: 'INFO',
          tableName: 'Customer',
          fieldName: 'SSN',
          recordId: '1001',
          maskType: 'SSN_MASK',
          userId: 'admin',
          sessionId: 'session_123',
          logTime: new Date().toISOString(),
          additionalInfo: 'Single value masking operation'
        },
        {
          logId: 2,
          logLevel: 'INFO',
          tableName: 'Customer',
          fieldName: 'Email',
          recordId: '1002',
          maskType: 'EMAIL_MASK',
          userId: 'user1',
          sessionId: 'session_124',
          logTime: new Date(Date.now() - 3600000).toISOString(),
          additionalInfo: 'Batch masking operation'
        },
        {
          logId: 3,
          logLevel: 'ERROR',
          tableName: 'Employee',
          fieldName: 'Phone',
          recordId: null,
          maskType: null,
          userId: 'user2',
          sessionId: 'session_125',
          logTime: new Date(Date.now() - 7200000).toISOString(),
          additionalInfo: 'Invalid phone number format'
        },
        {
          logId: 4,
          logLevel: 'INFO',
          tableName: 'API',
          fieldName: 'single-value',
          recordId: 'N/A',
          maskType: 'CREDIT_CARD_MASK',
          userId: 'api_user',
          sessionId: 'session_126',
          logTime: new Date(Date.now() - 10800000).toISOString(),
          additionalInfo: 'REST API masking request'
        }
      ] : logsData;
      
      setLogs(mockLogs);
      setError(null);
    } catch (err) {
      setError('Failed to load audit logs: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const filterLogs = () => {
    let filtered = [...logs];

    // Search filter
    if (searchTerm) {
      filtered = filtered.filter(log =>
        log.tableName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        log.fieldName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        log.userId?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        log.additionalInfo?.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Log level filter
    if (logLevelFilter !== 'ALL') {
      filtered = filtered.filter(log => log.logLevel === logLevelFilter);
    }

    // Table filter
    if (tableFilter !== 'ALL') {
      filtered = filtered.filter(log => log.tableName === tableFilter);
    }

    setFilteredLogs(filtered);
  };

  const getLogLevelColor = (level) => {
    switch (level) {
      case 'ERROR': return 'error';
      case 'WARN': return 'warning';
      case 'INFO': return 'info';
      default: return 'default';
    }
  };

  const formatDateTime = (dateString) => {
    return new Date(dateString).toLocaleString();
  };

  const getUniqueTables = () => {
    const tables = [...new Set(logs.map(log => log.tableName).filter(Boolean))];
    return tables.sort();
  };

  const exportLogs = () => {
    const csvContent = [
      ['Log ID', 'Level', 'Table', 'Field', 'Record ID', 'Mask Type', 'User', 'Time', 'Info'],
      ...filteredLogs.map(log => [
        log.logId,
        log.logLevel,
        log.tableName || '',
        log.fieldName || '',
        log.recordId || '',
        log.maskType || '',
        log.userId || '',
        formatDateTime(log.logTime),
        log.additionalInfo || ''
      ])
    ].map(row => row.join(',')).join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `ddm_audit_logs_${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Audit Logs
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        Monitor and track all data masking operations for compliance and security auditing.
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      <Card sx={{ mb: 3 }}>
        <CardContent>
          <Grid container spacing={2} alignItems="center">
            <Grid item xs={12} sm={6} md={3}>
              <TextField
                fullWidth
                size="small"
                label="Search logs"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                InputProps={{
                  startAdornment: <SearchIcon sx={{ mr: 1, color: 'action.active' }} />
                }}
              />
            </Grid>
            
            <Grid item xs={12} sm={6} md={2}>
              <FormControl fullWidth size="small">
                <InputLabel>Log Level</InputLabel>
                <Select
                  value={logLevelFilter}
                  label="Log Level"
                  onChange={(e) => setLogLevelFilter(e.target.value)}
                >
                  <MenuItem value="ALL">All Levels</MenuItem>
                  <MenuItem value="INFO">Info</MenuItem>
                  <MenuItem value="WARN">Warning</MenuItem>
                  <MenuItem value="ERROR">Error</MenuItem>
                </Select>
              </FormControl>
            </Grid>

            <Grid item xs={12} sm={6} md={2}>
              <FormControl fullWidth size="small">
                <InputLabel>Table</InputLabel>
                <Select
                  value={tableFilter}
                  label="Table"
                  onChange={(e) => setTableFilter(e.target.value)}
                >
                  <MenuItem value="ALL">All Tables</MenuItem>
                  {getUniqueTables().map(table => (
                    <MenuItem key={table} value={table}>{table}</MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>

            <Grid item xs={12} sm={6} md={5}>
              <Box display="flex" gap={1} justifyContent="flex-end">
                <Tooltip title="Refresh logs">
                  <IconButton onClick={loadAuditLogs} disabled={loading}>
                    <RefreshIcon />
                  </IconButton>
                </Tooltip>
                <Button
                  variant="outlined"
                  startIcon={<DownloadIcon />}
                  onClick={exportLogs}
                  disabled={filteredLogs.length === 0}
                >
                  Export CSV
                </Button>
              </Box>
            </Grid>
          </Grid>
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
            <Typography variant="h6">
              Audit Log Entries ({filteredLogs.length})
            </Typography>
          </Box>

          <TableContainer component={Paper} variant="outlined">
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Time</TableCell>
                  <TableCell>Level</TableCell>
                  <TableCell>Table</TableCell>
                  <TableCell>Field</TableCell>
                  <TableCell>Mask Type</TableCell>
                  <TableCell>User</TableCell>
                  <TableCell>Details</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredLogs.map((log) => (
                  <TableRow key={log.logId} hover>
                    <TableCell>
                      <Typography variant="body2" sx={{ fontFamily: 'monospace', fontSize: '0.75rem' }}>
                        {formatDateTime(log.logTime)}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Chip 
                        label={log.logLevel}
                        color={getLogLevelColor(log.logLevel)}
                        size="small"
                      />
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" fontWeight="medium">
                        {log.tableName || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>{log.fieldName || '-'}</TableCell>
                    <TableCell>
                      {log.maskType ? (
                        <Chip label={log.maskType} size="small" variant="outlined" />
                      ) : '-'}
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2">
                        {log.userId || '-'}
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <Typography variant="body2" color="textSecondary">
                        {log.additionalInfo || '-'}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ))}
                {filteredLogs.length === 0 && (
                  <TableRow>
                    <TableCell colSpan={7} align="center">
                      <Typography color="textSecondary" sx={{ py: 3 }}>
                        {logs.length === 0 ? 'No audit logs available' : 'No logs match the current filters'}
                      </Typography>
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </CardContent>
      </Card>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Log Statistics
              </Typography>
              <Typography variant="body2">
                <strong>Total Entries:</strong> {logs.length}
              </Typography>
              <Typography variant="body2">
                <strong>Info:</strong> {logs.filter(l => l.logLevel === 'INFO').length}
              </Typography>
              <Typography variant="body2">
                <strong>Warnings:</strong> {logs.filter(l => l.logLevel === 'WARN').length}
              </Typography>
              <Typography variant="body2">
                <strong>Errors:</strong> {logs.filter(l => l.logLevel === 'ERROR').length}
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Most Active Tables
              </Typography>
              {getUniqueTables().slice(0, 5).map(table => (
                <Typography key={table} variant="body2">
                  <strong>{table}:</strong> {logs.filter(l => l.tableName === table).length} operations
                </Typography>
              ))}
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Recent Activity
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Last operation: {logs.length > 0 ? formatDateTime(logs[0].logTime) : 'No activity'}
              </Typography>
              <Typography variant="body2" color="textSecondary">
                Operations today: {logs.filter(l => 
                  new Date(l.logTime).toDateString() === new Date().toDateString()
                ).length}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

export default AuditLogs;
