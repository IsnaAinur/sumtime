-- Test script to check admin login setup
-- Run this in Supabase SQL Editor

-- Check if admin@gmail.com exists in auth.users
SELECT 'Auth User Check:' as check_type, id, email, created_at
FROM auth.users
WHERE email = 'admin@gmail.com'

UNION ALL

-- Check if admin@gmail.com exists in users table
SELECT 'Users Table Check:' as check_type, id, username, email, role
FROM users
WHERE email = 'admin@gmail.com'

UNION ALL

-- Check if admin@sumtime.com exists (original admin)
SELECT 'Original Admin Check:' as check_type, id, username, email, role
FROM users
WHERE email = 'admin@sumtime.com';

-- Additional verification: Check RLS policies
SELECT 'RLS Policies:' as check_type, schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'users' AND policyname LIKE '%admin%';

-- Check recent login attempts (if audit logging is enabled)
-- SELECT 'Recent Logins:' as check_type, * FROM audit_logs WHERE action = 'login' ORDER BY created_at DESC LIMIT 5;
