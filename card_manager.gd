class_name CardManager extends Node2D

@export var card_hover_scale:Vector2 = Vector2(1.05, 1.05)

const COLLISION_MASK_CARD:int = 1
const COLLISION_MASK_CARD_SLOT:int = 2
const DEFAULT_CARD_MOVE_SPEED:float = 0.1

var screen_size:Vector2
var card_being_dragged:Card
var is_hovering_on_card:bool = false
var player_hand_reference:PlayerHand

func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_hand_reference = $"../PlayerHand"
	$"../InputManager".left_mouse_button_released.connect(on_left_click_released)

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos:Vector2 = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), 
		clamp(mouse_pos.y, 0, screen_size.y))

func start_drag(card:Card):
	card_being_dragged = card
	card.scale = Vector2.ONE

func finish_drag(card:Card):
	var card_slot_found:CardSlot = raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_in_slot:
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_in_slot = true
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged, DEFAULT_CARD_MOVE_SPEED)
	card.scale = card_hover_scale
	card_being_dragged = null

func connect_card_signals(card:Card) -> void:
	card.hovered.connect(on_hovered_over_card)
	card.hovered_off.connect(on_hovered_off_card)

func on_left_click_released() -> void:
	if card_being_dragged:
		finish_drag(card_being_dragged)

func on_hovered_over_card(card:Card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card:Card):
	if !card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered:Card = raycast_check_for_card()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card:Card, hovered:bool) -> void:
	if hovered:
		card.scale = card_hover_scale
		card.z_index = 2
	else:
		card.scale = Vector2.ONE
		card.z_index = 1

func raycast_check_for_card_slot() -> CardSlot:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

func raycast_check_for_card() -> Card:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

func get_card_with_highest_z_index(cards:Array[Dictionary]) -> Card:
	var highest_z_card:Card = cards[0].collider.get_parent()
	var highest_z_index:int = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card:Card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	
	return highest_z_card
