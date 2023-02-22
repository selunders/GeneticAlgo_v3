extends Area2D

@onready var food_timer:Timer = $FoodTimer
@onready var food_scene:PackedScene = preload("res://scenes/food.tscn")
@onready var foodList = $FoodList
@onready var collider:Rect2 = $CollisionShape2D.shape.get_rect()
@onready var height = collider.size.y / 2
@onready var width = collider.size.x / 2
@onready var center = collider.get_center()

func _on_timer_timeout():
	for i in range(0,1):
		var new_food = food_scene.instantiate()
		new_food.position = Vector2(randi_range(center.x-width,center.x+width), randi_range(center.y-height, center.y+height))
		new_food.position += position
		foodList.add_child(new_food)


func _on_gen_timer_timeout():
	for food in foodList.get_children():
		food.queue_free()
