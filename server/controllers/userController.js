const User = require('../models/User');
const Story = require('../models/Story');
const Follow = require('../models/Follow');

// @route   GET /users/:id
// @desc    Get a user's public profile with stats
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('username email profileImage bio createdAt');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    const [storiesCount, followersCount, followingCount] = await Promise.all([
      Story.countDocuments({ author: user.id }),
      Follow.countDocuments({ following: user.id }),
      Follow.countDocuments({ follower: user.id }),
    ]);

    res.json({
      id: user.id,
      username: user.username,
      email: user.email,
      profileImage: user.profileImage,
      bio: user.bio,
      createdAt: user.createdAt,
      storiesCount,
      followersCount,
      followingCount,
    });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ message: 'User not found' });
    }
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   PUT /users/me
// @desc    Update the current user's username/bio (Protected)
exports.updateProfile = async (req, res) => {
  const { username, bio } = req.body;

  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    if (username && username.trim() !== user.username) {
      const existing = await User.findOne({ username: username.trim() });
      if (existing) {
        return res.status(400).json({ message: 'Username is already taken' });
      }
      user.username = username.trim();
    }

    if (bio !== undefined) {
      user.bio = bio;
    }

    await user.save();

    res.json({
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        profileImage: user.profileImage,
        bio: user.bio,
      },
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};
