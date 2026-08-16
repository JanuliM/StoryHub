const Story = require('../models/Story');
const { GoogleGenAI } = require('@google/genai');
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// @route   GET /stories
// @desc    Fetch all recent stories with author details
exports.getStories = async (req, res) => {
  try {
    const filter = req.query.author ? { author: req.query.author } : {};
    const stories = await Story.find(filter)
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
  const { title, category, content, readTime, coverUrl } = req.body;

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
      coverUrl: coverUrl || '',
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

// @route   PUT /stories/:id/read
// @desc    Increment the read count for a story
exports.incrementReads = async (req, res) => {
  try {
    let story = await Story.findById(req.params.id);

    if (!story) {
      return res.status(404).json({ message: 'Story not found' });
    }

    story.reads = (story.reads || 0) + 1;
    await story.save();

    res.json({ message: 'Reads incremented', reads: story.reads });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Story not found' });
    }
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   GET /stories/trending
// @desc    Fetch top 10 trending stories based on reads
exports.getTrendingStories = async (req, res) => {
  try {
    const stories = await Story.find()
      .populate('author', 'username email profileImage')
      .sort({ reads: -1 })
      .limit(10);

    res.json(stories);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @route   POST /stories/ai-continue
// @desc    Generate a story continuation or plot ideas (Protected)
exports.continueStory = async (req, res) => {
  const { content, category, mode } = req.body;

  if (!content || !content.trim()) {
    return res.status(400).json({ message: 'Write a bit of your story first' });
  }

  try {
    const words = content.trim().split(/\s+/);
    const recentContent = words.slice(-400).join(' '); // last ~400 words, keeps cost/tokens down

    const instruction = mode === 'brainstorm'
      ? 'Suggest 3 short, distinct plot directions the story could go next. Number them 1-3, one sentence each.'
      : "Write the next paragraph, matching the tone and style above. Do not repeat what's already written. Keep it to 3-5 sentences.";

    const prompt = `You are a creative writing assistant helping an author continue their story.

Genre: ${category || 'General fiction'}
Story so far:
"""
${recentContent}
"""

${instruction}`;

    const response = await ai.models.generateContent({
      model: 'gemini-flash-latest',
      contents: prompt,
    });

    res.json({ suggestion: response.text });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ message: 'AI request failed' });
  }
};
