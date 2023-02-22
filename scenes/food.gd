extends Area2D
class_name Food

enum food_type {
	HEALTH,
	DAMAGE,
	SPEED,
	ROTATIONAL_SPEED
}

@onready var food_index = randi_range(0,3)
@onready var type = food_type.keys()[food_index] 

func _ready():
	$AnimatedSprite2D.frame = food_index

func _on_body_entered(body):
	if body is ai_bot:
		match type:
			food_type.HEALTH:
				body.health += 100
			food_type.DAMAGE:
				body.damage += 50
			food_type.SPEED:
				body.speed += 100
			food_type.ROTATIONAL_SPEED:
				body.rotational_speed += 100
		body.fitness += 5
		queue_free()
