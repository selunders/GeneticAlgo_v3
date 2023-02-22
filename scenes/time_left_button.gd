extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.time_left_changed.connect(update_text)

func update_text(timeLeft:int):
	self.text = String.num(timeLeft, 0)
