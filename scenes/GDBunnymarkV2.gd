extends Node2D

var grav = 500
var bunny_texture = load("res://scenes/wabbit_alpha.png")
var bunny_speeds = []
var label = Label.new()
var bunnies = []
var bunnyRoot = Node2D.new()
var screen_size

func _ready():
	add_child(bunnyRoot)
	label.position = Vector2(0, 20)
	add_child(label)

func _process(delta):
	screen_size = get_viewport_rect().size

	var bunny_children = bunnies.size()
	for i in range(0, bunnies.size()):
		var bunny = bunnies[i]
		var pos = bunny.position
		var speed = bunny_speeds[i]
		
		pos.x += speed.x * delta
		pos.y += speed.y * delta
	
		speed.y += grav * delta
	
		if pos.x > screen_size.x:
			speed.x *= -1
			pos.x = screen_size.x
		
		if pos.x < 0:
			speed.x *= -1
			pos.x = 0
			
		if pos.y > screen_size.y:
			pos.y = screen_size.y
			if randf() > 0.5:
				speed.y -= 30 + randf() * 1000
			else:
				speed.y *= -0.85
			
		if pos.y < 0:
			speed.y = 0
			pos.y = 0
		
		bunny.position = pos
		bunny_speeds[i] = speed

func add_bunny():
	var bunny = Sprite2D.new()
	bunny.set_texture(bunny_texture)
	bunnyRoot.add_child(bunny)
	bunnies.push_back(bunny)
	bunny_speeds.push_back(Vector2(randi() % 200 + 50, randi() % 200 + 50))
	bunny.position = Vector2(screen_size.x / 2, screen_size.y / 2)
	label.text = "Bunnies: " + str(bunnies.size())

func remove_bunny():
	var child_count = bunnies.size()
	if child_count == 0:
		return
	var bunny = bunnies[child_count - 1]
	bunny_speeds.pop_back()
	bunnies.pop_back()
	bunnyRoot.remove_child(bunny)
	bunny.queue_free()
	label.text = "Bunnies: " + str(bunnies.size())

func finish():
	emit_signal("benchmark_finished", bunnies.size())
