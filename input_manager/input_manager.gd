extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released
signal tutorial_show

const COLLISION_MASK_CARD:int = 1
const COLLISION_MASK_DECK:int = 4
const COLLISION_MASK_OPPONENT_CARD:int = 8

var card_manager_reference:CardManager
var deck_reference:Deck
var inputs_disabled:bool = false

func _ready() -> void:
	card_manager_reference = get_parent().find_child("CardManager")
	deck_reference = get_parent().find_child("Deck")

func _process(delta: float) -> void:
	if Input.is_action_pressed("show_tutorial"):
		for c in get_parent().find_child("Tutorial").get_children():
			c.visible = true
	elif Input.is_action_just_released("show_tutorial"):
		for c in get_parent().find_child("Tutorial").get_children():
			c.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			left_mouse_button_clicked.emit()
			raycast_at_cursor()
		else:
			left_mouse_button_released.emit()

func raycast_at_cursor() -> void:
	if inputs_disabled:
		return
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
				card_manager_reference.card_clicked(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK:
			if !deck_reference.cant_draw_manually:
				deck_reference.draw_card()
		elif result_collision_mask == COLLISION_MASK_OPPONENT_CARD:
			if !deck_reference.cant_draw_manually:
				get_parent().find_child("BattleManager").enemy_card_selected(result[0].collider.get_parent())
