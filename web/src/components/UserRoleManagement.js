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
  IconButton,
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions
} from '@mui/material';
import {
  People as PeopleIcon,
  PersonAdd as PersonAddIcon,
  Security as SecurityIcon,
  Delete as DeleteIcon,
  Add as AddIcon,
  Search as SearchIcon,
  Assignment as AssignmentIcon
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

function TabPanel({ children, value, index, ...other }) {
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`user-role-tabpanel-${index}`}
      aria-labelledby={`user-role-tab-${index}`}
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

function UserRoleManagement() {
  const [tabValue, setTabValue] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState('');

  // User Management State
  const [createUser, setCreateUser] = useState({
    userName: '',
    password: ''
  });

  const [deleteUser, setDeleteUser] = useState({
    userName: ''
  });

  // Role Management State
  const [createRole, setCreateRole] = useState({
    roleName: ''
  });

  const [deleteRole, setDeleteRole] = useState({
    roleName: ''
  });

  // Role Grant State
  const [grantRole, setGrantRole] = useState({
    userName: '',
    roleName: ''
  });

  const [deleteGrantedRole, setDeleteGrantedRole] = useState({
    grantId: ''
  });

  // Search State
  const [searchUser, setSearchUser] = useState({
    userName: ''
  });
  const [userRoleGrants, setUserRoleGrants] = useState(null);

  // Dialog State
  const [confirmDialog, setConfirmDialog] = useState({
    open: false,
    title: '',
    message: '',
    action: null
  });

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
    setError(null);
    setSuccess('');
  };

  // User Management Functions
  const handleCreateUser = async () => {
    if (!createUser.userName || !createUser.password) {
      setError('Username and password are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.createUser(createUser);
      setSuccess('User created successfully');
      
      setCreateUser({ userName: '', password: '' });
    } catch (err) {
      setError('Failed to create user: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteUser = async () => {
    if (!deleteUser.userName) {
      setError('Username is required');
      return;
    }

    setConfirmDialog({
      open: true,
      title: 'Confirm User Deletion',
      message: `Are you sure you want to delete user "${deleteUser.userName}"? This action cannot be undone.`,
      action: async () => {
        try {
          setLoading(true);
          setError(null);
          
          await apiService.deleteUser(deleteUser);
          setSuccess('User deleted successfully');
          
          setDeleteUser({ userName: '' });
        } catch (err) {
          setError('Failed to delete user: ' + (err.response?.data?.error || err.message));
        } finally {
          setLoading(false);
        }
      }
    });
  };

  // Role Management Functions
  const handleCreateRole = async () => {
    if (!createRole.roleName) {
      setError('Role name is required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.createRole(createRole);
      setSuccess('Role created successfully');
      
      setCreateRole({ roleName: '' });
    } catch (err) {
      setError('Failed to create role: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteRole = async () => {
    if (!deleteRole.roleName) {
      setError('Role name is required');
      return;
    }

    setConfirmDialog({
      open: true,
      title: 'Confirm Role Deletion',
      message: `Are you sure you want to delete role "${deleteRole.roleName}"? This will affect all users with this role.`,
      action: async () => {
        try {
          setLoading(true);
          setError(null);
          
          await apiService.deleteRole(deleteRole);
          setSuccess('Role deleted successfully');
          
          setDeleteRole({ roleName: '' });
        } catch (err) {
          setError('Failed to delete role: ' + (err.response?.data?.error || err.message));
        } finally {
          setLoading(false);
        }
      }
    });
  };

  // Role Grant Functions
  const handleGrantRole = async () => {
    if (!grantRole.userName || !grantRole.roleName) {
      setError('Username and role name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.grantRole(grantRole);
      setSuccess('Role granted successfully');
      
      setGrantRole({ userName: '', roleName: '' });
    } catch (err) {
      setError('Failed to grant role: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteGrantedRole = async () => {
    if (!deleteGrantedRole.grantId) {
      setError('Grant ID is required');
      return;
    }

    setConfirmDialog({
      open: true,
      title: 'Confirm Grant Removal',
      message: `Are you sure you want to remove this role grant (ID: ${deleteGrantedRole.grantId})?`,
      action: async () => {
        try {
          setLoading(true);
          setError(null);
          
          await apiService.deleteGrantedRole(deleteGrantedRole);
          setSuccess('Role grant removed successfully');
          
          setDeleteGrantedRole({ grantId: '' });
        } catch (err) {
          setError('Failed to remove role grant: ' + (err.response?.data?.error || err.message));
        } finally {
          setLoading(false);
        }
      }
    });
  };

  // Search Functions
  const handleSearchUserRoleGrants = async () => {
    if (!searchUser.userName) {
      setError('Username is required for search');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      const response = await apiService.getUserRoleGrants(searchUser);
      setUserRoleGrants(response.data);
      setSuccess('User role grants retrieved successfully');
    } catch (err) {
      setError('Search failed: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleConfirmDialogClose = () => {
    setConfirmDialog({ open: false, title: '', message: '', action: null });
  };

  const handleConfirmDialogConfirm = async () => {
    if (confirmDialog.action) {
      await confirmDialog.action();
    }
    handleConfirmDialogClose();
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        <PeopleIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
        User & Role Management
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        Manage users, security roles, and role assignments for DDM access control.
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
          <Tabs value={tabValue} onChange={handleTabChange} aria-label="user role management tabs">
            <Tab label="User Management" />
            <Tab label="Role Management" />
            <Tab label="Role Assignments" />
            <Tab label="View Grants" />
          </Tabs>
        </Box>

        {/* User Management Tab */}
        <TabPanel value={tabValue} index={0}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <PersonAddIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Create User
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Create a new user with username and password for DDM system access.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Username"
                    value={createUser.userName}
                    onChange={(e) => setCreateUser({...createUser, userName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., testuser"
                  />

                  <TextField
                    fullWidth
                    label="Password"
                    type="password"
                    value={createUser.password}
                    onChange={(e) => setCreateUser({...createUser, password: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="Enter secure password"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleCreateUser}
                    disabled={loading}
                    startIcon={<PersonAddIcon />}
                    size="large"
                  >
                    Create User
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <DeleteIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Delete User
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Remove an existing user from the DDM system.
                  </Typography>

                  <Alert severity="warning" sx={{ mb: 2 }}>
                    Deleting a user will remove all their role assignments and access permissions.
                  </Alert>

                  <TextField
                    fullWidth
                    label="Username"
                    value={deleteUser.userName}
                    onChange={(e) => setDeleteUser({...deleteUser, userName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., testuser"
                  />

                  <Button
                    variant="contained"
                    color="error"
                    fullWidth
                    onClick={handleDeleteUser}
                    disabled={loading}
                    startIcon={<DeleteIcon />}
                    size="large"
                  >
                    Delete User
                  </Button>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* Role Management Tab */}
        <TabPanel value={tabValue} index={1}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <SecurityIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Create Role
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Create a new security role for organizing user permissions.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Role Name"
                    value={createRole.roleName}
                    onChange={(e) => setCreateRole({...createRole, roleName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., DataAnalyst"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleCreateRole}
                    disabled={loading}
                    startIcon={<AddIcon />}
                    size="large"
                  >
                    Create Role
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <DeleteIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Delete Role
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Remove an existing security role from the system.
                  </Typography>

                  <Alert severity="error" sx={{ mb: 2 }}>
                    Deleting a role will affect all users currently assigned to this role.
                  </Alert>

                  <TextField
                    fullWidth
                    label="Role Name"
                    value={deleteRole.roleName}
                    onChange={(e) => setDeleteRole({...deleteRole, roleName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., DataAnalyst"
                  />

                  <Button
                    variant="contained"
                    color="error"
                    fullWidth
                    onClick={handleDeleteRole}
                    disabled={loading}
                    startIcon={<DeleteIcon />}
                    size="large"
                  >
                    Delete Role
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Common Role Examples
                  </Typography>
                  <Box display="flex" flexWrap="wrap" gap={1}>
                    <Chip label="DataAnalyst" color="primary" variant="outlined" />
                    <Chip label="DatabaseAdmin" color="secondary" variant="outlined" />
                    <Chip label="SecurityOfficer" color="error" variant="outlined" />
                    <Chip label="Developer" color="info" variant="outlined" />
                    <Chip label="ReadOnlyUser" color="success" variant="outlined" />
                    <Chip label="AuditUser" color="warning" variant="outlined" />
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* Role Assignments Tab */}
        <TabPanel value={tabValue} index={2}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <AssignmentIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Grant Role to User
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Assign a security role to a specific user for DDM access control.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Username"
                    value={grantRole.userName}
                    onChange={(e) => setGrantRole({...grantRole, userName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., testuser"
                  />

                  <TextField
                    fullWidth
                    label="Role Name"
                    value={grantRole.roleName}
                    onChange={(e) => setGrantRole({...grantRole, roleName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., DataAnalyst"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleGrantRole}
                    disabled={loading}
                    startIcon={<AssignmentIcon />}
                    size="large"
                  >
                    Grant Role
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <DeleteIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Remove Role Grant
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Remove a granted role using the grant ID.
                  </Typography>

                  <Alert severity="info" sx={{ mb: 2 }}>
                    Use the "View Grants" tab to find the grant ID for the role assignment you want to remove.
                  </Alert>

                  <TextField
                    fullWidth
                    label="Grant ID"
                    value={deleteGrantedRole.grantId}
                    onChange={(e) => setDeleteGrantedRole({...deleteGrantedRole, grantId: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., grant123"
                  />

                  <Button
                    variant="contained"
                    color="error"
                    fullWidth
                    onClick={handleDeleteGrantedRole}
                    disabled={loading}
                    startIcon={<DeleteIcon />}
                    size="large"
                  >
                    Remove Grant
                  </Button>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* View Grants Tab */}
        <TabPanel value={tabValue} index={3}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    <SearchIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
                    Search User Role Grants
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Retrieve all role grants for a specific user.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Username"
                    value={searchUser.userName}
                    onChange={(e) => setSearchUser({...searchUser, userName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., testuser"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleSearchUserRoleGrants}
                    disabled={loading}
                    startIcon={<SearchIcon />}
                    size="large"
                  >
                    Search Role Grants
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Role Grant Results
                  </Typography>

                  {userRoleGrants ? (
                    <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                      <Typography variant="subtitle2" gutterBottom>
                        User Role Grants:
                      </Typography>
                      <Typography variant="body2" sx={{ fontFamily: 'monospace', whiteSpace: 'pre-wrap' }}>
                        {JSON.stringify(userRoleGrants, null, 2)}
                      </Typography>
                    </Paper>
                  ) : (
                    <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                      <Typography variant="body2" color="textSecondary" align="center">
                        No search results yet. Use the search form to retrieve user role grant information.
                      </Typography>
                    </Paper>
                  )}
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>
      </Card>

      {/* Confirmation Dialog */}
      <Dialog
        open={confirmDialog.open}
        onClose={handleConfirmDialogClose}
        aria-labelledby="confirm-dialog-title"
      >
        <DialogTitle id="confirm-dialog-title">
          {confirmDialog.title}
        </DialogTitle>
        <DialogContent>
          <Typography>
            {confirmDialog.message}
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleConfirmDialogClose} color="primary">
            Cancel
          </Button>
          <Button onClick={handleConfirmDialogConfirm} color="error" variant="contained">
            Confirm
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default UserRoleManagement;
