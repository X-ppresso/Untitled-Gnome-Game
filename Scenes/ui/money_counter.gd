extends Label


func _process(delta: float) -> void:
	self.text = str(Score.score)
