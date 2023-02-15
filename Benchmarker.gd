extends Node2D

var fps_update_interval = 1.0
var elapsed_time = 0.0
var fps_label = null
var benchmark_container = null
var benchmark_node = null
var benchmark = null
var language = null
var arg_lang = "--lang="

var scenes = {
	gdscript = 'res://scenes/GD.tscn',
	csharp = 'res://scenes/CSharp.tscn',
	hxgodot = 'res://scenes/Haxe.tscn',
	godotcpp = 'res://scenes/CPP.tscn'
}

# bunnymark
var bunnymark_target = 60.0
var bunnymark_target_error = 0.5
var bunnymark_update_interval = 2.0
var stable_updates_required = 3
var bunnymark_update_elapsed_time = 0.0
var stable_updates = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	set_process(false)
	fps_label = get_node("Panel/FPS")
	benchmark_container = get_node("BenchmarkContainer")
	
	benchmark = "BunnymarkV2"
	language = "gdscript"
	
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg.substr(0, arg_lang.length()) == arg_lang:
			language = arg.split("=")[1]
	
	start_benchmark()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	elapsed_time += delta
	if elapsed_time >= fps_update_interval:
		fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
		elapsed_time = 0.0
	update_bunnymark(delta)

func start_benchmark():
	
	var scene = null
	var scenePath = scenes[language]
	if (scenePath != null):
		scene = ResourceLoader.load(scenePath) as PackedScene
	else:
		get_tree().quit()

	benchmark_node = scene.instantiate()
	benchmark_node.add_user_signal("benchmark_finished", ["output"])
	benchmark_node.connect("benchmark_finished", Callable(self, "benchmark_finished"))
	benchmark_container.add_child(benchmark_node)
	
	if benchmark_node.has_method("add_bunny"):
		set_process(true)
	else:
		benchmark_finished(0)

func benchmark_finished(output):
	print("benchmark output: ", output)
	benchmark_container.remove_child(benchmark_node)
	benchmark_node.queue_free()

	var time = Time.get_datetime_string_from_system()
	var result = print_stats(time, output)

	var fileName = 'res://reports/%s_%s_bunnyresult.csv' % [time.replace(':', '-'), language]

	var file = FileAccess.open(fileName, FileAccess.WRITE)
	file.store_string(result)
	file = null
	
	get_tree().quit()
	
func update_bunnymark(delta):
	bunnymark_update_elapsed_time += delta
	if bunnymark_update_elapsed_time > bunnymark_update_interval:
		var fps = Engine.get_frames_per_second()
		var difference = fps - bunnymark_target
		var bunny_difference = 0
		if difference > bunnymark_target_error:
			bunny_difference = min(1000, max(1, floor(20 * difference)))
		elif difference < -bunnymark_target_error:
			bunny_difference = max(-1000, min(-1, -1*ceil(20 * difference)))
		if abs(difference) < bunnymark_target_error:
			stable_updates += 1
			if stable_updates == stable_updates_required:
				benchmark_node.finish()
		else:
			if bunny_difference > 0:
				for i in range(bunny_difference):
					benchmark_node.add_bunny()
			else:
				for i in range(-1*bunny_difference):
					benchmark_node.remove_bunny()

			stable_updates = 0

		bunnymark_update_elapsed_time = 0.0

func print_stats(time, count):
	
	var info = Engine.get_version_info()

	var godotVersion = '"%d.%d.%s";"%s";"%s"' % [info['major'], info['minor'], info['status'], info['build'], Engine.get_architecture_name()]
	var osVersion = '"%s";"%s"' % [OS.get_name(), OS.get_version()]
	var cpuVersion = '"%s";"%d"' % [OS.get_processor_name(), OS.get_processor_count()]
	var gpuVersion = '"%s";"%d"' % [RenderingServer.get_video_adapter_name(), DisplayServer.get_screen_count()]

	var memInfo = '"%d";"%d"' % [(OS.get_static_memory_usage() / 1024 / 1024), (OS.get_static_memory_peak_usage() / 1024 / 1024)]

	var benchInfo = '"%s";"%s";"%d"' % [time, language, count]

	var res = "%s;%s;%s;%s;%s;%s" % [benchInfo, memInfo, godotVersion, osVersion, cpuVersion, gpuVersion]

	print(res)

	return res

