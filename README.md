{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs24 \cf0 # Elemental Clash\'a0v0.0.1\
\
**Authors:**  \
- David\'a0Magnabosco\'a0|\'a0PSU\'a0\'96\'a0DART\'a0205  \
- Dr.\'a0Greg\'a0O\'92Toole  \
\
**Date:** May\'a07,\'a02025  \
\
---\
\
## Table of Contents\
\
1. [Overview](#overview)  \
2. [Features](#features)  \
3. [Getting Started](#getting-started)  \
   - [Prerequisites](#prerequisites)  \
   - [Installation](#installation)  \
   - [Running the Game](#running-the-game)  \
4. [Gameplay](#gameplay)  \
5. [Project Structure](#project-structure)  \
6. [Dependencies](#dependencies)  \
\
---\
\
## Overview\
\
Elemental\'a0Clash is a turn\uc0\u8209 based, deck\u8209 building card battle game built with the Processing environment. You face off against the AI\u8209 controlled **Green Goblin**, playing elemental cards\'97each with unique damage values, effects, and initiative. Manage your Health Points (HP) and Mana strategically to overcome status effects and claim victory!\
\
---\
\
## Features\
\
- **Turn\uc0\u8209 Based Combat**  \
  Players alternate turns; cards with higher initiative resolve first.\
\
- **AI Opponent**  \
  The Green Goblin employs basic decision logic to challenge you.\
\
- **Resource Management**  \
  Balance HP and Mana to optimize each turn.\
\
- **Card Effects & Statuses**  \
  - Direct Damage & Healing  \
  - Freeze, Burn, Shamed  \
  - Attack/Heal Disabled  \
  - Mana\uc0\u8209 Regen Skip  \
  - Mana Drain  \
\
- **Deck & Hand Management**  \
  - Draw up to 10 cards per turn  \
  - Discard pile tracking  \
  - Limited shuffle charges  \
\
- **Dynamic UI**  \
  - Clear display of Player/Enemy HP, Mana, statuses, and hand size  \
  - Scrollable Action Log with keyword highlighting  \
  - Hover\uc0\u8209 zoom on cards in hand  \
  - Animated Goblin avatar with changing expressions and background  \
  - Visual feedback: damage flashes, turn indicators, battle announcements  \
\
- **Menus & Persistence**  \
  - In\uc0\u8209 game menu and settings (difficulty adjustment)  \
  - \'93How to Play\'94 help panel  \
  - Save/Load game state  \
\
- **Visual Flair**  \
  - High\uc0\u8209 quality card art and background images  \
  - GIF animations for victory and defeat sequences  \
\
---\
\
## Getting Started\
\
### Prerequisites\
\
- **Processing IDE** v4.x  \
- **GIF Animation Library** by Extrapixel  \
\
### Installation\
\
1. **Clone the repository**  \
   [git clone https://github.com/yourname/ElementalClash.git](https://github.com/1darkmatter/ElementalClash.git)\
2. Move into your Processing sketchbook\
3. Copy the Elemental_Card_Game_v0.0.1 folder into your Processing sketchbook directory.\
\
Install the GIF Animation library\
\
Open Processing IDE\
\
Go to Sketch \uc0\u8594  Import Library\'85 \u8594  Add Library\'85\
\
Search for GIF Animation by Extrapixel and install it\
\
Running the Game\
Open Processing IDE.\
\
Navigate to Elemental_Card_Game_v0.0.1/Main.pde.\
\
Click the > Run button.\
\
Gameplay\
Draw Phase\
Draw cards until you reach your hand limit.\
\
Play Phase\
Spend Mana to play cards\'97cards with higher initiative will act first.\
\
Resolve Phase\
Effects execute in initiative order.\
\
Status Management\
Monitor and react to Freeze, Burn, and other status effects.\
\
Victory Condition\
Reduce the Green Goblin\'92s HP to zero before yours reaches zero.\
\
Project Structure\
Elemental_Card_Game_v0.0.1/\
\uc0\u9500 \u9472 \u9472  AssetLoader.pde         # Loads images, GIFs & fonts\
\uc0\u9500 \u9472 \u9472  Button.pde              # UI Button class\
\uc0\u9500 \u9472 \u9472  Card.pde                # Card class & rendering logic\
\uc0\u9500 \u9472 \u9472  data/\
\uc0\u9474    \u9492 \u9472 \u9472  img/\
\uc0\u9474        \u9500 \u9472 \u9472  cards/          # Elemental card artwork (.png)\
\uc0\u9474        \u9474    \u9500 \u9472 \u9472  ArcticDescent.png\
\uc0\u9474        \u9474    \u9492 \u9472 \u9472  XelythFieryFeast.png\
\uc0\u9474        \u9492 \u9472 \u9472  core/           # UI assets & character art\
\uc0\u9474            \u9500 \u9472 \u9472  backcard_season1_goblins_skyfall.png\
\uc0\u9474            \u9492 \u9472 \u9472  character/\
\uc0\u9474                \u9492 \u9472 \u9472  goblin/ # Goblin expression images\
\uc0\u9474                    \u9500 \u9472 \u9472  goblin_angry.png\
\uc0\u9474                    \u9492 \u9472 \u9472  goblin_smug.png\
\uc0\u9500 \u9472 \u9472  Enemy.pde               # Enemy AI class & logic\
\uc0\u9500 \u9472 \u9472  Main.pde                # Entry point: game loop & state management\
\uc0\u9500 \u9472 \u9472  Panels.pde              # Menus, settings, help & game\u8209 over screens\
\uc0\u9500 \u9472 \u9472  Persistence.pde         # Save/Load handlers\
\uc0\u9500 \u9472 \u9472  Player.pde              # Player class & mechanics\
\uc0\u9500 \u9472 \u9472  UIHelpers.pde           # Drawing utility functions\
\uc0\u9492 \u9472 \u9472  sketch.properties       # Processing IDE configuration\
\
Note: Backup folders have been excluded to keep the distribution clean.\
\
Dependencies\
Processing IDE v4.x\
\
GIF Animation Library by Extrapixel\
\
Enjoy Elemental Clash\'97may your strategy be ever\uc0\u8209 elemental!}