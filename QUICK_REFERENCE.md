# DevSnaps - Quick Reference Guide

## 🎯 What is DevSnaps?

A premium, full-stack web application for developers to share beautiful code snippets and terminal themes in a Pinterest-style masonry layout.

---

## 📦 Core Components Created

### 1. **Enhanced Database Schema** (`supabase-setup-enhanced.sql`)
- Complete PostgreSQL schema with RLS policies
- Tables: `profiles`, `snaps`, `likes`
- Storage bucket: `snap-images` with security policies
- Automated triggers for likes count and profile creation
- Performance indexes for fast queries

### 2. **Feed Components**
- **`SnapCard.tsx`** - Individual snap display with:
  - Glassmorphism overlay on hover
  - Code preview modal
  - Like functionality
  - Language badge
  - Author information

- **`SnapsFeed.tsx`** - Main feed with:
  - Responsive masonry grid (3/2/1 columns)
  - Infinite scroll with "Load More"
  - Real-time like synchronization
  - Filter support (recent, popular, trending)

### 3. **Upload System** (`UploadForm.tsx`)
- Drag-and-drop file upload
- Image preview before upload
- Real-time code syntax highlighting
- Direct upload to Supabase Storage
- Form validation and error handling

### 4. **GitHub Staff Picks Integration**
- **`github-staff-picks.ts`** - Service layer with:
  - Fetch staff picks from public GitHub repo
  - 5-minute caching to reduce API calls
  - Error handling and fallbacks

- **`StaffPicksClient.tsx`** - Premium UI component
- **`app/staff-picks/page.tsx`** - Server component with ISR

### 5. **Page Updates**
- **Homepage** (`app/page.tsx`) - Hero section + feed integration
- **Upload** (`app/upload/page.tsx`) - Clean layout with tips section
- **Staff Picks** - Dynamic sync from GitHub

---

## 🔐 Security Features

### Row Level Security (RLS)
```sql
-- Example: Users can only delete their own snaps
CREATE POLICY "Users can delete their own snaps"
  ON snaps FOR DELETE
  USING (auth.uid() = user_id);
```

### Edge Middleware (`middleware.ts`)
- Protects `/upload` and `/settings` routes
- Redirects unauthenticated users to sign-in
- Refreshes session automatically

### Storage Security
- User-specific folders (`user_id/filename.ext`)
- 5MB file size limit
- Allowed MIME types: PNG, JPG, WebP, GIF
- Public read, authenticated write

---

## 🎨 UI/UX Features

### Glassmorphism Effects
```tsx
className="bg-gray-900/50 backdrop-blur-sm border border-gray-700"
```

### Gradient Text
```tsx
className="bg-gradient-to-r from-purple-400 via-pink-400 to-purple-400 text-transparent bg-clip-text"
```

### Smooth Animations (Framer Motion)
```tsx
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.4 }}
>
```

---

## 📊 Data Flow

### Upload Flow
```
User fills form
  ↓
Validate inputs
  ↓
Upload image to Supabase Storage (snap-images/user_id/timestamp.ext)
  ↓
Get public URL
  ↓
Insert snap into database
  ↓
Redirect to snap detail page
```

### Feed Flow
```
Server fetches initial snaps (SSR)
  ↓
Client hydrates with SnapsFeed component
  ↓
User scrolls → Load more snaps (client-side)
  ↓
User likes snap → Update database + UI
```

### Staff Picks Flow
```
GitHub repo contains favorites.json
  ↓
Server fetches via Octokit API
  ↓
Cache for 5 minutes
  ↓
Revalidate every 5 minutes (ISR)
```

---

## 🚀 Deployment Checklist

### Supabase Setup
- [x] Create project
- [x] Run SQL schema (`supabase-setup-enhanced.sql`)
- [x] Configure GitHub OAuth
- [x] Verify storage bucket exists
- [x] Test RLS policies

### GitHub Setup
- [x] Create OAuth App
- [x] Create public repo for staff picks
- [x] Add `favorites.json` file
- [x] Optional: Generate Personal Access Token

### Local Development
- [x] Install dependencies (`npm install`)
- [x] Copy `.env.local.example` to `.env.local`
- [x] Fill in environment variables
- [x] Run `npm run dev`
- [x] Test authentication
- [x] Test upload
- [x] Test feed

### Vercel Deployment
- [x] Push to GitHub
- [x] Import in Vercel
- [x] Add environment variables
- [x] Deploy
- [x] Update GitHub OAuth callback URL
- [x] Test production build

---

## 🔧 Environment Variables

