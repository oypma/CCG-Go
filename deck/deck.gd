class_name Deck extends Node2D

const CARD_SCENE_PATH:String = "uid://ben1g0hlxn7t1"
const CARD_DRAW_SPEED:float = 0.2

var player_deck:Array[String] = ["knight", "knight", "knight"]

func _ready() -> void:
	$RichTextLabel.text = str(player_deck.size())

func draw_card() -> void:
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	var card_scene:PackedScene = preload(CARD_SCENE_PATH)
	var new_card:Card = card_scene.instantiate()
	var card_manager:CardManager = get_parent().get_node("CardManager")
	card_manager.add_child(new_card)
	new_card.name = "Card"
	get_parent().find_child("PlayerHand").add_card_to_hand(new_card, CARD_DRAW_SPEED)
