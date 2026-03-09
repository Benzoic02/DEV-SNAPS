# 🚀 DevSnaps Deployment Guide

Complete step-by-step guide to deploy DevSnaps to production.

## 📋 Pre-Deployment Checklist

- [ ] Supabase project created
- [ ] Database schema applied (supabase-setup.sql)
- [ ] GitHub OAuth app configured
- [ ] Storage bucket created and configured
- [ ] GitHub repository for favorites created
- [ ] GitHub Personal Access Token generated
- [ ] All environment variables documented

## 1️⃣ Supabase Configuration

### Create Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in:
   - **Name**: devsnaps
   - **Database Password**: (save this securely)
   - **Region**: Choose closest to your users
4. Wait for project to initialize (~2 minutes)

### Apply Database Schema

1. Go to SQL Editor in Supabase Dashboard
2. Copy contents of `supabase-setup.sql`
3. Paste and click "Run"
4. Verify tables created: `profiles`, `snaps`, `likes`

### Configure Authentication

1. Go to **Authentication > Providers**
2. Enable GitHub provider
3. Configure GitHub OAuth:
   - Leave callback URL as shown (copy it)
   - We'll add Client ID and Secret after creating GitHub OAuth app

### Create Storage Bucket

1. Go to **Storage**
2. Click "New Bucket"
3. Name: `snap-images`
4. Make it **Public**
5. Click "Create"

The RLS policies are already applied via the SQL script.

## 2️⃣ GitHub OAuth Setup

### Create OAuth App

1. Go to GitHub Settings
2. Navigate to **Developer settings > OAuth Apps**
3. Click **"New OAuth App"**
4. Fill in:
   ```
   Application name: DevSnaps
   Homepage URL: https://your-app-name.vercel.app (use localhost:3000 for dev)
   Authorization callback URL: [paste from Supabase Auth settings]
   ```
5. Click **"Register application"**
6. Copy **Client ID**
7. Click **"Generate a new client secret"**
8. Copy **Client Secret** (save securely - shown only once)

### Add to Supabase

1. Return to Supabase **Authentication > Providers > GitHub**
2. Paste **Client ID**
3. Paste **Client Secret**
4. Click **"Save"**

## 3️⃣ GitHub Favorites Repository

### Create Repository

1. Go to GitHub
2. Create new **public** repository
3. Name: `devsnaps-favorites` (or your choice)
4. Initialize with README

### Create favorites.json

Create a file named `favorites.json` in the root:

```json
{
  "snaps": [
    {
      "id": "replace-with-actual-snap-id-from-database",
      "title": "Beautiful React Hook",
      "description": "An elegant useEffect pattern for async operations",
      "language": "javascript",
      "tags": ["react", "hooks", "async"]
    },
    {
      "id": "another-snap-id",
      "title": "Rust Error Handling",
      "description": "Idiomatic error handling with Result types",
      "language": "rust",
      "tags": ["rust", "errors", "best-practices"]
    }
  ]
}
```

**Note**: The `id` fields should match actual snap IDs from your database. You'll need to add snaps first, then update this file with their IDs.

### Generate Personal Access Token

1. Go to GitHub Settings
2. **Developer settings > Personal access tokens > Tokens (classic)**
3. Click **"Generate new token (classic)"**
4. Fill in:
   - **Note**: DevSnaps API Access
   - **Expiration**: No expiration (or your preference)
   - **Scopes**: Check `repo` (for private repos) or `public_repo` (for public only)
5. Click **"Generate token"**
6. Copy token immediately (shown only once)

## 4️⃣ Environment Variables

Create `.env.local` with these values:

