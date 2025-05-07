/* UIHelpers.pde
 * Elemental Clash – Helper functions for drawing UI elements
 * Contains functions for rendering background, bars, and other UI components.
 */

import gifAnimation.*;
import processing.core.PImage;

final color COLOR_STATUS_PURPLE = color(128, 0, 128); 

void drawBackground() {
  if (backgroundImg != null) {
    image(backgroundImg, 0, TOOLBAR_H, width, height - TOOLBAR_H);
  } else {
    background(COLOR_BG);
  }
}

void drawBar(float x, float y, float w, float h, int val, int max, color barCol) {
  pushStyle();
  noStroke(); 

  fill(35, 35, 35, 230);
  rect(x, y, w, h, 4);
  if (max > 0) { 
    float pw = map(max(0, val), 0, max, 0, w - 4);
    fill(barCol);
    rect(x + 2, y + 2, constrain(pw, 0, w - 4), h - 4, 3);
  } else if (val > 0) { 
       fill(barCol);
       rect(x + 2, y + 2, 2, h - 4, 3);
  }


  fill(255); 
  textSize(11);
  textAlign(CENTER, CENTER);
  text(val + "/" + max, x + w / 2, y + h / 2 + 0.5f);

  popStyle();
}

void drawFlash() {
  if (flashTimer <= 0) return;

  pushStyle(); 
  noStroke();
  fill(flashRed ? color(178, 34, 34, 110) 
                : color(30, 144, 255, 110));
  rect(0, TOOLBAR_H, width, height - TOOLBAR_H);
  flashTimer--; 
  popStyle(); 
}

void drawToolbar() {
  pushStyle();
  fill(COLOR_TOOLBAR); 
  noStroke();
  rect(0, 0, width, TOOLBAR_H);
  if (menuBtn   != null) menuBtn.display();
  if (lootBtn   != null) lootBtn.display();
  if (escapeBtn != null) escapeBtn.display();

  popStyle();
}

void drawTurnIndicator() {
  String cap;
  color col;  

  if (currentGameState == GameState.GAME_RUNNING) {
    boolean playerCanAct = playerTurn && phase == PHASE_PLAYER_ACTION && player != null && !player.isFrozen() && !player.isAttackDisabled();
    boolean enemyCanAct = !playerTurn && phase == PHASE_ENEMY_ACTION && enemy != null && !enemy.isFrozen() && !enemy.isAttackDisabled();
    boolean playerIsDisabled = playerTurn && player != null && (player.isFrozen() || player.isAttackDisabled()) && phase == PHASE_PLAYER_ACTION;
    boolean enemyIsDisabled = !playerTurn && enemy != null && (enemy.isFrozen() || enemy.isAttackDisabled()) && phase == PHASE_ENEMY_ACTION;
    if (playerCanAct) {
      cap = "YOUR TURN";
      col = COLOR_TURN_PLAYER;
    } else if (phase == PHASE_ENEMY_ACTION && enemyCanAct) {
      cap = (enemy != null ? enemy.name.toUpperCase() : "ENEMY") + "'S TURN";
      col = COLOR_TURN_ENEMY;
    } else if (playerIsDisabled) {
      cap = "YOU ARE DISABLED";
      col = color(100, 100, 255);
    } else if (enemyIsDisabled) {
      cap = (enemy != null ? enemy.name.toUpperCase() : "ENEMY") + " IS DISABLED";
      col = color(100, 100, 255);
    } else if (phase == PHASE_REVEAL_ANIMATE_CARDS || phase == PHASE_RESOLUTION_PAUSE || phase == PHASE_APPLY_EFFECTS) {
      cap = "RESOLVING...";
      col = COLOR_STATUS_PURPLE; 
    }
    else {
      cap = "WAITING..."; 
      col = COLOR_STATUS_PURPLE; 
    }
  } else {
    cap = "-";
    col = color(150);
  }

  textSize(14);
  float bw = textWidth(cap) + 24;

  pushStyle(); 
  noStroke();
  fill(0, 150);
  rect(width / 2 - bw / 2, 6, bw, TOOLBAR_H - 12, 4);

  fill(col); 
  textAlign(CENTER, CENTER);
  text(cap, width / 2, TOOLBAR_H / 2 + 1);

  popStyle(); 
}

void drawBattleArea() {
  pushStyle();
  fill(COLOR_BATTLE_AREA); 
  noStroke();
  rect(battleX, battleY, battleW, battleH, 12); 
  popStyle();
}

