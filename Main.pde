/*──────────────────────────────────────────────────
 Elemental Card Game v0.0.1  PR (Public Release)
 Author: David Magnabosco | PSU - DART 205 // Dr. Greg O'Toole | May 7 2025
 ───────────────────────────────────────────────────*/

/* Main.pde
 * Elemental Clash – Core game logic and state management
 * Handles game flow, turns, phases, and interactions between players, enemies, and cards.
 */
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import processing.core.PImage;
import gifAnimation.*;
import processing.data.*;
import processing.event.MouseEvent;

final int PLAYER_MAX_HP = 30, PLAYER_MAX_MANA = 10;
final int ENEMY_MAX_HP_BAS = 40;
final int PLAYER_STARTING_CARDS = 5;
final int ENEMY_STARTING_CARDS  = 5;
final int PLAYER_STARTING_SHUFFLES = 1;
final int HAND_SIZE_LIMIT = 10;
final int TOOLBAR_H= 50;
final float BATTLE_W_RATIO = 0.44f, BATTLE_H_RATIO = 0.40f;
final float PLAYER_TX_RATIO = 0.30f, ENEMY_TX_RATIO = 0.70f;
final float HAND_CARD_SCALE = 1.10f, PLAYED_CARD_SCALE = 1.20f, CARD_ZOOM_SCALE = 2.50f;
final int HAND_SPACING = 200, HAND_Y_OFFSET = 195;
final int BTN_BAR_YOFF = 60, BTN_BAR_H = 35;
final int UI_PAD = 15, BAR_H = 18, BAR_SP = 8;
final int SPLASH_MS = 2000;

final int ANIM_DURATION = 600;
final int FLASH_P_FR = 45, FLASH_E_FR = 90;
final float ANIM_LERP = 0.18f, ANIM_STOP = 8;


ArrayList<String> actionLogHistory = new ArrayList<String>();
final int MAX_LOG_ENTRIES_DISPLAY_APPROX = 7;
String currentActionLogLine = "";
final float ACTION_LOG_TEXT_SIZE = 13;
final float ACTION_LOG_LINE_HEIGHT = ACTION_LOG_TEXT_SIZE * 1.4f;
final float ACTION_LOG_ENTRY_ALLOCATED_HEIGHT = ACTION_LOG_LINE_HEIGHT * 2.2f; // Fixed height per entry (~2 lines + padding)
final float ACTION_LOG_PADDING = 10; // Padding inside the log panel
final color ACTION_LOG_TEXT_COLOR = color(230, 230, 230);
final color ACTION_LOG_BG_COLOR = color(30, 30, 30, 200);
final float UI_PANEL_STROKE_WEIGHT = 1.2f;
final float SCROLLBAR_WIDTH = 12;
final float SCROLLBAR_BALL_HEIGHT = 25;
final color SCROLLBAR_TRACK_COLOR = color(50, 50, 50, 200);
final color SCROLLBAR_BALL_COLOR = color(150, 150, 150, 220);
final color SCROLLBAR_BALL_HOVER_COLOR = color(200, 200, 200, 255);


float actionLogPanelX, actionLogPanelY, actionLogPanelW, actionLogPanelH;
PFont logFont;
PFont boldLogFont;
PFont defaultSystemFont;
PFont titleFont;


long resolutionStart = 0;
long fadeStart       = 0;
final int FADE_DURATION = 600;


final color COLOR_BG = #462D14, COLOR_TOOLBAR = #321E0A,
            COLOR_BATTLE_AREA = #281E0A, COLOR_UI_BOX_BG = #000000,
            COLOR_UI_BOX_STROKE = #969696,
            COLOR_HP_BAR = #CC3333,
            COLOR_MANA_BAR = #2E6BE0, COLOR_TURN_PLAYER = #32CD32,
            COLOR_TURN_ENEMY = #CD5C5C, COLOR_TEXT_UI = #E0E0E0,

            COLOR_TEXT_NORMAL = #FFFFFF;
enum GameState { SPLASH, INITIALIZING, GAME_RUNNING, MENU, GAME_OVER, LOOT_SCREEN }
GameState currentGameState = GameState.SPLASH;
int currentPanel = 0;

Player player;
Enemy enemy;
ArrayList<Card> playerDeck = new ArrayList<Card>(),
                hand       = new ArrayList<Card>();
ArrayList<Card> playerDiscardPile = new ArrayList<Card>();

Card playerPlayedCard = null, enemyPlayedCard = null, hoveredCard = null;
Card currentlyZoomedCard = null;
float currentZoomScaleAnim = 0.0f;
float currentZoomAlphaAnim = 0.0f;
float targetZoomScale = 0.0f;
float targetZoomAlpha = 0.0f;
boolean zoomActive = false;
float zoomPopTimer = 0.0f;
boolean zoomPopActive = false;
final float ZOOM_ANIM_LERP_SPEED = 0.25f;
final float ZOOM_POP_SCALE_FACTOR = 1.08f;
final float ZOOM_POP_DURATION = 0.1f;
final float CARD_HAND_HOVER_Y_OFFSET = -20;


boolean playerTurn = true;

int phase = 0;
final int PHASE_PLAYER_ACTION = 0;
final int PHASE_ENEMY_ACTION = 1;
final int PHASE_REVEAL_ANIMATE_CARDS = 2;
final int PHASE_RESOLUTION_PAUSE = 3;
final int PHASE_APPLY_EFFECTS = 4;
final int PHASE_END_ROUND_FADE = 5;
final int PRE_RESOLUTION_DELAY_MS = 1500;


long phaseTimer = 0;
int playerShuffleCount = PLAYER_STARTING_SHUFFLES;
int enemyShuffleCount  = 1;
boolean gameOver = false, lootPrompt = false;
long splashStart;
float battleW, battleH, battleX, battleY;
float playerTargetX, playerTargetY, enemyTargetX, enemyTargetY;
float playerCardX, playerCardY, enemyCardX, enemyCardY;
float playerAlpha = 255, enemyAlpha = 255;

float cardZoomX, cardZoomY;
int flashTimer = 0;
boolean flashRed = true;

int difficulty = 1;

boolean playerDidAttackLastTurn = false;
boolean enemyDidAttackLastTurn = false;
boolean opponentIsSmilingThisTurn = false;

boolean isNewMoon = false;
boolean isGrounded = true;

HashMap<String, PImage> cardImages;
HashMap<String, PImage> goblinImages; // Map to hold goblin expressions
PImage backgroundImg, lootChestImg;
Gif flawlessAnim, fatalityAnim;
Button menuBtn, lootBtn, escapeBtn;
Button shuffleBtn, passBtn;
Button tryAgainBtn, quitBtn;
Button mReturn, mSettings, mHelp, mQuit;
Button btnSave, btnLoad;
Button btnEasy, btnMedium, btnHard, btnBackSet, btnBackHelp;

int actionLogScrollOffset = 0;
int displayableLogEntries = 0; // How many log *entries* fit

// Shortened Quips (approx 20 words max), no manual newlines
String[] goblinQuips = {
  "Heh, is that all? My cat coughs up scarier things. Try again!", // ~13 words
  "My grandma hits harder with a rolling pin! Are you even trying, squishy? So sad.", // ~16 words
  "Pathetic! My toenails are scarier. Did you find your strategy in a cereal box? Next!", // ~16 words
  "Hah! Predictable! I've seen more exciting battles in a sandbox. *Yawn*", // ~12 words
  "Ooh, scary moves... Did you learn that from a particularly fluffy squirrel?", // ~12 words
  "Was that supposed to be a plan? Or just random flailing with extra steps?", // ~14 words
  "BOR-ING! I might take a nap. Are you powered by a potato? Wake me later.", // ~15 words
  "I've seen scarier things in my soup! You fight like a confused dairy farmer.", // ~14 words
  "Is that a card or a napkin? My pet rock has better strategies. Brain gone on vacation?", // ~17 words
  "Wow, such innovation. I'm truly underwhelmed. Three cheers for mediocrity!", // ~10 words
  "Look who came crawling back! Ready for another round of getting stomped? Scaredy-cat!", // ~13 words
  "Oh goodie, the punching bag returned! Did you miss my handsome face? Let's see if you last longer!", // ~18 words
  "Back already? You must enjoy losing! Maybe try thinking this time? Or just stand there." // ~16 words
};
String currentGoblinQuip = "";
int goblinQuipIndex = 0;
float goblinQuipPanelX, goblinQuipPanelY, goblinQuipPanelW, goblinQuipPanelH;
final float GOBLIN_IMG_SIZE = 180; // Display size for goblin image
float goblinImgX, goblinImgY;
final color GOBLIN_AVATAR_BG_COLOR = COLOR_BATTLE_AREA; // Match battle area background
final float GOBLIN_AVATAR_BG_PADDING = 6; // Padding for the background circle - Reduced
final color GOBLIN_QUIP_PANEL_BG = color(255, 255, 240, 220);
final color GOBLIN_QUIP_TEXT_COLOR_PREFIX = color(0, 128, 0);
final color GOBLIN_QUIP_TEXT_COLOR_QUIP = color(80, 40, 20);
final float GOBLIN_QUIP_TEXT_SIZE = 14;

// Goblin Avatar Transition State
String currentGoblinExprKey = "smug"; // Start with smug
String nextGoblinExprKey = null;
float goblinExprAlpha = 255;
boolean isGoblinFadingOut = false;
final float GOBLIN_FADE_SPEED = 10; // Controls fade speed (higher is faster)


String battleAnnouncementText = "";
float battleAnnouncementTimer = 0.0f;
final float BATTLE_ANNOUNCEMENT_DURATION_SEC = 2.5f;
final float BATTLE_ANNOUNCEMENT_TEXT_SIZE = 30;
final color BATTLE_ANNOUNCEMENT_TEXT_COLOR = color(255, 255, 120);
final color BATTLE_ANNOUNCEMENT_BG_COLOR = color(0,0,0,190);


