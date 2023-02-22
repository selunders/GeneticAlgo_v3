extends Timer

@onready var time_left_timer = $".."

func _on_timeout():
	Events.time_left_changed.emit(time_left_timer.time_left)
