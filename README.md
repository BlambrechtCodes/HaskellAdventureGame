# Haskell Adventure Game — Wanderer of the Foreign Land

## Assignment Overview

This is a **text-based adventure game** written in Haskell for the CS 421
programming-languages assignment. You play as a wanderer who has awakened in
a foreign, haunted land. The only way home is an ancient gate sealed by three
relics — the **Wishbone**, the **Coin**, and the **Star**. You must travel
through dangerous locations, fight enemies, collect relics, win three
battles, and finally defeat the **Hollow King** boss to open the gate and win
the game. If your health drops to zero, you lose.

## Assignment Goals (Requirements Covered)

| Requirement | How it is implemented |
|-------------|-----------------------|
| **Text-based adventure game** | All interaction happens through plain-text menus and prompts in the terminal |
| **10+ choices** | Character class selection; 6 location/menu options; 4 combat options per fight; boss-fight options; rest/status/quit — well over 10 distinct choices across a playthrough |
| **User input** | The player types their name, character class, and every menu/combat choice via `getLine` |
| **Random mechanics** | Random enemy encounters, random damage variance, 15% attack-miss chance, 25% relic drop chance, random location events, 50% flee success chance |
| **Deterministic mechanics** | Class base stats are fixed (Brute 12 HP/3 STR, Mage 6 HP/6 STR, Assault 9 HP/4 STR); resting always heals exactly 4 HP; the boss appears after exactly 3 victories; story progression follows your choices |

The game uses **both** random and deterministic systems, satisfying the
"Random OR Deterministic (or both)" requirement.

## How to Build and Run

```bash

# In your terminal, before going to the GHCI shell, import Random
stack ghci --package random

# Compile the Program in GHCI
:l AdventureGame.hs

# Run the main Function to start the game
:main
```

## How to Play

1. Run the program and enter your name.
2. Choose a character class: **Brute** (tough), **Mage** (strong but fragile), or **Assault** (balanced).
3. From the location menu choose where to travel: Dark Forest, Crystal Caves, or Ancient Ruins — or rest at camp, check your status, or quit.
4. When an enemy appears, fight it: Attack, Defend, or try to Flee.
5. Win 3 battles to face the boss, the Hollow King. Defeat him to win the game.
6. Reach 0 HP at any point and the game is over.

## Files

- `AdventureGame.hs` — Full Haskell implementation. The commented design template (plot, classes, random vs deterministic mechanics, win/loss conditions, choice list) lives at the top of this file.
- `README.md` — This file.

## Design Highlights (full details in the comment block of `AdventureGame.hs`)

- **Plot:** Wandering a foreign land to reclaim the three relics and escape through the gate.
- **Character classes:** Brute (12 HP, 3 STR), Mage (6 HP, 6 STR), Assault (9 HP, 4 STR).
- **Random:** enemy type, damage rolls, 15% miss chance, 25% relic drops, location events, flee chance.
- **Deterministic:** class stats, +4 HP camp rest, boss after exactly 3 wins.
- **Win:** Defeat the Hollow King boss.
- **Lose:** Health reaches 0.
