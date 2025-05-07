/* Persistence.pde
 * Elemental Clash – Handles Save/Load functionality using JSON
 * Saves and loads the game state to a JSON file.
 */
import processing.data.JSONObject;
import processing.data.JSONArray;
import java.io.File;

final String SAVE_FILENAME = "elemental_clash_save.json";

void saveGame(){
  println("[SAVE] Attempting to save game to " + dataPath(SAVE_FILENAME) + "...");
  JSONObject saveData = new JSONObject();
  try {
    saveData.setInt("difficulty", difficulty);
    saveData.setInt("playerShuffleCount", playerShuffleCount);
    saveData.setInt("enemyShuffleCount", enemyShuffleCount);
    saveData.setBoolean("playerTurn", playerTurn);
    saveData.setBoolean("gameOver", gameOver);
    saveData.setBoolean("lootPrompt", lootPrompt);


    saveData.setBoolean("playerDidAttackLastTurn", playerDidAttackLastTurn);
    saveData.setBoolean("enemyDidAttackLastTurn", enemyDidAttackLastTurn);
    saveData.setBoolean("isNewMoon", isNewMoon);
    saveData.setBoolean("isGrounded", isGrounded);
    if (player != null) {
        JSONObject playerState = new JSONObject();
        playerState.setInt("hp", player.hp);
        playerState.setInt("mana", player.mana);
        playerState.setJSONArray("deck", cardsToJson(playerDeck));
        playerState.setJSONArray("hand", cardsToJson(hand));
        playerState.setJSONArray("discardPile", cardsToJson(playerDiscardPile));
        playerState.setInt("frozenTurns", player.frozenTurns);
        playerState.setInt("healDisabledTurns", player.healDisabledTurns);
        playerState.setInt("attackDisabledTurns", player.attackDisabledTurns);
        playerState.setInt("skipManaRegenTurns", player.skipManaRegenTurns);
        playerState.setInt("burnTurns", player.burnTurns);
        playerState.setInt("burnAmount", player.burnAmount);
        playerState.setInt("shamedTurns", player.shamedTurns);

        saveData.setJSONObject("player", playerState);
    } else {
         println("[SAVE] Warning: Player object is null. Player state not saved.");
    }


    if (enemy != null) {
        JSONObject enemyState = new JSONObject();
        enemyState.setInt("hp", enemy.hp);
        enemyState.setInt("mana", enemy.mana);
        enemyState.setJSONArray("deck", cardsToJson(enemy.enemyDeck));
        enemyState.setJSONArray("hand", cardsToJson(enemy.enemyHand));
        enemyState.setJSONArray("discardPile", cardsToJson(enemy.discardPile));
        enemyState.setInt("frozenTurns", enemy.frozenTurns);
        enemyState.setInt("healDisabledTurns", enemy.healDisabledTurns);
        enemyState.setInt("attackDisabledTurns", enemy.attackDisabledTurns);
        enemyState.setInt("skipManaRegenTurns", enemy.skipManaRegenTurns);
        enemyState.setInt("burnTurns", enemy.burnTurns);
        enemyState.setInt("burnAmount", enemy.burnAmount);
        enemyState.setInt("shamedTurns", enemy.shamedTurns);

        enemyState.setString("name", enemy.name);

        saveData.setJSONObject("enemy", enemyState);
    } else {
        println("[SAVE] Warning: Enemy object is null. Enemy state not saved.");
    }


    saveJSONObject(saveData, dataPath(SAVE_FILENAME));
    println("[SAVE] Game saved successfully.");
    addToActionLog("Game saved.");
  } catch (Exception e) {
    println("[SAVE] Error saving game: " + e.getMessage());
    addToActionLog("Error saving game!");
    e.printStackTrace();
  }
}

