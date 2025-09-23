'use client'

import { useEffect, useState } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/Card'
import { Button } from '@/components/ui/Button'
import { Input } from '@/components/ui/Input'
import { DDMApiService, getApiErrorMessage, getResponseErrorMessage } from '@/services/api'
import { isValidAuthorizationTag, getAuthorizationTagValidationError, AUTH_TAG_PREFIX_CONST } from '@/lib/validation'
import type { AuthTagRequest, UpdateAuthTagRequest, AssociateAuthTagRoleRequest } from '@/types/api'
import { TagIcon, PlusIcon, PencilIcon, TrashIcon } from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

const createTagSchema = z.object({
  domainName: z.string().min(1, 'Domain name is required'),
  authTagName: z.string().superRefine((val, ctx) => {
    const err = getAuthorizationTagValidationError(val)
    if (err) ctx.addIssue({ code: z.ZodIssueCode.custom, message: err })
  }),
})

const updateTagSchema = z.object({
  domainName: z.string().min(1, 'Domain name is required'),
  authTagName: z.string().superRefine((val, ctx) => {
    const err = getAuthorizationTagValidationError(val)
    if (err) ctx.addIssue({ code: z.ZodIssueCode.custom, message: err })
  }),
  newName: z.string().superRefine((val, ctx) => {
    const err = getAuthorizationTagValidationError(val)
    if (err) ctx.addIssue({ code: z.ZodIssueCode.custom, message: err })
  }),
})

const deleteTagSchema = z.object({
  domainName: z.string().min(1, 'Domain name is required'),
  authTagName: z.string().superRefine((val, ctx) => {
    const err = getAuthorizationTagValidationError(val)
    if (err) ctx.addIssue({ code: z.ZodIssueCode.custom, message: err })
  }),
})

type CreateTagForm = z.infer<typeof createTagSchema>
type UpdateTagForm = z.infer<typeof updateTagSchema>
type DeleteTagForm = z.infer<typeof deleteTagSchema>