void settings(){
    size(1200, 800);
}

void setup(){
  frameRate(60);
  textAlign(CENTER, CENTER);
  rectMode(CORNER);
  imageMode(CORNER);
  ellipseMode(CENTER); // Use CENTER mode for drawing ellipse background
  splashStart = millis();

  titleFont = createFont("Georgia-Bold", 36);
  logFont = createFont("Arial", ACTION_LOG_TEXT_SIZE);
  try {
    boldLogFont = createFont("Arial-BoldMT", ACTION_LOG_TEXT_SIZE);
    if (boldLogFont == null) throw new Exception("Bold font failed to load");
  } catch (Exception e) {
    println("Warning: Bold font 'Arial-BoldMT' not found or failed to load. Using regular font instead. " + e.getMessage());
    boldLogFont = logFont;
  }
  defaultSystemFont = createFont("Arial", 16);

  actionLogPanelW = 260;
  actionLogPanelX = 10;
  goblinQuipPanelW = actionLogPanelW;
  goblinQuipPanelH = 100;
  goblinQuipPanelX = width - goblinQuipPanelW - 10;

  cardZoomX = actionLogPanelX + actionLogPanelW + 20;
  cardZoomY = TOOLBAR_H + 15;
}

void draw() {
  switch(currentGameState) {
    case SPLASH:
      drawSplash();
      if (millis() - splashStart > SPLASH_MS) {
        currentGameState = GameState.INITIALIZING;
      }
      break;
    case INITIALIZING:
      background(0);
      fill(255);
      textFont(defaultSystemFont);
      textSize(30);
      textAlign(CENTER, CENTER);
      text("Initializing…", width/2, height/2);
      initGame();
      currentGameState = GameState.GAME_RUNNING;
      break;
    case GAME_RUNNING:
      drawGameScreen();
      runPhaseLogic();
      break;
    case MENU:
      drawGameScreenDimmed();
      if (currentPanel == 1)      drawSettingsPanel();
      else if (currentPanel == 2) drawHelpPanel();
      else                        drawMenuPanel();
      break;
    case GAME_OVER:
      drawGameScreenDimmed();
      drawGameOver();
      break;
    case LOOT_SCREEN:
      drawGameScreenDimmed();
      drawLootScreen();
      break;
  }
}

void addToActionLog(String message) {
    actionLogHistory.add(0, message);
    if (actionLogHistory.size() > 100) { // Limit history size
        actionLogHistory.remove(actionLogHistory.size()-1);
    }
    currentActionLogLine = message;
    // Don't reset scroll on new message to allow user to read history
    // actionLogScrollOffset = 0;
    println("[LOG] " + message);
}

void setBattleAnnouncement(String message) {
    battleAnnouncementText = message;
    battleAnnouncementTimer = BATTLE_ANNOUNCEMENT_DURATION_SEC;
}

void drawBattleAnnouncement() {
    if (battleAnnouncementTimer > 0 && battleAnnouncementText != null && !battleAnnouncementText.isEmpty()) {
        pushStyle();
        float alpha = 255;
        float fullDuration = BATTLE_ANNOUNCEMENT_DURATION_SEC;
        float remainingTime = battleAnnouncementTimer;

        float fadeInDuration = 0.3f;
        float fadeOutDuration = 0.5f;
        if (remainingTime < fadeOutDuration) {
            alpha = map(remainingTime, 0, fadeOutDuration, 0, 255);
        } else if (fullDuration - remainingTime < fadeInDuration) {
            alpha = map(fullDuration - remainingTime, 0, fadeInDuration, 0, 255);
        }
        alpha = constrain(alpha,0,255);

        PFont announcementFont = (titleFont != null) ? titleFont : defaultSystemFont;
        textFont(announcementFont);
        textSize(BATTLE_ANNOUNCEMENT_TEXT_SIZE);
        textLeading(BATTLE_ANNOUNCEMENT_TEXT_SIZE * 1.2f);

        // Define area based on battle area
        float announcementAreaWidth = battleW - 40;
        float announcementAreaMaxHeight = battleH * 0.6f;
        float textPadding = 20;

        // Calculate required height for the text with wrapping
        float requiredTextHeight = getWrappedTextHeight(battleAnnouncementText, announcementAreaWidth - 2 * textPadding, announcementFont, BATTLE_ANNOUNCEMENT_TEXT_SIZE, BATTLE_ANNOUNCEMENT_TEXT_SIZE * 1.2f);
        float boxH = min(announcementAreaMaxHeight, requiredTextHeight + 2 * textPadding);

        float boxX = battleX + (battleW - announcementAreaWidth) / 2;
        float boxY = battleY + (battleH - boxH) / 2; // Center the box vertically

        // Draw background box
        fill(BATTLE_ANNOUNCEMENT_BG_COLOR, alpha * ( (BATTLE_ANNOUNCEMENT_BG_COLOR >> 24 & 0xFF) / 255.0f ) );
        noStroke();
        rect(boxX, boxY, announcementAreaWidth, boxH, 10);

        // Draw text centered and wrapped inside the box using 4-arg text()
        fill(red(BATTLE_ANNOUNCEMENT_TEXT_COLOR), green(BATTLE_ANNOUNCEMENT_TEXT_COLOR), blue(BATTLE_ANNOUNCEMENT_TEXT_COLOR), alpha);
        textAlign(CENTER, CENTER); // Ensure alignment is set correctly
        text(battleAnnouncementText, boxX, boxY, announcementAreaWidth, boxH); // Use 4-arg version for wrapping in rect

        popStyle();

        battleAnnouncementTimer -= 1.0 / frameRate;
        if (battleAnnouncementTimer <= 0) {
            battleAnnouncementText = "";
        }
    }
}


// Helper to estimate text height with wrapping
float getWrappedTextHeight(String txt, float maxWidth, PFont font, float fontSize, float lineSpacing) {
    if (txt == null || txt.isEmpty() || maxWidth <= 0) return 0;
    pushStyle();
    textFont(font, fontSize);
    textLeading(lineSpacing);
    float oneLineH = textAscent() + textDescent(); // Approx height of single line
    float totalH = 0;
    String[] lines = txt.split("\n"); // Split by manual newlines first

    for (String line : lines) {
        float w = textWidth(line);
        int wrappedLines = max(1, ceil(w / maxWidth)); // Estimate wrapped lines for this segment
        totalH += wrappedLines * lineSpacing;
    }
    // Adjust height slightly - textLeading includes space *between* lines.
    totalH -= (lines.length > 0 ? lineSpacing - oneLineH : 0);

    popStyle();
    return max(oneLineH, totalH); // Return at least one line height
}


void drawActionLogPanel() {
    float panelContentW = actionLogPanelW - ACTION_LOG_PADDING * 2;
    float panelContentH = actionLogPanelH - ACTION_LOG_PADDING; // Top padding only
    float startDrawY = actionLogPanelY + ACTION_LOG_PADDING;
    float currentDrawY = startDrawY;
    int entriesDrawnThisFrame = 0;

    // Calculate displayable entries based on fixed height allocation
    displayableLogEntries = floor(panelContentH / ACTION_LOG_ENTRY_ALLOCATED_HEIGHT);
    int maxScrollEntry = max(0, actionLogHistory.size() - displayableLogEntries);
    actionLogScrollOffset = constrain(actionLogScrollOffset, 0, maxScrollEntry);


    pushStyle();
    fill(ACTION_LOG_BG_COLOR);
    strokeWeight(UI_PANEL_STROKE_WEIGHT);
    stroke(COLOR_UI_BOX_STROKE);
    rect(actionLogPanelX, actionLogPanelY, actionLogPanelW, actionLogPanelH, 8);

    // Draw text entries, allocating fixed space
    textAlign(LEFT, TOP);
    textLeading(ACTION_LOG_LINE_HEIGHT); // Set leading for wrapping

    for (int i = 0; i < actionLogHistory.size(); i++) {
        int logIndex = actionLogScrollOffset + i;
        if (logIndex >= actionLogHistory.size()) break; // Past the end of history

        // Calculate Y position for this entry based on the fixed allocated height
        float entryY = startDrawY + entriesDrawnThisFrame * ACTION_LOG_ENTRY_ALLOCATED_HEIGHT;
        float entryAvailableH = ACTION_LOG_ENTRY_ALLOCATED_HEIGHT - ACTION_LOG_PADDING * 0.5f; // Height for text drawing

        // Check if drawing this entry would exceed panel bounds
        if (entryY + ACTION_LOG_LINE_HEIGHT > actionLogPanelY + actionLogPanelH - ACTION_LOG_PADDING) {
            break; // Stop drawing if the start of the next entry is outside the panel
        }

        String logEntry = actionLogHistory.get(logIndex);

        // Determine style based ONLY on specific keywords
        PFont currentFont = logFont;
        color currentFill = ACTION_LOG_TEXT_COLOR;
        String lowerEntry = logEntry.toLowerCase();

        if (lowerEntry.contains("out of mana!")) {
            currentFont = boldLogFont; currentFill = COLOR_HP_BAR;
        } else if (lowerEntry.contains("green goblin")) { // Only style the exact name
             currentFont = boldLogFont; currentFill = GOBLIN_QUIP_TEXT_COLOR_PREFIX;
        } else if (lowerEntry.contains(" you ") || lowerEntry.startsWith("you ") || lowerEntry.contains(" your ") || lowerEntry.startsWith("your ")) { // Style specific pronouns
             currentFont = boldLogFont; currentFill = COLOR_MANA_BAR;
        } else if (lowerEntry.contains("defeated")) { // Keep defeated styled
             currentFont = boldLogFont; currentFill = COLOR_HP_BAR;
        }
        // Removed styling based on "damage", "hits", "player"

        // Set style and draw the text with wrapping within the allocated box
        textFont(currentFont);
        fill(currentFill);
        textSize(ACTION_LOG_TEXT_SIZE);
        text(logEntry,
             actionLogPanelX + ACTION_LOG_PADDING,
             entryY, // Start drawing at the allocated Y
             panelContentW, // Constrain width
             entryAvailableH); // Constrain height (truncates if too long)

        entriesDrawnThisFrame++;
    }
    // Store the actual number of entries that were able to start drawing
    displayableLogEntries = entriesDrawnThisFrame;

    // Redraw scrollbar based on entries
    int actualMaxScroll = max(0, actionLogHistory.size() - displayableLogEntries);
    actionLogScrollOffset = constrain(actionLogScrollOffset, 0, actualMaxScroll); // Re-constrain based on actual fit

    if (actualMaxScroll > 0) {
        float scrollBarX = actionLogPanelX + actionLogPanelW + 2;
        float scrollBarY = actionLogPanelY + 2;
        float scrollBarH = actionLogPanelH - 4;

        fill(SCROLLBAR_TRACK_COLOR);
        noStroke();
        rect(scrollBarX, scrollBarY, SCROLLBAR_WIDTH, scrollBarH, SCROLLBAR_WIDTH/2);

        // Ensure displayableLogEntries is at least 1 for calculation if history exists
        int safeDisplayable = max(1, displayableLogEntries);
        int safeTotal = max(1, actionLogHistory.size());
        float ballHeight = max(SCROLLBAR_BALL_HEIGHT, scrollBarH * ((float)safeDisplayable / safeTotal));
        ballHeight = min(ballHeight, scrollBarH);
        float ballRange = scrollBarH - ballHeight;
        float ballY = scrollBarY;
         if (actualMaxScroll > 0) { // Use actual max scroll for mapping
             ballY += map(actionLogScrollOffset, 0, actualMaxScroll, 0, ballRange);
         }

        boolean ballHover = mouseX >= scrollBarX && mouseX <= scrollBarX + SCROLLBAR_WIDTH && mouseY >= ballY && mouseY <= ballY + ballHeight;
        fill(ballHover ? SCROLLBAR_BALL_HOVER_COLOR : SCROLLBAR_BALL_COLOR);
        rect(scrollBarX, constrain(ballY, scrollBarY, scrollBarY + scrollBarH - ballHeight), SCROLLBAR_WIDTH, ballHeight, SCROLLBAR_WIDTH/2);
    }

    popStyle();
}

