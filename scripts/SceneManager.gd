# SceneManager.gd  (Project Settings → Autoload 등록, 이름: SceneManager)
extends Node

var _busy: bool = false
var _cache: Dictionary = {}  # name -> PackedScene 캐시

# 중앙집중 경로 테이블(여기만 고치면 끝)
const SCENES := {
	"main":         "res://main.tscn",
	"garden":       "res://scenes/GardenScene.tscn",
	"shop":         "res://scenes/Shop.tscn",
	"library_menu": "res://scenes/LibraryMenu.tscn",
	"work_log": "res://scenes/WorkLog.tscn",      # ← 작업일지
	"recipe_book": "res://scenes/RecipeBook.tscn", # ← 레시피

}

# 공용 전환 함수(문자열/패키드씬 둘 다 지원). 기존 코드와 호환됨.
func change_scene(target) -> void:
	if _busy: return
	_busy = true
	print("[SM] request ->", target)
	call_deferred("_do_change", target)  # 트리 변경 충돌 방지

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

# 내부: 이름으로 lazy-preload
func _preload_by_name(name: String) -> PackedScene:
	if not SCENES.has(name):
		push_error("Unknown scene key: %s" % name)
		return null
	if not _cache.has(name):
		_cache[name] = load(SCENES[name])  # PackedScene 로드
	return _cache[name]

# 키 기반 이동(IDE 자동완성 잘 뜸)
func goto(name: String) -> void:
	var ps := _preload_by_name(name)
	if ps:
		change_scene(ps)

# 자주 쓰는 헬퍼
func goto_main() -> void:         goto("main")
func goto_garden() -> void:       goto("garden")
func goto_shop() -> void:         goto("shop")
func goto_library_menu() -> void: goto("library_menu")
