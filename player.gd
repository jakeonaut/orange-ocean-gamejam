extends Spatial

onready var level = get_tree().get_root().get_node("level")
var coconutProjectileRes = preload("res://coconutProjectile.tscn")
var playerSheetRes = preload("res://player_sheet.png")
var playerCoconutSheetRes = preload("res://player_sheet_coconut.png")
var text3dRes = preload("res://3DText.tscn")
onready var headSprite = get_node("headSprite")
onready var cameraTarget = get_node("cameraTarget")
onready var pfftSound = get_node("PfftSound")
onready var growSound = get_node("GrowSound")
onready var csgCombinerPosition = get_node("CSGCombiner")
onready var coverOfDarkness = get_node("CSGCombiner/CSGMesh")
onready var playerLight = get_node("CSGCombiner/PlayerLight")
var facing = Vector2(1, 0)
var prevFacing = Vector2(1, 0)
var should_advance_animation_frame = false
var myBodyParts = []
var prevBodyPartsStates = []
var coolTexts = ["awesome!", "radical!", "groovey!", "cool!", "xD!", "nice!", "okay!", "alright!", "neat!"]
var smallComboCoolTexts = ["combo?!?", "you go girl!!!", "now that's something!!!", "now we're getting somewhere!!!", "wtf?!?", "hekck yeah!!!!"]
var bigComboCoolTexts = ["I CAN'T BELIEVE IT!!!!!", "YOU ARE A FISH MASTER!!!!!", "BRO YOU GOTTA TEACH ME HOW TO DO THAT!!!!", "CRAB MODE ACTIVATED (JK)!!!!", "WHAT IS THIS POWER?!?!?"]

func _ready():
    myBodyParts = [headSprite]

var should_grow = false
func eatAnOrange():
    level.how_many_oranges_ate += 1
    should_grow = true

func eatALemon():
    level.how_many_lemons_ate += 1
    playerLight.scale += Vector3(0.5, 0.5, 0.5)

func eatACoconut():
    var could_i_eat_the_coconut = false
    for i in range(len(myBodyParts)):
        var bodyPart = myBodyParts[i]
        if bodyPart.texture != playerCoconutSheetRes:
            bodyPart.texture = playerCoconutSheetRes
            could_i_eat_the_coconut = true
            break
    if not could_i_eat_the_coconut:
        level.owSound.pitch_scale = rand_range(0.4, 0.6)
        level.owSound.play()
        level.deathOverlay.visible = false
        level.deathOverlay.color.a = 0.3
        level.prevTextBoxVisible = level.textBox.visible
        level.prevTextBoxTopVisible = level.textBoxTop.visible
        level.death_counter += 1
        level.gameState = level.GameState.GAME_OVER
        level.died_to_coconut_overconsumption = true
        level.causeOfDeathStr = "ate too many coconuts"
    else:
        level.how_many_coconuts_ate += 1
    return could_i_eat_the_coconut

func spitCoconutProjectile():
    var has_coconut_in_mouth = false
    for i in range(len(myBodyParts), 0, -1):
        var bodyPart = myBodyParts[i - 1]
        if bodyPart.texture == playerCoconutSheetRes:
            bodyPart.texture = playerSheetRes
            has_coconut_in_mouth = true
            break
    if not has_coconut_in_mouth:
        if level.has_stolen_a_coconut:
            print("NO MORE COCONUTS")
            level.errorSound.play()
        return
    var newCoconutProjectile = coconutProjectileRes.instance()
    level.add_child(newCoconutProjectile)
    newCoconutProjectile.global_transform.origin = headSprite.global_transform.origin
    newCoconutProjectile.facing = facing
    var coconutAniPlayer = newCoconutProjectile.get_node("AnimationPlayer")
    if facing.is_equal_approx(Vector2(1, 0)): # spit right
        newCoconutProjectile.global_transform.origin += Vector3(1, 0, 0)
        coconutAniPlayer.stop()
        coconutAniPlayer.clear_queue()
        coconutAniPlayer.play("tumbleRight")
    elif facing.is_equal_approx(Vector2(-1, 0)): # spit left
        newCoconutProjectile.global_transform.origin += Vector3(-1, 0, 0)
        coconutAniPlayer.stop()
        coconutAniPlayer.clear_queue()
        coconutAniPlayer.play("tumbleLeft")
    elif facing.is_equal_approx(Vector2(0, 1)): # spit up
        newCoconutProjectile.global_transform.origin += Vector3(0, 1, 0)
        coconutAniPlayer.stop()
        coconutAniPlayer.clear_queue()
        coconutAniPlayer.play("tumbleRight")
    elif facing.is_equal_approx(Vector2(0, -1)): # spit down
        newCoconutProjectile.global_transform.origin += Vector3(0, -1, 0)
        coconutAniPlayer.stop()
        coconutAniPlayer.clear_queue()
        coconutAniPlayer.play("tumbleRight")
    level.spitSound.pitch_scale = rand_range(0.8, 1.2)
    level.spitSound.play()
    yield(get_tree().create_timer(0.1), "timeout")
    level.swooshSound.play()


