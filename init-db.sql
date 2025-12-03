-- Create products table
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category VARCHAR(100),
    stock_quantity INTEGER DEFAULT 0,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO products (name, description, price, category, stock_quantity, image_url) VALUES
('Laptop', 'High-performance laptop with 16GB RAM', 999.99, 'Electronics', 50, '/images/laptop.jpg'),
('Smartphone', 'Latest smartphone with 5G', 699.99, 'Electronics', 100, '/images/phone.jpg'),
('Headphones', 'Wireless noise-cancelling headphones', 199.99, 'Electronics', 75, '/images/headphones.jpg'),
('Desk Chair', 'Ergonomic office chair', 249.99, 'Furniture', 30, '/images/chair.jpg'),
('Coffee Maker', 'Programmable coffee maker', 89.99, 'Home Appliances', 60, '/images/coffee-maker.jpg');
