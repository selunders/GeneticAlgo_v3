extends Control

signal set_time_scale

func _ready():
	set_time_scale.connect(func(multiplier): Engine.time_scale = multiplier)
