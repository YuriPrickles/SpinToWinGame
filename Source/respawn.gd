@tool
class_name Respawn
extends Node2D

@export var default_rotation:DefaultRotations = DefaultRotations.UP

enum DefaultRotations{
	UP = 0,
	DOWN = 180,
	RIGHT = 270,
	LEFT = 90
}

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_string(ThemeDB.fallback_font,Vector2(-4,0),"R",HORIZONTAL_ALIGNMENT_CENTER,-1, 16)
