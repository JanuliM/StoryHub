const express = require('express');
const router = express.Router();
const {
  getStories,
  createStory,
  getStoryById,
  updateStory,
  deleteStory,
  getTrendingStories,
  incrementReads,
} = require('../controllers/storyController');
const auth = require('../middleware/auth');

// @route   GET /stories & POST /stories
router.get('/', getStories);
router.post('/', auth, createStory);

// @route   GET /stories/trending
router.get('/trending', getTrendingStories);

// @route   GET /stories/:id, PUT /stories/:id, DELETE /stories/:id
router.get('/:id', getStoryById);
router.put('/:id/read', incrementReads);
router.put('/:id', auth, updateStory);
router.delete('/:id', auth, deleteStory);

module.exports = router;
