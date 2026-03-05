extends Panel

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var class_label: Label = $MarginContainer/VBoxContainer/ClassLabel
@onready var personality_label: Label = $MarginContainer/VBoxContainer/PersonalityLabel
@onready var gold_label: Label = $MarginContainer/VBoxContainer/GoldLabel

func show_hero(hero_data: Dictionary) -> void:
	visible = true
	name_label.text = "Name: %s" % str(hero_data.get("name", "Unknown"))
	class_label.text = "Class: %s" % str(hero_data.get("class", "Unknown"))
	personality_label.text = "Personality: %s" % str(hero_data.get("personality", "Unknown"))
	gold_label.text = "Gold: %d" % int(hero_data.get("gold", 0))

func hide_panel() -> void:
	visible = false

func _ready() -> void:
	visible = false
