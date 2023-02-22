extends Button


func _on_pressed():
	Events.end_tests.emit()