void loadGame(){
  println("[LOAD] Attempting to load game from " + dataPath(SAVE_FILENAME) + "...");
  File saveFile = new File(dataPath(SAVE_FILENAME));
  if (!saveFile.exists()) {
    println("[LOAD] No save file found at " + dataPath(SAVE_FILENAME));
    addToActionLog("No save file found.");
    return;
  }

  JSONObject saveData = loadJSONObject(dataPath(SAVE_FILENAME));
  if (saveData == null) {
    println("[LOAD] Error loading save data from file.");
    addToActionLog("Error loading save file!");
    return;
  }

  try {
    difficulty = saveData.getInt("difficulty", 1);
    playerShuffleCount = saveData.getInt("playerShuffleCount", PLAYER_STARTING_SHUFFLES);
    enemyShuffleCount = saveData.getInt("enemyShuffleCount", getEnemyShuffles());
    boolean loadedPlayerTurn = saveData.getBoolean("playerTurn", true);
    gameOver = saveData.getBoolean("gameOver", false);
    lootPrompt = saveData.getBoolean("lootPrompt", false);

    phase = PHASE_PLAYER_ACTION;
    phaseTimer = 0;
    resolutionStart = 0;
    fadeStart = 0;

    playerPlayedCard = null;
    enemyPlayedCard = null;
    hoveredCard = null;
    currentlyZoomedCard = null;
    currentZoomScaleAnim = 0.0f;
    currentZoomAlphaAnim = 0.0f;
    targetZoomScale = 0.0f;
    targetZoomAlpha = 0.0f;
    zoomActive = false;
    flashTimer = 0;
    playerAlpha = 255;
    enemyAlpha = 255;

    playerDidAttackLastTurn = saveData.getBoolean("playerDidAttackLastTurn", false);
    enemyDidAttackLastTurn = saveData.getBoolean("enemyDidAttackLastTurn", false);
    isNewMoon = saveData.getBoolean("isNewMoon", false);
    isGrounded = saveData.getBoolean("isGrounded", true);

    JSONObject playerState = saveData.getJSONObject("player");
    if (playerState != null) {
      player = new Player(PLAYER_MAX_HP, PLAYER_MAX_MANA);
      player.hp = playerState.getInt("hp", PLAYER_MAX_HP);
      player.mana = playerState.getInt("mana", PLAYER_MAX_MANA);
      playerDeck = jsonToCards(playerState.getJSONArray("deck"));
      hand = jsonToCards(playerState.getJSONArray("hand"));
      playerDiscardPile = jsonToCards(playerState.getJSONArray("discardPile"));
      player.frozenTurns = playerState.getInt("frozenTurns", 0);
      player.healDisabledTurns = playerState.getInt("healDisabledTurns", 0);
      player.attackDisabledTurns = playerState.getInt("attackDisabledTurns", 0);
      player.skipManaRegenTurns = playerState.getInt("skipManaRegenTurns", 0);
      player.burnTurns = playerState.getInt("burnTurns", 0);
      player.burnAmount = playerState.getInt("burnAmount", 0);
      player.shamedTurns = playerState.getInt("shamedTurns", 0);

      println("[LOAD] Player state loaded. HP: " + player.hp + " Mana: " + player.mana + " Deck: " + playerDeck.size() + " Hand: " + hand.size() + " Discard: " + playerDiscardPile.size());
    } else {
      println("[LOAD] Warning: Player save data missing. Resetting player state.");
      player = new Player(PLAYER_MAX_HP, PLAYER_MAX_MANA);
      initPlayerDeck();
      shuffleDeck(playerDeck);
      drawHand();
    }

    JSONObject enemyState = saveData.getJSONObject("enemy");
    if (enemyState != null) {
      String enemyName = enemyState.getString("name", "Green Goblin");
      enemy = new Enemy(enemyName, getEnemyHP());
      enemy.hp = enemyState.getInt("hp", getEnemyHP());
       enemy.mana = enemyState.getInt("mana", PLAYER_MAX_MANA);

      enemy.enemyDeck = jsonToCards(enemyState.getJSONArray("deck"));
      enemy.enemyHand = jsonToCards(enemyState.getJSONArray("hand"));
      enemy.discardPile = jsonToCards(enemyState.getJSONArray("discardPile"));
      enemy.frozenTurns = enemyState.getInt("frozenTurns", 0);
      enemy.healDisabledTurns = enemyState.getInt("healDisabledTurns", 0);
      enemy.attackDisabledTurns = enemyState.getInt("attackDisabledTurns", 0);
      enemy.skipManaRegenTurns = enemyState.getInt("skipManaRegenTurns", 0);
      enemy.burnTurns = enemyState.getInt("burnTurns", 0);
      enemy.burnAmount = enemyState.getInt("burnAmount", 0);
      enemy.shamedTurns = enemyState.getInt("shamedTurns", 0);
      println("[LOAD] Enemy state loaded. HP: " + enemy.hp + " Mana: " + enemy.mana + " Deck: " + enemy.enemyDeck.size() + " Hand: " + enemy.enemyHand.size() + " Discard: " + enemy.discardPile.size());
    } else {
      println("[LOAD] Warning: Enemy save data missing. Resetting enemy state.");
      enemy = new Enemy("Green Goblin", getEnemyHP());
      enemy.initializeEnemyDeck();
      shuffleDeck(enemy.enemyDeck);
      enemy.drawStartingHand();
    }

    playerTurn = loadedPlayerTurn;

    buildButtons();
    updateShuffleButton();
    addToActionLog("Game loaded successfully.");
    println("[LOAD] Game loaded.");
    if (gameOver) {
        currentGameState = GameState.GAME_OVER;
        if(fatalityAnim != null) { fatalityAnim.play(); fatalityAnim.jump(0); }
    } else if (lootPrompt) {
         currentGameState = GameState.LOOT_SCREEN;
         if(flawlessAnim != null) { flawlessAnim.play(); flawlessAnim.jump(0); }
    }
    else {
        currentGameState = GameState.GAME_RUNNING;
        currentPanel = 0;
         if (playerTurn) {
            addToActionLog("Your turn to act!");
         } else {
            addToActionLog(enemy.name + "'s turn to act!");
         }
    }


  } catch (Exception e) {
    println("[LOAD] Error loading or parsing save file: " + e.getMessage());
    addToActionLog("Error loading save file!");
    e.printStackTrace();
  }
}


