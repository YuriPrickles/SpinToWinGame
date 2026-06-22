@tool
class_name RotationGate
extends StaticBody2D
enum Rotations{
	UP = 0,
	DOWN = 180,
	RIGHT = 270,
	LEFT = 90
}
@export var width:int = 24
@export var height:int = 24
@export var direction:Rotations = Rotations.UP

@onready var collider: CollisionShape2D = $Collider
@onready var player_detector: Area2D = $PlayerDetector
@onready var area_2d_collider: CollisionShape2D = $PlayerDetector/Area2DCollider

var active:bool = false

var block_texture = preload("res://Assets/Gameplay/objects/rotationgate/rotationgate_block.png")
var face_texture = preload("res://Assets/Gameplay/objects/rotationgate/rotationgate_face.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = Main.Depths.Entities


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	collider.shape.size = Vector2(width,height)
	collider.position = Vector2(width,height) / 2
	area_2d_collider.shape.size = Vector2(width-4,height-4)
	player_detector.position = ((Vector2(width,height)) / 2) 
	if Engine.is_editor_hint():
		pass
		
	elif Main.main.should_update(self):
		queue_redraw()
		active = Main.main.map.normalized_rotation != roundi(direction) 
		if active and player_detector.get_overlapping_bodies().has(Main.main.get_player()):
			active = false
		collider.disabled = not active
		for spike in get_children():
			if spike is Spikes:
				spike.modulate = Color.CRIMSON if active else Color.DARK_GREEN
				spike.monitoring = active
	queue_redraw()
	

func _draw() -> void:
	var rotation_offset = deg_to_rad(float(direction) + 90)
	var arrow_draw_offset:int = 0
	match direction:
		0:
			arrow_draw_offset = 0
		90:
			arrow_draw_offset = 1
		180:
			arrow_draw_offset = 2
		270:
			arrow_draw_offset = 3
	
	var draw_offset:int = 0
	if not Engine.is_editor_hint():
		draw_offset = 0 if Main.main.map.normalized_rotation != roundi(direction) else 24
	
	draw_texture_rect_region(block_texture,Rect2(Vector2.ZERO,Vector2(width,height)),Rect2(Vector2(0,draw_offset),Vector2(24,24)))
	draw_texture_rect_region(face_texture,Rect2(Vector2((width-24)/2,(height-24)/2),Vector2(24,24)),Rect2(Vector2(24 * arrow_draw_offset,draw_offset),Vector2(24,24)))

	draw_string(ThemeDB.fallback_font,Vector2(width/2,height/2),str(active),HORIZONTAL_ALIGNMENT_CENTER,-1, 16)
