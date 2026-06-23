@tool
class_name Jumpthrough
extends StaticBody2D

@onready var collider: CollisionShape2D = $Collider
@export var texture:Texture2D = preload("res://Assets/Gameplay/objects/jumpthrough/jumpthrough.png")
@export var width:int = 8
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	collider.shape.size = Vector2(width,8)
	collider.position = Vector2(width,8) / 2
	queue_redraw()

func _draw() -> void:
	#draw_rect(Rect2(Vector2.ZERO,Vector2(width,4)),Color.GOLD)
	if width <= 8:
		draw_texture_rect_region(texture,Rect2(Vector2.ZERO,Vector2(8,8)),Rect2(0,0,8,8))
	else:
		for i in range(width/8):
			var texture_index = 1
			if i == width/8 - 1: texture_index = 2
			elif i == 0: texture_index = 0
			draw_texture_rect_region(texture,Rect2(Vector2(0 + (i*8),0),Vector2(8,8)),Rect2(8 +(texture_index *8),0,8,8))
