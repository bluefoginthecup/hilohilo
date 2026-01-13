# res://scenes/BaseSceneUI.gd
extends Control

@export var stop_bgm_on_exit := true  # 씬별로 끌지 말지 토글

func _ready() -> void:
	print("BaseSceneUI: READY (no sky)")

func _exit_tree() -> void:
	if stop_bgm_on_exit:
		AudioManager.stop_bgm(0.2)
	print("BaseSceneUI: _exit_tree() done (no sky cleanup)")
