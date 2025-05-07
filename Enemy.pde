/* Enemy.pde
 * Elemental Clash – Enemy character definition
 * Manages enemy state (HP, Mana), deck, hand, and status effects.
 */
import java.util.ArrayList;

class Enemy {
  String name;
  int hp;
  int mana;
  int frozenTurns       = 0; 
  int healDisabledTurns = 0;
  int attackDisabledTurns = 0;
  int skipManaRegenTurns = 0;
  int burnTurns    = 0;
  int burnAmount   = 0;
  int shamedTurns  = 0;

  ArrayList<Card> enemyDeck    = new ArrayList<Card>();
  ArrayList<Card> enemyHand    = new ArrayList<Card>();
  ArrayList<Card> discardPile  = new ArrayList<Card>();
  Enemy(String n, int h) {
    name = n;
    hp   = h;
    mana = PLAYER_MAX_MANA;
    frozenTurns = 0;
    healDisabledTurns = 0;
    attackDisabledTurns = 0;
    skipManaRegenTurns = 0;
    burnTurns = 0;
    burnAmount = 0;
    shamedTurns = 0;
  }

  void initializeEnemyDeck() {
    enemyDeck.clear();
    discardPile.clear();
    enemyHand.clear();
    enemyDeck.add(new Card("Pyrelash Vortex",      4, 2, "PyrelashVortex",       "Deal 4 damage to target.\nDeal 1 damage to yourself."));
    enemyDeck.add(new Card("Arctic Descent",       3, 4, "ArcticDescent",        "Deal 3 damage and freeze enemy for 1 turn."));
    enemyDeck.add(new Card("Dustline Hunt",        4, 5, "DustlineHunt",         "Deal 4 damage.\nBonus +2 damage if target didn't attack last turn."));
    enemyDeck.add(new Card("Lunate Shatter",       3, 5, "LunateShatter",        "Deal 3 damage. If under New Moon, deal 2 extra damage and disable healing for 1 turn."));
    enemyDeck.add(new Card("Sugarveil Mirage",     2, 4, "SugarveilMirage",      "Deal 2 damage. If opponent is smiling (IRL), deal +1 damage."));
    enemyDeck.add(new Card("Iron Requiem Strike",  2, 5, "IronRequiemStrike",    "Deal 2 damage and disable opponent's next attack."));
    enemyDeck.add(new Card("Ground Burst Mirage",  3, 4, "GroundBrustMirage",    "Deal 3 damage, gain 1 HP."));
    enemyDeck.add(new Card("Void Spell Unleashed", 3, 0, "VoidSpellUnleashed",   "Deal 3 damage to target and drain all their Mana."));
    enemyDeck.add(new Card("Nullivelle's Silent",  5, 6, "NullivellesSilent",    "Deal 5 damage. If opponent has full HP, deal +1 damage."));
    enemyDeck.add(new Card("Woundcycle",           3, 4, "Woundcycle",           "Deal 3 damage.\nTarget skips Mana regeneration next turn."));
    enemyDeck.add(new Card("Shuffle Surge",        0, 4, "Shuffle",              "Gain +1 Shuffle charge."));
    enemyDeck.add(new Card("Paddle of Pain",       2, 4, "PaddleOfPain",         "Deal 2 damage and apply Shamed (Damage reduced next turn) for 1 turn."));
    enemyDeck.add(new Card("Selvynne Overdrive Open-Cab", 5, 5, "SelvynneOverdriveOpenCab", "Deal 5 damage."));
    enemyDeck.add(new Card("Selyras Fiery Descent",2, 5, "SelyrasFieryDescent",  "Deal 2 damage. Target loses 1 HP at the start of their next turn for 1 turn."));
    enemyDeck.add(new Card("Taenya Chainsaw",      2, 4, "TaenyaChainsaw",       "Deal 2 damage, prevent enemy actions next turn."));
    enemyDeck.add(new Card("Thandors Wild Ride",   4, 3, "ThandorsWildRide",     "Deal 4 damage and skip opponent's next action."));
    enemyDeck.add(new Card("Vexalia Fire Feast",   3, 4, "VexaliaFireFeast",     "Deal 3 damage, burn 1 HP per turn for 2 turns."));
    enemyDeck.add(new Card("Xelyth Fiery Feast",   3, 1, "XelythFieryFeast",     "Deal 3 damage, burn 1 HP per turn for 2 turns."));
    for (int i = 0; i < 5; i++) enemyDeck.add(new Card("Arctic Descent",       3, 4, "ArcticDescent",        "Deal 3 damage and freeze enemy for 1 turn."));
    for (int i = 0; i < 5; i++) enemyDeck.add(new Card("Ground Burst Mirage",  3, 4, "GroundBrustMirage",    "Deal 3 damage, gain 1 HP."));
    for (int i = 0; i < 3; i++) enemyDeck.add(new Card("Shuffle Surge",        0, 4, "Shuffle",              "Gain +1 Shuffle charge."));
    for (int i = 0; i < 4; i++) enemyDeck.add(new Card("Woundcycle",           3, 4, "Woundcycle",           "Deal 3 damage.\nTarget skips Mana regeneration next turn."));
    for (int i = 0; i < 2; i++) enemyDeck.add(new Card("Vexalia Fire Feast",   3, 4, "VexaliaFireFeast",     "Deal 3 damage, burn 1 HP per turn for 2 turns."));
  }

