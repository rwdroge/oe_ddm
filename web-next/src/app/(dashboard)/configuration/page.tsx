'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { DDMApiService } from '@/services/api'
import type { DDMConfigRequest, FieldRequest } from '@/types/api'
import { CogIcon, PlusIcon, TrashIcon, MagnifyingGlassIcon } from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

const setConfigSchema = z.object({
  tableName: z.string().min(1, 'Table name is required'),
  fieldName: z.string().min(1, 'Field name is required'),
  maskValue: z.string().min(1, 'Mask value is required'),
  authTag: z.string().min(1, 'Authorization tag is required'),
})

const removeConfigSchema = z.object({
  tableName: z.string().min(1, 'Table name is required'),
  fieldName: z.string().min(1, 'Field name is required'),
})

const queryConfigSchema = z.object({
  tableName: z.string().min(1, 'Table name is required'),
  fieldName: z.string().min(1, 'Field name is required'),
  userName: z.string().optional(),
})

type SetConfigForm = z.infer<typeof setConfigSchema>
type RemoveConfigForm = z.infer<typeof removeConfigSchema>
type QueryConfigForm = z.infer<typeof queryConfigSchema>

export default function Configuration() {
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'set' | 'remove' | 'query'>('set')
  const [queryResult, setQueryResult] = useState<any>(null)

  const setForm = useForm<SetConfigForm>({
    resolver: zodResolver(setConfigSchema),
  })

  const removeForm = useForm<RemoveConfigForm>({
    resolver: zodResolver(removeConfigSchema),
  })

  const queryForm = useForm<QueryConfigForm>({
    resolver: zodResolver(queryConfigSchema),
  })

  const onSetSubmit = async (data: SetConfigForm) => {
    try {
      setLoading(true)
      const request: DDMConfigRequest = {
        tableName: data.tableName,
        fieldName: data.fieldName,
        maskValue: data.maskValue,
        authTag: data.authTag,
      }
      
      const response = await DDMApiService.setDDMConfig(request)
      
      if (response.success) {
        toast.success(`DDM configuration set for ${data.tableName}.${data.fieldName}`)
        setForm.reset()
      } else {
        toast.error(response.message || 'Failed to set DDM configuration')
      }
    } catch (error) {
      console.error('Set DDM config error:', error)
      toast.error('Failed to set DDM configuration')
    } finally {
      setLoading(false)
    }
  }

  const onRemoveSubmit = async (data: RemoveConfigForm) => {
    try {
      setLoading(true)
      const request: FieldRequest = {
        tableName: data.tableName,
        fieldName: data.fieldName,
      }
      
      const response = await DDMApiService.removeDDMConfig(request)
      
      if (response.success) {
        toast.success(`DDM configuration removed from ${data.tableName}.${data.fieldName}`)
        removeForm.reset()
      } else {
        toast.error(response.message || 'Failed to remove DDM configuration')
      }
    } catch (error) {
      console.error('Remove DDM config error:', error)
      toast.error('Failed to remove DDM configuration')
    } finally {
      setLoading(false)
    }
  }

  const onQuerySubmit = async (data: QueryConfigForm) => {
    try {
      setLoading(true)
      const response = await DDMApiService.getMaskAndAuthTag(
        data.tableName,
        data.fieldName,
        data.userName
      )
      
      if (response.success) {
        setQueryResult(response)
        toast.success(`Configuration retrieved for ${data.tableName}.${data.fieldName}`)
      } else {
        toast.error('Failed to retrieve configuration')
        setQueryResult(null)
      }
    } catch (error) {
      console.error('Query config error:', error)
      toast.error('Failed to retrieve configuration')
      setQueryResult(null)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 flex items-center space-x-3">
          <CogIcon className="h-8 w-8" />
          <span>DDM Configuration</span>
        </h1>
        <p className="mt-2 text-gray-600">
          Configure, manage, and query Dynamic Data Masking settings
        </p>
      </div>

      {/* Tab Navigation */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => setActiveTab('set')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'set'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Set Configuration
          </button>
          <button
            onClick={() => setActiveTab('remove')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'remove'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Remove Configuration
          </button>
          <button
            onClick={() => setActiveTab('query')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'query'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Query Configuration
          </button>
        </nav>
      </div>

      {/* Set Configuration Tab */}
      {activeTab === 'set' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <PlusIcon className="h-5 w-5" />
              <span>Set DDM Configuration</span>
            </CardTitle>
            <CardDescription>
              Configure DDM settings for a specific field with mask value and authorization tag
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={setForm.handleSubmit(onSetSubmit)} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Table Name
                  </label>
                  <Input
                    {...setForm.register('tableName')}
                    placeholder="e.g., Customer"
                    className={setForm.formState.errors.tableName ? 'border-red-500' : ''}
                  />
                  {setForm.formState.errors.tableName && (
                    <p className="mt-1 text-sm text-red-600">
                      {setForm.formState.errors.tableName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Field Name
                  </label>
                  <Input
                    {...setForm.register('fieldName')}
                    placeholder="e.g., CustNum"
                    className={setForm.formState.errors.fieldName ? 'border-red-500' : ''}
                  />
                  {setForm.formState.errors.fieldName && (
                    <p className="mt-1 text-sm text-red-600">
                      {setForm.formState.errors.fieldName.message}
                    </p>
                  )}
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Mask Value
                  </label>
                  <Input
                    {...setForm.register('maskValue')}
                    placeholder="e.g., ****, XXXX"
                    className={setForm.formState.errors.maskValue ? 'border-red-500' : ''}
                  />
                  {setForm.formState.errors.maskValue && (
                    <p className="mt-1 text-sm text-red-600">
                      {setForm.formState.errors.maskValue.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Authorization Tag
                  </label>
                  <Input
                    {...setForm.register('authTag')}
                    placeholder="e.g., SENSITIVE"
                    className={setForm.formState.errors.authTag ? 'border-red-500' : ''}
                  />
                  {setForm.formState.errors.authTag && (
                    <p className="mt-1 text-sm text-red-600">
                      {setForm.formState.errors.authTag.message}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" disabled={loading}>
                  {loading ? 'Setting...' : 'Set Configuration'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Remove Configuration Tab */}
      {activeTab === 'remove' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrashIcon className="h-5 w-5" />
              <span>Remove DDM Configuration</span>
            </CardTitle>
            <CardDescription>
              Remove DDM configuration from a specific field
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={removeForm.handleSubmit(onRemoveSubmit)} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Table Name
                  </label>
                  <Input
                    {...removeForm.register('tableName')}
                    placeholder="e.g., Customer"
                    className={removeForm.formState.errors.tableName ? 'border-red-500' : ''}
                  />
                  {removeForm.formState.errors.tableName && (
                    <p className="mt-1 text-sm text-red-600">
                      {removeForm.formState.errors.tableName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Field Name
                  </label>
                  <Input
                    {...removeForm.register('fieldName')}
                    placeholder="e.g., CustNum"
                    className={removeForm.formState.errors.fieldName ? 'border-red-500' : ''}
                  />
                  {removeForm.formState.errors.fieldName && (
                    <p className="mt-1 text-sm text-red-600">
                      {removeForm.formState.errors.fieldName.message}
                    </p>
                  )}
                </div>
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
                      Warning
                    </h3>
                    <div className="mt-2 text-sm text-yellow-700">
                      <p>
                        This will permanently remove the DDM configuration from the specified field.
                        The field will no longer be masked after this operation.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" variant="destructive" disabled={loading}>
                  {loading ? 'Removing...' : 'Remove Configuration'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Query Configuration Tab */}
      {activeTab === 'query' && (
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center space-x-2">
                <MagnifyingGlassIcon className="h-5 w-5" />
                <span>Query DDM Configuration</span>
              </CardTitle>
              <CardDescription>
                Retrieve mask and authorization tag information for a specific field
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={queryForm.handleSubmit(onQuerySubmit)} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Table Name
                    </label>
                    <Input
                      {...queryForm.register('tableName')}
                      placeholder="e.g., Customer"
                      className={queryForm.formState.errors.tableName ? 'border-red-500' : ''}
                    />
                    {queryForm.formState.errors.tableName && (
                      <p className="mt-1 text-sm text-red-600">
                        {queryForm.formState.errors.tableName.message}
                      </p>
                    )}
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Field Name
                    </label>
                    <Input
                      {...queryForm.register('fieldName')}
                      placeholder="e.g., CustNum"
                      className={queryForm.formState.errors.fieldName ? 'border-red-500' : ''}
                    />
                    {queryForm.formState.errors.fieldName && (
                      <p className="mt-1 text-sm text-red-600">
                        {queryForm.formState.errors.fieldName.message}
                      </p>
                    )}
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      User Name (Optional)
                    </label>
                    <Input
                      {...queryForm.register('userName')}
                      placeholder="e.g., testuser"
                    />
                  </div>
                </div>

                <div className="flex justify-end">
                  <Button type="submit" disabled={loading}>
                    {loading ? 'Querying...' : 'Query Configuration'}
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>

          {/* Query Results */}
          {queryResult && (
            <Card>
              <CardHeader>
                <CardTitle>Configuration Details</CardTitle>
                <CardDescription>
                  DDM configuration for {queryResult.tableName}.{queryResult.fieldName}
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <span className="text-sm font-medium text-gray-500">Table:</span>
                      <p className="text-sm text-gray-900">{queryResult.tableName}</p>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-500">Field:</span>
                      <p className="text-sm text-gray-900">{queryResult.fieldName}</p>
                    </div>
                    {queryResult.userName && (
                      <div>
                        <span className="text-sm font-medium text-gray-500">User:</span>
                        <p className="text-sm text-gray-900">{queryResult.userName}</p>
                      </div>
                    )}
                  </div>
                  
                  <div>
                    <span className="text-sm font-medium text-gray-500">Configuration Result:</span>
                    <div className="mt-2 bg-gray-50 rounded-lg p-4">
                      <pre className="text-sm text-gray-700 whitespace-pre-wrap font-mono">
                        {queryResult.result}
                      </pre>
                    </div>
                  </div>
                  
                  <div className="flex items-center space-x-2 text-sm">
                    <div className={`h-3 w-3 rounded-full ${queryResult.success ? 'bg-green-500' : 'bg-red-500'}`}></div>
                    <span className={queryResult.success ? 'text-green-700' : 'text-red-700'}>
                      {queryResult.success ? 'Query successful' : 'Query failed'}
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
          <CardTitle>DDM Configuration Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4 text-sm text-gray-600">
            <div>
              <h4 className="font-medium text-gray-900">Configuration Components:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li><strong>Table Name:</strong> The database table containing the field</li>
                <li><strong>Field Name:</strong> The specific field to be masked</li>
                <li><strong>Mask Value:</strong> The replacement value shown to unauthorized users</li>
                <li><strong>Authorization Tag:</strong> Controls who can see unmasked data</li>
              </ul>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Configuration vs Field Masking:</h4>
              <p className="mt-2">
                DDM Configuration provides low-level control over masking settings, while Field Masking 
                offers a higher-level interface with predefined masking types. Use DDM Configuration 
                for precise control over mask values and authorization tags.
              </p>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Query Information:</h4>
              <p className="mt-2">
                The query function retrieves current masking configuration and shows how the field 
                appears to different users based on their role assignments and authorization tags.
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
