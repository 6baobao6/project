extends Node2D

@onready var speedx1 = $speedx1
@onready var speedx2 = $speedx2
@onready var speedx3 = $speedx3
@onready var speedx4 = $speedx4



func _physics_process(delta):
	if GameManager.speed == 1:
		speedx1.modulate = Color(1, 1, 1, 1)
		speedx2.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx3.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx4.modulate = Color(0.5, 0.5, 0.5, 1)
	elif GameManager.speed == 2:
		speedx1.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx2.modulate = Color(1, 1, 1, 1)
		speedx3.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx4.modulate = Color(0.5, 0.5, 0.5, 1)
	elif GameManager.speed == 3:
		speedx1.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx2.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx3.modulate = Color(1, 1, 1, 1)
		speedx4.modulate = Color(0.5, 0.5, 0.5, 1)
	elif GameManager.speed == 4:
		speedx1.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx2.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx3.modulate = Color(0.5, 0.5, 0.5, 1)
		speedx4.modulate = Color(1, 1, 1, 1)
