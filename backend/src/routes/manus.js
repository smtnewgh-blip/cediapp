const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const manusController = require('../controllers/manusController');

router.post('/workflow/trigger', auth, manusController.triggerWorkflow);
router.get('/workflows', auth, manusController.getWorkflows);
router.post('/automate', auth, manusController.automateProcess);

module.exports = router;