void drawTopUI() {
  final int F = 13;
  float bw = 260, bh = 140;
  float y0 = TOOLBAR_H + 10;
  float px = 10;
  float ex = width - bw - 10;

  pushStyle();
  PFont uiFont = createFont("Arial", F);
  if (uiFont != null) {
      textFont(uiFont);
  }


  fill(COLOR_UI_BOX_BG, 210);
  stroke(COLOR_UI_BOX_STROKE); 
  strokeWeight(1.2f);
  rect(px, y0, bw, bh, 8); 
  rect(ex, y0, bw, bh, 8);
  noStroke(); 

  fill(COLOR_TEXT_UI);
  textSize(F);

  textAlign(LEFT, TOP);
  float y = y0 + UI_PAD;

  text("PLAYER", px + UI_PAD, y);
  y += F + BAR_SP;
  if (player != null) {
    drawBar(px + UI_PAD, y, 
           bw - 2 * UI_PAD, BAR_H, 
           player.hp, PLAYER_MAX_HP, COLOR_HP_BAR);
  } else {
       drawBar(px + UI_PAD, y,
           bw - 2 * UI_PAD, BAR_H,
           0, PLAYER_MAX_HP, COLOR_HP_BAR);
  }
  y += BAR_H + BAR_SP; 

   if (player != null) {
    drawBar(px + UI_PAD, y, 
           bw - 2 * UI_PAD, BAR_H, 
           player.mana, PLAYER_MAX_MANA, COLOR_MANA_BAR);
  } else {
       drawBar(px + UI_PAD, y,
           bw - 2 * UI_PAD, BAR_H,
           0, PLAYER_MAX_MANA, COLOR_MANA_BAR);
  }
  y += BAR_H + BAR_SP; 

  text("Shuffles: " + playerShuffleCount, px + UI_PAD, y); 
  y += F + 4;
  String playerStatus = "";
  if (player != null) { 
      if (player.isFrozen()) playerStatus += "Frozen (" + player.frozenTurns + ") ";
      if (player.healDisabledTurns > 0) playerStatus += "Heal Block (" + player.healDisabledTurns + ") ";
      if (player.isAttackDisabled()) playerStatus += "Attack Lock (" + player.attackDisabledTurns + ") ";
      if (!player.canRegenMana()) playerStatus += "Mana Lock (" + player.skipManaRegenTurns + ") ";
      if (player.burnTurns > 0) playerStatus += "Burning (" + player.burnAmount + "dmg/" + player.burnTurns + "t) ";
      if (player.isShamed()) playerStatus += "Shamed (" + player.shamedTurns + ") ";
  }


  if (!playerStatus.isEmpty()) {
    fill(#FFD700);
    textSize(F * 0.85f); 
    text("Status: " + playerStatus.trim(), px + UI_PAD, y, bw - 2 * UI_PAD, bh - (y - y0) - UI_PAD);
  }


  textAlign(RIGHT, TOP);
  y = y0 + UI_PAD;

  if (enemy != null) { 
     text(enemy.name.toUpperCase(), ex + bw - UI_PAD, y);
  } else {
     text("ENEMY", ex + bw - UI_PAD, y);
  }
  y += F + BAR_SP;

  if (enemy != null) { 
    drawBar(ex + UI_PAD, y, 
           bw - 2 * UI_PAD, BAR_H, 
           enemy.hp, getEnemyHP(), COLOR_HP_BAR);
  } else {
      drawBar(ex + UI_PAD, y,
           bw - 2 * UI_PAD, BAR_H,
           0, getEnemyHP(), COLOR_HP_BAR);
  }
  y += BAR_H + BAR_SP; 

  if (enemy != null && enemy.enemyHand != null) { 
     text("Hand: " + enemy.enemyHand.size(),
         ex + bw - UI_PAD, y);
  } else {
      text("Hand: 0", ex + bw - UI_PAD, y);
  }
  y += F + 1; 

  text("Shuffles: " + enemyShuffleCount, ex + bw - UI_PAD, y);
  y += F + 4; 

  String enemyStatus = "";
  if (enemy != null) { 
      if (enemy.isFrozen()) enemyStatus += "Frozen (" + enemy.frozenTurns + ") ";
      if (enemy.healDisabledTurns > 0) enemyStatus += "Heal Block (" + enemy.healDisabledTurns + ") ";
      if (enemy.isAttackDisabled()) enemyStatus += "Attack Lock (" + enemy.attackDisabledTurns + ") ";
      if (!enemy.canRegenMana()) enemyStatus += "Mana Lock (" + enemy.skipManaRegenTurns + ") ";
      if (enemy.burnTurns > 0) enemyStatus += "Burning (" + enemy.burnAmount + "dmg/" + enemy.burnTurns + "t) ";
      if (enemy.isShamed()) enemyStatus += "Shamed (" + enemy.shamedTurns + ") ";
   }


  if (!enemyStatus.isEmpty()) {
    fill(#FFD700);
    textSize(F * 0.85f);
    textAlign(RIGHT, TOP);
    text("Status: " + enemyStatus.trim(), ex + UI_PAD, y, bw - 2 * UI_PAD, bh - (y - y0) - UI_PAD);
  }


  popStyle(); 
}

void drawGameScreenDimmed() {
  drawGameScreen();
  pushStyle(); 
  noStroke();
  fill(0, 180); 
  rect(0, 0, width, height);
  popStyle();
}

void drawEnemyHand() {
  if (enemy == null || enemy.enemyHand == null || enemy.enemyHand.isEmpty()) return;

  float s = 0.6f;
  float w = Card.BASE_WIDTH * s;
  float h = Card.BASE_HEIGHT * s; 
  int n = enemy.enemyHand.size();
  if (n == 0) return;

  int spacing = 110;
  float totalW = (n - 1) * spacing + w;
  float startX = width / 2f - totalW / 2f;
  float y = battleY - h - 28;
  PImage back = (cardImages != null) ? cardImages.get("CardBack") : null;

  pushStyle();
  if (back != null) {
    for (int i = 0; i < n; i++) {
      image(back, startX + i * spacing, y, w, h);
    }
  } else {
    fill(120);
    noStroke();
    for (int i = 0; i < n; i++) {
      rect(startX + i * spacing, y, w, h, 4 * s);
    }
  }
  popStyle();
}

void renderPlayedCards() {
  pushStyle();

  float t_anim = millis() * 0.002f;
  float sScale = 1 + 0.04f * sin(t_anim); 
  float sAngle = radians(3) * sin(t_anim);
  if (playerPlayedCard != null && (phase >= PHASE_REVEAL_ANIMATE_CARDS && phase <= PHASE_END_ROUND_FADE)) {
    float currentCardX = playerCardX;
    float currentCardY = playerCardY;
    if (phase == PHASE_REVEAL_ANIMATE_CARDS) {
        currentCardX = lerp(playerCardX, playerTargetX, ANIM_LERP);
        currentCardY = lerp(playerCardY, playerTargetY, ANIM_LERP);
        playerCardX = currentCardX;
        playerCardY = currentCardY;
    } else {
        playerCardX = playerTargetX; 
        playerCardY = playerTargetY;
    }


    float cw = Card.BASE_WIDTH  * PLAYED_CARD_SCALE * sScale;
    float ch = Card.BASE_HEIGHT * PLAYED_CARD_SCALE * sScale;

    pushMatrix();
    translate(playerCardX + cw/2, playerCardY + ch/2);
    rotate(sAngle); 
    playerPlayedCard.displayWithAlpha(-cw/2, -ch/2, PLAYED_CARD_SCALE * sScale, playerAlpha, false);
    popMatrix(); 
  }

  if (enemyPlayedCard != null && (phase >= PHASE_REVEAL_ANIMATE_CARDS && phase <= PHASE_END_ROUND_FADE)) { 
    float currentCardX = enemyCardX;
    float currentCardY = enemyCardY;
     if (phase == PHASE_REVEAL_ANIMATE_CARDS) {
        currentCardX = lerp(enemyCardX, enemyTargetX, ANIM_LERP);
        currentCardY = lerp(enemyCardY, enemyTargetY, ANIM_LERP);
        enemyCardX = currentCardX;
        enemyCardY = currentCardY;
    } else {
        enemyCardX = enemyTargetX;
        enemyCardY = enemyTargetY;
    }


    float cw2 = Card.BASE_WIDTH  * PLAYED_CARD_SCALE * sScale;
    float ch2 = Card.BASE_HEIGHT * PLAYED_CARD_SCALE * sScale;

    pushMatrix();
    translate(enemyCardX + cw2/2, enemyCardY + ch2/2);
    rotate(-sAngle); 
    enemyPlayedCard.displayWithAlpha(-cw2/2, -ch2/2, PLAYED_CARD_SCALE * sScale, enemyAlpha, false);
    popMatrix(); 
  }
  popStyle(); 
}
