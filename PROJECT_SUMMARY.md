# 📦 DevSnaps - Project Summary

## Overview

DevSnaps is a premium, full-stack web application for developers to share beautiful code snippets and terminal themes. Think Pinterest for code, with a high-end, glassmorphic dark-mode aesthetic.

**Live Demo**: [Your Vercel URL here after deployment]

## 🎯 Key Features Implemented

### Core Functionality
- ✅ **User Authentication**: GitHub OAuth via Supabase Auth
- ✅ **Snap Upload**: Drag-and-drop image upload with code snippet editor
- ✅ **Masonry Feed**: Pinterest-style responsive grid layout
- ✅ **Staff Picks**: GitHub-synced curated favorites
- ✅ **Snap Details**: Full page view with stats and code highlighting
- ✅ **Edge Middleware**: Protected routes for authenticated users
- ✅ **Image Optimization**: Next.js Image component with Supabase Storage

### Database & Backend
- ✅ **PostgreSQL Schema**: Profiles, Snaps, Likes tables with RLS
- ✅ **Row Level Security**: Granular access control at database level
- ✅ **Auto Profile Creation**: Trigger-based profile creation on signup
- ✅ **Storage Policies**: User-based file upload permissions
- ✅ **GitHub API Integration**: Dynamic staff picks from repository

### UI/UX
- ✅ **Glassmorphism Design**: Premium dark-mode with glass effects
- ✅ **Responsive Layout**: Mobile-first, works on all screen sizes
- ✅ **Smooth Animations**: Framer Motion for transitions
- ✅ **Syntax Highlighting**: Atom One Dark theme for code
- ✅ **Custom Components**: Reusable UI components
- ✅ **Loading States**: Skeleton loaders and spinners

## 📂 Project Structure

```
devsnaps/
├── app/                          # Next.js App Router
│   ├── auth/                     # Authentication routes
│   │   ├── signin/               # Sign-in page
│   │   └── callback/             # OAuth callback handler
│   ├── snap/[id]/                # Dynamic snap detail page
│   ├── staff-picks/              # Curated picks page
│   ├── upload/                   # Upload form (protected)
│   ├── layout.tsx                # Root layout with navbar
│   ├── page.tsx                  # Home feed
│   └── globals.css               # Global styles
├── components/                   # React components
│   ├── Navbar.tsx                # Navigation with auth state
│   ├── SnapCard.tsx              # Individual snap card
│   └── MasonryGrid.tsx           # Masonry layout wrapper
├── lib/                          # Utilities and clients
│   ├── supabase.ts               # Supabase clients & types
│   ├── github.ts                 # GitHub API for staff picks
│   └── utils.ts                  # Helper functions
├── middleware.ts                 # Edge middleware for auth
├── supabase-setup.sql            # Database schema & policies
├── tailwind.config.ts            # Tailwind configuration
├── next.config.js                # Next.js configuration
└── package.json                  # Dependencies
```

## 🔧 Technology Stack

### Frontend
- **Next.js 15**: App Router, Server Components, Edge Middleware
- **React 19**: Latest features and optimizations
- **TypeScript**: Type-safe development
- **Tailwind CSS**: Utility-first styling
- **Framer Motion**: Smooth animations
- **React Masonry CSS**: Responsive grid layout
- **React Syntax Highlighter**: Code highlighting with Prism

### Backend
- **Supabase**: PostgreSQL database, Auth, Storage
- **Row Level Security**: Database-level authorization
- **Edge Functions**: Serverless functions
- **Storage**: File uploads with CDN

### APIs & Integrations
- **GitHub OAuth**: Secure authentication
- **GitHub API (Octokit)**: Staff picks sync
- **Next.js Image**: Optimized image delivery

### Deployment
- **Vercel**: Edge network deployment
- **GitHub**: Version control and CI/CD

## 🗃️ Database Schema

### Tables

**profiles**
- `id` (UUID, FK to auth.users)
- `username`, `full_name`, `avatar_url`
- `github_username`, `bio`
- Auto-created on user signup

**snaps**
- `id` (UUID, primary key)
- `user_id` (FK to profiles)
- `title`, `description`, `code_content`
- `language`, `image_url`, `theme_name`
- `likes_count`, `views_count`, `is_public`
- `tags` (array)

**likes**
- `id` (UUID)
- `user_id`, `snap_id`
- Unique constraint on (user_id, snap_id)

### RLS Policies

- Public can view public snaps
- Users can CRUD their own snaps
- Users can like/unlike snaps
- Storage follows user-based permissions

## 🔐 Security Implementation

