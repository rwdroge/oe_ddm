"use client"

import { useState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/Card"
import { Button } from "@/components/ui/Button"
import { Input } from "@/components/ui/Input"
import DDMApiService from "@/services/api"
import type { MaskAndAuthTagResponse } from "@/types/api"
import { EyeIcon, MagnifyingGlassIcon } from "@heroicons/react/24/outline"
import toast from "react-hot-toast"

const viewerSchema = z.object({
  tableName: z.string().min(1, "Table name is required"),
  fieldName: z.string().min(1, "Field name is required"),
  userName: z.string().optional(),
})

type ViewerForm = z.infer<typeof viewerSchema>

export default function DataViewer() {
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<MaskAndAuthTagResponse | null>(null)

  const form = useForm<ViewerForm>({
    resolver: zodResolver(viewerSchema),
    defaultValues: {
      tableName: "Customer",
      fieldName: "state",
      userName: "AdminUser",
    },
  })

  const onSubmit = async (data: ViewerForm) => {
    try {
      setLoading(true)
      const res = await DDMApiService.getMaskAndAuthTag(
        data.tableName,
        data.fieldName,
        data.userName || undefined
      )
      setResult(res)
      toast.success("Lookup completed")
    } catch (e) {
      console.error(e)
      setResult(null)
      toast.error("Failed to lookup mask/auth tag")
    } finally {
      setLoading(false)
    }
  }

  const presets: Array<{ label: string; table: string; field: string }> = [
    { label: "Customer.state (D:)", table: "Customer", field: "state" },
    { label: "Customer.city (L:MASKED)", table: "Customer", field: "city" },
    { label: "Customer.phone (P:0,X,4)", table: "Customer", field: "phone" },
    { label: "Customer.address (N:)", table: "Customer", field: "address" },
  ]

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold text-gray-900 flex items-center space-x-3">
          <EyeIcon className="h-8 w-8" />
          <span>Data Viewer</span>
        </h1>
        <p className="mt-2 text-gray-600">
          Preview mask and authorization tag resolution for a specific field, optionally for a given user.
        </p>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center space-x-2">
            <MagnifyingGlassIcon className="h-5 w-5" />
            <span>Lookup Field Mask/Auth Tag</span>
          </CardTitle>
          <CardDescription>
            Enter a table, field, and optional user to see the effective mask and authorization tag.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Table Name</label>
                <Input
                  {...form.register("tableName")}
                  placeholder="e.g., Customer"
                  className={form.formState.errors.tableName ? "border-red-500" : ""}
                />
                {form.formState.errors.tableName && (
                  <p className="mt-1 text-sm text-red-600">{form.formState.errors.tableName.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Field Name</label>
                <Input
                  {...form.register("fieldName")}
                  placeholder="e.g., state, city, phone, address"
                  className={form.formState.errors.fieldName ? "border-red-500" : ""}
                />
                {form.formState.errors.fieldName && (
                  <p className="mt-1 text-sm text-red-600">{form.formState.errors.fieldName.message}</p>
                )}
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">View as User (optional)</label>
                <Input
                  {...form.register("userName")}
                  placeholder="e.g., AdminUser, GeneralUser"
                />
                <p className="mt-1 text-xs text-gray-500">If omitted, the backend will evaluate without a specific user context.</p>
              </div>
            </div>

            <div className="flex flex-wrap gap-2">
              {presets.map((p) => (
                <Button
                  key={p.label}
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    form.setValue("tableName", p.table)
                    form.setValue("fieldName", p.field)
                  }}
                >
                  {p.label}
                </Button>
              ))}
            </div>

            <div className="flex justify-end">
              <Button type="submit" disabled={loading}>
                {loading ? "Looking up..." : "Lookup"}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      {result && (
        <Card>
          <CardHeader>
            <CardTitle>Result</CardTitle>
            <CardDescription>
              Table: <span className="font-mono">{result.tableName}</span> • Field: <span className="font-mono">{result.fieldName}</span>
              {result.userName ? (
                <>
                  {" "}• User: <span className="font-mono">{result.userName}</span>
                </>
              ) : null}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <div className="bg-gray-50 rounded-lg p-4">
                <h4 className="font-medium text-gray-900 mb-2">Mask/Authorization Tag Info</h4>
                <pre className="text-sm text-gray-700 whitespace-pre-wrap font-mono bg-white p-3 rounded border">
                  {result.result}
                </pre>
              </div>
              <div className="flex items-center space-x-2 text-sm">
                <div className={`h-3 w-3 rounded-full ${result.success ? "bg-green-500" : "bg-red-500"}`}></div>
                <span className={result.success ? "text-green-700" : "text-red-700"}>
                  {result.success ? "Lookup successful" : "Lookup failed"}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>How to interpret results</CardTitle>
        </CardHeader>
        <CardContent>
          <ul className="list-disc list-inside text-sm text-gray-600 space-y-1">
            <li><strong>Mask value:</strong> D: (default), L: (literal), P: (partial), N: (null)</li>
            <li><strong>Auth tag:</strong> The authorization tag that controls unmask visibility</li>
            <li><strong>User context:</strong> If a user is provided, visibility may differ by their roles</li>
          </ul>
        </CardContent>
      </Card>
    </div>
  )
}
