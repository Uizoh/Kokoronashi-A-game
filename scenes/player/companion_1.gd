extends CharacterBody2D


@export var player: Node2D         # Reference to the player
const follow_speed: float = 5.0
var follow_time: float = 10.0   # How long to follow in seconds
var x_offset: float = 100.0  
var following: bool = true
var timer: float = 0.0

func _process(dt: float):
	move_and_slide();
	
	if following and player:
		# Target position (with X offset)
		var target = player.global_position + Vector2(x_offset, 0)
		# Smoothly move toward target
		global_position = global_position.lerp(target, follow_speed * dt)
		# Countdown timer
		timer -= dt
		if timer <= 0:
			following = false



func start_follow(in_front: bool = false) -> void:
	following = true
	timer = follow_time
	x_offset = (50.0 if in_front else -50.0) # adjust distance

	
