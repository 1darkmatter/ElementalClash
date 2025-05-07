/* Panels.pde
 * Elemental Clash – menu, settings, and help panels
 * Uses drawBackground() from UIHelpers to keep background.png visible.
 */

final color PANEL_TINT_MENU     = color(0, 0, 0, 190);
final color PANEL_TINT_SETTINGS = color(0, 0, 0, 200);
final color PANEL_TINT_HELP     = color(0, 0, 0, 200);

final color PANEL_TITLE_COLOR   = #FFFFFF;
final color HELP_SUBTITLE_COLOR = #FFFF99;
final color HELP_KEY_TERM_COLOR = #99FFFF; // Consider using this for emphasis if needed
final float TITLE_SIZE_MENU     = 40;
final float TITLE_SIZE_SETTINGS = 32;
final float TITLE_SIZE_HELP     = 28;
final float HELP_TEXT_SIZE      = 14;
final float HELP_SUBTITLE_SIZE  = 18;
final int   PANEL_TITLE_Y = 90;
final float HELP_LINE_SPACING = HELP_TEXT_SIZE * 1.4f; // Increased slightly
final float HELP_SECTION_SPACING = HELP_LINE_SPACING * 0.8f; // Space after sections


void drawMenuPanel() {
  drawBackground();
  pushStyle();
  fill(PANEL_TINT_MENU);
  noStroke();
  rect(0, 0, width, height);
  popStyle();
  if (titleFont != null) textFont(titleFont); else textFont(defaultSystemFont);
  fill(PANEL_TITLE_COLOR);
  textSize(TITLE_SIZE_MENU);
  textAlign(CENTER, CENTER);
  text("GAME MENU", width / 2, PANEL_TITLE_Y);

  textFont(defaultSystemFont);
  if (mReturn != null) mReturn.display();
  if (mSettings != null) mSettings.display();
  if (mHelp != null) mHelp.display();
  if (btnSave != null) btnSave.display();
  if (btnLoad != null) btnLoad.display();
  if (mQuit != null) mQuit.display();
}

