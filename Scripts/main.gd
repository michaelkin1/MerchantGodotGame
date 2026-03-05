extends Node2D

@onready var world: Node2D = $World
@onready var shop_panel = $ShopCanvasLayer/ShopPanel
@onready var merchant_gold_label: Label = $ShopCanvasLayer/ShopPanel/MarginContainer/ShopVBox/TopBar/MerchantGoldLabel
@onready var hero_panel: Panel = $ShopCanvasLayer/HeroPanel

var hero_scene: PackedScene = preload("res://Scenes/Actors/Hero.tscn")
var current_hero: Node2D
var merchant_gold := 20


# Simple “shop stock” for now
var shop_items := [
	{ "id":"sword", "name":"Iron-Bitten Sword", "desc":"Old edge. Still hungry for work.", "power":2, "base_value":10 },
	{ "id":"potion", "name":"Cloudglass Tonic", "desc":"Smells like pine and lies.", "power":1, "base_value":8 }
]

var current_hero_data: Dictionary = {}

func _ready() -> void:

	print("rules version: ", DB.get_rules().get("version", "missing"))
	print("random item: ", DB.get_random_item().get("name", "none"))
	print("random mission: ", DB.get_random_mission().get("name", "none"))
	randomize()
	_update_merchant_gold_ui()

	# connect once
	if not shop_panel.item_priced.is_connected(_on_item_priced):
		shop_panel.item_priced.connect(_on_item_priced)

	_spawn_hero()

func _update_merchant_gold_ui() -> void:
	merchant_gold_label.text = "Gold: %d" % merchant_gold

func open_shop() -> void:
	shop_panel.visible = true
	shop_panel.set_items(shop_items)

func _on_item_priced(item_id: String, mode: String) -> void:
	var item := _find_item(item_id)
	if item.is_empty():
		print("Unknown item:", item_id)
		return

	var base := int(item.get("base_value", 0))
	var mult := _mult_for_mode(mode)
	var price := int(round(base * mult))

	# --- HERO AFFORDABILITY (hard rule) ---
	var hero_gold := int(current_hero_data.get("gold", 0))
	if price > hero_gold:
		print("REJECTED (can't afford):", item_id, "price", price, "hero_gold", hero_gold)
		return
	# --------------------------------------

	# Simple accept chances (tweak later)
	var accept_chance := _accept_chance_for_mode(mode)
	var accepted := randf() < accept_chance

	if accepted:
		# Merchant gains
		merchant_gold += price
		_update_merchant_gold_ui()

		# Hero pays + update Hero UI
		current_hero_data["gold"] = hero_gold - price
		hero_panel.show_hero(current_hero_data)

		print("SOLD", item_id, "for", price, "mode", mode)

		# Remove from BOTH main stock + UI
		_remove_item_from_stock(item_id)
		shop_panel.remove_item(item_id)

		# Optional: hero leaves (stub)
		# _hero_leave()
	else:
		print("REJECTED", item_id, "mode", mode)

func _mult_for_mode(mode: String) -> float:
	match mode:
		"fair": return 1.0
		"greedy": return 1.4
		"scam": return 2.0
		_: return 1.0

func _accept_chance_for_mode(mode: String) -> float:
	match mode:
		"fair": return 0.90
		"greedy": return 0.60
		"scam": return 0.25
		_: return 0.50

func _find_item(item_id: String) -> Dictionary:
	for it in shop_items:
		if str(it.get("id","")) == item_id:
			return it
	return {}

func _remove_item_from_stock(item_id: String) -> void:
	for i in range(shop_items.size()):
		if str(shop_items[i].get("id","")) == item_id:
			shop_items.remove_at(i)
			return
			
func _generate_hero_data() -> Dictionary:
	var classes = ["Warrior", "Scout", "Herbalist", "Mercenary"]
	var personalities = ["Honest", "Desperate", "Proud", "Suspicious"]

	return {
		"name": "Frogman #%d" % randi_range(10, 99),
		"class": classes.pick_random(),
		"personality": personalities.pick_random(),
		"gold": randi_range(6, 20)
	}
	
func _spawn_hero() -> void:
	if is_instance_valid(current_hero):
		current_hero.queue_free()

	current_hero = hero_scene.instantiate()
	current_hero.position = Vector2(200, 120)
	world.add_child(current_hero)

	current_hero_data = _generate_hero_data()
	hero_panel.show_hero(current_hero_data)
