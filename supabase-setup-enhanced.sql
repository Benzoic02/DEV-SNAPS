-- =====================================================
-- DevSnaps Complete Supabase Database Schema
-- High-Performance Setup with RLS and Storage
-- =====================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- =====================================================
-- PROFILES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  github_username TEXT,
  bio TEXT,
  website_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON profiles;
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- =====================================================
-- SNAPS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS snaps (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  code_content TEXT NOT NULL,
  language TEXT NOT NULL,
  image_url TEXT NOT NULL,
  theme_name TEXT,
  terminal_theme TEXT,
  font_family TEXT,
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
DROP POLICY IF EXISTS "Public snaps are viewable by everyone" ON snaps;
CREATE POLICY "Public snaps are viewable by everyone"
  ON snaps FOR SELECT
  USING (is_public = true);

DROP POLICY IF EXISTS "Users can view their own snaps" ON snaps;
CREATE POLICY "Users can view their own snaps"
  ON snaps FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Authenticated users can insert snaps" ON snaps;
CREATE POLICY "Authenticated users can insert snaps"
  ON snaps FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own snaps" ON snaps;
CREATE POLICY "Users can update their own snaps"
  ON snaps FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own snaps" ON snaps;
CREATE POLICY "Users can delete their own snaps"
  ON snaps FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- LIKES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS likes (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  snap_id UUID REFERENCES snaps(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(user_id, snap_id)
);

-- Enable RLS on likes
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

-- Likes policies
DROP POLICY IF EXISTS "Likes are viewable by everyone" ON likes;
CREATE POLICY "Likes are viewable by everyone"
  ON likes FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Authenticated users can like snaps" ON likes;
CREATE POLICY "Authenticated users can like snaps"
  ON likes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can unlike snaps" ON likes;
CREATE POLICY "Users can unlike snaps"
  ON likes FOR DELETE
  USING (auth.uid() = user_id);

-- =====================================================
-- INDEXES for High Performance
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_snaps_user_id ON snaps(user_id);
CREATE INDEX IF NOT EXISTS idx_snaps_created_at ON snaps(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_snaps_is_public ON snaps(is_public) WHERE is_public = true;
CREATE INDEX IF NOT EXISTS idx_snaps_language ON snaps(language);
CREATE INDEX IF NOT EXISTS idx_snaps_tags ON snaps USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_likes_snap_id ON likes(snap_id);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);

-- Text search index for snaps
CREATE INDEX IF NOT EXISTS idx_snaps_search ON snaps USING GIN(
  to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, ''))
);

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, full_name, avatar_url, github_username)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'user_name', NEW.raw_user_meta_data->>'preferred_username'),
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.raw_user_meta_data->>'user_name'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop existing trigger if exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if exist
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
DROP TRIGGER IF EXISTS update_snaps_updated_at ON snaps;

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_snaps_updated_at
  BEFORE UPDATE ON snaps
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to increment likes count
CREATE OR REPLACE FUNCTION increment_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE snaps
  SET likes_count = likes_count + 1
  WHERE id = NEW.snap_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to decrement likes count
CREATE OR REPLACE FUNCTION decrement_likes_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE snaps
  SET likes_count = likes_count - 1
  WHERE id = OLD.snap_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if exist
DROP TRIGGER IF EXISTS on_like_created ON likes;
DROP TRIGGER IF EXISTS on_like_deleted ON likes;

-- Triggers for likes count
CREATE TRIGGER on_like_created
  AFTER INSERT ON likes
  FOR EACH ROW EXECUTE FUNCTION increment_likes_count();

CREATE TRIGGER on_like_deleted
  AFTER DELETE ON likes
  FOR EACH ROW EXECUTE FUNCTION decrement_likes_count();

-- =====================================================
-- STORAGE BUCKET SETUP
-- =====================================================

-- Create snap-images bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'snap-images',
  'snap-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp', 'image/gif'];

-- Drop existing storage policies
DROP POLICY IF EXISTS "Authenticated users can upload snap images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own snap images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own snap images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view snap images" ON storage.objects;

-- Storage policies for authenticated uploads
CREATE POLICY "Authenticated users can upload snap images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'snap-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can update their own images
CREATE POLICY "Users can update their own snap images"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'snap-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Users can delete their own images
CREATE POLICY "Users can delete their own snap images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'snap-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Public can view all snap images
CREATE POLICY "Public can view snap images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'snap-images');

-- =====================================================
-- HELPFUL QUERIES
-- =====================================================

-- Get popular snaps (most liked)
-- SELECT s.*, p.username, p.avatar_url
-- FROM snaps s
-- JOIN profiles p ON s.user_id = p.id
-- WHERE s.is_public = true
-- ORDER BY s.likes_count DESC, s.created_at DESC
-- LIMIT 20;

-- Get recent snaps
-- SELECT s.*, p.username, p.avatar_url
-- FROM snaps s
-- JOIN profiles p ON s.user_id = p.id
-- WHERE s.is_public = true
-- ORDER BY s.created_at DESC
-- LIMIT 20;

-- Search snaps by text
-- SELECT s.*, p.username, p.avatar_url
-- FROM snaps s
-- JOIN profiles p ON s.user_id = p.id
-- WHERE s.is_public = true
--   AND to_tsvector('english', s.title || ' ' || COALESCE(s.description, '')) @@ plainto_tsquery('english', 'your search term')
-- ORDER BY s.created_at DESC;
