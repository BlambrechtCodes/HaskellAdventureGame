-- ===========================================================================
-- HASKELL ADVENTURE GAME: "Wanderer of the Foreign Land"
-- CS 421 Assignment -- Game Design and Character Selection
-- ===========================================================================
--
-- PROJECT PURPOSE
--   Build an interactive, text-based adventure game in Haskell that:
--     1. Presents a story through text.
--     2. Accepts and responds to user input.
--     3. Provides at least 10 meaningful gameplay choices.
--     4. Uses deterministic mechanics, random mechanics, or both.
--
-- IMPLEMENTATION SCOPE OF THIS FILE
--   Implemented:
--     * Character-class and player data types.
--     * Deterministic starting statistics for each class.
--     * Interactive class selection.
--     * Player-name entry and validation.
--     * Character confirmation and reselection.
--
--   Planned, but NOT implemented:
--     * Exploration and location events.
--     * Combat, enemy generation, and fleeing.
--     * Inventory, potions, and relic collection.
--     * Victory tracking and the Hollow King encounter.
--     * Win/loss checks and the main adventure loop.
--
--   Running this file completes character creation and then stops.
--   It does not run the full adventure.
--
module Main where

import Data.Char (isSpace, toLower)
import System.IO (hFlush, stdout)


-- ===========================================================================
-- DESIGN TEMPLATE: PLOT AND SETTING
-- ===========================================================================
--
-- PLOT
--   You awaken as a wanderer in a foreign, haunted land. Scattered ruins,
--   dark woods, and crystal caverns surround an ancient sealed gate.
--   The gate is your only path home.
--
--   Three sacred relics -- the Wishbone, the Coin, and the Star -- are
--   needed to break the gate's seal. However, the Hollow King guards
--   the passage and must be defeated before you can escape.
--
-- PLAYER GOALS
--   1. Choose a character class and enter a name.
--   2. Explore the Dark Forest, Crystal Caves, and Ancient Ruins.
--   3. Recover the Wishbone, Coin, and Star.
--   4. Earn three regular battle victories.
--   5. Defeat the Hollow King and return home.
--
-- PROPOSED PROGRESSION RULE
--   The third regular battle victory completes the combat requirement.
--   The boss encounter becomes available when BOTH conditions are met:
--     * The player has at least three regular battle victories.
--     * The player possesses all three relics.
--
--   Using "at least three" avoids accidentally locking the player out
--   if they win additional battles before collecting every relic.
--   The Hollow King victory is separate from regular battle victories.
--
-- WIN CONDITION
--   Defeat the Hollow King after satisfying both progression requirements,
--   then pass through the opened gate.
--
-- LOSS CONDITION
--   The player's current health reaches zero or below.
--   Future gameplay code must check this after damaging events and attacks.


-- ===========================================================================
-- DESIGN TEMPLATE: CHARACTER CLASSES
-- ===========================================================================
--
--   Class       Maximum HP    Strength    Role
--   Brute       12            3           High endurance, lower damage
--   Mage         6            6           Low endurance, high damage
--   Assault      9            4           Balanced endurance and damage
--
--   Starting statistics are deterministic:
--     * Each class always receives the same maximum HP and strength.
--     * A new player starts at full health.
--     * Character creation does not randomly change these statistics.
--
--   The player selects a class before entering a name and reviewing
--   the completed character.


-- ===========================================================================
-- DESIGN TEMPLATE: Enemy Types
-- ===========================================================================
--
--   Class       Maximum HP    Strength    Role
--   Goblin       1            1           Generally really weak (But annoying)
--   Skeleton     3            2           Low endurance, low damage
--   Theif        5            5           Balanced enemy
--

