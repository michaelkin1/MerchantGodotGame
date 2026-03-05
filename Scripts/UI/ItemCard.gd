extends PanelContainer

signal price_chosen(item_id: String, mode: String)

@onready var name_label: Label = $MarginContainer/VBoxContainer/NameLabel
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescriptionLabel
@onready var stats_label: Label = $MarginContainer/VBoxContainer/StatsLabel

@onready var fair_btn: Button = $MarginContainer/VBoxContainer/ButtonRow/FairBtn
@onready var greedy_btn: Button = $MarginContainer/VBoxContainer/ButtonRow/GreedyBtn
@onready var scam_btn: Button = $MarginContainer/VBoxContainer/ButtonRow/ScamBtn

var item: Dictionary

func _ready() -> void:
	fair_btn.pressed.connect(func(): _emit_mode("fair"))
	greedy_btn.pressed.connect(func(): _emit_mode("greedy"))
	scam_btn.pressed.connect(func(): _emit_mode("scam"))

func set_item(data: Dictionary) -> void:
	item = data
	name_label.text = str(data.get("name", "Item"))
	desc_label.text = str(data.get("desc", ""))
	stats_label.text = "Power: %s   Base: %sg" % [str(data.get("power", 0)), str(data.get("base_value", 0))]

	var base := int(data.get("base_value", 0))
	$MarginContainer/VBoxContainer/ButtonRow/FairBtn.text = "Fair (%dg)" % base
	$MarginContainer/VBoxContainer/ButtonRow/GreedyBtn.text = "Greedy (%dg)" % int(round(base * 1.4))
	$MarginContainer/VBoxContainer/ButtonRow/ScamBtn.text = "Scam (%dg)" % int(round(base * 2.0))

func _emit_mode(mode: String) -> void:
	emit_signal("price_chosen", str(item.get("id", "")), mode)
