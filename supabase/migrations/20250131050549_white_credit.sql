/*
  # Create admin and blog tables

  1. New Tables
    - `admins`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `created_at` (timestamp)
    
    - `blog_posts`
      - `id` (uuid, primary key)
      - `title` (text)
      - `slug` (text, unique)
      - `content` (text)
      - `excerpt` (text)
      - `published` (boolean)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
      - `author_id` (uuid, references auth.users)

  2. Security
    - Enable RLS on both tables
    - Add policies for admin access
*/

-- Create admins table
CREATE TABLE IF NOT EXISTS admins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Create blog_posts table
CREATE TABLE IF NOT EXISTS blog_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text UNIQUE NOT NULL,
  content text NOT NULL,
  excerpt text,
  published boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  author_id uuid REFERENCES auth.users NOT NULL
);

-- Enable RLS
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;

-- Policies for admins table
CREATE POLICY "Admins can read admin list"
  ON admins
  FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ));

-- Policies for blog_posts table
CREATE POLICY "Anyone can read published posts"
  ON blog_posts
  FOR SELECT
  TO anon, authenticated
  USING (published = true);

CREATE POLICY "Admins have full access to posts"
  ON blog_posts
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM admins WHERE user_id = auth.uid()
  ));