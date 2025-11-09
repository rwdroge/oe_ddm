# DDM Admin UI - Next.js

A modern, responsive web interface for OpenEdge Dynamic Data Masking (DDM) administration built with Next.js 14, TypeScript, and Tailwind CSS.

## Features

- **Modern Tech Stack**: Next.js 14 with App Router, TypeScript, Tailwind CSS
- **Comprehensive DDM Management**: 
  - Field masking configuration
  - Authorization tag management
  - Role creation and assignment
  - User management
  - System monitoring
- **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- **Type Safety**: Full TypeScript implementation with API type definitions
- **Form Validation**: Client-side validation with Zod schemas
- **Real-time Feedback**: Toast notifications for user actions
- **Authentication**: HTTP Basic Auth integration with OpenEdge backend

## Pages and Functionality

### Dashboard
- System health monitoring
- Quick access to all DDM functions
- Service status overview

### Field Masking
- Configure field-level data masking
- Support for FULL, PARTIAL, and CONDITIONAL masking types
- Remove existing masking configurations

### Authorization Tags
- Create, update, and delete authorization tags
- Domain-based tag management
- Access control configuration

### Role Management
- Create and delete security roles
- Grant roles to users
- Revoke role assignments

### User Management
- Create new user accounts
- Delete existing users
- Query user role grants

### Configuration
- Low-level DDM configuration management
- Query existing configurations
- Direct mask and authorization tag setup

### Monitoring
- Authorization tag and role information retrieval
- User role grant monitoring
- System overview and statistics

### Audit Logs
- Placeholder for audit logging functionality
- Framework for future audit trail implementation

## Prerequisites

- Node.js 18.0.0 or higher
- npm or yarn package manager
- OpenEdge DDM API server running on `localhost:8080`

## Installation

1. Navigate to the project directory:
```bash
cd /workspaces/oe_ddm/web-next
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

4. Open your browser and navigate to `http://localhost:3000`

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run type-check` - Run TypeScript type checking

## Configuration

### API Configuration
The application is configured to proxy API requests to the OpenEdge server. Update `next.config.js` if your API server runs on a different host/port:

```javascript
async rewrites() {
  return [
    {
      source: '/api/masking/:path*',
      destination: 'http://your-server:port/api/masking/:path*',
    },
  ]
}
```

### Environment Variables
Create a `.env.local` file for environment-specific configuration:

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080
```

## Authentication

The application uses HTTP Basic Authentication. Users must provide valid credentials that are authenticated against the OpenEdge server. Credentials are stored in localStorage for the session duration.

## Project Structure

```
src/
├── app/                    # Next.js App Router pages
│   ├── (dashboard)/       # Dashboard layout group
│   │   ├── page.tsx       # Dashboard home
│   │   ├── field-masking/ # Field masking management
│   │   ├── authorization-tags/ # Auth tag management
│   │   ├── role-management/ # Role management
│   │   ├── user-management/ # User management
│   │   ├── configuration/ # DDM configuration
│   │   ├── monitoring/    # System monitoring
│   │   └── audit-logs/    # Audit logs
│   ├── login/             # Login page
│   ├── layout.tsx         # Root layout
│   └── globals.css        # Global styles
├── components/            # Reusable components
│   ├── ui/               # Base UI components
│   └── layout/           # Layout components
├── lib/                  # Utility functions
├── services/             # API service layer
└── types/                # TypeScript type definitions
```

## API Integration

The application integrates with the OpenEdge DDM API through a comprehensive service layer (`src/services/api.ts`) that provides:

- Type-safe API calls
- Error handling and retry logic
- Authentication management
- Request/response interceptors

## Styling

The application uses Tailwind CSS for styling with a custom design system:

- **Primary Colors**: Blue tones for primary actions
- **Secondary Colors**: Pink/red tones for destructive actions
- **Component Library**: Custom UI components built on Tailwind
- **Responsive Design**: Mobile-first approach with breakpoint utilities

## Development

### Adding New Features

1. Create new page components in `src/app/(dashboard)/`
2. Add corresponding API methods in `src/services/api.ts`
3. Define TypeScript types in `src/types/api.ts`
4. Update navigation in `src/components/layout/Sidebar.tsx`

### Code Quality

- TypeScript strict mode enabled
- ESLint configuration for Next.js
- Consistent code formatting
- Form validation with Zod schemas

## Deployment

### Production Build

```bash
npm run build
npm run start
```

### Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000
CMD ["npm", "start"]
```

### Environment Configuration

For production deployment, ensure:

1. API server is accessible from the web server
2. CORS is properly configured on the OpenEdge server
3. Authentication credentials are properly managed
4. HTTPS is enabled for production use

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Contributing

1. Follow the existing code style and patterns
2. Add TypeScript types for new features
3. Include proper error handling
4. Test all functionality before submitting
5. Update documentation as needed

## License

This project is part of the OpenEdge DDM system. Please refer to your OpenEdge license agreement for usage terms.

## Support

For issues related to:
- **UI/Frontend**: Check browser console for errors, verify API connectivity
- **API Integration**: Ensure OpenEdge DDM service is running and accessible
- **Authentication**: Verify user credentials and server configuration

## Changelog

### Version 2.0.0
- Complete rewrite using Next.js 14
- Modern TypeScript implementation
- Responsive Tailwind CSS design
- Comprehensive DDM functionality
- Enhanced user experience and accessibility
