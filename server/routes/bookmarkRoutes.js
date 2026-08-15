const express = require('express');
const router = express.Router();
const { toggleBookmark, getUserBookmarks, checkBookmark } = require('../controllers/bookmarkController');
const auth = require('../middleware/auth');

// @route   GET /bookmark/check/:storyId (Protected)
router.get('/check/:storyId', auth, checkBookmark);

// @route   POST /bookmark (Protected)
router.post('/', auth, toggleBookmark);

// @route   GET /bookmark (Protected)
router.get('/', auth, getUserBookmarks);

module.exports = router;
