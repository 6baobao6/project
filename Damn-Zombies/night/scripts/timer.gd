extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 从 Global 脚本获取时间数据
	var current_day = GameManager.day
	var current_hour = 0
	var current_minute = 0
	# 根据当前时段计算小时
	if GameManager.is_day_time:
		current_hour = floor(GameManager.time_elapsed / 60)  # 白天每小时60秒
		current_minute = int(int(GameManager.time_elapsed) % 60)
	else:
		current_hour = 16 + floor(GameManager.time_elapsed / 60)  # 黑夜从16点开始
		current_minute = int(int(GameManager.time_elapsed) % 60)
	
	# 更新Label显示
	var minute_str = "%02d" % current_minute
	$Label.text = "Day:%d, %d:%s" % [current_day, current_hour, minute_str]
