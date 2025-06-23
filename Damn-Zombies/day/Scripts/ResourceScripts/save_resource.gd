extends Resource

class_name SaveResource

var save_file_name : String
var current_scene : String = "HomeScene"
var player_name : String = "Suki"

var coins : int
#Collected weapons check:
var current_weapon_equip = -1
var has_sword = false
var has_whip = false
var has_axe = false
var has_great_sword = false
#Collected suits check:
var current_suit_equip = -1
var has_green_suit = false
var has_rage_suit = false;
var has_snow_suit = false
var openedChests = []
# seeds
var hasSeed4 = false
var hasSeed5 = false
var hasSeed6 = false

var saved_grafts = []      # 存储嫁接植物数据
var has_saved_grafts = false  # 标记是否有保存的嫁接植物

var day: int
var time_elapsed : int  # 已过时间

func apply_data():
	GameManager._change_scene(current_scene)
	GameManager.main_player.coins = coins
	var current_suit_resource = _get_suit_resource(current_suit_equip)
	GameManager.main_player._set_suit(current_suit_resource)
	var current_weapon_resource = _get_weapon_resource(current_weapon_equip)
	GameManager.main_player._set_weapon(current_weapon_resource)
	GameManager.day = day
	GameManager.time_elapsed = time_elapsed
	
func _unlock_item(list_index : int, item_index : int):
	if list_index == 0:
		var list = _get_weapons()
		list[item_index] = true
		_set_weapons(list)
		list = _get_weapons()
	elif list_index == 1:
		var list = _get_suits()
		list[item_index] = true
		_set_suits(list)
	elif list_index == 2:
		var list = _get_seeds()
		list[item_index] = true
		_set_seeds(list)

func set_weapons(_has_sword : bool, _has_whip : bool, _has_axe : bool, _has_g_sword : bool):
	has_sword = _has_sword
	has_whip = _has_whip
	has_axe = _has_axe
	has_great_sword = _has_g_sword

func _set_weapons(list):
	has_sword = list[0]
	has_whip = list[1]
	has_axe = list[2]
	has_great_sword = list[3]	

func set_suits(_has_green : bool, _has_rage : bool, has_snow : bool):
	has_green_suit = _has_green
	has_rage_suit = _has_rage
	has_snow_suit = has_snow

func _set_suits(list):
	has_green_suit = list[0]
	has_rage_suit = list[1]
	has_snow_suit = list[2]

func set_seeds(_hasSeed4 : bool, _hasSeed5 : bool, _hasSeed6 : bool):
	hasSeed4 = _hasSeed4
	hasSeed4 = _hasSeed5
	hasSeed6 = _hasSeed6

func _set_seeds(list):
	hasSeed4 = list[0]
	hasSeed5 = list[1]
	hasSeed6 = list[2]
	
func _get_weapons():
	return [has_sword, has_whip, has_axe, has_great_sword]
	
func _get_suits():
	return[has_green_suit, has_rage_suit, has_snow_suit]
	
func _get_seeds():
	return[hasSeed4, hasSeed5, hasSeed6]
	
func open_chest(chestName):
	openedChests.append(chestName)
	print(openedChests)
	
func _get_suit_resource(suit_index : int):
	const path_prefix = "res://day/Resources/SuitResources/"
	const path_suffix = "Resource.tres"
	const suits = ["GreenSuit", "RedSuit", "SnowSuit"]
	var suit_resource
	if suit_index == -1:
		suit_resource = load(path_prefix + "NoSuit" + path_suffix)
	else:
		suit_resource = load(path_prefix + suits[suit_index] + path_suffix)
	return suit_resource
		
func _get_weapon_resource(weapon_index : int):
	if weapon_index == -1:
		return
	const path_prefix = "res://day/Resources/WeaponResources/"
	const path_suffix = ".tres"
	const weapons = ["Sword", "Whip", "Axe", "LongSword"]
	var weapon_resource = load(path_prefix + weapons[weapon_index] + path_suffix)
	return weapon_resource
