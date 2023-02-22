extends RigidBody2D

class_name player

@export var SPEED = 300.0
#@export_enum("It", "Not_It") var tagged:int

@export var ROTATIONAL_SPEED = 400.0
var player_number:int
var controls:player_controls
@onready var tagged_visual = $Tagged
@onready var tag_warmup_timer = $Timer
@onready var animator:AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	tag_warmup_timer.start()
	remove_child(tagged_visual)
	Events.player_awake.emit(self)

func set_controls(new_controls:player_controls):
	self.controls = new_controls
	print("Player ", player_number, " is awake")
	self.animator.frames = new_controls.sprite_set

func _physics_process(delta):
	var direction_x = Input.get_axis(controls.leftInput, controls.rightInput)
	var direction_y = Input.get_axis(controls.upInput, controls.downInput)
#	apply_central_impulse(Vector2(cos(rotation),sin(rotation)) * SPEED * direction_y *delta)
	apply_central_impulse(Vector2(sin(-rotation),cos(-rotation)) * SPEED * direction_y *delta)
	apply_torque_impulse(direction_x*ROTATIONAL_SPEED*delta)
	if not direction_y:
		apply_central_impulse()

func tagged():
	add_child(tagged_visual)
	tag_warmup_timer.start()


func _on_body_entered(body):
	if tag_warmup_timer.is_stopped():
		if body is player:
			print("Collided with player")
			remove_child(tagged_visual)
			body.tagged()
