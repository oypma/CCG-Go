extends Ability

const TORNADO_DAMAGE = 1

func trigger_ability(battle_manager:BattleManager, ability_card:Card, input_manager) -> void:
	super(battle_manager, ability_card, input_manager)
	await battle_manager.wait(1.0)
	var cards_to_destroy:Array = []
	for card in battle_manager.opponent_cards_on_battlefield:
		card.health = max(0, card.health - TORNADO_DAMAGE)
		card.get_node("Health").text = str(card.health)
		if card.health == 0:
			cards_to_destroy.append(card)
			
	await battle_manager.wait(1.0)
	
	if cards_to_destroy.size() > 0:
		for card in cards_to_destroy:
			battle_manager.destroy_card(card, "opponent")
	
	battle_manager.destroy_card(ability_card, "player")
	await battle_manager.wait(1.0)
	battle_manager.enable_end_turn_button()
	
	input_manager.inputs_disabled = false
