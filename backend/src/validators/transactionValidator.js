const Joi = require('joi');

const transactionSchema = Joi.object({
  amount: Joi.number().positive().required(),
  type: Joi.string().valid('buy', 'sell', 'transfer').required(),
  description: Joi.string().max(500),
  status: Joi.string().valid('pending', 'completed', 'failed')
});

const validateTransaction = (data) => {
  return transactionSchema.validate(data);
};

module.exports = { validateTransaction };
