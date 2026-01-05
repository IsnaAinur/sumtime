-- Script to clear all order data for fresh testing
-- Run this script in Supabase SQL Editor

-- Disable foreign key constraints temporarily
ALTER TABLE order_items DROP CONSTRAINT order_items_order_id_fkey;

-- Clear order items first (due to foreign key constraint)
DELETE FROM order_items;

-- Clear orders
DELETE FROM orders;

-- Reset order_id sequence by clearing and recreating (optional)
-- This ensures order IDs start fresh
-- Note: The generate_order_id function will handle this automatically

-- Re-enable foreign key constraints
ALTER TABLE order_items ADD CONSTRAINT order_items_order_id_fkey
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;

-- Verify tables are empty
SELECT COUNT(*) as orders_count FROM orders;
SELECT COUNT(*) as order_items_count FROM order_items;
