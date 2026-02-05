extends Spatial

onready var player = get_node("player")
onready var orange = get_node("orange")
onready var coconut = get_node("coconut")
onready var coconutMerchant = get_node("coconutMerchant")
onready var orangeFish = get_node("orangeFish")
onready var bubbleSound = get_node("BubbleSound")
onready var chompSound = get_node("ChompSound")
onready var equipCoconutSound = get_node("EquipCoconutSound")
onready var coconutChompSound = get_node("CoconutChompSound")
onready var spitSound = get_node("SpitSound")
onready var swooshSound = get_node("SwooshSound")
onready var crabSound = get_node("CrabSound")
onready var owSound = get_node("OwSound")
onready var bigOwSound = get_node("BigOwSound")
onready var heySound = get_node("HeySound")
onready var whatsupSound = get_node("WhatsupSound")
onready var heyUpsetSound = get_node("HeyUpsetSound")
onready var screamSound = get_node("ScreamSound")
onready var textBox = get_node("CanvasLayer/TextBox")
onready var textBoxText = get_node("CanvasLayer/TextBox/Text")
onready var textBoxTop = get_node("CanvasLayer/TextBoxTop")
onready var textBoxTopText = get_node("CanvasLayer/TextBoxTop/Text")
onready var camera = get_node("Camera")
onready var crabsNode = get_node("Crabs")
onready var bigCrab = get_node("bigCrab")
onready var deathOverlay = get_node("CanvasLayer/DeathOverlay")
onready var deathOverlayText = get_node("CanvasLayer/DeathOverlay/Text")
var creeped_out_coconut_merchant = false
var sin_counter = 0
var bubbleRes = preload("res://bubble.tscn")
var random_bubble_timer = 0
var random_bubble_time_limit = 10
var death_counter = 0
var move_counter = 0
var move_counter_at_last_game_state = 0
var prevTextBoxVisible = false
var prevTextBoxTopVisible = false
var has_died_to_coconut_crab = false

var HOW_MANY_ORANGES = 3

enum GameState {
    ORANGE_EATING,
    ORANGE_FISH_COMPLAINING,
    BEGIN_ADVENTURE,
    CRAB_INTERLUDE,
    COCONUT_CRAB_TIME,
    GAME_OVER,
}
var gameState = GameState.ORANGE_EATING
var prevGameState = GameState.ORANGE_EATING
var causeOfDeathStr = "you died"

var how_many_oranges_ate = 0
var adventure_size = 10
var should_snap_camera = false

func _ready():
    set_process(true)

