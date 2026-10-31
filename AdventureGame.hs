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
--   wins battles, and can challenge the Hollow King boss.
--   Defeating the Hollow King after earning three victories and
--   collecting all three relics wins the game; losing all health
--   loses the game.
--
module Main where

import Data.Char (isSpace, toLower)
import System.IO (hFlush, stdout)
import System.Random (randomRIO)


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
-- PROGRESSION RULE
--   The third regular battle victory completes the combat requirement.
--   The boss encounter becomes available when BOTH conditions are met:
--     * The player has at least three regular battle victories.
--     * The player possesses all three relics.
--
--   Using "at least three" avoids accidentally locking the player out
--   if they win additional battles before collecting every relic.
--   The Hollow King victory is separate from regular battle victories.
--   The player must explicitly challenge the boss from the main menu.
--
-- WIN CONDITION
--   Defeat the Hollow King after satisfying both progression requirements,
--   then pass through the opened gate.
--
-- LOSS CONDITION
--   The player's current health reaches zero or below.
--   Gameplay checks this after damaging events and attacks.


-- ===========================================================================
-- DESIGN TEMPLATE: CHARACTER CLASSES
-- ===========================================================================
--
--   Class       Maximum HP    Strength    Role
--   Brute       25            4           High endurance, lower damage
--   Mage        18            6           Medium endurance, high damage
--   Assault     20            5           Balanced endurance and damage
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
--   Goblin       1            1           Generally weak, but annoying
--   Skeleton     3            2           Low endurance, low damage
--   Thief        5            3           Balanced enemy
--   Boss        20            2           High endurance, steady damage
--
--   Enemy attacks add a random bonus of zero or one damage.
--   The boss has lower strength because every surviving enemy now
--   retaliates after the player's attack, including missed attacks.
--
--   The constructor "Theif" is retained for compatibility with the
--   original code; the displayed enemy name is correctly spelled.


-- ===========================================================================
-- DESIGN TEMPLATE: PLAYER INPUT AND MEANINGFUL CHOICES
-- ===========================================================================
--
--   Gameplay choices throughout the complete game:
--     1. Select Brute, Mage, or Assault.
--     2. Travel to the Dark Forest.
--     3. Travel to the Crystal Caves.
--     4. Travel to the Ancient Ruins.
--     5. Search the current location for relics.
--     6. Use a normal attack during combat.
--     7. Defend against an enemy's next attack.
--     8. Attempt to flee from combat.
--     9. Return to camp to restore health.
--    10. Inspect the ancient gate and remaining requirements.
--    11. Challenge the Hollow King once eligible.
--
--   Name entry, invalid-input retries, and confirmation prompts are not
--   counted as substitutes for meaningful adventure choices.
--
--   Menus explain unavailable actions, such as searching camp for
--   relics or challenging a locked boss.
--
--   Invalid input does not consume a combat turn. Tactical choices do:
--     * A missed or nonlethal attack allows enemy retaliation.
--     * Defending consumes a turn and reduces the incoming damage.
--     * Failing to flee allows an enemy attack.


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
--   * Each adventuring location contains one specific relic.
--   * Relic collections contain no duplicates.
--
-- RANDOM MECHANICS
--   * Enemy type encountered while exploring.
--   * Damage variation and player attack misses.
--   * Relic discovery and location events.
--   * Success or failure when attempting to flee.
--
--   Character selection requires no randomness.
--   System.Random is used for random gameplay features.


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
    { enemyMaxHP        :: Int
    , enemyBaseStrength :: Int
    } deriving (Eq, Show)


