class_name Main
extends Node

@export var map:Map

enum Depths{
	LevelCover = 99,
	Player  = 0,
	Entities = -1,
	FGTiles = -2,
	BGTiles = -3,
}

static var main:Main

func _init() -> void:
	main = self

func get_player() -> Player:
	return map.get_node("Player")

func should_update(entity:Node) -> bool:
	return get_player().current_level == (entity.get_parent() as Level)

static func normalize_rotation(degrees:float) -> int:
	return absi((roundi(degrees) % 360) - 180) % 360
