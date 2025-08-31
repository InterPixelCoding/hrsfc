#!/bin/bash
set -e

echo "=== Step 1: Installing Git LFS (requires sudo) ==="
if ! command -v git-lfs &> /dev/null; then
    sudo dnf install -y git-lfs
    git lfs install
else
    echo "Git LFS already installed."
    git lfs install
fi

echo "=== Step 2: Finding files > 40MB ==="
# Ensure .gitattributes exists (so grep won’t fail)
touch .gitattributes

# Track large files by extension if not already tracked
while IFS= read -r -d '' file; do
    ext="${file##*.}"
    pattern="*.${ext}"

    if ! grep -qF "$pattern" .gitattributes; then
        echo "Tracking $pattern with Git LFS"
        git lfs track "$pattern"
    else
        echo "Already tracking $pattern"
    fi

    git add "$file"
done < <(find . -type f -size +40M ! -path "./.git/*" -print0)

echo "=== Step 3: Adding .gitattributes ==="
git add .gitattributes

echo "=== Step 4: Ensuring README.md exists ==="
if [ ! -f README.md ]; then
    cat > README.md <<EOF
# Repository with Git LFS

This repository uses **Git Large File Storage (LFS)** for files larger than 40MB.  
To properly clone and use the files, make sure you have Git LFS installed:

\`\`\`bash
git lfs install
git clone <repo-url>
\`\`\`

Without Git LFS, you will only see small text pointer files instead of the actual data.
EOF
    git add README.md
    echo "Created README.md"
fi

echo "=== Step 5: Committing changes ==="
if git diff --cached --quiet; then
    echo "No changes to commit."
else
    git commit -m "Setup Git LFS (track >40MB files and add README)"
fi

echo "=== Step 6: Pushing to remote ==="
git push -u origin main

echo "✅ Done!"
