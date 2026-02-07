extends Spatial

onready var player = get_node("player")
onready var player2 = get_node("player2")
onready var orange = get_node("orange")
onready var orange2 = get_node("orange2")
onready var lemon = get_node("lemon")
onready var heartFruit = get_node("heartFruit")
onready var coconut1 = get_node("coconut")
onready var coconut2 = get_node("coconut2")
onready var coconut3 = get_node("coconut3")
onready var coconut4 = get_node("coconut4")
onready var coconut5 = get_node("coconut5")
onready var coconut6 = get_node("coconut6")
onready var coconut7 = get_node("coconut7")
onready var coconutMerchant = get_node("coconutMerchant")
onready var orangeFish = get_node("orangeFish")
onready var aquariumPet = get_node("aquariumPet")
onready var ewSound = get_node("EwSound")
onready var bubbleSound = get_node("BubbleSound")
onready var chompSound = get_node("ChompSound")
onready var equipCoconutSound = get_node("EquipCoconutSound")
onready var coconutChompSound = get_node("CoconutChompSound")
onready var shatterSound = get_node("ShatterSound")
onready var spitSound = get_node("SpitSound")
onready var sadSound = get_node("SadSound")
onready var kissSound = get_node("KissSound")
onready var swooshSound = get_node("SwooshSound")
onready var oofSound = get_node("OofSound")
onready var umSound = get_node("UmSound")
onready var crabSound = get_node("CrabSound")
onready var coolSound = get_node("CoolSound")
onready var applauseSound = get_node("ApplauseSound")
onready var owSound = get_node("OwSound")
onready var bigOwSound = get_node("BigOwSound")
onready var heySound = get_node("HeySound")
onready var errorSound = get_node("ErrorSound")
onready var lemonSound = get_node("LemonSound")
onready var whatsupSound = get_node("WhatsupSound")
onready var heyUpsetSound = get_node("HeyUpsetSound")
onready var deadParasiteSound = get_node("DeadParasiteSound")
onready var screamSound = get_node("ScreamSound")
onready var textBox = get_node("CanvasLayer/TextBox")
onready var textBoxText = get_node("CanvasLayer/TextBox/Text")
onready var textBoxTop = get_node("CanvasLayer/TextBoxTop")
onready var textBoxTopText = get_node("CanvasLayer/TextBoxTop/Text")
onready var camera = get_node("Camera")
onready var crabsNode = get_node("Crabs")
onready var coralsNode = get_node("Corals")
onready var secretCoral = get_node("Corals/secretCoral")
onready var bigCrab = get_node("bigCrab")
onready var wolfEelHead = get_node("WolfEelHead")
onready var deathOverlay = get_node("CanvasLayer/DeathOverlay")
onready var deathOverlayText = get_node("CanvasLayer/DeathOverlay/Text")
onready var creditsText = get_node("CanvasLayer/DeathOverlay/CreditsText")

var freed_aquarium_pet = false
var should_keep_moving_forward = false
var minimum_camera_x = 0
var currentCameraXBounds = Vector2(0, 0)
var currentCameraYBounds = Vector2(0, 0)
var has_stolen_a_coconut = false
var creeped_out_coconut_merchant = false
var sin_counter = 0
var helpful_counter = 0
var bubbleRes = preload("res://bubble.tscn")
var heartBubbleRes = preload("res://heartBubble.tscn")
var random_bubble_timer = 0
var random_bubble_time_limit = 10
var death_counter = 0
var move_counter = 0
var move_counter_at_last_game_state = 0
var combo_counter = 0
var trick_counter = 0
var max_combo = 0
var player2_combo_counter = 0
var player2_trick_counter = 0
var player2_max_combo = 0
var kiss_counter = 0
var kiss_combo_counter = 0
var max_kiss_combo = 0
var max_num_kisses_until_death = 8
var prevTextBoxVisible = false
var prevTextBoxTopVisible = false
var died_to_coconut_overconsumption = false
var died_to_kissing = false
var has_died_to_coconut_crab = false
var coconutCrabArray = []

var has_sacred_waltz_started = false
var SACRED_WALTZ_X_START = 52
var SACRED_WALTZ_X_START_REALLY = 65
var CAMERA_MIN_X_OFFSET = 2
var LEMON_Y_OFFSET = -69
var HOW_MANY_ORANGES = 3
var HOW_MANY_ORANGES_NO_IM_SERIOUS = 8
var HOW_MANY_LEMONS = 5
var FINAL_NUMBER_OF_ORANGES = 25

enum GameState {
    ORANGE_EATING,
    ORANGE_FISH_COMPLAINING,
    BEGIN_ADVENTURE,
    CRAB_INTERLUDE,
    COCONUT_CRAB_TIME,
    OCEAN_DEEP,
    SACRED_WALTZ,
    # SPAWNING_GROUNDS,
    END_CREDITS,
    FINAL_SCORE,
    GAME_OVER,
}
var gameState = GameState.ORANGE_EATING
var prevGameState = GameState.ORANGE_EATING
var causeOfDeathStr = "you died"

var can_end_the_game = false
var how_many_oranges_ate = 0
var how_many_coconuts_ate = 0
var how_many_lemons_ate = 0
var how_many_heart_fruit_ate = 0
var adventure_camera_size = 10
var waltz_camera_size = 15
var should_snap_camera = false
var parasite_damage_counter = 0
var parasite_damage_count_max = 10
var parasite_oof_counter = 0
var parasite_oof_counter_max = 3

func _ready():
    textBox.visible = true
    textBoxText.bbcode_text = "[color=#ff8426]if you so desire:\n    * use[/color] [wave]arrow keys[/wave] [color=#ff8426]to move..[/color]"
    set_process(true)

var lemon_failsafe_counter = 0
var lemon_failsafe_count_max = 7
var move_on_my_own_timer = 0
var move_on_my_own_time_max = 8

# top y = -60, bottom y = -70
# left x = 59, right x = 72

# player.x = 66
# player.y = -65

# player2.x = 65
# player2.y = -65

