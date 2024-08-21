extends Area2D

@export var speed = 1000

var velocity = Vector2.ZERO


func _process(delta):
	position += velocity * delta


func start(_transform):
	transform = _transform
	velocity = transform.x * speed


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_body_entered(body: Node2D):
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()


func _on_area_entered(area: Area2D):
	if area.is_in_group("enemies"):
		area.take_damage(1)