data Enemy = Enemy
    { enemyName     :: String
    , enemyClass    :: EnemyClass
    , enemyHealth   :: Int
    , enemyMaxHp    :: Int
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
    { playerName      :: String
    , playerClass     :: CharacterClass
    , playerHealth    :: Int
    , playerMaxHealth :: Int
    , playerStrength  :: Int
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
enemyStats Goblin   = EnemyStats 1 1
enemyStats Skeleton = EnemyStats 3 2
enemyStats Theif    = EnemyStats 5 3
enemyStats Boss     = EnemyStats 20 2


-- The name of each enemy type as shown in combat.
enemyTypeName :: EnemyClass -> String
enemyTypeName Goblin   = "Goblin"
enemyTypeName Skeleton = "Skeleton"
enemyTypeName Theif    = "Thief"
enemyTypeName Boss     = "Hollow King"


-- The boss enemy. High health makes this a longer encounter.
-- Its statistics come from enemyStats to avoid conflicting values.
hollowKingEnemy :: Enemy
hollowKingEnemy =
    let EnemyStats maxHP str = enemyStats Boss
    in Enemy
        { enemyName = enemyTypeName Boss
        , enemyClass = Boss
        , enemyHealth = maxHP
        , enemyMaxHp = maxHP
        , enemyStrength = str
        }


-- Generation of a regular enemy uses random location-based chances.


-- A location event that may happen while exploring.
-- BossEncounter is retained for compatibility, but random exploration
-- does not generate it. The boss is challenged explicitly at the gate.
data LocationEvent
    = EnemyEncounter Enemy
    | BossEncounter
    | RelicFound Relic
    | EmptyLocation
    deriving (Eq, Show)


-- Descriptions for each location in the wanderer's land.
locationDescription :: Location -> String
locationDescription Camp =
    "You rest at your camp by the ancient road, the pace"
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
    roll <- randomRIO (1 :: Int, 100)

    if roll <= 60
        then enemyFromClass Goblin
        else if roll <= 85
            then enemyFromClass Skeleton
            else enemyFromClass Theif

generateEnemy CrystalCaves = do
    roll <- randomRIO (1 :: Int, 100)

    if roll <= 30
        then enemyFromClass Goblin
        else if roll <= 60
            then enemyFromClass Skeleton
            else enemyFromClass Theif

generateEnemy AncientRuins = do
    roll <- randomRIO (1 :: Int, 100)

    if roll <= 25
        then enemyFromClass Goblin
        else if roll <= 55
            then enemyFromClass Skeleton
            else enemyFromClass Theif

-- Camp and Gate do not generate random enemy encounters.
-- This fallback keeps the function defined for every Location.
generateEnemy _ = enemyFromClass Goblin


-- Build an Enemy of the given class, using its deterministic stats.
enemyFromClass :: EnemyClass -> IO Enemy
enemyFromClass cls = do
    let EnemyStats maxHP str = enemyStats cls

    pure $
        Enemy
            { enemyName = enemyTypeName cls
            , enemyClass = cls
            , enemyHealth = maxHP
            , enemyMaxHp = maxHP
            , enemyStrength = str
            }


-- Each adventuring location contains one specific sacred relic.
locationRelic :: Location -> Maybe Relic
locationRelic DarkForest   = Just Wishbone
locationRelic CrystalCaves = Just Coin
locationRelic AncientRuins = Just Star
locationRelic Camp         = Nothing
locationRelic Gate         = Nothing


-- Generate a random location event for the given location.
--
-- If the location's relic has not been collected:
--   * 60% chance to find its relic.
--   * 30% chance to encounter an enemy.
--   * 10% chance to find nothing.
--
-- If the location's relic has already been collected:
--   * 70% chance to encounter an enemy.
--   * 30% chance to find nothing.
--
-- This increases relic discovery without repeatedly awarding duplicates.
-- Camp and Gate are safe and do not generate random encounters.
generateLocationEvent :: Game -> Location -> IO LocationEvent
generateLocationEvent game loc =
    case locationRelic loc of
        Nothing ->
            pure EmptyLocation

        Just relic -> do
            roll <- randomRIO (1 :: Int, 100)

            let alreadyOwned = relic `elem` gameRelics game

            if alreadyOwned
                then
                    if roll <= 70
                        then EnemyEncounter <$> generateEnemy loc
                        else pure EmptyLocation
                else
                    if roll <= 60
                        then pure (RelicFound relic)
                        else if roll <= 90
                            then EnemyEncounter <$> generateEnemy loc
                            else pure EmptyLocation


classStats :: CharacterClass -> ClassStats
classStats Brute   = ClassStats 25 4
classStats Mage    = ClassStats 18 6
classStats Assault = ClassStats 20 5

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
        { playerName = name
        , playerClass = chosenClass
        , playerHealth = maximumHP stats
        , playerMaxHealth = maximumHP stats
        , playerStrength = baseStrength stats
        , playerInventory = Inventory { relics = [] }
        }


-- ===========================================================================
-- DETERMINISTIC MECHANICS
-- ===========================================================================

-- Camp rest restores a player to the maximum health for their class.
-- Rest also moves the player to Camp and cannot revive a dead player.
rest :: Game -> Game
rest game
    | isGameOver game = game
    | otherwise =
        let player = gamePlayer game
        in game
            { gameLocation = Camp
            , gamePlayer =
                player { playerHealth = playerMaxHealth player }
            }


-- Add a relic to the player's collection (no duplicates allowed).
-- Keep the game collection and player inventory synchronized.
addRelic :: Game -> Relic -> Game
addRelic game relic =
    let existing = gameRelics game

        collected =
            if relic `elem` existing
                then existing
                else existing ++ [relic]

        player = gamePlayer game

    in game
        { gameRelics = collected
        , gamePlayer =
            player
                { playerInventory =
                    Inventory { relics = collected }
                }
        }


-- Construct the initial game state from a chosen character.
-- Preserve any relics already in the supplied player's inventory.
initialGame :: Player -> Game
initialGame player =
    let startingRelics =
            filter
                (`elem` relics (playerInventory player))
                [Wishbone, Coin, Star]

        startingPlayer =
            player
                { playerInventory =
                    Inventory { relics = startingRelics }
                }

    in Game
        { gamePlayer = startingPlayer
        , gameLocation = Camp
        , gameRelics = startingRelics
        , gameVictories = 0
        , gameLost = playerHealth player <= 0
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
        "1"      -> Just Attack
        "attack" -> Just Attack
        "2"      -> Just Defend
        "defend" -> Just Defend
        "3"      -> Just Flee
        "flee"   -> Just Flee
        _        -> Nothing


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
        Just chosenClass ->
            pure chosenClass

        Nothing -> do
            putStrLn "Invalid selection. Enter 1, 2, 3, or a class name."
            chooseClass


-- ===========================================================================
-- COMBAT
-- ===========================================================================

-- Run a complete combat encounter.
--
-- Each valid combat action consumes one turn:
--   * Attack: a surviving enemy retaliates, even if the player misses.
--   * Defend: the enemy attacks immediately for reduced damage.
--   * Flee: a failed escape allows the enemy to attack.
--
-- Defeated enemies never retaliate.
-- Invalid input does not consume a turn.
-- Boss eligibility is checked before starting a boss encounter.
combat :: Game -> Enemy -> IO Game
combat game enemy
    | isGameOver game = pure game

    | enemyClass enemy == Boss && not (isBossAvailable game) = do
        putStrLn "The Hollow King remains sealed behind the gate."
        pure game

    | otherwise = do
        putStrLn "\n--- Combat ---"
        putStrLn $ "The " ++ enemyName enemy ++ " prepares to fight!"

        combatLoop game enemy
  where
    combatLoop :: Game -> Enemy -> IO Game
    combatLoop current foe
        -- Player has fallen.
        | gameLost current
            || playerHealth (gamePlayer current) <= 0 = do
                putStrLn "You have fallen in battle."
                pure $ current { gameLost = True }

        -- Enemy has been slain.
        | enemyHealth foe <= 0 = do
            putStrLn $
                "You have vanquished the "
                ++ enemyName foe
                ++ "!"

            if enemyClass foe == Boss
                then do
                    putStrLn "The Hollow King falls. The gate opens!"
                    pure $ current { gameBossDefeated = True }
                else do
                    let victorious = updateVictories current

                    putStrLn $
                        "Regular victories: "
                        ++ show (gameVictories victorious)
                        ++ " (3 required)"

                    if isBossAvailable victorious
                        then
                            putStrLn $
                                "You have all three relics and enough victories."
                                ++ " The Hollow King can now be challenged!"
                        else pure ()

                    pure victorious

        | otherwise = do
            let player = gamePlayer current

            putStrLn $
                "\nYour HP: "
                ++ show (playerHealth player)
                ++ "/"
                ++ show (playerMaxHealth player)

            putStrLn $
                "Enemy HP: "
                ++ show (enemyHealth foe)
                ++ "/"
                ++ show (enemyMaxHp foe)

            putStrLn "Choose action: 1. Attack  2. Defend  3. Flee"

            input <- prompt "> "

            case parseCombatAction input of
                Just Attack -> do
                    (afterAttack, woundedEnemy) <-
                        playerAttack current foe

                    if enemyHealth woundedEnemy <= 0
                        then
                            combatLoop afterAttack woundedEnemy
                        else do
                            afterRetaliation <-
                                enemyTurn afterAttack woundedEnemy False

                            combatLoop afterRetaliation woundedEnemy

                Just Defend -> do
                    putStrLn $
                        "You brace yourself, reducing the incoming blow."

                    afterDefense <- enemyTurn current foe True
                    combatLoop afterDefense foe

                Just Flee -> do
                    escaped <- fleeCombat current foe

                    if escaped
                        then do
                            putStrLn "You successfully fled!"
                            pure current
                        else do
                            putStrLn $
                                "You failed to flee! The enemy attacks."

                            afterRetaliation <-
                                enemyTurn current foe False

                            combatLoop afterRetaliation foe

                Nothing -> do
                    putStrLn "Invalid action. Choose 1, 2, or 3."
                    combatLoop current foe


-- Perform an attack. 15% chance to miss; otherwise deals damage based on
-- the player's strength plus a random bonus from zero through four.
-- The combat loop handles retaliation if the enemy survives.
playerAttack :: Game -> Enemy -> IO (Game, Enemy)
playerAttack game enemy = do
    missRoll <- randomRIO (1 :: Int, 100)

    if missRoll <= 15
        then do
            putStrLn "You swing at the enemy but miss!"
            putStrLn "Your missed attack gives the enemy an opening."

            pure (game, enemy)
        else do
            bonus <- randomRIO (0 :: Int, 4)

            let damage =
                    max 1 (playerStrength (gamePlayer game) + bonus)

                woundedEnemy =
                    enemy
                        { enemyHealth =
                            max 0 (enemyHealth enemy - damage)
                        }

            putStrLn $
                "You strike the "
                ++ enemyName enemy
                ++ " for "
                ++ show damage
                ++ " damage!"

            pure (game, woundedEnemy)


-- The enemy attacks. If the player is defending, damage is halved,
-- rounding upward so incoming attacks always deal at least one damage.
-- Damage is based on strength plus a random bonus of zero or one.
enemyTurn :: Game -> Enemy -> Bool -> IO Game
enemyTurn game enemy defending
    | isGameOver game = pure game
    | enemyHealth enemy <= 0 = pure game

    | otherwise = do
        bonus <- randomRIO (0 :: Int, 1)

        let baseDamage = max 1 (enemyStrength enemy + bonus)

            damage =
                if defending
                    then (baseDamage + 1) `div` 2
                    else baseDamage

            player = gamePlayer game

            remainingHP =
                max 0 (playerHealth player - damage)

            updatedGame =
                game
                    { gamePlayer =
                        player { playerHealth = remainingHP }
                    , gameLost = remainingHP <= 0
                    }

        putStrLn $
            "The "
            ++ enemyName enemy
            ++ " hits you for "
            ++ show damage
            ++ " damage!"

        pure updatedGame


-- Attempt to flee from combat. 50% success rate.
-- The combat loop handles messages and attacks after a failed escape.
fleeCombat :: Game -> Enemy -> IO Bool
fleeCombat _ _ = do
    roll <- randomRIO (1 :: Int, 100)
    pure (roll <= 50)


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
        "Health:   "
        ++ show (playerHealth player)
        ++ "/"
        ++ show (playerMaxHealth player)

    putStrLn $ "Strength: " ++ show (playerStrength player)


confirmCharacter :: IO Bool
confirmCharacter = do
    input <- prompt "\nKeep this character? (yes/no): "

    case normalize input of
        "yes" -> pure True
        "y"   -> pure True
        "no"  -> pure False
        "n"   -> pure False

        _ -> do
            putStrLn "Please enter yes or no."
            confirmCharacter


-- Increase the regular victory count by one.
updateVictories :: Game -> Game
updateVictories game =
    game { gameVictories = gameVictories game + 1 }


-- Check whether the Hollow King encounter is available. The boss is
-- available when the player has at least three regular victories and
-- possesses all three sacred relics.
-- A dead player or a completed game cannot start another boss fight.
isBossAvailable :: Game -> Bool
isBossAvailable game =
    not (isGameOver game)
    && gameVictories game >= 3
    && allRelicsCollected (gameRelics game)
  where
    allRelicsCollected rs =
        all (`elem` rs) [Wishbone, Coin, Star]


-- Check whether the game has ended. The game ends when the player
-- either loses all health or defeats the Hollow King.
isGameOver :: Game -> Bool
isGameOver game =
    gameLost game
    || playerHealth (gamePlayer game) <= 0
    || gameBossDefeated game


-- The win condition: the living player has vanquished the Hollow King.
isVictory :: Game -> Bool
isVictory game =
    gameBossDefeated game
    && not (gameLost game)
    && playerHealth (gamePlayer game) > 0


-- Display a status report for the player.
displayStatus :: Game -> IO ()
displayStatus game = do
    let player = gamePlayer game

    putStrLn "\n--- Status ---"
    putStrLn $ "Name:          " ++ playerName player
    putStrLn $ "Class:         " ++ show (playerClass player)
    putStrLn $ "Location:      " ++ show (gameLocation game)

    putStrLn $
        "Health:        "
        ++ show (playerHealth player)
        ++ "/"
        ++ show (playerMaxHealth player)

    putStrLn $ "Strength:      " ++ show (playerStrength player)
    putStrLn $ "Relics:        " ++ show (gameRelics game)

    putStrLn $
        "Victories:     "
        ++ show (gameVictories game)
        ++ " (at least 3 required)"

    putStrLn $
        "Lost:          "
        ++ show (gameLost game || playerHealth player <= 0)

    putStrLn $
        "Boss available:"
        ++ show (isBossAvailable game)

    putStrLn $
        "Boss defeated: "
        ++ show (gameBossDefeated game)


-- Inspect the ancient gate and remaining requirements.
-- Visiting the gate updates the player's current location.
inspectGate :: Game -> IO Game
inspectGate game
    | isGameOver game = pure game

    | otherwise = do
        let atGate = game { gameLocation = Gate }

            missingRelics =
                filter
                    (`notElem` gameRelics game)
                    [Wishbone, Coin, Star]

            missingVictories =
                max 0 (3 - gameVictories game)

        putStrLn "\n--- The Ancient Gate ---"

        putStrLn $
            "The ancient gate stands before you, sealed by a glowing"
            ++ " arcane barrier."

        putStrLn $
            "Relics collected: "
            ++ show (length (gameRelics game))
            ++ "/3"

        putStrLn $
            "Regular battles won: "
            ++ show (gameVictories game)
            ++ " (at least 3 required)"

        if isBossAvailable game
            then do
                putStrLn $
                    "The gate's barrier begins to crack!"
                    ++ " The Hollow King awaits your challenge."

                putStrLn $
                    "Rest at camp if needed, then choose option 8"
                    ++ " to begin the final battle."
            else do
                putStrLn "The gate remains sealed."

                putStrLn $
                    "Missing relics: "
                    ++ show missingRelics

                putStrLn $
                    "Additional regular victories needed: "
                    ++ show missingVictories

        pure atGate


-- Challenge the Hollow King when eligible.
-- Eligibility is checked here as well as in the combat function,
-- so calling this function directly cannot bypass the requirements.
-- Fleeing and challenging again starts a fresh boss encounter.
challengeBoss :: Game -> IO Game
challengeBoss game
    | isGameOver game = pure game

    | not (isBossAvailable game) = do
        putStrLn $
            "The Hollow King is not yet available."
            ++ " Collect all three relics and win at least"
            ++ " three regular battles."

        pure game

    | otherwise = do
        putStrLn "\n--- The Hollow King Appears ---"

        putStrLn $
            "You approach the broken seal."
            ++ " The Hollow King steps forward to block your escape."

        combat (game { gameLocation = Gate }) hollowKingEnemy


-- ===========================================================================
-- EXPLORATION AND LOCATION EVENTS
-- ===========================================================================

-- Travel to a location and generate a random event.
-- The location is updated before the event occurs, including combat.
exploreLocation :: Game -> Location -> IO Game
exploreLocation game loc
    | isGameOver game = pure game

    | otherwise = do
        let arrived = game { gameLocation = loc }

        putStrLn $ "\n" ++ locationDescription loc

        event <- generateLocationEvent arrived loc

        case event of
            EnemyEncounter enemy -> do
                putStrLn $
                    "You encountered a "
                    ++ enemyTypeName (enemyClass enemy)
                    ++ "!"

                combat arrived enemy

            BossEncounter ->
                challengeBoss arrived

            RelicFound relic -> do
                putStrLn $ "You found the " ++ show relic ++ "!"

                let updated = addRelic arrived relic

                if isBossAvailable updated
                    then
                        putStrLn $
                            "You have all three relics and enough victories."
                            ++ " The Hollow King can now be challenged!"
                    else pure ()

                pure updated

            EmptyLocation -> do
                putStrLn "You find nothing of interest."
                pure arrived


-- Search the current location for relics.
-- Searching uses the same event chances as exploration and can
-- attract enemies. Camp cannot be searched for sacred relics.
searchLocation :: Game -> IO Game
searchLocation game
    | isGameOver game = pure game

    | otherwise =
        case gameLocation game of
            Camp -> do
                putStrLn "\n--- Searching the camp ---"

                putStrLn $
                    "Camp is safe, but there are no sacred relics here."

                putStrLn $
                    "Explore the Dark Forest, Crystal Caves,"
                    ++ " or Ancient Ruins."

                pure game

            Gate ->
                inspectGate game

            loc -> do
                putStrLn "\n--- Searching the area ---"

                putStrLn $
                    "You search carefully."
                    ++ " Nearby enemies may notice you..."

                exploreLocation game loc


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

-- The main location menu. Shows the available actions and dispatches
-- to the appropriate handler.
locationMenu :: Game -> IO Game
locationMenu game
    | isGameOver game = pure game

    | otherwise = do
        putStrLn "\n=== Wanderer's Compass ==="

        putStrLn $
            "You are currently at the "
            ++ show (gameLocation game)
            ++ "."

        putStrLn "What would you like to do?"
        putStrLn "1. Enter the Dark Forest"
        putStrLn "2. Enter the Crystal Caves"
        putStrLn "3. Enter the Ancient Ruins"
        putStrLn "4. Search your current location"
        putStrLn "5. Return to camp and rest"
        putStrLn "6. Inspect the ancient gate"
        putStrLn "7. View your status"
        putStrLn "8. Challenge the Hollow King (once eligible)"

        input <- prompt "> "

        case normalize input of
            "1" -> do
                putStrLn "You travel into the Dark Forest..."
                exploreLocation game DarkForest

            "2" -> do
                putStrLn "You travel into the Crystal Caves..."
                exploreLocation game CrystalCaves

            "3" -> do
                putStrLn "You travel into the Ancient Ruins..."
                exploreLocation game AncientRuins

            "4" ->
                searchLocation game

            "5" -> do
                putStrLn $
                    "You return to camp and rest,"
                    ++ " healing completely to full health."

                pure $ rest game

            "6" ->
                inspectGate game

            "7" -> do
                displayStatus game
                pure game

            "8" ->
                challengeBoss game

            _ -> do
                putStrLn "Invalid choice. Enter a number from 1 to 8."
                locationMenu game


-- ===========================================================================
-- MAIN ADVENTURE LOOP
-- ===========================================================================

-- The main game loop. Continues until the game is over.
gameLoop :: Game -> IO ()
gameLoop game
    | isGameOver game = do
        if isVictory game
            then
                putStrLn $
                    "\nYou have vanquished the Hollow King"
                    ++ " and escaped home!"
            else
                putStrLn $
                    "\nYou have fallen in battle."
                    ++ " The wanderer is defeated."

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

    putStrLn $
        "Recover the Wishbone, Coin, and Star,"
        ++ " win three regular battles,"
        ++ " and defeat the Hollow King to return home."

    player <- createPlayer

    let game = initialGame player

    gameLoop game