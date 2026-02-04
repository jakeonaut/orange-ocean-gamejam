extends Spatial

onready var mySprite = get_node("Sprite3D")
var y_speed = 0.1
var y_acc = 0.1
var y_max_speed = 0.5
var which_x = 1
var x_speed = 0.1
var x_acc = 0.1
var x_max_speed = 0.5

var opacity = 0.9
func _ready():
  set_process(true)
  opacity = mySprite.opacity

func _process(delta):
  opacity -= (delta)
  mySprite.opacity = opacity if opacity >= 0 else 0
  if opacity <= 0:
    queue_free()

  global_transform.origin.x += which_x * x_speed * (delta*11)
  global_transform.origin.y += y_speed * (delta*11)

  if which_x > 0:
    x_speed += x_acc * (delta*11)
    if x_speed >= x_max_speed:
      x_speed = x_max_speed
      which_x = -1
  elif which_x < 0:
    x_speed -= x_acc * (delta*11)
    if x_speed <= -x_max_speed:
      x_speed = x_max_speed
      which_x = 1

  if y_speed < y_max_speed:
    y_speed += y_acc * (delta*11)
    if y_speed >= y_max_speed:
      y_speed = y_max_speed