extends WhenPlayed

func trigger_ability(battle_manager:BattleManager, ability_card:Card, input_manager) -> void:
	await super(battle_manager, ability_card, input_manager)
	if ability_card == battle_manager.get_parent().find_child("CardManager").card_played_this_turn:
		battle_manager.get_parent().find_child("CardManager").card_played_this_turn = null
	input_manager.inputs_disabled = false
	battle_manager.enable_end_turn_button(true)
