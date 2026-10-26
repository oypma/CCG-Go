class_name Card
extends Node2D

signal hovered(card:Card)
signal hovered_off(card:Card)

var starting_position:Vector2

func _ready() -> void:
	get_parent().connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)
