@tool
class_name RestNote
extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var break_audio: AudioStreamPlayer2D = $BreakAudio

var timer:float = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite.offset.y = sin(Engine.get_frames_drawn() * 0.04)
	if not Engine.is_editor_hint():
		if Main.main.start_end_seq: return
		sprite.play("idle")
		for body in get_overlapping_bodies():
			if body is Player and not body.StateMachine == Player.State.RESPAWNING and not body.StateMachine == Player.State.ROTATING:
				body.spins = body.MAX_SPINS
				#(body as Player).camera_shake(2,4,delta)
				Main.main.freeze(delta * 5)
				Main.main.ending_sequence()


func _on_body_entered(body: Node2D) -> void:
	pass
