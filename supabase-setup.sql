-- =====================================================
-- DevSnaps Supabase Database Schema
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- PROFILES TABLE
-- =====================================================
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  github_username TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- =====================================================
-- SNAPS TABLE
-- =====================================================
CREATE TABLE snaps (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  code_content TEXT NOT NULL,
  language TEXT NOT NULL,
  image_url TEXT NOT NULL,
  theme_name TEXT,
  likes_count INTEGER DEFAULT 0,
  views_count INTEGER DEFAULT 0,
  is_public BOOLEAN DEFAULT true,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS on snaps
ALTER TABLE snaps ENABLE ROW LEVEL SECURITY;

-- Snaps policies
CREATE POLICY "Public snaps are viewable by everyone"
  ON snaps FOR SELECT
  USING (is_public = true);

CREATE POLICY "Users can view their own snaps"
  ON snaps FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Authenticated users can insert snaps"
  ON snaps FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own snaps"
  ON snaps FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own snaps"
  ON snaps FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- LIKES TABLE (for future feature)
-- =====================================================
CREATE TABLE likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  snap_id UUID REFERENCES snaps(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, snap_id)
);

-- Enable RLS on likes
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- Likes policies
CREATE POLICY "Likes are viewable by everyone"
  ON likes FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can like snaps"
  ON likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike snaps"
  ON likes FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- INDEXES for Performance
-- =====================================================
CREATE INDEX idx_snaps_user_id ON snaps(user_id);
CREATE INDEX idx_snaps_created_at ON snaps(created_at DESC);
CREATE INDEX idx_snaps_is_public ON snaps(is_public);
CREATE INDEX idx_likes_snap_id ON likes(snap_id);
CREATE INDEX idx_likes_user_id ON likes(user_id);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'user_name',
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_snaps_updated_at
  BEFORE UPDATE ON snaps
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- STORAGE BUCKET SETUP
-- =====================================================
-- Run this in the Supabase Dashboard Storage section:
-- 1. Create a bucket named "snap-images"
-- 2. Make it public
-- 3. Set the following policies:

-- Storage policies (run in SQL editor after creating bucket)
INSERT INTO storage.buckets (id, name, public)
VALUES ('snap-images', 'snap-images', true)
ON CONFLICT (id) DO UPDATE SET public = true;

-- Allow authenticated users to upload images
CREATE POLICY "Authenticated users can upload snap images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'snap-images');

-- Allow users to update their own images
CREATE POLICY "Users can update their own snap images"
ON storage.objects FOR UPDATE
TO authenticated
USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow users to delete their own images
CREATE POLICY "Users can delete their own snap images"
ON storage.objects FOR DELETE
TO authenticated
USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow public access to view images
CREATE POLICY "Public can view snap images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'snap-images');
