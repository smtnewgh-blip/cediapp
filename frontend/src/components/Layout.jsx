import React from 'react';
import { Outlet, Link, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';

function Layout() {
  const navigate = useNavigate();
  const logout = useAuthStore((state) => state.logout);
  const user = useAuthStore((state) => state.user);

  const handleLogout = () => {
    logout();
    navigate('/auth');
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow">
        <div className="container mx-auto px-4 py-4 flex justify-between items-center">
          <h1 className="text-2xl font-bold text-blue-600">CEDI App</h1>
          <div className="flex gap-4 items-center">
            <Link to="/" className="hover:text-blue-600">Dashboard</Link>
            <Link to="/transactions" className="hover:text-blue-600">Transactions</Link>
            <Link to="/ai-insights" className="hover:text-blue-600">AI Insights</Link>
            <Link to="/workflows" className="hover:text-blue-600">Workflows</Link>
            <span className="text-gray-600">{user?.name}</span>
            <button onClick={handleLogout} className="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600">
              Logout
            </button>
          </div>
        </div>
      </nav>
      <main className="container mx-auto px-4 py-8">
        <Outlet />
      </main>
    </div>
  );
}

export default Layout;
