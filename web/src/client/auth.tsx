import { createContext, useContext, useMemo, useState, type ReactNode } from 'react'
import { api } from '~/shared/api'
import type { User } from '~/shared/types'

interface AuthValue {
  user: User | null
  login: (email: string, password: string) => Promise<void>
  signup: (input: { name: string; email: string; password: string }) => Promise<void>
  logout: () => Promise<void>
}

const AuthContext = createContext<AuthValue | null>(null)

export function AuthProvider({ initialUser, children }: { initialUser: User | null; children: ReactNode }) {
  const [user, setUser] = useState<User | null>(initialUser)

  const value = useMemo<AuthValue>(() => ({
    user,
    login: async (email, password) => {
      const { user: signedIn } = await api.login(email, password)
      setUser(signedIn)
    },
    signup: async (input) => {
      const { user: created } = await api.signup(input)
      setUser(created)
    },
    logout: async () => {
      await api.logout()
      setUser(null)
    },
  }), [user])

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth(): AuthValue {
  const value = useContext(AuthContext)
  if (!value) throw new Error('useAuth must be used inside AuthProvider')
  return value
}
