// src/routes/product.js

const express = require('express');
const Product = require('../models/Product');
const Interaction = require('../models/Interaction');

const router = express.Router();

// Add a New Product
router.post('/', async (req, res) => {
  try {
    const products = req.body;
    if (!Array.isArray(products)) {
      return res.status(400).json({ message: 'Request body must be an array of products' });
    }

    const insertedProducts = await Product.insertMany(products);
    res.status(201).json({ message: `${insertedProducts.length} products inserted successfully`, products: insertedProducts });
  } catch (error) {
    console.error('Error inserting products:', error);
    res.status(500).json({ message: 'Server error' });
  }
});


// DELETE route to remove all products
router.delete('/', async (req, res) => {
  try {
    const result = await Product.deleteMany({});
    res.status(200).json({ message: `${result.deletedCount} products deleted successfully` });
  } catch (error) {
    console.error('Error deleting products:', error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get a Product by ID
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ message: 'Product not found' });
    res.json(product);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Update a Product by ID
router.put('/:id', async (req, res) => {
  try {
    const updatedProduct = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedProduct) return res.status(404).json({ message: 'Product not found' });
    res.json(updatedProduct);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Delete a Product by ID
router.delete('/:id', async (req, res) => {
  try {
    const deletedProduct = await Product.findByIdAndDelete(req.params.id);
    if (!deletedProduct) return res.status(404).json({ message: 'Product not found' });
    res.json({ message: 'Product deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
});

// Get All Products with Search and Filtering
router.get('/', async (req, res) => {
  console.log("Products route called"); // This should log every time the route is accessed
  try {
    const { name, category } = req.query;

    console.log("Received name parameter:", name);
    console.log("Received category parameter:", category);

    const query = {};
    
    if (name) {
      query.name = { $regex: new RegExp(name, 'i') };
    }
    if (category) {
      query.category = { $regex: new RegExp(category, 'i') };
    }

    console.log("Constructed Query Object:", query);

    const products = await Product.find(query);
    res.json(products);
  } catch (error) {
    console.error("Error fetching products:", error);
    res.status(500).json({ message: 'Server error' });
  }
});


// Get Recommendations for a User
router.get('/recommendations/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    console.log("Fetching recommendations for userId:", userId);

    // Fetch user's interactions and get the most viewed/liked category
    const interactions = await Interaction.find({ userId });
    console.log("User interactions found:", interactions.length);

    const categoryCounts = {};

    for (const interaction of interactions) {
      const product = await Product.findById(interaction.productId);
      if (product && product.category) {
        categoryCounts[product.category] = (categoryCounts[product.category] || 0) + 1;
      }
    }

    console.log("Category counts:", categoryCounts);

    // Find the top category
    const topCategory = Object.keys(categoryCounts).reduce((a, b) => categoryCounts[a] > categoryCounts[b] ? a : b, null);
    if (!topCategory) {
      console.log("No top category found for user interactions.");
      return res.status(404).json({ message: 'No recommendations available' });
    }

    const excludedProductIds = interactions.map(interaction => interaction.productId);
    const recommendations = await Product.find({ category: topCategory, _id: { $nin: excludedProductIds } });

    console.log("Recommendations found:", recommendations.length);
    res.json(recommendations);
  } catch (error) {
    console.error("Error fetching recommendations:", error);
    res.status(500).json({ message: 'Server error' });
  }
});


module.exports = router;
