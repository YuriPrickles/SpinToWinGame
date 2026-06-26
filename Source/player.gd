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
@onready var walk_audio: AudioStreamPlayer2D = $WalkAudio
@onready var land_audio: AudioStreamPlayer2D = $LandAudio
@onready var jump_audio: AudioStreamPlayer2D = $JumpAudio
@onready var death_audio: AudioStreamPlayer2D = $DeathAudio
@onready var spinboost_audio: AudioStreamPlayer2D = $SpinboostAudio


const COYOTE_MAX:float = 0.1
var coyote_timer:float = 0

const BUFFER_MAX:float = 0.1
var buffer_timer:float = 0
var buffering:bool = true
var current_level:Level = null
var prev_level:Level = null
var respawn_attached: Respawn
var draw_respawn_orb:bool=false

var next_jump_boost:Vector2 = Vector2.ZERO

var spins = 1
var MAX_SPINS = 1

enum State{
	NORMAL=0,
	JUMPING=1,
	ROTATING=2,
	RESPAWNING=3,
}
var StateMachine:State = State.NORMAL

var vel_override_timer:float = 0

func _ready() -> void:
	var levels = Main.main.map.levels
	for level in levels:
		if level.true_bounds.has_point(position):
			current_level = level
			current_level.cover_opacity = 0
			respawn_attached = current_level.get_nearest_respawn(position)

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("debug_unkillable"):
		spins = MAX_SPINS
		coyote_timer = 0.05
		really_dont_jump = false
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
	if StateMachine == State.RESPAWNING:
		queue_redraw()
	#if current_level:
		#camera.set_limit(SIDE_TOP,current_level.true_bounds.position.y)
		#camera.set_limit(SIDE_LEFT,current_level.true_bounds.position.x)
		#camera.set_limit(SIDE_BOTTOM,current_level.true_bounds.position.y + current_level.true_bounds.size.y)
		#camera.set_limit(SIDE_RIGHT,current_level.true_bounds.position.x + current_level.true_bounds.size.x)

var really_dont_jump:bool = false
var landed:bool = false
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		buffer_timer = 0
		buffering = true
		if not really_dont_jump and not StateMachine == State.ROTATING and not StateMachine == State.JUMPING and (is_on_floor() or (coyote_timer < COYOTE_MAX)):
			jump()
			coyote_timer = 0
			StateMachine = State.JUMPING
	if StateMachine == State.ROTATING or StateMachine == State.RESPAWNING: return
	if not is_on_floor():
		
		landed = false
		if Input.is_action_just_released("jump"):
			really_dont_jump = true
			StateMachine = State.NORMAL
			if velocity.y < -100:
				velocity.y = -100
		if not StateMachine == State.JUMPING: coyote_timer += delta
		else: coyote_timer = 0
		velocity.y = clampf(velocity.y + (get_gravity().y * delta),-INF, MAX_FALL_SPEED)
	if coyote_timer > 0: next_jump_boost = Vector2.ZERO
	if not StateMachine == State.ROTATING and buffering and buffer_timer < BUFFER_MAX:
		buffer_timer += delta
	
	if is_on_floor():
		if not landed:
			land_audio.play()
			landed = true
		really_dont_jump = false
		if coyote_timer >= 0 and StateMachine == State.NORMAL and spins < MAX_SPINS:
			#modulate = Color.GREEN
			spins = MAX_SPINS
		coyote_timer = 0
		if StateMachine == State.JUMPING:
			StateMachine = State.NORMAL
		if buffer_timer < BUFFER_MAX:
			jump()
			buffer_timer = 0
			StateMachine = State.JUMPING
		
	var rotate_dir:float = -Input.get_axis("rotate_left", "rotate_right")
	if spins > 0 and rotate_dir and not StateMachine == State.ROTATING:
		var rotation_value = 90 * rotate_dir
		rotate_level(rotation_value, true)
	if Input.is_action_just_pressed("debug_unkillable"):
		
		walk_audio.play()
	var direction := Input.get_axis("left", "right")
	if vel_override_timer <= 0:
		if direction:
			velocity.x = move_toward(velocity.x,direction * SPEED, ACCEL)
		else:
			velocity.x = move_toward(velocity.x, 0, DECEL)
	else:
		vel_override_timer -= delta
	move_and_slide()