### Authentication
- GitHub OAuth (no passwords)
- Session management via Supabase
- Automatic session refresh

### Authorization
- Edge Middleware protects `/upload`, `/settings`
- RLS policies at database level
- User-scoped file uploads in Storage

### Data Protection
- Service role key only on server
- Environment variables secured
- CORS properly configured

## 🎨 Design System

### Colors
- **Background**: Deep dark gradients (#0a0e17 → #1a1f2e)
- **Accents**: Purple-blue gradient (#667eea → #764ba2)
- **Glass**: Semi-transparent with backdrop blur

### Components
- Glass cards with border and shadow
- Gradient buttons with hover effects
- Custom scrollbar styling
- Badge system for tags and labels

### Typography
- System fonts for performance
- Gradient text for headers
- Clear hierarchy

## 🚀 Deployment Architecture

```
User Request
    ↓
Vercel Edge Network
    ↓
Middleware (Auth Check)
    ↓
Next.js Server Component
    ↓
Supabase (Data + Auth + Storage)
    ↓
GitHub API (Staff Picks)
```

## 📊 Performance Optimizations

- Server Components for initial load
- Image optimization with Next.js
- 60s revalidation for staff picks
- Edge middleware for fast auth
- Lazy loading for images
- Code splitting by route

## 🔄 Data Flow Examples

### Upload Flow
1. User navigates to `/upload`
2. Middleware checks auth → redirects if not logged in
3. User fills form and selects image
4. Image uploads to Supabase Storage
5. Snap metadata saved to database
6. Redirect to snap detail page

### Staff Picks Sync
1. Server component runs on page request
2. GitHub API fetches `favorites.json`
3. Extracts snap IDs from JSON
4. Queries database for matching snaps
5. Returns data with 60s cache
6. Updates automatically when GitHub file changes

## 📝 Environment Variables

### Required
```env
NEXT_PUBLIC_SUPABASE_URL          # Supabase project URL
NEXT_PUBLIC_SUPABASE_ANON_KEY     # Public anon key
SUPABASE_SERVICE_ROLE_KEY         # Secret service key
```

### Optional (for Staff Picks)
```env
GITHUB_ACCESS_TOKEN               # GitHub PAT
GITHUB_REPO_OWNER                 # Repository owner
GITHUB_REPO_NAME                  # Repository name
GITHUB_FAVORITES_PATH             # Path to favorites.json
```

## 🧪 Testing Checklist

- [ ] Sign in with GitHub
- [ ] Upload a snap with image
- [ ] View snap in feed
- [ ] Click snap to view details
- [ ] Test protected routes without auth
- [ ] Verify staff picks load
- [ ] Test on mobile device
- [ ] Check image optimization
- [ ] Verify middleware redirects
- [ ] Test sign out

## 🚧 Future Enhancements

### Planned Features
- [ ] Like functionality implementation
- [ ] User profiles with their snaps
- [ ] Search and filtering
- [ ] Collections/folders
- [ ] Comments on snaps
- [ ] Copy-to-clipboard for code
- [ ] Share to social media
- [ ] Dark/light mode toggle
- [ ] Analytics dashboard
- [ ] Trending algorithm

### Technical Improvements
- [ ] Unit tests (Jest + React Testing Library)
- [ ] E2E tests (Playwright)
- [ ] PWA support
- [ ] OpenGraph meta tags
- [ ] Sitemap generation
- [ ] RSS feed
- [ ] Rate limiting
- [ ] Spam detection

## 📖 Documentation

- **README.md**: Overview and features
- **QUICKSTART.md**: 5-minute setup guide
- **DEPLOYMENT.md**: Complete deployment guide
- **PROJECT_SUMMARY.md**: This file - architecture overview

## 🐛 Known Issues

- Supabase auth helpers are deprecated (consider migrating to @supabase/ssr)
- Some npm warnings about deprecated packages (non-critical)

## 📞 Support

For issues or questions:
1. Check the documentation files
2. Review Supabase logs
3. Check Vercel deployment logs
4. Inspect browser console for errors

## 🎉 Success Metrics

Once deployed, monitor:
- User signups (Supabase Auth dashboard)
- Total snaps uploaded
- Storage usage
- Page views (Vercel Analytics)
- Staff picks engagement

## 🏆 Credits

Built with:
- Next.js by Vercel
- Supabase for backend
- Tailwind CSS for styling
- Framer Motion for animations
- Designed for the developer community

---

**Status**: ✅ Ready for deployment
**Version**: 1.0.0
**Last Updated**: 2026-02-28
