'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/Button'
import { DDMApiService } from '@/services/api'
import { UserIcon, ArrowRightOnRectangleIcon } from '@heroicons/react/24/outline'
import toast from 'react-hot-toast'

export default function Header() {
  const [user, setUser] = useState<string | null>(null)

  useEffect(() => {
    const auth = DDMApiService.getAuth()
    if (auth) {
      setUser(auth.username)
    }
  }, [])

  const handleLogout = () => {
    DDMApiService.clearAuth()
    setUser(null)
    toast.success('Logged out successfully')
    window.location.href = '/login'
  }

  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 justify-between items-center">
          <div className="flex items-center">
            <h1 className="text-2xl font-bold text-gray-900">
              Dynamic Data Masking Administration
            </h1>
          </div>
          
          {user && (
            <div className="flex items-center space-x-4">
              <div className="flex items-center space-x-2 text-sm text-gray-700">
                <UserIcon className="h-5 w-5" />
                <span>{user}</span>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={handleLogout}
                className="flex items-center space-x-2"
              >
                <ArrowRightOnRectangleIcon className="h-4 w-4" />
                <span>Logout</span>
              </Button>
            </div>
          )}
        </div>
      </div>
    </header>
  )
}
