# DevSnaps 🚀

A premium, full-stack web application for developers to share beautiful code snippets and terminal themes. Built with Next.js, Supabase, and Tailwind CSS.

## ✨ Features

- **Masonry Grid Layout**: Pinterest-style responsive grid for beautiful content display
- **GitHub OAuth Authentication**: Secure sign-in with GitHub
- **Real-time Updates**: Live feed of code snippets from the community
- **Staff Picks**: Curated favorites synced from a GitHub repository
- **Glassmorphism UI**: Premium dark-mode design with glassmorphic effects
- **Edge Middleware Protection**: Route protection using Vercel Edge Functions
- **Image Optimization**: Next.js Image component for fast loading
- **Syntax Highlighting**: Beautiful code rendering with react-syntax-highlighter
- **Drag & Drop Upload**: Easy image upload with preview
- **Row Level Security**: Supabase RLS for secure data access

## 🛠 Tech Stack

- **Frontend**: Next.js 15 (App Router), React 19, TypeScript
- **Styling**: Tailwind CSS, Framer Motion
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **Deployment**: Vercel
- **APIs**: GitHub API (Octokit)

## 📋 Prerequisites

- Node.js 18+ and npm
- Supabase account
- GitHub account (for OAuth)
- Vercel account (for deployment)

## 🚀 Setup Instructions

### 1. Clone and Install

\`\`\`bash
cd devsnaps
npm install
\`\`\`

### 2. Supabase Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Run the SQL schema from `supabase-setup.sql` in the Supabase SQL Editor
3. Enable GitHub OAuth in Supabase Authentication settings:
   - Go to Authentication > Providers
   - Enable GitHub provider
   - Add your GitHub OAuth credentials (see step 3)
4. Create a Storage bucket named `snap-images` and make it public

### 3. GitHub OAuth Setup

1. Go to GitHub Settings > Developer settings > OAuth Apps > New OAuth App
2. Fill in the details:
   - **Application name**: DevSnaps
   - **Homepage URL**: `http://localhost:3000` (development)
   - **Authorization callback URL**: `https://YOUR_SUPABASE_PROJECT.supabase.co/auth/v1/callback`
3. Copy the Client ID and Client Secret to Supabase Auth settings

### 4. GitHub Favorites Repository (for Staff Picks)

1. Create a public GitHub repository (e.g., `devsnaps-favorites`)
2. Create a `favorites.json` file with this structure:

\`\`\`json
{
  "snaps": [
    {
      "id": "snap-id-from-database",
      "title": "Beautiful React Hook",
      "description": "An elegant useEffect pattern",
      "language": "javascript",
      "tags": ["react", "hooks"]
    }
  ]
}
\`\`\`

3. Create a GitHub Personal Access Token:
   - Go to GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)
   - Generate new token with `repo` scope (for public repos)
   - Copy the token for environment variables

### 5. Environment Variables

Copy `.env.local.example` to `.env.local` and fill in your values:

\`\`\`bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# GitHub API (for Staff Picks)
GITHUB_ACCESS_TOKEN=your-github-personal-access-token
GITHUB_REPO_OWNER=your-github-username
GITHUB_REPO_NAME=devsnaps-favorites
GITHUB_FAVORITES_PATH=favorites.json

# App Configuration
NEXT_PUBLIC_APP_URL=http://localhost:3000
\`\`\`

### 6. Run Development Server

\`\`\`bash
npm run dev
\`\`\`

Open [http://localhost:3000](http://localhost:3000) to see your app!

## 🚢 Deployment to Vercel

### 1. Connect GitHub Repository

1. Push your code to GitHub
2. Go to [vercel.com](https://vercel.com)
3. Import your repository
4. Vercel will auto-detect Next.js settings

### 2. Environment Variables

Add all environment variables from `.env.local` to Vercel:
- Go to Project Settings > Environment Variables
- Add each variable for Production, Preview, and Development environments
- Update `NEXT_PUBLIC_APP_URL` to your Vercel domain

### 3. Update OAuth Callback

After deployment, update your GitHub OAuth App:
- Add production callback URL: `https://YOUR_SUPABASE_PROJECT.supabase.co/auth/v1/callback`
- Add Vercel domain to Supabase Auth > URL Configuration > Site URL

### 4. Deploy

\`\`\`bash
git push origin main
\`\`\`

Vercel will automatically deploy your app!

## 📁 Project Structure

\`\`\`
devsnaps/
├── app/
│   ├── auth/
│   │   ├── signin/         # Sign-in page
│   │   └── callback/       # OAuth callback handler
│   ├── upload/             # Upload snap page
│   ├── snap/[id]/          # Individual snap page
│   ├── staff-picks/        # Staff picks page
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Home feed
│   └── globals.css         # Global styles
├── components/
│   ├── Navbar.tsx          # Navigation bar
│   ├── SnapCard.tsx        # Snap card component
│   └── MasonryGrid.tsx     # Masonry grid layout
├── lib/
│   ├── supabase.ts         # Supabase client & types
│   ├── github.ts           # GitHub API integration
│   └── utils.ts            # Utility functions
├── middleware.ts           # Edge middleware for auth
├── supabase-setup.sql      # Database schema
└── package.json
\`\`\`

## 🔒 Security Features

- **Row Level Security (RLS)**: Database-level access control
- **Edge Middleware**: Protected routes for authenticated users only
- **Secure Storage**: Supabase Storage with user-based policies
- **OAuth**: No passwords, secure GitHub authentication

## 🎨 Design Features

- Dark mode optimized
- Glassmorphism effects
- Smooth transitions with Framer Motion
- Responsive masonry grid
- Custom scrollbar styling
- Gradient accents
- Hover effects and animations

## 📝 Usage

1. **Sign In**: Click "Sign In with GitHub" to authenticate
2. **Upload**: Click "Upload Snap" to share your code snippet
   - Add a title and description
   - Select the programming language
   - Paste your code
   - Upload a screenshot (theme preview)
   - Add tags and theme name
3. **Explore**: Browse the feed to discover beautiful code from other developers
4. **Staff Picks**: Check out curated favorites from the team

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - feel free to use this project for your own purposes!

## 🙏 Acknowledgments

- Next.js team for the amazing framework
- Supabase for the backend infrastructure
- Vercel for seamless deployment
- The developer community for inspiration

---

Built with ❤️ by the DevSnaps team
