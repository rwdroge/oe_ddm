# OpenEdge Dynamic Data Masking (oe_ddm)

A comprehensive solution for masking sensitive data in OpenEdge databases to ensure privacy compliance and data protection.

## Overview

This project provides a complete data masking framework for OpenEdge ABL applications using:

- DevContainers for consistent development environments
- Visual Studio Code with AI assistant integrations
- Riverside OpenEdge ABL extension for ABL language support
- Progress Application Server (PAS) for OpenEdge for web services
- Dynamic data masking algorithms and patterns

## 🔒 Data Masking Features

- **Dynamic Masking**: Real-time data masking during query execution
- **Static Masking**: Batch processing for data warehouse scenarios
- **Format Preserving**: Maintains data format while masking content
- **Configurable Rules**: Flexible masking rules per field/table
- **Audit Trail**: Complete logging of masking operations
- **Performance Optimized**: Minimal impact on database performance

## Project Structure

```
oe_ddm/
├── .devcontainer/         # DevContainer configuration
├── .github/               # GitHub workflows and templates
├── .kilocode/             # Kilo Code AI assistant configuration
├── .vscode/               # VSCode configuration and settings
├── conf/                  # Configuration files for PAS
├── license/               # OpenEdge license files
│   └── placeholder_oe_cfg # Placeholder (replace with progress.cfg)
├── src/                   # Source code
│   ├── ddm/               # Data masking engine
│   ├── config/            # Configuration management
│   ├── utils/             # Utility classes
│   └── test/              # Unit tests
├── .gitignore             # Git ignore rules
├── README.md              # This file
└── openedge-project.json  # Project configuration
```

## ⚠️ Important License Notice

**Warning**: All container images used in this project contain OpenEdge 12.8 installations. By using these containers, you are subject to the Progress OpenEdge End User License Agreement (EULA). Please review the license terms at: https://www.progress.com/legal/license-agreements/openedge

## Prerequisites

### IDE and Container Runtime Requirements

**Visual Studio Code** - Must be installed to work with this devcontainer setup.

**AI Assistants (Optional)** - This project supports multiple AI coding assistants:
- GitHub Copilot (with OpenEdge MCP server integration)
- Kilo Code
- Codeium
- Other VSCode-compatible AI extensions

**Docker Desktop** - Required for this devcontainer setup to work properly. Docker and Docker Compose are minimum requirements.

### OpenEdge License Requirements

Before using this devcontainer, you must provide your own OpenEdge license file (`progress.cfg`). The license must include:

- **4GL Development System** - Required for ABL development and compilation
- **PASOE for Development** - Required for Progress Application Server for OpenEdge web services
- **Database License** - Any of the following:
  - Workgroup Database
  - Enterprise Database
  - Advanced Enterprise Database

### License Setup

1. Copy your valid `progress.cfg` license file to the `license/` folder
2. The file must be named exactly `progress.cfg` (case-sensitive)
3. Ensure the license includes all required components listed above

## Getting Started

### Step 1: Clone and Setup

```bash
git clone https://github.com/rwdroge/oe_ddm.git
cd oe_ddm
```

### Step 2: Configure License

Copy your `progress.cfg` file to the `license/` folder (replacing the placeholder file)

### Step 3: Open in VSCode

1. Open this project in Visual Studio Code
2. Install the "Dev Containers" extension if not already installed
3. Run command "Dev Containers: Reopen in Container" ([CTRL] + [SHIFT] + [P])
4. Wait for initialization

### Step 4: Install Extensions

The following extensions should be automatically installed:
- **OpenEdge ABL** by Riverside Software (required)
- **Dev Containers** by Microsoft (required)

**Optional AI Assistant Extensions**:
- **GitHub Copilot** - AI pair programmer with OpenEdge MCP integration
- **Kilo Code** - AI coding assistant
- **Codeium** - Free AI code completion

## 🚀 Quick Start Guide

### 1. ABL Examples

Run the provided examples to see DDM in action:

```bash
# Basic masking examples
cd /workspaces/oe_ddm
_progres -p src/examples/MaskingExample.p

# Advanced scenarios
_progres -p src/examples/AdvancedMaskingExample.p

# Database integration (requires sports2020 connection)
_progres -p src/examples/DatabaseMaskingExample.p -db sports2020 -S 10000 -H sports2020-db
```

### 2. REST API Setup

Start the PASOE server with DDM API:

```bash
# Start PASOE (adjust paths as needed)
$DLC/bin/tcman.sh start

# Test API health
curl http://localhost:8080/api/masking/health
```

