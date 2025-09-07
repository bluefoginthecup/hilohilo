extends Control
class_name BookPicker

signal book_chosen(path: String)

@onready var _panel: Control  = get_node_or_null("Panel")
@onready var _list:  ItemList = get_node_or_null("Panel/ItemList")

var _books := [
	{"title": "작업일지",   "path": "res://scenes/books/work_log.tscn"},
	{"title": "레시피 노트", "path": "res://scenes/books/recipes.tscn"},
]

func _ready() -> void:
	hide()

	if _panel:
		_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	else:
		push_error("[BookPicker] Panel 노드를 찾지 못했어요. 이름/경로 확인!")

	if _list:
		_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_list.size_flags_vertical   = Control.SIZE_EXPAND_FILL

		_list.clear()
		for b in _books:
			_list.add_item(b.title)

		_list.item_activated.connect(_on_pick)   # 더블클릭/Enter로 선택
		# _list.item_selected.connect(_on_pick)  # 단일 클릭으로도 열려면 사용
	else:
		push_error("[BookPicker] Panel/ItemList 경로에 ItemList가 없어요. 이름/위치 확인!")

func open_centered() -> void:
	size = Vector2(360, 240)
	z_index = 10
	show()
	global_position = (get_viewport_rect().size - size) / 2
	if _list:
		_list.grab_focus()

func _on_pick(idx: int) -> void:
	if idx >= 0 and idx < _books.size():
		var path := _books[idx].path as String 
		book_chosen.emit(path)    # ← 이제 신호 실제 사용됨
	hide()
