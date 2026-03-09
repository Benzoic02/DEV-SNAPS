# ⚡ Quick Start Guide

Get DevSnaps running locally in 5 minutes!

## Prerequisites

- Node.js 18+
- A Supabase account
- A GitHub account

## Step 1: Install Dependencies

```bash
cd devsnaps
npm install
```

## Step 2: Set Up Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to SQL Editor and run the entire `supabase-setup.sql` file
3. Go to Storage and verify the `snap-images` bucket was created
4. Go to Settings > API and copy your:
   - Project URL
   - `anon` public key
   - `service_role` key (keep secret!)

## Step 3: Configure GitHub OAuth

1. Go to GitHub Settings > Developer settings > OAuth Apps
2. Create New OAuth App:
   - **Homepage URL**: `http://localhost:3000`
   - **Callback URL**: Get this from Supabase Auth > Providers
3. Copy Client ID and Client Secret
4. Paste them in Supabase Auth > Providers > GitHub

## Step 4: Create Environment File

Copy `.env.local.example` to `.env.local`:

```bash
cp .env.local.example .env.local
```

Fill in your values:

```env
NEXT_PUBLIC_SUPABASE_URL=your-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Optional: For Staff Picks feature
GITHUB_ACCESS_TOKEN=your-github-token
GITHUB_REPO_OWNER=your-username
GITHUB_REPO_NAME=devsnaps-favorites
```

## Step 5: Run the App

```bash
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000) 🎉

## First Steps

1. **Sign in** with GitHub
2. **Upload your first snap**:
   - Take a screenshot of beautiful code
   - Fill in the title and description
   - Paste the code snippet
   - Upload!
3. **Explore** the feed

## Next Steps

- See `README.md` for full features
- See `DEPLOYMENT.md` for production deployment
- Customize the design in `app/globals.css` and `tailwind.config.ts`

## Troubleshooting

### Can't sign in?
- Check GitHub OAuth callback URL matches Supabase
- Verify Client ID/Secret are correct in Supabase

### Images won't upload?
- Verify Storage bucket `snap-images` exists
- Check bucket is set to public
- Verify RLS policies were created

### Build errors?
- Run `npm install` again
- Check Node.js version: `node -v` (should be 18+)
- Delete `.next` folder and try again

---

Need more help? Check the full README.md or DEPLOYMENT.md