### 3. Web UI Setup

Launch the React administration interface:

```bash
cd web
npm install
npm start
```

The web UI will be available at `http://localhost:3000`

## 📚 Examples and Usage

### ABL API Usage

```abl
/* Initialize the masking engine */
DEFINE VARIABLE oMaskingEngine AS DataMaskingEngine NO-UNDO.
oMaskingEngine = NEW DataMaskingEngine().

/* Configure masking rules */
oMaskingEngine:AddRule("Customer", "SSN", "SSN_MASK").
oMaskingEngine:AddRule("Customer", "CreditCard", "CREDIT_CARD_MASK").

/* Apply masking */
oMaskingEngine:MaskTable("Customer").
```

### REST API Usage

```bash
# Mask a single value
curl -X POST http://localhost:8080/api/masking/mask-value \
  -H "Content-Type: application/json" \
  -d '{"value": "123-45-6789", "maskType": "SSN_MASK"}'

# Add masking rule
curl -X POST http://localhost:8080/api/masking/add-rule \
  -H "Content-Type: application/json" \
  -d '{"tableName": "Customer", "fieldName": "SSN", "maskType": "SSN_MASK"}'
```

### Configuration Files

Masking rules are defined in JSON configuration files in the `conf/` directory:

```json
{
  "tables": {
    "Customer": {
      "fields": {
        "SSN": {
          "maskType": "SSN_MASK",
          "preserveFormat": true
        },
        "CreditCard": {
          "maskType": "CREDIT_CARD_MASK",
          "preserveFormat": true
        }
      }
    }
  }
}
```

## 🏗️ Architecture Overview

### Components

1. **ABL Core Engine** (`src/ddm/`)
   - `DataMaskingEngine.cls` - Main orchestration class
   - `MaskingConfig.cls` - Configuration management
   - `MaskingAlgorithms.cls` - Masking algorithms implementation

2. **REST API Layer** (`src/api/`)
   - `MaskingApiHandler.cls` - PASOE webhandler for REST endpoints
   - Configured in `conf/openedge.properties`

3. **Utilities** (`src/utils/`)
   - `MaskingLogger.cls` - Audit logging and compliance tracking

4. **Web UI** (`web/`)
   - React-based administration interface
   - Material-UI components for modern UX
   - Real-time API integration

5. **Examples** (`src/examples/`)
   - `MaskingExample.p` - Basic usage demonstrations
   - `AdvancedMaskingExample.p` - Complex scenarios and performance testing
   - `DatabaseMaskingExample.p` - Database integration examples

### Data Flow

```
Web UI ↔ REST API ↔ ABL Engine ↔ Database
   ↓         ↓         ↓
Audit Logs ← Logger ← Operations
```

## 🔧 Deployment Guide

### Production Deployment

1. **PASOE Configuration**
   ```bash
   # Create PASOE instance
   $DLC/bin/tcman.sh create -t oepas1 ddm-production
   
   # Configure properties
   cp conf/openedge.properties $CATALINA_BASE/conf/
   
   # Deploy ABL code
   cp -r src/* $CATALINA_BASE/webapps/ROOT/WEB-INF/openedge/
   ```

2. **Database Setup**
   ```bash
   # Create production database
   prodb create ddm-prod empty
   
   # Apply schema
   _progres -db ddm-prod -p setup/create-schema.p
   ```

3. **Web UI Deployment**
   ```bash
   cd web
   npm run build
   
   # Deploy to web server (nginx/apache)
   cp -r build/* /var/www/ddm-admin/
   ```

### Security Configuration

- Enable HTTPS for all communications
- Configure proper authentication in PASOE
- Set up database security and access controls
- Implement audit log retention policies
- Configure network security (firewalls, VPNs)

## 📊 Monitoring and Maintenance

### Health Checks
- API endpoint: `GET /api/masking/health`
- Database connectivity monitoring
- Performance metrics tracking

### Audit and Compliance
- All operations logged with timestamps
- User activity tracking
- Data access audit trails
- Configurable retention policies

## Development Features

- Full ABL language support with syntax highlighting and code completion
- Integrated debugging capabilities
- AI-powered code assistance with OpenEdge MCP server integration
- Access to OpenEdge database (sports2020 for testing)
- Automated testing framework
- Performance monitoring and optimization tools

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Security Notice

This tool is designed to help protect sensitive data. Always test masking rules thoroughly in a development environment before applying to production data.