// Trigger a change in goblin expression
void setGoblinExpression(String newKey) {
    if (goblinImages != null && goblinImages.containsKey(newKey) && !newKey.equals(currentGoblinExprKey) && nextGoblinExprKey == null) {
        nextGoblinExprKey = newKey;
        isGoblinFadingOut = true; // Start fading out current expression
        println("Starting fade out for Goblin expression: " + currentGoblinExprKey + " -> " + nextGoblinExprKey); // Debug
    }
}


void drawGoblinQuipPanel() {
    pushStyle();
    // Draw Panel Background
    fill(GOBLIN_QUIP_PANEL_BG);
    strokeWeight(UI_PANEL_STROKE_WEIGHT);
    stroke(COLOR_UI_BOX_STROKE);
    rect(goblinQuipPanelX, goblinQuipPanelY, goblinQuipPanelW, goblinQuipPanelH, 8);

    // Draw Title ("Gr33n G0b1in:")
    textFont(titleFont);
    textSize(GOBLIN_QUIP_TEXT_SIZE + 2);
    fill(GOBLIN_QUIP_TEXT_COLOR_PREFIX);
    textAlign(LEFT, TOP);
    text("Gr33n G0b1in:", goblinQuipPanelX + 10, goblinQuipPanelY + 10);

    // Draw Quip Text
    textFont(defaultSystemFont);
    textSize(GOBLIN_QUIP_TEXT_SIZE);
    fill(GOBLIN_QUIP_TEXT_COLOR_QUIP);
    textAlign(LEFT, TOP);
    float titleHeight = textAscent() + textDescent() + 6;
    float jokeY = goblinQuipPanelY + 10 + titleHeight;
    float jokeAreaHeight = goblinQuipPanelH - (jokeY - goblinQuipPanelY) - 10;
    textLeading(GOBLIN_QUIP_TEXT_SIZE * 1.3f);
    text(currentGoblinQuip, // Use the single selected quip
         goblinQuipPanelX + 10,
         jokeY,
         goblinQuipPanelW - 20, // Width constraint
         jokeAreaHeight       // Height constraint
    );

    // --- Goblin Avatar Drawing with Transition ---
    // Update alpha for fade effect
    if (isGoblinFadingOut) {
        goblinExprAlpha -= GOBLIN_FADE_SPEED;
        if (goblinExprAlpha <= 0) {
            goblinExprAlpha = 0;
            isGoblinFadingOut = false;
            if (nextGoblinExprKey != null) { // Ensure next key is valid before switching
               currentGoblinExprKey = nextGoblinExprKey;
               println("Switched Goblin to: " + currentGoblinExprKey); // Debug
            }
             nextGoblinExprKey = null; // Clear next key regardless
        }
    } else if (goblinExprAlpha < 255) {
        goblinExprAlpha += GOBLIN_FADE_SPEED;
        if (goblinExprAlpha > 255) goblinExprAlpha = 255;
    }
    goblinExprAlpha = constrain(goblinExprAlpha, 0, 255);


    // Get the current image
    PImage goblinImg = (goblinImages != null) ? goblinImages.get(currentGoblinExprKey) : null;

    if (goblinImg != null) {
        pushMatrix(); // Isolate image transformations
        translate(goblinImgX, goblinImgY); // Move origin to image center

        // Draw Background Circle (using battle area color)
        noStroke();
        fill(GOBLIN_AVATAR_BG_COLOR); // Use battle area color
        ellipse(0, 0, GOBLIN_IMG_SIZE + GOBLIN_AVATAR_BG_PADDING * 2, GOBLIN_IMG_SIZE + GOBLIN_AVATAR_BG_PADDING * 2);

        // Draw Goblin Image with tint for fade effect
        tint(255, goblinExprAlpha); // Apply alpha fade
        imageMode(CENTER);
        image(goblinImg, 0, 0, GOBLIN_IMG_SIZE, GOBLIN_IMG_SIZE);
        noTint(); // Reset tint
        popMatrix(); // Restore previous transformations

        imageMode(CORNER); // Reset imageMode
    }
    // --- End Goblin Avatar Drawing ---

    popStyle();
}



void drawSplash(){
  background(15, 0, 15);
  float r = 40, cx = width/2f, cy = height/2f;
  float a = map(millis()%1000, 0, 1000, 0, TWO_PI);
  stroke(255, 200);
  strokeWeight(5);
  noFill();
  arc(cx, cy, r*2, r*2, a, a + PI*1.5);
  fill(255);
  textFont(defaultSystemFont);
  textSize(26);
  textAlign(CENTER, CENTER);
  text("Loading Elemental Clash…", cx, cy + r + 48);
}

void initGame(){
  loadAssets();
  battleW = width * BATTLE_W_RATIO;
  battleH = height * BATTLE_H_RATIO;
  battleX = (width - battleW) / 2;
  battleY = TOOLBAR_H + (height - TOOLBAR_H - battleH) / 2;

  float playedW = Card.BASE_WIDTH * PLAYED_CARD_SCALE;
  float playedH = Card.BASE_HEIGHT * PLAYED_CARD_SCALE;
  playerTargetX = battleX + battleW * PLAYER_TX_RATIO - playedW / 2;
  playerTargetY = battleY + (battleH - playedH) / 2;
  enemyTargetX  = battleX + battleW * ENEMY_TX_RATIO  - playedW / 2;
  enemyTargetY  = playerTargetY;

  actionLogPanelH = battleH; // Set height equal to battleArea height
  actionLogPanelY = battleY; // Align top with battleArea top
  goblinQuipPanelY = battleY; // Align top with battleArea top

  // Calculate position for Goblin Image (below quip panel)
  goblinImgX = goblinQuipPanelX + goblinQuipPanelW / 2; // Centered below quip panel
  goblinImgY = goblinQuipPanelY + goblinQuipPanelH + 40 + GOBLIN_IMG_SIZE / 2; // Y position (center of image) - Adjusted padding


  player = new Player(PLAYER_MAX_HP, PLAYER_MAX_MANA);
  enemy  = new Enemy("Green Goblin", getEnemyHP());

  initPlayerDeck();
  shuffleDeck(playerDeck);
  drawHand();

  enemy.initializeEnemyDeck();
  shuffleDeck(enemy.enemyDeck);
  enemy.drawStartingHand();
  enemyShuffleCount = getEnemyShuffles();

  buildButtons();

  resetVolatileState();
  phase = PHASE_PLAYER_ACTION;
  playerTurn = true;
  addToActionLog("Your turn to act!");
  // Select a random quip on initial game start/reset
  goblinQuipIndex = (int)random(goblinQuips.length);
  currentGoblinQuip = goblinQuips[goblinQuipIndex];
  currentGoblinExprKey = "smug"; // Reset expression state
  nextGoblinExprKey = null;
  goblinExprAlpha = 255;
  isGoblinFadingOut = false;
  println("Initial Quip: " + currentGoblinQuip);
}

