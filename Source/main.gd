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
@onready var music: AudioStreamPlayer = $Music

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
var start_end_seq = false
func ending_sequence():
	if start_end_seq: return
	start_end_seq = true
	music.play(138.85)
	var plr = get_player()
	await plr.rotate_level(-(roundi(plr.collider.rotation_degrees) % 360))
	var tween2 = create_tween()
	tween2.tween_property(map.get_node("CanvasModulate"),"color",Color(0.247, 0.228, 0.255, 1.0),1)
	tween2.set_parallel(true)
	tween2.tween_property(plr.get_node("PointLight2D") as PointLight2D,"color",Color.WHITE,1)
	(music.stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_DISABLED
	
	plr.player_sprite.play("spin",1.4)
	await get_tree().create_timer(142.20 - 138.85).timeout
	plr.player_sprite.play("bow")
	await get_tree().create_timer(3).timeout
	var tween = create_tween()
	tween.tween_property(ui.fade_out,"color",Color.BLACK,2)
	tween.tween_callback(func():
		ui.fin.show()
		await get_tree().create_timer(2).timeout
		ui.thanks.show()
		await get_tree().create_timer(5).timeout
		get_tree().quit()
		)

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
