# Morning Reset — Build Checklist

No external packages. Pure SwiftUI. Estimated time: 5–10 minutes.

---

## Requirements

| Tool    | Minimum version |
|---------|----------------|
| macOS   | 14 Sonoma      |
| Xcode   | 15             |
| iOS sim | 17             |

---

## Step 1 — Get the code

```bash
git clone https://github.com/canayan1/MorningReset
cd MorningReset
```

Or download ZIP from GitHub → Code → Download ZIP, then unzip.

---

## Step 2 — Create a new Xcode project

1. Open **Xcode**
2. **File → New → Project**
3. Choose **iOS → App** → Next
4. Fill in:
   - Product Name: `MorningReset`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck **Include Tests**
5. Save **inside** the cloned `MorningReset/` folder
   → This creates `MorningReset.xcodeproj`

---

## Step 3 — Delete Xcode's placeholder files

Xcode auto-generates files you don't need. Delete both:

- `ContentView.swift` → Right-click → Delete → Move to Trash
- `MorningResetApp.swift` (the one Xcode created at root level) → Delete → Move to Trash

> Keeping either will cause a "multiple @main" build error.

---

## Step 4 — Add the source files

1. Right-click the **MorningReset** group in the sidebar
2. Click **"Add Files to 'MorningReset'..."**
3. Navigate into `MorningReset/MorningReset/`
4. Select all four folders: **App**, **State**, **Data**, **Screens**
5. At the bottom of the dialog:
   - **"Copy items if needed"** → **unchecked**
   - **"Create groups"** → **selected**
   - **"Add to targets: MorningReset"** → **checked**
6. Click **Add**

You should now see 7 Swift files in the sidebar.

---

## Step 5 — Set the deployment target

1. Click the **MorningReset** project (top of sidebar, blue icon)
2. Select the **MorningReset** target → **General** tab
3. Set **Minimum Deployments** to **iOS 17.0**

Required because `@Observable` is iOS 17+.

---

## Step 6 — Build and run

1. Select an **iPhone simulator** (iPhone 15 or 16)
2. Press **Cmd + R**

---

## What you should see

- Alarm screen with a **Start** button
- Tapping Start enters a 5-question morning quiz
- Answering each question auto-advances to the next
- Going idle for 60 seconds returns to the alarm screen
- After all 5 questions: Results screen (mode + suggestion + warning)
- Tapping Continue: Action screen (Learn / Choose Mode / Skip)

---

## Troubleshooting

**"Multiple @main attributes" error**
→ Delete the `MorningResetApp.swift` Xcode generated. Keep only the one in `App/`.

**"Cannot find type" errors**
→ A file wasn't added to the target. Select it in the sidebar → File Inspector (right panel) → check **Target Membership: MorningReset**.

**Blank screen on launch**
→ Make sure `MorningResetApp.swift` in `App/` is the only file with `@main`.
