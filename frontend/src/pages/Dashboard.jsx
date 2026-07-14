import React, { useState, useEffect } from 'react';
import api from '../utils/api';
import toast from 'react-hot-toast';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [chartData, setChartData] = useState([]);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const response = await api.get('/transactions');
      const transactions = response.data;
      
      setStats({
        totalTransactions: transactions.length,
        totalAmount: transactions.reduce((sum, t) => sum + parseFloat(t.amount || 0), 0),
        pending: transactions.filter(t => t.status === 'pending').length,
        completed: transactions.filter(t => t.status === 'completed').length
      });

      // Mock chart data
      setChartData([
        { date: 'Day 1', amount: 4000 },
        { date: 'Day 2', amount: 3000 },
        { date: 'Day 3', amount: 2000 },
        { date: 'Day 4', amount: 2780 },
        { date: 'Day 5', amount: 1890 },
        { date: 'Day 6', amount: 2390 },
        { date: 'Day 7', amount: 3490 }
      ]);
    } catch (error) {
      toast.error('Failed to fetch dashboard data');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="text-center py-8">Loading...</div>;

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Dashboard</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-600 text-sm">Total Transactions</h3>
          <p className="text-3xl font-bold mt-2">{stats?.totalTransactions || 0}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-600 text-sm">Total Amount</h3>
          <p className="text-3xl font-bold mt-2 text-green-600">₵{stats?.totalAmount?.toFixed(2) || 0}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-600 text-sm">Pending</h3>
          <p className="text-3xl font-bold mt-2 text-yellow-600">{stats?.pending || 0}</p>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <h3 className="text-gray-600 text-sm">Completed</h3>
          <p className="text-3xl font-bold mt-2 text-blue-600">{stats?.completed || 0}</p>
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-bold mb-4">Transaction Trend</h2>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="amount" stroke="#3b82f6" />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

export default Dashboard;
