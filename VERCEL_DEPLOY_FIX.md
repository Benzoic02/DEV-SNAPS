# 🔧 Vercel Deployment Fix

## Problem

You're getting this error:
```
> Couldn't find any `pages` or `app` directory. Please create one under the project root
Error: Command "next build" exited with 1
```

## Root Cause

Vercel is looking for the Next.js app in the wrong directory. You need to deploy from the **devsnaps** folder, not the parent FridayWorkspace folder.

## ✅ Solution: Option 1 - Deploy Correct Directory

### If deploying via Vercel Dashboard:

1. **Delete the current Vercel project** (if you already created one)
   - Go to your project settings
   - Scroll to "Delete Project"

2. **Re-import your repository**
   - Go to Vercel dashboard
   - Click "Add New" → "Project"
   - Import your GitHub repository

3. **Configure Root Directory** (THIS IS THE KEY STEP!)
   - In the import screen, look for "Root Directory"
   - Click "Edit" next to it
   - Select or type: `devsnaps`
   - This tells Vercel where your Next.js app actually is

4. **Set Environment Variables**
   - Add all your Supabase credentials
   - See DEPLOYMENT.md for the full list

5. **Deploy!**

### If deploying via Vercel CLI:

```bash
# Navigate to the devsnaps folder first!
cd "C:\Users\neonn\OneDrive\Documents\FridayWorkspace\devsnaps"

# Then deploy
vercel

# Follow the prompts
```

## ✅ Solution: Option 2 - Move Files Up

If you want to deploy from the workspace root, move everything from devsnaps up one level:

```bash
# DON'T DO THIS if you want to keep the devsnaps folder structure
# But if you want everything in the workspace root:

cd "C:\Users\neonn\OneDrive\Documents\FridayWorkspace"
mv devsnaps/* .
mv devsnaps/.* .  # Move hidden files
rmdir devsnaps
```

Then push to GitHub and deploy normally.

## ✅ Solution: Option 3 - Use vercel.json (If needed)

If you absolutely must deploy from the parent directory, create this file in the **workspace root** (not in devsnaps):

**File: C:\Users\neonn\OneDrive\Documents\FridayWorkspace\vercel.json**
```json
{
  "buildCommand": "cd devsnaps && npm run build",
  "outputDirectory": "devsnaps/.next",
  "installCommand": "cd devsnaps && npm install",
  "framework": "nextjs"
}
```

## 🎯 Recommended Approach

**Use Option 1** - It's the cleanest and most straightforward:

1. Make sure your GitHub repo has the devsnaps folder
2. In Vercel import settings, set Root Directory to `devsnaps`
3. That's it!

## 📋 Verification Checklist

Before deploying, verify:

- [ ] You have a `devsnaps` folder
- [ ] Inside `devsnaps` there's an `app` folder
- [ ] Inside `devsnaps` there's a `package.json`
- [ ] Inside `devsnaps` there's a `next.config.js`

Run this to verify:
```bash
ls "C:\Users\neonn\OneDrive\Documents\FridayWorkspace\devsnaps" | findstr "app package.json next.config.js"
```

Should output:
```
app
next.config.js
package.json
```

## 🚀 Correct GitHub Structure

Your repository should look like this:

```
your-repo/
└── devsnaps/           ← Set this as Root Directory in Vercel
    ├── app/
    ├── components/
    ├── lib/
    ├── package.json
    ├── next.config.js
    └── ...
```

NOT like this:
```
your-repo/
├── app/               ← This won't work
├── components/
└── ...
```

## 🔍 Debugging

If still not working:

1. **Check your Git repository structure** on GitHub
   - Does it have a `devsnaps` folder?
   - Or are all files in the root?

2. **Check Vercel build logs**
   - What directory is it trying to build from?
   - Look for the "Root Directory" setting

3. **Verify locally**
   ```bash
   cd devsnaps
   npm run build
   ```
   If this works locally, it should work on Vercel (with correct Root Directory)

## 💡 Quick Fix Command

If you want to move everything to the workspace root (simpler structure):

```bash
cd "C:\Users\neonn\OneDrive\Documents\FridayWorkspace"

# Create a backup first
cp -r devsnaps devsnaps-backup

# Move everything up
cd devsnaps
mv * ..
mv .* .. 2>/dev/null || true
cd ..
rm -rf devsnaps

# Now push to GitHub and deploy
git add .
git commit -m "Move files to root for Vercel deployment"
git push
```

Then deploy without specifying a Root Directory.

## ✅ Final Steps

After fixing the directory issue:

1. Push your code to GitHub
2. In Vercel, set Root Directory to `devsnaps` (or move files to root)
3. Add environment variables
4. Deploy!

Your build should succeed! 🎉

---

**Still stuck?** Share your:
1. GitHub repository structure (screenshot or `tree` output)
2. Vercel build logs
3. Whether you want to keep the devsnaps folder or move everything to root
