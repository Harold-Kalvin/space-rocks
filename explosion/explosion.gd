extends Sprite2D


func play():
	$AnimationPlayer.play("explosion")
	$Sound.play()
