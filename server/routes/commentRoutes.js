const express = require('express');
const router = express.Router();
const { addComment, getCommentsByStoryId } = require('../controllers/commentController');
const auth = require('../middleware/auth');

// @route   POST /comments (Protected)
router.post('/', auth, addComment);

// @route   GET /comments/:storyId
router.get('/:storyId', getCommentsByStoryId);

module.exports = router;
