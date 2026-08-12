#!/usr/bin/env sh
set -eu

if git diff --cached --quiet; then
  echo "No staged changes. Nothing to generate."
  exit 0
fi

echo "Generating commit message with Claude..."

recent="$(git log --oneline -20 2>/dev/null)"
diff="$(git diff --cached)"

prompt="$(printf 'Recent commit messages in this repo (for style reference):\n%s\n\nStaged diff:\n%s\n' "$recent" "$diff")"

message="$(printf '%s' "$prompt" | claude -p "Generate a git commit message for these staged changes. Match the style of the recent commit messages shown above as closely as possible, including their casing. Keep it short and concise. Output ONLY the raw commit message text, no markdown, no code blocks, no backticks, no explanations." --model sonnet --output-format text)"

subject="$(printf '%s\n' "$message" | sed -n '1{s/[[:space:]]*$//;p;q}')"
printf '%s' "$subject" | wl-copy

echo "Copied suggested commit message to clipboard:"
printf '%s\n' "$message"