func _process(delta):
    var has_player_moved = false
    if not deathOverlay.visible:
        if Input.is_action_just_pressed("ui_up"):
            player.moveUp()
            has_player_moved = true
        elif Input.is_action_just_pressed("ui_down"):
            player.moveDown()
            has_player_moved = true
        if Input.is_action_just_pressed("ui_left"):
            player.moveLeft()
            has_player_moved = true
        elif Input.is_action_just_pressed("ui_right"):
            player.moveRight()
            has_player_moved = true
        else:
            random_bubble_timer += (delta*22)
            if random_bubble_timer >= random_bubble_time_limit:
                random_bubble_timer = 0
                random_bubble_time_limit = rand_range(10, 40)
                spawnBubble(player.headSprite.global_transform.origin, 0)
    
    if has_player_moved:
        move_counter += 1
        
    if gameState == GameState.ORANGE_EATING:
        prevGameState = gameState
        if has_player_moved:
            playerMovedBubbleSpawn()
            if isPlayerEating(orange):
                how_many_oranges_ate += 1
                player.eatAnOrange()
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                
                if how_many_oranges_ate >= 2:
                    textBox.visible = false

                if how_many_oranges_ate >= HOW_MANY_ORANGES:
                    orange.visible = false
                    orangeFish.visible = true
                    heySound.play()
                    gameState = GameState.ORANGE_FISH_COMPLAINING
                    while doesIntersectWithAnyBodyPart(orangeFish):
                        orangeFish.global_transform.origin.x = randi() % 7 - 3
                        orangeFish.global_transform.origin.y = randi() % 7 - 3
                    textBox.visible = true
                    textBoxText.bbcode_text = "[center]hey man, you're eating all my [wave]freaking[/wave] [color=#ff8426]oranges[/color]!!![/center]"
                else:
                    while doesIntersectWithAnyBodyPart(orange):
                        orange.global_transform.origin.x = randi() % 7 - 3
                        orange.global_transform.origin.y = randi() % 7 - 3
    elif gameState == GameState.ORANGE_FISH_COMPLAINING:
        prevGameState = gameState
        if has_player_moved:
            playerMovedBubbleSpawn()
            if isPlayerEating(orangeFish):
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
            playerMovedBubbleSpawn()

            if isPlayerEating(orange):
                how_many_oranges_ate += 1
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
        if player.headSprite.global_transform.origin.y <= -25:
            textBoxTop.visible = true
            crabSound.play()
            textBoxTopText.bbcode_text = "[center][color=red]we're just some crabs. don't fuck with us!!!\nwe'll only move if you give us a coconut[/color][/center]"
            gameState = GameState.CRAB_INTERLUDE
            coconut.visible = true
            coconutMerchant.visible = true

    elif gameState == GameState.CRAB_INTERLUDE:
        prevGameState = gameState
        updateGameCamera(delta, Vector2(0, 0), Vector2(0, -45))
        if has_player_moved:
            playerMovedBubbleSpawn()
            if isPlayerEating(orange):
                how_many_oranges_ate += 1
                player.eatAnOrange()
                chompSound.pitch_scale = rand_range(0.8, 1.2)
                chompSound.play()
                for i in range(3):
                    spawnBubble(player.headSprite.global_transform.origin, i + 1)
                orange.visible = false
            for i in crabsNode.get_child_count():
                var crab = crabsNode.get_child(i)
                if isPlayerHeadCollidingWith(crab.get_node("Sprite3D")):
                    owSound.pitch_scale = rand_range(0.4, 0.6)
                    owSound.play()
                    deathOverlay.visible = false
                    deathOverlay.color.a = 0.3
                    prevTextBoxVisible = textBox.visible
                    prevTextBoxTopVisible = textBoxTop.visible
                    death_counter += 1
                    gameState = GameState.GAME_OVER
                    causeOfDeathStr = "got crabbed"
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
                causeOfDeathStr = "got BIG CRABBED"

            if not creeped_out_coconut_merchant and isPlayerEating(coconutMerchant):
                textBoxTop.visible = false
                heySound.pitch_scale = 0.5
                heySound.play()
                textBox.visible = true
                textBoxText.bbcode_text = "[center]uhh.. i'm sorry, i don't feel the same way..[/center]"
                sin_counter += 2
                if sin_counter >= 16:
                    creeped_out_coconut_merchant = true
                    textBoxText.bbcode_text = "[center]okay.. i'm gonna go...[/center]"
            elif isPlayerEating(coconut):
                coconut.visible = false
                coconutChompSound.play()
                player.eatACoconut()
                textBox.visible = false
            elif player.headSprite.global_transform.origin.y >= -15 and not creeped_out_coconut_merchant:
                move_counter_at_last_game_state = move_counter
                textBoxTop.visible = false
                if not textBox.visible:
                    if coconut.visible:
                        whatsupSound.pitch_scale = rand_range(1.1, 1.3)
                        whatsupSound.play()
                    else:
                        heyUpsetSound.pitch_scale = rand_range(1.4, 1.6)
                        heyUpsetSound.play()
                textBox.visible = true
                if coconut.visible:
                    textBoxText.bbcode_text = "[center]i'm a monkey-maid. yes, we exist.\nwanna buy a coconut?[/center]"
                elif player.has_coconut_in_mouth:
                    textBoxText.bbcode_text = "[center]you gonna pay for that bub?[/center]"
            elif player.headSprite.global_transform.origin.y <= -25:
                move_counter_at_last_game_state = move_counter
                textBox.visible = false
                if not textBoxTop.visible:
                    crabSound.pitch_scale = rand_range(0.9, 1.1)
                    crabSound.play()
                    textBoxTop.visible = true
                    if not player.has_coconut_in_mouth:
                        textBoxTopText.bbcode_text = "[center][color=red]we're just some crabs. don't fuck with us!!!\nwe'll only move if you give us a coconut[/color][/center]"
                    elif player.has_coconut_in_mouth:
                        textBoxTopText.bbcode_text = "[center][color=red]oh shit! you got a [color=#9e5b47]coconut[/color].\nspit that sucker out with[/color] [wave]X[/wave] [color=red]or[/color] [wave]Space[/wave][/center]"
            else:
                if move_counter > move_counter_at_last_game_state + 3:
                    textBox.visible = false
                    textBoxTop.visible = false
        if creeped_out_coconut_merchant and coconutMerchant.visible:
            coconutMerchant.global_transform.origin.x += (delta*4)
            coconutMerchant.global_transform.origin.y += (delta*4)
            if coconutMerchant.global_transform.origin.x >= 9:
                coconutMerchant.visible = false
        if Input.is_action_just_pressed("ui_select"):
            player.spitCoconutProjectile()

    elif gameState == GameState.COCONUT_CRAB_TIME:
        prevGameState = gameState
        updateGameCamera(delta, Vector2(0, 0), Vector2(0, -45))
        if has_player_moved:
            playerMovedBubbleSpawn()
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
                else:
                    causeOfDeathStr = "got BIG CRABBED"
            for i in crabsNode.get_child_count():
                var crab = crabsNode.get_child(i)
                if not crab.visible:
                    continue
                elif has_died_to_coconut_crab and crab.get_node("Sprite3D").start_frame == 8:
                    crab.get_node("Sprite3D").frame_delay = 0.1
                    if player.headSprite.global_transform.origin.x >= crab.get_node("Sprite3D").global_transform.origin.x:
                        crab.get_node("Sprite3D").global_transform.origin.x -= 1
                    else:
                        crab.get_node("Sprite3D").global_transform.origin.x += 1
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

                if crab.get_node("Sprite3D").global_transform.origin.x < -9 or crab.get_node("Sprite3D").global_transform.origin.x > 9:
                    crab.visible = false

            if move_counter > move_counter_at_last_game_state + 2:
                textBox.visible = false
                textBoxTop.visible = false
        if Input.is_action_just_pressed("ui_select"):
            player.spitCoconutProjectile()
    elif gameState == GameState.GAME_OVER:
        textBoxTop.visible = false
        if not deathOverlay.visible:
            deathOverlay.visible = true
            deathOverlayText.bbcode_text = "[center]you died...[/center]\ncause of death:\n    [color=red][shake]" + causeOfDeathStr + "[/shake][/color]\n\ntry again? press ENTER"
        deathOverlay.color.a += 0.2 * delta
        if deathOverlay.color.a > 1:
            deathOverlay.color.a = 1

        if Input.is_action_just_pressed("ui_accept"):
            player.restoreBodyPartPositions()
            deathOverlay.visible = false
            deathOverlay.color.a = 0
            gameState = prevGameState
            textBoxTop.visible = prevTextBoxTopVisible
            textBox.visible = prevTextBoxVisible

            if prevGameState == GameState.CRAB_INTERLUDE:
                textBoxTop.visible = true
                textBoxTopText.bbcode_text = "[color=red]we told you not to fuck with us man[/color]"
                textBox.visible = false
                crabSound.play()
            elif prevGameState == GameState.COCONUT_CRAB_TIME and has_died_to_coconut_crab:
                textBoxTop.visible = true
                if causeOfDeathStr == "got BIG COCONUT CRABBED":
                    textBoxTopText.bbcode_text = "[color=red]sorry puny one,\ni am comfortable here.[/color]"
                else:
                    textBoxTopText.bbcode_text = "[color=red]oh, wait, you want us to move?\n sorry, sorry.[/color]"
                textBox.visible = false
                crabSound.play()

        
