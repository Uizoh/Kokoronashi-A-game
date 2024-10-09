extends Node2D

var time_game: float = 0;

const meteor_scn = preload("res://scenes/meteor/meteor.tscn");
const giant_meteor_src = preload("res://scenes/giant_meteor/giant_meteor.tscn");

var callable: bool = true;
var is_meteor_spawnable: bool = false;


func _ready():
	$BlackScreen/AnimationPlayer.play("start");
	


# Processsssssssssssssssss
func _process(dt: float):
	time_game += dt;
	
	
	if time_game as int == 2 and callable:
		companion1_enters();
		callable = false;
	
	
	# 1st barage
	if time_game as int == 68 and callable:
		is_meteor_spawnable = true;
		callable = false;
		$Companion1.set("is_following_player_behind", true);
		meteor_barage(0.8, 1);
	
	
	if time_game as int == 78 and callable:
		$Companion1.set("is_following_player_behind", false);
		$Companion1.set("is_following_player_infront", true);
		is_meteor_spawnable = false;
		callable = false;
		
	# 1st giant meteor
	if time_game as int == 90 and callable:
		spawn_giant_meteor();
		callable = false
		

func companion1_enters():
	var tween = get_tree().create_tween();
	tween.tween_property($Companion1, "position", Vector2(410, 500), 6);

func companion2_enters():
	var tween = get_tree().create_tween();
	tween.tween_property($Companion2, "position", Vector2(856, 202), 4);


func meteor_barage(min_: float, max_: float):
	while is_meteor_spawnable:
		add_child(meteor_scn.instantiate());
		await get_tree().create_timer(randf_range(min_, max_)).timeout;


func spawn_giant_meteor():
	add_child(giant_meteor_src.instantiate());


func _on_callabler_timeout() -> void:
	callable = true;
