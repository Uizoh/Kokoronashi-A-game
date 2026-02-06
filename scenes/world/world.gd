extends Node2D

var time_game: float = 0;
var rng = RandomNumberGenerator.new();

const end_title_scn = preload("res://scenes/end_credits/end_credits.tscn");
const game_end_buttons_scn = preload("res://scenes/game_end_buttons/game_end_buttons.tscn");

# Player and Companion vars
@export var PLAYER: CharacterBody2D;
@export var COMPANION1: CharacterBody2D;
@export var COMPANION2: CharacterBody2D;

# The state of the companion
enum CompanionState {
	NOT_FOLLOWING,
	FOLLOWING_FRONT_UP,
	FOLLOWING_FRONT_DOWN,
	FOLLOWING_BACK_UP,
	FOLLOWING_BACK_DOWN,
	FOLLOWING_FRONT,
	FOLLOWING_BACK,
	TOGETHER,
};

# List of events for companion
var companion1_events := [];
var companion2_events := [];

const comp_speed: float = 120.0;

var companion1_state: CompanionState = CompanionState.NOT_FOLLOWING;
var companion2_state: CompanionState = CompanionState.NOT_FOLLOWING;

const offset_x: Vector2 = Vector2(120, 0); # for front and back only

var offset_fd = Vector2(rng.randi_range(80, 160), rng.randi_range(90, 140)); # front down
var offset_fu = Vector2(rng.randi_range(54, 160), rng.randi_range(-140, -50));# front up
var offset_bd = Vector2(rng.randi_range(-160, -68), rng.randi_range(60, 140)); # back down
var offset_bu = Vector2(rng.randi_range(-160, -72), rng.randi_range(-140, -78)); # back up

# Meteor vars
const meteor_scn = preload("res://scenes/meteor/meteor.tscn");
const giant_meteor_scn = preload("res://scenes/giant_meteor/giant_meteor.tscn");

var is_meteor_barrage_running: bool = false;

enum MeteorState {
	SPAWNABLE,
	NOT_SPAWNABLE
};

# List of events for meteor
var meteor_events := [
	{ time = 78, state = MeteorState.SPAWNABLE, min = 0.8, max = 1.0, done = false },
	{ time = 84, state = MeteorState.SPAWNABLE, min = 0.4, max = 0.6, done = false },
	{ time = 90, state = MeteorState.NOT_SPAWNABLE, min = 100, max = 100, done = false },
	{ time = 140, state = MeteorState.SPAWNABLE, min = 0.8, max = 1.0, done = false },
	{ time = 150, state = MeteorState.SPAWNABLE, min = 0.2, max = 0.6, done = false },
	{ time = 162, state = MeteorState.NOT_SPAWNABLE, min = 100, max = 100, done = false },
	{ time = 210, state = MeteorState.SPAWNABLE, min = 0.4, max = 0.6, done = false },
	{ time = 220, state = MeteorState.NOT_SPAWNABLE, min = 100, max = 100, done = false },
];

var meteor_state := MeteorState.NOT_SPAWNABLE;

# List of all one time events
var one_time_events := [
	{ time = 12, fun = companion1_enters, done = false }, # Companion 1 enters
	{ time = 98, fun = spawn_giant_meteor, done = false }, # 1st Giant meteor
	{ time = 172, fun = spawn_giant_meteor, done = false }, # 2nd Giant meteor
	{ time = 200, fun = companion2_enters, done = false }, # Companion 2 enters
	{ time = 222, fun = spawn_giant_meteor, done = false }, # 3rd Giant meteor
	{ time = 238, fun = stop_player_controls, done = false },
	{ time = 250, fun = end_move_forward, done = false },
	{ time = 266, fun = roll_end_credits, done = false },
	{ time = 280, fun = spawn_game_end_buttons, done = false },
];


