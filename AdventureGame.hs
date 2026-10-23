
-- HASKELL ADVENTURE GAME — "Wanderer of the Foreign Land"
-- CS 421 Assignment — Design Template
--
-- This file is a commented template. Replace the stubs below with real
-- Haskell code section by section to complete the text-based adventure game.
--
-- ASSIGNMENT REQUIREMENTS COVERED
--   1. Text-based adventure game         -> see gameLoop, locationMenu, combat
--   2. 10+ player choices                -> see CHOICES section below
--   3. User input                        -> see createPlayer and all menu prompts
--   4. Random OR Deterministic mechanics -> see RANDOM and DETERMINISTIC sections
--
-- ============================================================================

module Main where

-- ----------------------------------------------------------------------------
-- IMPORTS (TODO: add as needed)
-- ----------------------------------------------------------------------------
--   import System.Random (randomRIO)
--   import System.IO (hFlush, stdout, hSetBuffering, BufferMode(NoBuffering))

-- ----------------------------------------------------------------------------
-- DESIGN TEMPLATE — PLOT & SETTING
-- ----------------------------------------------------------------------------
--
-- PLOT:
--   You wake up in a foreign, haunted land with no memory of how you got
--   there. The only way home is an ancient gate sealed by three relics:
--   the Wishbone, the Coin, and the Star.
--
-- GOAL:
--   Travel through dangerous locations, fight enemies, collect the three
--   relics, win three battles, defeat the Hollow King boss, and escape.
--   If your health reaches zero, you lose.

-- ----------------------------------------------------------------------------
-- DESIGN TEMPLATE — CHARACTER CLASSES (DETERMINISTIC BASE STATS)
-- ----------------------------------------------------------------------------
--   Brute   : 12 max HP, 3 STR   — tough and steady, lower damage
--   Mage    :  6 max HP, 6 STR   — fragile but deadly
--   Assault :  9 max HP, 4 STR   — balanced
--
-- Choose one at the start. These base stats are deterministic (fixed).

-- ----------------------------------------------------------------------------
-- DESIGN TEMPLATE — RANDOM MECHANICS
-- ----------------------------------------------------------------------------
--   • Enemy encountered in a location is chosen at random
--   • Damage rolls vary within a range based on strength
--   • 15% chance that any attack (player or enemy) misses
--   • Location event is random (enemy, item, empty, trap)
--   • Loot drop is random (Health Potion or nothing)
--   • Relic drop after victory is random (Wishbone / Coin / Star)
--   • Fleeing from combat succeeds about 50% of the time

-- ----------------------------------------------------------------------------
-- DESIGN TEMPLATE — DETERMINISTIC MECHANICS
-- ----------------------------------------------------------------------------
--   • Base max HP and strength are fixed by your chosen character class
--   • Resting at camp always heals exactly 4 HP
--   • A Health Potion always heals exactly 5 HP
--   • The Hollow King boss appears after exactly 3 victories
--   • Story progression follows your menu choices

-- ----------------------------------------------------------------------------
-- DESIGN TEMPLATE — WIN / LOSE CONDITIONS
-- ----------------------------------------------------------------------------
--   Win  : Defeat the Hollow King boss (available after 3 victories)
--   Lose : Your health drops to 0 or below

-- ----------------------------------------------------------------------------
-- DESIGN TEMPLATE — PLAYER CHOICES (10+)
-- ----------------------------------------------------------------------------
--   1. Pick your character class (Brute / Mage / Assault)
--   2. Choose where to travel (Dark Forest / Crystal Caves / Ancient Ruins)
--   3. Rest at camp to heal
--   4. Check your status and inventory
--   5. Quit the game
--   6. In combat: Attack
--   7. In combat: Defend (halve the next incoming hit)
--   8. In combat: Use a Health Potion
--   9. In combat: Flee (50% success chance)
--   10. In the boss fight: Attack / Defend / Potion / Flee
--
-- Because these menus repeat every turn, a real playthrough contains many
-- more than 10 choices.

-- ----------------------------------------------------------------------------
-- DATA TYPES (TODO: define these)
-- ----------------------------------------------------------------------------
--   data Player  = Player { name, charClass, health, maxHealth, strength,
--                           victories, inventory :: ... }
--   data Enemy   = Enemy { eName, eHealth, eMaxHealth, eStrength :: ... }
--   (Optional) data Item = HealthPotion | Wishbone | Coin | Star