func override_vel(vel:Vector2, time=0.2):
	velocity = vel
	vel_override_timer = time

func do_animation():
	var prefix = "s_" if spins < MAX_SPINS else ""
	if Input.is_action_pressed("debug_unkillable"):
		animate("%sspin" % prefix,true)
		player_sprite.speed_scale = 4
		return
	else:
		player_sprite.speed_scale = 1
	if StateMachine == State.RESPAWNING:
		animate("%sdeath" % prefix,true,func():draw_respawn_orb=true)
	elif StateMachine == State.ROTATING:
		animate("%sspin" % prefix,true)
	elif StateMachine == State.JUMPING:
		animate("%sjump" % prefix,true)
	elif StateMachine == State.NORMAL:
		if velocity.x != 0:
			animate("%swalk" % prefix,true)
		else:
			animate("%sidle" % prefix)
	

func jump(vel = JUMP_VELOCITY):
	if next_jump_boost.y < 0:
		spinboost_audio.play()
		Main.main.freeze(0.1)
	else:
		jump_audio.play()
	velocity.x = velocity.x + next_jump_boost.x + (40 * sign(velocity.x))
	velocity.y = vel + next_jump_boost.y
	next_jump_boost = Vector2.ZERO

func rotate_level(rot:int,manual=false):
	var was_on_floor = is_on_floor()
	var state_to_return = StateMachine
	if not StateMachine == State.RESPAWNING:
		StateMachine = State.ROTATING
	var tween:Tween = create_tween()
	tween.tween_property(camera,"rotation_degrees",camera.rotation_degrees + rot,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(Main.main.map,"rotation_degrees",Main.main.map.rotation_degrees - rot,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(Main.main.map.get_node("CanvasLayer"),"rotation",deg_to_rad(Main.main.map.rotation_degrees - rot),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(Main.main.map.get_node("CanvasLayer/CanvasLayer"),"rotation",deg_to_rad(Main.main.map.rotation_degrees - rot),0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(player_sprite,"rotation_degrees",player_sprite.rotation_degrees + rot,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(collider,"rotation_degrees", collider.rotation_degrees + rot,0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(false)
	tween.tween_callback(func():
		StateMachine = state_to_return
		if was_on_floor:
			if not is_on_floor():
				StateMachine = State.JUMPING
			next_jump_boost = Vector2(0,JUMP_VELOCITY * 0.5)
			coyote_timer = -0.08
		if manual:
			spins -= 1
		)

func camera_shake(strength:float, frames:float,delta:float):
	for i in range(frames):
		camera.offset = Vector2(randf_range(-strength,strength),randf_range(-strength,strength))
		await get_tree().create_timer(delta).timeout
	camera.offset = Vector2.ZERO

func respawn():
	if Input.is_action_pressed("debug_unkillable"):
		return
	Main.main.freeze(0.1)
	death_audio.play()
	print(StateMachine)
	if not StateMachine == State.RESPAWNING:
		StateMachine = State.RESPAWNING
		player_sprite.stop()
		Main.main.map.add_child(OnDeathBoom.new(position))
		velocity = Vector2.ZERO
		move_and_slide()
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
			StateMachine = State.NORMAL
			draw_respawn_orb = false
			queue_redraw()
			respawn_orb_size = -2
			)

func animate(animation:String, interrupt:bool=true, callback:Callable=func():pass):
	if not interrupt:
		await player_sprite.animation_looped
		
	player_sprite.play(animation)
	if player_sprite.frame % 2 == 0 and player_sprite.animation.ends_with("walk"):
		if (velocity.x != 0) and is_on_floor():
			walk_audio.play()
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

var normal_b:Texture = preload("res://Assets/Gameplay/characters/ballerina.png")
var silver_b:Texture = preload("res://Assets/Gameplay/characters/silver_ballerina.png")
var respawn_orb_size:float = -2
func _draw() -> void:
	if draw_respawn_orb:
		player_sprite.visible = false
		draw_circle(Vector2(1,1).rotated(Engine.get_frames_drawn()*0.1),sin(Engine.get_frames_drawn() * 0.1) + respawn_orb_size,Color.WHITE)
	else:
		player_sprite.visible = true
