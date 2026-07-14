import React, { useState } from 'react';
import api from '../utils/api';
import toast from 'react-hot-toast';

function AIInsights() {
  const [insights, setInsights] = useState('');
  const [loading, setLoading] = useState(false);
  const [portfolio, setPortfolio] = useState('');

  const handleGetInsights = async () => {
    if (!portfolio.trim()) {
      toast.error('Please enter portfolio data');
      return;
    }

    setLoading(true);
    try {
      const response = await api.post('/ai/insights', {
        portfolio: JSON.parse(portfolio)
      });
      setInsights(response.data.insights);
      toast.success('Insights generated successfully');
    } catch (error) {
      toast.error('Failed to generate insights');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">AI Insights - Claude Powered</h1>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-lg shadow space-y-4">
          <h2 className="text-xl font-bold">Generate Insights</h2>
          <textarea
            placeholder='Enter portfolio data (JSON format)\nExample: {"btc": 1.5, "eth": 10, "cedi": 1000}'
            value={portfolio}
            onChange={(e) => setPortfolio(e.target.value)}
            rows="6"
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 font-mono text-sm"
          />
          <button
            onClick={handleGetInsights}
            disabled={loading}
            className="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 disabled:opacity-50"
          >
            {loading ? 'Generating...' : 'Get AI Insights'}
          </button>
        </div>

        <div className="bg-white p-6 rounded-lg shadow space-y-4">
          <h2 className="text-xl font-bold">Insights Result</h2>
          <div className="bg-gray-50 p-4 rounded-lg min-h-[250px] max-h-[400px] overflow-y-auto">
            {insights ? (
              <p className="text-gray-700 whitespace-pre-wrap">{insights}</p>
            ) : (
              <p className="text-gray-400 italic">AI insights will appear here...</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default AIInsights;
