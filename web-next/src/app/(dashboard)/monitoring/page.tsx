'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { DDMApiService } from '@/services/api'
import type { AuthTagRoleResponse, UserRoleGrantsResponse } from '@/types/api'
import { ChartBarIcon, MagnifyingGlassIcon, TagIcon, UserGroupIcon } from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

const authTagRoleSchema = z.object({
  domainName: z.string().min(1, 'Domain name is required'),
  authTagName: z.string().min(1, 'Authorization tag name is required'),
})

const userRoleGrantsSchema = z.object({
  userName: z.string().min(1, 'User name is required'),
})

type AuthTagRoleForm = z.infer<typeof authTagRoleSchema>
type UserRoleGrantsForm = z.infer<typeof userRoleGrantsSchema>

export default function Monitoring() {
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'auth-tag' | 'user-roles'>('auth-tag')
  const [authTagResult, setAuthTagResult] = useState<AuthTagRoleResponse | null>(null)
  const [userRolesResult, setUserRolesResult] = useState<UserRoleGrantsResponse | null>(null)

  const authTagForm = useForm<AuthTagRoleForm>({
    resolver: zodResolver(authTagRoleSchema),
  })

  const userRolesForm = useForm<UserRoleGrantsForm>({
    resolver: zodResolver(userRoleGrantsSchema),
  })

  const onAuthTagSubmit = async (data: AuthTagRoleForm) => {
    try {
      setLoading(true)
      const response = await DDMApiService.getAuthTagRole(data.domainName, data.authTagName)
      
      if (response.success) {
        setAuthTagResult(response)
        toast.success(`Authorization tag information retrieved for ${data.authTagName}`)
      } else {
        toast.error('Failed to retrieve authorization tag information')
        setAuthTagResult(null)
      }
    } catch (error) {
      console.error('Auth tag query error:', error)
      toast.error('Failed to retrieve authorization tag information')
      setAuthTagResult(null)
    } finally {
      setLoading(false)
    }
  }

  const onUserRolesSubmit = async (data: UserRoleGrantsForm) => {
    try {
      setLoading(true)
      const response = await DDMApiService.getUserRoleGrants(data.userName)
      
      if (response.success) {
        setUserRolesResult(response)
        toast.success(`Role grants retrieved for user ${data.userName}`)
      } else {
        toast.error('Failed to retrieve user role grants')
        setUserRolesResult(null)
      }
    } catch (error) {
      console.error('User roles query error:', error)
      toast.error('Failed to retrieve user role grants')
      setUserRolesResult(null)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 flex items-center space-x-3">
          <ChartBarIcon className="h-8 w-8" />
          <span>Information Monitoring</span>
        </h1>
        <p className="mt-2 text-gray-600">
          Monitor and retrieve information about DDM configurations, authorization tags, and user permissions
        </p>
      </div>

      {/* Tab Navigation */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => setActiveTab('auth-tag')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'auth-tag'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Authorization Tag & Role
          </button>
          <button
            onClick={() => setActiveTab('user-roles')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'user-roles'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            User Role Grants
          </button>
        </nav>
      </div>

      {/* Authorization Tag & Role Tab */}
      {activeTab === 'auth-tag' && (
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <TagIcon className="h-5 w-5" />
                <span>Authorization Tag & Role Information</span>
              </CardTitle>
              <CardDescription>
                Retrieve authorization tag and its associated role information
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={authTagForm.handleSubmit(onAuthTagSubmit)} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Domain Name
                    </label>
                    <Input
                      {...authTagForm.register('domainName')}
                      placeholder="e.g., TestDomain"
                      className={authTagForm.formState.errors.domainName ? 'border-red-500' : ''}
                    />
                    {authTagForm.formState.errors.domainName && (
                      <p className="mt-1 text-sm text-red-600">
                        {authTagForm.formState.errors.domainName.message}
                      </p>
                    )}
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Authorization Tag Name
                    </label>
                    <Input
                      {...authTagForm.register('authTagName')}
                      placeholder="e.g., CONFIDENTIAL"
                      className={authTagForm.formState.errors.authTagName ? 'border-red-500' : ''}
                    />
                    {authTagForm.formState.errors.authTagName && (
                      <p className="mt-1 text-sm text-red-600">
                        {authTagForm.formState.errors.authTagName.message}
                      </p>
                    )}
                  </div>
                </div>

                <div className="flex justify-end">
                  <Button type="submit" disabled={loading}>
                    {loading ? 'Retrieving...' : 'Get Authorization Tag Info'}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>

          {/* Authorization Tag Results */}
          {authTagResult && (
            <Card>
              <CardHeader>
                <CardTitle>Authorization Tag Details</CardTitle>
                <CardDescription>
                  Information for {authTagResult.authTagName} in domain {authTagResult.domainName}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <span className="text-sm font-medium text-gray-500">Domain:</span>
                      <p className="text-sm text-gray-900">{authTagResult.domainName}</p>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-500">Authorization Tag:</span>
                      <p className="text-sm text-gray-900">{authTagResult.authTagName}</p>
                    </div>
                  </div>
                  
                  <div>
                    <span className="text-sm font-medium text-gray-500">Role Information:</span>
                    <div className="mt-2 bg-gray-50 rounded-lg p-4">
                      <pre className="text-sm text-gray-700 whitespace-pre-wrap font-mono">
                        {authTagResult.result}
                      </pre>
                    </div>
                  </div>
                  
                  <div className="flex items-center space-x-2 text-sm">
                    <div className={`h-3 w-3 rounded-full ${authTagResult.success ? 'bg-green-500' : 'bg-red-500'}`}></div>
                    <span className={authTagResult.success ? 'text-green-700' : 'text-red-700'}>
                      {authTagResult.success ? 'Query successful' : 'Query failed'}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      )}

      {/* User Role Grants Tab */}
      {activeTab === 'user-roles' && (
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <UserGroupIcon className="h-5 w-5" />
                <span>User Role Grants</span>
              </CardTitle>
              <CardDescription>
                Retrieve all role grants for a specific user
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={userRolesForm.handleSubmit(onUserRolesSubmit)} className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    User Name
                  </label>
                  <Input
                    {...userRolesForm.register('userName')}
                    placeholder="e.g., testuser, john.doe"
                    className={userRolesForm.formState.errors.userName ? 'border-red-500' : ''}
                  />
                  {userRolesForm.formState.errors.userName && (
                    <p className="mt-1 text-sm text-red-600">
                      {userRolesForm.formState.errors.userName.message}
                    </p>
                  )}
                </div>

                <div className="flex justify-end">
                  <Button type="submit" disabled={loading}>
                    {loading ? 'Retrieving...' : 'Get User Role Grants'}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>

          {/* User Roles Results */}
          {userRolesResult && (
            <Card>
              <CardHeader>
                <CardTitle>User Role Grants</CardTitle>
                <CardDescription>
                  Role assignments for user {userRolesResult.userName}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div>
                    <span className="text-sm font-medium text-gray-500">User:</span>
                    <p className="text-sm text-gray-900">{userRolesResult.userName}</p>
                  </div>
                  
                  <div>
                    <span className="text-sm font-medium text-gray-500">Role Grants:</span>
                    <div className="mt-2 bg-gray-50 rounded-lg p-4">
                      <pre className="text-sm text-gray-700 whitespace-pre-wrap font-mono">
                        {userRolesResult.result}
                      </pre>
                    </div>
                  </div>
                  
                  <div className="flex items-center space-x-2 text-sm">
                    <div className={`h-3 w-3 rounded-full ${userRolesResult.success ? 'bg-green-500' : 'bg-red-500'}`}></div>
                    <span className={userRolesResult.success ? 'text-green-700' : 'text-red-700'}>
                      {userRolesResult.success ? 'Query successful' : 'Query failed'}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      )}

      {/* System Overview Card */}
      <Card>
        <CardHeader>
          <CardTitle>System Overview</CardTitle>
          <CardDescription>
            Current DDM system status and statistics
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="text-center p-4 bg-blue-50 rounded-lg">
              <div className="text-2xl font-bold text-blue-600">-</div>
              <div className="text-sm text-blue-800">Active Configurations</div>
              <div className="text-xs text-blue-600 mt-1">Field masking rules</div>
            </div>
            <div className="text-center p-4 bg-green-50 rounded-lg">
              <div className="text-2xl font-bold text-green-600">-</div>
              <div className="text-sm text-green-800">Authorization Tags</div>
              <div className="text-xs text-green-600 mt-1">Access control tags</div>
            </div>
            <div className="text-center p-4 bg-purple-50 rounded-lg">
              <div className="text-2xl font-bold text-purple-600">-</div>
              <div className="text-sm text-purple-800">Active Users</div>
              <div className="text-xs text-purple-600 mt-1">With role assignments</div>
            </div>
          </div>
          <div className="mt-6 text-center text-sm text-gray-500">
            <p>Real-time statistics are not available in the current API version.</p>
            <p>Use the query functions above to retrieve specific information.</p>
          </div>
        </CardContent>
      </Card>

      {/* Information Card */}
      <Card>
        <CardHeader>
          <CardTitle>Monitoring Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4 text-sm text-gray-600">
            <div>
              <h4 className="font-medium text-gray-900">Authorization Tag & Role Query:</h4>
              <p className="mt-2">
                This query retrieves information about an authorization tag and shows which roles 
                are associated with it. This helps you understand the access control hierarchy 
                and which users can access data protected by specific tags.
              </p>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">User Role Grants Query:</h4>
              <p className="mt-2">
                This query shows all role grants for a specific user, including grant IDs that 
                can be used to revoke specific role assignments. The information includes role 
                names, grant timestamps, and other relevant details.
              </p>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Monitoring Best Practices:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li>Regularly audit user role assignments</li>
                <li>Monitor authorization tag usage and effectiveness</li>
                <li>Review access patterns for anomalies</li>
                <li>Document role and tag relationships</li>
                <li>Maintain an inventory of active configurations</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
