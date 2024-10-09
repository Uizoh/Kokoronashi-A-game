extends ParallaxBackground

var scroll_speed = 80;

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(dt: float):
	scroll_offset.x -= scroll_speed * dt;
