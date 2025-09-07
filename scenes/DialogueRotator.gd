# res://scripts/DialogueRotator.gd

extends Control

@export_node_path("Label") var label_path: NodePath
@export var dialogues: Array[String] = []
@export var interval_sec: float = 3.0
@export var shuffle: bool = false

@onready var _label: Label = (get_node_or_null(label_path) as Label)
@onready var _timer: Timer = $Timer

var _idx := 0




func _ready() -> void:
	# 에디터에서 넣은 dialogues가 PackedStringArray 등일 수 있어 안전 변환
	dialogues = _to_string_array(dialogues)

	if dialogues.is_empty():
		dialogues = ["..."]
	if shuffle:
		dialogues.shuffle()

	_timer.wait_time = interval_sec
	_timer.one_shot = false
	if not _timer.is_connected("timeout", Callable(self, "_on_timeout")):
		_timer.timeout.connect(_on_timeout)

	_apply_text()
	_timer.start()

func _on_timeout() -> void:
	if dialogues.is_empty():
		return
	_idx = (_idx + 1) % dialogues.size()
	_apply_text()

func _apply_text() -> void:
	if _label:
		_label.text = dialogues[_idx]

# ---- 외부 제어 API ----
# new_list는 어떤 타입(Array, PackedStringArray 등)이든 허용
func set_dialogues(new_list: Array, new_interval: float = -1.0, do_shuffle: bool = false) -> void:
	var tmp := _to_string_array(new_list)
	if tmp.size() > 0:
		dialogues = tmp
	if new_interval > 0.0:
		interval_sec = new_interval
		_timer.wait_time = interval_sec
	shuffle = do_shuffle
	if shuffle:
		dialogues.shuffle()
	_idx = 0
	_apply_text()
	_timer.start()

func pause() -> void:
	_timer.stop()

func resume() -> void:
	_timer.start()

# ---- 유틸 ----
func _to_string_array(any_list) -> Array[String]:
	var out: Array[String] = []
	if typeof(any_list) == TYPE_PACKED_STRING_ARRAY:
		for s in any_list:
			out.append(String(s))
		return out
	elif any_list is Array:
		for v in any_list:
			out.append(String(v))
		return out
	# 그 외 타입이 오면 단일 값으로 간주
	if any_list != null:
		out.append(String(any_list))
	return out