function AssociateForm({ onChanged }: { onChanged?: () => void }) {
  const schema = z.object({
    currentRoleName: z.string().min(1, 'Current role is required'),
    authTagName: z.string().superRefine((val, ctx) => {
      const err = getAuthorizationTagValidationError(val)
      if (err) ctx.addIssue({ code: z.ZodIssueCode.custom, message: err })
    }),
    newRoleName: z.string().min(1, 'New role is required'),
  })
  type FormData = z.infer<typeof schema>

  const form = useForm<FormData>({ resolver: zodResolver(schema) })
  const [loading, setLoading] = useState(false)
  const [roles, setRoles] = useState<string[]>([])
  const [tags, setTags] = useState<string[]>([])

  useEffect(() => {
    (async () => {
      try {
        const res = await DDMApiService.getRoles()
        const list = (res.result || '')
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean)
        setRoles(list)
      } catch (e) {
        console.error(e)
      }
    })()
  }, [])

  // Load tags when current role changes
  useEffect(() => {
    const role = form.getValues('currentRoleName')
    if (!role) return
    (async () => {
      try {
        const res = await DDMApiService.getRoleAuthTags(role)
        const list = (res.result || '')
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean)
        setTags(list)
      } catch (e) {
        console.error(e)
        setTags([])
      }
    })()
  }, [form.watch('currentRoleName')])

  const onSubmit = async (data: FormData) => {
    try {
      setLoading(true)
      const payload: AssociateAuthTagRoleRequest = {
        currentRoleName: data.currentRoleName,
        authTagName: data.authTagName,
        newRoleName: data.newRoleName,
      }
      const res = await DDMApiService.associateAuthTagRole(payload)
      if (res.success) {
        toast.success(`Reassigned tag "${data.authTagName}" from ${data.currentRoleName} to ${data.newRoleName}`)
        form.reset()
        if (onChanged) onChanged()
      } else {
        toast.error(getResponseErrorMessage(res as any, 'Failed to reassign authorization tag'))
      }
    } catch (e: any) {
      console.error(e)
      toast.error(getApiErrorMessage(e, 'Failed to reassign authorization tag'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Current Role Name</label>
          <select
            className={`block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 text-sm ${form.formState.errors.currentRoleName ? 'border-red-500' : ''}`}
            {...form.register('currentRoleName')}
          >
            <option value="">Select a role…</option>
            {roles.map((r) => (
              <option key={r} value={r}>{r}</option>
            ))}
          </select>
          {form.formState.errors.currentRoleName && (
            <p className="mt-1 text-sm text-red-600">{form.formState.errors.currentRoleName.message}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">Authorization Tag Name</label>
          {tags.length > 0 ? (
            <select
              className={`block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 text-sm ${form.formState.errors.authTagName ? 'border-red-500' : ''}`}
              {...form.register('authTagName')}
            >
              <option value="">Select a tag…</option>
              {tags.map((t) => (
                <option key={t} value={t}>{t}</option>
              ))}
            </select>
          ) : (
            <Input
              {...form.register('authTagName')}
              placeholder={`e.g., ${AUTH_TAG_PREFIX_CONST}ContactInfo`}
              className={form.formState.errors.authTagName ? 'border-red-500' : ''}
            />
          )}
          {form.formState.errors.authTagName && (
            <p className="mt-1 text-sm text-red-600">{form.formState.errors.authTagName.message}</p>
          )}
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">New Role Name</label>
          <select
            className={`block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 text-sm ${form.formState.errors.newRoleName ? 'border-red-500' : ''}`}
            {...form.register('newRoleName')}
          >
            <option value="">Select a role…</option>
            {roles.map((r) => (
              <option key={r} value={r}>{r}</option>
            ))}
          </select>
          {form.formState.errors.newRoleName && (
            <p className="mt-1 text-sm text-red-600">{form.formState.errors.newRoleName.message}</p>
          )}
        </div>
      </div>

      <div className="flex justify-end">
        <Button type="submit" disabled={loading}>
          {loading ? 'Associating...' : 'Associate Tag to Role'}
        </Button>
      </div>
    </form>
  )
}

export default function AuthorizationTags() {
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState<'create' | 'update' | 'delete' | 'associate'>('create')
  const [roles, setRoles] = useState<string[]>([])
  const [allTags, setAllTags] = useState<{ name: string; role: string }[]>([])
  const [tagSearch, setTagSearch] = useState('')
  const [sortByRole, setSortByRole] = useState(false)

  const loadAllTags = async () => {
    try {
      const res = await DDMApiService.getAuthTagsWithRoles()
      const list = (res.result || '')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean)
        .map((item) => {
          const [name, role] = item.split('|')
          return { name: name || '', role: role || '' }
        })
      setAllTags(list)
    } catch (e) {
      console.error('Failed to load authorization tags', e)
      setAllTags([])
    }
  }

  useEffect(() => {
    (async () => {
      try {
        const res = await DDMApiService.getRoles()
        const list = (res.result || '')
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean)
        setRoles(list)
      } catch (e) {
        console.error(e)
      }
    })()
  }, [])

  const createForm = useForm<CreateTagForm>({
    resolver: zodResolver(createTagSchema),
  })

  const updateForm = useForm<UpdateTagForm>({
    resolver: zodResolver(updateTagSchema),
  })

  const deleteForm = useForm<DeleteTagForm>({
    resolver: zodResolver(deleteTagSchema),
  })

  const onCreateSubmit = async (data: CreateTagForm) => {
    try {
      setLoading(true)
      const request: AuthTagRequest = {
        domainName: data.domainName,
        authTagName: data.authTagName,
      }
      
      const response = await DDMApiService.createAuthTag(request)
      
      if (response.success) {
        toast.success(`Authorization tag "${data.authTagName}" created successfully in domain "${data.domainName}"`)
        createForm.reset()
        loadAllTags()
      } else {
        toast.error(getResponseErrorMessage(response as any, 'Failed to create authorization tag'))
      }
    } catch (error: any) {
      console.error('Create auth tag error:', error)
      toast.error(getApiErrorMessage(error, 'Failed to create authorization tag'))
    } finally {
      setLoading(false)
    }
  }

  const onUpdateSubmit = async (data: UpdateTagForm) => {
    try {
      setLoading(true)
      const request: UpdateAuthTagRequest = {
        domainName: data.domainName,
        authTagName: data.authTagName,
        newName: data.newName,
      }
      
      const response = await DDMApiService.updateAuthTag(request)
      
      if (response.success) {
        toast.success(`Authorization tag updated from "${data.authTagName}" to "${data.newName}"`)
        updateForm.reset()
        loadAllTags()
      } else {
        toast.error(getResponseErrorMessage(response as any, 'Failed to update authorization tag'))
      }
    } catch (error: any) {
      console.error('Update auth tag error:', error)
      toast.error(getApiErrorMessage(error, 'Failed to update authorization tag'))
    } finally {
      setLoading(false)
    }
  }

  const onDeleteSubmit = async (data: DeleteTagForm) => {
    try {
      setLoading(true)
      const request: AuthTagRequest = {
        domainName: data.domainName,
        authTagName: data.authTagName,
      }
      
      const response = await DDMApiService.deleteAuthTag(request)
      
      if (response.success) {
        toast.success(`Authorization tag "${data.authTagName}" deleted successfully`)
        deleteForm.reset()
        loadAllTags()
      } else {
        toast.error(getResponseErrorMessage(response as any, 'Failed to delete authorization tag'))
      }
    } catch (error: any) {
      console.error('Delete auth tag error:', error)
      toast.error(getApiErrorMessage(error, 'Failed to delete authorization tag'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-8">
      {/* Existing Authorization Tags Overview */}
      <Card>
        <CardHeader>
          <CardTitle>Existing Authorization Tags</CardTitle>
          <CardDescription>All authorization tags across roles</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center gap-2 mb-3">
            <Input
              placeholder="Search tags or roles..."
              value={tagSearch}
              onChange={(e) => setTagSearch(e.target.value)}
            />
            <Button type="button" variant="outline" size="sm" onClick={() => setSortByRole((v) => !v)}>
              Sort by {sortByRole ? 'role' : 'tag'}
            </Button>
            <Button type="button" variant="outline" size="sm" onClick={loadAllTags}>
              Refresh
            </Button>
          </div>
          {allTags.length === 0 ? (
            <p className="text-sm text-gray-600">No authorization tags found.</p>
          ) : (
            <ul className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2 text-sm">
              {allTags
                .filter((t) =>
                  (t.name + ' ' + t.role).toLowerCase().includes(tagSearch.toLowerCase())
                )
                .sort((a, b) =>
                  sortByRole ? a.role.localeCompare(b.role) : a.name.localeCompare(b.name)
                )
                .map((t) => (
                  <li key={`${t.name}|${t.role}`} className="rounded border bg-white px-3 py-2 flex items-center justify-between">
                    <span>{t.name}</span>
                    <span className="text-xs text-gray-600">{t.role}</span>
                  </li>
                ))}
            </ul>
          )}
        </CardContent>
      </Card>
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 flex items-center space-x-3">
          <TagIcon className="h-8 w-8" />
          <span>Authorization Tags</span>
        </h1>
        <p className="mt-2 text-gray-600">
          Manage authorization tags that control access to masked data
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
            Create Tag
          </button>
          <button
            onClick={() => setActiveTab('update')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'update'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Update Tag
          </button>
          <button
            onClick={() => setActiveTab('delete')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'delete'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Delete Tag
          </button>
          <button
            onClick={() => setActiveTab('associate')}
            className={`py-2 px-1 border-b-2 font-medium text-sm ${
              activeTab === 'associate'
                ? 'border-primary-500 text-primary-600'
                : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
            }`}
          >
            Associate to Role
          </button>
        </nav>
      </div>

      {/* Create Tag Tab */}
      {activeTab === 'create' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <PlusIcon className="h-5 w-5" />
              <span>Create Authorization Tag</span>
            </CardTitle>
            <CardDescription>
              Create a new authorization tag and associate it to a Role. The Role determines who can see unmasked data for fields using this tag.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={createForm.handleSubmit(onCreateSubmit)} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Role Name
                  </label>
                  <select
                    className={`block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 text-sm ${createForm.formState.errors.domainName ? 'border-red-500' : ''}`}
                    {...createForm.register('domainName')}
                  >
                    <option value="">Select a role…</option>
                    {roles.map((r) => (
                      <option key={r} value={r}>{r}</option>
                    ))}
                  </select>
                  {createForm.formState.errors.domainName && (
                    <p className="mt-1 text-sm text-red-600">
                      {createForm.formState.errors.domainName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Authorization Tag Name
                  </label>
                  <Input
                    {...createForm.register('authTagName')}
                    placeholder={`Must start with ${AUTH_TAG_PREFIX_CONST} and use A-Z, a-z, 0-9, _ . - # $ % &`}
                    className={createForm.formState.errors.authTagName ? 'border-red-500' : ''}
                  />
                  {createForm.formState.errors.authTagName && (
                    <p className="mt-1 text-sm text-red-600">
                      {createForm.formState.errors.authTagName.message}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" disabled={loading}>
                  {loading ? 'Creating...' : 'Create Authorization Tag'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Associate Tag to Role Tab */}
      {activeTab === 'associate' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <PencilIcon className="h-5 w-5" />
              <span>Associate Authorization Tag to Role</span>
            </CardTitle>
            <CardDescription>
              Reassign an existing authorization tag from a current role to a new role
            </CardDescription>
          </CardHeader>
          <CardContent>
            <AssociateForm onChanged={loadAllTags} />
          </CardContent>
        </Card>
      )}

      {/* Update Tag Tab */}
      {activeTab === 'update' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <PencilIcon className="h-5 w-5" />
              <span>Update Authorization Tag</span>
            </CardTitle>
            <CardDescription>
              Update an existing authorization tag name (association to Role remains the same)
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={updateForm.handleSubmit(onUpdateSubmit)} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Role Name
                  </label>
                  <select
                    className={`block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 text-sm ${updateForm.formState.errors.domainName ? 'border-red-500' : ''}`}
                    {...updateForm.register('domainName')}
                  >
                    <option value="">Select a role…</option>
                    {roles.map((r) => (
                      <option key={r} value={r}>{r}</option>
                    ))}
                  </select>
                  {updateForm.formState.errors.domainName && (
                    <p className="mt-1 text-sm text-red-600">
                      {updateForm.formState.errors.domainName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Current Tag Name
                  </label>
                  <Input
                    {...updateForm.register('authTagName')}
                    placeholder={`e.g., ${AUTH_TAG_PREFIX_CONST}ContactInfo`}
                    className={updateForm.formState.errors.authTagName ? 'border-red-500' : ''}
                  />
                  {updateForm.formState.errors.authTagName && (
                    <p className="mt-1 text-sm text-red-600">
                      {updateForm.formState.errors.authTagName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    New Tag Name
                  </label>
                  <Input
                    {...updateForm.register('newName')}
                    placeholder={`e.g., ${AUTH_TAG_PREFIX_CONST}PII`}
                    className={updateForm.formState.errors.newName ? 'border-red-500' : ''}
                  />
                  {updateForm.formState.errors.newName && (
                    <p className="mt-1 text-sm text-red-600">
                      {updateForm.formState.errors.newName.message}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" disabled={loading}>
                  {loading ? 'Updating...' : 'Update Authorization Tag'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Delete Tag Tab */}
      {activeTab === 'delete' && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center space-x-2">
              <TrashIcon className="h-5 w-5" />
              <span>Delete Authorization Tag</span>
            </CardTitle>
            <CardDescription>
              Remove an authorization tag (it will no longer control access for associated fields)
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={deleteForm.handleSubmit(onDeleteSubmit)} className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">Role Name</label>
                  <select
                    className={`block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500 text-sm ${deleteForm.formState.errors.domainName ? 'border-red-500' : ''}`}
                    {...deleteForm.register('domainName')}
                  >
                    <option value="">Select a role…</option>
                    {roles.map((r) => (
                      <option key={r} value={r}>{r}</option>
                    ))}
                  </select>
                  {deleteForm.formState.errors.domainName && (
                    <p className="mt-1 text-sm text-red-600">
                      {deleteForm.formState.errors.domainName.message}
                    </p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-2">
                    Authorization Tag Name
                  </label>
                  <Input
                    {...deleteForm.register('authTagName')}
                    placeholder={`e.g., ${AUTH_TAG_PREFIX_CONST}ContactInfo`}
                    className={deleteForm.formState.errors.authTagName ? 'border-red-500' : ''}
                  />
                  {deleteForm.formState.errors.authTagName && (
                    <p className="mt-1 text-sm text-red-600">
                      {deleteForm.formState.errors.authTagName.message}
                    </p>
                  )}
                </div>
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
                        This action will permanently delete the authorization tag. Any fields using this tag
                        may lose their access control. Make sure this tag is not in use before deleting.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-end">
                <Button type="submit" variant="destructive" disabled={loading}>
                  {loading ? 'Deleting...' : 'Delete Authorization Tag'}
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Information Card */}
      <Card>
        <CardHeader>
          <CardTitle>Authorization Tags Information</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4 text-sm text-gray-600">
            <div>
              <h4 className="font-medium text-gray-900">What are Authorization Tags?</h4>
              <p className="mt-2">
                Authorization tags are labels that control access to masked data. They work in conjunction 
                with user roles to determine who can see unmasked sensitive information.
              </p>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Authorization Tag Format</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li>Must begin with <code>#DDM_See_</code> (case-insensitive)</li>
                <li>Maximum length: 64 characters total</li>
                <li>Allowed characters: A–Z, a–z, 0–9, and <code>_ . - # $ % &</code></li>
                <li>No spaces allowed</li>
                <li>Must include non-empty content after the required prefix</li>
              </ul>
              <p className="mt-2">Examples: <code>#DDM_See_PII</code>, <code>#DDM_See_ContactInfo</code>, <code>#DDM_See_TopSecret</code></p>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Common Tag Examples:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li><strong>PII:</strong> Personally Identifiable Information</li>
                <li><strong>CONFIDENTIAL:</strong> Confidential business data</li>
                <li><strong>SENSITIVE:</strong> General sensitive information</li>
                <li><strong>FINANCIAL:</strong> Financial data and records</li>
                <li><strong>MEDICAL:</strong> Healthcare and medical information</li>
              </ul>
            </div>
            <div>
              <h4 className="font-medium text-gray-900">Best Practices:</h4>
              <ul className="mt-2 space-y-1 list-disc list-inside">
                <li>Use descriptive, standardized tag names</li>
                <li>Create tags based on data sensitivity levels</li>
                <li>Regularly review and audit tag usage</li>
                <li>Document tag purposes and access policies</li>
              </ul>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
