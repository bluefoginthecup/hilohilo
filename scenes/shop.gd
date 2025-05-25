extends Node2D  # 또는 Node2D



func _on_back_btn_pressed() -> void:
	print('돌아가기 클릭됨 ->메인으로 이동')
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