-- ===========================================================================
-- DESIGN TEMPLATE: PLAYER INPUT AND MEANINGFUL CHOICES
-- ===========================================================================
--
--   Planned choices throughout the complete game:
--     1. Select Brute, Mage, or Assault.
--     2. Travel to the Dark Forest.
--     3. Travel to the Crystal Caves.
--     4. Travel to the Ancient Ruins.
--     5. Search the current location for relics or supplies.
--     6. Approach an enemy and begin combat.
--     7. Use a normal attack during combat.
--     8. Defend against an enemy's next attack.
--     9. Drink a healing potion when one is available.
--    10. Attempt to flee from combat.
--    11. Return to camp to restore health.
--    12. Inspect the ancient gate and remaining requirements.
--    13. Challenge the Hollow King once eligible.
--
--   These are planned gameplay options, not features implemented here.
--   Name entry, invalid-input retries, and confirmation prompts are not
--   counted as substitutes for meaningful adventure choices.
--
--   Future menus should explain unavailable actions, such as attempting
--   to drink a potion with an empty inventory or challenging a locked boss.


-- ===========================================================================
-- DESIGN TEMPLATE: DETERMINISTIC AND RANDOM MECHANICS
-- ===========================================================================
--
-- DETERMINISTIC MECHANICS
--   * Class starting HP and strength.
--   * Starting at full health.
--   * Camp restores health to the class maximum.
--   * Potions restore a fixed amount without exceeding maximum HP.
--   * Boss eligibility depends on relics and regular battle victories.
--   * Zero or negative health causes defeat.
--
-- PROPOSED RANDOM MECHANICS -- FUTURE IMPLEMENTATION
--   * Enemy type encountered while exploring.
--   * Damage variation and attack misses.
--   * Supply drops and location events.
--   * Success or failure when attempting to flee.
--
--   Character selection requires no randomness.
--   Add System.Random only when implementing random gameplay features.

-- ===========================================================================
-- ENEMY DATA TYPES
-- ===========================================================================

data EnemyClass
    = Goblin
    | Skeleton
    | Theif
    deriving (Eq, Show)

data EnemyStats = EnemyStats
    { maximumHP    :: Int
    , baseStrength :: Int
    } deriving (Eq, Show)

data Enemy = Enemy
    { enemyName     :: String
    , enemyClass    :: CharacterClass
    , enemyHealth   :: Int
    , enemyMaxHealth :: Int
    , enemyStrength :: Int
    } deriving (Eq, Show)

-- ===========================================================================
-- CHARACTER-SELECTION DATA TYPES
-- ===========================================================================

data CharacterClass
    = Brute
    | Mage
    | Assault
    deriving (Eq, Show)

data ClassStats = ClassStats
    { maximumHP    :: Int
    , baseStrength :: Int
    } deriving (Eq, Show)

data Relic = Wishbone | Coin | Star
    deriving(Eq, Show, Enum, Bounded)

data Inventory = Inventory
    { potions :: Int
    , relics :: [Relic]
    } deriving (Eq, Show)

data Player = Player
    { playerName     :: String
    , playerClass    :: CharacterClass
    , playerHealth   :: Int
    , playerMaxHealth :: Int
    , playerStrength :: Int
    , playerInventory :: Inventory
    } deriving (Eq, Show)

-- ===========================================================================
-- DETERMINISTIC CLASS INFORMATION
-- ===========================================================================

enemyStats :: EnemyClass -> EnemyStats
enemyStats Skeleton   = EnemyStats 3 2
enemyStats Goblin     = EnemyStats 1 1
enemyStats Theif      = EnemyStats 5 5

-- Generation of an enemy will be completely random.

-- ===========================================================================
-- DETERMINISTIC CLASS INFORMATION
-- ===========================================================================

classStats :: CharacterClass -> ClassStats
classStats Brute   = ClassStats 12 3
classStats Mage    = ClassStats 6 6
classStats Assault = ClassStats 9 4

classDescription :: CharacterClass -> String
classDescription Brute =
    "High endurance and lower damage."
classDescription Mage =
    "Low endurance and high damage."
classDescription Assault =
    "Balanced endurance and damage."

-- Pure constructor: no input/output or randomness.
makePlayer :: String -> CharacterClass -> Player
makePlayer name chosenClass =
    let stats = classStats chosenClass
    in Player
        { playerName      = name
        , playerClass     = chosenClass
        , playerHealth    = maximumHP stats
        , playerMaxHealth = maximumHP stats
        , playerStrength  = baseStrength stats
        , playerInventory = Inventory { potions = 0, relics = [] }
        }


