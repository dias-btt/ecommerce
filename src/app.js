// src/app.js

const express = require('express');
const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
app.use(express.json());

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.error('❌ MongoDB connection error:', err));

// Authentication routes
const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

// Product routes
const productRoutes = require('./routes/product');
app.use('/api/products', productRoutes);

//Interaction routes
const interactionRoutes = require('./routes/interaction');
app.use('/api/interactions', interactionRoutes);

app.get('/', (req, res) => {
  res.send('🏪 Welcome to the E-commerce Backend API');
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

