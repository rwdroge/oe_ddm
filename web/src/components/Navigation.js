import React from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { 
  Tabs, 
  Tab, 
  Box 
} from '@mui/material';
import {
  Dashboard as DashboardIcon,
  Security as SecurityIcon,
  Settings as SettingsIcon,
  History as HistoryIcon,
  TableChart as TableIcon,
  VpnKey as VpnKeyIcon,
  People as PeopleIcon,
  Info as InfoIcon
} from '@mui/icons-material';

function Navigation() {
  const navigate = useNavigate();
  const location = useLocation();

  const handleChange = (event, newValue) => {
    navigate(newValue);
  };

  return (
    <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
      <Tabs 
        value={location.pathname} 
        onChange={handleChange}
        variant="scrollable"
        scrollButtons="auto"
        allowScrollButtonsMobile
      >
        <Tab 
          icon={<DashboardIcon />} 
          label="Dashboard" 
          value="/" 
        />
        <Tab 
          icon={<TableIcon />} 
          label="Field Masking" 
          value="/field-masking" 
        />
        <Tab 
          icon={<VpnKeyIcon />} 
          label="Auth Tags" 
          value="/authorization-tags" 
        />
        <Tab 
          icon={<PeopleIcon />} 
          label="Users & Roles" 
          value="/user-role-management" 
        />
        <Tab 
          icon={<InfoIcon />} 
          label="Information" 
          value="/information-monitoring" 
        />
        <Tab 
          icon={<SecurityIcon />} 
          label="Masking Tool" 
          value="/masking" 
        />
        <Tab 
          icon={<SettingsIcon />} 
          label="Configuration" 
          value="/configuration" 
        />
        <Tab 
          icon={<HistoryIcon />} 
          label="Audit Logs" 
          value="/logs" 
        />
      </Tabs>
    </Box>
  );
}

export default Navigation;
