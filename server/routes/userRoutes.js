const express = require('express');
const router = express.Router();
const { getUserProfile, updateProfile } = require('../controllers/userController');
const auth = require('../middleware/auth');

// @route   PUT /users/me (Protected)
router.put('/me', auth, updateProfile);

// @route   GET /users/:id
router.get('/:id', getUserProfile);

module.exports = router;
