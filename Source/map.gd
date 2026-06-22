@tool
class_name Map
extends Node2D

@export var levels:Array[Level]

var normalized_rotation: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		(get_node("CanvasModulate") as CanvasModulate).hide()
	else:
		normalized_rotation= absi(roundi(Main.main.map.rotation_degrees) - 180) % 360
		normalized_rotation = 0 if normalized_rotation == 180 else 180 if normalized_rotation == 0 else normalized_rotation
		(get_node("CanvasModulate") as CanvasModulate).show()
		rotation_degrees = roundi(rotation_degrees) % 360
	pass
