extends Node2D

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main/main.tscn");


func _on_exit_button_pressed():
	get_tree().quit();
