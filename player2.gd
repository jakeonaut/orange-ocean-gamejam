extends Spatial

onready var level = get_tree().get_root().get_node("level")
var coconutProjectileRes = preload("res://coconutProjectile.tscn")
var playerSheetRes = preload("res://player_sheet.png")
var playerCoconutSheetRes = preload("res://player_sheet_coconut.png")
var text3dRes = preload("res://3DText.tscn")
onready var headSprite = get_node("headSprite")
onready var parasite = get_node("parasite")
var facing = Vector2(1, 0)
var prevFacing = Vector2(1, 0)
var should_advance_animation_frame = false
var myBodyParts = []
var prevBodyPartsStates = []

var coolTexts = ["second best!", "silver (for second)!", "player 2!", "this is another fish!"]
var smallComboCoolTexts = ["combo (2)?!?", "you go boy!!!", "pets club 2!!!", "2 is a-okay!!!", "2 time!!"]
var bigComboCoolTexts = ["I ACTUALLY CAN BELIEVE IT!!!!!", "YOU ARE A FISH APPRENTICE!!!!!", "SIS YOU GOTTA TEACH ME HOW TO DO THAT!!!!", "WOLF EEL MODE ACTIVATED!!!!", "22222222?!?!?"]

func _ready():
    myBodyParts = [headSprite]

var should_grow = 0
func eatAHeartFruit():
    level.how_many_heart_fruit_ate += 1
    should_grow = 2

var how_many_times_did_i_grow = 0

func moveUp(ignore_the_rules = false):
    if not ignore_the_rules and myBodyParts.size() > 1 and facing.y < 0:
        maybeAdvanceBodyPartAnimationFrames()
        should_advance_animation_frame = not should_advance_animation_frame
        level.errorSound.play()
        return false
    if should_grow > 0: grow(0, 1)
    saveBodyPartPositions()
    facing = Vector2(0, 1)
    headSprite.global_transform.origin.y += 1
    moveMyBodyParts(0, 1)
    faceUp(headSprite)
    tryToBeCool()
    should_advance_animation_frame = not should_advance_animation_frame
    return true
func moveDown(ignore_the_rules = false):
    if not ignore_the_rules and myBodyParts.size() > 1 and facing.y > 0:
        maybeAdvanceBodyPartAnimationFrames()
        should_advance_animation_frame = not should_advance_animation_frame
        level.errorSound.play()
        return false
    if should_grow > 0: grow(0, -1)
    saveBodyPartPositions()
    facing = Vector2(0, -1)
    headSprite.global_transform.origin.y -= 1
    moveMyBodyParts(0, -1)
    faceDown(headSprite)
    tryToBeCool()
    should_advance_animation_frame = not should_advance_animation_frame
    return true
func moveLeft(ignore_the_rules = false):
    if not ignore_the_rules and myBodyParts.size() > 1 and facing.x > 0:
        maybeAdvanceBodyPartAnimationFrames()
        should_advance_animation_frame = not should_advance_animation_frame
        level.errorSound.play()
        return false
    if should_grow > 0: grow(-1, 0)
    saveBodyPartPositions()
    facing = Vector2(-1, 0)
    headSprite.global_transform.origin.x -= 1
    moveMyBodyParts(-1, 0)
    faceLeft(headSprite)
    tryToBeCool()
    should_advance_animation_frame = not should_advance_animation_frame
    return true
func moveRight(ignore_the_rules = false):
    if not ignore_the_rules and myBodyParts.size() > 1 and facing.x < 0:
        maybeAdvanceBodyPartAnimationFrames()
        should_advance_animation_frame = not should_advance_animation_frame
        level.errorSound.play()
        return false
    if should_grow > 0: grow(1, 0)
    saveBodyPartPositions()
    facing = Vector2(1, 0)
    headSprite.global_transform.origin.x += 1
    moveMyBodyParts(1, 0)
    faceRight(headSprite)
    tryToBeCool()
    should_advance_animation_frame = not should_advance_animation_frame
    return true

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
    if how_many_times_did_i_grow >= level.FINAL_NUMBER_OF_ORANGES:
      level.heartFruit.visible = false
      should_grow = 0
      return
    # TODO(jaketrower): This _x, _y should be set according to the direction that the LAST PREVIOUS BODY PART is moving.
    # so, it will be accurate for the first growth, but not subsequent growths rn
    headSprite.updateBaseFrame(2, 0)
    var newBodySprite = headSprite.duplicate()
    newBodySprite.name = "bodySprite"
    self.add_child(newBodySprite)
    newBodySprite.global_transform.origin = myBodyParts[len(myBodyParts) - 1].global_transform.origin + Vector3(-_x, -_y, -0.05)
    newBodySprite.updateBaseFrame(0, 1)
    newBodySprite.modulate.r = 1
    newBodySprite.modulate.b = 1
    newBodySprite.scale = Vector3(1, 1, 1)
    myBodyParts.push_back(newBodySprite)
    should_grow -= 1
    if should_grow < 0:
      should_grow = 0
    # growSound.pitch_scale = rand_range(0.8, 1.2)
    # growSound.play()
    yield(get_tree().create_timer(0.3), "timeout")
    level.player.pfftSound.pitch_scale = rand_range(0.8, 1.2)
    level.player.pfftSound.play()
    for i in range(2):
        level.spawnBubble(newBodySprite.global_transform.origin, i)
    how_many_times_did_i_grow += 1

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
    if prevBodyPartsStates.size() == 0:
      return
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
    if was_i_cool_this_time:
        var newAwesomeText = text3dRes.instance()
        level.add_child(newAwesomeText)
        var textArrayToUse = coolTexts
        if level.combo_counter > 0 and level.combo_counter < 4:
            textArrayToUse = smallComboCoolTexts
        elif level.combo_counter >= 4:
            textArrayToUse = bigComboCoolTexts

        var textToUse = textArrayToUse[randi() % len(textArrayToUse)]
        level.player2_trick_counter += 1
        level.player2_combo_counter += 1
        if level.player2_combo_counter > 1:
            textToUse = "+" + str(level.player2_combo_counter) + " " + textToUse
        var got_a_new_highscore = false
        if level.player2_combo_counter > level.player2_max_combo:
            level.player2_max_combo = level.player2_combo_counter
            if level.player2_combo_counter > 1:
                textToUse = textToUse + "\nnew player 2 score!!!"
                got_a_new_highscore = true
        newAwesomeText.get_node("Label3D").text = textToUse
        newAwesomeText.global_transform.origin = headSprite.global_transform.origin + Vector3(0, 0, 5.5)
        if got_a_new_highscore:
            level.applauseSound.play()
        else:
            level.coolSound.pitch_scale = rand_range(0.8, 1.2)
            level.coolSound.play()
    else:
        level.player2_combo_counter -= 1
        if level.player2_combo_counter <= 0:
            level.player2_combo_counter = 0

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