void drawSettingsPanel() {
  drawBackground();
  pushStyle();
  fill(PANEL_TINT_SETTINGS);
  noStroke();
  rect(0, 0, width, height);
  popStyle();

  if (titleFont != null) textFont(titleFont); else textFont(defaultSystemFont);
  fill(PANEL_TITLE_COLOR);
  textSize(TITLE_SIZE_SETTINGS);
  textAlign(CENTER, CENTER);
  text("DIFFICULTY SETTINGS", width / 2, PANEL_TITLE_Y);

  textFont(defaultSystemFont);
  if (btnEasy != null) btnEasy.display();
  if (btnMedium != null) btnMedium.display();
  if (btnHard != null) btnHard.display();


  pushStyle();
  stroke(#FFFF00);
  strokeWeight(4);
  noFill();

  Button sel = null;
  if (difficulty == 0 && btnEasy != null) sel = btnEasy;
  else if (difficulty == 1 && btnMedium != null) sel = btnMedium;
  else if (difficulty == 2 && btnHard != null) sel = btnHard;
  if (sel != null) {
      rect(sel.x - 3, sel.y - 3,
        sel.w + 6, sel.h + 6, 8);
  }
  popStyle();

  if (btnBackSet != null) btnBackSet.display();
}

void drawHelpPanel() {
  drawBackground();
  pushStyle();
  fill(PANEL_TINT_HELP);
  noStroke();
  rect(0, 0, width, height);
  popStyle();

  if (titleFont != null) textFont(titleFont); else textFont(defaultSystemFont);
  fill(PANEL_TITLE_COLOR);
  textSize(TITLE_SIZE_HELP);
  textAlign(CENTER, CENTER);
  text("HOW TO PLAY ELEMENTAL CLASH", width / 2, PANEL_TITLE_Y);

  // Centered two-column layout - Narrower
  float totalContentWidth = width * 0.7f; // Reduced total width further
  float columnGap = 25;
  float columnWidth = (totalContentWidth - columnGap) / 2;
  float blockStartX = (width - totalContentWidth) / 2; // Recalculated start X for centering
  float xLeft = blockStartX;
  float xRight = blockStartX + columnWidth + columnGap;
  float currentYLeft = PANEL_TITLE_Y + 50;
  float currentYRight = PANEL_TITLE_Y + 50;
  float bottomMargin = 100; // Space for the return button

  String[] sections = {
    "THE GOAL:", // L - 0
    "Defeat the insidious Green Goblin by reducing his HP to 0 before your own HP runs out or you deplete your deck!", // L - 1

    "CORE MECHANICS:", // L - 2
    "• Playing Cards: Click a card in your hand. Cards cost MANA (blue bar). Effects vary: damage, healing, status effects, etc.", // L - 3
    "• Conditional Effects: Some cards gain bonuses based on game state (e.g., New Moon, target's HP, recent actions). Read card text carefully!", // L - 4
    "• Mana Regeneration: Gain +1 Mana at the start of your turn, up to " + PLAYER_MAX_MANA + ". Some effects can block this!", // L - 5
    "• Card Initiative: When both players play cards, the card with higher INITIATIVE resolves first. Higher Initiative means the card acts first! Ties often favor the player.", // L - 6 (Explanation added)

    "PLAYER ACTIONS:", // L - 7
    "• Bypass Turn: Click 'Bypass >>' to end your turn. You'll still regenerate Mana if able.", // L - 8
    "• Shuffle Deck: Click '<< Shuffle (n)' to use a Shuffle charge. Returns hand, shuffles deck/discard, draws " + PLAYER_STARTING_CARDS + ". 'Shuffle Surge' adds charges!", // L - 9

    "STATUS EFFECTS:", // R - 10
    "• Freeze: Target cannot act.", // R - 11
    "• Burn: Target takes damage at start of turn.", // R - 12
    "• Shamed: Target deals reduced damage.", // R - 13
    "• Attack Disabled: Target cannot play attacks.", // R - 14
    "• Heal Disabled: Target cannot be healed.", // R - 15
    "• Mana Regen Skip: Target skips mana gain.", // R - 16

    "USER INTERFACE:", // R - 17
    "• Card Zoom: Hover card in hand for details (yellow border).", // R - 18
    "• Action Log: Left panel shows history (scrollable).", // R - 19
    "• Toolbar: Menu, turn status, Escape (concede).", // R - 20
    "• Win/Loss: Win -> click 'Seize Loot'. Lose -> Game Over.", // R - 21

    "SAVING & LOADING:", // R - 22
    "Use the Game Menu to Save or Load progress anytime." // R - 23
  };

  // Adjusted split point: Index 10 ("STATUS EFFECTS:") starts the right column.
  int midpointIndex = 10;

  // Draw Left Column
  for (int i = 0; i < midpointIndex; i++) {
      currentYLeft = drawHelpSection(sections[i], xLeft, currentYLeft, columnWidth, bottomMargin);
      if (currentYLeft > height - bottomMargin) break;
  }

  // Draw Right Column
  for (int i = midpointIndex; i < sections.length; i++) {
       currentYRight = drawHelpSection(sections[i], xRight, currentYRight, columnWidth, bottomMargin);
       if (currentYRight > height - bottomMargin) break;
  }


  if (btnBackHelp != null) btnBackHelp.display();
}

// Helper function to draw a single section in the help panel
float drawHelpSection(String sectionText, float x, float y, float w, float bottomMargin) {
    if (y > height - bottomMargin) return y; // Prevent drawing too low

    float currentY = y;

    if (sectionText.endsWith(":")) { // Title/Subtitle
      textFont(titleFont); // Use bold title font
      textSize(HELP_SUBTITLE_SIZE);
      fill(HELP_SUBTITLE_COLOR);
      textAlign(LEFT, TOP);
      currentY += HELP_SECTION_SPACING * 0.8f; // Space before subtitle
      text(sectionText, x, currentY, w, height - currentY - bottomMargin);
      currentY += HELP_SUBTITLE_SIZE + HELP_SECTION_SPACING * 0.3f; // Space after subtitle
    } else { // Detail text
      textFont(defaultSystemFont);
      textSize(HELP_TEXT_SIZE);
      fill(PANEL_TITLE_COLOR);
      textAlign(LEFT, TOP);
      textLeading(HELP_LINE_SPACING); // Apply line spacing for details

      // Calculate approximate height needed by using text() bounds
      float textH = 0;
      if (!sectionText.isEmpty()) {
           float singleLineHeight = textAscent() + textDescent();
           // Estimate lines based on width AND newlines within the text
           int manualNewlines = sectionText.split("\n").length -1;
           float approxWidthLines = ceil(textWidth(sectionText.replace("\n"," ")) / w); // Estimate based on width if all one line
           int lines = max(1, max(int(approxWidthLines), manualNewlines + 1)); // Take max of width estimate or manual breaks
           textH = max(singleLineHeight, lines * HELP_LINE_SPACING); // Use calculated lines
           // Reduce spacing between lines slightly to tighten paragraphs
           textH -= (lines > 1) ? (lines-1) * (HELP_LINE_SPACING - (textAscent()+textDescent()) )*0.3f : 0;
      }

       if (currentY + textH > height - bottomMargin) return height; // Stop if this section overflows

      // Draw the text within the bounds
      text(sectionText, x + 5, currentY, w - 10, height - currentY - bottomMargin);
      currentY += textH + HELP_SECTION_SPACING; // Move Y down after drawing the block
    }
    return currentY;
}


void drawGameOver() {
  drawBackground();
  pushStyle();
  fill(0, 225);
  noStroke();
  rect(0, 0, width, height);

  if (fatalityAnim != null) {
    imageMode(CENTER);
    image(fatalityAnim, width/2, height/2 - 110, 420, 266);
    imageMode(CORNER);
  }

  if (titleFont != null) textFont(titleFont); else textFont(defaultSystemFont);
  fill(#FF3333);
  textSize(58);
  textAlign(CENTER, CENTER);
  text("GAME OVER", width/2, height/2 + 60);

  textFont(defaultSystemFont);
  if (tryAgainBtn != null) tryAgainBtn.display();
  if (quitBtn != null) quitBtn.display();
  popStyle();
}

void drawLootScreen() {
  drawBackground();
  pushStyle();
  fill(0, 235);
  noStroke();
  rect(0, 0, width, height);
  if (flawlessAnim != null && flawlessAnim.isPlaying()) {
    imageMode(CENTER);
    image(flawlessAnim, width/2, TOOLBAR_H + (height - TOOLBAR_H) * 0.28f, 420, 266);
    imageMode(CORNER);
  }

  if (lootChestImg != null) {
    imageMode(CENTER);
    float imgY = TOOLBAR_H + (height - TOOLBAR_H) / 2 + 40;
    image(lootChestImg, width/2, imgY, width, height - TOOLBAR_H - 80);
    imageMode(CORNER);
  }

  if (titleFont != null) textFont(titleFont); else textFont(defaultSystemFont);
  fill(COLOR_TEXT_NORMAL);
  textSize(36);
  textAlign(CENTER, CENTER);
  text("LOOT GATHERED\nClick the chest to exit",
    width/2, TOOLBAR_H + 85);

  popStyle();
}
