class_name Main
extends Node

@export var map:Map

enum Depths{
	LevelCover = 99,
	Player  = 0,
	Entities = -1,
	FGTiles = -2,
	BGTiles = -3,
	VeryBackground = -99,
}
@onready var very_background: CanvasLayer = $SubViewportContainer/SubViewport/VeryBackground
@onready var vb_color_rect: ColorRect = $SubViewportContainer/SubViewport/VeryBackground/VBColorRect

static var main:Main

const VOID_COLOR:Color = Color("b0a9b1")

func _init() -> void:
	main = self

func _ready() -> void:
	vb_color_rect.color = VOID_COLOR

func get_player() -> Player:
	return map.get_node("Player")

func should_update(entity:Node) -> bool:
	return get_player().current_level == (entity.get_parent() as Level)

static func normalize_rotation(degrees:float) -> int:
	if roundi(degrees) == 360: return 0
	var initial_normalized = (roundi(degrees) % 360)
	if initial_normalized < 0: initial_normalized += 360
	return initial_normalized

func freeze(time:float):
	get_tree().paused = true
	await get_tree().create_timer(time).timeout
	get_tree().paused = false