# enum DanceState {
#     GO_TO_CORNERS
# }
# var danceState = DanceState.GO_TO_CORNERS
# func processCelestialBeingMovement(_delta):
#     var playerPos = player.headSprite.global_transform.origin
#     var player2Pos = player2.headSprite.global_transform.origin
#     print(playerPos, player2Pos, danceState)
#     if danceState == DanceState.GO_TO_CORNERS:
#         if playerPos.y == player2Pos.y:
#             player2.moveDown(true)
#             player.moveUp(true)
#             playerMovedBubbleSpawn()
#             playerMovedBubbleSpawn(player2)
#             return
#         else:
#             if playerPos.x > 60:
#                 player.moveLeft(true)
#                 playerMovedBubbleSpawn()
#             elif playerPos.y < -59:
#                 player.moveUp(true)
#                 playerMovedBubbleSpawn()
#             if player2Pos.x < 71:
#                 player.moveRight(true)
#                 playerMovedBubbleSpawn(player2)
#             elif player2Pos.y > -69:
#                 player.moveDown(true)
#                 playerMovedBubbleSpawn(player2)

var increment_timer = 0
var increment_time_limit = 0.5
var stop_it = false
onready var oldWomanSound = get_node("OldWomanSound")
func _process(delta):
    # it's not working w/e
    # if gameState == GameState.SPAWNING_GROUNDS:
    #     move_on_my_own_timer += (delta*22)
    #     if move_on_my_own_timer >= move_on_my_own_time_max:
    #         move_on_my_own_timer = 0
    #         processCelestialBeingMovement(delta)
    #     return
    if stop_it:
        if Input.is_action_just_pressed("ui_accept") and gameState == GameState.END_CREDITS:
            stop_it = false
            gameState = GameState.FINAL_SCORE
            creditsText.visible_characters = -1
        return

    if gameState == GameState.FINAL_SCORE:
        deathOverlay.color.a += 0.2 * delta
        if deathOverlay.color.a > 0.8:
            deathOverlay.color.a = 0.8
        deathOverlayText.visible = false
        creditsText.visible = true
        if creditsText.visible_characters == -1:
            creditsText.visible_characters = 0
            var finalText = "[center]"
            finalText += "[color=#847e87]fruit ate:[/color] " + str(how_many_oranges_ate + how_many_coconuts_ate + how_many_lemons_ate + how_many_heart_fruit_ate)
            finalText += "\n[color=#847e87]deaths:[/color] " + str(death_counter)
            finalText += "\n[color=#847e87]crabs coconutted:[/color] " + str(len(coconutCrabArray) + (1 if bigCrab.get_node("Sprite3D").start_frame == 8 else 0))
            finalText += "\n[color=#847e87]helpfulness:[/color] " + str(helpful_counter)
            finalText += "\n[color=#847e87]sin incurred:[/color] " + str(sin_counter)
            finalText += "\n[color=#847e87]total tricks:[/color] " + str(trick_counter) + ", hiscore: " + str(max_combo)
            finalText += "\n[color=#847e87]player 2 tricks:[/color] " + str(player2_trick_counter) + ", hiscore: " + str(player2_max_combo)
            finalText += "\n[color=#847e87]total kisses:[/color] " + str(kiss_counter) + ", hiscore: " + str(max_kiss_combo)
            if freed_aquarium_pet:
                finalText += "\n[wave]you freed the aquarium pet ^_^[/wave]"
            finalText += "\n [color=#847e87]okay bye.[/color]"
            finalText += "[/center]"
            creditsText.bbcode_text = finalText
        if creditsText.visible_characters < creditsText.bbcode_text.length() - 250 and not Input.is_action_just_pressed("ui_accept"):
            increment_timer += (delta*22)
            if increment_timer >= increment_time_limit:
                print(creditsText.visible_characters, ", ", creditsText.bbcode_text.length())
                increment_timer = 0
                oldWomanSound.pitch_scale = rand_range(0.8, 1.2)
                oldWomanSound.play()
                creditsText.visible_characters += 1
        else:
            creditsText.visible_characters = -1
            aquariumPet.get_node("YippeeSound").pitch_scale = 0.5
            aquariumPet.get_node("YippeeSound").play()
            stop_it = true
        return
    elif gameState == GameState.END_CREDITS:
        textBox.visible = false
        textBoxTop.visible = false
        deathOverlay.color.a += 0.2 * delta
        if deathOverlay.color.a > 0.8:
            deathOverlay.color.a = 0.8
        deathOverlayText.visible = false
        creditsText.visible = true
        if creditsText.visible_characters == -1:
            creditsText.visible_characters = 0
            creditsText.bbcode_text = "[center]you beat [color=#ff8426]orange ocean[/color]\nfor bigmode 2026 by [color=#ff8408]p[/color][color=#63ce08]e[/color][color=#ffff3a]t[/color][color=#6b63ff]s[/color] [color=#ffff3a]c[/color][color=#6b63ff]l[/color][color=#ff8408]u[/color][color=#63ce08]b[/color] 2 / jakeonaut\n\ngodot engine: godot team idk\ndark souls death sound: videogamedunkey\ntropical water normal map: filter forge\nerror boy sfx: UGameZ (on itch!)\nwilhelm scream: ???\neverything else by me!\n i made it!\n[shake]ME!!!!![/shake]\npress [ENTER] for final score[/center]"
        if creditsText.visible_characters < creditsText.bbcode_text.length() - 250 and not Input.is_action_just_pressed("ui_accept"):
            increment_timer += (delta*22)
            if increment_timer >= increment_time_limit:
                increment_timer = 0
                oldWomanSound.pitch_scale = rand_range(0.8, 1.2)
                oldWomanSound.play()
                creditsText.visible_characters += 1
        else:
            creditsText.visible_characters = -1
            aquariumPet.get_node("YippeeSound").play()
            stop_it = true
        return

    # DEBUG
    if player.headSprite.global_transform.origin.x > 48 and gameState == GameState.ORANGE_EATING:
        gameState = GameState.OCEAN_DEEP

    var has_player_moved = false
    if not deathOverlay.visible:
        if Input.is_action_just_pressed("ui_up"):
            has_player_moved = player.moveUp()
            if triedToKissPlayer2(0, -1):
                player.restoreBodyPartPositions()
                has_player_moved = false
            elif shouldPlayer2Move():
                player2.moveDown()
                playerMovedBubbleSpawn(player2)
            playerMovedBubbleSpawn()
            
        elif Input.is_action_just_pressed("ui_down"):
            has_player_moved = player.moveDown()
            if triedToKissPlayer2(0, 1):
                player.restoreBodyPartPositions()
                has_player_moved = false
            elif shouldPlayer2Move():
                player2.moveUp()
                playerMovedBubbleSpawn(player2)
            playerMovedBubbleSpawn()
        if Input.is_action_just_pressed("ui_left"):
            has_player_moved = player.moveLeft()
            if triedToKissPlayer2(1, 0):
                player.restoreBodyPartPositions()
                has_player_moved = false
            elif shouldPlayer2Move():
                player2.moveRight()
                playerMovedBubbleSpawn(player2)
            playerMovedBubbleSpawn()
        elif Input.is_action_just_pressed("ui_right"):
            has_player_moved = player.moveRight()
            if triedToKissPlayer2(-1, 0):
                player.restoreBodyPartPositions()
                has_player_moved = false
            elif shouldPlayer2Move():
                player2.moveLeft()
                playerMovedBubbleSpawn(player2)
            playerMovedBubbleSpawn()
        else:
            random_bubble_timer += (delta*22)
            if random_bubble_timer >= random_bubble_time_limit:
                random_bubble_timer = 0
                random_bubble_time_limit = rand_range(10, 40)
                spawnBubble(player.headSprite.global_transform.origin, 0)
    if has_player_moved:
        if isPlayerOutOfBounds(player):
            player.restoreBodyPartPositions()
            errorSound.play()
            has_player_moved = false
            if isPlayerOutOfBounds(player2):
                player2.restoreBodyPartPositions()
        elif triedToHeadbuttAquariumPet():
            player.restoreBodyPartPositions()
            errorSound.play()
            has_player_moved = false
            if aquariumPet.get_node("Sprite3D").start_frame == 6:
                umSound.play()
                aquariumPet.get_node("Sprite3D").updateBaseFrameWithStartFrame(22)
                textBoxTopText.bbcode_text = "[center]um. don't tap the glass..[/center]"
        else:
            move_counter += 1
    # okay, semi-regardless of game state...
    if gameState != GameState.GAME_OVER:
        thingsToDoRegardlessOfGameState(has_player_moved, delta)
        
    if gameState == GameState.ORANGE_EATING:
        prevGameState = gameState
        if has_player_moved:
            if isPlayerEating(orange):
                player.eatAnOrange()
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)    
                if how_many_oranges_ate >= 2:
                    textBox.visible = false
                if how_many_oranges_ate >= HOW_MANY_ORANGES:
                    # orange.visible = false
                    orangeFish.visible = true
                    heySound.play()
                    gameState = GameState.ORANGE_FISH_COMPLAINING
                    while doesIntersectWithAnyBodyPart(orangeFish):
                        orangeFish.global_transform.origin.x = randi() % 7 - 3
                        orangeFish.global_transform.origin.y = randi() % 7 - 3
                    textBox.visible = true
                    textBoxText.bbcode_text = "[center]hey man, you're eating all my [wave]freaking[/wave] [color=#ff8426]oranges[/color]!!![/center]"
                while doesIntersectWithAnyBodyPart(orange) or orange.global_transform.origin.is_equal_approx(orangeFish.global_transform.origin):
                    orange.global_transform.origin.x = randi() % 7 - 3
                    orange.global_transform.origin.y = randi() % 7 - 3
    elif gameState == GameState.ORANGE_FISH_COMPLAINING:
        prevGameState = gameState
        if has_player_moved:
            if isPlayerEating(orange):
                player.eatAnOrange()
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)    
                if how_many_oranges_ate >= HOW_MANY_ORANGES_NO_IM_SERIOUS:
                    if orange.visible:
                        heyUpsetSound.play()
                    orange.visible = false
                    sin_counter += 2
                    textBoxText.bbcode_text = "[center]well, are you happy? [color=#ff8426]they're[/color] all gone.\ni hate you[/center]"
                else:
                    while doesIntersectWithAnyBodyPart(orange) or orange.global_transform.origin.is_equal_approx(orangeFish.global_transform.origin):
                        orange.global_transform.origin.x = randi() % 7 - 3
                        orange.global_transform.origin.y = randi() % 7 - 3
            elif isPlayerEating(orangeFish):
                CAMERA_X_OFFSET = 7
                CAMERA_Y_OFFSET = 6
                screamSound.play()
                sin_counter += 10
                player.eatAnOrange()
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                orangeFish.visible = false
                move_counter_at_last_game_state = move_counter
                gameState = GameState.BEGIN_ADVENTURE
                textBox.visible = true
                textBoxText.bbcode_text = "[center][shake][color=#ff8426]AAAAAUUUUUUGGGHHH!!!!!![/color][/shake][/center]"
                orange.visible = true
                orange.global_transform.origin.x = randi() % 7 - 3
                orange.global_transform.origin.y = player.headSprite.global_transform.origin.y - 3
                while doesIntersectWithAnyBodyPart(orange):
                    orange.global_transform.origin.x = randi() % 7 - 3
                    orange.global_transform.origin.y = player.headSprite.global_transform.origin.y - 3
    elif gameState == GameState.BEGIN_ADVENTURE:
        prevGameState = gameState
        updateGameCamera(delta, Vector2(0, 0), Vector2(0, -25))
        if has_player_moved:
            if isPlayerEating(orange):
                player.eatAnOrange()
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                orange.global_transform.origin.x = randi() % 7 - 3
                orange.global_transform.origin.y = player.headSprite.global_transform.origin.y - 3
                while doesIntersectWithAnyBodyPart(orange):
                    orange.global_transform.origin.x = randi() % 7 - 3
                    orange.global_transform.origin.y = player.headSprite.global_transform.origin.y - 3
        if move_counter > move_counter_at_last_game_state + 5:
            textBox.visible = false
        if player.headSprite.global_transform.origin.y <= -24:
            textBoxTop.visible = true
            crabSound.play()
            textBoxTopText.bbcode_text = "[center][color=red]we're just some crabs. don't fuck with us!!!\nwe'll only move if you give us a coconut[/color][/center]"
            gameState = GameState.CRAB_INTERLUDE
            coconut1.visible = true
            coconut2.visible = true
            coconut3.visible = true
            coconut4.visible = true
            coconut5.visible = true
            coconut6.visible = true
            coconut7.visible = true
            coconutMerchant.visible = true
    elif gameState == GameState.CRAB_INTERLUDE:
        prevGameState = gameState
        updateGameCamera(delta, Vector2(0, 0), Vector2(0, -45))
        if has_player_moved:
            playerMovedEatAnOrange()
            if has_stolen_a_coconut:
                if player.headSprite.global_transform.origin.y <= -20:
                    coconut1.visible = true
                    coconut2.visible = true
                    coconut3.visible = true
                    coconut4.visible = true
                    coconut5.visible = true
                    coconut6.visible = true
                    coconut7.visible = true
            if player.headSprite.global_transform.origin.y >= -15 and not creeped_out_coconut_merchant and not isPlayerEating(coconutMerchant):
                move_counter_at_last_game_state = move_counter
                textBoxTop.visible = false
                if not textBox.visible:
                    if not has_stolen_a_coconut:
                        whatsupSound.pitch_scale = rand_range(1.1, 1.3)
                        whatsupSound.play()
                    else:
                        heyUpsetSound.pitch_scale = rand_range(1.4, 1.6)
                        heyUpsetSound.play()
                textBox.visible = true
                if not has_stolen_a_coconut:
                    textBoxText.bbcode_text = "[center]i'm a monkey-maid. yes, we exist.\nwanna buy a coconut?[/center]"
                else:
                    textBoxText.bbcode_text = "[center]you gonna pay for that bub?[/center]"
            elif player.headSprite.global_transform.origin.y <= -25:
                if not textBoxTopText.bbcode_text == "[color=red]we told you not to fuck with us man[/color]":
                    move_counter_at_last_game_state = move_counter
                textBox.visible = false
                if not textBoxTop.visible or (textBoxTopText.bbcode_text == "[color=red]we told you not to fuck with us man[/color]" and move_counter >= move_counter_at_last_game_state + 2):
                    crabSound.pitch_scale = rand_range(0.9, 1.1)
                    crabSound.play()
                    textBoxTop.visible = true
                    if not has_stolen_a_coconut:
                        textBoxTopText.bbcode_text = "[center][color=red]we're just some crabs. don't fuck with us!!!\nwe'll only move if you give us a coconut[/color][/center]"
                    elif has_stolen_a_coconut:
                        textBoxTopText.bbcode_text = "[center][color=red]oh shit! you got a [color=#9e5b47]coconut[/color].\nspit that sucker out with[/color] [wave]X[/wave] [color=red]or[/color] [wave]Space[/wave][/center]"
            else:
                if move_counter > move_counter_at_last_game_state + 3:
                    textBox.visible = false
                    textBoxTop.visible = false
    elif gameState == GameState.COCONUT_CRAB_TIME:
        prevGameState = gameState
        updateGameCamera(delta, Vector2(0, 0), Vector2(0, -65))
        if has_player_moved:
            playerMovedEatAnOrange()
            if has_stolen_a_coconut:
                if player.headSprite.global_transform.origin.y <= -20:
                    coconut1.visible = true
                    coconut2.visible = true
                    coconut3.visible = true
                    coconut4.visible = true
                    coconut5.visible = true
                    coconut6.visible = true
                    coconut7.visible = true
            if move_counter > move_counter_at_last_game_state + 2:
                textBox.visible = false
                textBoxTop.visible = false
            if isPlayerEating(lemon):
                player.eatALemon()
                lemonSound.pitch_scale = rand_range(0.8, 1.0)
                lemonSound.play()
                gameState = GameState.OCEAN_DEEP
                player.infestWithParasites()
                for i in range(4):
                    var coconut = [coconut1, coconut3, coconut5, coconut7][i]
                    coconut.visible = true
                    coconut.global_transform.origin.x -= 6
                    coconut.global_transform.origin.y -= 53
                # should_keep_moving_forward = true
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                lemon.global_transform.origin.x = player.headSprite.global_transform.origin.x + 3
                lemon.global_transform.origin.y = randi() % 7 + LEMON_Y_OFFSET
                lemon_failsafe_counter = 0
                while doesIntersectWithAnyBodyPart(lemon) and lemon_failsafe_counter < lemon_failsafe_count_max:
                    lemon.global_transform.origin.x = player.headSprite.global_transform.origin.x + 3
                    lemon.global_transform.origin.y = randi() % 7 + LEMON_Y_OFFSET
                    lemon_failsafe_counter += 1
    elif gameState == GameState.OCEAN_DEEP:
        prevGameState = gameState
        updateGameCamera(delta, Vector2(0, 50), Vector2(-65, -65))
        if has_player_moved:
            playerMovedEatAnOrange()
            if player.headSprite.global_transform.origin.x >= SACRED_WALTZ_X_START:
                secretCoral.visible = true
                equipCoconutSound.pitch_scale = 0.5
                equipCoconutSound.play()
                for i in range(5):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                gameState = GameState.SACRED_WALTZ
                FINAL_NUMBER_OF_ORANGES = how_many_oranges_ate + 7
                CAMERA_X_OFFSET = 7
                CAMERA_Y_OFFSET = 6
            if how_many_lemons_ate >= 2 and player.doIHaveParasites():
                parasite_oof_counter += 1
                if parasite_oof_counter >= parasite_oof_counter_max:
                    parasite_oof_counter = 0
                    oofSound.pitch_scale = rand_range(1.0, 1.4)
                    oofSound.play()
                    player.get_node("AnimationPlayer").stop()
                    player.get_node("AnimationPlayer").play("hurtByParasite")
                    parasite_damage_counter += 1
                    if parasite_damage_counter >= parasite_damage_count_max:
                        parasite_damage_counter = 0
                        death_counter += 1
                        gameState = GameState.GAME_OVER
                        owSound.pitch_scale = rand_range(0.4, 0.6)
                        owSound.play()
                        causeOfDeathStr = "[color=#a271ff]succumbed to deep-sea parasites[/color]"
            if move_counter > move_counter_at_last_game_state + 2:
                textBox.visible = false
                textBoxTop.visible = false
            if isPlayerEating(lemon):
                player.eatALemon()
                minimum_camera_x = player.headSprite.global_transform.origin.x - CAMERA_MIN_X_OFFSET
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                lemonSound.pitch_scale = rand_range(0.8, 1.0)
                lemonSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                if how_many_lemons_ate >= HOW_MANY_LEMONS:
                    lemon.visible = false
                else:
                    lemon.global_transform.origin.x = player.headSprite.global_transform.origin.x + 3
                    lemon.global_transform.origin.y = randi() % 7 + LEMON_Y_OFFSET
                    lemon_failsafe_counter = 0
                    while (doesIntersectWithAnyBodyPart(lemon) or doesIntersectWithAnyCoral(lemon)) and lemon_failsafe_counter < lemon_failsafe_count_max:
                        lemon.global_transform.origin.x = player.headSprite.global_transform.origin.x + 3
                        lemon.global_transform.origin.y = randi() % 7 + LEMON_Y_OFFSET
                        lemon_failsafe_counter += 1
                    lemon_failsafe_counter = 0
                    while doesIntersectWithAnyCoral(lemon) and lemon_failsafe_counter < lemon_failsafe_count_max:
                        lemon.global_transform.origin.x = player.headSprite.global_transform.origin.x + 3
                        lemon.global_transform.origin.y = randi() % 7 + LEMON_Y_OFFSET
                        lemon_failsafe_counter += 1

            var headPos = player.headSprite.global_transform.origin
            var aquariumPetPos = aquariumPet.global_transform.origin
            if headPos.x > aquariumPetPos.x - 4 and headPos.x < aquariumPetPos.x + 4 and not freed_aquarium_pet:
                move_counter_at_last_game_state = move_counter
                if not textBoxTop.visible:
                    if minimum_camera_x < aquariumPetPos.x - CAMERA_MIN_X_OFFSET*3:
                        minimum_camera_x = aquariumPetPos.x - CAMERA_MIN_X_OFFSET*3
                    heySound.pitch_scale = rand_range(1.2, 1.4)
                    heySound.play()
                    textBoxTop.visible = true
                    textBoxTopText.bbcode_text = "hi!! hi!! over here!!! i'm stuck\nin this aquarium... i'm slowly dying lol!!"
            elif headPos.x >= aquariumPetPos.x + 4 and headPos.x < aquariumPetPos.x + 7 and not freed_aquarium_pet:
                move_counter_at_last_game_state = move_counter
                if textBoxTopText.bbcode_text == "hi!! hi!! over here!!! i'm stuck\nin this aquarium... i'm slowly dying lol!!":
                    sadSound.pitch_scale = rand_range(1.4, 1.6)
                    sadSound.play()
                    textBoxTop.visible = true
                    textBoxTopText.bbcode_text = "oh okay... bye..."
            elif move_counter > move_counter_at_last_game_state + 3:
                textBox.visible = false
                textBoxTop.visible = false
    elif gameState == GameState.SACRED_WALTZ:
        prevGameState = gameState
        if how_many_oranges_ate < FINAL_NUMBER_OF_ORANGES:
            orange2.visible = true
        if has_sacred_waltz_started:
            updateGameCamera(delta, Vector2(65.5, 65.5), Vector2(-65, -65))
        else:
            updateGameCamera(delta, Vector2(SACRED_WALTZ_X_START, 65), Vector2(-65, -65))
        if has_player_moved:
            if player.headSprite.global_transform.origin.x >= SACRED_WALTZ_X_START_REALLY:
                has_sacred_waltz_started = true
            if isPlayerEating(heartFruit):
                ewSound.pitch_scale = rand_range(1.4, 1.6)
                ewSound.play()
                player.get_node("AnimationPlayer").stop()
                player.get_node("AnimationPlayer").play("hurtByParasite")
                while doesIntersectWithAnyBodyPart(heartFruit, player2):
                    heartFruit.global_transform.origin.x = SACRED_WALTZ_X_START_REALLY + (randi() % 9 - 4)
                    heartFruit.global_transform.origin.y = -65 + (randi() % 9 - 4)
            if isPlayerEating(orange2, player2):
                ewSound.pitch_scale = rand_range(1.4, 1.6)
                ewSound.play()
                player2.get_node("AnimationPlayer").stop()
                player2.get_node("AnimationPlayer").play("hurtByParasite")
                while doesIntersectWithAnyBodyPart(orange2):
                    orange2.global_transform.origin.x = SACRED_WALTZ_X_START_REALLY + (randi() % 9 - 4)
                    orange2.global_transform.origin.y = -65 + (randi() % 9 - 4)

            if isPlayerEating(orange2):
                player.eatAnOrange()
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                if how_many_oranges_ate >= FINAL_NUMBER_OF_ORANGES:
                    orange2.visible = false
                while doesIntersectWithAnyBodyPart(orange2):
                    orange2.global_transform.origin.x = SACRED_WALTZ_X_START_REALLY + (randi() % 9 - 4)
                    orange2.global_transform.origin.y = -65 + (randi() % 9 - 4)
            playerMovedEatAnOrange()
            if isPlayerEating(heartFruit, player2):
                player2.eatAHeartFruit()
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                if how_many_heart_fruit_ate >= FINAL_NUMBER_OF_ORANGES or (player2.how_many_times_did_i_grow + player2.should_grow >= FINAL_NUMBER_OF_ORANGES):
                    heartFruit.visible = false
                else:
                    while doesIntersectWithAnyBodyPart(heartFruit, player2):
                        heartFruit.global_transform.origin.x = SACRED_WALTZ_X_START_REALLY + (randi() % 9 - 4)
                        heartFruit.global_transform.origin.y = -65 + (randi() % 9 - 4)
            if not heartFruit.visible and not orange2.visible and not textBoxTop.visible:
                can_end_the_game = true
                aquariumPet.get_node("YippeeSound").play()
                textBoxTop.visible = true
                textBox.visible = true
                textBoxTopText.bbcode_text = "wow!! congratulations! YOU WIN!\ni ran out of time to make more,\nsorry!"
                textBoxText.bbcode_text = "alright, now seal the deal\nwith 3 kisses (3)!!\nthen i'll roll credits"
                # gameState = GameState.SPAWNING_GROUNDS
    elif gameState == GameState.GAME_OVER:
        updateGameCamera(delta)
        textBoxTop.visible = false
        if not deathOverlay.visible:
            deathOverlay.visible = true
            deathOverlayText.bbcode_text = "[center]you died...[/center]\ncause of death:\n    [color=red][shake]" + causeOfDeathStr + "[/shake][/color]\n\ntry again? press ENTER"
        deathOverlay.color.a += 0.2 * delta
        if deathOverlay.color.a > 1:
            deathOverlay.color.a = 1
        if Input.is_action_just_pressed("ui_accept"):
            if not died_to_kissing:
                player.restoreBodyPartPositions()
            deathOverlay.visible = false
            deathOverlay.color.a = 0
            gameState = prevGameState
            textBoxTop.visible = prevTextBoxTopVisible
            textBox.visible = prevTextBoxVisible
            if prevGameState == GameState.CRAB_INTERLUDE and not died_to_coconut_overconsumption:
                textBoxTop.visible = true
                if how_many_coconuts_ate > 0:
                    textBoxTopText.bbcode_text = "[color=red]i aint movin'\n'til i get my coconut, brudda[/color]"
                else:
                    textBoxTopText.bbcode_text = "[color=red]we told you not to fuck with us man[/color]"
                textBox.visible = false
                crabSound.play()
            elif prevGameState == GameState.COCONUT_CRAB_TIME:
                if causeOfDeathStr == "got BIG COCONUT CRABBED" or causeOfDeathStr == "got BIG CRABBED":
                    textBoxTop.visible = true
                    textBoxTopText.bbcode_text = "[color=red]sorry puny one,\ni am comfortable here.[/color]"
                    crabSound.play()
                elif causeOfDeathStr == "got coconut crabbed":
                    textBoxTop.visible = true
                    textBoxTopText.bbcode_text = "[color=red]oh, wait, you want us to move?\n sorry, sorry.[/color]"
                    crabSound.play()
                elif causeOfDeathStr == "got crabbed":
                    textBoxTop.visible = true
                    textBoxTopText.bbcode_text = "[color=red]i aint movin'\n'til i get my coconut, brudda[/color]"
                    crabSound.play()
                textBox.visible = false
            died_to_coconut_overconsumption = false


