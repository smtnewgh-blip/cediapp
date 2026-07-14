import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Dashboard from './pages/Dashboard';
import Transactions from './pages/Transactions';
import AIInsights from './pages/AIInsights';
import ManusWorkflows from './pages/ManusWorkflows';
import Auth from './pages/Auth';
import { AuthProvider } from './context/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/auth" element={<Auth />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Dashboard />} />
            <Route path="transactions" element={<Transactions />} />
            <Route path="ai-insights" element={<AIInsights />} />
            <Route path="workflows" element={<ManusWorkflows />} />
          </Route>
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
