extends Node2D

@onready var sun_sprite = $sun_sprite
@onready var timer = $Timer

var rng = RandomNumberGenerator.new()
var sun_speed = 40
var move = 1
var rand_choice = rng.randi_range(1, 2)
var rand_rotate_num
var pick_sun_pos = Vector2(16, 16)
var picked = false

func _ready():
	timer.start()
	if rand_choice == 1:
		rand_rotate_num = rng.randf_range(-5, -2)
	else:
		rand_rotate_num = rng.randf_range(5, 2)

func _physics_process(delta):
	if !picked:
		self.position.y += sun_speed * GameManager.speed * delta
		self.rotate(rand_rotate_num * delta * GameManager.speed)
	else:
		self.position = self.position.move_toward(pick_sun_pos, delta * (sun_speed/5.0) * GameManager.speed * (self.position.distance_to(pick_sun_pos)))
		if self.rotation_degrees > 0.5 :
			self.rotation_degrees -= 8 * delta * GameManager.speed * abs(self.rotation_degrees)
		elif self.rotation_degrees < -0.5:
			self.rotation_degrees += 8 * delta * GameManager.speed * abs(self.rotation_degrees)
		self.modulate.a -= (1/self.position.distance_to(pick_sun_pos)) * delta * GameManager.speed
	
	if self.modulate.a < 0:
		self.queue_free()
	
	if timer.time_left < 2:
		self.modulate.a *= 0.995
	if timer.time_left < 0.1:
		self.queue_free()

func _on_sun_area_mouse_entered():
	sun_sprite.frame = 1

func _on_sun_area_mouse_exited():
	sun_sprite.frame = 0

func _on_sun_area_input_event(viewport, event, shape_idx):
	if !picked:
		GameManager.sun_value_surplus += 50
		event = event
		viewport = viewport
		shape_idx = shape_idx
	picked = true
