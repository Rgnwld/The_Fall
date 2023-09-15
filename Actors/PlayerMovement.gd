extends CharacterBody2D

@export var RUN_SPEED = 300.0
@export var JUMP_FORCE = -400.0
@export var BULLET_FORCE = 1000

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var isJumping = false

var bulletPath := preload("res://Items/bullet.tscn")


@onready var anim := $anim as AnimatedSprite2D
@onready var gunObject = $Gun as Node2D
@onready var bulletPosition := $Gun/Marker2D

func mouseInput(): 
	gunObject.look_at(get_global_mouse_position())
	if(Input.is_action_just_pressed("ui_mouse_0")):
		print("shoot")
		var bulletInstance = bulletPath.instantiate()
		get_parent().add_child(bulletInstance)
		bulletInstance.position = $Gun/Marker2D.global_position
		bulletInstance.linear_velocity = (get_global_mouse_position() - bulletInstance.position).normalized() * BULLET_FORCE
		bulletInstance.look_at(get_global_mouse_position())

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	#Handle mouse input
	mouseInput()

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		isJumping = true
	elif is_on_floor():
		isJumping = false	
	
	if abs(velocity.x) > 0 && !isJumping:
		anim.play("run")
	elif isJumping:
		anim.play("jump")
	else:
		anim.play("idle")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * RUN_SPEED
		anim.scale.x = abs(anim.scale.x) * sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, RUN_SPEED)

	move_and_slide()
