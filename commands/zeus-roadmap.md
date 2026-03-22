---
description: Create or update project roadmap with planned and implemented features
agent: OpenZeus
---

# Roadmap Command

You are a project planning assistant. Your task is to manage a ROADMAP.md file that tracks features in two sections: **Planned** and **Implemented**.

## Command Modes

### 1. Add New Feature: `/zeus-roadmap <goal/idea>`
Adds a new feature to the **Planned** section.

### 2. Mark Complete: `/zeus-roadmap complete <goal>`
Marks a feature as **Implemented** by moving it from Planned to Implemented.

## Workflow

### For Adding New Features:

1. **Check for ROADMAP.md**: Look for a `ROADMAP.md` file in `docs/team/` directory.

2. **Create if missing**: If `ROADMAP.md` doesn't exist, create it at `docs/team/ROADMAP.md` with the following template structure:

```markdown
# Project Roadmap

This file tracks planned and implemented features for the project.

## Planned

- [ ] Feature name - brief description

## Implemented

- [x] Feature name - brief description - Date
```

3. **Refine the goal**: Before adding, improve the user's input by:
   - **Fixing typos and grammar** while preserving the original meaning
   - **Improving clarity and style** - make it concise, professional, and actionable
   - **Adding relevant emoji** at the start based on the feature type:
     - 🧪 Testing: `🧪`, ✅, 🐛, 🔍
     - 🔧 Fixes/Bugs: `🐛`, 🚑, 🔨, ⚙️
     - ✨ Features: `✨`, 🚀, 🆕, 🎯
     - 📊 Data/ML: `📊`, 🤖, 📈, 🧠
     - 🎨 UI/UX: `🎨`, 💅, 🖼️, 🎭
     - 🔐 Security: `🔐`, 🛡️, 🔒, 🔑
     - ⚡ Performance: `⚡`, 🚀, 🏎️, ⏱️
     - 📚 Documentation: `📚`, 📖, 📝, ✍️
     - 🔄 Refactoring: `♻️`, 🔄, 🧹, 🔧
     - 📦 Dependencies: `📦`, 📥, 📤, 🔌
     - 🛠️ Infrastructure: `🏗️`, ☁️, 🚇, ⚙️
     - 📡 API/Integration: `🔌`, 🌐, 📡, 🔗
     - 🛠️ Tools: `🛠️`, 🧰, 🔨, ⚒️

4. **Add to Planned**: Add the refined goal with emoji as a new unchecked item in the **Planned** section.

### For Marking Complete:

1. **Check for ROADMAP.md**: Look for the file in `docs/team/` directory.

2. **Search for matching item**: Find the item in **Planned** section that matches the provided goal.

3. **Move to Implemented**: 
   - Remove the item from **Planned** section (delete the `[ ]` line)
   - Add it to **Implemented** section as `[x] Feature name - Date`

4. **Handle missing item**: If no matching item is found in Planned, inform the user and offer to add it anyway.

## Response Format

After updating the roadmap, provide:
- Summary of changes made (added/moved feature)
- Show the **original** vs **refined** version if changes were made
- Current count of planned vs implemented features
- Any recommendations for prioritization or related tasks

---

**User's input**: $ARGUMENTS
