extends Resource

class_name Genome

#var mutation_rate = 0.3
var mutation_rate = 0.5

@export var dict = {
	"SAFE_DISTANCE" = 10000,
	"SEARCH_ROTATION_TIME" = randf(),
	"SEARCH_MOVE_TIME" = randf(),
	"SWITCH_ROTATION_DIRECTION" = randf(),
	"EVADE_ON_TARGETED" = randf(),
	"ATTACK_ON_TARGETED" = randf(),
	"DETECT_TARGETED" = randf(),
	"CHASE_HEALTH_FOOD" = randf(),
	"CHASE_SPEED_FOOD" = randf(),
	"CHASE_RSPEED_FOOD" = randf(),
	"CHASE_DAMAGE_FOOD" = randf(),
	"SWITCH_FROM_CURRENT_GOAL" = randf(),
	"SWITCH_TO_ATTACK_STATE" = randf(),
	"STARTING_SPEED" = randf_range(100,300),
	"STARTING_RSPEED" = randf_range(100,300),
	"STARTING_HEALTH" = 100,
	"STARTING_DAMAGE" = 20,
	"VIEW_DISTANCE" = 5,
	"VIEW_WIDTH" = 5,
	"MASS" = 2,
	"CHASE_TIME" = 3
	}

func print_genome():
	for key in dict.keys():
		print(key, ": ", dict[key])

func make_child():
	var new_genome = self.duplicate(true)
	new_genome.dict = dict.duplicate(true)
	new_genome.mutate()
#	new_genome.print_genome()
	return new_genome

func mutate():
	for key in dict.keys():
		if randf() < mutation_rate:
			match key:
				"SAFE_DISTANCE":
					dict[key] += randi_range(-5000,5000)
				"STARTING_SPEED":
					dict[key] += randi_range(-300, 300)
				"STARTING_RSPEED":
					dict[key] += randi_range(-300,300)
				"STARTING_HEALTH":
					pass
#					dict[key] += randi_range(-100,100)
				"STARTING_DAMAGE":
					pass
#					dict[key] += randi_range(-50,50)
				"VIEW_DISTANCE":
					dict[key] += randi_range(-30,30)
				"VIEW_WIDTH":
					dict[key] += randi_range(-30,30)
				"MASS":
					dict[key] = dict[key] + randf_range(-1,1)
					if dict[key] < 0.05: dict[key] = 0.05
				"CHASE_TIME":
					dict[key] = dict[key] + randf_range(-1,1)
					if dict[key] < 0.05: dict[key] = 0.05
				_:
					dict[key] = wrapf(randf_range(-1,1)+dict[key],0,1)
			if dict[key] < 0: dict[key] = 0

func reproduce_with(other_parent:Genome):
	var new_genome = self.duplicate(true)
	new_genome.dict = self.dict.duplicate(true)
	for key in dict.keys():
		if randf() < 0.3333: # 1/3 chance to take other parents
			new_genome.dict[key] = other_parent.dict[key]
		elif randf() < 0.5: # 1/3 chance to average
			new_genome.dict[key] = (new_genome.dict[key] + other_parent.dict[key]) / 2
		# 1/3 chance to keep the first parent's
		if dict[key] < 0: dict[key] = 0
	new_genome.mutate()
	return new_genome
