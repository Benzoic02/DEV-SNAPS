# DevSnaps 🎨

> A premium, Pinterest-style platform for developers to share beautiful code snippets and terminal themes.

![DevSnaps Banner](https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1200&h=400&fit=crop)

## ✨ Features

### 🎯 Core Functionality
- **Masonry Grid Feed** - Beautiful, responsive Pinterest-style layout for snaps
- **Drag & Drop Upload** - Seamless image upload directly to Supabase Storage
- **Syntax Highlighting** - Gorgeous code rendering with Atom One Dark theme
- **GitHub OAuth** - Secure authentication powered by Supabase Auth
- **Staff Picks** - Curated collection synced dynamically from GitHub
- **Like System** - Engage with community through likes and favorites

### 🔒 Security & Performance
- **Row Level Security (RLS)** - User data protection at the database level
- **Edge Middleware** - Authentication protection on sensitive routes
- **Server-Side Rendering** - Fast initial page loads with Next.js App Router
- **Image Optimization** - Automatic image optimization via Next.js Image
- **Caching** - Smart caching for GitHub API and database queries

### 🎨 Premium UI/UX
- **Dark Mode** - Sleek dark theme with purple/pink gradients
- **Glassmorphism** - Modern frosted glass UI effects
- **Smooth Animations** - Framer Motion for buttery transitions
- **Responsive Design** - Mobile-first, works beautifully on all devices
- **Accessibility** - Semantic HTML and ARIA labels

---

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Supabase account
- GitHub account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/devsnaps.git
cd devsnaps
```

2. **Install dependencies**
```bash
npm install
```

3. **Set up environment variables**
```bash
cp .env.local.example .env.local
```

Edit `.env.local` with your Supabase credentials:
```env
NEXT_PUBLIC_SUPABASE_URL=https://yourproject.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
NEXT_PUBLIC_GITHUB_OWNER=your-github-username
NEXT_PUBLIC_GITHUB_REPO=devsnaps-favorites
```

4. **Run database migrations**

Go to Supabase Dashboard → SQL Editor and run `supabase-setup-enhanced.sql`

5. **Start development server**
```bash
npm run dev
```

Visit `http://localhost:3000` 🎉

---

## 📚 Documentation

- **[Complete Setup Guide](./COMPLETE_SETUP_GUIDE.md)** - Detailed setup instructions
- **[Architecture Overview](./ARCHITECTURE.md)** - System design and architecture (if exists)
- **[API Reference](./API.md)** - API endpoints and usage (if needed)

---

## 🏗️ Tech Stack

### Frontend
- **Next.js 15** - React framework with App Router
- **React 19** - Latest React with Server Components
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first CSS framework
- **Framer Motion** - Animation library
- **Lucide Icons** - Beautiful icon set

### Backend & Database
- **Supabase** - Backend-as-a-Service
  - PostgreSQL database
  - Authentication (GitHub OAuth)
  - File storage
  - Row Level Security
- **GitHub API** - Staff picks integration via Octokit

### Deployment
- **Vercel** - Hosting and Edge Functions
- **GitHub** - Version control and CI/CD

### Code Quality
- **ESLint** - Linting
- **Prettier** - Code formatting (if configured)
- **TypeScript** - Type checking

---

## 📁 Project Structure

```
devsnaps/
├── app/                          # Next.js App Router
│   ├── page.tsx                  # Homepage with feed
│   ├── upload/                   # Upload page
│   ├── staff-picks/              # Staff picks page
│   ├── snap/[id]/                # Individual snap page
│   ├── auth/                     # Authentication pages
│   └── layout.tsx                # Root layout
│
├── components/                   # React components
│   ├── feed/                     # Feed components
│   │   ├── SnapsFeed.tsx         # Main feed with masonry
│   │   └── SnapCard.tsx          # Individual snap card
│   └── upload/                   # Upload components
│       └── UploadForm.tsx        # Upload form with drag-drop
│
├── lib/                          # Utility functions
│   ├── supabase.ts               # Supabase client setup
│   ├── github-staff-picks.ts     # GitHub API integration
│   └── utils.ts                  # Helper functions
│
├── middleware.ts                 # Edge Middleware (auth)
├── supabase-setup-enhanced.sql   # Database schema
├── favorites.json                # Example staff picks
└── .env.local.example            # Environment variables template
```