func moveUp():
    if myBodyParts.size() > 1 and facing.y < 0:
        maybeAdvanceBodyPartAnimationFrames()
        should_advance_animation_frame = not should_advance_animation_frame
        print("CANNOT MOVE THAT WAY UP")
        level.errorSound.play()
        return false
    if should_grow: grow(0, 1)
    saveBodyPartPositions()
    facing = Vector2(0, 1)
    headSprite.global_transform.origin.y += 1
    moveMyBodyParts(0, 1)
    faceUp(headSprite)
    tryToBeCool()
    should_advance_animation_frame = not should_advance_animation_frame
    return true
func moveDown():
    if myBodyParts.size() > 1 and facing.y > 0:
        maybeAdvanceBodyPartAnimationFrames()
        should_advance_animation_frame = not should_advance_animation_frame
        print("CANNOT MOVE THAT WAY DOWN")
        level.errorSound.play()
        return false
    if should_grow: grow(0, -1)
    saveBodyPartPositions()
    facing = Vector2(0, -1)
    headSprite.global_transform.origin.y -= 1
    moveMyBodyParts(0, -1)
    faceDown(headSprite)
    tryToBeCool()
    should_advance_animation_frame = not should_advance_animation_frame
    return true
func moveLeft():
    if myBodyParts.size() > 1 and facing.x > 0:
        maybeAdvanceBodyPartAnimationFrames()
        should_advance_animation_frame = not should_advance_animation_frame
        print("CANNOT MOVE THAT WAY LEFT")
        level.errorSound.play()
        return false
    if should_grow: grow(-1, 0)
    saveBodyPartPositions()
    facing = Vector2(-1, 0)
    headSprite.global_transform.origin.x -= 1
    moveMyBodyParts(-1, 0)
    faceLeft(headSprite)
    tryToBeCool()
    should_advance_animation_frame = not should_advance_animation_frame
    return true
func moveRight():
    if myBodyParts.size() > 1 and facing.x < 0:
        maybeAdvanceBodyPartAnimationFrames()
        should_advance_animation_frame = not should_advance_animation_frame
        print("CANNOT MOVE THAT WAY RIGHT")
        level.errorSound.play()
        return false
    if should_grow: grow(1, 0)
    saveBodyPartPositions()
    facing = Vector2(1, 0)
    headSprite.global_transform.origin.x += 1
    moveMyBodyParts(1, 0)
    faceRight(headSprite)
    tryToBeCool()
    should_advance_animation_frame = not should_advance_animation_frame
    return true

