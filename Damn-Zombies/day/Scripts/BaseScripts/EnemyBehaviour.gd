extends Character

class_name EnemyBehaviour

@export var resetable : bool
@export var coins_to_give: int = 1
@onready var player = get_parent().get_node("Player")
@onready var agent = get_node("NavigationAgent2D")
@onready var base_pos = position
var base_pickup_scene = preload("res://day/Scenes/Objects/BasePickUp.tscn")
var coin = preload("res://day/Scenes/Objects/PickUpItems/GoldPickUp.tscn")

const dropWeapons = [[1, 'Whip'], [2, 'Axe'], [3, 'LongSword']]
const randiMax = 3
const randiMin = 0
const weaponResourcePath = "res://day/Resources/WeaponResources/"
var died = false
signal enemy_died
signal enemy_reset

func _physics_process(delta):	
	if position.distance_to(agent.get_final_position()) < 5:
		_on_timer_timeout()
	var direction = to_local(agent.get_next_path_position()).normalized()
	vertDir = direction.y
	horiDir = direction.x	
	
	var toPlayer = global_position - player.global_position
	if position.distance_to(player.position) < 20:
		_attack(toPlayer * -1)
	
	super._physics_process(delta)
	
func _on_timer_timeout():
	agent.target_position = player.position

func _reset():
	position = base_pos
	_set_health(max_health)
	set_process(true)
	set_physics_process(true)
	var col = get_node("WalkingCollider")
	col.call_deferred("set_disabled", false)
	canAct = true
	emit_signal("enemy_reset")

func _on_screen():
	if not died:
		set_physics_process(true)

func _off_screen():
	if resetable:
		_reset()
	set_physics_process(false)

func _take_damage(damage : int, stun_lock = 1.0):
	super._take_damage(damage, stun_lock)
	# 0 Sword 1 Whip 2 Axe 3 Longsword
	if (health == 0 && !died):
		died = true
		emit_signal("enemy_died")
		var dropDice = randi() % (10 - 0)
		if dropDice == 1:
			var pickup = base_pickup_scene.instantiate()
			var weaponIndex = randi() % (randiMax - randiMin) + randiMin
			var droppedWeapon = dropWeapons[weaponIndex]
			var resourcePath = weaponResourcePath + droppedWeapon[1] + ".tres"
			var pickUpResource = load(resourcePath)
			pickup.resource = pickUpResource
			pickup.unlock_item_index = droppedWeapon[0]
			pickup.global_position = global_position
			get_parent().add_child(pickup)
		else:
			coin = coin.instantiate()
			coin.coins_given = coins_to_give
			coin.global_position = global_position
			get_parent().call_deferred("add_child", coin)