var CAMERA_X_OFFSET = 6
var CAMERA_Y_OFFSET = 5
func isPlayerOutOfBounds(which_player = player):
    var lb = currentCameraXBounds.x - CAMERA_X_OFFSET
    var rb = currentCameraXBounds.y + CAMERA_X_OFFSET
    var tb = currentCameraYBounds.x + CAMERA_Y_OFFSET
    var bb = currentCameraYBounds.y - CAMERA_Y_OFFSET
    var headPos = which_player.headSprite.global_transform.origin
    return headPos.x <= lb or headPos.x >= rb or headPos.y >= tb or headPos.y <= bb

func triedToHeadbuttAquariumPet():
    return isPlayerEating(aquariumPet) and aquariumPet.get_node("Sprite3D").start_frame != 12


func triedToKissPlayer2(_x, _y):
    var tried_to_kiss = isPlayerEating(player2.headSprite)
    if tried_to_kiss:
        if player2.should_grow > 0:
            player2.grow(_x, _y)

        if player2.headSprite.facing.x != 0:
            kiss_counter += 1
            kiss_combo_counter += 1
            if kiss_combo_counter >= 3:
                var newAwesomeText = player.text3dRes.instance()
                self.add_child(newAwesomeText)
                var textArrayToUse = ["smoochy", "smoochums", "mwah!", "kiss-o-matic"]
                var textToUse = textArrayToUse[randi() % len(textArrayToUse)]
                textToUse = "+" + str(kiss_combo_counter) + " " + textToUse
                var got_a_new_highscore = false
                if kiss_combo_counter > max_kiss_combo:
                    max_kiss_combo = kiss_combo_counter
                    if kiss_combo_counter >= 4:
                        textToUse = textToUse + "\nnew high score!!!"
                        got_a_new_highscore = true
                newAwesomeText.get_node("Label3D").text = textToUse
                newAwesomeText.global_transform.origin = player.headSprite.global_transform.origin + Vector3(0, 0, 5.5)
                if got_a_new_highscore:
                    applauseSound.play()
                else:
                    coolSound.pitch_scale = rand_range(1.4, 1.8)
                    coolSound.play()
                if can_end_the_game:
                    gameState = GameState.END_CREDITS
                    deathOverlay.visible = true
                    deathOverlay.color.a = 0
                elif kiss_combo_counter >= max_num_kisses_until_death:
                    owSound.play()
                    gameState = GameState.GAME_OVER
                    causeOfDeathStr = "stop kissing!!!"
                    if died_to_kissing:
                        causeOfDeathStr = "alright fine you win"
                        max_num_kisses_until_death = 999
                    died_to_kissing = true
                    kiss_combo_counter = 0
            kissSound.play()
            spawnAKiss()
        else:
            errorSound.play()
    return tried_to_kiss