void resetVolatileState(){
  gameOver = false;
  lootPrompt = false;
  actionLogHistory.clear();
  addToActionLog("New Game Started!");
  playerPlayedCard = null;
  enemyPlayedCard = null;
  hoveredCard = null;
  currentlyZoomedCard = null;
  currentZoomScaleAnim = 0.0f;
  currentZoomAlphaAnim = 0.0f;
  targetZoomScale = 0.0f;
  targetZoomAlpha = 0.0f;
  zoomActive = false;
  zoomPopTimer = 0.0f;
  zoomPopActive = false;
  flashTimer = 0;
  playerAlpha = 255;
  enemyAlpha = 255;
  battleAnnouncementText = "";
  battleAnnouncementTimer = 0.0f;

  playerShuffleCount = PLAYER_STARTING_SHUFFLES;
  enemyShuffleCount = 1;
  if (player != null) {
      player.frozenTurns = 0;
      player.healDisabledTurns = 0;
      player.attackDisabledTurns = 0;
      player.skipManaRegenTurns = 0;
      player.burnTurns = 0;
      player.burnAmount = 0;
      player.shamedTurns = 0;
  }

   if (enemy != null) {
      enemy.frozenTurns = 0;
      enemy.healDisabledTurns = 0;
      enemy.attackDisabledTurns = 0;
      enemy.skipManaRegenTurns = 0;
      enemy.burnTurns = 0;
      enemy.burnAmount = 0;
      enemy.shamedTurns = 0;
   }

  playerDidAttackLastTurn = false;
  enemyDidAttackLastTurn = false;

  isNewMoon = false;
  isGrounded = true;

  if(flawlessAnim != null) flawlessAnim.pause();
  if(fatalityAnim != null) fatalityAnim.pause();
  if(flawlessAnim != null) flawlessAnim.jump(0);
  if(fatalityAnim != null) fatalityAnim.jump(0);

  updateShuffleButton();

  // Select a "reset" specific quip if appropriate context exists, or random otherwise
  goblinQuipIndex = (int)random(goblinQuips.length); // Pick a new one on reset too
  currentGoblinQuip = goblinQuips[goblinQuipIndex];
  currentGoblinExprKey = "smug"; // Reset expression state
  nextGoblinExprKey = null;
  goblinExprAlpha = 255;
  isGoblinFadingOut = false;
  println("Reset Quip: " + currentGoblinQuip);
}

void updateShuffleButton() {
  if (shuffleBtn != null) {
     shuffleBtn.label = "<< Shuffle (" + playerShuffleCount + ")";
  }
}

void buildButtons(){
  menuBtn = new Button(10, 10, 90, 30, "Menu");
  lootBtn = new Button(110, 10, 120, 30, "Seize Loot");
  lootBtn.enabled = false;
  escapeBtn = new Button(width - 120, 10, 100, 30, "Escape");
  shuffleBtn = new Button(30, height - BTN_BAR_YOFF, 185, BTN_BAR_H, "<< Shuffle (" + playerShuffleCount + ")");
  passBtn    = new Button(width - 170, height - BTN_BAR_YOFF, 140, BTN_BAR_H, "Bypass >>");
  float btnW = 120, btnH = 45, btnSpacing = 28;
  tryAgainBtn = new Button(width / 2 - (btnW * 2 + btnSpacing) / 2, height / 2 + 150, btnW, btnH, "Restart");
  quitBtn     = new Button(tryAgainBtn.x + btnW + btnSpacing, height / 2 + 150, btnW, btnH, "Quit");
  float cx = width / 2f, bw = 220, bh = 45, gap = 65, sy = 220;
  mReturn   = new Button(cx - bw/2, sy + 0 * gap, bw, bh, "Return to Game");
  mSettings = new Button(cx - bw/2, sy + 1 * gap, bw, bh, "Settings");
  mHelp     = new Button(cx - bw/2, sy + 2 * gap, bw, bh, "How to Play");
  btnSave   = new Button(cx - bw/2, sy + 3 * gap, bw, bh, "Save Game");
  btnLoad   = new Button(cx - bw/2, sy + 4 * gap, bw, bh, "Load Game");
  mQuit     = new Button(cx - bw/2, sy + 5 * gap + 20, bw, bh, "Quit Game");
  float dw = 110, dx = cx - (dw * 3 + 40) / 2, dy = 180;
  btnEasy   = new Button(dx      , dy, dw, 45, "Easy");
  btnMedium = new Button(dx + dw + 20, dy, dw, 45, "Medium");
  btnHard   = new Button(dx + 2 * (dw + 20), dy, dw, 45, "Hard");
  btnBackSet  = new Button(cx - 60, dy + 110, 120, 45, "Return");
  btnBackHelp = new Button(cx - 60, height - 90, 120, 45, "Return");
}

void drawGameScreen(){
  drawBackground();
  drawToolbar();
  drawFlash();
  drawBattleArea();
  drawTurnIndicator();
  drawTopUI();
  drawEnemyHand();
  drawActionLogPanel();
  drawGoblinQuipPanel();
  drawBattleAnnouncement();
  drawPlayerHand();
  shuffleBtn.display();
  passBtn.display();

  renderPlayedCards();

  drawPlayerHand();
  updateShuffleButton();
  if (shuffleBtn != null) shuffleBtn.display();
  if (passBtn != null) {
    passBtn.enabled = (playerTurn && phase == PHASE_PLAYER_ACTION && player != null && !player.isFrozen() && !player.isAttackDisabled());
    passBtn.display();
  }

  if (zoomActive) {
      targetZoomAlpha = 255;
      if (zoomPopTimer > 0) {
          targetZoomScale = CARD_ZOOM_SCALE * ZOOM_POP_SCALE_FACTOR;
          zoomPopTimer -= 1.0f / frameRate;
          if(zoomPopTimer <=0) {
             zoomPopActive = false;
             targetZoomScale = CARD_ZOOM_SCALE;
          }
      } else {
          targetZoomScale = CARD_ZOOM_SCALE;
      }
  } else {
      targetZoomScale = 0.0f;
      targetZoomAlpha = 0.0f;
  }

  currentZoomScaleAnim = lerp(currentZoomScaleAnim, targetZoomScale, ZOOM_ANIM_LERP_SPEED);
  currentZoomAlphaAnim = lerp(currentZoomAlphaAnim, targetZoomAlpha, ZOOM_ANIM_LERP_SPEED);
  if (zoomActive && !zoomPopActive ) {
    if(abs(currentZoomScaleAnim - CARD_ZOOM_SCALE) < 0.01f) {
      currentZoomScaleAnim = CARD_ZOOM_SCALE;
    }
  }


  if(currentlyZoomedCard != null && currentZoomAlphaAnim > 1 && playerTurn && phase == PHASE_PLAYER_ACTION) {
    currentlyZoomedCard.displayWithAlpha(cardZoomX, cardZoomY, currentZoomScaleAnim, currentZoomAlphaAnim, true);
  } else if (!zoomActive && currentZoomAlphaAnim < 10) {
    if (abs(currentZoomScaleAnim - 0.0f) < 0.1f) currentZoomScaleAnim = 0.0f;
    if (currentZoomScaleAnim == 0.0f) currentlyZoomedCard = null;
  }


  if(lootPrompt) drawLootPromptOverlay();
}

