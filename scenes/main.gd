extends Control

@onready var _bookshelf_btn: TextureButton = $BookshelfBtn   # ★ 추가!
var _picker: BookPicker = null  # ★ BookPicker.gd의 클래스 타입 지정



func _ready():
	print("main.gd: READY")

	# DialogueRotator가 클릭 가로막지 않게
	if $DialogueRotator is Control:
		$DialogueRotator.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 모자걸이 버튼 연결
	var hat := $hatStandBtn
	hat.disabled = false
	if not hat.pressed.is_connected(_on_hatStandBtn_pressed):
		hat.pressed.connect(_on_hatStandBtn_pressed)

	# 책장 버튼 연결
	if _bookshelf_btn and not _bookshelf_btn.pressed.is_connected(_on_bookshelf_pressed):
		_bookshelf_btn.pressed.connect(_on_bookshelf_pressed)

	# 대사 세팅
	$DialogueRotator.set_dialogues([
		"안녕하세요 아가씨",
		"모자걸이를 클릭해 상점에 가보세요!",
		"오늘 날씨 참 좋네요",
		"책장 서랍에서 아이템을 확인해보세요 "
	], 3.0, false)

func _on_hatStandBtn_pressed():
	print("모자걸이 클릭됨 → 상점으로 이동 중…")
	SceneManager.change_scene("res://scenes/shop.tscn")

# ===== 책장 핸들러 =====
func _on_bookshelf_pressed():
	if _picker == null:
		var packed := load("res://ui/BookPicker.tscn")
		if packed == null:
			push_error("BookPicker.tscn 경로 확인 필요")
			return
		_picker = packed.instantiate() as BookPicker
		add_child(_picker)
		if not _picker.has_signal("book_chosen"):
			push_error("BookPicker.gd에 signal book_chosen(path) 정의 필요")
		else:
			_picker.book_chosen.connect(_on_book_chosen)
	_picker.open_centered()


func _on_book_chosen(path: String):
	print("선택된 책:", path)
	SceneManager.change_scene(path)