func spawnAKiss():
    yield(get_tree().create_timer(0.1), "timeout")
    for i in range(2):
        spawnBubble(player.headSprite.global_transform.origin, i + 1, heartBubbleRes)

func shouldPlayer2Move():
    return gameState == GameState.SACRED_WALTZ and player.headSprite.global_transform.origin.x >= SACRED_WALTZ_X_START

func thingsToDoRegardlessOfGameState(has_player_moved, delta):
    var headPos = player.headSprite.global_transform.origin
    var csgPos = player.csgCombinerPosition.global_transform.origin
    # camera.size = camera.size + (adventure_camera_size - camera.size) * (delta*5)
    player.csgCombinerPosition.global_transform.origin.x = csgPos.x + (headPos.x - csgPos.x) * (delta * 5)
    player.csgCombinerPosition.global_transform.origin.y = csgPos.y + (headPos.y - csgPos.y) * (delta * 5)

    if has_player_moved:
        kiss_combo_counter -= 1
        if kiss_combo_counter <= 0:
            kiss_combo_counter = 0
        if isPlayerHeadCollidingWith(bigCrab.get_node("Sprite3D"), -1.5, 1, 1.5, -1):
            owSound.pitch_scale = rand_range(0.4, 0.6)
            owSound.play()
            bigOwSound.pitch_scale = rand_range(0.4, 0.6)
            bigOwSound.play()
            deathOverlay.visible = false
            deathOverlay.color.a = 0.3
            prevTextBoxVisible = textBox.visible
            prevTextBoxTopVisible = textBoxTop.visible
            death_counter += 1
            gameState = GameState.GAME_OVER
            if bigCrab.get_node("Sprite3D").start_frame == 8:
                causeOfDeathStr = "got BIG COCONUT CRABBED"
                has_died_to_coconut_crab = true
            else:
                causeOfDeathStr = "got BIG CRABBED"
        if isPlayerHeadCollidingWith(wolfEelHead, -1.5, 1, 1.5, -1) and not wolfEelHead.start_frame == 28:
            screamSound.pitch_scale = rand_range(0.4, 0.6)
            screamSound.play()
            bigOwSound.pitch_scale = rand_range(0.4, 0.6)
            bigOwSound.play()
            deathOverlay.visible = false
            deathOverlay.color.a = 0.3
            prevTextBoxVisible = textBox.visible
            prevTextBoxTopVisible = textBoxTop.visible
            death_counter += 1
            gameState = GameState.GAME_OVER
            causeOfDeathStr = "[img]res://wolfEel.png[/img]"

        for i in crabsNode.get_child_count():
            var crab = crabsNode.get_child(i)
            if not crab.visible:
                continue
            elif willCoconutCrabsRunAway() and crab.get_node("Sprite3D").start_frame == 8:
                pass
            elif isPlayerHeadCollidingWith(crab.get_node("Sprite3D")):
                owSound.pitch_scale = rand_range(0.4, 0.6)
                owSound.play()
                deathOverlay.visible = false
                deathOverlay.color.a = 0.3
                prevTextBoxVisible = textBox.visible
                prevTextBoxTopVisible = textBoxTop.visible
                death_counter += 1
                gameState = GameState.GAME_OVER
                if crab.get_node("Sprite3D").start_frame == 8:
                    causeOfDeathStr = "got coconut crabbed"
                    has_died_to_coconut_crab = true
                else:
                    causeOfDeathStr = "got crabbed"
        for i in coralsNode.get_child_count():
            var coral = coralsNode.get_child(i)
            if not coral.visible:
                continue
            elif isPlayerHeadCollidingWith(coral):
                owSound.pitch_scale = rand_range(0.4, 0.6)
                owSound.play()
                deathOverlay.visible = false
                deathOverlay.color.a = 0.3
                prevTextBoxVisible = textBox.visible
                prevTextBoxTopVisible = textBoxTop.visible
                death_counter += 1
                gameState = GameState.GAME_OVER
                causeOfDeathStr = "[color=#00ffff]dead coral tell no tales[/color]"
        for i in range(7):
                var coconut = [coconut1, coconut2, coconut3, coconut4, coconut5, coconut6, coconut7][i]
                if isPlayerEating(coconut):
                    if player.eatACoconut():
                        coconut.visible = false
                    coconutChompSound.play()
                    if not has_stolen_a_coconut:
                        textBox.visible = false
                    has_stolen_a_coconut = true
        if not creeped_out_coconut_merchant and isPlayerEating(coconutMerchant):
            textBoxTop.visible = false
            heySound.pitch_scale = 0.5
            heySound.play()
            textBox.visible = true
            textBoxText.bbcode_text = "[center]uhh.. i'm sorry, i don't feel the same way..[/center]"
            sin_counter += 2
            if sin_counter >= 16: # and not coconutMerchant.is_stunned:
                creeped_out_coconut_merchant = true
                textBoxText.bbcode_text = "[center]okay.. i'm gonna go...[/center]"
    if Input.is_action_just_pressed("ui_select"):
        player.spitCoconutProjectile()
    if creeped_out_coconut_merchant and coconutMerchant.visible:
        coconutMerchant.global_transform.origin.x += (delta*4)
        coconutMerchant.global_transform.origin.y += (delta*4)
        if coconutMerchant.global_transform.origin.x >= 9:
            coconutMerchant.visible = false
    if willCoconutCrabsRunAway():
        for i in range(len(coconutCrabArray)):
            var coconutCrab = coconutCrabArray[i]
            if not coconutCrab.visible: continue
            coconutCrab.frame_delay = 0.1
            if player.headSprite.global_transform.origin.x >= coconutCrab.global_transform.origin.x:
                coconutCrab.global_transform.origin.x -= (delta*5)
                if coconutCrab.global_transform.origin.x < -9:
                    coconutCrab.visible = false
            else:
                coconutCrab.global_transform.origin.x += (delta*5)
                if coconutCrab.global_transform.origin.x > 9:
                    coconutCrab.visible = false