---

## 🎯 Key Features Explained

### 1. Masonry Grid Layout

The feed uses `react-masonry-css` for a Pinterest-style layout that adapts to different screen sizes:

```tsx
<Masonry
  breakpointCols={{
    default: 3,
    1536: 3,
    1280: 3,
    1024: 2,
    768: 2,
    640: 1,
  }}
>
  {snaps.map(snap => <SnapCard key={snap.id} snap={snap} />)}
</Masonry>
```

### 2. Drag & Drop Upload

Upload component supports both drag-and-drop and click-to-browse:

- Validates file type (images only)
- Checks file size (5MB max)
- Shows live preview
- Uploads to Supabase Storage under user's folder

### 3. GitHub Staff Picks Integration

Staff picks are automatically synced from a public GitHub repository:

1. Create a `favorites.json` file in a public repo
2. Configure environment variables
3. DevSnaps fetches and displays picks every 5 minutes

### 4. Row Level Security

All database tables have RLS policies:

```sql
-- Users can only update their own snaps
CREATE POLICY "Users can update their own snaps"
  ON snaps FOR UPDATE
  USING (auth.uid() = user_id);
```

### 5. Edge Middleware Protection

Protected routes (`/upload`, `/settings`) require authentication:

```typescript
export async function middleware(req: NextRequest) {
  const supabase = createMiddlewareClient({ req, res })
  const { data: { session } } = await supabase.auth.getSession()

  if (isProtectedPath && !session) {
    return NextResponse.redirect(new URL('/auth/signin', req.url))
  }
}
```

---

## 🔧 Configuration

### Supabase Tables

- **profiles** - User profiles (auto-created on signup)
- **snaps** - Code snippets and screenshots
- **likes** - Like relationships
- **storage.objects** - Image storage (snap-images bucket)

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | ✅ | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ✅ | Supabase public key |
| `NEXT_PUBLIC_GITHUB_OWNER` | ✅ | GitHub repo owner |
| `NEXT_PUBLIC_GITHUB_REPO` | ✅ | GitHub repo name |
| `GITHUB_TOKEN` | ⚪ | GitHub PAT (optional, for higher rate limits) |

---

## 🚢 Deployment

### Deploy to Vercel

1. Push your code to GitHub
2. Import project in Vercel
3. Add environment variables
4. Deploy!

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/yourusername/devsnaps)

### Update GitHub OAuth

After deployment, update your GitHub OAuth App:
- Homepage URL: `https://your-domain.vercel.app`
- Callback URL: Keep the Supabase callback URL

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Supabase** - Amazing backend platform
- **Vercel** - Best deployment experience
- **Next.js Team** - Incredible framework
- **Tailwind CSS** - Utility-first CSS
- **React Syntax Highlighter** - Beautiful code rendering

---

## 📧 Support

- **Documentation**: [Complete Setup Guide](./COMPLETE_SETUP_GUIDE.md)
- **Issues**: [GitHub Issues](https://github.com/yourusername/devsnaps/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/devsnaps/discussions)

---

## 🎨 Screenshots

### Homepage Feed
![Homepage](https://via.placeholder.com/800x500?text=Homepage+Feed)

### Upload Page
![Upload](https://via.placeholder.com/800x500?text=Upload+Page)

### Staff Picks
![Staff Picks](https://via.placeholder.com/800x500?text=Staff+Picks)

---

Made with ❤️ by the DevSnaps community

**Star ⭐ this repo if you find it useful!**
