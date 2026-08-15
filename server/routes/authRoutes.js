const express = require('express');
const router = express.Router();
const { registerUser, loginUser, uploadProfileImage } = require('../controllers/authController');

// @route   POST /register
router.post('/register', registerUser);

// @route   POST /login
router.post('/login', loginUser);

// @route   PUT /profile-image
router.put('/profile-image', uploadProfileImage);

module.exports = router;
