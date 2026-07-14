require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const routes = require('./routes');
const { errorHandler } = require('./middleware/errorHandler');
const { logger } = require('./middleware/logger');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({ origin: process.env.CORS_ORIGIN }));
app.use(express.json());
app.use(logger);

// Database Connection
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

app.locals.db = pool;

// Routes
app.use('/api', routes);

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Error Handler
app.use(errorHandler);

// Start Server
app.listen(PORT, process.env.HOST || 'localhost', () => {
  console.log(`Backend server running on http://localhost:${PORT}`);
});

module.exports = app;