```bash
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# GitHub API Configuration
GITHUB_ACCESS_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxx
GITHUB_REPO_OWNER=your-github-username
GITHUB_REPO_NAME=devsnaps-favorites
GITHUB_FAVORITES_PATH=favorites.json

# App Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### Where to find Supabase keys:

1. Go to Project Settings
2. Click **API**
3. Copy:
   - **Project URL** → `NEXT_PUBLIC_SUPABASE_URL`
   - **anon/public** key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - **service_role** key → `SUPABASE_SERVICE_ROLE_KEY` (keep secret!)

## 5️⃣ Local Testing

```bash
# Install dependencies
npm install

# Run development server
npm run dev
```

Visit http://localhost:3000 and test:
- [ ] Sign in with GitHub
- [ ] Upload a snap
- [ ] View snap details
- [ ] Check staff picks page
- [ ] Verify image uploads work

## 6️⃣ Deploy to Vercel

### Connect Repository

1. Push code to GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: DevSnaps application"
   git branch -M main
   git remote add origin https://github.com/yourusername/devsnaps.git
   git push -u origin main
   ```

2. Go to [vercel.com](https://vercel.com)
3. Click **"Import Project"**
4. Select your GitHub repository
5. Vercel auto-detects Next.js settings ✓

### Configure Environment Variables

In Vercel project settings:

1. Go to **Settings > Environment Variables**
2. Add ALL variables from `.env.local`
3. Select environments: **Production, Preview, Development**
4. Click **"Save"**

**Important**: Update `NEXT_PUBLIC_APP_URL` to your Vercel domain:
```
NEXT_PUBLIC_APP_URL=https://devsnaps.vercel.app
```

### Deploy

1. Click **"Deploy"**
2. Wait for build to complete (~2-3 minutes)
3. Visit your deployed app!

## 7️⃣ Post-Deployment Configuration

### Update GitHub OAuth

1. Go to your GitHub OAuth App settings
2. Add production callback URL:
   ```
   https://your-project.supabase.co/auth/v1/callback
   ```
3. Update Homepage URL:
   ```
   https://your-app.vercel.app
   ```

### Update Supabase Site URL

1. Go to Supabase **Authentication > URL Configuration**
2. Update **Site URL**:
   ```
   https://your-app.vercel.app
   ```
3. Add **Redirect URLs**:
   ```
   https://your-app.vercel.app/**
   ```

### Test Production

- [ ] Sign in with GitHub (production)
- [ ] Upload a snap
- [ ] Verify images load
- [ ] Check middleware protection on /upload
- [ ] Test staff picks sync

## 8️⃣ Updating Staff Picks

To add new staff picks:

1. Go to your app and find snaps you want to feature
2. Copy their IDs from the URL (e.g., `/snap/abc123`)
3. Update `favorites.json` in your GitHub repository
4. Commit and push changes
5. Staff picks will update automatically (60s cache)

## 🔧 Troubleshooting

### "OAuth Error" when signing in
- Check GitHub OAuth callback URL matches Supabase
- Verify Client ID and Secret in Supabase

### Images not uploading
- Verify Storage bucket is public
- Check RLS policies are applied
- Ensure CORS is configured in Supabase Storage

### Staff picks not showing
- Verify GitHub token has correct permissions
- Check repository name and path in env vars
- Ensure favorites.json is valid JSON

### Build fails on Vercel
- Check all environment variables are set
- Verify TypeScript has no errors: `npm run build` locally
- Check Vercel build logs for specific errors

## 📊 Monitoring

### Supabase Dashboard
- Monitor database usage
- Check auth logs
- Review storage usage

### Vercel Analytics
- Enable Vercel Analytics in project settings
- Monitor page views and performance
- Track deployment health

## 🔐 Security Checklist

- [ ] Service role key is NOT in client-side code
- [ ] RLS policies are enabled on all tables
- [ ] Storage bucket has proper RLS policies
- [ ] CORS is properly configured
- [ ] GitHub OAuth app is production-only
- [ ] Environment variables are secure

## 🎉 Done!

Your DevSnaps application is now live! Share it with the developer community and start curating beautiful code snippets.

---

Need help? Check the main README.md or create an issue on GitHub.
