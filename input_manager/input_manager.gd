extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD:int = 1
const COLLISION_MASK_DECK:int = 4

var card_manager_reference:CardManager
var deck_reference:Deck

func _ready() -> void:
	card_manager_reference = get_parent().find_child("CardManager")
	deck_reference = get_parent().find_child("Deck")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			left_mouse_button_clicked.emit()
			raycast_at_cursor()
		else:
			left_mouse_button_released.emit()

func raycast_at_cursor() -> void:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask:int =  result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD:
			var card_found:Card = result[0].collider.get_parent()
			if card_found:
				card_manager_reference.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			deck_reference.draw_card()
