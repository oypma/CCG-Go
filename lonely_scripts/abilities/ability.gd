class_name Ability extends Node

func trigger_ability(battle_manager:BattleManager, ability_card:Card, input_manager) -> void:
	input_manager.inputs_disabled = true
	battle_manager.enable_end_turn_button(false)
