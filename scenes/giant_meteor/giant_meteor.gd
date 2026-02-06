extends Area2D


func _process(dt: float) -> void:
	position.x -= 200 * dt;
	

func _on_body_entered(body: Node2D) -> void:
	if body == get_node("../Player"):
		get_node("../BlackScreen/AnimationPlayer").play("blackscreen");
		get_node("../Player/State").play("cracked");
		$".".queue_free();
		
	if  body == get_node("../Companion1"):
		get_node("../BlackScreen/AnimationPlayer").play("blackscreen");
		get_node("../Companion1").queue_free();
		$".".queue_free();
		
	elif body == get_node("../Companion2"):
		get_node("../BlackScreen/AnimationPlayer").play("blackscreen");
		get_node("../Companion2/State").play("cracked");
		$".".queue_free();
