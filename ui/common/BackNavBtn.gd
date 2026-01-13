# res://ui/common/BackNavBtn.gd
class_name BackNavBtn
extends Button

enum Corner { TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT }

@export var label_text := "방으로"
@export_file("*.tscn") var target_scene_path := "res://scenes/Main.tscn"
@export var scene_key := "main"
@export var use_scene_manager := true

@export var corner: BackNavBtn.Corner = BackNavBtn.Corner.TOP_LEFT
@export var margin := Vector2i(20, 20)

func _ready() -> void:
	text = label_text
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP

	if get_parent() is Control:
		await get_tree().process_frame
		_apply_corner_layout()

	# ✅ 이제 존재하는 메서드에 연결
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed)

func _on_pressed() -> void:
	_go_back()

func _go_back() -> void:
	if use_scene_manager and typeof(SceneManager) != TYPE_NIL:
		if SceneManager.has_method("goto_main"):
			SceneManager.goto_main(); return
		if SceneManager.has_method("goto") and scene_key != "":
			SceneManager.goto(scene_key); return
		if SceneManager.has_method("change_scene"):
			SceneManager.change_scene(target_scene_path); return
	get_tree().change_scene_to_file(target_scene_path)

func _apply_corner_layout() -> void:
	var right  := (corner == BackNavBtn.Corner.TOP_RIGHT or corner == BackNavBtn.Corner.BOTTOM_RIGHT)
	var bottom := (corner == BackNavBtn.Corner.BOTTOM_LEFT or corner == BackNavBtn.Corner.BOTTOM_RIGHT)

	anchor_left   = 1.0 if right  else 0.0
	anchor_right  = 1.0 if right  else 0.0
	anchor_top    = 1.0 if bottom else 0.0
	anchor_bottom = 1.0 if bottom else 0.0

	if right:
		offset_right = -float(margin.x)
		offset_left  = offset_right - size.x
	else:
		offset_left  = float(margin.x)
		offset_right = offset_left + size.x

	if bottom:
		offset_bottom = -float(margin.y)
		offset_top    = offset_bottom - size.y
	else:
		offset_top    = float(margin.y)
		offset_bottom = offset_top + size.y
