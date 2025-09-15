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

## Data Masking Configuration

### Basic Usage

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

### Configuration Files

Masking rules are defined in JSON configuration files in the `src/config/` directory:

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