func _ready():
	$BlackScreen/AnimationPlayer.play("start");
	companion1_events = [
		{ time = 16.0, state = CompanionState.FOLLOWING_FRONT, done = false },
		{ time = 18.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 24.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 27.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 32.0, state = CompanionState.FOLLOWING_BACK_UP, done = false },
		{ time = 36.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 40.0, state = CompanionState.FOLLOWING_FRONT, done = false },
		{ time = 44.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 46.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 50.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 54.0, state = CompanionState.FOLLOWING_BACK_UP, done = false },
		{ time = 58.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 60.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 64.0, state = CompanionState.FOLLOWING_BACK_UP, done = false },
		{ time = 68.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 72.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 74.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 78.0, state = CompanionState.FOLLOWING_BACK, done = false },
		{ time = 84.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 88.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 92.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 96.0, state = CompanionState.FOLLOWING_BACK, done = false }, 	# 1st
		{ time = 108.0, state = CompanionState.FOLLOWING_BACK_UP, done = false },
		{ time = 112.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 114.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 120.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 123.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 127.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 130.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 134.0, state = CompanionState.FOLLOWING_FRONT, done = false },
		{ time = 136.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 138.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 140.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 142.0, state = CompanionState.FOLLOWING_BACK_UP, done = false },
		{ time = 145.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 148.0, state = CompanionState.FOLLOWING_BACK, done = false },
		{ time = 152.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 156.0, state = CompanionState.FOLLOWING_BACK_UP, done = false },
		{ time = 158.0, state = CompanionState.FOLLOWING_BACK, done = false },
		{ time = 160.0, state = CompanionState.FOLLOWING_BACK_UP, done = false },
		{ time = 162.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 166.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 168.0, state = CompanionState.FOLLOWING_FRONT, done = false },	# 2nd
		
	];
	
	companion2_events = [
		{ time = 202.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 206.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 210.0, state = CompanionState.FOLLOWING_BACK_DOWN, done = false },
		{ time = 212.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 214.0, state = CompanionState.FOLLOWING_FRONT, done = false },
		{ time = 215.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 221.0, state = CompanionState.FOLLOWING_FRONT, done = false },
		{ time = 232.0, state = CompanionState.FOLLOWING_FRONT_UP, done = false },
		{ time = 236.0, state = CompanionState.FOLLOWING_FRONT_DOWN, done = false },
		{ time = 238.0, state = CompanionState.TOGETHER, done = false },
	];


# Process time, events and state changes
func _process(dt: float):
	time_game += dt;
	
	if time_game < 182: 
		_handle_companion1_events();
	else:
		_handle_companion2_events();
	
	_handle_meteor_events();
	_handle_one_time_events();


# Procss companion movement/velocity
func _physics_process(_dt: float) -> void:
	if is_instance_valid(COMPANION1):
		match companion1_state:
			CompanionState.FOLLOWING_FRONT:
				companion_follow_front(COMPANION1);
			CompanionState.FOLLOWING_BACK:
				companion_follow_back(COMPANION1);
			CompanionState.FOLLOWING_FRONT_UP:
				companion_follow_fu(COMPANION1);
			CompanionState.FOLLOWING_FRONT_DOWN:
				companion_follow_fd(COMPANION1);
			CompanionState.FOLLOWING_BACK_UP:
				companion_follow_bu(COMPANION1);
			CompanionState.FOLLOWING_BACK_DOWN:
				companion_follow_bd(COMPANION1);
			CompanionState.NOT_FOLLOWING:
				pass
	if is_instance_valid(COMPANION2):
		match companion2_state:
			CompanionState.FOLLOWING_FRONT:
				companion_follow_front(COMPANION2);
			CompanionState.FOLLOWING_BACK:
				companion_follow_back(COMPANION2);
			CompanionState.FOLLOWING_FRONT_UP:
				companion_follow_fu(COMPANION2);
			CompanionState.FOLLOWING_FRONT_DOWN:
				companion_follow_fd(COMPANION2);
			CompanionState.FOLLOWING_BACK_UP:
				companion_follow_bu(COMPANION2);
			CompanionState.FOLLOWING_BACK_DOWN:
				companion_follow_bd(COMPANION2);
			CompanionState.TOGETHER:
				companion_follow_together(COMPANION2);
			CompanionState.NOT_FOLLOWING:
				pass


# Other functions
func companion1_enters():
	var tween = get_tree().create_tween();
	tween.tween_property(COMPANION1, "position", Vector2(410, 500), 6);
#
func companion2_enters():
	var tween = get_tree().create_tween();
	tween.tween_property(COMPANION2, "position", Vector2(856, 202), 4);


func set_meteor_state(new_state: MeteorState, min_: float, max_: float):
	if meteor_state == new_state: 
		return;
	
	meteor_state = new_state;
	match meteor_state:
		MeteorState.SPAWNABLE:
			meteor_barrage(min_, max_);
		MeteorState.NOT_SPAWNABLE:
			is_meteor_barrage_running = false;

func meteor_barrage(min_: float, max_: float):
	if is_meteor_barrage_running:
		pass
	
	is_meteor_barrage_running = true;
	while is_meteor_barrage_running:
		add_child(meteor_scn.instantiate());
		await get_tree().create_timer(randf_range(min_, max_)).timeout;


func spawn_giant_meteor():
	add_child(giant_meteor_scn.instantiate());