  void takeDamage(int d) {
    if(d > 0) {
      int actualDamage = d;
      if (shamedTurns > 0) {
        actualDamage = max(0, d - 1);
        println(name + " is Shamed! Damage reduced by 1.");
      }
      hp = max(0, hp - actualDamage);
      println(name + " took " + actualDamage + " damage. HP: " + hp);
    }
  }

  void heal(int h) {
    if(h > 0 && healDisabledTurns == 0) {
        hp = min(getEnemyHP(), hp + h);
        println(name + " healed " + h + " HP. HP: " + hp);
    } else if (healDisabledTurns > 0) {
         println(name + "'s healing is disabled!");
    }
  }

  void drainMana() {
    mana = 0;
    println(name + "'s mana was drained!");
  }

  void applyStatus(String statusType, int duration, int amount) {
      if (duration <= 0) return;
      println(name + " is affected by " + statusType + " for " + duration + " turns (amount: " + amount + ").");
      if (statusType.equals("freeze")) {
          frozenTurns = max(frozenTurns, duration);
      } else if (statusType.equals("healDisabled")) {
          healDisabledTurns = max(healDisabledTurns, duration);
      } else if (statusType.equals("attackDisabled")) {
          attackDisabledTurns = max(attackDisabledTurns, duration);
      } else if (statusType.equals("skipManaRegen")) {
          skipManaRegenTurns = max(skipManaRegenTurns, duration);
      } else if (statusType.equals("burn")) {
          burnAmount = max(burnAmount, amount);
          burnTurns = max(burnTurns, duration);   
      } else if (statusType.equals("shamed")) {
          shamedTurns = max(shamedTurns, duration);
      }
  }

  void startTurnStatusUpdate() { 
    println(name + " status update @ start of action phase:");
    if (burnTurns > 0) {
      println(name + " takes " + burnAmount + " burn damage.");
      takeDamage(burnAmount);
      burnTurns--;
       if (burnTurns == 0) {
           println(name + " is no longer burning.");
           burnAmount = 0; 
       }
    }

    if (frozenTurns > 0) {
        frozenTurns--;
        if (frozenTurns == 0) println(name + " is no longer frozen.");
    }
    if (attackDisabledTurns > 0) {
        attackDisabledTurns--;
        if (attackDisabledTurns == 0) println(name + "'s attack is no longer disabled.");
    }
    if (skipManaRegenTurns > 0) { 
    }
    if (healDisabledTurns > 0) {
        healDisabledTurns--;
        if (healDisabledTurns == 0) println(name + "'s healing is no longer disabled.");
    }
     if (shamedTurns > 0) {
        shamedTurns--;
        if (shamedTurns == 0) println(name + " is no longer shamed.");
    }
  }
  
  void endTurnManaStatusUpdate() {
    if (skipManaRegenTurns > 0) {
        skipManaRegenTurns--;
        if (skipManaRegenTurns == 0) println(name + " will regenerate mana next turn.");
    }
  }


  boolean isFrozen()        { return frozenTurns > 0;
  }
  boolean isAttackDisabled(){ return attackDisabledTurns > 0; }
  boolean canHeal()         { return healDisabledTurns == 0;
  }
  boolean canRegenMana()    { return skipManaRegenTurns == 0;
  }
  boolean isShamed()        { return shamedTurns > 0;
  }


  void drawStartingHand() {
    int cardsToDraw = ENEMY_STARTING_CARDS - enemyHand.size();
    cardsToDraw = max(0, cardsToDraw);
    for (int i = 0; i < cardsToDraw && enemyHand.size() < HAND_SIZE_LIMIT; i++) {
        if (enemyDeck.isEmpty()) {
            println("[WARN] " + name + "'s deck is empty. Cannot draw more cards.");
            break;
        }
        enemyHand.add(enemyDeck.remove(0));
    }
    println(name + " drew hand. Total cards: " + enemyHand.size());
  }
}
