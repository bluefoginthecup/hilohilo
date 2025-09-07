extends Node
var _busy := false

func change_scene(path: String) -> void:
	if _busy: return
	_busy = true
	print("[SM] request ->", path)   # ★ 로그1
	call_deferred("_do_change", path)

func _do_change(path: String) -> void:
	var err := get_tree().change_scene_to_file(path)
	print("[SM] result  ->", err)    # ★ 로그2 (0이면 성공)
	if err != OK:
		push_error("Scene change failed: %s (err=%d)" % [path, err])
	_busy = false
