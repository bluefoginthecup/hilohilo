
extends "res://scenes/BaseSceneUI.gd"


const SHOP_THEME := preload("res://assets/audio/shop_theme.ogg")


func _ready() -> void:
	# 씬 열리면 상점 BGM 재생 (기존 곡과 자동 크로스페이드)
	AudioManager.play_bgm(SHOP_THEME, true, 0.8)
	print("shop.gd: READY")
	
	
