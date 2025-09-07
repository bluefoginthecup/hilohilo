extends Node2D


func _ready():
	print("shop.gd: READY")

func _on_back_btn_pressed():
	print("돌아가기 클릭됨 -> 메인으로 이동")
	SceneManager.change_scene("res://scenes/main.tscn")
