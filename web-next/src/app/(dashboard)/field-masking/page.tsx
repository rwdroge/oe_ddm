'use client'

import { useEffect, useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { Select } from '@/components/ui/Select'
import { DDMApiService, getApiErrorMessage, getResponseErrorMessage } from '@/services/api'
import { AUTH_TAG_PREFIX_CONST } from '@/lib/validation'
import type { ConfigureFieldRequest, FieldRequest } from '@/types/api'
import { EyeSlashIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

// UI-level mask kinds aligned to D/N/L/P
const maskKinds = ['DEFAULT', 'NULL', 'LITERAL', 'PARTIAL'] as const
type MaskKind = typeof maskKinds[number]

const fieldMaskingSchema = z.object({
  tableName: z.string().min(1, 'Table name is required'),
  fieldName: z.string().min(1, 'Field name is required'),
  // UI mask kind, we will map to backend maskingType + maskingValue on submit
  maskKind: z.enum(maskKinds),
  maskingValue: z.string().optional(),
  authTag: z.string().min(1, 'Authorization tag is required'),
}).superRefine((val, ctx) => {
  // Only require and validate maskingValue for LITERAL and PARTIAL
  if (val.maskKind === 'LITERAL') {
    if (!val.maskingValue || val.maskingValue.trim().length === 0) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['maskingValue'], message: 'Literal mask requires a value (e.g., MASKED)' })
    }
  }
  if (val.maskKind === 'PARTIAL') {
    if (!val.maskingValue || val.maskingValue.trim().length === 0) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['maskingValue'], message: 'Partial mask requires a format (e.g., 0,X,4)' })
    } else if (!/^\d+,[^,],\d+$/.test(val.maskingValue)) {
      ctx.addIssue({ code: z.ZodIssueCode.custom, path: ['maskingValue'], message: 'Partial mask must be start,maskChar,count (e.g., 0,X,4)' })
    }
  }
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
  const [tables, setTables] = useState<string[]>([])
  const [fields, setFields] = useState<string[]>([])
  const [authTags, setAuthTags] = useState<string[]>([])
  const [fieldTypes, setFieldTypes] = useState<Record<string, string>>({})
  const [listsLoading, setListsLoading] = useState({ tables: false, fields: false, tags: false })
  const [listsError, setListsError] = useState<string | null>(null)
  const [configsLoading, setConfigsLoading] = useState(false)
  const [configsError, setConfigsError] = useState<string | null>(null)
  const [fieldConfigs, setFieldConfigs] = useState<{ fieldName: string; result: string; maskValue?: string; authTag?: string }[]>([])

  function parseConfigSummary(summary: string): { maskValue?: string; authTag?: string } {
    if (!summary) return {}
    // Try common patterns first
    const patterns = [
      /mask\s*[:=]\s*([^,;\n]+).*?auth\s*tag\s*[:=]\s*([^,;\n]+)/i,
      /auth\s*tag\s*[:=]\s*([^,;\n]+).*?mask\s*[:=]\s*([^,;\n]+)/i,
      /Mask\s*Value\s*[:=]\s*([^,;\n]+).*?Auth\s*Tag\s*[:=]\s*([^,;\n]+)/i,
    ]
    for (const re of patterns) {
      const m = summary.match(re)
      if (m) {
        // normalize order to mask, auth
        if (/mask/i.test(re.source.split('.*?')[0])) {
          return { maskValue: m[1]?.trim(), authTag: m[2]?.trim() }
        } else {
          return { maskValue: m[2]?.trim(), authTag: m[1]?.trim() }
        }
      }
    }
    // Fallback: try to detect single tokens starting with D:/N:/L:/P:
    const maskToken = summary.match(/\b([DN]:|L:[^,;\s]+|P:\d+,[^,],\d+)\b/)
    const tagToken = summary.match(/#DDM_See_[A-Za-z0-9_.\-#$%&]+/i)
    const parsed: { maskValue?: string; authTag?: string } = {}
    if (maskToken) parsed.maskValue = maskToken[1]
    if (tagToken) parsed.authTag = tagToken[0]
    return parsed
  }

  const configureForm = useForm<FieldMaskingForm>({
    resolver: zodResolver(fieldMaskingSchema),
    defaultValues: {
      maskKind: 'DEFAULT',
    },
  })

  const selectedMaskKind = configureForm.watch('maskKind')
  const selectedTable = configureForm.watch('tableName')

  const removeForm = useForm<RemoveMaskForm>({
    resolver: zodResolver(removeMaskSchema),
  })

  // Load initial lists: tables and auth tags
  useEffect(() => {
    const fetchLists = async () => {
      try {
        setListsLoading((s) => ({ ...s, tables: true, tags: true }))
        setListsError(null)
        const [tablesRes, tagsRes] = await Promise.all([
          DDMApiService.getTables(),
          DDMApiService.getAuthTags(),
        ])

        setTables(tablesRes.tables || [])
        const tags = (tagsRes.result || '')
          .split(',')
          .map((t) => t.trim())
          .filter((t) => t.length > 0)
        setAuthTags(tags)
      } catch (e: any) {
        setListsError(getApiErrorMessage(e, 'Failed to load tables or authorization tags'))
      } finally {
        setListsLoading((s) => ({ ...s, tables: false, tags: false }))
      }
    }
    fetchLists()
  }, [])

  // Load fields whenever a table is selected
  useEffect(() => {
    const fetchFields = async () => {
      if (!selectedTable) {
        setFields([])
        setFieldConfigs([])
        return
      }
      try {
        setListsLoading((s) => ({ ...s, fields: true }))
        setListsError(null)
        const res = await DDMApiService.getFields(selectedTable)
        setFields(res.fields || [])
        setFieldTypes(res.fieldTypes || {})
      } catch (e: any) {
        setListsError(getApiErrorMessage(e, 'Failed to load fields'))
        setFields([])
        setFieldTypes({})
      } finally {
        setListsLoading((s) => ({ ...s, fields: false }))
      }
    }
    fetchFields()
  }, [selectedTable])

  // Load existing masking configurations for the selected table (aggregated endpoint)
  const refreshConfigs = async () => {
    if (!selectedTable) {
      setFieldConfigs([])
      return
    }
    try {
      setConfigsLoading(true)
      setConfigsError(null)
      const res = await DDMApiService.getTableConfigs(selectedTable)
      const items = (res.items || []).map((it) => {
        const parsed = parseConfigSummary(it.result || '')
        return { fieldName: it.fieldName, result: it.result || '', maskValue: parsed.maskValue, authTag: parsed.authTag }
      })
      setFieldConfigs(items)
    } catch (e: any) {
      setConfigsError(getApiErrorMessage(e, 'Failed to load field configurations'))
      setFieldConfigs([])
    } finally {
      setConfigsLoading(false)
    }
  }

  useEffect(() => {
    refreshConfigs()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedTable])

  const onConfigureSubmit = async (data: FieldMaskingForm) => {
    try {
      setLoading(true)
      // Enforce datatype compatibility for PARTIAL (character only)
      const fType = fieldTypes[data.fieldName]?.toUpperCase?.() || ''
      if (data.maskKind === 'PARTIAL' && fType && fType !== 'CHARACTER') {
        configureForm.setError('maskKind', { type: 'custom', message: 'Partial masks are only supported for CHARACTER fields' })
        setLoading(false)
        return
      }
      // Map UI mask kind to backend request shape
      let maskingType: ConfigureFieldRequest['maskingType'] = 'FULL'
      let maskingValue: string = ''
      switch (data.maskKind) {
        case 'DEFAULT':
          maskingType = 'FULL'
          maskingValue = 'D:'
          break
        case 'NULL':
          maskingType = 'FULL'
          maskingValue = 'N:'
          break
        case 'LITERAL':
          maskingType = 'FULL'
          maskingValue = `L:${data.maskingValue || ''}`
          break
        case 'PARTIAL':
          maskingType = 'PARTIAL'
          maskingValue = `P:${data.maskingValue || ''}`
          break
      }

      const request: ConfigureFieldRequest = {
        tableName: data.tableName,
        fieldName: data.fieldName,
        maskingType,
        maskingValue,
        authTag: data.authTag,
      }
      
      const response = await DDMApiService.configureField(request)
      
      if (response.success) {
        toast.success(`Field masking configured successfully for ${data.tableName}.${data.fieldName}`)
        configureForm.reset()
      } else {
        toast.error(getResponseErrorMessage(response as any, 'Failed to configure field masking'))
      }
    } catch (error: any) {
      console.error('Configure field error:', error)
      toast.error(getApiErrorMessage(error, 'Failed to configure field masking'))
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
        toast.error(getResponseErrorMessage(response as any, 'Failed to remove mask'))
      }
    } catch (error: any) {
      console.error('Remove mask error:', error)
      toast.error(getApiErrorMessage(error, 'Failed to remove mask'))
    } finally {
      setLoading(false)
    }
  }

  const maskingKindOptions: { value: MaskKind; label: string; description: string }[] = [
    { value: 'DEFAULT', label: 'Default (D:)', description: 'Default mask provided by clients' },
    { value: 'NULL', label: 'Null (N:)', description: 'Sets masked value to null (any type)' },
    { value: 'LITERAL', label: 'Literal (L:value)', description: 'Replace value with literal (not for RAW/LOGICAL)' },
    { value: 'PARTIAL', label: 'Partial (P:start,maskChar,count)', description: 'Partially mask character fields' },
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
              {/* Demo Presets */}
              <div className="space-y-2">
                <div className="text-sm text-gray-700 font-medium">Demo Presets</div>
                <div className="flex flex-wrap gap-2">
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      configureForm.setValue('tableName', 'Customer')
                      configureForm.setValue('fieldName', 'state')
                      configureForm.setValue('maskKind', 'DEFAULT')
                      configureForm.setValue('maskingValue', undefined)
                      configureForm.setValue('authTag', '#DDM_SEE_ContactInfo')
                    }}
                  >
                    Default mask: Customer.state (D:)
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      configureForm.setValue('tableName', 'Customer')
                      configureForm.setValue('fieldName', 'city')
                      configureForm.setValue('maskKind', 'LITERAL')
                      configureForm.setValue('maskingValue', 'MASKED')
                      configureForm.setValue('authTag', '#DDM_SEE_ContactInfo')
                    }}
                  >
                    Literal mask: Customer.city (L:MASKED)
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      configureForm.setValue('tableName', 'Customer')
                      configureForm.setValue('fieldName', 'phone')
                      configureForm.setValue('maskKind', 'PARTIAL')
                      configureForm.setValue('maskingValue', '0,X,4')
                      configureForm.setValue('authTag', '#DDM_SEE_ContactInfo')
                    }}
                  >
                    Partial mask: Customer.phone (P:0,X,4)
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      configureForm.setValue('tableName', 'Customer')
                      configureForm.setValue('fieldName', 'address')
                      configureForm.setValue('maskKind', 'NULL')
                      configureForm.setValue('maskingValue', undefined)
                      configureForm.setValue('authTag', '#DDM_SEE_ContactInfo')
                    }}
                  >
                    Null mask: Customer.address (N:)
                  </Button>
                </div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Table Name
                  </label>
                  <Select
                    {...configureForm.register('tableName')}
                    className={configureForm.formState.errors.tableName ? 'border-red-500' : ''}
                  >
                    <option value="">{listsLoading.tables ? 'Loading tables...' : 'Select a table'}</option>
                    {tables.map((t) => (
                      <option key={t} value={t}>{t}</option>
                    ))}
                  </Select>
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
                  <Select
                    {...configureForm.register('fieldName')}
                    disabled={!configureForm.getValues('tableName')}
                    className={configureForm.formState.errors.fieldName ? 'border-red-500' : ''}
                  >
                    <option value="">
                      {!configureForm.getValues('tableName')
                        ? 'Select a table first'
                        : listsLoading.fields ? 'Loading fields...' : 'Select a field'}
                    </option>
                    {fields.map((f) => (
                      <option key={f} value={f}>{f}</option>
                    ))}
                  </Select>
                  {configureForm.formState.errors.fieldName && (
                    <p className="mt-1 text-sm text-red-600">
                      {configureForm.formState.errors.fieldName.message}
                    </p>
                  )}
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Mask Type
                </label>
                <Select
                  {...configureForm.register('maskKind')}
                  className={configureForm.formState.errors.maskKind ? 'border-red-500' : ''}
                >
                  {maskingKindOptions.map((option) => (
                    <option key={option.value} value={option.value}>
                      {option.label} - {option.description}
                    </option>
                  ))}
                </Select>
                {configureForm.formState.errors.maskKind && (
                  <p className="mt-1 text-sm text-red-600">
                    {configureForm.formState.errors.maskKind.message as any}
                  </p>
                )}
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {selectedMaskKind === 'LITERAL' || selectedMaskKind === 'PARTIAL' ? (
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-2">
                      Mask Value
                    </label>
                    <Input
                      {...configureForm.register('maskingValue')}
                      placeholder={selectedMaskKind === 'LITERAL' ? 'MASKED' : '0,X,4'}
                      className={configureForm.formState.errors.maskingValue ? 'border-red-500' : ''}
                    />
                    <p className="mt-1 text-xs text-gray-500">
                      {selectedMaskKind === 'LITERAL'
                        ? 'Literal mask: enter only the value after "L:" (not for RAW/LOGICAL)'
                        : 'Partial mask: enter only start,maskChar,count (character fields only)'}
                      . The transformed value must preserve the original datatype.
                    </p>
                    {configureForm.formState.errors.maskingValue && (
                      <p className="mt-1 text-sm text-red-600">
                        {configureForm.formState.errors.maskingValue.message}
                      </p>
                    )}
                  </div>
                ) : null}

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Authorization Tag
                  </label>
                  <Select
                    {...configureForm.register('authTag')}
                    className={configureForm.formState.errors.authTag ? 'border-red-500' : ''}
                  >
                    <option value="">{listsLoading.tags ? 'Loading authorization tags...' : 'Select an authorization tag'}</option>
                    {authTags.map((t) => (
                      <option key={t} value={t}>{t}</option>
                    ))}
                  </Select>
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

      {/* Existing Configurations */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <CardTitle>Existing Field Masking Configurations</CardTitle>
            <Button type="button" variant="outline" size="sm" onClick={refreshConfigs} disabled={!selectedTable || configsLoading}>
              {configsLoading ? 'Refreshing...' : 'Refresh'}
            </Button>
          </div>
          <CardDescription>
            {selectedTable ? `For table ${selectedTable}` : 'Select a table to view existing configurations'}
          </CardDescription>
        </CardHeader>
        <CardContent>
          {!selectedTable ? (
            <p className="text-sm text-gray-600">Select a table to load configurations.</p>
          ) : configsLoading ? (
            <p className="text-sm text-gray-600">Loading configurations...</p>
          ) : configsError ? (
            <p className="text-sm text-red-600">{configsError}</p>
          ) : fieldConfigs.length === 0 ? (
            <p className="text-sm text-gray-600">No existing DDM configurations found for this table.</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Field</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mask</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Authorization Tag</th>
                    <th className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Details</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {fieldConfigs.map((cfg) => (
                    <tr key={cfg.fieldName}>
                      <td className="px-4 py-2 text-sm text-gray-900">{cfg.fieldName}</td>
                      <td className="px-4 py-2 text-sm text-gray-700">{cfg.maskValue || '-'}</td>
                      <td className="px-4 py-2 text-sm text-gray-700">{cfg.authTag || '-'}</td>
                      <td className="px-4 py-2 text-xs text-gray-500 leading-snug whitespace-pre-wrap">{cfg.result}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
