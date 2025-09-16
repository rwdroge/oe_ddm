'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { DDMApiService } from '@/services/api'
import type { CreateUserRequest, UserRequest, UserRoleGrantsResponse } from '@/types/api'
import { UserIcon, PlusIcon, TrashIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

const createUserSchema = z.object({
  userName: z.string().min(1, 'User name is required'),
  password: z.string().min(6, 'Password must be at least 6 characters'),
})

const deleteUserSchema = z.object({
  userName: z.string().min(1, 'User name is required'),
})

const queryUserSchema = z.object({
  userName: z.string().min(1, 'User name is required'),
})

type CreateUserForm = z.infer<typeof createUserSchema>
type DeleteUserForm = z.infer<typeof deleteUserSchema>
type QueryUserForm = z.infer<typeof queryUserSchema>

export default function UserManagement() {
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'create' | 'delete' | 'query'>('create')
  const [userGrants, setUserGrants] = useState<UserRoleGrantsResponse | null>(null)

  const createForm = useForm<CreateUserForm>({
    resolver: zodResolver(createUserSchema),
  })

  const deleteForm = useForm<DeleteUserForm>({
    resolver: zodResolver(deleteUserSchema),
  })

  const queryForm = useForm<QueryUserForm>({
    resolver: zodResolver(queryUserSchema),
  })

  const onCreateSubmit = async (data: CreateUserForm) => {
    try {
      setLoading(true)
      const request: CreateUserRequest = {
        userName: data.userName,
        password: data.password,
      }
      
      const response = await DDMApiService.createUser(request)
      
      if (response.success) {
        toast.success(`User "${data.userName}" created successfully`)
        createForm.reset()
      } else {
        toast.error(response.message || 'Failed to create user')
      }
    } catch (error) {
      console.error('Create user error:', error)
      toast.error('Failed to create user')
    } finally {
      setLoading(false)
    }
  }

  const onDeleteSubmit = async (data: DeleteUserForm) => {
    try {
      setLoading(true)
      const request: UserRequest = {
        userName: data.userName,
      }
      
      const response = await DDMApiService.deleteUser(request)
      
      if (response.success) {
        toast.success(`User "${data.userName}" deleted successfully`)
        deleteForm.reset()
      } else {
        toast.error(response.message || 'Failed to delete user')
      }
    } catch (error) {
      console.error('Delete user error:', error)
      toast.error('Failed to delete user')
    } finally {
      setLoading(false)
    }
  }

  const onQuerySubmit = async (data: QueryUserForm) => {
    try {
      setLoading(true)
      const response = await DDMApiService.getUserRoleGrants(data.userName)
      
      if (response.success) {
        setUserGrants(response)
        toast.success(`Role grants retrieved for user "${data.userName}"`)
      } else {
        toast.error('Failed to retrieve user role grants')
        setUserGrants(null)
      }
    } catch (error) {
      console.error('Query user error:', error)
      toast.error('Failed to retrieve user role grants')
      setUserGrants(null)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 flex items-center space-x-3">
          <UserIcon className="h-8 w-8" />
          <span>User Management</span>
        </h1>
        <p className="mt-2 text-gray-600">
          Create, manage, and monitor users in the DDM system
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
            Create User
          </button>
          <button
            onClick={() => setActiveTab('delete')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'delete'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Delete User
          </button>
          <button
            onClick={() => setActiveTab('query')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'query'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Query User Roles
          </button>
        </nav>
      </div>

      {/* Create User Tab */}
      {activeTab === 'create' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <PlusIcon className="h-5 w-5" />
              <span>Create New User</span>
            </CardTitle>
            <CardDescription>
              Create a new user account with username and password
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={createForm.handleSubmit(onCreateSubmit)} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    User Name
                  </label>
                  <Input
                    {...createForm.register('userName')}
                    placeholder="e.g., john.doe, testuser"
                    className={createForm.formState.errors.userName ? 'border-red-500' : ''}
                  />
                  {createForm.formState.errors.userName && (
                    <p className="mt-1 text-sm text-red-600">
                      {createForm.formState.errors.userName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Password
                  </label>
                  <Input
                    type="password"
                    {...createForm.register('password')}
                    placeholder="Enter secure password"
                    className={createForm.formState.errors.password ? 'border-red-500' : ''}
                  />
                  {createForm.formState.errors.password && (
                    <p className="mt-1 text-sm text-red-600">
                      {createForm.formState.errors.password.message}
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
                      Security Note
                    </h3>
                    <div className="mt-2 text-sm text-blue-700">
                      <p>
                        New users will have no roles assigned by default. You'll need to grant 
                        appropriate roles in the Role Management section to give them access to data.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" disabled={loading}>
                  {loading ? 'Creating...' : 'Create User'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Delete User Tab */}
      {activeTab === 'delete' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrashIcon className="h-5 w-5" />
              <span>Delete User</span>
            </CardTitle>
            <CardDescription>
              Remove an existing user account from the system
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={deleteForm.handleSubmit(onDeleteSubmit)} className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  User Name
                </label>
                <Input
                  {...deleteForm.register('userName')}
                  placeholder="e.g., john.doe"
                  className={deleteForm.formState.errors.userName ? 'border-red-500' : ''}
                />
                {deleteForm.formState.errors.userName && (
                  <p className="mt-1 text-sm text-red-600">
                    {deleteForm.formState.errors.userName.message}
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
                      Danger Zone
                    </h3>
                    <div className="mt-2 text-sm text-red-700">
                      <p>
                        This action will permanently delete the user account and all associated 
                        role grants. This cannot be undone. Make sure you have the correct username.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" variant="destructive" disabled={loading}>
                  {loading ? 'Deleting...' : 'Delete User'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Query User Roles Tab */}
      {activeTab === 'query' && (
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <MagnifyingGlassIcon className="h-5 w-5" />
                <span>Query User Role Grants</span>
              </CardTitle>
              <CardDescription>
                Retrieve all role grants for a specific user
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={queryForm.handleSubmit(onQuerySubmit)} className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    User Name
                  </label>
                  <Input
                    {...queryForm.register('userName')}
                    placeholder="e.g., john.doe"
                    className={queryForm.formState.errors.userName ? 'border-red-500' : ''}
                  />
                  {queryForm.formState.errors.userName && (
                    <p className="mt-1 text-sm text-red-600">
                      {queryForm.formState.errors.userName.message}
                    </p>
                  )}
                </div>

                <div className="flex justify-end">
                  <Button type="submit" disabled={loading}>
                    {loading ? 'Querying...' : 'Query Role Grants'}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>

          {/* Results */}
          {userGrants && (
            <Card>
              <CardHeader>
                <CardTitle>Role Grants for {userGrants.userName}</CardTitle>
                <CardDescription>
                  Current role assignments and permissions
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="bg-gray-50 rounded-lg p-4">
                    <h4 className="font-medium text-gray-900 mb-2">Grant Information:</h4>
                    <pre className="text-sm text-gray-700 whitespace-pre-wrap font-mono bg-white p-3 rounded border">
                      {userGrants.result}
                    </pre>
                  </div>
                  
                  <div className="flex items-center space-x-2 text-sm">
                    <div className={`h-3 w-3 rounded-full ${userGrants.success ? 'bg-green-500' : 'bg-red-500'}`}></div>
                    <span className={userGrants.success ? 'text-green-700' : 'text-red-700'}>
                      {userGrants.success ? 'Query successful' : 'Query failed'}
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}
        </div>
      )}

      {/* Information Card */}
      <Card>
        <CardHeader>
          <CardTitle>User Management Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4 text-sm text-gray-600">
            <div>
              <h4 className="font-medium text-gray-900">User Account Lifecycle:</h4>
              <ol className="mt-2 space-y-1 list-decimal list-inside">
                <li>Create user account with username and password</li>
                <li>Grant appropriate roles for data access</li>
                <li>Monitor user activity and role usage</li>
                <li>Update roles as needed based on job requirements</li>
                <li>Remove user account when no longer needed</li>
              </ol>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Security Best Practices:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li>Use strong passwords (minimum 6 characters, preferably longer)</li>
                <li>Follow the principle of least privilege for role assignments</li>
                <li>Regularly audit user accounts and role grants</li>
                <li>Remove inactive or unnecessary user accounts promptly</li>
                <li>Monitor user access patterns for anomalies</li>
              </ul>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Role Grant Information:</h4>
              <p className="mt-2">
                The role grants query shows all roles currently assigned to a user, including 
                grant IDs that can be used to revoke specific role assignments in the Role Management section.
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
