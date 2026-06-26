extends VBoxContainer

@onready var music: RichTextLabel = $Music
@onready var sfx: RichTextLabel = $SFX
@onready var settings_menu: MarginContainer = $"../.."
@onready var pause_menu_handler: CenterContainer = $"../../../VBoxContainer/VBoxContainer/VBoxContainer2"
@onready var pause_text: MarginContainer = $"../../../VBoxContainer"

var active = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var selected = 0

func appear():
	active = true
	selected = 0
	settings_menu.show()

func disappear():
	settings_menu.hide()
	active = false
	selected = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		var m_vol = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music"))
		var s_vol = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX"))
		var option_arr:Array[Control] = [music, sfx]
		for i in option_arr.size():
			if i == selected:
				option_arr[i].modulate = Color.YELLOW
			else:
				option_arr[i].modulate = Color.WHITE
		music.text = "[font_size=64][left]Music: %d%%" % round(100 * m_vol)
		sfx.text = "[font_size=64][left]SFX: %d%%" % round(100 * s_vol)
		
		if (Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up")):
			var rotate_dir:int = Input.get_axis("up", "down")
			if selected - rotate_dir < 0:
				selected = 1
			elif selected - rotate_dir > 1:
				selected = 0
			else:
				selected -= rotate_dir
		if (Input.is_action_just_pressed("rotate_left") or Input.is_action_just_pressed("rotate_right")):
			var dir = Input.get_axis("rotate_left", "rotate_right")
			match selected:
				0:
					AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"),(clamp(m_vol + (dir * 0.1),0,1)))
				1:
					AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"),clamp(s_vol + (dir * 0.1),0,1))

func _input(event: InputEvent) -> void:
	var plr = Main.main.get_player()
	if Input.is_action_just_pressed("cancel") and plr.StateMachine != Player.State.RESPAWNING:
		if active:
			disappear()
			active = false
			await get_tree().create_timer(0.1).timeout
			pause_menu_handler.appear()
			pause_text.show()
			pause_menu_handler.active = true
	if not active: return
