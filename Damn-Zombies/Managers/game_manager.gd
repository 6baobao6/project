extends Node  # 继承自Node类，作为自动加载的全局脚本

var random = RandomNumberGenerator.new()  # 随机数生成器实例

# 假设转场库脚本自动加载的节点名称为 FancyFade 和 Transitions
#var FancyFade = preload("res://addons/transitions/FancyFade.gd").new()
#const Transitions = preload("res://addons/transitions/Transitions.gd")

# 游戏状态变量
var speed = 1  # 游戏速度
var sun_value = 300  # 阳光值
var sun_value_deficit = 0  # 阳光不足量
var sun_value_surplus = 0  # 阳光过剩量
var leaf_value = 100  # 叶子值
var leaf_value_deficit = 0  # 叶子不足量
var leaf_value_surplus = 0  # 叶子过剩量
var danger_level = 0  # 危险等级
var slime_count = 0  # 粘液数量
var you_lost = false  # 游戏失败标志

var is_day_time = true  # 当前是否为白天
var is_god_mode = false  # 上帝模式标志
const DAY_SCENE_PATH = "res://day/Scenes/Levels/HomeScene.tscn"  # 白天场景路径
const NIGHT_SCENE_PATH = "res://night/scenes/lawn.tscn"  # 夜晚场景路径
var day_duration = 960.0  # 白天持续时间(秒)
var night_duration = 480.0  # 夜晚持续时间(秒)
var day = 1
var time_elapsed = 0.0  # 已过时间
var is_time_cycle_enabled = false  # 是否启用时间循环
var timer
var timer_label




# 场景管理相关
var current_level  # 当前关卡节点
var main_player : Player  # 玩家角色引用
var main_hud : GameUI  # 游戏UI引用
const AUTOLOAD_AMOUNT = 6  # 自动加载的子节点索引

var saved_grafts = []      # 存储嫁接植物数据
var has_saved_grafts = false  # 标记是否有保存的嫁接植物

const DAY_VIEWPORT_SIZE = Vector2i(256, 190)  # 白天视口尺寸
const NIGHT_VIEWPORT_SIZE = Vector2i(480, 280) # 夜间视口尺寸
#const DAY_VIEWPORT_SIZE = Vector2i(256, 190)  # 白天视口尺寸
#const NIGHT_VIEWPORT_SIZE = Vector2i(14, 56) # 夜间视口尺寸

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS  # 设置始终处理模式
	# 获取当前关卡和玩家节点
	current_level = get_tree().root.get_child(AUTOLOAD_AMOUNT)
	main_player = current_level.get_node("Player")
	
	# 实例化timer节点
	timer = preload("res://night/scenes/timer.tscn").instantiate()
	get_tree().root.add_child(timer)
	# 获取timer中的Label节点
	timer_label = timer.get_node("Label")

# 切换场景函数(白天的场景树，夜间只有一个)
func _change_scene(next_scene : String, newPos = null):
	# 从当前场景移除玩家
	current_level.remove_child(main_player)
	
	# 加载新场景
	var next_level = load("res://day/Scenes/Levels/" + next_scene+".tscn").instantiate()
	
	# 替换新场景中的玩家为当前玩家
	var scene_player = next_level.get_node("Player")
	var scene_player_pos = scene_player.global_position
	next_level.remove_child(scene_player)
	scene_player.queue_free()
	next_level.add_child(main_player)
	main_player.name = "Player"
	
	# 设置玩家位置
	if newPos != null:
		main_player.global_position = newPos
	else:
		main_player.global_position = scene_player_pos

	# 延迟添加新场景并移除旧场景
	var original_layer = main_player.collision_layer
	var original_mask = main_player.collision_mask
	main_player.set_deferred("collision_layer", 0)
	main_player.set_deferred("collision_mask", 0)
	get_tree().root.call_deferred("add_child", next_level)
	get_tree().root.call_deferred("remove_child", current_level)
	current_level.call_deferred("free")
	current_level = next_level
	await get_tree().process_frame
	main_player.collision_layer = original_layer
	main_player.collision_mask = original_mask

	
	# 等待一帧后设置UI
	await get_tree().create_timer(0.0001).timeout
	main_player.setup_ui()
	
# 获取当前关卡名称（处理特殊字符）
func get_current_level_name():
	var level_name = current_level.name 
	level_name = level_name.replace('"', "")
	level_name = level_name.replace("&", "")
	return level_name

