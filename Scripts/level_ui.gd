extends CanvasLayer

@onready var timer_label = $MarginContainer/Timer_label
@export var timer : Timer

func _ready() -> void:
	timer.start()
	
func _time_left():
	var time_left = timer.time_left
	var minute = floor(time_left / 60)
	var second = int(time_left) % 60
	return [minute, second]
# ini timernya :" ^^

func _process(delta: float) -> void:
	timer_label.text = "%02d:%02d" %_time_left()
