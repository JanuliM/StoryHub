const mongoose = require('mongoose');

const CommentSchema = new mongoose.Schema(
  {
    storyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Story',
      required: true,
    },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    comment: {
      type: String,
      required: true,
      trim: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Comment', CommentSchema);
