@tool
class_name Level
extends Node2D

@export var bounds:Rect2
@export var foreground_tiles: TileMapLayer

var cover_opacity:float = 1

var level_cover = LevelCover.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	foreground_tiles = get_node("ForegroundTiles")
	foreground_tiles.z_index = Main.Depths.FGTiles
	level_cover.level = self
	add_child(level_cover)
	level_cover.z_index = Main.Depths.LevelCover
	level_cover.z_as_relative = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		bounds.position = position
		queue_redraw()
	else:
		queue_redraw()
		level_cover.queue_redraw()

func get_nearest_respawn(pos:Vector2):
	var distance = INF
	var respawn:Respawn = null
	for node in get_children():
		if node is Respawn:
			print(node.name + ": " + str(node.position.distance_to(pos - position)))
			if node.position.distance_to(pos - position) < distance:
				distance = node.position.distance_to(pos)
				respawn = node
	print(respawn.position)
	return respawn

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_rect(Rect2(Vector2.ZERO,bounds.size),Color.ORANGE,false,3)
class LevelCover:
	extends Node2D
	var level:Level
	func _draw() -> void:
		if not level or Engine.is_editor_hint(): return
		draw_rect(Rect2(Vector2.ZERO,level.bounds.size),Color.BLACK * level.cover_opacity, true)
		for i in range(0,8,4):
			draw_rect(Rect2(Vector2.ZERO,level.bounds.size),Color.BLACK * 0.6, false,i,true)
