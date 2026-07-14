const express = require('express');
const router = express.Router();
const transactionRoutes = require('./transactions');
const aiRoutes = require('./ai');
const manusRoutes = require('./manus');
const authRoutes = require('./auth');

router.use('/transactions', transactionRoutes);
router.use('/ai', aiRoutes);
router.use('/manus', manusRoutes);
router.use('/auth', authRoutes);

module.exports = router;
