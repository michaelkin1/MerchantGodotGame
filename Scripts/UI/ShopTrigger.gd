extends Area2D

@export var main_path: NodePath

func _ready() -> void:
	input_pickable = true

func _input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		
		print("WAGON CLICKED")

		var main = get_node(main_path)
		main.open_shop()
