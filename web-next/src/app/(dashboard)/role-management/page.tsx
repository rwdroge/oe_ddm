'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { DDMApiService } from '@/services/api'
import type { RoleRequest, GrantRoleRequest, DeleteGrantedRoleRequest } from '@/types/api'
import { UserGroupIcon, PlusIcon, UserPlusIcon, TrashIcon } from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

const createRoleSchema = z.object({
  roleName: z.string().min(1, 'Role name is required'),
})

const deleteRoleSchema = z.object({
  roleName: z.string().min(1, 'Role name is required'),
})

const grantRoleSchema = z.object({
  userName: z.string().min(1, 'User name is required'),
  roleName: z.string().min(1, 'Role name is required'),
})

const revokeRoleSchema = z.object({
  grantId: z.string().min(1, 'Grant ID is required'),
})

type CreateRoleForm = z.infer<typeof createRoleSchema>
type DeleteRoleForm = z.infer<typeof deleteRoleSchema>
type GrantRoleForm = z.infer<typeof grantRoleSchema>
type RevokeRoleForm = z.infer<typeof revokeRoleSchema>

export default function RoleManagement() {
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'create' | 'delete' | 'grant' | 'revoke'>('create')

  const createForm = useForm<CreateRoleForm>({
    resolver: zodResolver(createRoleSchema),
  })

  const deleteForm = useForm<DeleteRoleForm>({
    resolver: zodResolver(deleteRoleSchema),
  })

  const grantForm = useForm<GrantRoleForm>({
    resolver: zodResolver(grantRoleSchema),
  })

  const revokeForm = useForm<RevokeRoleForm>({
    resolver: zodResolver(revokeRoleSchema),
  })

  const onCreateSubmit = async (data: CreateRoleForm) => {
    try {
      setLoading(true)
      const request: RoleRequest = {
        roleName: data.roleName,
      }
      
      const response = await DDMApiService.createRole(request)
      
      if (response.success) {
        toast.success(`Role "${data.roleName}" created successfully`)
        createForm.reset()
      } else {
        toast.error(response.message || 'Failed to create role')
      }
    } catch (error) {
      console.error('Create role error:', error)
      toast.error('Failed to create role')
    } finally {
      setLoading(false)
    }
  }

  const onDeleteSubmit = async (data: DeleteRoleForm) => {
    try {
      setLoading(true)
      const request: RoleRequest = {
        roleName: data.roleName,
      }
      
      const response = await DDMApiService.deleteRole(request)
      
      if (response.success) {
        toast.success(`Role "${data.roleName}" deleted successfully`)
        deleteForm.reset()
      } else {
        toast.error(response.message || 'Failed to delete role')
      }
    } catch (error) {
      console.error('Delete role error:', error)
      toast.error('Failed to delete role')
    } finally {
      setLoading(false)
    }
  }

  const onGrantSubmit = async (data: GrantRoleForm) => {
    try {
      setLoading(true)
      const request: GrantRoleRequest = {
        userName: data.userName,
        roleName: data.roleName,
      }
      
      const response = await DDMApiService.grantRole(request)
      
      if (response.success) {
        toast.success(`Role "${data.roleName}" granted to user "${data.userName}"`)
        grantForm.reset()
      } else {
        toast.error(response.message || 'Failed to grant role')
      }
    } catch (error) {
      console.error('Grant role error:', error)
      toast.error('Failed to grant role')
    } finally {
      setLoading(false)
    }
  }

  const onRevokeSubmit = async (data: RevokeRoleForm) => {
    try {
      setLoading(true)
      const request: DeleteGrantedRoleRequest = {
        grantId: data.grantId,
      }
      
      const response = await DDMApiService.deleteGrantedRole(request)
      
      if (response.success) {
        toast.success(`Role grant revoked successfully`)
        revokeForm.reset()
      } else {
        toast.error(response.message || 'Failed to revoke role grant')
      }
    } catch (error) {
      console.error('Revoke role error:', error)
      toast.error('Failed to revoke role grant')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 flex items-center space-x-3">
          <UserGroupIcon className="h-8 w-8" />
          <span>Role Management</span>
        </h1>
        <p className="mt-2 text-gray-600">
          Create and manage security roles for controlling access to masked data
        </p>
      </div>

      {/* Tab Navigation */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => setActiveTab('create')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'create'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Create Role
          </button>
          <button
            onClick={() => setActiveTab('delete')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'delete'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Delete Role
          </button>
          <button
            onClick={() => setActiveTab('grant')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'grant'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Grant Role
          </button>
          <button
            onClick={() => setActiveTab('revoke')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'revoke'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Revoke Role
          </button>
        </nav>
      </div>

      {/* Create Role Tab */}
      {activeTab === 'create' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <PlusIcon className="h-5 w-5" />
              <span>Create Security Role</span>
            </CardTitle>
            <CardDescription>
              Create a new security role that can be granted to users
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={createForm.handleSubmit(onCreateSubmit)} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Role Name
                </label>
                <Input
                  {...createForm.register('roleName')}
                  placeholder="e.g., DataAnalyst, Administrator, Viewer"
                  className={createForm.formState.errors.roleName ? 'border-red-500' : ''}
                />
                {createForm.formState.errors.roleName && (
                  <p className="mt-1 text-sm text-red-600">
                    {createForm.formState.errors.roleName.message}
                  </p>
                )}
                <p className="mt-2 text-sm text-gray-500">
                  Choose a descriptive name that reflects the role's purpose and permissions
                </p>
              </div>

              <div className="flex justify-end">
                <Button type="submit" disabled={loading}>
                  {loading ? 'Creating...' : 'Create Role'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Delete Role Tab */}
      {activeTab === 'delete' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrashIcon className="h-5 w-5" />
              <span>Delete Security Role</span>
            </CardTitle>
            <CardDescription>
              Remove an existing security role from the system
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={deleteForm.handleSubmit(onDeleteSubmit)} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Role Name
                </label>
                <Input
                  {...deleteForm.register('roleName')}
                  placeholder="e.g., DataAnalyst"
                  className={deleteForm.formState.errors.roleName ? 'border-red-500' : ''}
                />
                {deleteForm.formState.errors.roleName && (
                  <p className="mt-1 text-sm text-red-600">
                    {deleteForm.formState.errors.roleName.message}
                  </p>
                )}
              </div>

              <div className="bg-red-50 border border-red-200 rounded-md p-4">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-red-800">
                      Warning
                    </h3>
                    <div className="mt-2 text-sm text-red-700">
                      <p>
                        Deleting a role will remove it permanently. Make sure no users are currently 
                        assigned this role, as it may affect their access to masked data.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" variant="destructive" disabled={loading}>
                  {loading ? 'Deleting...' : 'Delete Role'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Grant Role Tab */}
      {activeTab === 'grant' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <UserPlusIcon className="h-5 w-5" />
              <span>Grant Role to User</span>
            </CardTitle>
            <CardDescription>
              Assign a security role to a specific user
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={grantForm.handleSubmit(onGrantSubmit)} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    User Name
                  </label>
                  <Input
                    {...grantForm.register('userName')}
                    placeholder="e.g., testuser, john.doe"
                    className={grantForm.formState.errors.userName ? 'border-red-500' : ''}
                  />
                  {grantForm.formState.errors.userName && (
                    <p className="mt-1 text-sm text-red-600">
                      {grantForm.formState.errors.userName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Role Name
                  </label>
                  <Input
                    {...grantForm.register('roleName')}
                    placeholder="e.g., DataAnalyst"
                    className={grantForm.formState.errors.roleName ? 'border-red-500' : ''}
                  />
                  {grantForm.formState.errors.roleName && (
                    <p className="mt-1 text-sm text-red-600">
                      {grantForm.formState.errors.roleName.message}
                    </p>
                  )}
                </div>
              </div>

              <div className="bg-blue-50 border border-blue-200 rounded-md p-4">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-blue-800">
                      Information
                    </h3>
                    <div className="mt-2 text-sm text-blue-700">
                      <p>
                        Granting a role to a user will allow them to access data protected by 
                        authorization tags associated with that role.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" disabled={loading}>
                  {loading ? 'Granting...' : 'Grant Role'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Revoke Role Tab */}
      {activeTab === 'revoke' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrashIcon className="h-5 w-5" />
              <span>Revoke Role Grant</span>
            </CardTitle>
            <CardDescription>
              Remove a role grant using the grant ID
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={revokeForm.handleSubmit(onRevokeSubmit)} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Grant ID
                </label>
                <Input
                  {...revokeForm.register('grantId')}
                  placeholder="e.g., grant123, role_grant_456"
                  className={revokeForm.formState.errors.grantId ? 'border-red-500' : ''}
                />
                {revokeForm.formState.errors.grantId && (
                  <p className="mt-1 text-sm text-red-600">
                    {revokeForm.formState.errors.grantId.message}
                  </p>
                )}
                <p className="mt-2 text-sm text-gray-500">
                  You can find grant IDs by querying user role grants in the monitoring section
                </p>
              </div>

              <div className="bg-yellow-50 border border-yellow-200 rounded-md p-4">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="ml-3">
                    <h3 className="text-sm font-medium text-yellow-800">
                      Caution
                    </h3>
                    <div className="mt-2 text-sm text-yellow-700">
                      <p>
                        Revoking a role grant will immediately remove the user's access to data 
                        protected by that role's authorization tags.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" variant="destructive" disabled={loading}>
                  {loading ? 'Revoking...' : 'Revoke Role Grant'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Information Card */}
      <Card>
        <CardHeader>
          <CardTitle>Role Management Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4 text-sm text-gray-600">
            <div>
              <h4 className="font-medium text-gray-900">How Roles Work:</h4>
              <p className="mt-2">
                Roles are security containers that can be granted to users. When a user has a role, 
                they can access data protected by authorization tags associated with that role.
              </p>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Role Examples:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li><strong>DataAnalyst:</strong> Can access analytical data with PII masking</li>
                <li><strong>Administrator:</strong> Full access to all data and configurations</li>
                <li><strong>Viewer:</strong> Read-only access to masked data</li>
                <li><strong>FinanceTeam:</strong> Access to financial data and reports</li>
              </ul>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Best Practices:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li>Follow the principle of least privilege</li>
                <li>Use descriptive role names that reflect their purpose</li>
                <li>Regularly audit role assignments</li>
                <li>Document role permissions and responsibilities</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