void drawPlayerHand() {
  if (hand == null || hand.isEmpty()) return;

  float w = Card.BASE_WIDTH * HAND_CARD_SCALE;
  float h = Card.BASE_HEIGHT * HAND_CARD_SCALE;
  int   baseY = height - HAND_Y_OFFSET;
  int   numCards = hand.size();
  float totalHandWidth = (numCards - 1) * HAND_SPACING + w;
  float startX = width / 2 - totalHandWidth / 2;
  Card newlyHoveredThisFrame = null;
  boolean canPlayerAct = playerTurn && phase == PHASE_PLAYER_ACTION && player != null && !player.isFrozen() && !player.isAttackDisabled();

  for (int i = 0; i < numCards; i++) {
    float x = startX + i * HAND_SPACING;
    float y = baseY;
    Card c = hand.get(i);

    boolean overOriginalPos = mouseX >= x && mouseX <= x + w && mouseY >= baseY && mouseY <= baseY + h;
    boolean overHoverPos = mouseX >= x && mouseX <= x + w && mouseY >= baseY + CARD_HAND_HOVER_Y_OFFSET && mouseY <= baseY + CARD_HAND_HOVER_Y_OFFSET + h;

    if ((overOriginalPos || overHoverPos) && canPlayerAct) {
      y = baseY + CARD_HAND_HOVER_Y_OFFSET;
      newlyHoveredThisFrame = c;
      if (hoveredCard != c) {
        hoveredCard = c;
        if (mouseX != pmouseX || mouseY != pmouseY) {
            if (currentlyZoomedCard != c || !zoomActive) {
                currentZoomScaleAnim = HAND_CARD_SCALE * 0.8f;
                currentZoomAlphaAnim = 0;
                zoomPopTimer = ZOOM_POP_DURATION;
                zoomPopActive = true;
            }
            currentlyZoomedCard = c;
            zoomActive = true;
        }
      } else if (mouseX != pmouseX || mouseY != pmouseY) {
        if (currentlyZoomedCard != c || !zoomActive) {
            currentZoomScaleAnim = HAND_CARD_SCALE * 0.8f;
            currentZoomAlphaAnim = 0;
            zoomPopTimer = ZOOM_POP_DURATION;
            zoomPopActive = true;
        }
         currentlyZoomedCard = c;
         if (!zoomActive) {
             zoomActive = true;
             zoomPopTimer = ZOOM_POP_DURATION;
             currentZoomScaleAnim = HAND_CARD_SCALE * 0.8f;
             currentZoomAlphaAnim = 0;
         }
      }
    }

    c.displayWithAlpha(x, y, HAND_CARD_SCALE, 255, false);

    if (!canPlayerAct) {
        pushStyle();
        fill(0, 0, 0, 150);
        noStroke();
        rect(x, y, w, h, 8 * HAND_CARD_SCALE);
        popStyle();
    }
  }

  if (newlyHoveredThisFrame == null ) {
      if (hoveredCard != null) {
        hoveredCard = null;
      }
      if (zoomActive) {
         boolean mouseOverZoomArea = mouseX >= cardZoomX && mouseX <= cardZoomX + Card.BASE_WIDTH * currentZoomScaleAnim && mouseY >= cardZoomY && mouseY <= cardZoomY + Card.BASE_HEIGHT * currentZoomScaleAnim;
         if (!mouseOverZoomArea && newlyHoveredThisFrame == null) {
            zoomActive = false;
         }
      }
  } else {
     if (currentlyZoomedCard != newlyHoveredThisFrame && (mouseX != pmouseX || mouseY != pmouseY) ) {
        if(newlyHoveredThisFrame != null){
          currentZoomScaleAnim = HAND_CARD_SCALE * 0.8f;
          currentZoomAlphaAnim = 0;
          zoomPopTimer = ZOOM_POP_DURATION;
          currentlyZoomedCard = newlyHoveredThisFrame;
          zoomActive = true;
          zoomPopActive = true;
        }
     }
  }

  if (!zoomActive && currentZoomAlphaAnim < 10 && abs(currentZoomScaleAnim) < 0.1f) {
      currentlyZoomedCard = null;
  }

  if (hoveredCard != null && currentlyZoomedCard == hoveredCard && zoomActive && canPlayerAct) {
    int idx = hand.indexOf(hoveredCard);
    if (idx != -1) {
        float xPos = startX + idx * HAND_SPACING;
        float yPos = baseY + CARD_HAND_HOVER_Y_OFFSET;
        pushStyle();
        noFill();
        stroke(#FFFF00);
        strokeWeight(4);
        rect(xPos - 2, yPos - 2, w + 4, h + 4, 8 * HAND_CARD_SCALE);
        popStyle();
    }
  }
}


void drawLootPromptOverlay() {
  pushStyle();
  fill(0, 200);
  rect(0, 0, width, height);
  fill(#FFD700);
  textSize(30);
  textAlign(CENTER, CENTER);
  text("Enemy Defeated!\nClick \"Seize Loot\" in the toolbar.",
       width/2, height/2);
  popStyle();
}

void mouseWheel(MouseEvent event) {
   int approxDisplayable = floor((actionLogPanelH - ACTION_LOG_PADDING*2) / ACTION_LOG_ENTRY_ALLOCATED_HEIGHT);
   int actualMaxScroll = max(0, actionLogHistory.size() - approxDisplayable);
   actualMaxScroll = max(0, actionLogHistory.size() - 1); // Allow scrolling to make last item visible


  if (mouseX > actionLogPanelX && mouseX < actionLogPanelX + actionLogPanelW + SCROLLBAR_WIDTH + 2 &&
      mouseY > actionLogPanelY && mouseY < actionLogPanelY + actionLogPanelH) {
    if (actualMaxScroll > 0) { // Use actual max scroll here
        float e = event.getCount();
        if (e < 0) { // Scroll down
          actionLogScrollOffset = min(actionLogScrollOffset + 1, actualMaxScroll);
        } else if (e > 0) { // Scroll up
          actionLogScrollOffset = max(0, actionLogScrollOffset - 1);
        }
    }
  }
}


void mousePressed(){
  switch(currentGameState){
    case GAME_RUNNING:
      handleGameInput();
      break;
    case MENU:
      handleMenuInput();
      break;
    case GAME_OVER:
      if(tryAgainBtn != null && tryAgainBtn.isMouseOver()){
        currentGameState = GameState.INITIALIZING;
      } else if(quitBtn != null && quitBtn.isMouseOver()) {
        exit();
      }
      break;
    case LOOT_SCREEN:
      if(mouseY > TOOLBAR_H){
          exit();
      }
      if(mouseY < TOOLBAR_H){
        if(menuBtn != null && menuBtn.isMouseOver()){
          currentPanel = 3;
          currentGameState = GameState.MENU;
          return;
        }
        if(lootBtn != null && lootBtn.isMouseOver() && lootBtn.label.equals("Exit Game")){
            exit();
        }
        if(escapeBtn != null && escapeBtn.isMouseOver()){
             exit();
        }
      }
      break;
    case SPLASH:
         if (millis() - splashStart > 500) {
              currentGameState = GameState.INITIALIZING;
         }
         break;
    case INITIALIZING:
        break;
  }
}

void handleGameInput(){
  if(mouseY < TOOLBAR_H){
    if(menuBtn != null && menuBtn.isMouseOver()){
      currentPanel = 3;
      currentGameState = GameState.MENU;
      return;
    }
    if(lootBtn != null && lootBtn.isMouseOver() && lootBtn.enabled){
      currentGameState = GameState.LOOT_SCREEN;
      lootPrompt = false;
      if(flawlessAnim != null) {
         flawlessAnim.play();
         flawlessAnim.jump(0);
      }
      return;
    }
    if(escapeBtn != null && escapeBtn.isMouseOver()){
      gameOver = true;
      currentGameState = GameState.GAME_OVER;
      addToActionLog("You fled!");
       if(fatalityAnim != null) {
          fatalityAnim.play();
          fatalityAnim.jump(0);
       }
      return;
    }
  }

  if(playerTurn && phase == PHASE_PLAYER_ACTION && player != null && !player.isFrozen() && !player.isAttackDisabled()){
    if(shuffleBtn != null && shuffleBtn.isMouseOver() && playerShuffleCount > 0){
      playerShuffleCount--;
      playerDeck.addAll(hand);
      hand.clear();
      playerDeck.addAll(playerDiscardPile);
      playerDiscardPile.clear();

      shuffleDeck(playerDeck);

      for(int i = 0; i < PLAYER_STARTING_CARDS && hand.size() < HAND_SIZE_LIMIT; i++){
        if(playerDeck.isEmpty()){
          println("[WARN] Player deck is empty after shuffle. Cannot draw full hand.");
          break;
        }
        hand.add(playerDeck.remove(0));
      }
      addToActionLog("Shuffled deck. Drew " + hand.size() + " cards.");
      playerPlayedCard = null;
      playerDidAttackLastTurn = false;
      phaseTimer = 0;
      phase = PHASE_ENEMY_ACTION;
      return;
    }
    if(passBtn != null && passBtn.isMouseOver()){
      if (player.canRegenMana()) {
        player.mana = min(PLAYER_MAX_MANA, player.mana + 1);
        addToActionLog("You passed the turn, gained 1 Mana.");
      } else {
        addToActionLog("You passed the turn. Mana regen skipped.");
      }
      playerPlayedCard = null;
      playerDidAttackLastTurn = false;
      phaseTimer = 0;
      phase = PHASE_ENEMY_ACTION;
      return;
    }
  }

  if(playerTurn && phase == PHASE_PLAYER_ACTION && player != null && !player.isFrozen() && !player.isAttackDisabled() && hand != null){
    float cw = Card.BASE_WIDTH * HAND_CARD_SCALE;
    float ch = Card.BASE_HEIGHT * HAND_CARD_SCALE;
    int handBaseY = height - HAND_Y_OFFSET;
    int numCards = hand.size();
    float totalHandWidth = (numCards - 1) * HAND_SPACING + cw;
    float startX = width / 2 - totalHandWidth / 2;
    for(int i = hand.size() - 1; i >= 0; i--){
      float cx = startX + i * HAND_SPACING;
      float currentCardDisplayY = handBaseY;
      if (hoveredCard == hand.get(i)) {
          currentCardDisplayY = handBaseY + CARD_HAND_HOVER_Y_OFFSET;
      }

      if(mouseX >= cx && mouseX <= cx + cw && mouseY >= currentCardDisplayY && mouseY <= currentCardDisplayY + ch){
        Card sel = hand.get(i);
        if(player.mana >= sel.manaCost){
          hand.remove(i);
          player.mana -= sel.manaCost;
          playerPlayedCard = sel;
          playerCardX = cx;
          playerCardY = currentCardDisplayY;
          playerAlpha = 255;
          addToActionLog("Playing " + sel.name + "…");
          playerDidAttackLastTurn = true;
          currentlyZoomedCard = null;
          hoveredCard = null;
          zoomActive = false;
          phaseTimer = 0;
          phase = PHASE_ENEMY_ACTION;
          return;
        } else {
          addToActionLog("OUT OF MANA! Use BYPASS to gain Mana.");
          setGoblinExpression("laugh"); // Example trigger
          return;
        }
      }
    }
  }
}


void handleMenuInput(){
  textFont(defaultSystemFont);
  if(currentPanel == 1){
    if(btnEasy != null && btnEasy.isMouseOver()){
      difficulty = 0;
      applyDifficulty();
    } else if(btnMedium != null && btnMedium.isMouseOver()){
      difficulty = 1;
      applyDifficulty();
    } else if(btnHard != null && btnHard.isMouseOver()){
      difficulty = 2;
      applyDifficulty();
    } else if(btnBackSet != null && btnBackSet.isMouseOver()) {
      currentPanel = 3;
    }
  } else if(currentPanel == 2){
    if(btnBackHelp != null && btnBackHelp.isMouseOver()) {
      currentPanel = 3;
    }
  } else {
    if(mReturn != null && mReturn.isMouseOver()) {
      currentGameState = GameState.GAME_RUNNING;
      currentPanel = 0;
    } else if(mSettings != null && mSettings.isMouseOver()) {
      currentPanel = 1;
    } else if(mHelp != null && mHelp.isMouseOver()) {
      currentPanel = 2;
    } else if(btnSave != null && btnSave.isMouseOver()) {
      saveGame();
    } else if(btnLoad != null && btnLoad.isMouseOver()) {
      loadGame();
      if (currentGameState == GameState.GAME_RUNNING) currentPanel = 0;
    } else if(mQuit != null && mQuit.isMouseOver()) {
      exit();
    }
  }
}


void runPhaseLogic() {
  long now = millis();
  if ((player != null && player.hp <= 0) || (enemy != null && enemy.hp <= 0)) {
      if (currentGameState != GameState.GAME_OVER && currentGameState != GameState.LOOT_SCREEN) {
         endBattle(player != null && player.hp > 0);
      }
      return;
  }

  switch(phase) {
    case PHASE_PLAYER_ACTION:
      if (playerTurn) {
        if (phaseTimer == 0) {
            player.startTurnStatusUpdate();
            if (player.canRegenMana()) {
               player.mana = min(PLAYER_MAX_MANA, player.mana + 1);
               println("Player regenerated 1 Mana. Current Mana: " + player.mana);
            } else {
                println("Player mana regeneration skipped.");
            }
            player.endTurnManaStatusUpdate();
            addToActionLog("Your turn to act!");
            // Select and display the *next* quip in the sequence
            goblinQuipIndex = (goblinQuipIndex + 1) % goblinQuips.length;
            currentGoblinQuip = goblinQuips[goblinQuipIndex];
            // Simple logic to maybe change expression based on quip (example)
             String lowerQuip = currentGoblinQuip.toLowerCase();
            if (lowerQuip.contains("?")) setGoblinExpression("baffled");
            else if (lowerQuip.contains("punching bag") || lowerQuip.contains("hah!")) setGoblinExpression("laugh");
            else if (lowerQuip.contains("!") || lowerQuip.contains("pathetic")) setGoblinExpression("angry");
            else if (lowerQuip.contains("scaredy-cat") || lowerQuip.contains("crawling")) setGoblinExpression("shocked");
            else if (lowerQuip.contains("grandma") || lowerQuip.contains("smiled")) setGoblinExpression("smile");
            else setGoblinExpression("smug"); // Default

            println("Selected Quip: " + currentGoblinQuip);


            if (player.isFrozen() || player.isAttackDisabled()) {
                addToActionLog("Player is " + (player.isFrozen() ? "frozen" : "disabled") + "!");
                setGoblinExpression("laugh"); // Example trigger
                playerPlayedCard = null;
                playerDidAttackLastTurn = false;
                phaseTimer = now;
                phase = PHASE_ENEMY_ACTION;
                return;
            }
            phaseTimer = now;
        }
      } else {
          phase = PHASE_ENEMY_ACTION;
          phaseTimer = 0;
      }
      break;
    case PHASE_ENEMY_ACTION:
      if (!playerTurn) {
          if (phaseTimer == 0) {
            enemy.startTurnStatusUpdate();
            if (enemy.canRegenMana()) {
                enemy.mana = min(PLAYER_MAX_MANA, enemy.mana + 1);
                println(enemy.name + " regenerated 1 Mana. Current Mana: " + enemy.mana);
            } else {
                 println(enemy.name + " mana regeneration skipped.");
            }
            enemy.endTurnManaStatusUpdate();
            addToActionLog(enemy.name + "'s turn to act!");
            opponentIsSmilingThisTurn = (random(1) > 0.5);


            if (enemy.isFrozen() || enemy.isAttackDisabled()) {
              addToActionLog(enemy.name + " is " + (enemy.isFrozen() ? "frozen" : "disabled") + "!");
              setGoblinExpression("angry"); // Example trigger
              enemyPlayedCard = null;
              enemyDidAttackLastTurn = false;
            } else {
              enemyTurnAI();
            }
            phaseTimer = now;
            phase = PHASE_REVEAL_ANIMATE_CARDS;
            return;
          }
      } else {
           phase = PHASE_REVEAL_ANIMATE_CARDS;
           phaseTimer = 0;
      }
      break;
    case PHASE_REVEAL_ANIMATE_CARDS:
      boolean playerAnimDone = playerPlayedCard == null || dist(playerCardX, playerCardY, playerTargetX, playerTargetY) < ANIM_STOP;
      boolean enemyAnimDone = enemyPlayedCard == null || dist(enemyCardX, enemyCardY, enemyTargetX, enemyTargetY) < ANIM_STOP;

      if (phaseTimer == 0) phaseTimer = now;
      if (now >= phaseTimer + 500 && playerAnimDone && enemyAnimDone) {
          if (playerPlayedCard != null) { playerCardX = playerTargetX;
          playerCardY = playerTargetY; }
          if (enemyPlayedCard != null) { enemyCardX = enemyTargetX;
          enemyCardY = enemyTargetY; }
          resolutionStart = 0;
          phase = PHASE_RESOLUTION_PAUSE;
          phaseTimer = 0;
      }
      break;
    case PHASE_RESOLUTION_PAUSE:
      if (resolutionStart == 0) resolutionStart = now;
      if (now - resolutionStart >= PRE_RESOLUTION_DELAY_MS) {
        resolutionStart = 0;
        phase = PHASE_APPLY_EFFECTS;
      }
      break;

    case PHASE_APPLY_EFFECTS:
      String effectResult1 = "";
      String effectResult2 = "";

      Card firstToResolve = null;
      Card secondToResolve = null;
      Object firstSrc = null, firstTgt = null;
      Object secondSrc = null, secondTgt = null;

      boolean playerHasCard = playerPlayedCard != null;
      boolean enemyHasCard = enemyPlayedCard != null;
      if (playerHasCard && enemyHasCard) {
          // Compare Initiative
          if (playerPlayedCard.initiative >= enemyPlayedCard.initiative) {
              firstToResolve = playerPlayedCard;
              firstSrc = player; firstTgt = enemy;
              secondToResolve = enemyPlayedCard; secondSrc = enemy; secondTgt = player;
          } else {
              firstToResolve = enemyPlayedCard;
              firstSrc = enemy; firstTgt = player;
              secondToResolve = playerPlayedCard; secondSrc = player; secondTgt = enemy;
          }
      } else if (playerHasCard) {
          firstToResolve = playerPlayedCard;
          firstSrc = player; firstTgt = enemy;
      } else if (enemyHasCard) {
          firstToResolve = enemyPlayedCard;
          firstSrc = enemy; firstTgt = player;
      }

      if (firstToResolve != null) {
          applyCard(firstToResolve, firstSrc, firstTgt);
          effectResult1 = currentActionLogLine;
      }

      // Check for game end *after* first effect resolves
      if ((player != null && player.hp <= 0) || (enemy != null && enemy.hp <=0)) {
          if (!effectResult1.isEmpty()) setBattleAnnouncement(effectResult1);
          // Don't resolve second card if game ended
      } else if (secondToResolve != null) {
          applyCard(secondToResolve, secondSrc, secondTgt);
          effectResult2 = currentActionLogLine;
          // Combine announcements if both exist
          String combinedAnnouncement = "";
          if (!effectResult1.isEmpty() && !effectResult2.isEmpty()) {
              combinedAnnouncement = effectResult1 + "\n" + effectResult2;
          } else if (!effectResult1.isEmpty()) {
              combinedAnnouncement = effectResult1;
          } else {
              combinedAnnouncement = effectResult2;
          }
          setBattleAnnouncement(combinedAnnouncement);

      } else if (!effectResult1.isEmpty()) {
          setBattleAnnouncement(effectResult1); // Show first result if no second card
      }

      // Handle case where no cards were played (both passed)
      if (playerPlayedCard == null && enemyPlayedCard == null && firstToResolve == null && secondToResolve == null) {
         String passMsg = "";
         if (playerTurn) passMsg = "You passed. " + (enemy != null ? enemy.name : "Enemy") + " also passed. Round ends.";
         else passMsg = (enemy != null ? enemy.name : "Enemy") + " passed. You also passed. Round ends.";
         addToActionLog(passMsg);
      }


      fadeStart = now;
      phase = PHASE_END_ROUND_FADE;
      break;
    case PHASE_END_ROUND_FADE:
      float t = constrain((now - fadeStart) / (float)FADE_DURATION, 0, 1);
      playerAlpha = enemyAlpha = lerp(255, 0, t);

      if (t >= 1) {
        playerAlpha = enemyAlpha = 255;
        if (playerPlayedCard != null && player != null) {
            playerDiscardPile.add(playerPlayedCard);
        }
        if (enemyPlayedCard != null && enemy != null) {
            enemy.discardPile.add(enemyPlayedCard);
        }

        playerDidAttackLastTurn = (playerPlayedCard != null && (playerPlayedCard.damage > 0 || (playerPlayedCard.rulesText != null && !playerPlayedCard.rulesText.toLowerCase().contains("heal")) ) );
        enemyDidAttackLastTurn = (enemyPlayedCard != null && (enemyPlayedCard.damage > 0 || (enemyPlayedCard.rulesText != null && !enemyPlayedCard.rulesText.toLowerCase().contains("heal")) ) );


        playerPlayedCard = null;
        enemyPlayedCard = null;

        playerTurn = !playerTurn;
        phaseTimer = 0;
        phase = PHASE_PLAYER_ACTION;
      }
      break;
  }
}


void applyCard(Card c, Object src, Object tgt){
  if(c == null || src == null || tgt == null) return;
  Player sourcePlayer = null;
  Enemy sourceEnemy = null;
  Player targetPlayer = null;
  Enemy targetEnemy = null;

  if(src instanceof Player) sourcePlayer = (Player)src;
  else if(src instanceof Enemy) sourceEnemy = (Enemy)src;

  if(tgt instanceof Player) targetPlayer = (Player)tgt;
  else if(tgt instanceof Enemy) targetEnemy = (Enemy)tgt;

  String sourceNameDisplay = (sourcePlayer != null ? "Your" : (sourceEnemy != null ? sourceEnemy.name + "'s" : "Unknown"));
  String cardEffectLog = sourceNameDisplay + " " + c.name;


  if (c.name.equals("Pyrelash Vortex")) {
      int dmgToTarget = 4;
      int dmgToSelf = 1;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmgToTarget);
      cardEffectLog += " hits " + targetEnemy.name + " for " + dmgToTarget;
      }
      if (targetPlayer != null) { targetPlayer.takeDamage(dmgToTarget);
      cardEffectLog += " hits Player for " + dmgToTarget; }
      if (sourcePlayer != null) { sourcePlayer.takeDamage(dmgToSelf);
      cardEffectLog += " and self for " + dmgToSelf; }
      if (sourceEnemy != null) { sourceEnemy.takeDamage(dmgToSelf);
      cardEffectLog += " and self for " + dmgToSelf; }
      flashRed = true;
  } else if (c.name.equals("Arctic Descent")) {
      int dmg = 3;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmg); targetEnemy.applyStatus("freeze", 1, 0); cardEffectLog += " deals " + dmg + " to " + targetEnemy.name + " and freezes.";}
      if (targetPlayer != null) { targetPlayer.takeDamage(dmg);
      targetPlayer.applyStatus("freeze", 1, 0); cardEffectLog += " deals " + dmg + " to Player and freezes.";}
      flashRed = true;
  } else if (c.name.equals("Dustline Hunt")) {
      int damage = 4;
      boolean targetWasInactive = false;
      if (targetPlayer != null && !playerDidAttackLastTurn && src == enemy) targetWasInactive = true;
      if (targetEnemy != null && !enemyDidAttackLastTurn && src == player) targetWasInactive = true;

      if(targetWasInactive) damage += 2;
      if (targetEnemy != null) {targetEnemy.takeDamage(damage); cardEffectLog += " hits " + targetEnemy.name + " for " + damage;}
      if (targetPlayer != null) {targetPlayer.takeDamage(damage);
      cardEffectLog += " hits Player for " + damage;}
      if(targetWasInactive) cardEffectLog += " (bonus for inactivity!)";
      flashRed = true;
  } else if (c.name.equals("Lunate Shatter")) {
      int damage = 3;
      String extraEffect = "";
      if (isNewMoon) {
          damage += 2;
          if (targetEnemy != null) targetEnemy.applyStatus("healDisabled", 1, 0);
          if (targetPlayer != null) targetPlayer.applyStatus("healDisabled", 1, 0);
          extraEffect = " + New Moon bonus & heal disable!";
      }
      if (targetEnemy != null) {targetEnemy.takeDamage(damage);
      cardEffectLog += " hits " + targetEnemy.name + " for " + damage + extraEffect;}
      if (targetPlayer != null) {targetPlayer.takeDamage(damage);
      cardEffectLog += " hits Player for " + damage + extraEffect;}
      flashRed = true;
  } else if (c.name.equals("Sugarveil Mirage")) {
      int damage = 2;
      if (opponentIsSmilingThisTurn) {
        damage += 1;
        cardEffectLog += " (opponent smiled! +1 bonus)";
      }
      if (targetEnemy != null) {targetEnemy.takeDamage(damage);
      cardEffectLog += " deals " + damage + " to " + targetEnemy.name;}
      if (targetPlayer != null) {targetPlayer.takeDamage(damage);
      cardEffectLog += " deals " + damage + " to Player";}
      flashRed = true;
  } else if (c.name.equals("Iron Requiem Strike")) {
      int dmg = 2;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmg); targetEnemy.applyStatus("attackDisabled", 1, 0); cardEffectLog += " deals " + dmg + " and disables " + targetEnemy.name + "'s attack.";}
      if (targetPlayer != null) { targetPlayer.takeDamage(dmg);
      targetPlayer.applyStatus("attackDisabled", 1, 0); cardEffectLog += " deals " + dmg + " and disables Player's attack.";}
      flashRed = true;
  } else if (c.name.equals("Ground Burst Mirage")) {
      int dmg = 3; int heal = 1;
      if (targetEnemy != null) {targetEnemy.takeDamage(dmg); cardEffectLog += " hits " + targetEnemy.name + " for " + dmg;}
      if (targetPlayer != null) {targetPlayer.takeDamage(dmg);
      cardEffectLog += " hits Player for " + dmg;}
      if (sourcePlayer != null) {sourcePlayer.heal(heal);
      cardEffectLog += " & You heal " + heal;}
      if (sourceEnemy != null) {sourceEnemy.heal(heal);
      cardEffectLog += " & " + sourceEnemy.name + " heals " + heal;}
      flashRed = true;
  } else if (c.name.equals("Void Spell Unleashed")) {
      int dmg = 3;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmg); targetEnemy.drainMana(); cardEffectLog += " deals " + dmg + " to " + targetEnemy.name + " and drains mana.";}
      if (targetPlayer != null) { targetPlayer.takeDamage(dmg);
      targetPlayer.drainMana(); cardEffectLog += " deals " + dmg + " to Player and drains mana.";}
      flashRed = true;
  } else if (c.name.equals("Nullivelle's Silent")) {
      int damage = 5;
      boolean fullHPBonus = false;
      if (targetEnemy != null && targetEnemy.hp == getEnemyHP()) fullHPBonus = true;
      if (targetPlayer != null && targetPlayer.hp == PLAYER_MAX_HP) fullHPBonus = true;
      if(fullHPBonus) damage+=1;
      if (targetEnemy != null) {targetEnemy.takeDamage(damage);
      cardEffectLog += " strikes " + targetEnemy.name + " for " + damage + (fullHPBonus ? " (Full HP Bonus!)" : "");}
      if (targetPlayer != null) {targetPlayer.takeDamage(damage);
      cardEffectLog += " strikes Player for " + damage + (fullHPBonus ? " (Full HP Bonus!)" : "");}
      flashRed = true;
  } else if (c.name.equals("Woundcycle")) {
      int dmg = 3;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmg);
      targetEnemy.applyStatus("skipManaRegen", 1, 0); cardEffectLog += " deals " + dmg + " and skips " + targetEnemy.name + "'s mana regen.";}
      if (targetPlayer != null) { targetPlayer.takeDamage(dmg);
      targetPlayer.applyStatus("skipManaRegen", 1, 0); cardEffectLog += " deals " + dmg + " and skips Player's mana regen.";}
      flashRed = true;
  } else if (c.name.equals("Shuffle Surge")) {
      if (sourcePlayer != null) playerShuffleCount++;
      if (sourceEnemy != null) enemyShuffleCount++;
      cardEffectLog = sourceNameDisplay + " gains a Shuffle Charge!";
      flashRed = false;
      updateShuffleButton();
  } else if (c.name.equals("Paddle of Pain")) {
      int dmg = 2;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmg); targetEnemy.applyStatus("shamed", 1, 0); cardEffectLog += " deals " + dmg + " to " + targetEnemy.name + " and shames them.";}
      if (targetPlayer != null) { targetPlayer.takeDamage(dmg);
      targetPlayer.applyStatus("shamed", 1, 0); cardEffectLog += " deals " + dmg + " to Player and shames them.";}
      flashRed = true;
  } else if (c.name.equals("Selvynne Overdrive Open-Cab")) {
      int dmg = 5;
      if (targetEnemy != null) {targetEnemy.takeDamage(dmg); cardEffectLog += " blasts " + targetEnemy.name + " for " + dmg;}
      if (targetPlayer != null) {targetPlayer.takeDamage(dmg);
      cardEffectLog += " blasts Player for " + dmg;}
      flashRed = true;
  } else if (c.name.equals("Selyras Fiery Descent")) {
      int dmg = 2;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmg); targetEnemy.applyStatus("burn", 1, 1); cardEffectLog += " deals " + dmg + " to " + targetEnemy.name + " and burns for 1.";}
      if (targetPlayer != null) { targetPlayer.takeDamage(dmg);
      targetPlayer.applyStatus("burn", 1, 1); cardEffectLog += " deals " + dmg + " to Player and burns for 1.";}
      flashRed = true;
  } else if (c.name.equals("Taenya Chainsaw")) {
      int dmg = 2;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmg); targetEnemy.applyStatus("attackDisabled", 1, 0); cardEffectLog += " deals " + dmg + " and disables " + targetEnemy.name + "'s attack.";}
      if (targetPlayer != null) { targetPlayer.takeDamage(dmg);
      targetPlayer.applyStatus("attackDisabled", 1, 0); cardEffectLog += " deals " + dmg + " and disables Player's attack.";}
      flashRed = true;
  } else if (c.name.equals("Thandors Wild Ride")) {
      int dmg = 4;
      if (targetEnemy != null) { targetEnemy.takeDamage(dmg); targetEnemy.applyStatus("attackDisabled", 1, 0); targetEnemy.applyStatus("skipManaRegen", 1, 0);
      cardEffectLog += " deals " + dmg + ", disables attack and mana regen for " + targetEnemy.name + ".";}
      if (targetPlayer != null) { targetPlayer.takeDamage(dmg);
      targetPlayer.applyStatus("attackDisabled", 1, 0); targetPlayer.applyStatus("skipManaRegen", 1, 0); cardEffectLog += " deals " + dmg + ", disables attack and mana regen for Player.";}
      flashRed = true;
  } else if (c.name.equals("Vexalia Fire Feast") || c.name.equals("Xelyth Fiery Feast")) {
      int damageAmount = 3;
      if (targetEnemy != null) { targetEnemy.takeDamage(damageAmount); targetEnemy.applyStatus("burn", 2, 1); cardEffectLog += " deals " + damageAmount + " to " + targetEnemy.name + " and burns for 2 turns (1 dmg/turn).";}
      if (targetPlayer != null) { targetPlayer.takeDamage(damageAmount);
      targetPlayer.applyStatus("burn", 2, 1); cardEffectLog += " deals " + damageAmount + " to Player and burns for 2 turns (1 dmg/turn).";}
      flashRed = true;
  }
  else if (c.damage > 0){ // Generic damage card
    if(targetPlayer != null) {targetPlayer.takeDamage(c.damage);
    cardEffectLog += " deals " + c.damage + " damage to Player.";}
    if(targetEnemy != null) {targetEnemy.takeDamage(c.damage);
    cardEffectLog += " deals " + c.damage + " damage to " + targetEnemy.name + ".";}
    flashRed = true;
  } else if (c.damage < 0) { // Generic heal card
    int healingAmount = -c.damage;
    if(sourcePlayer != null && sourcePlayer.canHeal()) {sourcePlayer.heal(healingAmount); cardEffectLog = sourceNameDisplay + " " + c.name + " heals you for " + healingAmount + ".";}
    else if(sourceEnemy != null && sourceEnemy.canHeal()) {sourceEnemy.heal(healingAmount);
    cardEffectLog = sourceNameDisplay + " " + c.name + " heals " + sourceEnemy.name + " for " + healingAmount + ".";}
    else { cardEffectLog = sourceNameDisplay + " " + c.name + " healing blocked!";}
    flashRed = false;
  } else {
      // For cards with no damage/healing, use rules text
       cardEffectLog = sourceNameDisplay + " " + c.name + " effect: " + c.rulesText.replace("\n", " ");
  }
  currentActionLogLine = cardEffectLog; // Update single line display if needed
  flashTimer = (src instanceof Player) ? FLASH_P_FR : FLASH_E_FR; // Trigger flash based on source
}


