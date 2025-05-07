/* Player.pde
 * Elemental Clash – Player character definition
 * Manages player state, HP, Mana, and status effects.
 */
class Player{
  int hp,mana; 

  int     frozenTurns       = 0;
  int     healDisabledTurns = 0;
  int     attackDisabledTurns = 0;
  int     skipManaRegenTurns = 0;
  int     burnTurns    = 0;
  int     burnAmount   = 0;
  int     shamedTurns  = 0;
  Player(int h,int m){
    hp=h;
    mana=m; 
  }

  void takeDamage(int d){
    if(d > 0) { 
      int actualDamage = d;
      if (shamedTurns > 0) { 
        actualDamage = max(0, d - 1);
        println("Player is Shamed! Damage reduced by 1.");
      }
      hp = max(0, hp - actualDamage);
      println("Player took " + actualDamage + " damage. HP: " + hp);
    }
  }

  void heal(int h){
    if(h > 0 && healDisabledTurns == 0) { 
        hp = min(PLAYER_MAX_HP, hp + h);
        println("Player healed " + h + " HP. HP: " + hp);
    } else if (healDisabledTurns > 0) {
         println("Player's healing is disabled!");
    }
  }

  void drainMana() {
    mana = 0;
     println("Player's mana was drained!");
  }

  void applyStatus(String statusType, int duration, int amount) {
      if (duration <= 0) return;
      println("Player is affected by " + statusType + " for " + duration + " turns.");
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
      println("Player status update @ start of action phase:");
      if (burnTurns > 0) {
          println("Player takes " + burnAmount + " burn damage.");
          takeDamage(burnAmount);
          burnTurns--;
          if (burnTurns == 0) {
            println("Player is no longer burning.");
            burnAmount = 0; 
          }
      }

      if (frozenTurns > 0) {
          frozenTurns--;
          if (frozenTurns == 0) println("Player is no longer frozen."); 
      }
      if (attackDisabledTurns > 0) {
          attackDisabledTurns--;
          if (attackDisabledTurns == 0) println("Player's attack is no longer disabled.");
      }
      if (skipManaRegenTurns > 0) {
      }
       if (healDisabledTurns > 0) {
          healDisabledTurns--;
          if (healDisabledTurns == 0) println("Player's healing is no longer disabled.");
      }
      if (shamedTurns > 0) {
          shamedTurns--;
          if (shamedTurns == 0) println("Player is no longer shamed."); 
      }
  }
  
  void endTurnManaStatusUpdate() {
    if (skipManaRegenTurns > 0) {
        skipManaRegenTurns--;
        if (skipManaRegenTurns == 0) println("Player will regenerate mana next turn.");
    }
  }


  boolean isFrozen()        { return frozenTurns > 0;
  }
  boolean isAttackDisabled(){ return attackDisabledTurns > 0; }
  boolean canHeal()         { return healDisabledTurns == 0;
  }
  boolean canRegenMana()    { return skipManaRegenTurns == 0;
  }
  boolean isShamed()        { return shamedTurns > 0; }
}
