require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Ensure models are registered with Mongoose
require('./models/User');
require('./models/Story');
require('./models/Comment');
require('./models/Bookmark');
require('./models/Follow');

const authRoutes = require('./routes/authRoutes');
const storyRoutes = require('./routes/storyRoutes');
const commentRoutes = require('./routes/commentRoutes');
const bookmarkRoutes = require('./routes/bookmarkRoutes');
const followRoutes = require('./routes/followRoutes');
const userRoutes = require('./routes/userRoutes');

const app = express();

// Middleware
app.use(cors());
// Raised from the 100kb default: story covers and profile pictures are sent as base64 JSON
app.use(express.json({ limit: '10mb' }));

// Connect to MongoDB
const MONGODB_URI = (process.env.MONGODB_URI || 'mongodb://localhost:27017/storyhub').trim();
mongoose
  .connect(MONGODB_URI)
  .then(() => console.log('Successfully connected to MongoDB.'))
  .catch((err) => console.error('MongoDB connection error:', err));

// Routes
app.use('/', authRoutes);
app.use('/stories', storyRoutes);
app.use('/comments', commentRoutes);
app.use('/bookmark', bookmarkRoutes);
app.use('/follow', followRoutes);
app.use('/users', userRoutes);

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});
