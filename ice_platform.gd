@tool
class_name Ice_Platform
extends Node2D

@onready var original_position = position
@onready var _rigid_body := $RigidBody2D
@onready var _sprites := $RigidBody2D/Sprites
@onready var _collision_shape := $RigidBody2D/CollisionShape2D
@onready var _area_collision_shape := $RigidBody2D/Area2D/AreaCollisionShape2D
@onready var _animation_player := $RigidBody2D/AnimationPlayer

const SPRITE: Texture2D = preload("res://New folder/Screenshot 2025-11-03 145659.png")

## هل يمكن القفز من تحت؟
@export var one_way: bool = false:
	set = _set_one_way

## الوقت قبل سقوط المنصة بعد لمسة اللاعب
@export var fall_time: float = -1

var fall_timer: Timer
@export var respawn_time: float = 5.0
var respawn_timer: Timer

# موقع الـ RigidBody الأصلي لتجنب مشاكل الحركة
var original_rigidbody_position: Vector2

func _ready():
	_recreate_sprites()

	# حفظ موقع الـ RigidBody الأصلي
	original_rigidbody_position = _rigid_body.position

	# إعداد مؤقت السقوط
	fall_timer = Timer.new()
	fall_timer.one_shot = true
	fall_timer.timeout.connect(_fall)
	add_child(fall_timer)

	# إعداد مؤقت الرجوع
	respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(_respawn)
	add_child(respawn_timer)
	
	_rigid_body.freeze = true
	_collision_shape.disabled = false
	_area_collision_shape.disabled = false


func _set_one_way(new_one_way):
	one_way = new_one_way
	if is_node_ready():
		_recreate_sprites()


func _recreate_sprites():
	if not _sprites:
		return
	for c in _sprites.get_children():
		c.queue_free()

	_collision_shape.one_way_collision = one_way

	var new_sprite := Sprite2D.new()
	new_sprite.texture = SPRITE
	new_sprite.hframes = 12
	new_sprite.vframes = 3
	new_sprite.frame_coords = Vector2i(10, 1)
	_sprites.add_child(new_sprite)


func _on_area_2d_body_entered(body):
	if not body.is_in_group("players"):
		return
	if fall_time > 0:
		fall_timer.start(fall_time)
		_animation_player.play("shake")
	elif fall_time == 0:
		_rigid_body.call_deferred("set_freeze_enabled", false)


func _fall():
	_rigid_body.freeze = false
	_rigid_body.linear_velocity = Vector2.ZERO
	_rigid_body.angular_velocity = 0
	_animation_player.stop()
	respawn_timer.start(respawn_time)


func _respawn():
	_rigid_body.freeze = true
	_rigid_body.linear_velocity = Vector2.ZERO
	_rigid_body.angular_velocity = 0
	_rigid_body.rotation = 0
	_rigid_body.position = original_rigidbody_position
	_animation_player.play("reset")
