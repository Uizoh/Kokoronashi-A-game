extends CharacterBody2D

var is_following_player_behind: bool = false;
var is_following_player_infront: bool = false;

func _process(_dt: float):
	move_and_slide();
	
	if get_node("../").get("time_game") as int == 60 and is_following_player_behind:
		follow_behind_player();
		
	if get_node("../").get("time_game") as int == 80 and is_following_player_infront:
		follow_infront_player();
	
	
func follow_behind_player():
	position = get_node("../Player").position - Vector2(100, 0);
	
func follow_infront_player():
	position = get_node("../Player").position + Vector2(100, 0);
