const express = require('express');
const cors = require('cors');
const redis = require('redis');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Redis client
const redisClient = redis.createClient({
  url: `redis://${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));
redisClient.connect();

// Health check
app.get('/health', async (req, res) => {
  try {
    await redisClient.ping();
    res.status(200).json({ 
      status: 'OK', 
      timestamp: new Date().toISOString(),
      service: 'cart-service'
    });
  } catch (error) {
    res.status(503).json({ 
      status: 'Service Unavailable', 
      error: error.message 
    });
  }
});

// Get cart for user
app.get('/cart/:userId', async (req, res) => {
  try {
    const cart = await redisClient.get(`cart:${req.params.userId}`);
    res.json(cart ? JSON.parse(cart) : { items: [] });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add item to cart
app.post('/cart/:userId/items', async (req, res) => {
  try {
    const { productId, quantity, productName, price } = req.body;
    const cartKey = `cart:${req.params.userId}`;
    
    let cart = await redisClient.get(cartKey);
    cart = cart ? JSON.parse(cart) : { items: [] };
    
    const existingItemIndex = cart.items.findIndex(item => item.productId === productId);
    
    if (existingItemIndex > -1) {
      cart.items[existingItemIndex].quantity += quantity;
    } else {
      cart.items.push({ productId, quantity, productName, price });
    }
    
    await redisClient.set(cartKey, JSON.stringify(cart), { EX: 86400 }); // 24h expiry
    
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Remove item from cart
app.delete('/cart/:userId/items/:productId', async (req, res) => {
  try {
    const cartKey = `cart:${req.params.userId}`;
    let cart = await redisClient.get(cartKey);
    
    if (!cart) {
      return res.status(404).json({ error: 'Cart not found' });
    }
    
    cart = JSON.parse(cart);
    cart.items = cart.items.filter(item => item.productId !== req.params.productId);
    
    await redisClient.set(cartKey, JSON.stringify(cart), { EX: 86400 });
    
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Cart service running on port ${port}`);
});