func toggle_time_of_day():
	"""
	切换白天/夜晚场景
	夜间模式没有玩家，白天模式有玩家
	"""

	var current_scene_name = get_current_level_name()
		# 确定目标视口尺寸
	var target_viewport_size = DAY_VIEWPORT_SIZE if is_day_time else NIGHT_VIEWPORT_SIZE
	if is_day_time:
		target_viewport_size = NIGHT_VIEWPORT_SIZE
	else:
		target_viewport_size = DAY_VIEWPORT_SIZE
	# 创建视口缩放Tween动画
	var viewport_tween = create_tween()
	viewport_tween.tween_property(
		get_tree().root,
		"content_scale_size",
		target_viewport_size,
		0.5  # 过渡时间0.5秒
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# 根据当前时间决定加载白天还是夜晚场景
	var next_scene_path = ""
	if is_day_time:
		sun_value = (5 + (10/day)* main_player.coins) * 100
		main_player.coins = 0
		#await viewport_tween.finished
		# 切换到夜间模式 - 不需要玩家
		next_scene_path = NIGHT_SCENE_PATH 
		
		# 保存玩家位置（如果需要）
		var player_pos = main_player.global_position
		
		# 从当前场景移除玩家
		current_level.remove_child(main_player)
		# 加载夜间场景
		var next_level = load(next_scene_path).instantiate()
		FancyFade.cell_noise(next_level, 1)

		# 延迟添加新场景并移除旧场景
		get_tree().root.call_deferred("add_child", next_level)
		get_tree().root.call_deferred("remove_child", current_level)
		current_level.call_deferred("free")
		current_level = next_level
		
		# 不需要处理玩家，因为夜间模式没有玩家
	else:
		# 切换到白天模式 - 需要添加玩家
		#next_scene_path = DAY_SCENE_PATH + current_scene_name + ".tscn"
		#await viewport_tween.finished
		next_scene_path = DAY_SCENE_PATH
		# 加载白天场景
		var next_level = load(next_scene_path).instantiate()
		FancyFade.cell_noise(next_level, 1)

		# 获取白天场景中的玩家位置
		var scene_player = next_level.get_node("Player")
		var scene_player_pos = scene_player.global_position
		next_level.remove_child(scene_player)
		scene_player.queue_free()
		
		# 添加当前玩家到新场景
		next_level.add_child(main_player)
		main_player.name = "Player"
		main_player.global_position = scene_player_pos
		main_player._set_health(8)
		# 延迟添加新场景并移除旧场景
		get_tree().root.call_deferred("add_child", next_level)
		get_tree().root.call_deferred("remove_child", current_level)
		current_level.call_deferred("free")
		current_level = next_level
		await get_tree().create_timer(0.0001).timeout
		main_player.setup_ui()
		day += 1
	
	
	# 切换时间标志
	is_day_time = !is_day_time

	# 等待一帧后设置UI（仅在白天模式）
	#DisplayServer.window_set_size(get_tree().root.size, 0)  # 0 表示主窗口
	time_elapsed = 0.0
		

func _process(delta):
	if is_time_cycle_enabled:
		time_elapsed += delta * speed  # 考虑游戏速度
			
	# 检查昼夜切换
	var current_duration = day_duration if is_day_time else night_duration
	if time_elapsed >= current_duration:
		# 触发场景切换（根据需求可选）
		toggle_time_of_day()
	
# 测试输入处理
#func _input(event):
	#if event is InputEventKey and event.pressed:
		## 按8键保存游戏
		#if event.keycode == KEY_8:
			#print("SAVING GAME")
			#SaveManager.save_data(SaveManager.current_save_file)
		## 按9键加载游戏
		#if event.keycode == KEY_9:
			#print("LOADING GAME")
			#var data = SaveManager.load_data(SaveManager.current_save_file)
			#data.apply_data()
		# 按P键开启上帝模式（测试用）
		#if event.keycode == KEY_P:  # TODO: 添加上帝模式（用于测试）
			## 上帝模式设置
			#var god_resource = SaveManager.current_save_resource
			#god_resource.player_name = "GOD"
			#god_resource.coins = 999
			#god_resource.set_weapons(true, true, true, true)
			#god_resource.set_suits(true, true, true)
			#main_player.coins = 999
			#SaveManager.current_save_resource = god_resource
			#is_god_mode = true
			#print("上帝模式已激活")
				## 上帝模式下按T键切换白天/夜晚
		#if is_god_mode and event.keycode == KEY_T:
			#print("切换时间: %s" % ("夜晚" if is_day_time else "白天"))
			#toggle_time_of_day()
		#if is_god_mode and event.keycode == KEY_V:
			#Dead()
			
func Dead():
	if is_day_time:
		return
	else:
		await toggle_time_of_day()
		main_player._take_damage(INF)
		you_lost = false
