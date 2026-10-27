class_name PlayerHand extends Node2D

const CARD_WIDTH:float = 200.0
const HAND_Y_POSITION:float = 890.0
const DEFAULT_CARD_MOVE_SPEED:float = 0.1

var player_hand:Array = []
var center_screen_x:float

func _ready() -> void:
	center_screen_x = get_viewport().get_visible_rect().size.x / 2 

func add_card_to_hand(card:Card, speed:float) -> void:
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.starting_position, DEFAULT_CARD_MOVE_SPEED)

func update_hand_positions(speed:float) -> void:
	for i in range(player_hand.size()):
		var new_position:Vector2 = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card:Card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index:int) -> float:
	var total_width:float = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset:float = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

func animate_card_to_position(card:Card, pos:Vector2, speed:float):
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(card, "position", pos, speed)

func remove_card_from_hand(card:Card) -> void:
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions(DEFAULT_CARD_MOVE_SPEED)
