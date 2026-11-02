class_name BattleManager extends Node

const SMALL_CARD_SCALE:float = 0.6
const CARD_MOVE_SPEED:float = 0.2

var end_turn_button:Button = null
var opponent_deck:OpponentDeck = null
var empty_monster_card_slots:Array = []
var opponent_hand:OpponentHand = null

@onready var battle_timer: Timer = $BattleTimer

func _ready() -> void:
	end_turn_button = get_parent().find_child("EndTurnButton")
	opponent_deck = get_parent().find_child("O_Deck")
	end_turn_button.pressed.connect(_on_end_turn_button_pressed)
	opponent_hand = get_parent().find_child("OpponentHand")
	
	for c in get_parent().get_node("CardSlots/Opponent").get_children():
		empty_monster_card_slots.append(c)

func _on_end_turn_button_pressed() -> void:
	opponent_turn()
	
func opponent_turn() -> void:
	end_turn_button.disabled = true
	end_turn_button.visible = false
	
	battle_timer.start()
	await battle_timer.timeout
	
	if opponent_deck.opponent_deck.size() != 0:
		opponent_deck.draw_card()
		battle_timer.start()
		await battle_timer.timeout

	if empty_monster_card_slots.size() == 0:
		end_opponent_turn()
		return
	
	await try_play_card_with_highest_attack()
	
	end_opponent_turn()

func try_play_card_with_highest_attack() -> void:
	var _opponent_hand:Array = opponent_hand.opponent_hand
	if _opponent_hand.size() == 0:
		end_opponent_turn()
		return
	var random_empty_monster_card_slot:MonsterCardSlot = empty_monster_card_slots[randi_range(0, empty_monster_card_slots.size() - 1)]
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
	
	battle_timer.start()
	await battle_timer.timeout

func end_opponent_turn() -> void:
	get_parent().find_child("Deck").reset_draw()
	get_parent().find_child("CardManager").reset_played_monster()
	end_turn_button.disabled = false
	end_turn_button.visible = true
