# 🏗️ DevSnaps Architecture

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLIENT (Browser)                         │
│  ┌──────────────┐  ┌──────────────┐  ┌────────────────────┐   │
│  │ React Pages  │  │  Components  │  │  Client Supabase   │   │
│  │              │  │              │  │      Client        │   │
│  └──────────────┘  └──────────────┘  └────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    VERCEL EDGE NETWORK                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   Edge Middleware                         │  │
│  │  • Authentication Check                                   │  │
│  │  • Route Protection (/upload, /settings)                  │  │
│  │  • Redirect to /auth/signin if unauthorized              │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      NEXT.JS SERVER                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Server Components (RSC)                      │  │
│  │  • app/page.tsx (Feed)                                   │  │
│  │  • app/staff-picks/page.tsx                              │  │
│  │  • app/snap/[id]/page.tsx                                │  │
│  │  • Fetch data server-side                                │  │
│  │  • 60s revalidation for staff picks                      │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Client Components                            │  │
│  │  • app/upload/page.tsx                                   │  │
│  │  • components/Navbar.tsx                                 │  │
│  │  • Interactive UI elements                               │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              API Routes                                   │  │
│  │  • app/auth/callback/route.ts                            │  │
│  │  • OAuth callback handler                                │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
           ↓                            ↓
┌──────────────────────────┐  ┌─────────────────────────────────┐
│   SUPABASE BACKEND       │  │      GITHUB API                 │
│                          │  │                                 │
│  ┌────────────────────┐ │  │  ┌───────────────────────────┐ │
│  │   PostgreSQL       │ │  │  │   Octokit REST API        │ │
│  │   • profiles       │ │  │  │   • Get favorites.json    │ │
│  │   • snaps          │ │  │  │   • From public repo      │ │
│  │   • likes          │ │  │  │   • Returns snap IDs      │ │
│  │   • RLS Policies   │ │  │  └───────────────────────────┘ │
│  └────────────────────┘ │  │                                 │
│                          │  └─────────────────────────────────┘
│  ┌────────────────────┐ │
│  │   Auth             │ │
│  │   • GitHub OAuth   │ │
│  │   • Session mgmt   │ │
│  │   • JWTs           │ │
│  └────────────────────┘ │
│                          │
│  ┌────────────────────┐ │
│  │   Storage          │ │
│  │   • snap-images    │ │
│  │   • Public bucket  │ │
│  │   • RLS policies   │ │
│  └────────────────────┘ │
└──────────────────────────┘
```

## Request Flow Diagrams

### 1. Page Load (Unauthenticated)

```
User → Vercel Edge → Middleware → Next.js Server → Supabase DB
                        ↓
                   No session?
                        ↓
                   Continue to page
                        ↓
                   Render public feed
                        ↓
                   Return HTML to user
```

### 2. Sign In Flow

```
User clicks "Sign In"
        ↓
Navigate to /auth/signin
        ↓
Click "Continue with GitHub"
        ↓
Supabase Auth initiates OAuth
        ↓
Redirect to GitHub
        ↓
User authorizes app
        ↓
GitHub redirects to callback
        ↓
/auth/callback exchanges code for session
        ↓
Supabase creates/updates user
        ↓
Trigger creates profile row
        ↓
Redirect to home page (authenticated)
```

### 3. Upload Snap Flow

```
User navigates to /upload
        ↓
Middleware checks session
        ↓
Session exists? → Yes → Continue
                  No → Redirect to /auth/signin?redirectTo=/upload
        ↓
User fills form
        ↓
Selects image file
        ↓
Client uploads to Supabase Storage
  • Path: {user_id}/{timestamp}.{ext}
  • RLS: Only owner can upload to their folder
        ↓
Get public URL from Storage
        ↓
Insert snap into database
  • user_id from session
  • image_url from storage
  • RLS: Only owner can insert with their user_id
        ↓
Redirect to /snap/{id}
```

### 4. Staff Picks Sync

```
User navigates to /staff-picks
        ↓
Server component executes
        ↓
Call getStaffPickSnapIds()
        ↓
GitHub API (via Octokit)
  • GET /repos/{owner}/{repo}/contents/{path}
  • Returns base64 encoded favorites.json
        ↓
Decode and parse JSON
        ↓
Extract snap IDs array
        ↓
Query Supabase for snaps
  • WHERE id IN (staffPickIds)
  • JOIN with profiles
        ↓
Return data (cached for 60s)
        ↓
Render masonry grid
```

## Component Architecture

### Server Components (RSC)
```
app/
├── page.tsx                    # Home feed - fetches snaps server-side
├── staff-picks/page.tsx        # Staff picks - fetches from GitHub + DB
└── snap/[id]/page.tsx          # Snap detail - fetches single snap

Benefits:
• No JavaScript sent to client for data fetching
• Better SEO (fully rendered HTML)
• Automatic request deduplication
• Can use server-only secrets
```

### Client Components
```
components/
├── Navbar.tsx                  # Auth state, dropdown interactions
├── SnapCard.tsx                # Hover effects, animations
├── MasonryGrid.tsx             # Layout calculations
└── app/upload/page.tsx         # Form state, file upload

When to use:
• Need useState, useEffect
• Event handlers (onClick, onChange)
• Browser APIs (FileReader, navigator)
• Third-party libraries requiring client (Framer Motion)
```

## Database Schema

### Entity Relationship Diagram

```
┌─────────────────┐
│   auth.users    │ (Supabase managed)
│   - id (PK)     │
│   - email       │
│   - metadata    │
└────────┬────────┘
         │ 1
         │
         │ 1
