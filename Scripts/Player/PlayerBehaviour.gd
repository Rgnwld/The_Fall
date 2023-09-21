extends CharacterBody2D

#Imports
var bulletPath := preload("res://Prefabs/Items/bullet.tscn")
var coinPath := preload("res://Prefabs/Items/coin.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var isJumping = false

var can_main_fire = true
var can_alt_fire = true

@export var RATE_OF_MAIN_FIRE = 0.4 
@export var RATE_OF_ALT_FIRE = 0.8 
@export var RUN_SPEED = 300.0
@export var JUMP_FORCE = -400.0
@export var BULLET_FORCE = 1000
@export var COIN_FORCE = 1000
@export var COIN_UP_FORCE = 200


@onready var anim := $anim as AnimatedSprite2D
@onready var gunObject = $Gun as Node2D
@onready var bulletPosition := $Gun/Marker2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	#Handle Mouse Input
	handle_mouse_input()
	#Handle Animation
	handle_animation()
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		isJumping = true
	elif is_on_floor():
		isJumping = false	


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * RUN_SPEED
		anim.scale.x = abs(anim.scale.x) * sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_SPEED)

	move_and_slide()

func handle_mouse_input(): 
	gunObject.look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("ui_mouse_0") && can_main_fire:
		can_main_fire = false
		var bulletInstance = bulletPath.instantiate()
		bulletInstance.position = $Gun/Marker2D.global_position
		bulletInstance.linear_velocity = (get_global_mouse_position() - bulletInstance.position).normalized() * BULLET_FORCE
		bulletInstance.rotation = get_angle_to(get_global_mouse_position())
		get_parent().add_child(bulletInstance)
		await (get_tree().create_timer(RATE_OF_MAIN_FIRE).timeout)
		can_main_fire = true
		
	if Input.is_action_just_pressed("ui_mouse_1") && can_alt_fire:
		can_alt_fire = false
		var coinInstance = coinPath.instantiate()
		coinInstance.position = $Gun/Marker2D.global_position
		coinInstance.linear_velocity = ((get_global_mouse_position() - coinInstance.position).normalized() * COIN_FORCE) + (Vector2.UP * COIN_UP_FORCE)
		coinInstance.rotation = get_angle_to(get_global_mouse_position())
		get_parent().add_child(coinInstance)
		await (get_tree().create_timer(RATE_OF_ALT_FIRE).timeout)
		can_alt_fire = true


func handle_animation():
		
	if abs(velocity.x) > 0 && !isJumping:
		anim.play("run")
	elif isJumping:
		anim.play("jump")
	else:
		anim.play("idle")
