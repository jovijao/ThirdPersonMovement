extends CharacterBody3D

@export var camera_pivot_ver: Node3D 
@export var camera_pivot_hor : Node3D
@export var camera : Camera3D
@onready var model : Node3D = $Model
@export var sensibility = 0.002
@export var speed = 4.2
@export var gravity_force = 10.0
@export var jump_force = 4.2

var may_jump = false
var can_jump = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
	var input = get_input()
	
	if input != Vector2.ZERO:
		model.rotation.y = lerp_angle(model.rotation.y, -input.angle(), 4 * delta)
	
	velocity.x = get_input().x * speed
	velocity.z = get_input().y * speed
	gravity(delta)
	jump()
	move_and_slide()

func jump():
	if Input.is_action_just_pressed("jump"):
		may_jump = true
		$JumpBufferTimer.start()
	
	if is_on_floor():
		can_jump = true
	elif can_jump and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()
	
	if may_jump and can_jump:
		velocity.y = jump_force

func gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity_force * delta
	else:
		velocity.y = -gravity_force/10


func get_input():
	return Input.get_vector("left", "right", "foward", "backward").rotated(-camera_pivot_hor.rotation.y)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_pivot_hor.rotation.y -= event.relative.x * sensibility
		camera_pivot_ver.rotation.x -= event.relative.y * sensibility
		
		camera_pivot_ver.rotation_degrees.x = clamp(
			camera_pivot_ver.rotation_degrees.x, -90.0, 90.0)
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_coyote_timer_timeout():
	can_jump = false


func _on_jump_buffer_timer_timeout():
	may_jump = false
