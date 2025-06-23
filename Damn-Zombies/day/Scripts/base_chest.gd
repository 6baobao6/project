extends StaticBody2D

@export var interact_dist : float = 20.0
@onready var player = get_parent().get_node("Player")
@onready var prompt = get_node("KeyPrompt")
var canInteract: bool = true
var isOpened: bool = false
@export var chestName: String = ""
@export var itemType: int = -1
@export var itemIndex: int = -1
@export var itemName: String = ""
@export var spritePath: String = ""
@onready var hud = get_parent().get_node("Camera2D").get_child(0).get_child(0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spritePath == "":
		print("No Sprite!")
	if itemIndex == -1:
		print("No item index indicated!")
	$Sprite2D.texture = load(spritePath)
	if itemType == 2:
		$Sprite2D.hframes = 12
		$Sprite2D.vframes = 2
		$Sprite2D.frame = 1
		$Sprite2D.frame_coords = Vector2i(1, 0)
	prompt.hide()
	if SaveManager.current_save_resource.openedChests.has(chestName):
		isOpened = true
		$AnimatedSprite2D.play("open")
	player.connect("Interact", _on_player_interact)
	$Timer.timeout.connect(_on_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not isOpened:
		prompt.visible = _get_player_close()
			
func _on_player_interact():
	if (canInteract && not isOpened && _get_player_close()):
		open_chest()

func open_chest():
	isOpened = true
	SaveManager.current_save_resource.open_chest(chestName)
	prompt.visible = false
	$AnimatedSprite2D.play("open")
	$Sprite2D.visible = true
	$Timer.start()

func _on_timer_timeout():
	$Sprite2D.visible = false
	SoundManager.play_sound(SoundManager.SOUND.PICK_UP)
	SaveManager.current_save_resource._unlock_item(itemType, itemIndex)
	if itemType == 0:
		var weaponPath = "res://day/Resources/WeaponResources/" + itemName + ".tres"
		var weaponResource = load(weaponPath)
		player._set_weapon(weaponResource)
	elif itemType == 2:
		hud._set_text_box(player.portrait, "Great. " + itemName + " seeds, this shall help me survive the night.")
		

func _get_player_close() -> bool:
	return position.distance_to(player.position) < interact_dist
