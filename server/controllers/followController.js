const Follow = require('../models/Follow');
const User = require('../models/User');

// @route   POST /follow/:authorId
// @desc    Toggle follow for an author (Protected)
exports.toggleFollow = async (req, res) => {
  const { authorId } = req.params;

  if (authorId === req.user.id) {
    return res.status(400).json({ message: 'You cannot follow yourself' });
  }

  try {
    const author = await User.findById(authorId);
    if (!author) {
      return res.status(404).json({ message: 'Author not found' });
    }

    const existingFollow = await Follow.findOne({
      follower: req.user.id,
      following: authorId,
    });

    if (existingFollow) {
      await existingFollow.deleteOne();
      return res.json({ following: false, message: 'Author unfollowed' });
    } else {
      const newFollow = new Follow({
        follower: req.user.id,
        following: authorId,
      });
      await newFollow.save();
      return res.status(201).json({ following: true, message: 'Author followed' });
    }
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   GET /follow/status/:authorId
// @desc    Check if the current user follows an author (Protected)
exports.getFollowStatus = async (req, res) => {
  try {
    const existingFollow = await Follow.findOne({
      follower: req.user.id,
      following: req.params.authorId,
    });
    return res.json({ following: !!existingFollow });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   GET /follow/followers/:userId
// @desc    Get a user's followers
exports.getFollowers = async (req, res) => {
  try {
    const follows = await Follow.find({ following: req.params.userId })
      .populate('follower', 'username email profileImage bio')
      .sort({ createdAt: -1 });

    res.json(follows.map((f) => f.follower));
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   GET /follow/following/:userId
// @desc    Get the list of authors a user follows
exports.getFollowing = async (req, res) => {
  try {
    const follows = await Follow.find({ follower: req.params.userId })
      .populate('following', 'username email profileImage bio')
      .sort({ createdAt: -1 });

    res.json(follows.map((f) => f.following));
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};
