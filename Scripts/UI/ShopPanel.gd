extends Panel

signal item_priced(item_id: String, mode: String)

@export var item_card_scene: PackedScene
@export var item_list_path: NodePath  # set in inspector

@onready var item_list: VBoxContainer = $MarginContainer/ShopVBox/ItemList
@onready var close_button: Button = $CloseButton

var items: Array = []

func _ready() -> void:
	visible = false
	print("ShopPanel ready. item_list=", item_list)

func _on_close_button_pressed() -> void:
	visible = false

func set_items(new_items: Array) -> void:
	print("set_items called, count:", new_items.size())
	items = new_items
	_refresh()

func _refresh() -> void:
	if item_list == null:
		push_error("ShopPanel: item_list_path is wrong/empty.")
		return
	if item_card_scene == null:
		push_error("ShopPanel: item_card_scene is not set in Inspector.")
		return

	for c in item_list.get_children():
		c.queue_free()

	for it in items:
		var card = item_card_scene.instantiate()
		item_list.add_child(card)

		if card.has_method("set_item"):
			card.call("set_item", it)
		else:
			push_error("ItemCard scene is missing set_item(data).")
			continue

		if card.has_signal("price_chosen"):
			card.connect("price_chosen", Callable(self, "_on_card_price_chosen"))
		else:
			push_error("ItemCard scene is missing signal price_chosen.")

func _on_card_price_chosen(item_id: String, mode: String) -> void:
	emit_signal("item_priced", item_id, mode)

func remove_item(item_id: String) -> void:
	for i in range(items.size()):
		if str(items[i].get("id", "")) == item_id:
			items.remove_at(i)
			break
	_refresh()
