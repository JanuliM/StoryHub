const Story = require('../models/Story');

// @route   GET /stories
// @desc    Get all stories
exports.getStories = async (req, res) => {
  try {
    const stories = await Story.find().sort({ createdAt: -1 });
    res.json(stories);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// @route   POST /stories
// @desc    Create a new story (Protected)
exports.createStory = async (req, res) => {
  const { title, content, readTime } = req.body;

  try {
    const newStory = new Story({
      title,
      content,
      readTime,
      author: req.user.id,
      authorName: req.user.username,
    });

    const story = await newStory.save();
    res.status(201).json(story);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
