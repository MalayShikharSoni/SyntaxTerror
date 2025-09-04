extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var speed: int = 600
var direction: int = 1

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta

# Bullet disappears when colliding with something
func _on_body_entered(body: Node) -> void:
	queue_free()

# Bullet disappears when leaving the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