func willCoconutCrabsRunAway():
    if has_died_to_coconut_crab:
        return true
    elif len(coconutCrabArray) >= 6:
        return true
    elif len(coconutCrabArray) >= 5 and bigCrab.get_node("Sprite3D").start_frame == 8:
        return true
    return false 

func playerMovedBubbleSpawn(which_player = player):
    random_bubble_timer = 0
    if gameState == GameState.BEGIN_ADVENTURE or gameState == GameState.CRAB_INTERLUDE:
        bubbleSound.pitch_scale = rand_range(0.6, 1.0)
    elif gameState == GameState.COCONUT_CRAB_TIME or gameState == GameState.SACRED_WALTZ: # or gameState == GameState.SPAWNING_GROUNDS:
        bubbleSound.pitch_scale = rand_range(0.5, 0.9)
    elif gameState == GameState.OCEAN_DEEP:
        bubbleSound.pitch_scale = rand_range(0.4, 0.8)
    else:
        bubbleSound.pitch_scale = rand_range(0.8, 1.2)
    bubbleSound.play()
    var how_many = 1 if shouldPlayer2Move() else 2
    for i in range(how_many):
        spawnBubble(which_player.headSprite.global_transform.origin, i)

func playerMovedEatAnOrange():
    if isPlayerEating(orange):
        player.eatAnOrange()
        chompSound.pitch_scale = rand_range(0.8, 1.2)
        chompSound.play()
        for i in range(3):
            spawnBubble(player.headSprite.global_transform.origin, i + 1)
        orange.visible = false

