-- Delete records from order_items where the parent order has a random ID (length != 9)
DELETE FROM order_items
WHERE order_id IN (
  SELECT id FROM orders WHERE LENGTH(order_id) <> 9
);

-- Delete records from orders where order_id is random (length != 9)
DELETE FROM orders
WHERE LENGTH(order_id) <> 9;
