local Color = require "color"

-- CONFIGURATION --

   -- Size of Display --
width  = 1200
height = 900

   -- Fullscreen? --
isFull = false

   -- Dimentions of Card Images --
img_width = 4320
img_height = 7680

   -- Scale of Cards --
scale = 0.017

   -- Set Random Seed --
seed = os.time() -- [default: 5 for testing, os.time() for main use]

   -- Target Points --
target_points = 100 -- [default: 25]

isSim = false

   -- End Button Options --
end_x = width*0.9
end_y = height*0.9
end_scale = 0.15


-- ENUMS --

   -- File Locations --
FILE_LOCATIONS = {
  -- Images --
  EMPTY   = "Sprites/Empty.png",
  BACK    = "Sprites/Card Back.png",
  END     = "Sprites/end.png",
  BG      = "Sprites/background.jpg",
  CRYSTAL = "Sprites/ManaCrystal.png",
  ORB     = "Sprites/Orb.png",
  SMOKE   = "Sprites/OrbSmoke.png",
  
  -- Sprite Sheets --
  GHOST  = "Sprites/Dark VFX 2/Dark VFX 2 (48x64).png",
  BEAM   = "Sprites/Holy VFX 02/Holy VFX 02.png",
  FIRE   = "Sprites/Holy VFX 01/Holy VFX 01 Repeatable.png",
  POINTS = "Sprites/Holy VFX 01/Holy VFX 01 Impact.png",  
  SPIRIT = "Sprites/Dark VFX 1/Dark VFX 1 (40x32).png",
  
  -- Sound Effects --
  PLACE  = "SFX/placeCard.mp3",
  DEATH  = "SFX/cardDeath.mp3",
  REVEAL = "SFX/revealCard.mp3",
  BGSFX  = "SFX/backgroundSounds.mp3",
  WHISP  = "SFX/whispers.mp3",

  -- Card Sheet --
  CSV   = "Resources/Tapesh Sankaran Project 3 Card Table - Sheet1.csv",
  
  -- Fonts --
  FONT1 = "Resources/Fighting Spirit 2 bold.otf",
  FONT2 = "Resources/JMH Typewriter-Thin.ttf",
}

   -- Colors --
COLORS = {
  TRUE_BLACK   = Color(0, 0, 0),

  BLACK        = Color(49/2, 54/2, 56/2),
  GREY         = Color(49, 54, 56),
  WHITE        = Color(224, 223, 213),
  
  DARK_RED     = Color(151/4, 21/4, 12/4),
  RED          = Color(151, 21, 12),
  ORANGE       = Color(221, 96, 18),
  YELLOW       = Color(241, 178, 76),
  
  PURPLE       = Color(0.5, 0.2, 0.5),
  
  DARK_BLUE    = Color(.2, .3, 0.8),
  BLUE         = Color(.3, .5, 1),
  
  DARK_GREEN   = Color(.18, .302, .255),
  DARKER_GREEN = Color(.1, .240, .210),
  
  DARK_GOLD    = Color(0.95, 0.810, 0.2),
  GOLD         = Color(1.00, 0.860, 0.25),
  LIGHT_GOLD   = Color(1.00, .922, .502),
}

   -- Weights --
ABILITY_WEIGHTS = {
  onPlay = 0.7,
  onDiscard = 0.6,
  onReveal = 1.2,
  onEoT = 1.4,
  copy = 0.4,
  buff = 1.7,
  curse = 0.7,
  sacrifice = 2.0,
  move = 0.5
}
   -- Keys --
ABILITY_KEYS = {
  "onPlay",
  "onReveal",
  "onDiscard",
  "onEoT",
  "copy",
  "buff",
  "curse",
  "sacrifice",
  "move"
}


-- GLOBAL VARS --
game = {}
ai = {}
pyAI = {}
cardData = {}
hasWon = false
cont_over = false
anim_manager = {}
initActionSize = 0
isPaused = false
menu_manager = {}
masterVolume = 1
bgMusicVolume = 1
effectsVolume = 1
result = "unfinished"

-- USEFUL FUNCTIONS --
function indexOf(tbl, val)
  for i, v in ipairs(tbl) do
    if v == val then return i end
  end
  return nil  -- Not found
end

function indexOfName(tbl, val)
  for i, v in ipairs(tbl) do
    if v.name == val then return i end
  end
  return nil  -- Not found
end

function love.conf(t)
   t.console = true
end