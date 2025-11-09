'use client'

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { DocumentTextIcon, ClockIcon, UserIcon, CogIcon } from '@heroicons/react/24/outline'

export default function AuditLogs() {
  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 flex items-center space-x-3">
          <DocumentTextIcon className="h-8 w-8" />
          <span>Audit Logs</span>
        </h1>
        <p className="mt-2 text-gray-600">
          Monitor and review DDM operations and system activities
        </p>
      </div>

      {/* Audit Log Categories */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <CogIcon className="h-5 w-5 text-blue-600" />
              <span>Configuration Changes</span>
            </CardTitle>
            <CardDescription>
              Field masking and authorization tag modifications
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="text-center py-8 text-gray-500">
              <ClockIcon className="h-8 w-8 mx-auto mb-2 opacity-50" />
              <p className="text-sm">No recent configuration changes</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <UserIcon className="h-5 w-5 text-green-600" />
              <span>User Activities</span>
            </CardTitle>
            <CardDescription>
              User logins, role assignments, and access attempts
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="text-center py-8 text-gray-500">
              <ClockIcon className="h-8 w-8 mx-auto mb-2 opacity-50" />
              <p className="text-sm">No recent user activities</p>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <DocumentTextIcon className="h-5 w-5 text-purple-600" />
              <span>Data Access</span>
            </CardTitle>
            <CardDescription>
              Masked data access and authorization events
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="text-center py-8 text-gray-500">
              <ClockIcon className="h-8 w-8 mx-auto mb-2 opacity-50" />
              <p className="text-sm">No recent data access events</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Information Card */}
      <Card>
        <CardHeader>
          <CardTitle>Audit Logging Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4 text-sm text-gray-600">
            <div>
              <h4 className="font-medium text-gray-900">Audit Log Types:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li><strong>Configuration Changes:</strong> DDM rule modifications, tag updates</li>
                <li><strong>User Activities:</strong> Login attempts, role grants/revokes</li>
                <li><strong>Data Access:</strong> Masked data queries and authorization checks</li>
                <li><strong>System Events:</strong> Service starts/stops, health checks</li>
              </ul>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Implementation Note:</h4>
              <p className="mt-2">
                The current OpenEdge DDM API does not provide built-in audit logging endpoints. 
                To implement comprehensive audit logging, you would need to:
              </p>
              <ul className="mt-2 space-y-1 list-disc list-inside ml-4">
                <li>Add logging to the OpenEdge backend services</li>
                <li>Create audit log storage (database tables or log files)</li>
                <li>Implement audit log retrieval APIs</li>
                <li>Add real-time log monitoring capabilities</li>
              </ul>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Best Practices:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li>Log all configuration changes with timestamps and user details</li>
                <li>Monitor failed authentication attempts</li>
                <li>Track data access patterns for anomaly detection</li>
                <li>Implement log retention policies</li>
                <li>Ensure audit logs are tamper-proof</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
