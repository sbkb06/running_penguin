class_name Enemy
extends CharacterBody2D

@export_range(0, 1000, 10, "suffix:px/s") var speed: float = 100.0
@export var player_loses_life: bool = true
@export var squashable: bool = true
@export_enum("Left:0", "Right:1") var start_direction: int = 0
@export var max_distance: float = 300.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: int
var start_position: Vector2

@onready var _sprite := $AnimatedSprite2D

func _ready():
	Global.gravity_changed.connect(_on_gravity_changed)
	direction = -1 if start_direction == 0 else 1
	start_position = position
	_sprite.play("walk")

func _physics_process(delta):
	if not Global.game_started_flag:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	# تحريك العدو
	velocity.x = direction * speed
	move_and_slide()

	# عكس الاتجاه إذا وصل الحد الأقصى
	if abs(position.x - start_position.x) >= max_distance:
		direction *= -1

	# قلب الشكل حسب الاتجاه
	_sprite.flip_h = direction > 0

	# تشغيل الأنيميشن باستمرار
	if not _sprite.is_playing():
		_sprite.play("walk")

func _on_gravity_changed(new_gravity):
	gravity = new_gravity

func _on_hitbox_body_entered(body):
	if not body.is_in_group("players"):
		return

	if squashable and body.velocity.y > 0 and body.position.y < position.y:
		body.stomp()
		queue_free()
	elif player_loses_life and Global.game_started_flag:
		Global.lives -= 1
