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
--     * Exploration and location events.
--     * Combat, enemy generation, and fleeing.
--     * Inventory and relic collection.
--     * Victory tracking and the Hollow King encounter.
--     * Win/loss checks and the main adventure loop.
--
--   The entire adventure is now playable from the main entry point.
--   The player explores locations, fights enemies, collects relics,
--   wins battles, and can challenge or fight the Hollow King boss.
--   Defeating the Hollow King after earning three victories and
--   collecting all three relics wins the game; losing all health
--   loses the game.
--
module Main where

import Data.Char (isSpace, toLower)
import System.IO (hFlush, stdout)
import System.Random (randomRIO, Random)


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
    | Boss
    deriving (Eq, Show)

data EnemyStats = EnemyStats
    { enemyMaxHP    :: Int
    , enemyBaseStrength :: Int
    } deriving (Eq, Show)

data Enemy = Enemy
    { enemyName     :: String
    , enemyClass    :: EnemyClass
    , enemyHealth   :: Int
    , enemyMaxHp :: Int
    , enemyStrength :: Int
    } deriving (Eq, Show)

-- The actions available to the player during a fight.
data CombatAction = Attack | Defend | Flee
    deriving (Eq, Show)

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
    deriving (Eq, Show, Enum, Bounded)

data Inventory = Inventory
    { relics :: [Relic]
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
-- GAME-STATE DATA TYPES
-- ===========================================================================

-- The places the wanderer can travel to.
data Location = Camp | DarkForest | CrystalCaves | AncientRuins | Gate
    deriving (Eq, Show)

-- The complete running state of an adventure.
data Game = Game
    { gamePlayer       :: Player
    , gameLocation     :: Location
    , gameRelics       :: [Relic]
    , gameVictories    :: Int
    , gameLost         :: Bool
    , gameBossDefeated :: Bool
    } deriving (Eq, Show)

-- ===========================================================================
-- DETERMINISTIC CLASS INFORMATION
-- ===========================================================================

enemyStats :: EnemyClass -> EnemyStats
enemyStats Skeleton   = EnemyStats 3 5
enemyStats Goblin     = EnemyStats 2 3
enemyStats Theif      = EnemyStats 6 5
enemyStats Boss       = EnemyStats 20 8

-- The name of each enemy type as shown in combat.
enemyTypeName :: EnemyClass -> String
enemyTypeName Goblin     = "Goblin"
enemyTypeName Skeleton   = "Skeleton"
enemyTypeName Theif      = "Thief"
enemyTypeName Boss       = "Hollow King"

-- The boss enemy.  Very high health and strength.
hollowKingEnemy :: Enemy
hollowKingEnemy =
    Enemy
        { enemyName = "Hollow King"
        , enemyClass = Boss
        , enemyHealth = 20
        , enemyMaxHp = 20
        , enemyStrength = 8
        }

-- Generation of an enemy will be completely random.

-- A location event that may happen while exploring.
data LocationEvent = EnemyEncounter Enemy | BossEncounter | RelicFound Relic | EmptyLocation
    deriving (Eq, Show)

-- Descriptions for each location in the wanderer's land.
locationDescription :: Location -> String
locationDescription Camp =
    "You rest at your camp by the ancient road, the pack"
    ++ " slow and the fire warm."
locationDescription DarkForest =
    "The Dark Forest is a twisted tangle of ancient trees"
    ++ " with bent trunks and pulsating shadows that reach"
    ++ " out to touch you."
locationDescription CrystalCaves =
    "The Crystal Caves shine with eerie light from walls of"
    ++ " glowing quartz and mineral veins."
locationDescription AncientRuins =
    "The Ancient Ruins are crumbling arches and overgrown"
    ++ " statues of a forgotten civilization."
locationDescription Gate =
    "The ancient gate stands before you, sealed by a glowing"
    ++ " arcane barrier. It is your only path home."

-- Generate a random enemy for the given location.
generateEnemy :: Location -> IO Enemy
generateEnemy DarkForest = do
    roll <- randomRIO (1 :: Int, 100 :: Int)
    if roll <= 60
        then enemyFromClass Goblin
        else if roll <= 85
            then enemyFromClass Skeleton
            else enemyFromClass Theif
generateEnemy CrystalCaves = do
    roll <- randomRIO (1 :: Int, 100 :: Int)
    if roll <= 30
        then enemyFromClass Goblin
        else if roll <= 60
            then enemyFromClass Skeleton
            else enemyFromClass Theif
generateEnemy AncientRuins = do
    roll <- randomRIO (1 :: Int, 100 :: Int)
    if roll <= 25
        then enemyFromClass Goblin
        else if roll <= 55
            then enemyFromClass Skeleton
            else enemyFromClass Theif

-- Build an Enemy of the given class, using its deterministic stats.
enemyFromClass :: EnemyClass -> IO Enemy
enemyFromClass cls = do
    let EnemyStats maxHP str = enemyStats cls
    pure $ Enemy (enemyTypeName cls) cls maxHP maxHP str

-- Generate a random location event for the given location.
generateLocationEvent :: Game -> Location -> IO LocationEvent
generateLocationEvent game loc
    | isBossAvailable game = do
        roll <- randomRIO (1 :: Int, 100 :: Int)
        if roll <= 30
            then pure BossEncounter
            else locationRandomEvent game loc
    | otherwise = locationRandomEvent game loc
  where
    locationRandomEvent :: Game -> Location -> IO LocationEvent
    locationRandomEvent game loc = do
        roll <- randomRIO (1 :: Int, 100 :: Int)
        case loc of
            DarkForest -> do
                if roll <= 60
                    then EnemyEncounter <$> generateEnemy DarkForest
                    else if roll <= 85
                        then RelicFound <$> pure Wishbone
                        else pure EmptyLocation
            CrystalCaves -> do
                if roll <= 30
                    then EnemyEncounter <$> generateEnemy CrystalCaves
                    else if roll <= 55
                        then RelicFound <$> pure Coin
                        else pure EmptyLocation
            AncientRuins -> do
                if roll <= 25
                    then EnemyEncounter <$> generateEnemy AncientRuins
                    else if roll <= 50
                        then RelicFound <$> pure Star
                        else pure EmptyLocation
            _ -> pure EmptyLocation

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
        , playerInventory = Inventory { relics = [] }
        }

