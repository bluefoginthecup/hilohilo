extends Control

func _ready() -> void:
	$ShopBtn.pressed.connect(_on_shop)
	$HomeBtn.pressed.connect(_on_home)
	$TrailBtn.pressed.connect(_on_trail) 

func _on_shop() -> void:
	if has_node("/root/SceneManager"):
		SceneManager.goto_shop()         # 맵→상점

func _on_home() -> void:
	if has_node("/root/SceneManager"):
		SceneManager.goto_main()         # 맵→방(Main)
		
		
func _on_trail() -> void:                  # ✅ 추가
	if has_node("/root/SceneManager"):
		SceneManager.goto_walk_trail()
