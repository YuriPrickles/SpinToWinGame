@tool
class_name Map
extends Node2D

@export var levels:Array[Level]

var normalized_rotation: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
#@onready var very_background: CanvasLayer = $CanvasLayer/VeryBackground
var added = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not added:
		added = true
		
		if not Engine.is_editor_hint():
			var level_cover:LevelCover = preload("res://Source/level_cover.tscn").instantiate()
			level_cover.levels = levels
			$CanvasLayer.add_child(level_cover)

	if Engine.is_editor_hint():
		(get_node("CanvasModulate") as CanvasModulate).hide()
	else:
		normalized_rotation = Main.normalize_rotation(rotation_degrees)
		(get_node("CanvasModulate") as CanvasModulate).show()
		rotation_degrees = roundi(rotation_degrees) % 360
		#very_background.rotation = deg_to_rad(roundi(rad_to_deg(very_background.rotation)) % 360)
		#$CanvasLayer/VeryBackground2.rotation = deg_to_rad(roundi(rad_to_deg($CanvasLayer/VeryBackground2.rotation)) % 360)
	pass