# All companion following player functions
func companion_follow_together(companion: CharacterBody2D):
	var target_pos: Vector2 = PLAYER.global_position + Vector2(0, 60);
	var direction: Vector2 = target_pos - companion.global_position;
	var distance: float = direction.length();
	
	if distance < 4.0:
		companion.velocity = Vector2.ZERO;
		return;
		
	var slowdown_radius: float = 60.0;
	var t: Variant = clamp(distance / slowdown_radius, 0.2, 1.0);
	
	companion.velocity = direction.normalized() * (comp_speed + 100) * t;


func companion_follow_front(companion: CharacterBody2D):
	var target_pos: Vector2 = PLAYER.global_position + offset_x
	var direction: Vector2 = target_pos - companion.global_position;
	var distance: float = direction.length();
	
	if distance < 4.0:
		companion.velocity = Vector2.ZERO;
		return;
		
	var slowdown_radius: float = 60.0;
	var t: Variant = clamp(distance / slowdown_radius, 0.2, 1.0);
	
	companion.velocity = direction.normalized() * (comp_speed + 80) * t;


func companion_follow_fd(companion: CharacterBody2D):
	var target_pos: Vector2 = PLAYER.global_position + offset_fd;
	var direction: Vector2 = target_pos - companion.global_position;
	var distance: float = direction.length();
	
	if distance < 4.0:
		companion.velocity = Vector2.ZERO;
		return;
		
	var slowdown_radius: float = 60.0;
	var t: Variant = clamp(distance / slowdown_radius, 0.2, 1.0);
	
	companion.velocity = direction.normalized() * comp_speed * t;


func companion_follow_bd(companion: CharacterBody2D):
	var target_pos: Vector2 = PLAYER.global_position + offset_bd;
	var direction: Vector2 = target_pos - companion.global_position;
	var distance: float = direction.length();
	
	if distance < 4.0:
		companion.velocity = Vector2.ZERO;
		return;
		
	var slowdown_radius: float = 60.0;
	var t: Variant = clamp(distance / slowdown_radius, 0.2, 1.0);
	
	companion.velocity = direction.normalized() * comp_speed * t;

func companion_follow_fu(companion: CharacterBody2D):
	var target_pos: Vector2 = PLAYER.global_position + offset_fu;
	var direction: Vector2 = target_pos - companion.global_position;
	var distance: float = direction.length();
	
	if distance < 4.0:
		companion.velocity = Vector2.ZERO;
		return;
		
	var slowdown_radius: float = 60.0;
	var t: Variant = clamp(distance / slowdown_radius, 0.2, 1.0);
	
	companion.velocity = direction.normalized() * comp_speed * t;


func companion_follow_bu(companion: CharacterBody2D):
	var target_pos: Vector2 = PLAYER.global_position + offset_bu;
	var direction: Vector2 = target_pos - companion.global_position;
	var distance: float = direction.length();
	
	if distance < 4.0:
		companion.velocity = Vector2.ZERO;
		return;
		
	var slowdown_radius: float = 60.0;
	var t: Variant = clamp(distance / slowdown_radius, 0.2, 1.0);
	
	companion.velocity = direction.normalized() * comp_speed * t;


func companion_follow_back(companion: CharacterBody2D):
	var target_pos: Vector2 = PLAYER.global_position - offset_x;
	var direction: Vector2 = target_pos - companion.global_position;
	var distance: float = direction.length();
	
	if distance < 4.0:
		companion.velocity = Vector2.ZERO;
		return;
		
	var slowdown_radius: float = 60.0;
	var t: Variant = clamp(distance / slowdown_radius, 0.2, 1.0);
	
	companion.velocity = direction.normalized() * (comp_speed + 80) * t;


func stop_player_controls():
	$Player.playable = false;
	var tween = get_tree().create_tween();
	tween.tween_property(PLAYER, "position", Vector2(540, 324), 8);

func end_move_forward():
	var tween = get_tree().create_tween();
	tween.tween_property(PLAYER, "position", Vector2(1352, 324), 32);


func roll_end_credits():
	add_child(end_title_scn.instantiate());

func spawn_game_end_buttons():
	add_child(game_end_buttons_scn.instantiate());


func _handle_companion1_events():
	for event in companion1_events:
		if time_game >= event.time and not event.done:
			if is_instance_valid(COMPANION1):
				companion1_state = event.state;
				event.done = true


func _handle_companion2_events():
	for event in companion2_events:
		if time_game >= event.time and not event.done:
			if is_instance_valid(COMPANION2):
				companion2_state = event.state;
				event.done = true


func _handle_meteor_events():
	for event in meteor_events:
		if time_game >= event.time and not event.done:
			set_meteor_state(event.state, event.min, event.max);
			event.done = true


func _handle_one_time_events():
	for event in one_time_events:
		if time_game >= event.time and not event.done:
			event.fun.call();
			event.done = true