-- ===========================================================================
-- INPUT HELPERS
-- ===========================================================================

trim :: String -> String
trim = dropWhileEndSpace . dropWhile isSpace
  where
    dropWhileEndSpace = reverse . dropWhile isSpace . reverse

normalize :: String -> String
normalize = map toLower . trim

prompt :: String -> IO String
prompt message = do
    putStr message
    hFlush stdout
    getLine


-- ===========================================================================
-- CLASS SELECTION
-- ===========================================================================

parseClass :: String -> Maybe CharacterClass
parseClass input =
    case normalize input of
        "1"       -> Just Brute
        "brute"   -> Just Brute
        "2"       -> Just Mage
        "mage"    -> Just Mage
        "3"       -> Just Assault
        "assault" -> Just Assault
        _         -> Nothing

displayClassOption :: String -> CharacterClass -> IO ()
displayClassOption number chosenClass = do
    let stats = classStats chosenClass
    putStrLn $
        number ++ ". " ++ show chosenClass
        ++ " | HP: " ++ show (maximumHP stats)
        ++ " | STR: " ++ show (baseStrength stats)
    putStrLn $ "   " ++ classDescription chosenClass

chooseClass :: IO CharacterClass
chooseClass = do
    putStrLn "\nChoose your character class:"
    displayClassOption "1" Brute
    displayClassOption "2" Mage
    displayClassOption "3" Assault
    input <- prompt "Enter a number or class name: "

    case parseClass input of
        Just chosenClass -> pure chosenClass
        Nothing -> do
            putStrLn "Invalid selection. Enter 1, 2, 3, or a class name."
            chooseClass


-- ===========================================================================
-- NAME ENTRY AND CHARACTER CONFIRMATION
-- ===========================================================================

chooseName :: IO String
chooseName = do
    input <- prompt "\nEnter your wanderer's name: "
    let name = trim input

    if null name
        then do
            putStrLn "Your name cannot be empty."
            chooseName
        else pure name

displayPlayer :: Player -> IO ()
displayPlayer player = do
    putStrLn "\n--- Your Character ---"
    putStrLn $ "Name:     " ++ playerName player
    putStrLn $ "Class:    " ++ show (playerClass player)
    putStrLn $
        "Health:   " ++ show (playerHealth player)
        ++ "/" ++ show (playerMaxHealth player)
    putStrLn $ "Strength: " ++ show (playerStrength player)

confirmCharacter :: IO Bool
confirmCharacter = do
    input <- prompt "\nKeep this character? (yes/no): "

    case normalize input of
        "yes" -> pure True
        "y"   -> pure True
        "no"  -> pure False
        "n"   -> pure False
        _     -> do
            putStrLn "Please enter yes or no."
            confirmCharacter


-- ===========================================================================
-- CHARACTER-CREATION ENTRY POINT
-- ===========================================================================

createPlayer :: IO Player
createPlayer = do
    chosenClass <- chooseClass
    name <- chooseName
    let player = makePlayer name chosenClass

    displayPlayer player
    confirmed <- confirmCharacter

    if confirmed
        then pure player
        else do
            putStrLn "\nLet's create your character again."
            createPlayer


-- ===========================================================================
-- PROGRAM ENTRY POINT -- CHARACTER SELECTION ONLY
-- ===========================================================================

main :: IO ()
main = do
    putStrLn "======================================"
    putStrLn "     Wanderer of the Foreign Land"
    putStrLn "======================================"
    putStrLn "You awaken in a haunted land far from home."

    player <- createPlayer

    putStrLn $
        "\nCharacter creation complete. Welcome, "
        ++ playerName player ++ "!"
    putStrLn "The adventure itself has not been implemented yet."

    -- TODO: Pass player to the future adventure loop.
    -- TODO: Implement exploration and the documented gameplay choices.
    -- TODO: Implement combat, inventory, relics, and victory tracking.
    -- TODO: Implement boss eligibility and win/loss conditions.