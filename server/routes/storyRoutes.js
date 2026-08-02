const express = require('express');
const router = express.Router();
const { getStories, createStory } = require('../controllers/storyController');
const auth = require('../middleware/auth');

// @route   GET /stories
router.get('/', getStories);

// @route   POST /stories
router.post('/', auth, createStory);

module.exports = router;
