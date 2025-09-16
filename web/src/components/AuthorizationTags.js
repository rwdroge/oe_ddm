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
  Chip
} from '@mui/material';
import {
  Label as TagIcon,
  Add as AddIcon,
  Delete as DeleteIcon,
  Edit as EditIcon,
  Search as SearchIcon
} from '@mui/icons-material';
import { apiService } from '../services/apiService';

function TabPanel({ children, value, index, ...other }) {
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`auth-tabpanel-${index}`}
      aria-labelledby={`auth-tab-${index}`}
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

function AuthorizationTags() {
  const [tabValue, setTabValue] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState('');

  // Create Auth Tag State
  const [createTag, setCreateTag] = useState({
    domainName: '',
    authTagName: ''
  });

  // Update Auth Tag State
  const [updateTag, setUpdateTag] = useState({
    domainName: '',
    authTagName: '',
    newName: ''
  });

  // Delete Auth Tag State
  const [deleteTag, setDeleteTag] = useState({
    domainName: '',
    authTagName: ''
  });

  // Search State
  const [searchParams, setSearchParams] = useState({
    domainName: '',
    authTagName: ''
  });
  const [searchResults, setSearchResults] = useState(null);

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
    setError(null);
    setSuccess('');
  };

  const handleCreateAuthTag = async () => {
    if (!createTag.domainName || !createTag.authTagName) {
      setError('Domain name and authorization tag name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.createAuthTag(createTag);
      setSuccess('Authorization tag created successfully');
      
      // Reset form
      setCreateTag({
        domainName: '',
        authTagName: ''
      });
    } catch (err) {
      setError('Failed to create authorization tag: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateAuthTag = async () => {
    if (!updateTag.domainName || !updateTag.authTagName || !updateTag.newName) {
      setError('All fields are required for updating authorization tag');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.updateAuthTag(updateTag);
      setSuccess('Authorization tag updated successfully');
      
      // Reset form
      setUpdateTag({
        domainName: '',
        authTagName: '',
        newName: ''
      });
    } catch (err) {
      setError('Failed to update authorization tag: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteAuthTag = async () => {
    if (!deleteTag.domainName || !deleteTag.authTagName) {
      setError('Domain name and authorization tag name are required');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      await apiService.deleteAuthTag(deleteTag);
      setSuccess('Authorization tag deleted successfully');
      
      // Reset form
      setDeleteTag({
        domainName: '',
        authTagName: ''
      });
    } catch (err) {
      setError('Failed to delete authorization tag: ' + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  const handleSearchAuthTagRole = async () => {
    if (!searchParams.domainName || !searchParams.authTagName) {
      setError('Domain name and authorization tag name are required for search');
      return;
    }

    try {
      setLoading(true);
      setError(null);
      
      const response = await apiService.getAuthTagRole(searchParams);
      setSearchResults({
        type: 'authTagRole',
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
        <TagIcon sx={{ mr: 1, verticalAlign: 'middle' }} />
        Authorization Tag Management
      </Typography>
      <Typography variant="body1" color="textSecondary" paragraph>
        Create, update, delete, and manage authorization tags for DDM field access control.
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
          <Tabs value={tabValue} onChange={handleTabChange} aria-label="authorization tags tabs">
            <Tab label="Create Tag" />
            <Tab label="Update Tag" />
            <Tab label="Delete Tag" />
            <Tab label="Search & View" />
          </Tabs>
        </Box>

        {/* Create Auth Tag Tab */}
        <TabPanel value={tabValue} index={0}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Create Authorization Tag
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Create a new authorization tag in the specified domain for field access control.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Domain Name"
                    value={createTag.domainName}
                    onChange={(e) => setCreateTag({...createTag, domainName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., TestDomain"
                  />

                  <TextField
                    fullWidth
                    label="Authorization Tag Name"
                    value={createTag.authTagName}
                    onChange={(e) => setCreateTag({...createTag, authTagName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., CONFIDENTIAL"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleCreateAuthTag}
                    disabled={loading}
                    startIcon={<AddIcon />}
                    size="large"
                  >
                    Create Authorization Tag
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Common Authorization Tags
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Standard authorization tag examples:
                  </Typography>

                  <Box display="flex" flexWrap="wrap" gap={1} sx={{ mb: 2 }}>
                    <Chip label="PII" color="error" variant="outlined" />
                    <Chip label="FINANCIAL" color="warning" variant="outlined" />
                    <Chip label="CONFIDENTIAL" color="primary" variant="outlined" />
                    <Chip label="SENSITIVE" color="secondary" variant="outlined" />
                    <Chip label="PUBLIC" color="success" variant="outlined" />
                    <Chip label="INTERNAL" color="info" variant="outlined" />
                  </Box>

                  <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                    <Typography variant="subtitle2" gutterBottom>Tag Usage Guidelines:</Typography>
                    <Typography variant="body2" color="textSecondary">
                      • <strong>PII:</strong> Personally Identifiable Information<br/>
                      • <strong>FINANCIAL:</strong> Financial and payment data<br/>
                      • <strong>CONFIDENTIAL:</strong> Highly sensitive business data<br/>
                      • <strong>SENSITIVE:</strong> General sensitive information<br/>
                      • <strong>PUBLIC:</strong> Publicly available data<br/>
                      • <strong>INTERNAL:</strong> Internal company use only
                    </Typography>
                  </Paper>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* Update Auth Tag Tab */}
        <TabPanel value={tabValue} index={1}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={8}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Update Authorization Tag
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Update an existing authorization tag with a new name.
                  </Typography>

                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Domain Name"
                        value={updateTag.domainName}
                        onChange={(e) => setUpdateTag({...updateTag, domainName: e.target.value})}
                        placeholder="e.g., TestDomain"
                      />
                    </Grid>
                    <Grid item xs={12} sm={6}>
                      <TextField
                        fullWidth
                        label="Current Tag Name"
                        value={updateTag.authTagName}
                        onChange={(e) => setUpdateTag({...updateTag, authTagName: e.target.value})}
                        placeholder="e.g., CONFIDENTIAL"
                      />
                    </Grid>
                    <Grid item xs={12}>
                      <TextField
                        fullWidth
                        label="New Tag Name"
                        value={updateTag.newName}
                        onChange={(e) => setUpdateTag({...updateTag, newName: e.target.value})}
                        placeholder="e.g., TOP_SECRET"
                      />
                    </Grid>
                  </Grid>

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleUpdateAuthTag}
                    disabled={loading}
                    startIcon={<EditIcon />}
                    sx={{ mt: 3 }}
                    size="large"
                  >
                    Update Authorization Tag
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={4}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Update Guidelines
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Important considerations when updating authorization tags:
                  </Typography>

                  <Alert severity="warning" sx={{ mb: 2 }}>
                    Updating an authorization tag will affect all fields currently using this tag.
                  </Alert>

                  <Typography variant="body2" color="textSecondary">
                    • Verify the tag is not in active use<br/>
                    • Consider the impact on existing DDM rules<br/>
                    • Update related documentation<br/>
                    • Test access permissions after update
                  </Typography>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* Delete Auth Tag Tab */}
        <TabPanel value={tabValue} index={2}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Delete Authorization Tag
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Remove an authorization tag from the specified domain.
                  </Typography>

                  <Alert severity="error" sx={{ mb: 3 }}>
                    <strong>Warning:</strong> Deleting an authorization tag will remove access control for all fields using this tag.
                  </Alert>

                  <TextField
                    fullWidth
                    label="Domain Name"
                    value={deleteTag.domainName}
                    onChange={(e) => setDeleteTag({...deleteTag, domainName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., TestDomain"
                  />

                  <TextField
                    fullWidth
                    label="Authorization Tag Name"
                    value={deleteTag.authTagName}
                    onChange={(e) => setDeleteTag({...deleteTag, authTagName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., CONFIDENTIAL"
                  />

                  <Button
                    variant="contained"
                    color="error"
                    fullWidth
                    onClick={handleDeleteAuthTag}
                    disabled={loading}
                    startIcon={<DeleteIcon />}
                    size="large"
                  >
                    Delete Authorization Tag
                  </Button>
                </CardContent>
              </Card>
            </Grid>

            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Deletion Checklist
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Before deleting an authorization tag, ensure:
                  </Typography>

                  <Box component="ul" sx={{ pl: 2 }}>
                    <Typography component="li" variant="body2" color="textSecondary">
                      No active DDM rules are using this tag
                    </Typography>
                    <Typography component="li" variant="body2" color="textSecondary">
                      No user roles depend on this tag for access
                    </Typography>
                    <Typography component="li" variant="body2" color="textSecondary">
                      Backup configurations have been created
                    </Typography>
                    <Typography component="li" variant="body2" color="textSecondary">
                      Stakeholders have been notified
                    </Typography>
                    <Typography component="li" variant="body2" color="textSecondary">
                      Alternative access controls are in place
                    </Typography>
                  </Box>

                  <Alert severity="info" sx={{ mt: 2 }}>
                    Consider updating the tag instead of deleting it if you need to change its purpose.
                  </Alert>
                </CardContent>
              </Card>
            </Grid>
          </Grid>
        </TabPanel>

        {/* Search & View Tab */}
        <TabPanel value={tabValue} index={3}>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Card variant="outlined">
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    Search Authorization Tag & Role
                  </Typography>
                  <Typography variant="body2" color="textSecondary" paragraph>
                    Retrieve authorization tag and its associated role information.
                  </Typography>

                  <TextField
                    fullWidth
                    label="Domain Name"
                    value={searchParams.domainName}
                    onChange={(e) => setSearchParams({...searchParams, domainName: e.target.value})}
                    sx={{ mb: 2 }}
                    placeholder="e.g., TestDomain"
                  />

                  <TextField
                    fullWidth
                    label="Authorization Tag Name"
                    value={searchParams.authTagName}
                    onChange={(e) => setSearchParams({...searchParams, authTagName: e.target.value})}
                    sx={{ mb: 3 }}
                    placeholder="e.g., SENSITIVE"
                  />

                  <Button
                    variant="contained"
                    fullWidth
                    onClick={handleSearchAuthTagRole}
                    disabled={loading}
                    startIcon={<SearchIcon />}
                    size="large"
                  >
                    Search Tag & Role Info
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
                        Authorization Tag & Role Details:
                      </Typography>
                      <Typography variant="body2" sx={{ fontFamily: 'monospace', whiteSpace: 'pre-wrap' }}>
                        {JSON.stringify(searchResults.data, null, 2)}
                      </Typography>
                    </Paper>
                  ) : (
                    <Paper elevation={1} sx={{ p: 2, bgcolor: 'grey.50' }}>
                      <Typography variant="body2" color="textSecondary" align="center">
                        No search results yet. Use the search form to retrieve authorization tag and role information.
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

export default AuthorizationTags;
