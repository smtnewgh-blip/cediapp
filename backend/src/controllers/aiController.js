const axios = require('axios');

const CLAUDE_API = 'https://api.anthropic.com/v1';

const analyzeTransaction = async (req, res) => {
  try {
    const { transactionData } = req.body;
    const prompt = `Analyze this transaction: ${JSON.stringify(transactionData)}. Provide risk assessment and recommendations.`;

    const response = await axios.post(
      `${CLAUDE_API}/messages`,
      {
        model: process.env.CLAUDE_MODEL,
        max_tokens: 1024,
        messages: [{ role: 'user', content: prompt }]
      },
      {
        headers: { 'x-api-key': process.env.CLAUDE_API_KEY }
      }
    );

    res.json({ analysis: response.data.content[0].text });
  } catch (err) {
    res.status(500).json({ error: 'AI analysis failed', details: err.message });
  }
};

const forecastTrend = async (req, res) => {
  try {
    const { historicalData } = req.body;
    const prompt = `Forecast trend for CEDI coin based on: ${JSON.stringify(historicalData)}. Provide predictions for next 7 days.`;

    const response = await axios.post(
      `${CLAUDE_API}/messages`,
      {
        model: process.env.CLAUDE_MODEL,
        max_tokens: 1024,
        messages: [{ role: 'user', content: prompt }]
      },
      {
        headers: { 'x-api-key': process.env.CLAUDE_API_KEY }
      }
    );

    res.json({ forecast: response.data.content[0].text });
  } catch (err) {
    res.status(500).json({ error: 'Forecast failed', details: err.message });
  }
};

const getInsights = async (req, res) => {
  try {
    const { portfolio } = req.body;
    const prompt = `Provide financial insights for portfolio: ${JSON.stringify(portfolio)}. Include optimization suggestions.`;

    const response = await axios.post(
      `${CLAUDE_API}/messages`,
      {
        model: process.env.CLAUDE_MODEL,
        max_tokens: 2048,
        messages: [{ role: 'user', content: prompt }]
      },
      {
        headers: { 'x-api-key': process.env.CLAUDE_API_KEY }
      }
    );

    res.json({ insights: response.data.content[0].text });
  } catch (err) {
    res.status(500).json({ error: 'Insights generation failed', details: err.message });
  }
};

module.exports = { analyzeTransaction, forecastTrend, getInsights };
