const express = require('express');
const router = express.Router();
const { registerUser, loginUser } = require('../controllers/authController');

// @route   POST /register
router.post('/register', registerUser);

// @route   POST /login
router.post('/login', loginUser);

module.exports = router;
