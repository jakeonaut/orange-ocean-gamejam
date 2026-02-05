extends Spatial

onready var level = get_tree().get_root().get_node("level")
onready var aniPlayer = get_node("AnimationPlayer")
onready var clonkSound = get_node("ClonkSound")
onready var weakRicochetSound = get_node("WeakRicochetSound")
onready var mySprite = get_node("Sprite3D")

var facing = Vector2(1, 0)
var facingAcc = Vector2(0, 0)
var opacity = 1
var is_ricocheting = false

func _ready():
    set_process(true)

func _process(delta):
    facing += facingAcc * (delta * 10)
    self.global_transform.origin.x += (facing.x * (delta*10))
    self.global_transform.origin.y += (facing.y * (delta*10))
    if is_ricocheting:
        opacity -= (delta * 3)
        if opacity < 0: queue_free()
        return
    else:
        opacity -= (delta * 2)
        if opacity < 0: queue_free()
    mySprite.opacity = opacity

    if level.coconutMerchant.visible: # and not level.coconutMerchant.is_stunned:
        if didCollideWithTarget(level.coconutMerchant):
            activateRicochet()
            if level.coconutMerchant.is_stunned:
                level.sin_counter += 1
            else:
                level.sin_counter += 5
            level.coconutMerchant.is_stunned = true
            level.coconutMerchant.mySprite.rotation_degrees.z = 90
            yield(get_tree().create_timer(0.1), "timeout")
            level.owSound.pitch_scale = rand_range(0.9, 1.1)
            level.owSound.play()

    if didCollideWithTarget(level.bigCrab.get_node("Sprite3D"), -2, 1.5, 2, -1.5):
        if level.bigCrab.get_node("Sprite3D").start_frame == 8:
            activateRicochet()
            weakRicochetSound.pitch_scale = rand_range(0.8, 1.2)
            weakRicochetSound.play()
            level.textBox.visible = false
            level.textBoxTop.visible = true
            level.textBoxTopText.bbcode_text = "[wave]this puny weapon cannot harm me[/wave]"
            level.move_counter_at_last_game_state = level.move_counter
        else:
            if level.gameState == level.GameState.CRAB_INTERLUDE:
                level.gameState = level.GameState.COCONUT_CRAB_TIME
            level.bigCrab.get_node("Sprite3D").updateBaseFrame(2, 1)
            level.equipCoconutSound.pitch_scale = rand_range(0.6, 0.8)
            level.equipCoconutSound.play()
            level.textBox.visible = false
            level.textBoxTop.visible = true
            level.textBoxTopText.bbcode_text = "[wave]thank you puny creature.[/wave]"
            level.move_counter_at_last_game_state = level.move_counter
            queue_free()
    for i in level.crabsNode.get_child_count():
        var crab = level.crabsNode.get_child(i)
        if didCollideWithTarget(crab.get_node("Sprite3D")):
            if crab.get_node("Sprite3D").start_frame == 8:
                activateRicochet()
                weakRicochetSound.pitch_scale = rand_range(1.4, 1.6)
                weakRicochetSound.play()
                level.textBox.visible = false
                level.textBoxTop.visible = true
                level.textBoxTopText.bbcode_text = "[wave]i already got one bro[/wave]"
                level.move_counter_at_last_game_state = level.move_counter
            else:
                if level.gameState == level.GameState.CRAB_INTERLUDE:
                    level.gameState = level.GameState.COCONUT_CRAB_TIME
                crab.get_node("Sprite3D").updateBaseFrame(2, 1)
                level.equipCoconutSound.pitch_scale = rand_range(0.8, 1.2)
                level.equipCoconutSound.play()
                level.textBox.visible = false
                level.textBoxTop.visible = true
                level.textBoxTopText.bbcode_text = "[wave]hell yeah.[/wave]"
                level.move_counter_at_last_game_state = level.move_counter
                queue_free()
        # if isPlayerEating(crab.get_node("Sprite3D")):
        #     owSound.pitch_scale = rand_range(0.4, 0.6)
        #     owSound.play()
        #     deathOverlay.visible = false
        #     deathOverlay.color.a = 0.3
        #     prevTextBoxVisible = textBox.visible
        #     prevTextBoxTopVisible = textBoxTop.visible
        #     gameState = GameState.GAME_OVER
        #     causeOfDeathStr = "got crabbed"

func didCollideWithTarget(target, lb = -1, tb = 1, rb = 1, bb = -1):
    var pos = self.global_transform.origin
    var tPos = target.global_transform.origin
    return pos.x > tPos.x + lb and pos.x < tPos.x + rb and pos.y > tPos.y + bb and pos.y < tPos.y + tb

func activateRicochet():
    facing = -facing
    if facing.x == 0:
        facingAcc.x = -1
        facing.x = 1
    elif facing.y == 0:
        facingAcc.y = -1
        facing.y = 1
    clonkSound.play()
    opacity = 1.0
    is_ricocheting = true