-- ----------------------------------------------------------------------------
-- STATIC TABLES (TODO: fill in)
-- ----------------------------------------------------------------------------
--   wildEnemies :: [(String, Int, Int)]  -- (name, health, strength)
--   bossEnemy   :: Enemy                  -- The Hollow King (appears after 3 wins)

-- ----------------------------------------------------------------------------
-- RANDOM HELPERS (TODO: implement)
-- ----------------------------------------------------------------------------
--   roll    :: Int -> Int -> IO Int      -- random int in inclusive range
--   chance  :: Int -> IO Bool            -- True with given percent probability
--   pickRandom :: [a] -> IO a            -- random element from a list
--   rollDamage :: Int -> IO Int          -- damage based on attacker strength

-- ----------------------------------------------------------------------------
-- CHARACTER CREATION — USER INPUT (TODO: implement)
-- ----------------------------------------------------------------------------
--   createPlayer :: IO Player
--     1. Print title and plot summary
--     2. Prompt for and read the player's name (getLine)
--     3. Show the three classes with deterministic stats
--     4. Read class choice (getLine)
--     5. Return Player with chosen stats, full health, 0 wins, empty inventory

-- ----------------------------------------------------------------------------
-- DISPLAY / STATUS (TODO: implement)
-- ----------------------------------------------------------------------------
--   printStatus :: Player -> IO ()
--     Print name, class, HP, strength, victories (out of 3), and inventory

-- ----------------------------------------------------------------------------
-- ENEMY GENERATION (TODO: implement)
-- ----------------------------------------------------------------------------
--   randomEnemy :: IO Enemy
--     Pick a random enemy from wildEnemies and return it at full health

-- ----------------------------------------------------------------------------
-- COMBAT SYSTEM — RANDOM + DETERMINISTIC (TODO: implement)
-- ----------------------------------------------------------------------------
--   combat :: Player -> Enemy -> IO (Maybe Player)
--     Returns Nothing if player dies, Just updated player on victory.
--     Player choices each turn:
--       1. Attack       — roll damage (random), apply to enemy
--       2. Defend       — halve the next incoming hit (deterministic)
--       3. Use Potion   — heal exactly 5 HP if Health Potion in inventory
--       4. Flee         — 50% random chance to escape; otherwise take a hit
--     Enemy turn:
--       - Attacks back (random damage based on enemy strength)
--       - 15% random chance to miss
--       - If player defended, halve incoming damage once
--     After victory:
--       - Increment victory count
--       - Random loot (Health Potion or nothing)
--       - Random relic (Wishbone / Coin / Star)

-- ----------------------------------------------------------------------------
-- EXPLORATION / LOCATIONS — RANDOM EVENTS (TODO: implement)
-- ----------------------------------------------------------------------------
--   explore :: Player -> String -> IO ()
--     Travel to a location and trigger a random event:
--       1. Enemy encounter -> start combat
--       2. Find item       -> add Health Potion to inventory
--       3. Nothing happens -> description only
--       4. Trap / hazard   -> take small deterministic damage
--
--   locationMenu :: Player -> IO ()
--     Menu choices:
--       1. Dark Forest
--       2. Crystal Caves
--       3. Ancient Ruins
--       4. Rest at Camp   — heal exactly 4 HP (deterministic)
--       5. Check Status
--       6. Quit
--     Read choice with getLine and branch accordingly

-- ----------------------------------------------------------------------------
-- BOSS FIGHT — DETERMINISTIC TRIGGER (TODO: implement)
-- ----------------------------------------------------------------------------
--   bossFight :: Player -> IO ()
--     Available only after 3 victories.
--     Combat against the Hollow King.
--     Victory: print win message and end game.
--   Defeat: print game-over message and end game

-- ----------------------------------------------------------------------------
-- MAIN GAME LOOP (TODO: implement)
-- ----------------------------------------------------------------------------
--   gameLoop :: Player -> IO ()
--     Loop until game ends:
--       - If HP <= 0: print GAME OVER and stop
--       - If victories >= 3: start bossFight
--       - Otherwise: show locationMenu

-- ----------------------------------------------------------------------------
-- ENTRY POINT (TODO: implement)
-- ----------------------------------------------------------------------------
--   main :: IO ()
--     Set stdout buffering to NoBuffering.
--     Call createPlayer, then call gameLoop.