func isPlayerHeadCollidingWith(target, lb = -0.5, tb = 0.5, rb = 0.5, bb = -0.5, which_player = player):
    var pos = which_player.headSprite.global_transform.origin
    var tPos = target.global_transform.origin
    return pos.x > tPos.x + lb and pos.x < tPos.x + rb and pos.y > tPos.y + bb and pos.y < tPos.y + tb

func isPlayerEating(sprite, which_player = player):
    if not sprite.visible:
        return false
    return sprite.global_transform.origin.x == which_player.headSprite.global_transform.origin.x and sprite.global_transform.origin.y == which_player.headSprite.global_transform.origin.y

func doesIntersectWithAnyBodyPart(sprite, which_player = player):
    var spritePos = sprite.global_transform.origin
    for i in range(len(which_player.myBodyParts)):
        var bodyPart = which_player.myBodyParts[i]
        var bodyPartPos = bodyPart.global_transform.origin
        if spritePos.x == bodyPartPos.x and spritePos.y == bodyPartPos.y:
            return true
    return false 

func doesIntersectWithAnyCoral(sprite):
    var spritePos = sprite.global_transform.origin
    for i in coralsNode.get_child_count():
        var coral = coralsNode.get_child(i)
        if not coral.visible: continue
        var coralPos = coral.global_transform.origin
        if spritePos.x == coralPos.x and spritePos.y == coralPos.y:
            return true
    return false 

