# res://Scripts/DataDB.gd
extends Node
class_name DataDB

# Why: Load and cache all data once, so gameplay code never touches raw files.

const PATH_RULES    := "res://Data/rules_v0.5.json"
const PATH_HEROES   := "res://Data/Heroes/heroes_v0.5.json"
const PATH_ITEMS    := "res://Data/Items/items_v0.5.json"
const PATH_MISSIONS := "res://Data/Missions/missions_v0.5.json"
const PATH_MERCHANT := "res://Data/Merchant/merchant_v0.5.json"

var rules: Dictionary = {}
var heroes: Dictionary = {}
var items: Dictionary = {}
var missions: Dictionary = {}
var merchant: Dictionary = {}

# Fast lookup maps (id -> dict)
var _class_by_id: Dictionary = {}
var _wealth_by_id: Dictionary = {}
var _item_by_id: Dictionary = {}
var _mission_by_id: Dictionary = {}

func _ready() -> void:
	# Why: Fail fast on boot if data is missing or invalid.
	rules = _load_json_dict(PATH_RULES)
	heroes = _load_json_dict(PATH_HEROES)
	items = _load_json_dict(PATH_ITEMS)
	missions = _load_json_dict(PATH_MISSIONS)
	merchant = _load_json_dict(PATH_MERCHANT)

	_build_indexes()
	_validate_minimum()

	print("[DataDB] Loaded v%s | classes=%d wealth=%d items=%d missions=%d" % [
		str(rules.get("version", "?")),
		heroes.get("classes", []).size(),
		heroes.get("wealth", []).size(),
		items.get("items", []).size(),
		missions.get("missions", []).size()
	])

func _load_json_dict(path: String) -> Dictionary:
	# Why: Centralize file IO + parse errors in one place.
	if not FileAccess.file_exists(path):
		push_error("[DataDB] File not found: " + path)
		return {}

	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("[DataDB] Could not open: " + path)
		return {}

	var text := f.get_as_text()
	var parsed = JSON.parse_string(text)

	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[DataDB] JSON root is not a Dictionary: " + path)
		return {}

	return parsed

func _build_indexes() -> void:
	# Why: O(1) lookups by id; prevents loops sprinkled everywhere.
	_class_by_id.clear()
	for c in heroes.get("classes", []):
		var id := str(c.get("id", ""))
		if id == "":
			push_error("[DataDB] Hero class missing id")
			continue
		_class_by_id[id] = c

	_wealth_by_id.clear()
	for w in heroes.get("wealth", []):
		var id := str(w.get("id", ""))
		if id == "":
			push_error("[DataDB] Wealth entry missing id")
			continue
		_wealth_by_id[id] = w

	_item_by_id.clear()
	for it in items.get("items", []):
		var id := str(it.get("id", ""))
		if id == "":
			push_error("[DataDB] Item missing id")
			continue
		_item_by_id[id] = it

	_mission_by_id.clear()
	for m in missions.get("missions", []):
		var id := str(m.get("id", ""))
		if id == "":
			push_error("[DataDB] Mission missing id")
			continue
		_mission_by_id[id] = m

func _validate_minimum() -> void:
	# Why: Catch obvious setup mistakes before you debug gameplay symptoms.
	if rules.is_empty():
		push_error("[DataDB] rules is empty (parse failed?)")
	if heroes.is_empty():
		push_error("[DataDB] heroes is empty (parse failed?)")
	if items.get("items", []).is_empty():
		push_error("[DataDB] items list is empty")
	if missions.get("missions", []).is_empty():
		push_error("[DataDB] missions list is empty")

	# Optional sanity checks for channel names
	if rules.has("channels") and rules["channels"].has("sale"):
		var allowed_sale: Array = rules["channels"]["sale"]
		_validate_hero_channel_keys("sale_mods", allowed_sale)

	if rules.has("channels") and rules["channels"].has("quest"):
		var allowed_quest: Array = rules["channels"]["quest"]
		_validate_hero_channel_keys("quest_mods", allowed_quest)

func _validate_hero_channel_keys(mods_key: String, allowed: Array) -> void:
	# Why: Prevent silent typos like "qualty_preference" that break balance.
	for class_id in _class_by_id.keys():
		var c: Dictionary = _class_by_id[class_id]
		var mods: Dictionary = c.get(mods_key, {})
		for k in mods.keys():
			# Allow nested dict for type affinities if you use that pattern.
			if str(k) == "type_affinity":
				continue
			if not allowed.has(k):
				push_error("[DataDB] Unknown channel '%s' in %s for class '%s'" % [str(k), mods_key, str(class_id)])

# -------------------------
# Public getters
# -------------------------

func get_rules() -> Dictionary:
	return rules

func get_hero_class(id: String) -> Dictionary:
	return _class_by_id.get(id, {})

func get_wealth(id: String) -> Dictionary:
	return _wealth_by_id.get(id, {})

func get_item(id: String) -> Dictionary:
	return _item_by_id.get(id, {})

func get_mission(id: String) -> Dictionary:
	return _mission_by_id.get(id, {})

func get_random_item() -> Dictionary:
	var arr: Array = items.get("items", [])
	return arr.pick_random() if arr.size() > 0 else {}

func get_random_mission() -> Dictionary:
	var arr: Array = missions.get("missions", [])
	return arr.pick_random() if arr.size() > 0 else {}

func get_random_class_id() -> String:
	var arr: Array = heroes.get("classes", [])
	return str(arr.pick_random().get("id", "")) if arr.size() > 0 else ""

func get_random_wealth_id() -> String:
	var arr: Array = heroes.get("wealth", [])
	return str(arr.pick_random().get("id", "")) if arr.size() > 0 else ""