func tryToBeCool():
    var headPos = Vector2(headSprite.global_transform.origin.x, headSprite.global_transform.origin.y)
    var was_i_cool_this_time = false
    for i in range(1, len(myBodyParts)):
        var bodyPart = myBodyParts[i]
        var bodyPos = Vector2(bodyPart.global_transform.origin.x, bodyPart.global_transform.origin.y)
        if bodyPart.frame_coords.y == 1 and headPos.is_equal_approx(bodyPos) and (
            (headSprite.isHorizontal() and bodyPart.isVertical())
            or (headSprite.isVertical() and bodyPart.isHorizontal())
        ):
            was_i_cool_this_time = true
            break
    
    # if was_i_cool_this_time:
    #     is_cool = true
    # else:
    #     is_cool = false
    if was_i_cool_this_time:
        var newAwesomeText = text3dRes.instance()
        level.add_child(newAwesomeText)
        var textArrayToUse = coolTexts
        if level.combo_counter > 0 and level.combo_counter < 5:
            textArrayToUse = smallComboCoolTexts
        elif level.combo_counter >= 5:
            textArrayToUse = bigComboCoolTexts

        var textToUse = textArrayToUse[randi() % len(textArrayToUse)]

        level.trick_counter += 1
        level.combo_counter += 1

        if level.combo_counter > 1:
            textToUse = "+" + str(level.combo_counter) + " " + textToUse
        
        var got_a_new_highscore = false
        if level.combo_counter > level.max_combo:
            level.max_combo = level.combo_counter
            if level.combo_counter > 1:
                textToUse = textToUse + "\nnew high score!!!"
                got_a_new_highscore = true

        newAwesomeText.get_node("Label3D").text = textToUse
        newAwesomeText.global_transform.origin = headSprite.global_transform.origin + Vector3(0, 0, 4)
        if got_a_new_highscore:
            level.applauseSound.play()
        else:
            level.coolSound.pitch_scale = rand_range(0.8, 1.2)
            level.coolSound.play()
    else:
        level.combo_counter = 0

func maybeAdvanceBodyPartAnimationFrames():
    for i in range(len(myBodyParts)):
        var bodyPart = myBodyParts[i]
        bodyPart.updateBaseFrameWithStartFrame(bodyPart.start_frame)
        if should_advance_animation_frame:
            bodyPart.animation_counter = bodyPart.frame_delay
            bodyPart.animate(1)
        else:
            bodyPart.animation_counter = 0

func grow(_x, _y):
    # TODO(jaketrower): This _x, _y should be set according to the direction that the LAST PREVIOUS BODY PART is moving.
    # so, it will be accurate for the first growth, but not subsequent growths rn
    headSprite.updateBaseFrame(2, 0)
    var newBodySprite = headSprite.duplicate()
    newBodySprite.name = "bodySprite"
    self.add_child(newBodySprite)
    newBodySprite.global_transform.origin = myBodyParts[len(myBodyParts) - 1].global_transform.origin + Vector3(-_x, -_y, -0.05)
    newBodySprite.updateBaseFrame(0, 1)
    myBodyParts.push_back(newBodySprite)
    should_grow = false
    # growSound.pitch_scale = rand_range(0.8, 1.2)
    # growSound.play()
    yield(get_tree().create_timer(0.3), "timeout")
    pfftSound.pitch_scale = rand_range(0.8, 1.2)
    pfftSound.play()
    for i in range(2):
        level.spawnBubble(newBodySprite.global_transform.origin, i)

func moveMyBodyParts(_x, _y):
    var x = _x
    var y = _y
    for i in range(1, len(myBodyParts)):
        var bodyPart = myBodyParts[i]
        var leadingBodyPart = myBodyParts[i-1]
        var leadingBodyPartPos = leadingBodyPart.global_transform.origin

        var oldBodyPartPos = bodyPart.global_transform.origin
        bodyPart.global_transform.origin.x = leadingBodyPart.global_transform.origin.x - x
        bodyPart.global_transform.origin.y = leadingBodyPart.global_transform.origin.y - y

        x = bodyPart.global_transform.origin.x - oldBodyPartPos.x
        y = bodyPart.global_transform.origin.y - oldBodyPartPos.y

        var trailingBodyPart = myBodyParts[i+1] if i < len(myBodyParts) - 1 else null
        if trailingBodyPart == null:
            updateBodyPartSprite(bodyPart, x, y, _x, _y, leadingBodyPartPos, oldBodyPartPos, 0)
        elif trailingBodyPart != null:
            # need to update rotation between prevBodyPart.pos and currentPos (which will be where nextBodyPart.pos will go)
            # and if it's a straight line (e.g. same X or same Y between the two), need to face/rotate correctly
            updateBodyPartSprite(bodyPart, x, y, _x, _y, leadingBodyPartPos, oldBodyPartPos, 2)

        _x = x
        _y = y
    cameraTarget.global_transform.origin = headSprite.global_transform.origin
    cameraTarget.global_transform.origin.z = 6

