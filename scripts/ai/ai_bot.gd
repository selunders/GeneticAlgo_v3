extends RigidBody2D

class_name ai_bot

var genome:Genome
#var current_state = chase_state
@export var current_target:Node2D = null
var current_state = search_state_spin
var previous_state
var just_switched:bool = true
var search_direction:int = 1
@onready var hitbox:Hitbox = $hitbox
var health:int
var damage:int
var speed:int
var rspeed:int

var fitness = 0
var reproduction_chance = 0
#var player_number:int
#var controls:player_controls
var walls_in_view_count = 0

@onready var animator:AnimatedSprite2D = $AnimatedSprite2D
@onready var search_state_timer = $SearchState/State_Timer
@onready var eyes = $Eyes
@onready var explosion_scene = preload("res://scenes/explosion.tscn")

func _ready():
#	Events.bot_report_self.connect(report_self)
	Events.bot_awake.emit(self)
	init_self()

func init_self():
	if not genome:
		print("Where's my genome?")
	health = genome.dict["STARTING_HEALTH"]
	damage = genome.dict["STARTING_DAMAGE"]
	speed = genome.dict["STARTING_SPEED"]
	rspeed = genome.dict["STARTING_RSPEED"]
	set_mass(genome.dict["MASS"])
	eyes.scale.y = genome.dict["VIEW_DISTANCE"]
	eyes.position.y -= genome.dict["VIEW_DISTANCE"] / 2
	eyes.scale.x = genome.dict["VIEW_WIDTH"]
	animator.play()

func _physics_process(delta):
	var directions = current_state.call(current_target)
#	apply_central_impulse(Vector2(cos(rotation),sin(rotation)) * directions[1] * delta)
	apply_central_impulse(Vector2(sin(-rotation),cos(-rotation)) * -1 * directions[1] * delta)
	apply_torque_impulse(directions[0] * delta)

func chase_state(target):
	if not target:
		switch_state(null, search_state_spin)
		return Vector2(0,0)
#	if self.position.distance_squared_to(target.position) > 10000:
#		current_state = chase_state
	if just_switched == true:
		search_state_timer.start(genome.dict["CHASE_TIME"])
		just_switched = false
	elif search_state_timer.is_stopped():
		switch_state(null, search_state_spin)
		return Vector2(0,0)
	var angle_to_target = (target.position - self.position).angle()
#	print(angle_to_target)
	var angle_diff = angle_to_target - self.rotation
	angle_diff += PI/2
	angle_diff = wrapf(angle_diff, -PI, PI)
	
	return Vector2(rspeed * angle_diff, speed)
#	return Vector2(ROTATIONAL_SPEED * angle_diff, SPEED)
	
func evade_state(target):
	if not target:
		switch_state(null, search_state_spin)
		return Vector2(0,0)
	if self.position.distance_squared_to(target.position) > genome.dict["SAFE_DISTANCE"]:
		switch_state(null, search_state_spin)
		return Vector2(0,0)
	var vector_to_target = (target.position - self.position)
	var angle_to_target = vector_to_target.angle()
#	print(angle_to_target)
	var angle_diff = angle_to_target + self.rotation
	angle_diff += PI/2
	angle_diff = wrapf(angle_diff, -PI, PI)
	return Vector2(rspeed * angle_diff, speed)

func search_state_spin(_target):
	if just_switched:
		search_state_timer.start(genome.dict["SEARCH_ROTATION_TIME"])
		search_direction = search_direction * -1 if randf() < genome.dict["SWITCH_ROTATION_DIRECTION"] else search_direction
		just_switched = false
	if search_state_timer.is_stopped():
		switch_state(null, search_state_move)
	return Vector2(rspeed * 0.5 * search_direction, 0)

func search_state_move(_target):
	if just_switched:
		search_state_timer.start(genome.dict["SEARCH_MOVE_TIME"])
		just_switched = false
	if search_state_timer.is_stopped():
		switch_state(null, search_state_spin)
	return Vector2(0, speed)

func avoid_wall_state(target):
	if just_switched:
		search_state_timer.start(1)
		just_switched = false
#	if walls_in_view_count > 0:
	if not search_state_timer.is_stopped():
		return Vector2(0, -1 * speed * 0.5)
#		return Vector2(rspeed * search_direction * 1, -speed * 0.5)
	else:
		switch_state(target, previous_state)
		return Vector2(0,0)

func switch_state(new_target, new_state):
	just_switched = true
	if new_target != null:
		self.current_target = new_target
	previous_state = current_state
	current_state = new_state

func targeted_by(attacker):
	if randf() < genome.dict["DETECT_TARGETED"]:
		if randf() < genome.dict["ATTACK_ON_TARGETED"]:
			switch_state(attacker, chase_state)
		else:
			switch_state(attacker, evade_state)
	
func _on_eyes_body_entered(body):
	if randf() < genome.dict["SWITCH_FROM_CURRENT_GOAL"] or current_state != chase_state:
		if body is ai_bot and body != self:
			if randf() < genome.dict["SWITCH_TO_ATTACK_STATE"]:
				switch_state(body, chase_state)
				body.targeted_by(self)
#		print("Saw a bot")
#	elif body is Wall:
#		print("Looking at a wall")
#		walls_in_view_count += 1
#		switch_state(current_target, avoid_wall_state)

func _on_eyes_area_entered(area):
	if area is Food:
		if randf() < genome.dict["SWITCH_FROM_CURRENT_GOAL"] or current_state != chase_state:
			var chance:int = 0
			match area.food_index:
				0:
					chance = genome.dict["CHASE_HEALTH_FOOD"]
				1:
					chance = genome.dict["CHASE_DAMAGE_FOOD"]
				2:
					chance = genome.dict["CHASE_SPEED_FOOD"]
				3:
					chance = genome.dict["CHASE_RSPEED_FOOD"]
			if randf() < chance:
				switch_state(area, chase_state)


func _on_attack_timer_timeout():
	if hitbox.current_body != null:
		hitbox.do_damage(damage, self)

func take_damage(amount, attacker):
	health -= amount
#	attacker.fitness += 1
#	fitness -= 1
	if health <= 0:
		attacker.fitness += 10
		attacker.health = attacker.genome.dict["STARTING_HEALTH"]
		var explosion = explosion_scene.instantiate()
		explosion.global_position = global_position
		get_tree().get_root().add_child(explosion)
		queue_free()

func _on_eyes_area_exited(_area):
	pass
#	if area is Wall:
#		walls_in_view_count -= 1

#func _notification(what: int ) -> void:
#	match what:
#		NOTIFICATION_PREDELETE:
#			on_predelete()
#
#func on_predelete():
#
