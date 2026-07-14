const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const aiController = require('../controllers/aiController');

router.post('/analyze', auth, aiController.analyzeTransaction);
router.post('/forecast', auth, aiController.forecastTrend);
router.post('/insights', auth, aiController.getInsights);

module.exports = router;
