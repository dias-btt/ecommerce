// src/routes/interaction.js

const express = require('express');
const Interaction = require('../models/Interaction');

const router = express.Router();

// Log Interaction
router.post('/', async (req, res) => {
  try {
    const { userId, productId, interactionType } = req.body;

    const newInteraction = new Interaction({ userId, productId, interactionType });
    await newInteraction.save();
    res.status(201).json({ message: 'Interaction logged successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
