import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { Box } from '@mui/material';
import Navigation from './components/Navigation';
import Dashboard from './components/Dashboard';
import MaskingTool from './components/MaskingTool';
import ConfigurationManager from './components/ConfigurationManager';
import AuditLogs from './components/AuditLogs';
import FieldMasking from './components/FieldMasking';
import AuthorizationTags from './components/AuthorizationTags';
import UserRoleManagement from './components/UserRoleManagement';
import InformationMonitoring from './components/InformationMonitoring';

const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Box sx={{ display: 'flex' }}>
          <Navigation />
          <Box component="main" sx={{ flexGrow: 1, p: 3, mt: 8 }}>
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/masking" element={<MaskingTool />} />
              <Route path="/configuration" element={<ConfigurationManager />} />
              <Route path="/logs" element={<AuditLogs />} />
              <Route path="/field-masking" element={<FieldMasking />} />
              <Route path="/authorization-tags" element={<AuthorizationTags />} />
              <Route path="/user-role-management" element={<UserRoleManagement />} />
              <Route path="/information-monitoring" element={<InformationMonitoring />} />
            </Routes>
          </Box>
        </Box>
      </Router>
    </ThemeProvider>
  );
}

export default App;
