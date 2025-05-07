/* AssetLoader.pde
 * Elemental Clash – load all art & gifs
 * Handles loading images and animations used in the game.
 */
import gifAnimation.*;
import java.util.HashMap;
import processing.core.PImage;

final String IMG_CARDS_PATH = "img/cards/";
final String IMG_CORE_PATH  = "img/core/";
final String IMG_GOBLIN_PATH = "img/core/character/goblin/";

void loadAssets(){
  println("[ASSETS] Begin loading assets...");
  cardImages = new HashMap<String, PImage>();
  goblinImages = new HashMap<String, PImage>();

  println(" > Loading card images from /" + IMG_CARDS_PATH);
  String[][] cardAtlas = {
    {"PyrelashVortex",              "PyrelashVortex.png"},
    {"ArcticDescent",               "ArcticDescent.png"},
    {"DustlineHunt",                "DustlineHunt.png"},
    {"LunateShatter",
              "LunateShatter.png"},
    {"SugarveilMirage",
         "SugarveilMirage.png"},
    {"IronRequiemStrike",           "IronRequiemStrike.png"},
    {"GroundBrustMirage",           "GroundBrustMirage.png"},
    {"VoidSpellUnleashed",          "VoidSpellUnleashed.png"},
    {"NullivellesSilent",          "NullivellesSilent.png"},
    {"Woundcycle",
            "Woundcycle.png"},
    {"Shuffle",
            "Shuffle.png"},
    {"PaddleOfPain",                "PaddleOfPain.png"},
    {"SelvynneOverdriveOpenCab",    "SelvynneOverdriveOpenCab.png"},
    {"SelyrasFieryDescent",         "SelyrasFieryDescent.png"},
    {"TaenyaChainsaw",             "TaenyaChainsaw.png"},
    {"ThandorsWildRide",
           "ThandorsWildRide.png"},
    {"VexaliaFireFeast",
      "VexaliaFireFeast.png"},
    {"XelythFieryFeast",            "XelythFieryFeast.png"}
  };
  int cardsLoaded = 0;
  int cardsMissing = 0;
  for (String[] row : cardAtlas) {
    String key = row[0];
    String filename = row[1];
    PImage img = loadImage(IMG_CARDS_PATH + filename);
    if (img != null) {
      cardImages.put(key, img);
      cardsLoaded++;
    } else {
      println("   [WARN] Missing card image: " + IMG_CARDS_PATH + filename + " (Key: " + key + ")");
      cardsMissing++;
    }
  }
  println("   > Card Images Loaded: " + cardsLoaded + ", Missing: " + cardsMissing);
  println(" > Loading core images from /" + IMG_CORE_PATH);
  backgroundImg = loadImage(IMG_CORE_PATH + "background.png");
  if (backgroundImg == null) println("   [WARN] Missing core image: background.png");

  lootChestImg  = loadImage(IMG_CORE_PATH + "loot_chest.png");
  if (lootChestImg == null) println("   [WARN] Missing core image: loot_chest.png");

  PImage cardBackImg = loadImage(IMG_CORE_PATH + "backcard_season1_goblins_skyfall.png");
  if (cardBackImg != null) {
    cardImages.put("CardBack", cardBackImg);
    println("   ✓ Loaded: Card Back");
  } else {
    println("   [WARN] Missing core image: backcard_season1_goblins_skyfall.png");
  }

  println(" > Loading GIFs from /" + IMG_CORE_PATH);
  try {
    flawlessAnim = new Gif(this, IMG_CORE_PATH + "flawless_victory_drops.gif");
    if (flawlessAnim != null) {
      flawlessAnim.pause();
      println("   ✓ Loaded: Flawless Victory GIF");
    } else {
      println("   [WARN] Flawless GIF loaded as null.");
    }
  } catch(Exception e) {
    println("   [ERROR] Loading Flawless GIF failed: " + e.getMessage());
    flawlessAnim = null;
  }

  try {
    fatalityAnim = new Gif(this, IMG_CORE_PATH + "fatality_drops.gif");
    if (fatalityAnim != null) {
      fatalityAnim.pause();
      println("   ✓ Loaded: Fatality GIF");
    } else {
        println("   [WARN] Fatality GIF loaded as null.");
    }
  } catch(Exception e) {
    println("   [ERROR] Loading Fatality GIF failed: " + e.getMessage());
    fatalityAnim = null;
  }

  println(" > Loading Goblin Expressions from /" + IMG_GOBLIN_PATH);
  String[] goblinExpressions = {
    "smile", "laugh", "angry", "panicked", "shocked", "smug", "baffled"
  };
  int goblinImgLoaded = 0;
  int goblinImgMissing = 0;
  for (String expr : goblinExpressions) {
      String filename = "goblin_" + expr + ".png";
      PImage img = loadImage(IMG_GOBLIN_PATH + filename);
      if (img != null) {
          goblinImages.put(expr, img);
          println("   ✓ Loaded: " + filename);
          goblinImgLoaded++;
      } else {
          println("   [WARN] Missing Goblin image: " + IMG_GOBLIN_PATH + filename);
          goblinImgMissing++;
      }
  }
   println("   > Goblin Images Loaded: " + goblinImgLoaded + ", Missing: " + goblinImgMissing);


  println("[ASSETS] Asset loading finished.");
}
