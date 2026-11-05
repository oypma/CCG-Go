class_name Deck extends Node2D

const CARD_SCENE_PATH:String = "uid://ben1g0hlxn7t1"
const CARD_DRAW_SPEED:float = 0.2
const STARTING_HAND_SIZE:int = 5

var player_deck:Array[String] = ["knight", "archer", "tornado", "tornado", "demon", "knight", "archer", "knight"]
var o_player_deck:Array[String]
var card_database_reference:Script
var drawn_card_this_turn:bool = false
var cant_draw_manually:bool = false

func _ready() -> void:
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://lonely_scripts/card_database.gd")
	o_player_deck = player_deck.duplicate()
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
		cant_draw_manually = true
		await get_tree().create_timer(0.3).timeout
	cant_draw_manually = false
	drawn_card_this_turn = true

func draw_card() -> void:
	if drawn_card_this_turn:
		return
	
	drawn_card_this_turn = true
	
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
	new_card.card_type = card_database_reference.CARDS[card_drawn_name][2]

	if new_card.card_type == "monster":
		new_card.get_node("Ability").visible = false
		new_card.attack = card_database_reference.CARDS[card_drawn_name][0]
		new_card.get_node("Attack").text = str(new_card.attack)
		new_card.health = card_database_reference.CARDS[card_drawn_name][1]
		new_card.get_node("Health").text = str(new_card.health)
	elif new_card.card_type == "magic":
		new_card.get_node("Attack").visible = false
		new_card.get_node("Health").visible = false
		new_card.get_node("Ability").visible = true
		new_card.get_node("Ability").text = card_database_reference.CARDS[card_drawn_name][3]
		var new_card_ability_script_path:String = card_database_reference.CARDS[card_drawn_name][4]
		if new_card_ability_script_path:
			new_card.ability_script = load(new_card_ability_script_path).new()
	var card_manager:CardManager = get_parent().get_node("CardManager")
	card_manager.add_child(new_card)
	new_card.name = "Card"
	new_card.position = self.global_position
	get_parent().find_child("PlayerHand").add_card_to_hand(new_card, CARD_DRAW_SPEED)
	
	new_card.get_node("AnimationPlayer").play("card_flip")

func reset_draw() -> void:
	drawn_card_this_turn = false

func reset() -> void:
	player_deck = o_player_deck
	player_deck.shuffle()
	$RichTextLabel.text = str(player_deck.size())
	card_database_reference = preload("res://lonely_scripts/card_database.gd")
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
		cant_draw_manually = true
		await get_tree().create_timer(0.3).timeout
	cant_draw_manually = false
	drawn_card_this_turn = true
