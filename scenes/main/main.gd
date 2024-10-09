extends Node2D


func _ready():
	pass


func _process(_dt: float):
	pass


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://scenes/world/world.tscn");


func _on_exit_button_pressed():
	get_tree().quit();
