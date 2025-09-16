'use client'

import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { DDMApiService } from '@/services/api'
import type { ConfigureFieldRequest, FieldRequest } from '@/types/api'
import { EyeSlashIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

const fieldMaskingSchema = z.object({
  tableName: z.string().min(1, 'Table name is required'),
  fieldName: z.string().min(1, 'Field name is required'),
  maskingType: z.enum(['FULL', 'PARTIAL', 'CONDITIONAL']),
  maskingValue: z.string().min(1, 'Masking value is required'),
  authTag: z.string().min(1, 'Authorization tag is required'),
})

const removeMaskSchema = z.object({
  tableName: z.string().min(1, 'Table name is required'),
  fieldName: z.string().min(1, 'Field name is required'),
})

type FieldMaskingForm = z.infer<typeof fieldMaskingSchema>
type RemoveMaskForm = z.infer<typeof removeMaskSchema>

export default function FieldMasking() {
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'configure' | 'remove'>('configure')

  const configureForm = useForm<FieldMaskingForm>({
    resolver: zodResolver(fieldMaskingSchema),
    defaultValues: {
      maskingType: 'PARTIAL',
    },
  })

  const removeForm = useForm<RemoveMaskForm>({
    resolver: zodResolver(removeMaskSchema),
  })

  const onConfigureSubmit = async (data: FieldMaskingForm) => {
    try {
      setLoading(true)
      const request: ConfigureFieldRequest = {
        tableName: data.tableName,
        fieldName: data.fieldName,
        maskingType: data.maskingType,
        maskingValue: data.maskingValue,
        authTag: data.authTag,
      }
      
      const response = await DDMApiService.configureField(request)
      
      if (response.success) {
        toast.success(`Field masking configured successfully for ${data.tableName}.${data.fieldName}`)
        configureForm.reset()
      } else {
        toast.error(response.message || 'Failed to configure field masking')
      }
    } catch (error) {
      console.error('Configure field error:', error)
      toast.error('Failed to configure field masking')
    } finally {
      setLoading(false)
    }
  }

  const onRemoveSubmit = async (data: RemoveMaskForm) => {
    try {
      setLoading(true)
      const request: FieldRequest = {
        tableName: data.tableName,
        fieldName: data.fieldName,
      }
      
      const response = await DDMApiService.unsetMask(request)
      
      if (response.success) {
        toast.success(`Mask removed successfully from ${data.tableName}.${data.fieldName}`)
        removeForm.reset()
      } else {
        toast.error(response.message || 'Failed to remove mask')
      }
    } catch (error) {
      console.error('Remove mask error:', error)
      toast.error('Failed to remove mask')
    } finally {
      setLoading(false)
    }
  }

  const maskingTypeOptions = [
    { value: 'FULL', label: 'Full Masking', description: 'Completely mask the field value' },
    { value: 'PARTIAL', label: 'Partial Masking', description: 'Partially mask the field value' },
    { value: 'CONDITIONAL', label: 'Conditional Masking', description: 'Mask based on conditions' },
  ]

  return (
    <div className="space-y-8">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 flex items-center space-x-3">
          <EyeSlashIcon className="h-8 w-8" />
          <span>Field Masking</span>
        </h1>
        <p className="mt-2 text-gray-600">
          Configure data masking for database fields to protect sensitive information
        </p>
      </div>

      {/* Tab Navigation */}
      <div className="border-b border-gray-200">
        <nav className="-mb-px flex space-x-8">
          <button
            onClick={() => setActiveTab('configure')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'configure'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Configure Masking
          </button>
          <button
            onClick={() => setActiveTab('remove')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'remove'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Remove Masking
          </button>
        </nav>
      </div>

      {/* Configure Masking Tab */}
      {activeTab === 'configure' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <PlusIcon className="h-5 w-5" />
              <span>Configure Field Masking</span>
            </CardTitle>
            <CardDescription>
              Set up data masking for a specific database field with authorization tags
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={configureForm.handleSubmit(onConfigureSubmit)} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Table Name
                  </label>
                  <Input
                    {...configureForm.register('tableName')}
                    placeholder="e.g., Customer"
                    className={configureForm.formState.errors.tableName ? 'border-red-500' : ''}
                  />
                  {configureForm.formState.errors.tableName && (
                    <p className="mt-1 text-sm text-red-600">
                      {configureForm.formState.errors.tableName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Field Name
                  </label>
                  <Input
                    {...configureForm.register('fieldName')}
                    placeholder="e.g., CustNum, Name"
                    className={configureForm.formState.errors.fieldName ? 'border-red-500' : ''}
                  />
                  {configureForm.formState.errors.fieldName && (
                    <p className="mt-1 text-sm text-red-600">
                      {configureForm.formState.errors.fieldName.message}
                    </p>
                  )}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Masking Type
                </label>
                <Select
                  {...configureForm.register('maskingType')}
                  className={configureForm.formState.errors.maskingType ? 'border-red-500' : ''}
                >
                  {maskingTypeOptions.map((option) => (
                    <option key={option.value} value={option.value}>
                      {option.label} - {option.description}
                    </option>
                  ))}
                </Select>
                {configureForm.formState.errors.maskingType && (
                  <p className="mt-1 text-sm text-red-600">
                    {configureForm.formState.errors.maskingType.message}
                  </p>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Masking Value
                  </label>
                  <Input
                    {...configureForm.register('maskingValue')}
                    placeholder="e.g., ****, XXXX, ###"
                    className={configureForm.formState.errors.maskingValue ? 'border-red-500' : ''}
                  />
                  {configureForm.formState.errors.maskingValue && (
                    <p className="mt-1 text-sm text-red-600">
                      {configureForm.formState.errors.maskingValue.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Authorization Tag
                  </label>
                  <Input
                    {...configureForm.register('authTag')}
                    placeholder="e.g., SENSITIVE, PII, CONFIDENTIAL"
                    className={configureForm.formState.errors.authTag ? 'border-red-500' : ''}
                  />
                  {configureForm.formState.errors.authTag && (
                    <p className="mt-1 text-sm text-red-600">
                      {configureForm.formState.errors.authTag.message}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" disabled={loading}>
                  {loading ? 'Configuring...' : 'Configure Masking'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Remove Masking Tab */}
      {activeTab === 'remove' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrashIcon className="h-5 w-5" />
              <span>Remove Field Masking</span>
            </CardTitle>
            <CardDescription>
              Remove existing data masking configuration from a database field
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
                    placeholder="e.g., CustNum, Name"
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
                        This action will permanently remove the masking configuration from the specified field.
                        Make sure you have the correct table and field names before proceeding.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" variant="destructive" disabled={loading}>
                  {loading ? 'Removing...' : 'Remove Masking'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Information Card */}
      <Card>
        <CardHeader>
          <CardTitle>Field Masking Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4 text-sm text-gray-600">
            <div>
              <h4 className="font-medium text-gray-900">Masking Types:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li><strong>Full Masking:</strong> Completely replaces the field value with the mask</li>
                <li><strong>Partial Masking:</strong> Masks only part of the field value</li>
                <li><strong>Conditional Masking:</strong> Applies masking based on specific conditions</li>
              </ul>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Authorization Tags:</h4>
              <p className="mt-2">
                Authorization tags control who can see unmasked data. Users must have appropriate 
                roles granted to access data with specific authorization tags.
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
