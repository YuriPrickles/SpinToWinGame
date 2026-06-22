@tool
class_name Lightbeam
extends Node2D

@export var width:int
@export var height:int
var offsets: Array[int]
var opacity:float = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	offsets.append(randi() % 125)
	offsets.append(randi() % 125)
	offsets.append(randi() % 125)
	offsets.append(randi() % 125)
	z_index = Main.Depths.FGTiles
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if Main.main.should_update(self):
			queue_redraw()
			var plr = Main.main.get_player()
			opacity = clamp(plr.position.distance_to(plr.current_level.position + position)/96,0,1)
	else:
		queue_redraw()

func _draw() -> void:
	if offsets.size() < 4: return
	for j in range(4):
		for i in range(width / 4):
			i += 1
			var rect_size = Vector2(8,height + sin((Engine.get_frames_drawn() + offsets[j]) * 0.05 * i / height) * height )
			var rect_pos = Vector2(sin((Engine.get_frames_drawn() + offsets[j]) * 0.02 * i + (i*i)) * width/2 - 4,0)
			draw_rect(Rect2(rect_pos,rect_size),Color(0.871, 1.0, 0.89, 1.0) * 0.4 * opacity)
