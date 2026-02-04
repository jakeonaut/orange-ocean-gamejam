extends Spatial

onready var player = get_node("player")
onready var orange = get_node("orange")
onready var bubbleSound = get_node("BubbleSound")
onready var chompSound = get_node("ChompSound")
var bubbleRes = preload("res://bubble.tscn")
var random_bubble_timer = 0
var random_bubble_time_limit = 10

func _ready():
    set_process(true)

func _process(delta):
    var has_player_moved = false
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
        random_bubble_timer = 0
        bubbleSound.pitch_scale = rand_range(0.8, 1.2)
        bubbleSound.play()
        for i in range(2):
            spawnBubble(player.headSprite.global_transform.origin, i)
        
        if orange.global_transform.origin.x == player.headSprite.global_transform.origin.x and orange.global_transform.origin.y == player.headSprite.global_transform.origin.y:
            player.eatAnOrange()
            chompSound.pitch_scale = rand_range(0.8, 1.2)
            chompSound.play()
            for i in range(3):
                spawnBubble(player.headSprite.global_transform.origin, i + 1)
    

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