void enemyTurnAI(){
  long now = millis();
  if (enemy == null) return;
  if(enemy.enemyHand.isEmpty() && enemy.enemyDeck.isEmpty() && enemyShuffleCount > 0){
    enemyShuffleCount--;
    enemy.enemyDeck.addAll(enemy.discardPile);
    enemy.discardPile.clear();
    shuffleDeck(enemy.enemyDeck);

    enemy.enemyHand.clear();
    for (int i = 0; i < ENEMY_STARTING_CARDS && !enemy.enemyDeck.isEmpty() && enemy.enemyHand.size() < HAND_SIZE_LIMIT; i++) {
        enemy.enemyHand.add(enemy.enemyDeck.remove(0));
    }
    addToActionLog(enemy.name + " shuffled and drew " + enemy.enemyHand.size() + " cards.");
  }

  if(enemy.enemyHand.isEmpty()){
    addToActionLog(enemy.name + " has no cards and passes.");
    enemyPlayedCard = null;
    enemyDidAttackLastTurn = false;
    return;
  }

  Card choice = null;
  ArrayList<Card> playableCards = new ArrayList<Card>();
  for(Card c : enemy.enemyHand) {
      if(c != null && c.manaCost <= enemy.mana ) {
          playableCards.add(c);
      }
  }

  if(playableCards.isEmpty()){
    addToActionLog(enemy.name + " cannot afford any card and passes.");
    enemyPlayedCard = null;
    enemyDidAttackLastTurn = false;
    return;
  }

  choice = playableCards.get( (int)random(playableCards.size()) );


  enemy.enemyHand.remove(choice);
  enemyPlayedCard = choice;
  enemy.mana -= choice.manaCost;
  enemyCardX = width - (battleX + battleW * ENEMY_TX_RATIO - (Card.BASE_WIDTH * PLAYED_CARD_SCALE) / 2) - Card.BASE_WIDTH * PLAYED_CARD_SCALE;
  enemyCardY = TOOLBAR_H + 50;
  enemyAlpha = 255;
  enemyDidAttackLastTurn = true;
  addToActionLog(enemy.name + " plays " + choice.name + "...");
}