┌────────┴────────┐
│    profiles     │
│   - id (PK,FK)  │────┐
│   - username    │    │
│   - avatar_url  │    │
│   - bio         │    │
└─────────────────┘    │
                       │ 1
                       │
                       │ *
                ┌──────┴──────┐
                │    snaps    │
                │  - id (PK)  │────┐
                │  - user_id  │    │
                │  - title    │    │
                │  - code     │    │
                │  - image    │    │
                └─────────────┘    │
                                   │ 1
                                   │
                                   │ *
                            ┌──────┴──────┐
                            │    likes    │
                            │  - id (PK)  │
                            │  - user_id  │
                            │  - snap_id  │
                            └─────────────┘
```

### Row Level Security (RLS)

```sql
-- Profiles: Anyone can view, only owner can update
CREATE POLICY "Public profiles viewable"
  ON profiles FOR SELECT USING (true);

CREATE POLICY "Users update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- Snaps: Public snaps visible to all, owner can CRUD
CREATE POLICY "Public snaps viewable"
  ON snaps FOR SELECT USING (is_public = true);

CREATE POLICY "Users CRUD own snaps"
  ON snaps FOR ALL USING (auth.uid() = user_id);

-- Storage: User folders isolated
CREATE POLICY "Users upload to own folder"
  ON storage.objects FOR INSERT
  USING (auth.uid()::text = (storage.foldername(name))[1]);
```

## Security Architecture

### Authentication Flow

```
Client
  ↓
Supabase Client (with anon key)
  ↓
Supabase Auth Service
  ↓
GitHub OAuth
  ↓
Return JWT (session token)
  ↓
Store in httpOnly cookie
  ↓
Include in all requests
```

### Authorization Layers

```
1. Edge Middleware (Route-level)
   • Checks session exists
   • Redirects unauthorized users
   • Runs on Vercel Edge

2. Row Level Security (Data-level)
   • Enforced in PostgreSQL
   • Cannot be bypassed
   • Checks auth.uid() = user_id

3. Storage Policies (File-level)
   • User-based folder access
   • Public read, private write
   • Enforced by Supabase
```

## Data Flow Patterns

### Server Component Data Fetching

```typescript
// app/page.tsx
async function HomePage() {
  const supabase = createServerSupabase()

  // Runs on server, no client JS
  const { data } = await supabase
    .from('snaps')
    .select('*, profiles(*)')
    .eq('is_public', true)

  // Passes data as props to client components
  return <MasonryGrid snaps={data} />
}
```

### Client Component State

```typescript
// components/Navbar.tsx
'use client'

function Navbar() {
  const [user, setUser] = useState(null)
  const supabase = createClientSupabase()

  useEffect(() => {
    // Runs in browser
    supabase.auth.getUser().then(setUser)
  }, [])

  // Real-time auth state
  return <nav>...</nav>
}
```

## Deployment Architecture

### Vercel Edge Network

```
                    ┌─────────────────┐
                    │   User Request  │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   Vercel Edge   │
                    │   (Closest POP) │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼────────┐  ┌────────▼────────┐  ┌───────▼────────┐
│   Middleware   │  │  Static Assets  │  │   API Routes   │
│   (Auth Check) │  │   (Cached)      │  │  (Serverless)  │
└───────┬────────┘  └─────────────────┘  └───────┬────────┘
        │                                          │
        └──────────────────┬───────────────────────┘
                           │
                  ┌────────▼────────┐
                  │  Next.js Server │
                  │   (Serverless)  │
                  └────────┬────────┘
                           │
              ┌────────────┴────────────┐
              │                         │
      ┌───────▼────────┐       ┌────────▼────────┐
      │    Supabase    │       │   GitHub API    │
      │   (Database)   │       │  (Staff Picks)  │
      └────────────────┘       └─────────────────┘
```

### Environment Variables Flow

```
Development:
  .env.local → Next.js dev server

Production:
  Vercel Dashboard → Environment Variables → Build & Runtime

Server-side only:
  • SUPABASE_SERVICE_ROLE_KEY
  • GITHUB_ACCESS_TOKEN

Client-side (NEXT_PUBLIC_*):
  • NEXT_PUBLIC_SUPABASE_URL
  • NEXT_PUBLIC_SUPABASE_ANON_KEY
  • NEXT_PUBLIC_APP_URL
```

## Performance Optimizations

### Caching Strategy

```
1. Next.js Revalidation
   • Server components: revalidate = 60s
   • Staff picks refresh every minute

2. Vercel Edge Cache
   • Static assets: Cache-Control headers
   • Image optimization: Automatic CDN

3. Browser Cache
   • Images: Aggressive caching
   • Code splitting: Per-route bundles
```

### Image Optimization Pipeline

```
User uploads image
        ↓
Supabase Storage (original)
        ↓
Next.js Image component
        ↓
Vercel Image Optimization
  • Resize to needed size
  • Convert to WebP/AVIF
  • Serve from edge CDN
        ↓
Browser receives optimized image
```

## Monitoring & Observability

### Supabase Dashboard
- Auth logs: Who signed in/out
- Database: Query performance
- Storage: Usage metrics
- Real-time: Active connections

### Vercel Analytics
- Page views & routes
- Web Vitals (LCP, FID, CLS)
- Edge function execution time
- Build logs

## Scalability Considerations

### Current Architecture Scales to:
- **Users**: 100k+ (Supabase handles millions)
- **Snaps**: Millions (PostgreSQL capacity)
- **Requests**: Vercel Edge Network handles spikes
- **Images**: Unlimited (Supabase Storage scales)

### Bottlenecks to Monitor:
- GitHub API rate limits (5000 req/hr authenticated)
- Supabase database connections (pooling)
- Storage bandwidth (upgrade tier if needed)

---

**Last Updated**: 2026-02-28
**Architecture Version**: 1.0
