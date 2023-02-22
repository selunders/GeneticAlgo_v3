extends Area2D

class_name Hitbox

var current_body = null

func _on_body_entered(body):
	if body is ai_bot:
		current_body = body

func _on_body_exited(body):
	if body == current_body:
		current_body = null

func do_damage(amount, attacker):
	if current_body:
		current_body.take_damage(amount, attacker)
