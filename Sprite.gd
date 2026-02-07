extends Sprite3D

var animation_counter = 0
export var frame_delay = 0.4
var original_frame_delay = 0
# If true, this will override frame_delay after first frame change.
export var should_randomize_frame_delay = false
var start_frame = 0
var base_frame = start_frame
export var max_frames = 2

var has_finished_animation = false
var repeat_animation = true

var facing = Vector2(1, 0)
var is_rotating = false
export var should_fizzle_out = false
var should_soft_fizzle_out = false
export var should_animate = true # set this to false if you handle animation through an AnimationPlayer
export var reversed = false
export var is_exempt_from_time_dilation = false

export(String, FILE) var overwritten_green_palette_path = null
var overwritten_green_palette = null
export(String, FILE) var overwritten_yellow_palette_path = null
var overwritten_yellow_palette = null

var should_fly_somewhere = false
var should_fly_fizzle_out = false
var has_reached_fly_dest = false
var fly_pos = Vector3(0, 0, 0)
var fly_speed = 11

func _ready():
    set_process(true)
    start_frame = get_frame()
    original_frame_delay = frame_delay

    var should_duplicate_material = false
    if overwritten_green_palette_path != null:
        overwritten_green_palette = load(overwritten_green_palette_path)
        should_duplicate_material = true
    if overwritten_yellow_palette_path != null:
        overwritten_yellow_palette = load(overwritten_yellow_palette_path)
        should_duplicate_material = true

    if should_duplicate_material and material_override:
        pass
        material_override = material_override.duplicate()

func changeSpriteColorPalette(palette, palette_name = ""):
    if material_override:
        var material = material_override
        if material is ShaderMaterial:
            if palette_name == "green_palette" and overwritten_green_palette != null: # whateva
                palette = overwritten_green_palette
            if palette_name == "yellow_palette" and overwritten_yellow_palette != null: # whateva
                palette = overwritten_yellow_palette
            material.set_shader_param("target_palette", palette)
            material_override = material

func preProcess():
    pass

func _process(delta):
    preProcess()
    if visible and should_animate:
        animate(delta)

    if should_fly_somewhere and not has_reached_fly_dest:
        global_transform.origin.x = global_transform.origin.x + (fly_pos.x - global_transform.origin.x) * (delta*fly_speed)
        global_transform.origin.y = global_transform.origin.y + (fly_pos.y - global_transform.origin.y) * (delta*fly_speed)
        if stepify(global_transform.origin.x, 0.1) == stepify(fly_pos.x, 0.1) and stepify(global_transform.origin.y, 0.1) == stepify(fly_pos.y, 0.1):
            has_reached_fly_dest = true
        

func trySetFrame(next_frame):
    if not reversed:
        if next_frame < hframes * vframes and (is_really_glitchy or next_frame < start_frame + max_frames):
            set_frame(next_frame)
            return true
        set_frame((hframes * vframes) - 1)
        return false
    elif reversed:
        if next_frame >= 0 and (is_really_glitchy or next_frame > start_frame - max_frames):
            set_frame(next_frame)
            return true
        set_frame(0)
        return false

func restart():
    animation_counter = 0
    trySetFrame(start_frame)

func randomizeFrame():
    animation_counter = 0
    trySetFrame(randi() % int(min(max_frames, hframes * vframes)))
    
export var is_really_glitchy = false
func animate(delta):
    if max_frames == 1:
        return

    animation_counter += delta
    if animation_counter >= frame_delay:
        animation_counter = 0
        var frame = get_frame()
        var next_frame = frame + 1 if not reversed else frame - 1
        if not trySetFrame(next_frame):
            if should_fizzle_out or should_fly_fizzle_out and has_reached_fly_dest:
                queue_free()
            elif should_soft_fizzle_out:
                visible = false
            else:
                trySetFrame(start_frame)
        
        if should_randomize_frame_delay:
            randomizeFrameDelay()

func reverseIt():
    if reversed:
        reversed = false
        start_frame += max_frames
    else:
        reversed = true
        start_frame -= max_frames
            

func randomizeFrameDelay():
    frame_delay = rand_range(original_frame_delay/4, original_frame_delay*2.2)

func updateBaseFrame(hframe, vframe):
    start_frame = (self.hframes * vframe) + hframe
    base_frame = start_frame
    trySetFrame(start_frame)
    restart()

func updateBaseFrameWithStartFrame(startFrame):
    start_frame = startFrame
    base_frame = start_frame
    trySetFrame(start_frame)
    restart()

func isHorizontal():
    return facing.y == 0 and (facing.x > 0 or facing.x < 0)

func isVertical():
    return facing.x == 0 and (facing.y > 0 or facing.y < 0)
