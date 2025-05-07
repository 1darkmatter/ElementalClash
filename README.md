# Elemental Clash v0.0.1

**Authors:**  
- David Magnabosco | PSU – DART 205  
- Dr. Greg O’Toole  

**Date:** May 7, 2025  

---

## Table of Contents

1. [Overview](#overview)  
2. [Features](#features)  
3. [Getting Started](#getting-started)  
   - [Prerequisites](#prerequisites)  
   - [Installation](#installation)  
   - [Running the Game](#running-the-game)  
4. [Gameplay](#gameplay)  
5. [Project Structure](#project-structure)  
6. [Dependencies](#dependencies)  

---

## Overview

Elemental Clash is a turn‑based, deck‑building card battle game built with the Processing environment. You face off against the AI‑controlled **Green Goblin**, playing elemental cards—each with unique damage values, effects, and initiative. Manage your Health Points (HP) and Mana strategically to overcome status effects and claim victory!

---

## Features

- **Turn‑Based Combat**  
  Players alternate turns; cards with higher initiative resolve first.

- **AI Opponent**  
  The Green Goblin employs basic decision logic to challenge you.

- **Resource Management**  
  Balance HP and Mana to optimize each turn.

- **Card Effects & Statuses**  
  - Direct Damage & Healing  
  - Freeze, Burn, Shamed  
  - Attack/Heal Disabled  
  - Mana‑Regen Skip  
  - Mana Drain  

- **Deck & Hand Management**  
  - Draw up to 10 cards per turn  
  - Discard pile tracking  
  - Limited shuffle charges  

- **Dynamic UI**  
  - Clear display of Player/Enemy HP, Mana, statuses, and hand size  
  - Scrollable Action Log with keyword highlighting  
  - Hover‑zoom on cards in hand  
  - Animated Goblin avatar with changing expressions and background  
  - Visual feedback: damage flashes, turn indicators, battle announcements  

- **Menus & Persistence**  
  - In‑game menu and settings (difficulty adjustment)  
  - “How to Play” help panel  
  - Save/Load game state  

- **Visual Flair**  
  - High‑quality card art and background images  
  - GIF animations for victory and defeat sequences  

---

## Getting Started

### Prerequisites

- **Processing IDE** v4.x  
- **GIF Animation Library** by Extrapixel  

### Installation

1. **Clone the repository**  
   [git clone https://github.com/yourname/ElementalClash.git](https://github.com/1darkmatter/ElementalClash.git)
2. Move into your Processing sketchbook
3. Copy the Elemental_Card_Game_v0.0.1 folder into your Processing sketchbook directory.

Install the GIF Animation library

Open Processing IDE

Go to Sketch → Import Library… → Add Library…

Search for GIF Animation by Extrapixel and install it

Running the Game
Open Processing IDE.

Navigate to Elemental_Card_Game_v0.0.1/Main.pde.

Click the > Run button.

Gameplay
Draw Phase
Draw cards until you reach your hand limit.

Play Phase
Spend Mana to play cards—cards with higher initiative will act first.

Resolve Phase
Effects execute in initiative order.

Status Management
Monitor and react to Freeze, Burn, and other status effects.

Victory Condition
Reduce the Green Goblin’s HP to zero before yours reaches zero.

## Project Structure

```Elemental_Card_Game_v0.0.1/
├── AssetLoader.pde         # Loads images, GIFs & fonts
├── Button.pde              # UI Button class
├── Card.pde                # Card class & rendering logic
├── data/
│   └── img/
│       ├── cards/          # Elemental card artwork (.png)
│       │   ├── ArcticDescent.png
│       │   └── XelythFieryFeast.png
│       └── core/           # UI assets & character art
│           ├── backcard_season1_goblins_skyfall.png
│           ├── background.png
│           └── character/
│               └── goblin/ # Goblin expression images
│                   ├── goblin_angry.png
│                   └── goblin_smug.png
├── Enemy.pde               # Enemy AI class & logic
├── Main.pde                # Entry point: game loop & state management
├── Panels.pde              # Menus, settings, help & game‑over screens
├── Persistence.pde         # Save/Load handlers
├── Player.pde              # Player class & mechanics
├── UIHelpers.pde           # Drawing utility functions
└── sketch.properties       # Processing IDE configuration
```

Note: Backup folders have been excluded to keep the distribution clean.

Dependencies
Processing IDE v4.x

GIF Animation Library by Extrapixel

Enjoy Elemental Clash—may your strategy be ever‑elemental!
