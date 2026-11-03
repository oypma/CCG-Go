class_name BattleManager extends Node

const SMALL_CARD_SCALE:float = 0.6
const CARD_MOVE_SPEED:float = 0.2
const BATTLE_POS_OFFSET:float = 25

var end_turn_button:Button = null
var opponent_deck:OpponentDeck = null
var empty_monster_card_slots:Array = []
var opponent_hand:OpponentHand = null
var player_health_label:RichTextLabel = null
var opponent_health_label:RichTextLabel = null

var opponent_cards_on_battlefield:Array = []
var player_cards_on_battlefield:Array = []

@export var starting_health:int = 10

var player_health:int = 10
var opponent_health:int = 10

@onready var battle_timer: Timer = $BattleTimer

func _ready() -> void:
	end_turn_button = get_parent().find_child("EndTurnButton")
	opponent_deck = get_parent().find_child("O_Deck")
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	opponent_hand = get_parent().find_child("OpponentHand")
	
	for c in get_parent().get_node("CardSlots/Opponent/MonsterCardSlots").get_children():
		empty_monster_card_slots.append(c)
	
	player_health_label = get_parent().find_child("PlayerHealth")
	opponent_health_label = get_parent().find_child("OpponentHealth")
	
	player_health = starting_health
	player_health_label.text = str(player_health)
	opponent_health = starting_health
	opponent_health_label.text = str(opponent_health)

func _on_end_turn_button_pressed() -> void:
	opponent_turn()
	
func opponent_turn() -> void:
	end_turn_button.disabled = true
	end_turn_button.visible = false
	
	await wait(1)
	
	if opponent_deck.opponent_deck.size() != 0:
		opponent_deck.draw_card()
		await wait(1)


	if empty_monster_card_slots.size() != 0:
		await try_play_card_with_highest_attack()
	
	if opponent_cards_on_battlefield.size() != 0:
		var enemy_cards_to_attack:Array = opponent_cards_on_battlefield.duplicate()
		for card in enemy_cards_to_attack:
			if player_cards_on_battlefield.size() != 0:
				var card_to_attack:Card = player_cards_on_battlefield.pick_random()
				await attack(card, card_to_attack, "opponent")
			else:
				await direct_attack(card, "opponent")
	
	end_opponent_turn()

func direct_attack(attacking_card:Card, attacker:String) -> void:
	var new_pos_y:float = 1080.0
	if attacker == "opponent":
		new_pos_y = 1080
	else:
		new_pos_y = 0
	
	var new_pos:Vector2 = Vector2(attacking_card.position.x, new_pos_y)
	
	attacking_card.z_index = 5
	
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	
	await wait(0.15)
	
	if attacker == "opponent":
		player_health = max(0, player_health - attacking_card.attack)
		player_health_label.text = str(player_health)
	else:
		opponent_health = max(0, player_health - attacking_card.attack)
		opponent_health_label.text = str(opponent_health)
	
	var tween2:Tween = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_in.position, CARD_MOVE_SPEED)
	
	attacking_card.z_index = 0
	await wait(1)

func attack(attacking_card:Card, defending_card:Card, attacker:String) -> void:
	attacking_card.z_index = 5
	var new_pos:Vector2 = Vector2(defending_card.position.x, defending_card.position.y + BATTLE_POS_OFFSET)
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, CARD_MOVE_SPEED)
	await wait(0.15)
	var tween2:Tween = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_in.position, CARD_MOVE_SPEED)
	
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	defending_card.get_node("Health").text = str(defending_card.health)
	attacking_card.health = max(0, attacking_card.health - defending_card.attack)
	attacking_card.get_node("Health").text = str(attacking_card.health)
	
	await wait(1)
	attacking_card.z_index = 0
	
	var card_was_destroyed:bool = false
	
	if attacking_card.health == 0:
		destroy_card(attacking_card, attacker)
	if defending_card.health == 0:
		if attacker == "player":
			destroy_card(defending_card, "opponent")
			card_was_destroyed = true
		else:
			destroy_card(defending_card, "player")
			card_was_destroyed = true
	
	if card_was_destroyed:
		await wait(1.0)

func destroy_card(card:Card, card_owner:String) -> void:
	var new_pos:Vector2 = Vector2.ZERO
	
	if card_owner == "player":
		new_pos = get_parent().find_child("PlayerDiscard").position
	if card_owner == "opponent":
		new_pos = get_parent().find_child("OpponentDiscard").position
	
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, CARD_MOVE_SPEED)

func try_play_card_with_highest_attack() -> void:
	var _opponent_hand:Array = opponent_hand.opponent_hand
	if _opponent_hand.size() == 0:
		end_opponent_turn()
		return
	var random_empty_monster_card_slot:MonsterCardSlot = empty_monster_card_slots.pick_random()
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	var card_with_highest_atk:OpponentCard = _opponent_hand[0]
	for card in _opponent_hand:
		if card.attack > card_with_highest_atk.attack:
			card_with_highest_atk = card
	
	var tween:Tween = get_tree().create_tween()
	tween.tween_property(card_with_highest_atk, "position", random_empty_monster_card_slot.position, CARD_MOVE_SPEED)
	var tween2:Tween = get_tree().create_tween()
	tween2.tween_property(card_with_highest_atk, "scale", Vector2(SMALL_CARD_SCALE, SMALL_CARD_SCALE), CARD_MOVE_SPEED)
	card_with_highest_atk.get_node("AnimationPlayer").play("card_flip")
	
	opponent_hand.remove_card_from_hand(card_with_highest_atk)
	card_with_highest_atk.card_slot_in = random_empty_monster_card_slot
	opponent_cards_on_battlefield.append(card_with_highest_atk)
	await wait(1)

func wait(wait_time:float):
	battle_timer.start(wait_time)
	await battle_timer.timeout

func end_opponent_turn() -> void:
	get_parent().find_child("Deck").reset_draw()
	get_parent().find_child("CardManager").reset_played_monster()
	end_turn_button.disabled = false
	end_turn_button.visible = true