func faceUp(sprite):
    sprite.rotation_degrees.z = 90
    sprite.flip_h = false

func faceDown(sprite):
    sprite.rotation_degrees.z = -90
    sprite.flip_h = false

func faceLeft(sprite):
    sprite.rotation_degrees.z = 0
    sprite.flip_h = true

func faceRight(sprite):
    sprite.rotation_degrees.z = 0
    sprite.flip_h = false

func spawnBubble(pos, time_to_yield = 0, which_bubble_res = bubbleRes):
    if time_to_yield > 0:
        yield(get_tree().create_timer(0.1*time_to_yield), "timeout")
    var newBubble = which_bubble_res.instance()
    self.add_child(newBubble)
    newBubble.global_transform.origin = pos
    newBubble.global_transform.origin.y += rand_range(0.3, 0.8)
    newBubble.global_transform.origin.x += rand_range(-0.5, 0.5)
    if randi() % 2 <= 1:
        newBubble.which_x = -1

func updateGameCamera(delta, x_bounds = null, y_bounds = null):
    if x_bounds != null: currentCameraXBounds = x_bounds
    if y_bounds != null: currentCameraYBounds = y_bounds

    # var size_to_use = adventure_camera_size if gameState != GameState.SACRED_WALTZ else waltz_camera_size
    var size_to_use = adventure_camera_size
    camera.size = camera.size + (size_to_use - camera.size) * (delta*5)
    if stepify(camera.size, 0.1) == stepify(size_to_use, 0.1):
        camera.size = size_to_use
    if should_snap_camera:
        camera.global_transform.origin = player.cameraTarget.global_transform.origin
    elif camera.size == size_to_use:
        camera.global_transform.origin = camera.global_transform.origin + (player.cameraTarget.global_transform.origin - camera.global_transform.origin) * (delta*2)
        if camera.global_transform.origin.x > currentCameraXBounds.y:
            camera.global_transform.origin.x = currentCameraXBounds.y
        elif camera.global_transform.origin.x < currentCameraXBounds.x:
            camera.global_transform.origin.x = currentCameraXBounds.x
        if camera.global_transform.origin.y < currentCameraYBounds.y:
            camera.global_transform.origin.y = currentCameraYBounds.y
        elif camera.global_transform.origin.y > currentCameraYBounds.x:
            camera.global_transform.origin.y = currentCameraYBounds.x

    if should_keep_moving_forward:
        if camera.global_transform.origin.x < minimum_camera_x:
            camera.global_transform.origin.x = minimum_camera_x
            

    var coverOfDarknessAlpha = 0
    if gameState == GameState.COCONUT_CRAB_TIME:
        var y = camera.global_transform.origin.y
        coverOfDarknessAlpha = ((-40 - y) / 20)
    elif gameState == GameState.OCEAN_DEEP:
        var x = camera.global_transform.origin.x
        coverOfDarknessAlpha = ((SACRED_WALTZ_X_START - x) / 20)

    if coverOfDarknessAlpha < 0: coverOfDarknessAlpha = 0
    if coverOfDarknessAlpha > 1: coverOfDarknessAlpha = 1
    player.coverOfDarkness.material.albedo_color.a = coverOfDarknessAlpha

    # if y > -40, alpha should equal 0
    # if y == -40, alpha should equal 0
    # if y == -60, alpha should equal 1
    # alpha = -40
        
