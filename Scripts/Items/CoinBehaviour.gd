extends RigidBody2D

@export var ROTATION_VELOCITY := 1.0
@export var BULLET_SPEED = 1000

@onready var anim_sprie := $AnimatedSprite2D
@onready var player := $"../Player" as CharacterBody2D

var bulletPath := preload("res://Prefabs/Items/bullet.tscn")

var next_coin_reference: Area2D
var can_ricochet = false
var coins_inside_area = []

func ricochet_towards(point): # Ricochet coin
	var direction = point - global_position
	var bulletInstance = bulletPath.instantiate() as Node2D
	bulletInstance.linear_velocity = direction.normalized() * BULLET_SPEED
	bulletInstance.position = global_position
	bulletInstance.rotation = get_angle_to(point)
	get_parent().add_child(bulletInstance)
	
func check_closest_coin(): # Check closest coin to ricochet
	var closest_coin = 9999
	for coin in coins_inside_area:
		if coin.position.distance_to(global_position) < closest_coin:
			next_coin_reference = coin


func _physics_process(_delta):
	anim_sprie.rotate(ROTATION_VELOCITY / 360)
	
	if can_ricochet:
		var ricochet_direction := Vector2(randf_range(-1,1), randf_range(-1,1)) + global_position
		print(ricochet_direction)
		
		if next_coin_reference != null:
			next_coin_reference.get_parent().freeze = true
			ricochet_direction = next_coin_reference.global_position
		
		ricochet_towards(ricochet_direction)	

func _on_body_entered(body: Node):
	if body.is_class("RigidBody2D"):
		if body.get_collision_layer_value(6): # hit bullet layer (6)
			can_ricochet = true
	queue_free()

func _on_search_area_area_entered(area): # Find other coin to ricochet
	coins_inside_area.append(area)
	check_closest_coin()
	
func _on_search_area_area_exited(area):
	coins_inside_area.erase(area)
	check_closest_coin()
