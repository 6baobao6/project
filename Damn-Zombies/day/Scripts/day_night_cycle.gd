extends CanvasModulate

var elapsed_time: float = 0.0
const DURATION: float = 960.0  # 白天的时间长度
const NIGHT_DURATION: float = 480.0  # 夜晚的时间长度

func _process(delta: float) -> void:
	# 如果是白天，更新时间
	if GameManager.is_day_time:  
		elapsed_time = GameManager.time_elapsed  # 使用全局的 time_elapsed

		# 计算进度（0 ~ 1 的值）
		var progress: float = clamp(elapsed_time / DURATION, 0.0, 1.0)
		var animation_time: float = lerp(0.0, 960.0, progress)

		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("Day_Night_cycle")

		# 设置 AnimationPlayer 播放位置
		$AnimationPlayer.seek(animation_time, true)

		# 当白天时间到达结束时，重置时间
		if elapsed_time > DURATION:
			GameManager.time_elapsed = 0.0  # 重置全局时间
			GameManager.is_day_time = false  # 切换到夜晚状态

	# 如果是夜晚，暂停时间更新
	else:
		# 可以选择不更新 gamemanager.time_elapsed，确保白天时间不会累积到夜晚
		pass
