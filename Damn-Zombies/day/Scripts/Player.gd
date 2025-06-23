extends Character

class_name Player

@export var item : ItemResource
@export var suit : SuitResource
var coins : int = 0

var smoke = preload("res://day/Scenes/Objects/Effects/smoke_effect.tscn")
var counter = preload("res://day/Scenes/Objects/Effects/single_particle.tscn")
var camouflaged = false
var parrying = false
@onready var parry_hitbox : CollisionShape2D = get_node("ParryHitbox/CollisionShape2D")

signal Interact
signal ChangeItem
signal ChangeCoins
	
func setup_ui(game_ui : GameUI = null):
	if game_ui == null:
		game_ui = get_parent().get_node("Camera2D").get_child(0).get_child(0)
	if (game_ui != null):
		connect("ChangeWeapon", game_ui._update_weapon_ui)
		connect("ChangeHealth", game_ui._update_health_ui)
		connect("ChangeItem", game_ui._update_item_ui)
		connect("ChangeCoins", game_ui.update_money_ui)
	else:
		print("NO HUD FOUND")
	_set_health(health)
	_set_weapon(weapon)
	_set_item(item)
	_set_suit(suit)
	set_coins(0)

func _physics_process(delta):
	if (Input.is_action_just_pressed("interact")):
		emit_signal("Interact")
	if (Input.is_action_just_pressed("use_item")):
		_handle_item_used()
	if (Input.is_action_just_pressed("use_ability")):
		if suit != null:
			suit.suit_ability()
	if (Input.is_action_just_pressed("speed_up")):
		_increase_speed()

	_handle_movement_inputs(delta)
	_handle_attack_input()
	
func _increase_speed():
	if GameManager.speed < 4:
		GameManager.speed += 1
	else:
		GameManager.speed = 1

func _take_damage(damage : int, stun_lock = 1.0):
	if parrying:
		SoundManager.play_sound(SoundManager.SOUND.H_ATTACK)
		ParticleManager._play_particle(ParticleManager.parry_counter, \
			animator.sprite.global_position + Vector2(0, 3), \
			9, Vector2(1.1, 1.2), 1.5)
		parry_hitbox.set_deferred("disabled", false)
		await get_tree().create_timer(0.2).timeout
		parry_hitbox.set_deferred("disabled", true)
		return
	super._take_damage(damage, stun_lock)
	if health == 0:
		dead()

func dead():
	_set_health(0)
	await get_tree().create_timer(2.0).timeout
	await GameManager._change_scene("HomeScene")
	await get_tree().create_timer(1.0).timeout
	set_process(true)
	set_physics_process(true)
	var col = get_node("WalkingCollider")
	col.call_deferred("set_disabled", false)
	animator.play("idle")
	_set_health(4)
	SoundManager.play_sound(SoundManager.SOUND.HEAL)
	await get_tree().create_timer(1.0).timeout
	SoundManager.play_sound(SoundManager.SOUND.HEAL)
	_set_health(8)
	canAct = true
	

func _handle_movement_inputs(delta):
	vertDir = Input.get_axis("up", "down")
	horiDir = Input.get_axis("left", "right")
	super._physics_process(delta)
	
func _handle_attack_input():
	if (weapon == null):
		return
	var vertAct = Input.get_axis("act_up","act_down")
	var horiAct = Input.get_axis("act_left","act_right")
	var direction = Vector2(horiAct, vertAct)
	if direction.length() > 0:
		_attack (direction)
		
func _handle_item_used():
	if (item != null):
		item._use_item(self)

func _set_item(_item : ItemResource):
	item = _item
	emit_signal("ChangeItem", _item)
	
func _set_suit(_suit : SuitResource):
	if _suit != null:
		suit = _suit
		suit._set_suit(self)
	SaveManager.current_save_resource.current_suit_equip = _get_suit_index(_suit)

func _set_weapon(_weapon : WeaponResource):
	super._set_weapon(_weapon)
	SaveManager.current_save_resource.current_weapon_equip = _get_weapon_index(_weapon)
	
func set_coins(value_change : int, new_text : Texture2D = null):
	coins += value_change
	emit_signal("ChangeCoins", coins, new_text)
		
func reset_state():
	suit._reset_suit_ability()
	animator.stop()
	animator.play("RESET")
	animator.play("idle")

var suit_paths = [
	"res://day/Resources/SuitResources/NoSuitResource.tres",
	"res://day/Resources/SuitResources/GreenSuitResource.tres",
	"res://day/Resources/SuitResources/RedSuitResource.tres",
	"res://day/Resources/SuitResources/SnowSuitResource.tres"
]

func _get_suit_index(_suit : SuitResource) -> int:
	if SuitResource != null:
		return suit_paths.find(_suit.resource_path) - 1
	return -2

var weapon_paths = [
	"res://day/Resources/WeaponResources/Sword.tres",
	"res://day/Resources/WeaponResources/Whip.tres",
	"res://day/Resources/WeaponResources/Axe.tres",
	"res://day/Resources/WeaponResources/LongSword.tres"
]

func _get_weapon_index(_weapon : WeaponResource) -> int:
	if _weapon != null:
		return weapon_paths.find(_weapon.resource_path)
	return -1
