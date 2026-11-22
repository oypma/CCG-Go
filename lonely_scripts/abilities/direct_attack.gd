extends WhenAttacking

const PROJECTILE = preload("res://magic_attacks/arrow.tscn")

func trigger_ability(battle_manager:BattleManager, ability_card:Card, input_manager) -> void:
	super(battle_manager, ability_card, input_manager)
	
	await deploy_projectile(battle_manager, ability_card)
	
	await battle_manager.wait(1.0)
	
	battle_manager.enable_end_turn_button()
	
	input_manager.inputs_disabled = false

func deploy_projectile(battle_manager:BattleManager, ability_card:Card) -> void:
	var projectile = PROJECTILE.instantiate()
	battle_manager.get_parent().add_child(projectile)
	projectile.position = ability_card.position
	var target_player:String = "player_1"
	if ability_card is PlayerCard:
		target_player = "player_2"
	await projectile.fly(battle_manager, target_player)
