const Bookmark = require('../models/Bookmark');
const Story = require('../models/Story');

// @route   POST /bookmark
// @desc    Toggle bookmark for a story (Protected)
exports.toggleBookmark = async (req, res) => {
  const { storyId } = req.body;

  if (!storyId) {
    return res.status(400).json({ message: 'storyId is required' });
  }

  try {
    const story = await Story.findById(storyId);
    if (!story) {
      return res.status(404).json({ message: 'Story not found' });
    }

    const existingBookmark = await Bookmark.findOne({
      userId: req.user.id,
      storyId,
    });

    if (existingBookmark) {
      await existingBookmark.deleteOne();
      return res.json({ bookmarked: false, message: 'Bookmark removed' });
    } else {
      const newBookmark = new Bookmark({
        userId: req.user.id,
        storyId,
      });
      await newBookmark.save();
      return res.status(201).json({ bookmarked: true, message: 'Story bookmarked' });
    }
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   GET /bookmark
// @desc    Get user's bookmarked stories (Protected)
exports.getUserBookmarks = async (req, res) => {
  try {
    const bookmarks = await Bookmark.find({ userId: req.user.id })
      .populate({
        path: 'storyId',
        populate: { path: 'author', select: 'username email profileImage' },
      })
      .sort({ createdAt: -1 });

    res.json(bookmarks);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};
