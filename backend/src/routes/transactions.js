const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const transactionController = require('../controllers/transactionController');

router.get('/', auth, transactionController.getTransactions);
router.get('/:id', auth, transactionController.getTransaction);
router.post('/', auth, transactionController.createTransaction);
router.put('/:id', auth, transactionController.updateTransaction);
router.delete('/:id', auth, transactionController.deleteTransaction);

module.exports = router;