JSONArray cardsToJson(ArrayList<Card> cardList){
  JSONArray jsonArray = new JSONArray();
  if (cardList == null) return jsonArray;

  for (Card c : cardList) {
    if (c == null) continue;
    JSONObject cardJson = new JSONObject();
    cardJson.setString("n", c.name);
    cardJson.setInt("d", c.damage);
    cardJson.setInt("m", c.manaCost);
    cardJson.setString("k", c.imageKey);
    cardJson.setString("r", c.rulesText);
    cardJson.setInt("i", c.initiative); // Save "i" for initiative
    cardJson.setString("ct", c.creatureType);
    jsonArray.append(cardJson);
  }
  return jsonArray;
}

ArrayList<Card> jsonToCards(JSONArray cardArray){
  ArrayList<Card> cardList = new ArrayList<Card>();
  if (cardArray == null) return cardList;

  for (int i = 0; i < cardArray.size(); i++) {
    JSONObject cardJson = cardArray.getJSONObject(i);
    if (cardJson != null) {
      Card loadedCard = new Card(
        cardJson.getString("n", "Unknown Card"),
        cardJson.getInt("d", 0),
        cardJson.getInt("m", 0),
        cardJson.getString("k", "CardBack"),
        cardJson.getString("r", "No rules text."),
        cardJson.getInt("i", 1), // Load "i" as initiative, default to 1
        cardJson.getString("ct", "None")
      );
      cardList.add(loadedCard);
    }
  }
  return cardList;
}
