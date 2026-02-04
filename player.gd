extends Spatial

onready var level = get_tree().get_root().get_node("level")
onready var headSprite = get_node("headSprite")
onready var pfftSound = get_node("PfftSound")
onready var growSound = get_node("GrowSound")

var should_advance_animation_frame = false
var myBodyParts = []
func _ready():
    myBodyParts = [headSprite]

var should_grow = false
func eatAnOrange():
    should_grow = true

func moveUp():
    if should_grow: grow(0, 1)
    headSprite.global_transform.origin.y += 1
    moveMyBodyParts(0, 1)
    faceUp(headSprite)
    should_advance_animation_frame = not should_advance_animation_frame
func moveDown():
    if should_grow: grow(0, -1)
    headSprite.global_transform.origin.y -= 1
    moveMyBodyParts(0, -1)
    faceDown(headSprite)
    should_advance_animation_frame = not should_advance_animation_frame
func moveLeft():
    if should_grow: grow(-1, 0)
    headSprite.global_transform.origin.x -= 1
    moveMyBodyParts(-1, 0)
    faceLeft(headSprite)
    should_advance_animation_frame = not should_advance_animation_frame
func moveRight():
    if should_grow: grow(1, 0)
    headSprite.global_transform.origin.x += 1
    moveMyBodyParts(1, 0)
    faceRight(headSprite)
    should_advance_animation_frame = not should_advance_animation_frame

func grow(_x, _y):
    headSprite.updateBaseFrame(2, 0)
    var newBodySprite = headSprite.duplicate()
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

func faceUp(sprite):
    sprite.rotation_degrees.z = 90
    sprite.flip_v = false
    sprite.flip_h = false
func faceDown(sprite):
    sprite.rotation_degrees.z = -90
    sprite.flip_v = false
    sprite.flip_h = false
func faceLeft(sprite):
    sprite.rotation_degrees.z = 0
    sprite.flip_v = false
    sprite.flip_h = true
func faceRight(sprite):
    sprite.rotation_degrees.z = 0
    sprite.flip_v = false
    sprite.flip_h = false