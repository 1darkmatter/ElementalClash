/* Card.pde
 * Elemental Clash – Card definition and display
 * Manages card attributes and rendering, including hover-zoom info panels.
 */
import processing.core.PImage;

class Card {
  static final float BASE_WIDTH  = 170;
  static final float BASE_HEIGHT = 255;
  static final float TXT_S       = 10;
  static final float TXT_N       = 13;

  String name;
  int    damage;
  int    manaCost;
  String imageKey;
  String rulesText;
  int    initiative = 1; // Renamed from speed
  String creatureType = "None";

  // Base constructor
  Card(String n, int dmg, int mana, String key, String rules) {
    name     = n;
    damage   = dmg;
    manaCost = mana;
    imageKey = key;
    rulesText = rules;
  }

  // Constructor with initiative
  Card(String n, int dmg, int mana, String key, String rules, int init) { // Parameter renamed init
    this(n, dmg, mana, key, rules);
    initiative = init; // Assigned to initiative
  }

  // Constructor with initiative and type
  Card(String n, int dmg, int mana, String key, String rules, int init, String cType) { // Parameter renamed init
    this(n, dmg, mana, key, rules, init); // Calls constructor with init
    if (cType != null && !cType.isEmpty()) {
      creatureType = cType;
    }
  }


  void displayWithAlpha(float x, float y, float s, float alpha, boolean zoom) {
    PImage art = cardImages.get(imageKey);
    float w = BASE_WIDTH * s;
    float h = BASE_HEIGHT * s;

    pushStyle();
    if (art != null) {
      tint(255, alpha);
      image(art, x, y, w, h);
      noTint();
    } else {
      fill(150, alpha);
      rect(x, y, w, h, 8 * s);
      fill(0, alpha);
      textAlign(CENTER, CENTER);
      textSize(11 * s);
      textLeading(14 * s);
      text(name, x + w/2 - w*0.4f, y + h/2 - 11 * s, w*0.8f, 11 * s * 2);
    }

    if (zoom && alpha > 0) {
      float pad   = 8 * s;
      float panelX = x + w + pad;
      float panelY = y;
      float panelH = h;
      float maxW   = width - panelX - pad;
      float defaultW = 260 * s;
      float panelW = min(defaultW, maxW);

      pushStyle();
      fill(0, alpha * 0.85f);
      noStroke();
      rect(panelX, panelY, panelW, panelH, 6 * s);
      float currentY = panelY + pad;

      if (titleFont != null) textFont(titleFont); else textFont(defaultSystemFont);
      textSize(TXT_S * s * 1.1f);
      textAlign(LEFT, TOP);
      textLeading(TXT_S * s * 1.2f);

      fill(COLOR_HP_BAR, alpha);
      String lbl = damage > 0 ?
 "DMG: " + damage : damage < 0 ?
 "HEAL: " + (-damage) : "EFFECT";
      text(lbl, panelX + pad, currentY);
      currentY += TXT_S * s * 1.1f + 4;

      fill(COLOR_MANA_BAR, alpha);
      text("MANA: " + manaCost, panelX + pad, currentY);
      currentY += TXT_S * s * 1.1f + 4;

      fill(200, alpha);
      text("INITIATIVE: " + initiative, panelX + pad, currentY); // Changed label to INITIATIVE
      currentY += TXT_S * s * 1.1f + 4;

      text("TYPE: " + creatureType, panelX + pad, currentY);
      currentY += TXT_S * s * 1.1f + 8;

      textFont(defaultSystemFont); // Use default font for rules text
      fill(255, alpha);
      textSize(TXT_S * s * 0.8f);
      textLeading(TXT_S * s * 1.0f);
      textAlign(LEFT, TOP);
      text(rulesText, panelX + pad, currentY, panelW - 2 * pad, panelH - (currentY - panelY) - pad - (TXT_N * s + pad));

      // Use title font for the Card Title at the bottom
      if (titleFont != null) textFont(titleFont); else textFont(defaultSystemFont);
      fill(255, alpha);
      textSize(TXT_N * s);
      textAlign(CENTER, BOTTOM);
      text(name, panelX + panelW/2, panelY + panelH - pad);

      popStyle();
    }
    popStyle();
  }

  boolean isClickedInHand(float cx, float cy, float mx, float my) {
    float w = BASE_WIDTH * HAND_CARD_SCALE;
    float h = BASE_HEIGHT * HAND_CARD_SCALE;
    return mx >= cx && mx <= cx + w && my >= cy && my <= cy + h;
  }
}
