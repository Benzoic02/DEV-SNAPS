# DevSnaps - Complete Setup & Deployment Guide

## 🎯 Overview

DevSnaps is a high-performance, full-stack web application built with:
- **Next.js 15** (App Router)
- **Supabase** (PostgreSQL + Auth + Storage)
- **Tailwind CSS** (with glassmorphism UI)
- **GitHub API** (for Staff Picks integration)
- **Vercel** (deployment platform)

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Supabase Setup](#supabase-setup)
3. [GitHub Setup (Staff Picks)](#github-setup-staff-picks)
4. [Local Development](#local-development)
5. [Vercel Deployment](#vercel-deployment)
6. [Environment Variables](#environment-variables)
7. [Testing](#testing)

---

## Prerequisites

- Node.js 18+ installed
- Supabase account (free tier works)
- GitHub account
- Vercel account (free tier works)
- Git installed

---

## Supabase Setup

### Step 1: Create a New Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Fill in:
   - **Name**: DevSnaps (or your choice)
   - **Database Password**: Generate a strong password (save it!)
   - **Region**: Choose closest to your users
4. Wait for project to initialize (~2 minutes)

### Step 2: Run Database Schema

1. In your Supabase project dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy the contents of `supabase-setup-enhanced.sql` from this repo
4. Paste it into the SQL editor
5. Click "Run" or press `Ctrl/Cmd + Enter`
6. Verify success - you should see tables created in the Table Editor

### Step 3: Configure GitHub OAuth

1. In Supabase dashboard, go to **Authentication** → **Providers**
2. Find **GitHub** and click to expand
3. Enable GitHub provider
4. Note down:
   - **Callback URL** (e.g., `https://yourproject.supabase.co/auth/v1/callback`)

### Step 4: Create GitHub OAuth App

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in:
   - **Application name**: DevSnaps
   - **Homepage URL**: `http://localhost:3000` (for development)
   - **Authorization callback URL**: Use the callback URL from Supabase (Step 3.3)
4. Click "Register application"
5. Note down **Client ID**
6. Generate a new **Client Secret** (save it immediately!)

### Step 5: Connect GitHub to Supabase

1. Go back to Supabase → Authentication → Providers → GitHub
2. Enter:
   - **Client ID** from Step 4.5
   - **Client Secret** from Step 4.6
3. Click "Save"

### Step 6: Verify Storage Bucket

1. In Supabase dashboard, go to **Storage**
2. Verify `snap-images` bucket exists (created by SQL script)
3. If not, create it manually:
   - Click "New bucket"
   - Name: `snap-images`
   - Public: ✓ Enabled
   - File size limit: 5MB
   - Allowed MIME types: `image/png, image/jpeg, image/jpg, image/webp, image/gif`

---

## GitHub Setup (Staff Picks)

### Step 1: Create a Public GitHub Repository

1. Create a new public repository (e.g., `devsnaps-favorites`)
2. Create a file named `favorites.json` in the root
3. Use this template:

```json
{
  "last_updated": "2026-03-09T00:00:00Z",
  "staff_picks": [
    {
      "id": "unique-id-1",
      "title": "Amazing Code Example",
      "description": "Description of why this snap is featured",
      "image_url": "https://your-cdn.com/image.jpg",
      "snap_url": "/snap/abc123",
      "author": "Username",
      "featured_date": "2026-03-09T00:00:00Z"
    }
  ]
}
```

### Step 2: Optional - Generate GitHub Token

For higher API rate limits (not required for public repos):

1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Click "Generate new token (classic)"
3. Select scopes: `public_repo` (read-only)
4. Generate and save the token

---

## Local Development

### Step 1: Clone and Install

```bash
cd devsnaps
npm install
```

### Step 2: Configure Environment Variables

Create `.env.local` in the project root:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://yourproject.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# GitHub Staff Picks
NEXT_PUBLIC_GITHUB_OWNER=your-github-username
NEXT_PUBLIC_GITHUB_REPO=devsnaps-favorites
NEXT_PUBLIC_GITHUB_FAVORITES_PATH=favorites.json
GITHUB_TOKEN=your-github-token-optional
```

**Where to find these values:**

- **Supabase URL & Anon Key**:
  - Supabase Dashboard → Settings → API
  - Copy "Project URL" and "anon/public" key

- **GitHub variables**:
  - Owner: Your GitHub username
  - Repo: Your favorites repository name
  - Token: From GitHub Setup Step 2 (optional)

### Step 3: Run Development Server

```bash
npm run dev
```

Visit `http://localhost:3000` - you should see DevSnaps!

### Step 4: Test GitHub OAuth

1. Click "Sign In with GitHub"
2. Authorize the app
3. You should be redirected back and logged in
4. Check Supabase → Authentication → Users to verify

---

## Vercel Deployment

### Step 1: Push to GitHub

```bash
git init
git add .
git commit -m "Initial DevSnaps deployment"
git branch -M main
git remote add origin https://github.com/yourusername/devsnaps.git
git push -u origin main
```

### Step 2: Import to Vercel

1. Go to [vercel.com](https://vercel.com) and sign in
2. Click "New Project"
3. Import your GitHub repository
4. Configure:
   - **Framework Preset**: Next.js
   - **Root Directory**: ./
   - **Build Command**: `next build`
   - **Output Directory**: `.next`

### Step 3: Add Environment Variables

In Vercel project settings → Environment Variables, add:

```env
NEXT_PUBLIC_SUPABASE_URL=https://yourproject.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_GITHUB_OWNER=your-github-username
NEXT_PUBLIC_GITHUB_REPO=devsnaps-favorites
NEXT_PUBLIC_GITHUB_FAVORITES_PATH=favorites.json
GITHUB_TOKEN=your-github-token-optional
```

### Step 4: Deploy

1. Click "Deploy"
2. Wait for build to complete (~2-3 minutes)
3. Visit your deployed URL (e.g., `https://devsnaps.vercel.app`)

### Step 5: Update GitHub OAuth for Production

1. Go to your GitHub OAuth App settings
2. Update **Homepage URL** to your Vercel domain
3. Add an additional **Authorization callback URL**:
   - `https://yourproject.supabase.co/auth/v1/callback`
4. Save changes

---

## Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | ✅ | Your Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ✅ | Supabase anonymous/public key |
| `NEXT_PUBLIC_GITHUB_OWNER` | ✅ | GitHub username for Staff Picks repo |
| `NEXT_PUBLIC_GITHUB_REPO` | ✅ | GitHub repository name for Staff Picks |
| `NEXT_PUBLIC_GITHUB_FAVORITES_PATH` | ⚪ | Path to favorites.json (default: "favorites.json") |
| `GITHUB_TOKEN` | ⚪ | GitHub PAT for higher rate limits (optional) |

---

## Testing

### Test Authentication
1. Sign in with GitHub
2. Verify user created in Supabase → Authentication → Users
3. Verify profile created in Supabase → Table Editor → profiles

### Test Upload
1. Click "Upload Your Snap"
2. Fill in form with:
   - Screenshot
   - Title
   - Code snippet
   - Language
3. Submit
4. Verify:
   - Image uploaded to Supabase Storage → snap-images
   - Snap created in Supabase → snaps table
   - Redirected to snap detail page

### Test Feed
1. Visit homepage
2. Verify masonry grid displays snaps
3. Test like functionality (heart icon)
4. Test "Load More" button

### Test Staff Picks
1. Visit `/staff-picks`
2. Verify snaps load from your GitHub favorites.json
3. Update favorites.json in GitHub
4. Wait 5 minutes or redeploy
5. Verify changes reflected

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Next.js App Router                    │
│  ┌────────────┐  ┌────────────┐  ┌──────────────────┐  │
│  │   Home     │  │   Upload   │  │   Staff Picks    │  │
│  │   Feed     │  │   Form     │  │   (GitHub API)   │  │
│  └────────────┘  └────────────┘  └──────────────────┘  │
└───────────┬─────────────┬──────────────────┬───────────┘
            │             │                  │
            ▼             ▼                  ▼
    ┌──────────────┐ ┌─────────────┐ ┌──────────────┐
    │   Supabase   │ │   Supabase  │ │    GitHub    │
    │     Auth     │ │   Storage   │ │     API      │
    └──────────────┘ └─────────────┘ └──────────────┘
            │             │
            └─────────┬───┘
                      ▼
              ┌──────────────┐
              │  PostgreSQL  │
              │  (Supabase)  │
              └──────────────┘
```

---

## Key Features

### ✨ Premium UI/UX
- Dark mode with glassmorphism effects
- Smooth animations with Framer Motion
- Responsive masonry grid layout
- Syntax highlighting with react-syntax-highlighter

### 🔒 Security
- Row Level Security (RLS) on all tables
- User can only edit/delete their own snaps
- Authenticated uploads only
- Protected routes via Edge Middleware

### ⚡ Performance
- Server-side rendering (SSR)
- Image optimization via Next.js Image
- Incremental Static Regeneration (ISR)
- Cached GitHub API requests (5-minute TTL)

### 🎨 Developer Experience
- TypeScript for type safety
- ESLint for code quality
- Tailwind CSS for rapid styling
- Modular component architecture

---

## Troubleshooting

### Issue: "Failed to upload snap"
- **Check**: Supabase Storage bucket exists and is public
- **Check**: RLS policies on storage.objects table
- **Check**: User is authenticated

### Issue: "Staff Picks not loading"
- **Check**: GitHub repo is public
- **Check**: favorites.json exists and is valid JSON
- **Check**: Environment variables are set correctly
- **Check**: GitHub API rate limit (60 requests/hour without token)

### Issue: "Cannot sign in with GitHub"
- **Check**: GitHub OAuth app credentials match Supabase
- **Check**: Callback URL is correct
- **Check**: OAuth app is not suspended

---

## Support & Resources

- **Supabase Docs**: https://supabase.com/docs
- **Next.js Docs**: https://nextjs.org/docs
- **Vercel Docs**: https://vercel.com/docs
- **GitHub OAuth**: https://docs.github.com/en/developers/apps/oauth-apps

---

## 🎉 You're All Set!

Your DevSnaps instance is now live and ready for developers to share beautiful code snaps!

**Next Steps:**
1. Customize the theme colors in `tailwind.config.ts`
2. Update the homepage hero text in `app/page.tsx`
3. Create your first staff pick in `favorites.json`
4. Share your DevSnaps URL with the community!

Happy coding! 🚀
