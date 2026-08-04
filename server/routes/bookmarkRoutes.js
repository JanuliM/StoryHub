const express = require('express');
const router = express.Router();
const { toggleBookmark, getUserBookmarks } = require('../controllers/bookmarkController');
const auth = require('../middleware/auth');

// @route   POST /bookmark (Protected)
router.post('/', auth, toggleBookmark);

// @route   GET /bookmark (Protected)
router.get('/', auth, getUserBookmarks);

module.exports = router;