void endBattle(boolean playerWon){
    if(currentGameState != GameState.GAME_OVER && currentGameState != GameState.LOOT_SCREEN){
        if(playerWon){
            lootPrompt = true;
            lootBtn.enabled = true;
            addToActionLog("Enemy Defeated!");
            setGoblinExpression("shocked"); // Example trigger
        } else {
            gameOver = true;
            currentGameState = GameState.GAME_OVER;
            addToActionLog("You were defeated!");
            setGoblinExpression("laugh"); // Example trigger
            if(fatalityAnim != null) {
               fatalityAnim.play();
               fatalityAnim.jump(0);
            }
        }
    }
}


void initPlayerDeck(){
  playerDeck.clear();
  playerDiscardPile.clear();
  hand.clear();
  // Card definitions using initiative instead of speed
  playerDeck.add(new Card("Pyrelash Vortex",      4, 2, "PyrelashVortex",       "Deal 4 damage to target.\nDeal 1 damage to yourself.", 2, "Fire"));
  playerDeck.add(new Card("Arctic Descent",       3, 4, "ArcticDescent",        "Deal 3 damage and freeze enemy for 1 turn.", 1, "Ice"));
  playerDeck.add(new Card("Dustline Hunt",        4, 5, "DustlineHunt",         "Deal 4 damage.\nBonus +2 damage if target didn't attack last turn.", 2, "Earth"));
  playerDeck.add(new Card("Lunate Shatter",       3, 5, "LunateShatter",        "Deal 3 damage. If under New Moon, deal 2 extra damage and disable healing for 1 turn.", 3, "Void"));
  playerDeck.add(new Card("Sugarveil Mirage",     2, 4, "SugarveilMirage",      "Deal 2 damage. If opponent is smiling (IRL), deal +1 damage.", 1, "Illusion"));
  playerDeck.add(new Card("Iron Requiem Strike",  2, 5, "IronRequiemStrike",    "Deal 2 damage and disable opponent's next attack.", 2, "Metal"));
  playerDeck.add(new Card("Ground Burst Mirage",  3, 4, "GroundBrustMirage",    "Deal 3 damage, gain 1 HP.", 2, "Earth"));
  playerDeck.add(new Card("Void Spell Unleashed", 3, 0, "VoidSpellUnleashed",   "Deal 3 damage to target and drain all their Mana.", 4, "Void"));
  playerDeck.add(new Card("Nullivelle's Silent",  5, 6, "NullivellesSilent",    "Deal 5 damage. If opponent has full HP, deal +1 damage.", 3, "Void"));
  playerDeck.add(new Card("Woundcycle",           3, 4, "Woundcycle",           "Deal 3 damage.\nTarget skips Mana regeneration next turn.", 2, "Underworld"));
  playerDeck.add(new Card("Shuffle Surge",        0, 4, "Shuffle",              "Gain +1 Shuffle charge.", 5, "Effect"));
  playerDeck.add(new Card("Paddle of Pain",       2, 4, "PaddleOfPain",         "Deal 2 damage and apply Shamed (Damage reduced next turn) for 1 turn.", 1, "Physical"));
  playerDeck.add(new Card("Selvynne Overdrive Open-Cab", 5, 5, "SelvynneOverdriveOpenCab", "Deal 5 damage.", 3, "Tech"));
  playerDeck.add(new Card("Selyras Fiery Descent",2, 5, "SelyrasFieryDescent",  "Deal 2 damage. Target loses 1 HP at the start of their next turn for 1 turn.", 2, "Fire"));
  playerDeck.add(new Card("Taenya Chainsaw",      2, 4, "TaenyaChainsaw",       "Deal 2 damage, prevent enemy actions next turn.", 2, "Tech"));
  playerDeck.add(new Card("Thandors Wild Ride",   4, 3, "ThandorsWildRide",     "Deal 4 damage and skip opponent's next action.", 3, "Beast"));
  playerDeck.add(new Card("Vexalia Fire Feast",   3, 4, "VexaliaFireFeast",     "Deal 3 damage, burn 1 HP per turn for 2 turns.", 2, "Fire"));
  playerDeck.add(new Card("Xelyth Fiery Feast",   3, 1, "XelythFieryFeast",     "Deal 3 damage, burn 1 HP per turn for 2 turns.", 2, "Fire"));
  for (int i = 0; i < 5; i++) playerDeck.add(new Card("Arctic Descent",       3, 4, "ArcticDescent",        "Deal 3 damage and freeze enemy for 1 turn.", 1, "Ice"));
  for (int i = 0; i < 5; i++) playerDeck.add(new Card("Ground Burst Mirage",  3, 4, "GroundBrustMirage",    "Deal 3 damage, gain 1 HP.", 2, "Earth"));
  for (int i = 0; i < 3; i++) playerDeck.add(new Card("Shuffle Surge",        0, 4, "Shuffle",              "Gain +1 Shuffle charge.", 5, "Effect"));
  for (int i = 0; i < 4; i++) playerDeck.add(new Card("Woundcycle",           3, 4, "Woundcycle",           "Deal 3 damage.\nTarget skips Mana regeneration next turn.", 2, "Underworld"));
  for (int i = 0; i < 2; i++) playerDeck.add(new Card("Vexalia Fire Feast",   3, 4, "VexaliaFireFeast",     "Deal 3 damage, burn 1 HP per turn for 2 turns.", 2, "Fire"));
}

