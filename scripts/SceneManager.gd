extends Node

var _busy: bool = false
var _cache: Dictionary = {}  # name -> PackedScene 캐시

const SCENES := {
	"main":         "res://scenes/Main.tscn",
	"garden":       "res://scenes/GardenScene.tscn",
	"shop":         "res://scenes/Shop.tscn",
	"library_menu": "res://scenes/LibraryMenu.tscn",
	"work_log":     "res://scenes/WorkLog.tscn",
	"recipe_book":  "res://scenes/RecipeBook.tscn",
	"house_front":  "res://scenes/HouseFront.tscn", 
	"walk_trail":   "res://scenes/WalkTrail.tscn",
}

# ---------- 변경된 부분 ----------
# 공용 전환 함수 (문자열/패키드씬 지원) + 전환 전 BGM 페이드아웃
func change_scene(target, fade_before: bool = true, fade_sec: float = 0.3) -> void:
	if _busy:
		return
	_busy = true
	print("[SM] request ->", target)

	# 1) 전환 전에 BGM 페이드아웃 (AudioManager 오토로드 기준)
	if fade_before and has_node("/root/AudioManager"):
		await AudioManager.fade_out_bgm(fade_sec)

	# 2) 프레임 끝에 안전하게 씬 교체
	call_deferred("_do_change", target)

func _do_change(target) -> void:
	var err := OK
	if target is String:
		err = get_tree().change_scene_to_file(target)
	elif target is PackedScene:
		err = get_tree().change_scene_to_packed(target)
	else:
		push_error("SceneManager.change_scene: invalid target type: %s" % typeof(target))
		_busy = false
		return

	print("[SM] result  ->", err)  # 0이면 OK
	if err != OK:
		push_error("Scene change failed: %s (err=%d)" % [str(target), err])
	_busy = false

func _preload_by_key(key: String) -> PackedScene:
	if not SCENES.has(key):
		push_error("Unknown scene key: %s" % key)
		return null
	if not _cache.has(key):
		_cache[key] = load(SCENES[key])
	return _cache[key]

func goto(key: String, fade_before: bool = true, fade_sec: float = 0.3) -> void:
	var ps := _preload_by_key(key)
	if ps:
		change_scene(ps, fade_before, fade_sec)

# 헬퍼
func goto_main() -> void:         goto("main")
func goto_garden() -> void:       goto("garden")
func goto_shop() -> void:         goto("shop")
func goto_library_menu() -> void: goto("library_menu")
func goto_house_front() -> void: goto("house_front")   
func goto_walk_trail() -> void: goto("walk_trail") 
