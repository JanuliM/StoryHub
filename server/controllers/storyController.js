const Story = require('../models/Story');

// @route   GET /stories
// @desc    Fetch all recent stories with author details
exports.getStories = async (req, res) => {
  try {
    const stories = await Story.find()
      .populate('author', 'username email profileImage')
      .sort({ createdAt: -1 });

    res.json(stories);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   POST /stories
// @desc    Create a new story post (Protected)
exports.createStory = async (req, res) => {
  const { title, category, content, readTime } = req.body;

  if (!title || !content) {
    return res.status(400).json({ message: 'Title and content are required' });
  }

  try {
    const newStory = new Story({
      title,
      category: category || 'Fantasy',
      content,
      readTime: readTime || '5 min read',
      author: req.user.id,
      authorName: req.user.username,
    });

    const story = await newStory.save();
    await story.populate('author', 'username email profileImage');

    res.status(201).json(story);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   GET /stories/:id
// @desc    Get a single story by ID with author details
exports.getStoryById = async (req, res) => {
  try {
    const story = await Story.findById(req.params.id).populate(
      'author',
      'username email profileImage'
    );

    if (!story) {
      return res.status(404).json({ message: 'Story not found' });
    }

    res.json(story);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Story not found' });
    }
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   PUT /stories/:id
// @desc    Edit a story (Protected - Owner only)
exports.updateStory = async (req, res) => {
  const { title, category, content, readTime } = req.body;

  try {
    let story = await Story.findById(req.params.id);

    if (!story) {
      return res.status(404).json({ message: 'Story not found' });
    }

    // Check user ownership
    if (story.author.toString() !== req.user.id) {
      return res.status(401).json({ message: 'User not authorized to edit this story' });
    }

    if (title) story.title = title;
    if (category) story.category = category;
    if (content) story.content = content;
    if (readTime) story.readTime = readTime;

    story = await story.save();
    await story.populate('author', 'username email profileImage');

    res.json(story);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Story not found' });
    }
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   DELETE /stories/:id
// @desc    Delete a story (Protected - Owner only)
exports.deleteStory = async (req, res) => {
  try {
    const story = await Story.findById(req.params.id);

    if (!story) {
      return res.status(404).json({ message: 'Story not found' });
    }

    // Check user ownership
    if (story.author.toString() !== req.user.id) {
      return res.status(401).json({ message: 'User not authorized to delete this story' });
    }

    await story.deleteOne();

    res.json({ message: 'Story removed successfully' });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Story not found' });
    }
    res.status(500).json({ message: 'Server Error' });
  }
};
