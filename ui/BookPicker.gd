class_name BookPicker
extends Control
signal book_chosen(path_or_key: String)
signal closed

@export var entries := [
	{"label":"작업일지", "key":"work_log"},
	{"label":"레시피",  "key":"recipe_book"},
]

@onready var _list: VBoxContainer = null

func _ready():
	# 항상 UI를 보장하고, 리스트를 채운다
	_ensure_ui()
	_fill_entries()
	hide()  # 처음엔 숨김

func open_centered():
	show()
	top_level = true
	z_index = 9999
	mouse_filter = MOUSE_FILTER_STOP

	await get_tree().process_frame
	reset_size()
	if size.x <= 1 or size.y <= 1:
		custom_minimum_size = Vector2(480, 600)
		size = custom_minimum_size

	var vp := get_viewport_rect().size
	position = (vp - size) * 0.5
	move_to_front()
	grab_focus()

func close():
	hide()
	emit_signal("closed")

# ---------------- internal ----------------
func _ensure_ui():
	# 이미 에디터에서 만든 ListVBox가 있으면 그걸 씀
	_list = _find_list_vbox()
	if _list: return

	# 없으면 최소 UI를 만든다
	var panel := Panel.new()
	add_child(panel)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var margin := MarginContainer.new()
	panel.add_child(margin)
	for k in ["margin_left","margin_right","margin_top","margin_bottom"]:
		margin.add_theme_constant_override(k, 16)

	var root := VBoxContainer.new()
	margin.add_child(root)
	root.custom_minimum_size = Vector2(448, 0)

	# 헤더
	var header := HBoxContainer.new()
	root.add_child(header)

	var title := Label.new()
	title.text = "무슨 책 볼래?"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "닫기"
	close_btn.pressed.connect(close)
	header.add_child(close_btn)

	root.add_child(HSeparator.new())

	# 리스트
	_list = VBoxContainer.new()
	_list.name = "ListVBox"
	root.add_child(_list)

func _find_list_vbox() -> VBoxContainer:
	# 씬에 이미 만들어 둔 VBoxContainer 이름이 "ListVBox"라면 찾아서 리턴
	if has_node("ListVBox"):
		return get_node("ListVBox") as VBoxContainer
	# 혹시 패널/마진 밑에 있을 수도 있으니 한 번 더 탐색
	for child in get_children():
		var v := child.find_child("ListVBox", true, false)
		if v and v is VBoxContainer:
			return v
	return null

func _fill_entries():
	if _list == null:
		push_error("BookPicker: _list(VBox) 없음"); return

	# 초기화 후 다시 채움
	for c in _list.get_children():
		c.queue_free()

	# 버튼 생성
	for e in entries:
		var btn := Button.new()
		btn.text = str(e.get("label","항목"))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var key := str(e.get("key",""))
		btn.pressed.connect(func():
			emit_signal("book_chosen", key)
			close()
		)
		_list.add_child(btn)
