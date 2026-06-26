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

static var ui: UI


static var main:Main

const VOID_COLOR:Color = Color("ffffffff")

func _init() -> void:
	main = self

func _ready() -> void:
	ui = $UI
var saved_input

var send_jump:bool = false
var send_spin_L:bool = false
var send_spin_R:bool = false

func _process(delta: float) -> void:
	if listen_for_inputs:
		if Input.is_action_just_pressed("jump"):
			send_jump = true
			print("heard!")
		if Input.is_action_just_pressed("rotate_left"):
			send_spin_L = true
			print("heard!")
		if Input.is_action_just_pressed("rotate_right"):
			send_spin_R = true
			print("heard!")
	get_window().content_scale_size = Vector2(0, 0)

func get_player() -> Player:
	return map.get_node("Player")

func should_update(entity:Node) -> bool:
	return get_player().current_level == (entity.get_parent() as Level)

static func normalize_rotation(degrees:float) -> int:
	if roundi(degrees) == 360: return 0
	var initial_normalized = (roundi(degrees) % 360)
	if initial_normalized < 0: initial_normalized += 360
	return initial_normalized


var listen_for_inputs:bool= false
func freeze(time:float):
	get_tree().paused = true
	listen_for_inputs = true
	await get_tree().create_timer(time).timeout
	get_tree().paused = false
	listen_for_inputs = false
	if send_jump:
		Input.action_press("jump")
		send_jump = false
	if send_spin_L:
		Input.action_press("rotate_left")
		send_spin_L = false
	if send_spin_R:
		Input.action_press("rotate_right")
		send_spin_R = false