func playerMovedBubbleSpawn():
    random_bubble_timer = 0
    bubbleSound.pitch_scale = rand_range(0.8, 1.2)
    bubbleSound.play()
    for i in range(2):
        spawnBubble(player.headSprite.global_transform.origin, i)

func isPlayerHeadCollidingWith(target, lb = -0.5, tb = 0.5, rb = 0.5, bb = -0.5):
    var pos = player.headSprite.global_transform.origin
    var tPos = target.global_transform.origin
    return pos.x > tPos.x + lb and pos.x < tPos.x + rb and pos.y > tPos.y + bb and pos.y < tPos.y + tb

func isPlayerEating(sprite):
    if not sprite.visible:
        return false
    return sprite.global_transform.origin.x == player.headSprite.global_transform.origin.x and sprite.global_transform.origin.y == player.headSprite.global_transform.origin.y
    
func doesIntersectWithAnyBodyPart(sprite):
    var spritePos = sprite.global_transform.origin
    for i in range(len(player.myBodyParts)):
        var bodyPart = player.myBodyParts[i]
        var bodyPartPos = bodyPart.global_transform.origin
        if spritePos.x == bodyPartPos.x and spritePos.y == bodyPartPos.y:
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

func spawnBubble(pos, time_to_yield = 0):
    if time_to_yield > 0:
        yield(get_tree().create_timer(0.1*time_to_yield), "timeout")
    var newBubble = bubbleRes.instance()
    self.add_child(newBubble)
    newBubble.global_transform.origin = pos
    newBubble.global_transform.origin.y += rand_range(0.3, 0.8)
    newBubble.global_transform.origin.x += rand_range(-0.5, 0.5)
    if randi() % 2 <= 1:
        newBubble.which_x = -1

func updateGameCamera(delta, x_bounds, y_bounds):
    camera.size = camera.size + (adventure_size - camera.size) * (delta*5)
    if stepify(camera.size, 0.1) == stepify(adventure_size, 0.1):
        camera.size = adventure_size
    if should_snap_camera:
        camera.global_transform.origin = player.cameraTarget.global_transform.origin
    elif camera.size == adventure_size:
        camera.global_transform.origin = camera.global_transform.origin + (player.cameraTarget.global_transform.origin - camera.global_transform.origin) * (delta*2)
        if stepify(camera.global_transform.origin.x, 0.1) == stepify(player.cameraTarget.global_transform.origin.x, 0.1) and stepify(camera.global_transform.origin.y, 0.1) == stepify(player.cameraTarget.global_transform.origin.y, 0.1):
            # should_snap_camera = true
            pass
        if camera.global_transform.origin.x > x_bounds.y:
            camera.global_transform.origin.x = x_bounds.y
        elif camera.global_transform.origin.x < x_bounds.x:
            camera.global_transform.origin.x = x_bounds.x
        if camera.global_transform.origin.y < y_bounds.y:
            camera.global_transform.origin.y = y_bounds.y
        elif camera.global_transform.origin.y > y_bounds.x:
            camera.global_transform.origin.y = y_bounds.x
        
