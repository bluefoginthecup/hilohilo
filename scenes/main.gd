# res://scenes/MainScene.gd
extends "res://scenes/BaseSceneUI.gd"

const MAIN_THEME := preload("res://assets/audio/main_theme.ogg")

@onready var _bookshelf_btn: TextureButton = $BookshelfBtn
@onready var _hat_btn: BaseButton = $hatStandBtn
@onready var _Window_btn: BaseButton = $WindowBtn

@export var picker_scene: PackedScene   # BookPicker.tscn 꽂기
var _picker: BookPicker = null

func _ready() -> void:
	super()  # BaseSceneUI._ready()
	AudioManager.play_bgm(MAIN_THEME, true, 0.8)
	print("main.gd: READY_v3")

	if $DialogueRotator is Control:
		$DialogueRotator.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if _hat_btn and not _hat_btn.pressed.is_connected(_on_hatStandBtn_pressed):
		_hat_btn.disabled = false
		_hat_btn.pressed.connect(_on_hatStandBtn_pressed)

	if _Window_btn and not _Window_btn.pressed.is_connected(_on_WindowBtn_pressed):
		_Window_btn.disabled = false
		_Window_btn.pressed.connect(_on_WindowBtn_pressed)

	if _bookshelf_btn and not _bookshelf_btn.pressed.is_connected(_on_bookshelf_pressed):
		_bookshelf_btn.pressed.connect(_on_bookshelf_pressed)

	$DialogueRotator.set_dialogues([
		"안녕하세요 아가씨",
		"모자걸이를 클릭해 외출하세요!",
		"오늘 날씨 참 좋네요",
		"책장 서랍에서 아이템을 확인해보세요 "
	], 3.0, false)

# ───────────── 종료 훅: 호스트에서 stop() 전에 호출 ─────────────
func prepare_shutdown() -> void:
	print("MainScene: prepare_shutdown()")
	# BGM 등 즉시 정리(중복 호출되어도 안전)
	AudioManager.stop_bgm(0.1)

	# 혹시 남아있을 수 있는 기본 Environment를 방어적으로 해제
	var vp := get_viewport()
	if vp:
		var w3d := vp.get_world_3d()
		if w3d:
			w3d.environment = null

	# 누수 의심 노드 출력
	print_orphan_nodes()

	# 한 프레임 양보해 참조 떨어뜨리기
	await get_tree().process_frame

# ───────────── 앱 자체 종료 시 자동 호출 ─────────────
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		await prepare_shutdown()
		get_tree().quit()

func _on_hatStandBtn_pressed():
	print("모자걸이 클릭됨 → 외출준비중...")
	SceneManager.goto_house_front()


func _on_WindowBtn_pressed():
	print("창문 클릭됨 → 정원으로 이동 중…")
	SceneManager.goto_garden()

func _on_bookshelf_pressed():
	if _picker == null:
		if picker_scene == null:
			push_error("picker_scene 미지정"); return
		var inst := picker_scene.instantiate()
		_picker = inst as BookPicker
		if _picker == null:
			push_error("picker_scene이 BookPicker 타입 아님"); return
		add_child(_picker, true)
		if _picker.has_signal("book_chosen") and not _picker.book_chosen.is_connected(_on_book_chosen):
			_picker.book_chosen.connect(_on_book_chosen)
	_picker.open_centered()

func _on_book_chosen(path_or_key: String):
	print("선택된 책:", path_or_key)
	if SceneManager.SCENES.has(path_or_key):
		SceneManager.goto(path_or_key)
	else:
		SceneManager.change_scene(path_or_key)