-- ===========================================================================
-- DETERMINISTIC MECHANICS
-- ===========================================================================

-- Camp rest restores a player to the maximum health for their class.
rest :: Game -> Game
rest game =
    let player = gamePlayer game
        maxHP = playerMaxHealth player
    in game { gamePlayer = player { playerHealth = maxHP } }

-- Add a relic to the player's collection (no duplicates allowed).
addRelic :: Game -> Relic -> Game
addRelic game relic
    | relic `elem` gameRelics game = game
    | otherwise = game { gameRelics = gameRelics game ++ [relic] }

-- Construct the initial game state from a chosen character.
initialGame :: Player -> Game
initialGame player =
    Game
        { gamePlayer       = player
        , gameLocation     = Camp
        , gameRelics       = []
        , gameVictories    = 0
        , gameLost         = False
        , gameBossDefeated = False
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

-- Parse a player's combat input into a CombatAction.
parseCombatAction :: String -> Maybe CombatAction
parseCombatAction input =
    case normalize input of
        "1"       -> Just Attack
        "attack"  -> Just Attack
        "2"       -> Just Defend
        "defend"  -> Just Defend
        "4"       -> Just Flee
        "flee"    -> Just Flee
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
-- COMBAT
-- ===========================================================================

-- A single turn in combat.  The player chooses an action and the enemy
-- reacts.  Returns the updated game state and the updated enemy.
combat :: Game -> Enemy -> IO Game
combat game enemy = do
    putStrLn $ "\n--- Combat ---"
    putStrLn $ "A " ++ enemyTypeName (enemyClass enemy) ++ " leaps out!"
    putStrLn $ "Enemy HP: " ++ show (enemyHealth enemy) ++ "/" ++ show (enemyMaxHp enemy)
    combatLoop game enemy False
  where
    combatLoop :: Game -> Enemy -> Bool -> IO Game
    combatLoop game enemy defending
        -- Player has fallen.
        | gameLost game = do
            putStrLn "You have fallen in battle. The enemy escapes with its spoils."
            pure game
        -- Enemy has been slain.
        | enemyHealth enemy <= 0 = do
            putStrLn "You have vanquished the enemy!"
            if enemyClass enemy == Boss
                then pure $ game { gameBossDefeated = True }
                else pure $ updateVictories game
        | otherwise = do
            putStrLn $ "Enemy HP: " ++ show (enemyHealth enemy) ++ " / " ++ show (enemyMaxHp enemy)
            putStrLn "Choose action: 1. Attack  2. Defend  3. Flee"
            input <- prompt "> "
            
            case parseCombatAction input of
                Just Attack -> do
                    (game', enemy') <- playerAttack game enemy
                    combatLoop game' enemy' False
                Just Defend -> do
                    putStrLn "You brace yourself, reducing the next blow by half."
                    combatLoop game enemy True
                Just Flee -> do
                    fled <- fleeCombat game enemy
                    if fled
                        then do
                            putStrLn "You successfully fled!"
                            pure game
                        else do
                            putStrLn "You failed to flee! The enemy attacks."
                            game'' <- enemyTurn game enemy defending
                            combatLoop game'' enemy False
                Nothing -> do
                    putStrLn "Invalid action. Choose 1, 2, or 3."
                    combatLoop game enemy defending

-- Perform an attack.  15% chance to miss; otherwise deals damage based on
-- the player's strength plus a small random variance.
playerAttack :: Game -> Enemy -> IO (Game, Enemy)
playerAttack game enemy = do
    missRoll <- randomRIO (1 :: Int, 100 :: Int)
    if missRoll <= 15
        then do
            putStrLn "You swing at the enemy but miss!"
            let enemy' = enemy { enemyHealth = enemyHealth enemy }
            let game' = game { gameLost = playerHealth (gamePlayer game) <= 0 }
            pure (game', enemy')
        else do
            dmgRoll <- randomRIO (1 :: Int, 100 :: Int)
            let damage = max 1 (playerStrength (gamePlayer game) + (dmgRoll `mod` 5))
            putStrLn $ "You strike the " ++ enemyTypeName (enemyClass enemy) ++ " for " ++ show damage ++ " damage!"
            let enemy' = enemy { enemyHealth = max 0 (enemyHealth enemy - damage) }
            let game' = game { gameLost = playerHealth (gamePlayer game) <= 0 }
            pure (game', enemy')

-- The enemy attacks.  If the player is defending, the damage is halved.
enemyTurn :: Game -> Enemy -> Bool -> IO Game
enemyTurn game enemy defending = do
    dmgRoll <- randomRIO (1 :: Int, 100 :: Int)
    let baseDmg = enemyStrength enemy + (dmgRoll `mod` 4) `max` 1
    let damage = if defending then baseDmg `div` 2 else baseDmg
    let player = gamePlayer game
    let newHP = playerHealth player - damage
    let game' = game
            { gamePlayer = player { playerHealth = max 0 newHP }
            , gameLost = newHP <= 0
            }
    putStrLn $ "The " ++ enemyTypeName (enemyClass enemy) ++ " hits you for " ++ show damage ++ " damage!"
    pure game'

-- Attempt to flee from combat.  50% success rate.
fleeCombat :: Game -> Enemy -> IO Bool
fleeCombat game enemy = do
    roll <- randomRIO (1 :: Int, 100 :: Int)
    if roll <= 50
        then do
            putStrLn "You break free and escape!"
            pure True
        else do
            putStrLn "You fail to flee and are forced to fight!"
            pure False

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


-- Increase the regular victory count by one.
updateVictories :: Game -> Game
updateVictories game = game { gameVictories = gameVictories game + 1 }

-- Check whether the Hollow King encounter is available.  The boss is
-- available when the player has at least three regular victories and
-- possesses all three sacred relics.
isBossAvailable :: Game -> Bool
isBossAvailable game =
    gameVictories game >= 3 && allRelicsCollected (gameRelics game)
  where
    allRelicsCollected rs = all (`elem` rs) [Wishbone, Coin, Star]

-- Check whether the game has ended.  The game ends when the player
-- either loses all health or defeats the Hollow King.
isGameOver :: Game -> Bool
isGameOver game = gameLost game || gameBossDefeated game

-- The win condition: the player has vanquished the Hollow King.
isVictory :: Game -> Bool
isVictory = gameBossDefeated

-- Display a status report for the player.
displayStatus :: Game -> IO ()
displayStatus game = do
    putStrLn "\n--- Status ---"
    putStrLn $ "Name:         " ++ playerName (gamePlayer game)
    putStrLn $ "Class:        " ++ show (playerClass (gamePlayer game))
    putStrLn $ "Health:       " ++ show (playerHealth (gamePlayer game)) ++ "/" ++ show (playerMaxHealth (gamePlayer game))
    putStrLn $ "Strength:     " ++ show (playerStrength (gamePlayer game))
    putStrLn $ "Relics:       " ++ show (gameRelics game)
    putStrLn $ "Victories:    " ++ show (gameVictories game) ++ "/3"
    putStrLn $ "Lost:         " ++ show (gameLost game)
    putStrLn $ "Boss defeated:" ++ show (gameBossDefeated game)

-- Inspect the ancient gate and remaining requirements.
inspectGate :: Game -> IO Game
inspectGate game = do
    putStrLn "\n--- The Ancient Gate ---"
    putStrLn "The ancient gate stands before you, sealed by a glowing arcane barrier."
    putStrLn $ "Relics collected: " ++ show (length (gameRelics game)) ++ "/3"
    putStrLn $ "Regular battles won: " ++ show (gameVictories game) ++ "/3"
    
    if isBossAvailable game
        then putStrLn "The gate's barrier begins to crack! The Hollow King emerges!"
        else do
            let missingRelics = 3 - length (gameRelics game)
                missingVictories = 3 - gameVictories game
            putStrLn $ "The gate remains sealed. Requirements: " ++ show missingRelics ++ " more relic(s), " ++ show missingVictories ++ " more victory(es)."
    pure game

-- Challenge the Hollow King when eligible.
challengeBoss :: Game -> IO Game
challengeBoss game = do
    putStrLn "\n--- The Hollow King Appears ---"
    game' <- combat game hollowKingEnemy
    pure game'

-- ===========================================================================
-- EXPLORATION AND LOCATION EVENTS
-- ===========================================================================

-- Travel to a location and generate a random event.
exploreLocation :: Game -> Location -> IO Game
exploreLocation game loc = do
    putStrLn $ "\n" ++ locationDescription loc
    event <- generateLocationEvent game loc
    case event of
        EnemyEncounter enemy -> do
            putStrLn $ "You encountered a " ++ enemyTypeName (enemyClass enemy) ++ "!"
            game' <- combat game enemy
            pure game'
        BossEncounter -> do
            putStrLn "The air grows cold as a towering figure emerges from the shadows!"
            game' <- combat game hollowKingEnemy
            pure game'
        RelicFound relic -> do
            putStrLn $ "You found the " ++ show relic ++ "!"
            pure $ addRelic game relic
        EmptyLocation -> do
            putStrLn "You find nothing of interest."
            pure game

-- Search the current location for relics or supplies.
searchLocation :: Game -> IO Game
searchLocation game = do
    putStrLn "\n--- Searching the area ---"
    roll <- randomRIO (1 :: Int, 100 :: Int)
    if roll <= 30
        then do
            relic <- randomRelic
            putStrLn $ "You found the " ++ show relic ++ "!"
            pure $ addRelic game relic
        else do
            putStrLn "You search but find nothing of value."
            pure game
    where
        randomRelic :: IO Relic
        randomRelic = do
            index <- randomRIO
                ( fromEnum (minBound :: Relic)
                , fromEnum (maxBound :: Relic)
                )
            pure (toEnum index)

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
-- LOCATION MENU
-- ===========================================================================

-- The main location menu.  Shows the available actions and dispatches
-- to the appropriate handler.
locationMenu :: Game -> IO Game
locationMenu game = do
    putStrLn "\n=== Wanderer's Compass ==="
    putStrLn $ "You are currently at the " ++ show (gameLocation game) ++ "."
    putStrLn "What would you like to do?"
    putStrLn "1. Enter the Dark Forest"
    putStrLn "2. Enter the Crystal Caves"
    putStrLn "3. Enter the Ancient Ruins"
    putStrLn "4. Search your current location"
    putStrLn "5. Rest at camp"
    putStrLn "6. Inspect the ancient gate"
    putStrLn "7. View your status"
    putStrLn "8. Challenge the Hollow King (once eligible)"
    
    input <- prompt "> "
    
    case input of
        "1" -> do
            putStrLn "You travel into the Dark Forest..."
            exploreLocation game DarkForest
        "2" -> do
            putStrLn "You travel into the Crystal Caves..."
            exploreLocation game CrystalCaves
        "3" -> do
            putStrLn "You travel into the Ancient Ruins..."
            exploreLocation game AncientRuins
        "4" -> searchLocation game
        "5" -> do
            putStrLn "You rest at camp, healing completely to full health."
            pure $ rest game
        "6" -> inspectGate game
        "7" -> do
            displayStatus game
            locationMenu game
        "8" | isBossAvailable game -> do
            putStrLn "You step forward to challenge the Hollow King!"
            challengeBoss game
        "8" -> do
            putStrLn "The Hollow King is not yet available. You lack the required victories and relics."
            locationMenu game
        _ -> do
            putStrLn "Invalid choice. Enter a number from 1 to 9."
            locationMenu game

-- ===========================================================================
-- MAIN ADVENTURE LOOP
-- ===========================================================================

-- The main game loop.  Continues until the game is over.
gameLoop :: Game -> IO ()
gameLoop game
    | isGameOver game = do
        if isVictory game
            then putStrLn "\nYou have vanquished the Hollow King and escaped home!"
            else putStrLn "\nYou have fallen in battle. The wanderer is defeated."
        putStrLn "The adventure ends here."
    | otherwise = do
        next <- locationMenu game
        gameLoop next

-- The program entry point.
main :: IO ()
main = do
    putStrLn "======================================"
    putStrLn "     Wanderer of the Foreign Land"
    putStrLn "======================================"
    putStrLn "You awaken in a haunted land far from home."
    
    player <- createPlayer
    
    let game = initialGame player
    
    gameLoop game
