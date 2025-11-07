@tool
class_name Player
extends CharacterBody2D

const _PLAYER_ACTIONS = {
	Global.Player.ONE:
	{
		"jump": "player_1_jump",
		"left": "player_1_left",
		"right": "player_1_right",
	},
	Global.Player.TWO:
	{
		"jump": "player_2_jump",
		"left": "player_2_left",
		"right": "player_2_right",
	},
}

@export var player: Global.Player = Global.Player.ONE
@export_range(0, 1000, 10, "suffix:px/s") var speed: float = 500.0
@export_range(0, 5000, 1000, "suffix:px/s²") var acceleration: float = 5000.0
@export_range(-1000, 1000, 10, "suffix:px/s") var jump_velocity = -880.0
@export_range(0, 100, 5, "suffix:%") var jump_cut_factor: float = 20
@export_range(0, 0.5, 1 / 60.0, "suffix:s") var coyote_time: float = 5.0 / 60.0
@export_range(0, 0.5, 1 / 60.0, "suffix:s") var jump_buffer: float = 5.0 / 60.0
@export var double_jump: bool = false

var coyote_timer: float = 0
var jump_buffer_timer: float = 0
var double_jump_armed: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var original_position: Vector2

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():

	if Engine.is_editor_hint():
		set_process(false)
		set_physics_process(false)
	else:
		Global.gravity_changed.connect(_on_gravity_changed)
		Global.lives_changed.connect(_on_lives_changed)

	original_position = position


func _on_gravity_changed(new_gravity):
	gravity = new_gravity


func _jump():
	velocity.y = jump_velocity
	coyote_timer = 0
	jump_buffer_timer = 0
	if double_jump_armed:
		double_jump_armed = false
	elif double_jump:
		double_jump_armed = true


func stomp():
	double_jump_armed = false
	_jump()


func _player_just_pressed(action):
	if player == Global.Player.BOTH:
		return (
			Input.is_action_just_pressed(_PLAYER_ACTIONS[Global.Player.ONE][action])
			or Input.is_action_just_pressed(_PLAYER_ACTIONS[Global.Player.TWO][action])
		)
	return Input.is_action_just_pressed(_PLAYER_ACTIONS[player][action])


func _player_just_released(action):
	if player == Global.Player.BOTH:
		return (
			Input.is_action_just_released(_PLAYER_ACTIONS[Global.Player.ONE][action])
			or Input.is_action_just_released(_PLAYER_ACTIONS[Global.Player.TWO][action])
		)
	return Input.is_action_just_released(_PLAYER_ACTIONS[player][action])


func _get_player_axis(action_a, action_b):
	if player == Global.Player.BOTH:
		return clamp(
			(
				Input.get_axis(
					_PLAYER_ACTIONS[Global.Player.ONE][action_a],
					_PLAYER_ACTIONS[Global.Player.ONE][action_b]
				)
				+ Input.get_axis(
					_PLAYER_ACTIONS[Global.Player.TWO][action_a],
					_PLAYER_ACTIONS[Global.Player.TWO][action_b]
				)
			),
			-1,
			1
		)
	return Input.get_axis(_PLAYER_ACTIONS[player][action_a], _PLAYER_ACTIONS[player][action_b])


func _physics_process(delta):
	if not Global.game_started_flag:
		return

	if Global.lives <= 0:
		return

	if is_on_floor():
		coyote_timer = coyote_time + delta
		double_jump_armed = false

	if _player_just_pressed("jump"):
		jump_buffer_timer = jump_buffer + delta

	if jump_buffer_timer > 0 and (double_jump_armed or coyote_timer > 0):
		_jump()

	if _player_just_released("jump") and velocity.y < 0:
		velocity.y *= (1 - (jump_cut_factor / 100.0))

	if coyote_timer <= 0:
		velocity.y += gravity * delta

	var direction = _get_player_axis("left", "right")
	if direction:
		velocity.x = move_toward(
			velocity.x,
			sign(direction) * speed,
			abs(direction) * acceleration * delta,
		)
		if direction > 0:
			$AnimatedSprite2D.scale.x = -1  # وجه لليمين
		elif direction < 0:
			$AnimatedSprite2D.scale.x = 1  # وجه لليسار
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)

	# تشغيل الأنيميشن حسب الاتجاه
	if velocity == Vector2.ZERO:
		if anim.current_animation != "idle":
			anim.play("idle")
	else:
		if direction > 0:
			if anim.current_animation != "walk_right":
				anim.play("walk_right")
		elif direction < 0:
			if anim.current_animation != "walk_left":
				anim.play("walk_left")


	move_and_slide()

	coyote_timer -= delta
	jump_buffer_timer -= delta


func reset():
	position = original_position
	velocity = Vector2.ZERO
	coyote_timer = 0
	jump_buffer_timer = 0


func _on_lives_changed():
	if Global.lives > 0:
		reset()
