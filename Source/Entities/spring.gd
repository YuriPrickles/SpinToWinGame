class_name Spring
extends Area2D

@onready var collider: CollisionShape2D = $Collider
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var bounce_audio: AudioStreamPlayer2D = $BounceAudio
@onready var retract_audio: AudioStreamPlayer2D = $RetractAudio


func _ready() -> void:
	pass # Replace with function body.

var active = true
func _process(delta: float) -> void:
	queue_redraw()
	if not active: return
	for body in get_overlapping_bodies():
		if body is Player and not body.StateMachine == Player.State.ROTATING and not body.StateMachine == Player.State.RESPAWNING:
			body = body as Player
			var final_rotation = Main.normalize_rotation(rotation_degrees + Main.main.map.rotation_degrees)
			var bop = false
			if (final_rotation - 90) % 180 == 0:
				body.global_position = global_position
				bop = true
			body.spins =body.MAX_SPINS
			bounce_audio.play(0.5)
			body.override_vel(Vector2(0,-300).rotated(deg_to_rad(final_rotation)),0.2 if bop else 0)
			if bop:
				body.velocity.y = -150
			sprite.play("boing")
			await get_tree().create_timer(0.2).timeout
			retract_audio.play()
