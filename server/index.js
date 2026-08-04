require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Ensure models are registered with Mongoose
require('./models/User');
require('./models/Story');
require('./models/Comment');
require('./models/Bookmark');

const authRoutes = require('./routes/authRoutes');
const storyRoutes = require('./routes/storyRoutes');
const commentRoutes = require('./routes/commentRoutes');
const bookmarkRoutes = require('./routes/bookmarkRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

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

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});
