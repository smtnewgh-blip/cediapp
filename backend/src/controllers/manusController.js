const axios = require('axios');

const MANUS_API_URL = process.env.MANUS_API_URL;
const MANUS_API_KEY = process.env.MANUS_API_KEY;

const triggerWorkflow = async (req, res) => {
  try {
    const { workflowId, payload } = req.body;

    const response = await axios.post(
      `${MANUS_API_URL}/workflows/${workflowId}/trigger`,
      payload,
      {
        headers: {
          'Authorization': `Bearer ${MANUS_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    res.json({ status: 'triggered', data: response.data });
  } catch (err) {
    res.status(500).json({ error: 'Workflow trigger failed', details: err.message });
  }
};

const getWorkflows = async (req, res) => {
  try {
    const response = await axios.get(
      `${MANUS_API_URL}/workflows`,
      {
        headers: {
          'Authorization': `Bearer ${MANUS_API_KEY}`
        }
      }
    );

    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch workflows', details: err.message });
  }
};

const automateProcess = async (req, res) => {
  try {
    const { processName, conditions, actions } = req.body;

    const response = await axios.post(
      `${MANUS_API_URL}/automations`,
      { processName, conditions, actions },
      {
        headers: {
          'Authorization': `Bearer ${MANUS_API_KEY}`,
          'Content-Type': 'application/json'
        }
      }
    );

    res.json({ status: 'automation_created', data: response.data });
  } catch (err) {
    res.status(500).json({ error: 'Process automation failed', details: err.message });
  }
};

module.exports = { triggerWorkflow, getWorkflows, automateProcess };
