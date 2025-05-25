extends Control

func _ready():
	$DialogueLabel.text = "모자걸이를 클릭해 상점에 가보세요!"

func _on_HatStandBtn_pressed():
	print("모자걸이 클릭됨 → 상점으로 이동 중...")
	get_tree().change_scene_to_file("res://scenes/shop.tscn")
