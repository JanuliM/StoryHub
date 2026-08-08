const express = require('express');
const router = express.Router();
const { addComment, getCommentsByStoryId, deleteComment } = require('../controllers/commentController');
const auth = require('../middleware/auth');

// @route   POST /comments (Protected)
router.post('/', auth, addComment);

// @route   GET /comments/:storyId
router.get('/:storyId', getCommentsByStoryId);

// @route   DELETE /comments/:id (Protected)
router.delete('/:id', auth, deleteComment);

module.exports = router;
