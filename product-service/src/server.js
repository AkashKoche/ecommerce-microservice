const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Database connection
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ 
      status: 'OK', 
      timestamp: new Date().toISOString(),
      service: 'product-service'
    });
  } catch (error) {
    res.status(503).json({ 
      status: 'Service Unavailable', 
      error: error.message 
    });
  }
});

// Get all products
app.get('/products', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT id, name, description, price, category, stock_quantity, image_url FROM products WHERE stock_quantity > 0'
    );
    res.json(rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get product by ID
app.get('/products/:id', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT id, name, description, price, category, stock_quantity, image_url FROM products WHERE id = $1',
      [req.params.id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Update product stock
app.patch('/products/:id/stock', async (req, res) => {
  try {
    const { quantity } = req.body;
    const { rows } = await pool.query(
      'UPDATE products SET stock_quantity = stock_quantity - $1 WHERE id = $2 RETURNING id, stock_quantity',
      [quantity, req.params.id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
    }
    
    res.json(rows[0]);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Product service running on port ${port}`);
});
