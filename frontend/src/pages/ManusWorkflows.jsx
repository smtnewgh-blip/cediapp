import React, { useState } from 'react';
import api from '../utils/api';
import toast from 'react-hot-toast';

function ManusWorkflows() {
  const [workflows, setWorkflows] = useState([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    workflowId: '',
    payload: '{}'
  });

  const fetchWorkflows = async () => {
    setLoading(true);
    try {
      const response = await api.get('/manus/workflows');
      setWorkflows(response.data.workflows || []);
      toast.success('Workflows fetched successfully');
    } catch (error) {
      toast.error('Failed to fetch workflows');
    } finally {
      setLoading(false);
    }
  };

  const handleTriggerWorkflow = async () => {
    if (!formData.workflowId.trim()) {
      toast.error('Please enter workflow ID');
      return;
    }

    try {
      const response = await api.post('/manus/workflow/trigger', {
        workflowId: formData.workflowId,
        payload: JSON.parse(formData.payload)
      });
      toast.success('Workflow triggered successfully');
      setFormData({ workflowId: '', payload: '{}' });
    } catch (error) {
      toast.error(error.response?.data?.error || 'Failed to trigger workflow');
    }
  };

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-bold">Manus Workflows</h1>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white p-6 rounded-lg shadow space-y-4">
          <h2 className="text-xl font-bold">Trigger Workflow</h2>
          <input
            type="text"
            placeholder="Workflow ID"
            value={formData.workflowId}
            onChange={(e) => setFormData({ ...formData, workflowId: e.target.value })}
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600"
          />
          <textarea
            placeholder='Payload (JSON format)'
            value={formData.payload}
            onChange={(e) => setFormData({ ...formData, payload: e.target.value })}
            rows="6"
            className="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-600 font-mono text-sm"
          />
          <button
            onClick={handleTriggerWorkflow}
            className="w-full bg-green-600 text-white py-2 rounded hover:bg-green-700"
          >
            Trigger Workflow
          </button>
        </div>

        <div className="bg-white p-6 rounded-lg shadow space-y-4">
          <div className="flex justify-between items-center">
            <h2 className="text-xl font-bold">Available Workflows</h2>
            <button
              onClick={fetchWorkflows}
              disabled={loading}
              className="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 disabled:opacity-50"
            >
              {loading ? 'Loading...' : 'Refresh'}
            </button>
          </div>
          <div className="space-y-2 max-h-[300px] overflow-y-auto">
            {workflows.length > 0 ? (
              workflows.map((workflow, idx) => (
                <div key={idx} className="bg-gray-50 p-3 rounded border border-gray-200">
                  <p className="font-medium">{workflow.name || workflow.id}</p>
                  <p className="text-sm text-gray-600">{workflow.description}</p>
                </div>
              ))
            ) : (
              <p className="text-gray-400 italic">No workflows available</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default ManusWorkflows;
