@tool
class_name  Refill
extends Area2D

@export var wait_time:float = 1.5
@export var one_use:bool = false
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var break_audio: AudioStreamPlayer2D = $BreakAudio
@onready var respawn_audio: AudioStreamPlayer2D = $RespawnAudio

var timer:float = 0
var empty = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = wait_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		sprite.rotation_degrees = -Main.main.map.rotation_degrees
		if timer < wait_time:
			timer += delta
		elif empty:
			respawn_audio.play()
			empty = false
		if empty:
			sprite.play("empty")
		else:
			sprite.play("idle")
			for body in get_overlapping_bodies():
				if body is Player and body.spins < body.MAX_SPINS and not empty and not body.StateMachine == Player.State.ROTATING:
					body.spins = body.MAX_SPINS
					timer = 0
					if one_use:
						hide()
						timer = -INF
					empty = true
					(body as Player).camera_shake(2,4,delta)
					break_audio.play()
					Main.main.freeze(delta * 5)
	else:
		$PointLight2D.hide()
	sprite.offset.y = sin(Engine.get_frames_drawn() * 0.04)
		


func _on_body_entered(body: Node2D) -> void:
	pass
