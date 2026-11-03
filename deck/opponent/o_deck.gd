class_name OpponentDeck extends Node2D

const CARD_SCENE_PATH:String = "uid://ccwhw645gd31j"
const CARD_DRAW_SPEED:float = 0.2
const STARTING_HAND_SIZE:int = 5

var opponent_deck:Array[String] = ["knight", "archer", "demon", "knight", "knight", "knight", "knight", "knight"]
var card_database_reference:Script
var cant_draw_manually:bool = false

func _ready() -> void:
	opponent_deck.shuffle()
	$RichTextLabel.text = str(opponent_deck.size())
	card_database_reference = preload("res://card_database.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		cant_draw_manually = true
		await get_tree().create_timer(0.3).timeout
	cant_draw_manually = false

func draw_card() -> void:
	var card_drawn_name:String = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)
	
	if opponent_deck.size() == 0:
		$Sprite2D.visible = false
		$RichTextLabel.visible = false
	
	$RichTextLabel.text = str(opponent_deck.size())
	var card_scene:PackedScene = preload(CARD_SCENE_PATH)
	var new_card:OpponentCard = card_scene.instantiate()
	var card_image_path:String = str("res://sprites/" + card_drawn_name + ".png")
	new_card.get_node("CardImage").texture = load(card_image_path)
	new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
	new_card.get_node("Attack").text = str(new_card.attack)
	new_card.health = card_database_reference.CARDS[card_drawn_name][1]
	new_card.get_node("Health").text = str(new_card.health)
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][2]
	
	
	var card_manager:CardManager = get_parent().get_node("CardManager")
	card_manager.add_child(new_card)
	new_card.name = "Card"
	new_card.position = self.global_position
	get_parent().find_child("OpponentHand").add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.find_child("CardImageBack").show()
