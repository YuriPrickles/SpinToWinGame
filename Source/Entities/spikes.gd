@tool
extends Area2D

@export var width:int = 8
@export var texture:Texture2D = preload("res://Assets/Gameplay/objects/spikes/spikes.png")
@onready var collider: CollisionShape2D = $Collider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_index = Main.Depths.Entities
	collider.position = Vector2(width/2,6)
	(collider.shape as RectangleShape2D).size = Vector2(width, 4)
	queue_redraw()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		collider.position = Vector2(width/2,6)
		(collider.shape as RectangleShape2D).size = Vector2(width, 4)
		queue_redraw()
	elif Main.main.should_update(self):
		queue_redraw()
	else: return

func _draw() -> void:
	for i in range(0,width,8):
		draw_texture(texture,Vector2(i,0))


func _on_body_entered(body: Node2D) -> void:
	if body is Player and body is not TileMapLayer:
		var allow_pass = false
		var vel = body.velocity.rotated(body.collider.rotation)
		print(roundi(abs(rotation_degrees)) % 360)
		match roundi(abs(rotation_degrees)) % 360:
			0:
				if vel.y < 0:
					allow_pass = true
			90:
				if vel.x < 0:
					allow_pass = true
			180:
				if vel.y > 0:
					allow_pass = true
			270:
				if vel.x > 0:
					allow_pass = true
		if not body.is_rotating and not allow_pass:
			body.respawn()
