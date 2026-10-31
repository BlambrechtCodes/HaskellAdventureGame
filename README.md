# Haskell Adventure Game — Wanderer of the Foreign Land

## 1. Project Files

- `AdventureGame.hs` — Full Haskell implementation (single source file; the `Main`
  module contains all data types, game logic, combat, exploration, and the
  entry point).
- `README.md` — This documentation file.

## 2. Game Premise and Rules

### Premise

You awaken as a wanderer in a foreign, haunted land. Scattered ruins, dark
woods, and crystal caverns surround an ancient sealed gate — your only path
home. Three sacred relics — the **Wishbone**, the **Coin**, and the **Star** —
are needed to break the gate's seal. The **Hollow King** guards the passage and
must be defeated before you can escape. You explore locations, fight enemies,
collect relics, win battles, and finally challenge the boss to win.

### Rules

- **Character creation:** Choose one of three classes (Brute, Mage, Assault),
  enter a name, and confirm the character. Stats are fixed by class and you
  start at full health.
- **Locations:** Travel to the Dark Forest, Crystal Caves, or Ancient Ruins;
  return to camp to rest; inspect the ancient gate; view status; or challenge
  the boss. Each adventuring location holds exactly one specific relic:
  - Dark Forest → **Wishbone**
  - Crystal Caves → **Coin**
  - Ancient Ruins → **Star**
- **Exploration:** Searching/exploring a location generates a random event:
  finding its relic (if not yet collected), encountering a random enemy, or
  finding nothing. Camp and the Gate are safe (no encounters).
- **Combat:** When an enemy appears, choose **Attack**, **Defend**, or **Flee**
  each turn. Enemies retaliate after a surviving player attack (even a miss),
  after a failed flee, and immediately when you defend (for reduced damage).
  Defeated enemies do not retaliate. Invalid input does not consume a turn.
- **Resting:** Returning to camp restores your health to your class maximum.
- **Progression / Boss:** The Hollow King becomes available only when **both**
  conditions hold: at least **3 regular battle victories** and **all 3 relics**
  collected. You must explicitly challenge him from the location menu.
- **Win:** Defeat the Hollow King.
- **Lose:** Your health reaches 0 (or below) at any point.

### Character Classes

| Class   | Max HP | Strength | Role                              |
|---------|--------|----------|-----------------------------------|
| Brute   | 25     | 4        | High endurance, lower damage      |
| Mage    | 18     | 6        | Low endurance, high damage        |
| Assault | 20     | 5        | Balanced endurance and damage     |

### Enemies

| Enemy              | Max HP | Strength | Notes                              |
|--------------------|--------|----------|------------------------------------|
| Goblin             | 1      | 1        | Weak but annoying                  |
| Skeleton           | 3      | 2        | Low endurance, low damage          |
| Thief              | 5      | 3        | Balanced enemy                     |
| Hollow King (Boss) | 20     | 2        | High endurance, steady damage      |

Enemy attacks add a random bonus of 0 or 1 damage. The player's attack adds a
random bonus of 0 through 4 and has a 15% chance to miss.

## 3. How to Compile and Play

### Requirements

- [Stack](https://docs.haskellstack.org/) with GHC (tested with GHC 9.10.3).
  The only non-base dependency is `random`, which Stack resolves automatically.

### Compile

```bash
# From the project directory:
stack ghc -- AdventureGame.hs -o adventure
```

This produces an executable named `adventure`.

### Run

```bash
./adventure
```

### Alternative: run interactively in GHCi

```bash
stack ghci
# inside GHCi:
:l AdventureGame.hs
:main
```

### Play

1. Run the program and read the intro.
2. Choose a character class: **Brute**, **Mage**, or **Assault** (by number or
   name).
3. Enter your wanderer's name and confirm the character.
4. From the **Wanderer's Compass** menu choose:
   1. Enter the Dark Forest
   2. Enter the Crystal Caves
   3. Enter the Ancient Ruins
   4. Search your current location
   5. Return to camp and rest
   6. Inspect the ancient gate
   7. View your status
   8. Challenge the Hollow King (once eligible)
5. When an enemy appears, fight it: **Attack**, **Defend**, or **Flee**.
6. Win at least 3 regular battles and collect all 3 relics, then challenge
   the **Hollow King** (menu option 8) and defeat him to win.
7. If your health reaches 0 at any point, the game is over.

## 4. The 10 (11) Meaningful Choices

The game provides the following meaningful gameplay choices (as listed in the
design template), well over the required 10:

1. **Select a character class** — Brute, Mage, or Assault.
2. **Travel to the Dark Forest.**
3. **Travel to the Crystal Caves.**
4. **Travel to the Ancient Ruins.**
5. **Search the current location** for relics (may attract enemies).
6. **Use a normal attack** during combat.
7. **Defend** against an enemy's next attack (halves incoming damage).
8. **Attempt to flee** from combat.
9. **Return to camp to restore health.**
10. **Inspect the ancient gate** and view remaining requirements.
11. **Challenge the Hollow King** once eligible.

Name entry, invalid-input retries, and confirmation prompts are not counted as
substitutes for meaningful adventure choices. Menus explain unavailable actions
(e.g., searching camp for relics, challenging a locked boss). Invalid input
does not consume a combat turn.

## 5. Deterministic vs. Random Mechanics

### Deterministic Mechanics

- **Class starting stats** — Brute 25 HP/4 STR, Mage 18 HP/6 STR,
  Assault 20 HP/5 STR; always the same for a given class.
- **Starting at full health** — a new player begins at maximum HP.
- **Camp rest** — restores health to the class maximum (full heal).
- **Boss eligibility** — requires at least 3 regular victories **and** all 3
  relics; deterministic threshold check.
- **Defeat** — health reaching 0 (or below) ends the game.
- **Relic placement** — each adventuring location contains one specific relic
  (Dark Forest → Wishbone, Crystal Caves → Coin, Ancient Ruins → Star).
- **No duplicate relics** — collecting an already-owned relic is not awarded
  again; the game state and player inventory stay synchronized.
- **Enemy stats** — Goblin 1 HP/1 STR, Skeleton 3 HP/2 STR, Thief 5 HP/3 STR,
  Hollow King 20 HP/2 STR are fixed by class.
- **Progression counters** — regular victories increment by exactly 1 per
  defeated regular enemy; the Hollow King victory is tracked separately.

### Random Mechanics

- **Enemy type encountered while exploring** — location-based weighted
  probabilities (e.g., Dark Forest: 60% Goblin / 25% Skeleton / 15% Thief;
  Crystal Caves: 30% / 30% / 40%; Ancient Ruins: 25% / 30% / 45%).
- **Damage variation** — player attacks deal strength + a random bonus of 0–4;
  enemy attacks deal strength + a random bonus of 0 or 1.
- **Attack miss chance** — 15% chance the player's attack misses entirely.
- **Relic discovery / location events** — if a location's relic is uncollected:
  60% chance to find the relic, 30% chance of an enemy encounter, 10%
  nothing; if already collected: 70% enemy encounter, 30% nothing.
- **Flee success** — 50% chance to escape combat.
- **Defend mitigation** — defending halves incoming damage (rounding up), so
  the roll still varies with the random bonus.

The game uses **both** random and deterministic systems, satisfying the
"Random OR Deterministic (or both)" requirement.

## 6. Win / Loss Conditions

- **Win:** Defeat the Hollow King after satisfying both progression
  requirements (≥3 regular victories and all 3 relics), then escape through
  the opened gate.
- **Lose:** Your current health reaches 0 or below.

