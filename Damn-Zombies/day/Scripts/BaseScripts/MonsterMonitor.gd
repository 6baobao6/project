extends Node

var enemiesCount = 0
var enemies = []
@export var dropChest: bool = false
@onready var chest = get_node("BaseChest")
var chestCollisionShape
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chestCollisionShape = chest.get_node("CollisionShape2D")
	if SaveManager.current_save_resource.openedChests.has(chest.chestName):
		chest.visible = true
		chestCollisionShape.disabled = false
	else:
		chest.visible = false
		chestCollisionShape.disabled = true
	var allCharacters = get_children()
	for chr in allCharacters:
		if (chr is EnemyBehaviour):
			chr.enemy_died.connect(_on_enemy_died)
			chr.enemy_reset.connect(_on_enemy_reset)
			enemiesCount += 1
			enemies.append(chr)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_enemy_died():
	enemiesCount -= 1
	if (enemiesCount == 0):
		_on_all_enemy_died()
	
func _on_enemy_reset():
	enemiesCount += 1

func _on_all_enemy_died():
	if (dropChest):
		chestCollisionShape.call_deferred("set_disabled", false)
		chest.visible = true

		
