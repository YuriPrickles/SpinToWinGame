extends Control

@onready var cont: RichTextLabel = $Continue
@onready var respawn: RichTextLabel = $Respawn
@onready var exit: RichTextLabel = $Exit
@onready var settings: RichTextLabel = $Settings
@onready var pause_menu: ColorRect = $"../../.."

var select_index = 0
const MAX_IND = 3
var active = false

func appear():
	get_tree().paused = true
	active = true
	var tween = create_tween()
	tween.tween_property(pause_menu,"modulate",Color.WHITE,0.1)

func disappear():
	var tween = create_tween()
	tween.tween_property(pause_menu,"modulate",Color.TRANSPARENT,0.1)
	tween.tween_callback(func():
		get_tree().paused = false
		active = false
		select_index = 0
		rotate_wait = false
		offset_transform_rotation = 0
		)

func _process(delta: float) -> void:
	var plr = Main.main.get_player()
	#offset_transform_rotation = deg_to_rad(rad_to_deg(roundi(offset_transform_rotation) % 360))
	var option_arr = [cont,respawn,exit,settings]
	for i in option_arr.size():
		if i == select_index:
			option_arr[i].modulate = Color.YELLOW
		else:
			option_arr[i].modulate = Color.WHITE
	if active and plr.StateMachine == Player.State.RESPAWNING:
		disappear()
	
var rotate_wait:bool = false
func _input(event: InputEvent) -> void:
	var plr = Main.main.get_player()
	if Input.is_action_just_pressed("cancel") and plr.StateMachine != Player.State.RESPAWNING:
		if active:
			disappear()
		else:
			appear()
	if not active: return
	if not rotate_wait and (Input.is_action_just_pressed("rotate_left") or Input.is_action_just_pressed("rotate_right")):
		rotate_wait = true
		var rotate_dir:int = -Input.get_axis("rotate_left", "rotate_right")
		if select_index - rotate_dir < 0:
			select_index = 3
		elif select_index - rotate_dir > 3:
			select_index = 0
		else:
			select_index -= rotate_dir
		if rotate_dir != 0:
			var tween = create_tween()
			tween.tween_property(self, "offset_transform_rotation",offset_transform_rotation + deg_to_rad(rotate_dir * 90),0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_callback(func():
				rotate_wait = false
				)
	if Input.is_action_just_pressed("accept"):
		match select_index:
			0:
				disappear()
			1:
				disappear()
				plr.respawn()
			2:
				get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
				get_tree().quit()
			3:
				active = false
				$"../..".hide()
				settings_menu.appear()
@onready var settings_menu: VBoxContainer = $"../../../SettingsMenu/VBoxContainer/VBoxContainer"
