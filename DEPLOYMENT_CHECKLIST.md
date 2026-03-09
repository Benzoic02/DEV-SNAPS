# DevSnaps - Deployment Checklist

Use this checklist to ensure a smooth deployment of your DevSnaps instance.

---

## 📋 Pre-Deployment

### ✅ Local Development
- [ ] Clone repository
- [ ] Run `npm install`
- [ ] Copy `.env.local.example` to `.env.local`
- [ ] Verify all files are present:
  - [ ] `supabase-setup-enhanced.sql`
  - [ ] `components/feed/SnapCard.tsx`
  - [ ] `components/feed/SnapsFeed.tsx`
  - [ ] `components/upload/UploadForm.tsx`
  - [ ] `lib/github-staff-picks.ts`
  - [ ] `middleware.ts`

---

## 🗄️ Supabase Setup

### ✅ Create Project
- [ ] Go to [supabase.com](https://supabase.com)
- [ ] Click "New Project"
- [ ] Enter project details:
  - [ ] Name: DevSnaps (or your choice)
  - [ ] Database password (save it!)
  - [ ] Region (closest to your users)
- [ ] Wait for project initialization (~2 min)

### ✅ Run Database Schema
- [ ] Go to SQL Editor in Supabase dashboard
- [ ] Create new query
- [ ] Copy/paste contents of `supabase-setup-enhanced.sql`
- [ ] Click "Run" (Ctrl/Cmd + Enter)
- [ ] Verify tables created:
  - [ ] `profiles`
  - [ ] `snaps`
  - [ ] `likes`

### ✅ Verify Storage
- [ ] Go to Storage section
- [ ] Check `snap-images` bucket exists
- [ ] Verify bucket is public
- [ ] Check file size limit: 5MB
- [ ] Verify allowed MIME types: PNG, JPG, WebP, GIF

### ✅ Get Credentials
- [ ] Go to Settings → API
- [ ] Copy **Project URL** → Save for `NEXT_PUBLIC_SUPABASE_URL`
- [ ] Copy **anon/public key** → Save for `NEXT_PUBLIC_SUPABASE_ANON_KEY`

---

## 🔐 GitHub OAuth Setup

### ✅ Configure in Supabase
- [ ] Go to Authentication → Providers
- [ ] Find GitHub, click to expand
- [ ] Enable GitHub provider
- [ ] Copy **Callback URL** (e.g., `https://yourproject.supabase.co/auth/v1/callback`)

### ✅ Create GitHub OAuth App
- [ ] Go to GitHub Settings → Developer settings → OAuth Apps
- [ ] Click "New OAuth App"
- [ ] Fill in details:
  - [ ] Application name: DevSnaps
  - [ ] Homepage URL: `http://localhost:3000` (for dev)
  - [ ] Callback URL: Paste from Supabase
- [ ] Click "Register application"
- [ ] Copy **Client ID**
- [ ] Generate and copy **Client Secret**

### ✅ Connect to Supabase
- [ ] Return to Supabase → Authentication → Providers → GitHub
- [ ] Paste **Client ID**
- [ ] Paste **Client Secret**
- [ ] Click "Save"

---

## 📁 GitHub Staff Picks Setup

### ✅ Create Favorites Repository
- [ ] Create new public GitHub repository
  - [ ] Name: `devsnaps-favorites` (or your choice)
  - [ ] Visibility: **Public**
  - [ ] Initialize with README: Optional
- [ ] Create `favorites.json` file in repo root
- [ ] Copy template from `favorites.json` in project
- [ ] Customize with your own picks (or keep examples)
- [ ] Commit and push

### ✅ Optional: Generate GitHub Token
For higher API rate limits (5,000/hour vs 60/hour):
- [ ] Go to GitHub Settings → Developer settings → Personal access tokens
- [ ] Click "Generate new token (classic)"
- [ ] Name: DevSnaps API
- [ ] Select scope: `public_repo` (read-only)
- [ ] Generate and copy token
- [ ] Save for `GITHUB_TOKEN` env variable

---

## 💻 Local Testing

### ✅ Configure Environment
- [ ] Update `.env.local` with values:
  ```env
  NEXT_PUBLIC_SUPABASE_URL=https://yourproject.supabase.co
  NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
  NEXT_PUBLIC_GITHUB_OWNER=your-github-username
  NEXT_PUBLIC_GITHUB_REPO=devsnaps-favorites
  GITHUB_TOKEN=your-token-optional
  ```

### ✅ Start Development Server
- [ ] Run `npm run dev`
- [ ] Open `http://localhost:3000`
- [ ] Verify homepage loads

### ✅ Test Authentication
- [ ] Click "Sign In with GitHub"
- [ ] Authorize the app
- [ ] Verify redirect back to homepage
- [ ] Check user created in Supabase → Authentication → Users
- [ ] Check profile created in Supabase → Table Editor → profiles

### ✅ Test Upload
- [ ] Navigate to `/upload`
- [ ] Fill in form:
  - [ ] Upload screenshot (drag-drop or browse)
  - [ ] Enter title
  - [ ] Enter code snippet
  - [ ] Select language
  - [ ] Optional: theme, description, tags
- [ ] Click "Publish Snap"
- [ ] Verify:
  - [ ] Image uploaded to Storage → snap-images
  - [ ] Snap created in Table Editor → snaps
  - [ ] Redirected to snap detail page

### ✅ Test Feed
- [ ] Go to homepage
- [ ] Verify snap appears in masonry grid
- [ ] Click heart icon to like
- [ ] Verify like count increases
- [ ] Check likes table in Supabase

### ✅ Test Staff Picks
- [ ] Navigate to `/staff-picks`
- [ ] Verify picks load from GitHub repo
- [ ] Check for no errors in console
- [ ] Verify last updated date shows

---

## 🚀 Vercel Deployment

### ✅ Prepare Repository
- [ ] Ensure all changes committed to git
- [ ] Push to GitHub:
  ```bash
  git add .
  git commit -m "Ready for deployment"
  git push origin main
  ```

### ✅ Import to Vercel
- [ ] Go to [vercel.com](https://vercel.com)
- [ ] Sign in with GitHub
- [ ] Click "New Project"
- [ ] Import your DevSnaps repository
- [ ] Configure build settings:
  - [ ] Framework Preset: **Next.js** (auto-detected)
  - [ ] Root Directory: `./`
  - [ ] Build Command: `next build` (default)
  - [ ] Output Directory: `.next` (default)

### ✅ Add Environment Variables
In Vercel project settings → Environment Variables:

- [ ] Add `NEXT_PUBLIC_SUPABASE_URL`
  - Value: Your Supabase URL
  - Environments: Production, Preview, Development

- [ ] Add `NEXT_PUBLIC_SUPABASE_ANON_KEY`
  - Value: Your Supabase anon key
  - Environments: Production, Preview, Development

- [ ] Add `NEXT_PUBLIC_GITHUB_OWNER`
  - Value: Your GitHub username
  - Environments: Production, Preview, Development

- [ ] Add `NEXT_PUBLIC_GITHUB_REPO`
  - Value: Your favorites repo name
  - Environments: Production, Preview, Development

- [ ] Optional: Add `GITHUB_TOKEN`
  - Value: Your GitHub PAT
  - Environments: Production, Preview, Development

### ✅ Deploy
- [ ] Click "Deploy"
- [ ] Wait for build to complete (~2-3 minutes)
- [ ] Check for build errors (should show ✅ Success)
- [ ] Copy deployment URL (e.g., `https://devsnaps-abc123.vercel.app`)

---

## 🔄 Post-Deployment Configuration

### ✅ Update GitHub OAuth
- [ ] Go to GitHub OAuth App settings
- [ ] Update **Homepage URL** to Vercel domain
  - Example: `https://devsnaps-abc123.vercel.app`
- [ ] Add production callback URL (keep dev one too):
  - Add: `https://yourproject.supabase.co/auth/v1/callback`
- [ ] Save changes

### ✅ Optional: Custom Domain
If using a custom domain:
- [ ] Add domain in Vercel project settings
- [ ] Update DNS records as instructed
- [ ] Wait for SSL certificate (~1-2 minutes)
- [ ] Update GitHub OAuth App homepage URL
- [ ] Test with custom domain

---

## ✅ Production Testing

### ✅ Verify Deployment
- [ ] Visit production URL
- [ ] Homepage loads correctly
- [ ] No console errors
- [ ] Images load properly
- [ ] Responsive on mobile (test with DevTools)

### ✅ Test Authentication (Production)
- [ ] Click "Sign In with GitHub"
- [ ] Authorize app
- [ ] Verify redirect works
- [ ] Check if user appears in Supabase

### ✅ Test Upload (Production)
- [ ] Go to `/upload`
- [ ] Upload a test snap
- [ ] Verify it appears in feed
- [ ] Check Supabase Storage and Database

### ✅ Test Staff Picks (Production)
- [ ] Visit `/staff-picks`
- [ ] Verify picks load correctly
- [ ] Update `favorites.json` in GitHub
- [ ] Wait 5 minutes
- [ ] Refresh page, verify changes appear

### ✅ Test Like Functionality
- [ ] Like a snap
- [ ] Unlike a snap
- [ ] Verify count updates correctly
- [ ] Check in Supabase likes table

---

## 🎨 Optional Customization

### ✅ Branding
- [ ] Update app name in `layout.tsx`
- [ ] Change theme colors in `tailwind.config.ts`
- [ ] Update hero text in `app/page.tsx`
- [ ] Add logo/favicon

### ✅ Analytics (Optional)
- [ ] Set up Vercel Analytics (auto-enabled)
- [ ] Add Google Analytics (if desired)
- [ ] Configure Sentry for error tracking

### ✅ SEO
- [ ] Update metadata in page files
- [ ] Add `robots.txt`
- [ ] Add `sitemap.xml`
- [ ] Submit to Google Search Console

---

## 📊 Monitoring

### ✅ Post-Launch Checks
- [ ] Monitor Vercel deployment logs
- [ ] Check Supabase usage (database, storage, auth)
- [ ] Monitor GitHub API rate limits
- [ ] Watch for errors in Vercel dashboard

### ✅ Weekly Maintenance
- [ ] Review user activity
- [ ] Check storage usage
- [ ] Update staff picks if needed
- [ ] Monitor performance metrics

---

## 🐛 Troubleshooting

### Issue: Build fails in Vercel
- [ ] Check environment variables are set
- [ ] Verify no TypeScript errors
- [ ] Check build logs for specific errors
- [ ] Try building locally: `npm run build`

### Issue: Authentication doesn't work
- [ ] Verify GitHub OAuth callback URL matches
- [ ] Check Supabase provider is enabled
- [ ] Ensure Client ID and Secret are correct
- [ ] Check browser console for errors

### Issue: Upload fails
- [ ] Verify Storage bucket exists
- [ ] Check RLS policies on storage.objects
- [ ] Ensure user is authenticated
- [ ] Check file size and type

### Issue: Staff Picks don't load
- [ ] Verify GitHub repo is public
- [ ] Check `favorites.json` is valid JSON
- [ ] Confirm environment variables are set
- [ ] Check GitHub API rate limit

---

## ✅ Success Criteria

Your deployment is successful when:

- ✅ Users can sign in with GitHub
- ✅ Users can upload snaps
- ✅ Feed displays in masonry grid
- ✅ Like functionality works
- ✅ Staff picks load from GitHub
- ✅ All routes are accessible
- ✅ Images load from Supabase Storage
- ✅ No console errors
- ✅ Responsive on mobile devices
- ✅ Fast page loads (<3 seconds)

---

## 🎉 You're Live!

Once all checkboxes are ✅, your DevSnaps instance is live!

**Share your deployment:**
- Tweet about it
- Post on LinkedIn
- Share in developer communities
- Add to your portfolio

**Next steps:**
- Create your first staff pick
- Invite friends to upload snaps
- Customize branding
- Monitor analytics

---

## 📞 Need Help?

**Resources:**
- `COMPLETE_SETUP_GUIDE.md` - Detailed instructions
- `QUICK_REFERENCE.md` - Quick lookup
- `README_NEW.md` - Project overview

**Support:**
- Supabase Discord
- Next.js GitHub Discussions
- Vercel Support

---

**Happy deploying! 🚀**
