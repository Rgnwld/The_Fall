extends Camera2D

@export var max_camera_distance = 2 as float
@export var smoothness = 0.125 as float
@export var camera_offset = Vector2(0,0)

@onready var player = $".."

func _physics_process(delta):
	var target_position = player.global_position
	var direction = target_position - get_global_mouse_position() 
#	var direction = get_global_mouse_position() - target_position 

	if direction.length() < 0:
		direction = direction.normalized() * 0

	if direction.length() > max_camera_distance:
		direction = direction.normalized() * max_camera_distance
	
	var desired_position = target_position - direction
	var offset_position = desired_position + camera_offset
	var smoothed_position = lerp(global_position, offset_position, smoothness)
	global_position = smoothed_position
