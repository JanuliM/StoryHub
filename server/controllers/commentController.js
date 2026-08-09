const Comment = require('../models/Comment');
const Story = require('../models/Story');

// @route   POST /comments
// @desc    Add a comment to a story (Protected)
exports.addComment = async (req, res) => {
  const { storyId, comment } = req.body;

  if (!storyId || !comment) {
    return res.status(400).json({ message: 'storyId and comment are required' });
  }

  try {
    const story = await Story.findById(storyId);
    if (!story) {
      return res.status(404).json({ message: 'Story not found' });
    }

    let newComment = new Comment({
      storyId,
      userId: req.user.id,
      comment,
    });

    await newComment.save();
    await newComment.populate('userId', 'username profileImage');

    res.status(201).json(newComment);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   GET /comments/:storyId
// @desc    Fetch all comments for a specific story
exports.getCommentsByStoryId = async (req, res) => {
  try {
    const comments = await Comment.find({ storyId: req.params.storyId })
      .populate('userId', 'username profileImage')
      .sort({ createdAt: -1 });

    res.json(comments);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   DELETE /comments/:id
// @desc    Delete a comment (Protected)
exports.deleteComment = async (req, res) => {
  try {
    const comment = await Comment.findById(req.params.id);
    if (!comment) {
      return res.status(404).json({ message: 'Comment not found' });
    }

    if (comment.userId.toString() !== req.user.id) {
      return res.status(401).json({ message: 'Not authorized to delete this comment' });
    }

    await comment.deleteOne();
    res.json({ message: 'Comment deleted successfully' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};
