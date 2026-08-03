const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// @route   POST /register
// @desc    Register a new user
exports.registerUser = async (req, res) => {
  const { username, email, password, profileImage } = req.body;

  // Basic Validation
  if (!username || !email || !password) {
    return res.status(400).json({ message: 'Please provide username, email, and password' });
  }

  try {
    // Check if user exists
    let user = await User.findOne({ $or: [{ email }, { username }] });
    if (user) {
      return res.status(400).json({ message: 'Username or email already exists' });
    }

    // Create user instance
    user = new User({
      username,
      email,
      password,
      profileImage: profileImage || '',
    });

    // Hash password securely with bcrypt
    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);

    await user.save();

    // Create JWT Token payload
    const payload = {
      user: {
        id: user.id,
        username: user.username,
      },
    };

    // Generate JWT Token
    jwt.sign(
      payload,
      process.env.JWT_SECRET || 'supersecretstoryhubkey12345',
      { expiresIn: '7d' },
      (err, token) => {
        if (err) throw err;
        res.status(201).json({
          token,
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            profileImage: user.profileImage,
          },
        });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   POST /login
// @desc    Authenticate user & get token
exports.loginUser = async (req, res) => {
  const { email, password } = req.body;

  // Basic Validation
  if (!email || !password) {
    return res.status(400).json({ message: 'Please provide email and password' });
  }

  try {
    // Check for user by email
    let user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Check password match with bcrypt
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    // Create JWT Token payload
    const payload = {
      user: {
        id: user.id,
        username: user.username,
      },
    };

    // Generate JWT Token
    jwt.sign(
      payload,
      process.env.JWT_SECRET || 'supersecretstoryhubkey12345',
      { expiresIn: '7d' },
      (err, token) => {
        if (err) throw err;
        res.json({
          token,
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            profileImage: user.profileImage,
          },
        });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};
