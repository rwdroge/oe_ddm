'use client'

import { useEffect, useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { DDMApiService } from '@/services/api'
import type { HealthResponse } from '@/types/api'
import {
  ShieldCheckIcon,
  EyeSlashIcon,
  TagIcon,
  UserGroupIcon,
  ChartBarIcon,
  ExclamationTriangleIcon,
} from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

export default function Dashboard() {
  const [health, setHealth] = useState<HealthResponse | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    checkHealth()
  }, [])

  const checkHealth = async () => {
    try {
      setLoading(true)
      const healthData = await DDMApiService.getHealth()
      setHealth(healthData)
      toast.success('System health check completed')
    } catch (error) {
      console.error('Health check failed:', error)
      toast.error('Failed to check system health')
    } finally {
      setLoading(false)
    }
  }

  const stats = [
    {
      name: 'User Management',
      description: 'Create and manage users for DDM',
      icon: UserGroupIcon,
      href: '/user-management',
      color: 'bg-indigo-500',
    },
    {
      name: 'Role Management',
      description: 'Create roles and grant them to users',
      icon: UserGroupIcon,
      href: '/role-management',
      color: 'bg-purple-500',
    },
    {
      name: 'Authorization Tags',
      description: 'Associate authorization tags with roles',
      icon: TagIcon,
      href: '/authorization-tags',
      color: 'bg-green-500',
    },
    {
      name: 'Field Masking',
      description: 'Configure data masking for database fields',
      icon: EyeSlashIcon,
      href: '/field-masking',
      color: 'bg-blue-500',
    },
    {
      name: 'Data Viewer',
      description: 'Preview mask/auth tag per field by user',
      icon: EyeSlashIcon,
      href: '/data-viewer',
      color: 'bg-teal-500',
    },
    {
      name: 'Monitoring',
      description: 'Monitor DDM operations and performance',
      icon: ChartBarIcon,
      href: '/monitoring',
      color: 'bg-orange-500',
    },
    {
      name: 'Audit Logs',
      description: 'Review audit log entries and activity',
      icon: ChartBarIcon,
      href: '/audit-logs',
      color: 'bg-slate-500',
    },
  ]

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="mt-2 text-gray-600">
          Overview of your Dynamic Data Masking system
        </p>
      </div>

      {/* System Health */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <ShieldCheckIcon className="h-6 w-6" />
            <span>System Health</span>
          </CardTitle>
          <CardDescription>
            Current status of the DDM service
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex items-center space-x-2">
              <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-primary-600"></div>
              <span>Checking system health...</span>
            </div>
          ) : health ? (
            <div className="space-y-4">
              <div className="flex items-center space-x-2">
                <div className="h-3 w-3 bg-green-500 rounded-full"></div>
                <span className="font-medium">Service: {health.service}</span>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                <div>
                  <span className="text-gray-500">Status:</span>
                  <span className="ml-2 font-medium capitalize">{health.status}</span>
                </div>
                <div>
                  <span className="text-gray-500">Version:</span>
                  <span className="ml-2 font-medium">{health.version}</span>
                </div>
                <div>
                  <span className="text-gray-500">Database:</span>
                  <span className="ml-2 font-medium">{health.database}</span>
                </div>
              </div>
              <Button onClick={checkHealth} variant="outline" size="sm">
                Refresh Status
              </Button>
            </div>
          ) : (
            <div className="flex items-center space-x-2 text-red-600">
              <ExclamationTriangleIcon className="h-5 w-5" />
              <span>Unable to connect to DDM service</span>
              <Button onClick={checkHealth} variant="outline" size="sm">
                Retry
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Quick Actions */}
      <div>
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Quick Actions</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((item) => (
            <Card key={item.name} className="hover:shadow-md transition-shadow cursor-pointer">
              <CardHeader className="pb-3">
                <div className="flex items-center space-x-3">
                  <div className={`p-2 rounded-lg ${item.color}`}>
                    <item.icon className="h-6 w-6 text-white" />
                  </div>
                  <div>
                    <CardTitle className="text-lg">{item.name}</CardTitle>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <CardDescription className="mb-4">
                  {item.description}
                </CardDescription>
                <Button 
                  variant="outline" 
                  size="sm" 
                  className="w-full"
                  onClick={() => window.location.href = item.href}
                >
                  Open
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Recent Activity */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Activity</CardTitle>
          <CardDescription>
            Latest DDM operations and changes
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="text-center py-8 text-gray-500">
            <ChartBarIcon className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p>No recent activity to display</p>
            <p className="text-sm">DDM operations will appear here</p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
