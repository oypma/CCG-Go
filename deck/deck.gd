class_name Deck extends Node2D

const CARD_SCENE_PATH:String = "uid://ben1g0hlxn7t1"
const CARD_DRAW_SPEED:float = 0.2

var player_deck:Array[String] = ["knight", "archer", "demon", "knight"]
var card_database_reference:Script

func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://card_database.gd")

func draw_card() -> void:
	var card_drawn_name:String = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(player_deck.size())
	var card_scene:PackedScene = preload(CARD_SCENE_PATH)
	var new_card:Card = card_scene.instantiate()
	var card_image_path:String = str("res://sprites/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.get_node("Attack").text = str(card_database_reference.CARDS[card_drawn_name][0])
	new_card.get_node("Health").text = str(card_database_reference.CARDS[card_drawn_name][1])
	
	var card_manager:CardManager = get_parent().get_node("CardManager")
	card_manager.add_child(new_card)
	new_card.name = "Card"
	new_card.position = self.global_position
	get_parent().find_child("PlayerHand").add_card_to_hand(new_card, CARD_DRAW_SPEED)
	
	new_card.get_node("AnimationPlayer").play("card_flip")
