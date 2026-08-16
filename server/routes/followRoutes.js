const express = require('express');
const router = express.Router();
const {
  toggleFollow,
  getFollowStatus,
  getFollowers,
  getFollowing,
} = require('../controllers/followController');
const auth = require('../middleware/auth');

// @route   GET /follow/status/:authorId (Protected)
router.get('/status/:authorId', auth, getFollowStatus);

// @route   GET /follow/followers/:userId
router.get('/followers/:userId', getFollowers);

// @route   GET /follow/following/:userId
router.get('/following/:userId', getFollowing);

// @route   POST /follow/:authorId (Protected)
router.post('/:authorId', auth, toggleFollow);

module.exports = router;
