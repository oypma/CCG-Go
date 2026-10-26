class_name PlayerHand extends Node2D

const HAND_COUNT:int = 2
const CARD_SCENE_PATH:String = "uid://ben1g0hlxn7t1"
const CARD_WIDTH:float = 200.0
const HAND_Y_POSITION:float = 890.0

var player_hand:Array = []
var center_screen_x:float

func _ready() -> void:
	center_screen_x = get_viewport().get_visible_rect().size.x / 2
	
	var card_scene:PackedScene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_card:Card = card_scene.instantiate()
		var card_manager:CardManager = get_parent().get_node("CardManager")
		card_manager.add_child(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)

func add_card_to_hand(card:Card) -> void:
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.starting_position)

func update_hand_positions() -> void:
	for i in range(player_hand.size()):
		var new_position:Vector2 = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var card:Card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position)

func calculate_card_position(index:int) -> float:
	var total_width:float = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset:float = center_screen_x + index * CARD_WIDTH - total_width / 2
	return x_offset

func animate_card_to_position(card:Card, pos:Vector2):
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(card, "position", pos, 0.1)

func remove_card_from_hand(card:Card) -> void:
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
