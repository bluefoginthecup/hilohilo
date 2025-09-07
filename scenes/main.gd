extends Control

@onready var _bookshelf_btn: TextureButton = $BookshelfBtn
@onready var _hat_btn: BaseButton = $hatStandBtn

@export var picker_scene: PackedScene   # ← 인스펙터에 BookPicker.tscn 꽂기
var _picker: BookPicker = null

func _ready():
	print("main.gd: READY")

	if $DialogueRotator is Control:
		$DialogueRotator.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if _hat_btn and not _hat_btn.pressed.is_connected(_on_hatStandBtn_pressed):
		_hat_btn.disabled = false
		_hat_btn.pressed.connect(_on_hatStandBtn_pressed)

	if _bookshelf_btn and not _bookshelf_btn.pressed.is_connected(_on_bookshelf_pressed):
		_bookshelf_btn.pressed.connect(_on_bookshelf_pressed)

	$DialogueRotator.set_dialogues([
		"안녕하세요 아가씨",
		"모자걸이를 클릭해 상점에 가보세요!",
		"오늘 날씨 참 좋네요",
		"책장 서랍에서 아이템을 확인해보세요 "
	], 3.0, false)

func _on_hatStandBtn_pressed():
	print("모자걸이 클릭됨 → 상점으로 이동 중…")
	SceneManager.goto_shop()

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
	# ★ 한 줄만 호출 (중복 제거)
	_picker.open_centered()

func _on_book_chosen(path_or_key: String):
	print("선택된 책:", path_or_key)
	if SceneManager.SCENES.has(path_or_key):
		SceneManager.goto(path_or_key)
	else:
		SceneManager.change_scene(path_or_key)
