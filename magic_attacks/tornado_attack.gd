class_name TornadoAttack extends Node2D

const TORNADO_DAMAGE = 1

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is MonsterCardSlot:
		var cards_to_destroy:Array = []
		if area.get_parent().card_in_slot_ref:
			area.get_parent().card_in_slot_ref.health = max(0, area.get_parent().card_in_slot_ref.health - TORNADO_DAMAGE)
			area.get_parent().card_in_slot_ref.get_node("Health").text = str(area.get_parent().card_in_slot_ref.health)
			if area.get_parent().card_in_slot_ref.health == 0:
				cards_to_destroy.append(area.get_parent().card_in_slot_ref)
			if cards_to_destroy.size() > 0:
				for card in cards_to_destroy:
					get_parent().find_child("BattleManager").destroy_card(card, "opponent")