```env
# Required
NEXT_PUBLIC_SUPABASE_URL=https://yourproject.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_GITHUB_OWNER=your-github-username
NEXT_PUBLIC_GITHUB_REPO=devsnaps-favorites

# Optional
GITHUB_TOKEN=your-github-pat
NEXT_PUBLIC_GITHUB_FAVORITES_PATH=favorites.json
```

---

## 📁 File Structure

```
devsnaps/
├── app/
│   ├── page.tsx                       # Homepage with feed
│   ├── upload/page.tsx                # Upload page
│   ├── staff-picks/
│   │   ├── page.tsx                   # Server component
│   │   └── StaffPicksClient.tsx       # Client component
│   └── auth/
│       ├── signin/page.tsx            # Sign in
│       └── callback/route.ts          # OAuth callback
│
├── components/
│   ├── feed/
│   │   ├── SnapsFeed.tsx              # Main feed component
│   │   └── SnapCard.tsx               # Snap card component
│   └── upload/
│       └── UploadForm.tsx             # Upload form
│
├── lib/
│   ├── supabase.ts                    # Supabase client
│   ├── github-staff-picks.ts          # GitHub API service
│   └── utils.ts                       # Utilities
│
├── middleware.ts                       # Edge Middleware
├── supabase-setup-enhanced.sql        # Database schema
├── favorites.json                     # Example staff picks
├── .env.local.example                 # Env template
├── COMPLETE_SETUP_GUIDE.md            # Detailed guide
└── README_NEW.md                      # Project README
```

---

## 🎯 Key Technologies

| Technology | Purpose | Version |
|------------|---------|---------|
| Next.js | React framework | 15.x |
| React | UI library | 19.x |
| TypeScript | Type safety | 5.x |
| Supabase | Backend/DB/Auth | Latest |
| Tailwind CSS | Styling | 3.x |
| Framer Motion | Animations | 11.x |
| react-masonry-css | Grid layout | 1.x |
| react-syntax-highlighter | Code rendering | 15.x |
| @octokit/rest | GitHub API | 20.x |
| Lucide React | Icons | Latest |

---

## 🐛 Common Issues & Solutions

### Issue: Upload fails
**Solution**: Check Supabase Storage bucket exists and RLS policies are correct

### Issue: GitHub OAuth doesn't work
**Solution**: Verify callback URL matches Supabase exactly

### Issue: Staff Picks not loading
**Solution**: Ensure GitHub repo is public and `favorites.json` exists

### Issue: Middleware redirects in loop
**Solution**: Check middleware matcher config excludes static files

---

## 🎨 Customization Guide

### Change Theme Colors
Edit `tailwind.config.ts`:
```typescript
colors: {
  purple: {...},  // Change to your brand color
  pink: {...},
}
```

### Modify Masonry Breakpoints
Edit `components/feed/SnapsFeed.tsx`:
```typescript
const breakpointColumns = {
  default: 4,    // Change column count
  1536: 4,
  // ...
}
```

### Update Code Theme
Edit `components/feed/SnapCard.tsx` and `components/upload/UploadForm.tsx`:
```typescript
import { atomDark } from 'react-syntax-highlighter/dist/esm/styles/prism'
// Change to: vscDarkPlus, dracula, nord, etc.
```

---

## 📈 Performance Optimizations

1. **ISR (Incremental Static Regeneration)**
   - Staff Picks: Revalidate every 5 minutes
   - Homepage: Revalidate every 60 seconds

2. **Image Optimization**
   - Next.js Image component for automatic optimization
   - Proper sizing with `sizes` attribute
   - Lazy loading by default

3. **Database Indexes**
   - Indexed: `user_id`, `created_at`, `is_public`, `language`, `tags`
   - GIN index for full-text search

4. **Caching**
   - GitHub API responses cached for 5 minutes
   - Supabase client-side cache for liked snaps

---

## 🎓 Learning Resources

- [Next.js App Router](https://nextjs.org/docs/app)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [Supabase Storage](https://supabase.com/docs/guides/storage)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Framer Motion](https://www.framer.com/motion/)

---

## ✅ Success Criteria

Your DevSnaps instance is ready when:

- ✅ Users can sign in with GitHub
- ✅ Users can upload snaps (image + code)
- ✅ Feed displays in masonry grid
- ✅ Like functionality works
- ✅ Staff Picks sync from GitHub
- ✅ All routes are protected correctly
- ✅ Images load from Supabase Storage
- ✅ RLS policies enforce data security

---

**Need help?** Check [COMPLETE_SETUP_GUIDE.md](./COMPLETE_SETUP_GUIDE.md) for detailed instructions!
