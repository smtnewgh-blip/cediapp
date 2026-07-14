const { validateTransaction } = require('../validators/transactionValidator');

const getTransactions = async (req, res) => {
  try {
    const result = await req.app.locals.db.query(
      'SELECT * FROM transactions WHERE user_id = $1 ORDER BY created_at DESC',
      [req.user.id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const getTransaction = async (req, res) => {
  try {
    const result = await req.app.locals.db.query(
      'SELECT * FROM transactions WHERE id = $1 AND user_id = $2',
      [req.params.id, req.user.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const createTransaction = async (req, res) => {
  try {
    const { error, value } = validateTransaction(req.body);
    if (error) return res.status(400).json({ error: error.details[0].message });

    const result = await req.app.locals.db.query(
      'INSERT INTO transactions (user_id, amount, type, description, status) VALUES ($1, $2, $3, $4, $5) RETURNING *',
      [req.user.id, value.amount, value.type, value.description, 'pending']
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const updateTransaction = async (req, res) => {
  try {
    const result = await req.app.locals.db.query(
      'UPDATE transactions SET description = $1, status = $2 WHERE id = $3 AND user_id = $4 RETURNING *',
      [req.body.description, req.body.status, req.params.id, req.user.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

const deleteTransaction = async (req, res) => {
  try {
    const result = await req.app.locals.db.query(
      'DELETE FROM transactions WHERE id = $1 AND user_id = $2 RETURNING id',
      [req.params.id, req.user.id]
    );
    if (result.rows.length === 0) return res.status(404).json({ error: 'Not found' });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

module.exports = { getTransactions, getTransaction, createTransaction, updateTransaction, deleteTransaction };
