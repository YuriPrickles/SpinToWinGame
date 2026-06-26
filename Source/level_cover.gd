class_name LevelCover
extends Node2D
var levels:Array[Level]
var draw_cover:bool = false

func _ready() -> void:
	pass
	#var spr = Sprite2D.new()
	#spr.texture = load("res://Assets/Gameplay/backgrounds/background.png")
	#spr.region_enabled = true
	#spr.centered = false
	#spr.region_rect = level.true_bounds
	#spr.texture_repeat = TextureRepeat.TEXTURE_REPEAT_ENABLED
	#add_child(spr)
func _process(delta: float) -> void:
	queue_redraw()
func _draw() -> void:
	#parallax_2d.rotation_degrees = Main.main.map.rotation_degrees + 90
	if material:
		material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	for level in levels:
		if not level or Engine.is_editor_hint(): return
		for i in range(0,24,1):
			draw_rect(Rect2(level.position,level.true_bounds.size),Main.VOID_COLOR * 0.12, false,i,false)
		if Main.main.get_player().current_level != level:
			draw_rect(Rect2(level.position,level.true_bounds.size),Main.VOID_COLOR * level.cover_opacity, true)
