extends Node

@onready var UL_Bound = $Bounds/UpperLeft
@onready var LR_Bound = $Bounds/LowerRight

@onready var bots_parent = $"../AI_Players"
@onready var bot_scene = preload("res://scripts/ai/ai_bot.tscn")
@onready var gen_timer = $Gen_Timer
@export var bots_per_gen = 100
#@export var mutation_rate = 0


var generation_count:int = 0

var current_gen = []
var next_gen = []
var surviving_bots = []
#var next_gen = []
@onready var output_file = create_output_file()
var run_test_end = false

func _ready():
	Events.end_tests.connect(flag_end_test)
	Engine.time_scale = 40
	generate_genomes(current_gen)
	spawn_generation(current_gen)

func create_output_file():
	return
	var time = Time.get_datetime_dict_from_system()
	var file_name:String = "results_" + str(time.month) + "_" + str(time.day) + "_" + str(time.hour) + "_" + str(time.minute) + "_" + str(time.second) + ".csv"
	var output_folder:String = "res://output_data/"
#	var output_folder:String = "user://Godot_Output/"
	var file = FileAccess.open(str(output_folder) + str(file_name), FileAccess.WRITE)
	var headers = ["Generation", "FITNESS"]
	var temp_genome = Genome.new()
	for key in temp_genome.dict.keys():
		headers.append(key)
	file.store_csv_line(headers)
	return file
	
func generate_genomes(genome_array:Array):
	for i in range(0, bots_per_gen):
		var new_genome = Genome.new()
		new_genome.mutate()
		genome_array.append(new_genome)

func spawn_generation(genome_array):
	var printed_first = false
	for genome in genome_array:
		if not printed_first:
#			genome.print_genome()
			printed_first = true
		var new_bot:ai_bot = bot_scene.instantiate()
#		genome.print_genome()
		new_bot.genome = genome
		new_bot.set_rotation(randf_range(0, 2*PI))
		new_bot.global_position = Vector2(randi_range(UL_Bound.global_position.x,LR_Bound.global_position.x), randi_range(UL_Bound.global_position.y, LR_Bound.global_position.y))
		bots_parent.add_child(new_bot)

func _on_gen_timer_timeout():
#	print("Timer expired")
	gather_surviving_bots()
	next_gen = []
#	sort_bots()
#	roulette()
	calc_gen_stats()
	if not run_test_end:	
		tournament(5)
	#	print("Next gen size: ", next_gen.size())
	#	print(next_gen[0])
		for bot in surviving_bots:
			bot.queue_free()
		spawn_generation(next_gen)
	else:
		do_end_test()
#	print("New gen should be going")

func gather_surviving_bots():
	surviving_bots = []
	for bot in bots_parent.get_children():
		surviving_bots.append(bot)

#func sort_bots():
#	surviving_bots.sort_custom(func(a,b): return a if a.fitness > b.fitness else b)

func calc_gen_stats():
	var total_fitness = 0.0
	var most_fit = surviving_bots[0]
	var least_fit = surviving_bots[1]
	
#	var average_stats = Genome.new()
#	average_stats.dict = most_fit.genome.dict.duplicate(true)
#	for key in average_stats.dict.keys():
#		average_stats.dict[key] = 0
	for bot in surviving_bots:
		var stats_array = [generation_count, bot.fitness]
		for key in bot.genome.dict.keys():
			stats_array.append(bot.genome.dict[key])
#		output_file.store_csv_line(stats_array)
		total_fitness += bot.fitness
		if bot.fitness > most_fit.fitness: most_fit = bot
		if bot.fitness < least_fit.fitness: least_fit = bot
#	for key in average_stats.dict.keys():
#		average_stats.dict[key] /= surviving_bots.size()
#	most_fit.genome.print_genome()
#	print("Top Fitness: ", most_fit.fitness)
#	print("Bottom Fitness: ", least_fit.fitness)
	print("Average Fitness of gen ", generation_count, " survivors: ", total_fitness/surviving_bots.size())
#	var average_stats_array = [generation_count, total_fitness/surviving_bots.sizes()]
#	for key in average_stats.dict.keys():
#		average_stats_array.append(str(average_stats.dict[key]))
#	output_file.store_csv_line(average_stats_array)
	generation_count += 1
#	if(generation_count >= 99):
#		flag_end_test()
	
func roulette():
	var total_fitness = 0.0
	var most_fit = surviving_bots[0]
	for bot in surviving_bots:
		total_fitness += bot.fitness
#		print(bot.fitness)
		if bot.fitness > most_fit.fitness: most_fit = bot
	most_fit.genome.print_genome()
	print("Top Fitness: ", most_fit.fitness)
	print("Average Fitness ", generation_count, ": ", total_fitness/surviving_bots.size())
	generation_count += 1
	for bot in surviving_bots:
		bot.reproduction_chance = bot.fitness/total_fitness
	var new_bots:int = 0
	while new_bots < bots_per_gen:
		var temp_bot:ai_bot = surviving_bots.pick_random()
		if randf() < temp_bot.reproduction_chance:
			var child_genome = temp_bot.genome.make_child()
#			child_genome.print_genome()
			next_gen.append(child_genome)
			new_bots += 1
#			print("GenomeLength = ", next_gen_genomes.size())

func tournament(size = 3):
	for i in range(0, bots_per_gen):
		var most_fit_1 = surviving_bots.pick_random()
		var most_fit_2 = surviving_bots.pick_random()
		for j in range(0, size-1):
			var contender = surviving_bots.pick_random()
			if most_fit_1.fitness < contender.fitness:
				most_fit_1 = contender
		for j in range(0, size-1):
			var contender = surviving_bots.pick_random()
			if most_fit_2.fitness < contender.fitness:
				most_fit_2 = contender
		var child_genome = most_fit_1.genome.reproduce_with(most_fit_2.genome)
		next_gen.append(child_genome)

func flag_end_test():
	run_test_end = true
	gen_timer.one_shot = true

func do_end_test():
	output_file = null
