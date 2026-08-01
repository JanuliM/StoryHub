const jwt = require('jsonwebtoken');

module.exports = function (req, res, next) {
  // Get token from header
  const authHeader = req.header('Authorization');

  // Check if no token
  if (!authHeader) {
    return res.status(401).json({ message: 'No authorization token, access denied' });
  }

  try {
    const token = authHeader.split(' ')[1] || authHeader;
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'supersecretstoryhubkey12345');
    req.user = decoded.user;
    next();
  } catch (err) {
    res.status(401).json({ message: 'Token is not valid' });
  }
};