void drawHand(){
  int cardsToDraw = PLAYER_STARTING_CARDS - hand.size();
  cardsToDraw = max(0, cardsToDraw);

  for(int i = 0; i < cardsToDraw && hand.size() < HAND_SIZE_LIMIT; i++){
    if(playerDeck.isEmpty()){
      println("[WARN] Player deck is empty. Cannot draw more cards.");
      break;
    }
    hand.add(playerDeck.remove(0));
  }
}

void shuffleDeck(ArrayList<Card> d){
    if(d != null) {
        Collections.shuffle(d);
    } else {
        println("[WARN] Attempted to shuffle a null deck.");
    }
}

int getEnemyHP(){
    return (difficulty == 0) ? ENEMY_MAX_HP_BAS - 10 :
           (difficulty == 2) ? ENEMY_MAX_HP_BAS + 15 :
                               ENEMY_MAX_HP_BAS;
}

int getEnemyShuffles(){
    return 1;
}

void applyDifficulty(){
  if (enemy != null) {
     enemy.hp = getEnemyHP();
     enemy.enemyDeck.clear();
     enemy.enemyHand.clear();
     enemy.discardPile.clear();
     enemy.initializeEnemyDeck();
     shuffleDeck(enemy.enemyDeck);
     enemy.drawStartingHand();
     enemyShuffleCount = getEnemyShuffles();
  }

  addToActionLog("Difficulty updated.");
  println("Difficulty set to " + difficulty + (enemy != null ? (". Enemy HP: " + enemy.hp + ", Enemy Shuffles: " + enemyShuffleCount) : ""));
}
