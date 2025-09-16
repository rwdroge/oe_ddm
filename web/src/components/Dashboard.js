import React, { useState, useEffect } from 'react';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  Chip,
  LinearProgress,
  Alert
} from '@mui/material';
import {
  Security as SecurityIcon,
  TableChart as TableIcon,
  Assessment as AssessmentIcon,
  CheckCircle as CheckIcon
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

function Dashboard() {
  const [healthStatus, setHealthStatus] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    checkApiHealth();
  }, []);

  const checkApiHealth = async () => {
    try {
      setLoading(true);
      const response = await apiService.checkHealth();
      setHealthStatus(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to connect to DDM API');
      console.error('Health check failed:', err);
    } finally {
      setLoading(false);
    }
  };

  const StatCard = ({ title, value, icon, color = 'primary' }) => (
    <Card>
      <CardContent>
        <Box display="flex" alignItems="center" justifyContent="space-between">
          <Box>
            <Typography color="textSecondary" gutterBottom>
              {title}
            </Typography>
            <Typography variant="h4" component="div">
              {value}
            </Typography>
          </Box>
          <Box color={`${color}.main`}>
            {icon}
          </Box>
        </Box>
      </CardContent>
    </Card>
  );

  if (loading) {
    return (
      <Box>
        <Typography variant="h4" gutterBottom>
          Dashboard
        </Typography>
        <LinearProgress />
      </Box>
    );
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        DDM Administration Dashboard
      </Typography>

      {error && (
        <Alert severity="error" sx={{ mb: 3 }}>
          {error}
        </Alert>
      )}

      {healthStatus && (
        <Alert severity="success" sx={{ mb: 3 }}>
          API Status: {healthStatus.status} - {healthStatus.service} v{healthStatus.version}
        </Alert>
      )}

      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="API Status"
            value={healthStatus ? "Online" : "Offline"}
            icon={<CheckIcon fontSize="large" />}
            color={healthStatus ? "success" : "error"}
          />
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Masking Rules"
            value="12"
            icon={<SecurityIcon fontSize="large" />}
            color="primary"
          />
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Protected Tables"
            value="5"
            icon={<TableIcon fontSize="large" />}
            color="info"
          />
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <StatCard
            title="Operations Today"
            value="47"
            icon={<AssessmentIcon fontSize="large" />}
            color="warning"
          />
        </Grid>

        <Grid item xs={12} md={8}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Available Masking Types
              </Typography>
              <Box display="flex" flexWrap="wrap" gap={1}>
                <Chip label="SSN Masking" color="primary" variant="outlined" />
                <Chip label="Credit Card" color="primary" variant="outlined" />
                <Chip label="Email" color="primary" variant="outlined" />
                <Chip label="Phone Number" color="primary" variant="outlined" />
                <Chip label="Generic" color="primary" variant="outlined" />
                <Chip label="Date Shifting" color="primary" variant="outlined" />
                <Chip label="Numeric Range" color="primary" variant="outlined" />
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Quick Actions
              </Typography>
              <Typography variant="body2" color="textSecondary">
                • Test single value masking
              </Typography>
              <Typography variant="body2" color="textSecondary">
                • Configure new rules
              </Typography>
              <Typography variant="body2" color="textSecondary">
                • View audit logs
              </Typography>
              <Typography variant="body2" color="textSecondary">
                • Export configurations
              </Typography>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                System Information
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2">
                    <strong>OpenEdge Version:</strong> 12.8
                  </Typography>
                  <Typography variant="body2">
                    <strong>PASOE Status:</strong> Running
                  </Typography>
                  <Typography variant="body2">
                    <strong>Database:</strong> sports2020
                  </Typography>
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Typography variant="body2">
                    <strong>Last Configuration Update:</strong> {new Date().toLocaleString()}
                  </Typography>
                  <Typography variant="body2">
                    <strong>Active Sessions:</strong> 3
                  </Typography>
                  <Typography variant="body2">
                    <strong>Memory Usage:</strong> 45%
                  </Typography>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

export default Dashboard;
