extends Projectile

const ARROW_DAMAGE:int = 1

func fly(battle_manager:BattleManager, target_player:String):
	var target_to_go_to = null
	if target_player == "player_1":
		target_to_go_to = get_parent().find_child("Player1")
	else:
		target_to_go_to = get_parent().find_child("Player2")

	var target_pos:Vector2 = Vector2.ZERO
	look_at(target_to_go_to.position)
	print(rotation_degrees)
	var tween:Tween = create_tween()
	tween.tween_property(self, "position", target_pos, 1)
	await tween.finished
	battle_manager.direct_damage(ARROW_DAMAGE)
	queue_free()
