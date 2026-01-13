# res://scenes/BaseScene2D.gd
extends Node2D

@export var stop_bgm_on_exit := true  # 씬마다 토글 가능

func _ready() -> void:
	# Node2D 공통 초기화 작업이 있으면 여기 넣기
	print("BaseScene2D: READY")

func _exit_tree() -> void:
	if stop_bgm_on_exit:
		AudioManager.stop_bgm(0.2)  # 공통 페이드아웃
