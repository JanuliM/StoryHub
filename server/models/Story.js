const mongoose = require('mongoose');

const StorySchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
      trim: true,
    },
    category: {
      type: String,
      required: true,
      enum: ['Fantasy', 'Romance', 'Horror', 'Mystery', 'Adventure', 'Sci-Fi', 'Comedy'],
      default: 'Fantasy',
    },
    content: {
      type: String,
      required: true,
    },
    author: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    authorName: {
      type: String,
    },
    readTime: {
      type: String,
      default: '5 min read',
    },
    coverUrl: {
      type: String,
      default: '',
    },
    reads: {
      type: Number,
      default: 0,
    },
    likes: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Story', StorySchema);
