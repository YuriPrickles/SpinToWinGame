class_name Player
extends CharacterBody2D


const SPEED = 120.0
const ACCEL = 20.0
const DECEL = 40.0
const JUMP_VELOCITY = -200.0
const MAX_FALL_SPEED = 300
@onready var camera: Camera2D = $Camera2D
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var collider: CollisionShape2D = $Collider

var is_rotating = false

const COYOTE_MAX:float = 0.2
var coyote_timer:float = 0
var jumping:bool = false

const BUFFER_MAX:float = 0.4
var buffer_timer:float = 0
var buffering:bool = false
var current_level:Level = null
var prev_level:Level = null
var respawning = false
var respawn_attached: Respawn

func _ready() -> void:
	var levels = Main.main.map.levels
	for level in levels:
		if level.bounds.has_point(position):
			current_level = level
			current_level.cover_opacity = 0
			respawn_attached = current_level.get_nearest_respawn(position)

func _process(delta: float) -> void:
	if sign(velocity.x) != 0:
		player_sprite.flip_h = sign(velocity.x) != 1
	var levels = Main.main.map.levels
	for level in levels:
		if level.bounds.has_point(position):
			current_level = level
	if prev_level and prev_level != current_level:
		var tween:Tween = create_tween()
		respawn_attached = current_level.get_nearest_respawn(position)
		tween.tween_property(prev_level,"cover_opacity",1,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel()
		tween.tween_property(current_level,"cover_opacity",0,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	prev_level = current_level
	#if current_level:
		#camera.set_limit(SIDE_TOP,current_level.bounds.position.y)
		#camera.set_limit(SIDE_LEFT,current_level.bounds.position.x)
		#camera.set_limit(SIDE_BOTTOM,current_level.bounds.position.y + current_level.bounds.size.y)
		#camera.set_limit(SIDE_RIGHT,current_level.bounds.position.x + current_level.bounds.size.x)

func respawn():
	if not respawning:
		velocity = Vector2.ZERO
		move_and_slide()
		respawning = true
		camera_shake(7, 5,0.016)
		await get_tree().create_timer(0.3).timeout
		rotate_level(respawn_attached.default_rotation - (roundi(collider.rotation_degrees) % 360))
		await get_tree().create_timer(0.3).timeout
		var tween = create_tween()
		tween.tween_property(self,"position",current_level.position + respawn_attached.position,0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func(): respawning = false)
func _physics_process(delta: float) -> void:
	if is_rotating or respawning: return
	if not is_on_floor():
		if not jumping: coyote_timer += delta
		velocity.y = clampf(velocity.y + (get_gravity().y * delta),JUMP_VELOCITY, MAX_FALL_SPEED)
	if buffering:
		buffer_timer += delta
		if buffer_timer > BUFFER_MAX:
			buffering = false
		elif is_on_floor():
			jump()
			
	if is_on_floor():
		jumping = false
	var rotate_dir:float = Input.get_axis("rotate_left", "rotate_right")
	if not jumping and Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or (coyote_timer > 0 and coyote_timer < COYOTE_MAX):
			jump()
			coyote_timer = 0
			jumping = true
		else:
			buffering = true
	
	if rotate_dir and not is_rotating:
		var rotation_value = 90 * rotate_dir
		rotate_level(rotation_value)
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x,direction * SPEED, ACCEL)
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL)
	move_and_slide()
		
func jump(vel = JUMP_VELOCITY):
	velocity.y = vel

func rotate_level(rot:int):
	is_rotating = true
	var tween:Tween = create_tween()
	tween.tween_property(camera,"rotation_degrees",camera.rotation_degrees + rot,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(Main.main.map,"rotation_degrees",Main.main.map.rotation_degrees - rot,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(player_sprite,"rotation_degrees",player_sprite.rotation_degrees + rot,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(collider,"rotation_degrees", collider.rotation_degrees + rot,0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(false)
	tween.tween_callback(func(): is_rotating = false)

func camera_shake(strength:float, frames:float,delta:float):
	for i in range(frames):
		camera.offset = Vector2(randf_range(-strength,strength),randf_range(-strength,strength))
		await get_tree().create_timer(delta).timeout
	camera.offset = Vector2.ZERO
