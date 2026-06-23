class_name Player
extends CharacterBody2D


const SPEED = 120.0
const ACCEL = 20.0
const DECEL = 40.0
const JUMP_VELOCITY = -225.0
const MAX_FALL_SPEED = 200
@onready var camera: Camera2D = $Camera2D
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
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
var draw_respawn_orb:bool=false

func _ready() -> void:
	var levels = Main.main.map.levels
	for level in levels:
		if level.true_bounds.has_point(position):
			current_level = level
			current_level.cover_opacity = 0
			respawn_attached = current_level.get_nearest_respawn(position)

func _process(delta: float) -> void:
	if sign(velocity.x) != 0:
		player_sprite.flip_h = sign(velocity.x) != 1
	var levels = Main.main.map.levels
	do_animation()
	for level in levels:
		if level.true_bounds.has_point(position):
			current_level = level
	if prev_level and prev_level != current_level:
		var tween:Tween = create_tween()
		respawn_attached = current_level.get_nearest_respawn(position)
		tween.tween_property(prev_level,"cover_opacity",1,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel()
		tween.tween_property(current_level,"cover_opacity",0,0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	prev_level = current_level
	if respawning:
		queue_redraw()
	#if current_level:
		#camera.set_limit(SIDE_TOP,current_level.true_bounds.position.y)
		#camera.set_limit(SIDE_LEFT,current_level.true_bounds.position.x)
		#camera.set_limit(SIDE_BOTTOM,current_level.true_bounds.position.y + current_level.true_bounds.size.y)
		#camera.set_limit(SIDE_RIGHT,current_level.true_bounds.position.x + current_level.true_bounds.size.x)

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

func do_animation():
	if respawning:
		animate("death",true,func():draw_respawn_orb=true)
	elif is_rotating:
		animate("spin",true)
	elif jumping:
		animate("jump",true)
	elif velocity.x != 0:
		animate("walk",true)
	else:
		animate("idle")
	

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

func respawn():
	if not respawning:
		player_sprite.stop()
		Main.main.map.add_child(OnDeathBoom.new(position))
		velocity = Vector2.ZERO
		move_and_slide()
		respawning = true
		camera_shake(7, 5,0.016)
		await get_tree().create_timer(0.3).timeout
		var tween2 = create_tween()
		tween2.set_parallel(true)
		tween2.tween_property(self,"respawn_orb_size",6,1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		
		rotate_level(respawn_attached.default_rotation - (roundi(collider.rotation_degrees) % 360))
		await get_tree().create_timer(0.5).timeout
		Main.main.map.add_child(OnDeathBoom.new(current_level.position + respawn_attached.position,true))
		var tween = create_tween()
		tween.tween_property(self,"position",current_level.position + respawn_attached.position,0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		
		tween.set_parallel(false)
		tween.tween_callback(func():
			respawning = false
			draw_respawn_orb = false
			queue_redraw()
			respawn_orb_size = -2
			)
func animate(animation:String, interrupt:bool=true, callback:Callable=func():pass):
	if not interrupt:
		await player_sprite.animation_looped
	player_sprite.play(animation)
	if callback:
		await player_sprite.animation_looped
		callback.call()

class OnDeathBoom:
	extends Node2D
	var timer = 0
	var reverse:bool = false
	var max_time:float = 1
	
	func _init(pos:Vector2,rev:bool=false) -> void:
		position = pos
		reverse = rev
		if rev: max_time = 0.5
		material = CanvasItemMaterial.new()
		material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	
	func _process(delta: float) -> void:
		timer += delta
		queue_redraw()
		if timer >= max_time: queue_free()
	
	func _draw() -> void:
		var burst_amount = 8
		for i in range(burst_amount):
			var num = (360/burst_amount) * i
			if not reverse:
				draw_circle(Vector2(0,-160 * timer).rotated(deg_to_rad(num + timer * 24) ),sin(Engine.get_frames_drawn() * 0.3) + 4,Color.WHITE * absf(max_time + 0.5-timer))
			else:
				draw_circle(Vector2(0,-160 * absf(max_time-timer)).rotated(deg_to_rad(num + absf(max_time-timer) * 256) ),sin(Engine.get_frames_drawn() * 0.3) + 4,Color.WHITE * (timer + timer))

var respawn_orb_size:float = -2
func _draw() -> void:
	if draw_respawn_orb:
		player_sprite.visible = false
		draw_circle(Vector2(1,1).rotated(Engine.get_frames_drawn()*0.1),sin(Engine.get_frames_drawn() * 0.1) + respawn_orb_size,Color.WHITE)
	else:
		player_sprite.visible = true
	pass
