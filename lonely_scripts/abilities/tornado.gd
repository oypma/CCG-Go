extends Ability

const TORNADO = preload("res://magic_attacks/tornado_attack.tscn")

func trigger_ability(battle_manager:BattleManager, ability_card:Card, input_manager) -> void:
	super(battle_manager, ability_card, input_manager)
	await battle_manager.wait(1.0)
	
	await deploy_tornado(battle_manager)
	await battle_manager.wait(1.0)
	battle_manager.destroy_card(ability_card, "player")
	await battle_manager.wait(1.0)
	
	battle_manager.enable_end_turn_button()
	
	input_manager.inputs_disabled = false

func deploy_tornado(battle_manager:BattleManager) -> void:
	var tornado_child = TORNADO.instantiate()
	battle_manager.get_parent().add_child(tornado_child)
	tornado_child.get_node("AnimationPlayer").play("roll")
	await tornado_child.get_node("AnimationPlayer").animation_finished
	tornado_child.queue_free()