func updateBodyPartSprite(bodyPart, x, y, _x, _y, leadingBodyPartPos, oldBodyPartPos, x_frame):
    if leadingBodyPartPos.x == oldBodyPartPos.x or leadingBodyPartPos.y == oldBodyPartPos.y: 
        bodyPart.updateBaseFrame(x_frame, 1)
        # need to face the right direction
        if x > 0: faceRight(bodyPart)
        elif x < 0: faceLeft(bodyPart)
        elif y > 0: faceUp(bodyPart)
        elif y < 0: faceDown(bodyPart)
    elif leadingBodyPartPos.x > oldBodyPartPos.x and leadingBodyPartPos.y > oldBodyPartPos.y:
        if _x > 0:
            bodyPart.updateBaseFrame(x_frame, 2)
            faceRight(bodyPart)
        elif _y > 0:
            bodyPart.updateBaseFrame(x_frame, 3)
            faceDown(bodyPart)
    elif leadingBodyPartPos.x > oldBodyPartPos.x and leadingBodyPartPos.y < oldBodyPartPos.y: 
        if _x > 0:
            bodyPart.updateBaseFrame(x_frame, 2)
            faceRight(bodyPart)
            bodyPart.flip_v = true
        elif _y < 0:
            bodyPart.updateBaseFrame(x_frame, 2)
            faceDown(bodyPart)
    elif leadingBodyPartPos.x < oldBodyPartPos.x and leadingBodyPartPos.y > oldBodyPartPos.y:
        if _x < 0:
            bodyPart.updateBaseFrame(x_frame, 3)
            faceRight(bodyPart)
            # bodyPart.flip_v = true
        elif _y > 0:
            bodyPart.updateBaseFrame(x_frame, 2)
            faceUp(bodyPart)
    elif leadingBodyPartPos.x < oldBodyPartPos.x and leadingBodyPartPos.y < oldBodyPartPos.y:
        if _x < 0:
            bodyPart.updateBaseFrame(x_frame, 3)
            faceRight(bodyPart)
            bodyPart.flip_v = true
        elif _y < 0:
            bodyPart.updateBaseFrame(x_frame, 3)
            faceUp(bodyPart)
    if should_advance_animation_frame:
        bodyPart.animation_counter = bodyPart.frame_delay
        bodyPart.animate(1)
    else:
        bodyPart.animation_counter = 0

func saveBodyPartPositions():
    prevFacing = facing
    prevBodyPartsStates = []
    for i in range(0, len(myBodyParts)):
        var bodyPart = myBodyParts[i]
        var bodyPartPos = bodyPart.global_transform.origin
        var bodyPartFlipH = bodyPart.flip_h
        var bodyPartFlipV = bodyPart.flip_v
        var bodyPartRotation = bodyPart.rotation_degrees
        var bodyPartStartFrame = bodyPart.start_frame
        prevBodyPartsStates.push_back([bodyPartPos, bodyPartFlipH, bodyPartFlipV, bodyPartRotation, bodyPartStartFrame])

func restoreBodyPartPositions():
    print("RESTORE FACING: from: ", facing, " to: ", prevFacing)
    facing = prevFacing
    for i in range(0, len(myBodyParts)):
        var bodyPart = myBodyParts[i]
        var prevBodyPartState = prevBodyPartsStates[i]

        bodyPart.global_transform.origin = prevBodyPartState[0]
        bodyPart.flip_h = prevBodyPartState[1]
        bodyPart.flip_v = prevBodyPartState[2]
        bodyPart.rotation_degrees = prevBodyPartState[3]
        bodyPart.updateBaseFrameWithStartFrame(prevBodyPartState[4])

        if should_advance_animation_frame:
            bodyPart.animation_counter = bodyPart.frame_delay
            bodyPart.animate(1)
        else:
            bodyPart.animation_counter = 0

func faceUp(sprite):
    sprite.facing = Vector2(0, 1)
    sprite.rotation_degrees.z = 90
    sprite.flip_v = false
    sprite.flip_h = false
func faceDown(sprite):
    sprite.facing = Vector2(0, -1)
    sprite.rotation_degrees.z = -90
    sprite.flip_v = false
    sprite.flip_h = false
func faceLeft(sprite):
    sprite.facing = Vector2(-1, 0)
    sprite.rotation_degrees.z = 0
    sprite.flip_v = false
    sprite.flip_h = true
func faceRight(sprite):
    sprite.facing = Vector2(1, 0)
    sprite.rotation_degrees.z = 0
    sprite.flip_v = false
    sprite.flip_h = false
