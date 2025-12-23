-- Fix admin role for admin@gmail.com user
-- Run this script in Supabase SQL Editor

-- Update the role for admin@gmail.com to admin if it exists
UPDATE users
SET role = 'admin'
WHERE email = 'admin@gmail.com' AND role != 'admin';

-- If the user doesn't exist in users table but exists in auth.users,
-- you may need to insert them manually or they will be created on next login
-- through the registration process with the updated _determineRole function

-- Alternative approach: Check if user exists in auth and create profile
-- Note: This requires knowing the user ID from auth.users table
-- You can find the user ID by running:
-- SELECT id, email FROM auth.users WHERE email = 'admin@gmail.com';

-- Then manually insert if needed (replace 'USER_ID_HERE' with actual user ID):
-- INSERT INTO users (id, username, email, password_hash, role)
-- VALUES ('USER_ID_HERE', 'admin', 'admin@gmail.com', '', 'admin')
-- ON CONFLICT (id) DO UPDATE SET role = 'admin';

-- Verify the update
SELECT id, username, email, role
FROM users
WHERE email = 'admin@gmail.com';

-- Also check if user exists in auth.users
SELECT id, email, created_at
FROM auth.users
WHERE email = 'admin@gmail.com';
