extends Button

@export var time_scale:float = 1

func _on_pressed():
	TimeControls.set_time_scale.emit(time_scale)
