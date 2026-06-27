class_name UI
extends Control

@onready var textbox_margin: MarginContainer = $TextboxMargin
@onready var text_field: RichTextLabel = $TextboxMargin/ColorRect/Margin/Text
@onready var fade_out: ColorRect = $FadeOut
@onready var fin: RichTextLabel = $FadeOut/Fin
@onready var thanks: RichTextLabel = $FadeOut/Thanks

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	textbox_margin.modulate = Color.TRANSPARENT

func _process(delta: float) -> void:
	pass

func appear():
	var tween:Tween = create_tween()
	tween.tween_property(textbox_margin,"modulate",Color.WHITE * 1, 0.5)

func disappear():
	var tween:Tween = create_tween()
	tween.tween_property(textbox_margin,"modulate",Color.TRANSPARENT, 0.5)

signal begone
func say(string):
	await appear()
	text_field.text = string
	await begone
	await disappear()
