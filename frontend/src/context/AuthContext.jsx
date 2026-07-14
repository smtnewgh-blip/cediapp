import React, { createContext, useContext } from 'react';
import { useAuthStore } from '../store/authStore';

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const { user, token } = useAuthStore();

  return (
    <AuthContext.Provider value={{ user, token, isAuthenticated: !!token }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
