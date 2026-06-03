# MobStats - Spells & Abilities Extension ⚔️🔮

This is a modular fork of the original **MobStats** addon by Refaim. It introduces a dynamic combat log scanner that creates a custom "bestiary" or "Pokédex" of creature abilities as you fight them throughout Azeroth.

---

## 🚀 Change Description
A modular extension has been designed and implemented to dynamically record the abilities used by nearby creatures by scanning the English combat log. The system persistently stores this data within the user's `WTF` folder, utilizes safe hooks with the `GameTooltip` to prevent memory corruption across other native modules, and includes smart filters to avoid false positives triggered by player interactions (PvP/Duels) or the user's own abilities.

---

## 🛠️ Architecture & Core Components

### 1. File: `MobStats.toc`
* **Purpose:** Declares data persistence on the local drive (`SavedVariables`) and instructs the client to load the new scanning module sequentially upon startup.

### 2. New File: `MobSpellsCore.lua`
* **Purpose:** A completely new file designed in a decoupled (modular) fashion to ensure native functions within the original addon's internal files remain safe and unaltered. It contains the regex string-matching engine for the classic combat log, target validation logic, and database maintenance console commands.

---

## 🎮 In-Game Commands
You can maintain your learned spell database using the native addon slash command:

* `/mobstats reset` — Wipes the learned monster abilities database completely to rebuild it from scratch.
* `/mobstats spell reset` — Alternate command to wipe the saved spell database.

---

## 📥 Installation (For Players)
If you want to use this specific extended version with the spell-learning feature:

1. Click the green **Code** button at the top right of this page and select **Download ZIP**.
2. Extract the contents into your `\Interface\AddOns\` directory.
3. **Important:** Rename the extracted folder from `MobStats-master` to just `MobStats`.
4. Log into the game and enjoy hunting!

## 🤝 Credits & Acknowledgments
This extension wouldn't be possible without the incredible foundation and support from:

* **Refaim** — The original creator and lead developer of **MobStats**. Thank you for building such a robust, clean, and well-structured core architecture that allows modular features like this to be integrated seamlessly.
* **Claude** — For the technical assistance, engineering advice, and optimization of the Lua pattern matching logic used to capture complex combat log events.