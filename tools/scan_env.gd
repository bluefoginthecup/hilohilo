@tool
extends EditorScript

func _run() -> void:
	print("\n=== Scan: Environment / Sky references in scenes ===")
	_scan_dir("res://")
	var def_env := ProjectSettings.get_setting("rendering/environment/default_environment")
	print("ProjectSettings rendering/environment/default_environment =", def_env)
	print("=== Scan done. ===\n")

func _scan_dir(path: String) -> void:
	var d := DirAccess.open(path)
	if d == null:
		return
	for f in d.get_files():
		if f.ends_with(".tscn") or f.ends_with(".scn"):
			_check_scene(path.path_join(f))
	for sub in d.get_directories():
		if sub.begins_with("."):
			continue
		_scan_dir(path.path_join(sub))

func _check_scene(scene_path: String) -> void:
	var ps := load(scene_path)
	if ps is PackedScene:
		var inst := (ps as PackedScene).instantiate()
		var hits: Array[String] = []
		_collect(inst, hits)
		if hits.size() > 0:
			print("[FOUND] ", scene_path)
			for h in hits:
				print("  - ", h)
		inst.free()

func _collect(n: Node, hits: Array[String]) -> void:
	if n is WorldEnvironment:
		if (n as WorldEnvironment).environment:
			hits.append("%s: WorldEnvironment has Environment" % n.get_path())
	elif n is Camera3D:
		if (n as Camera3D).environment:
			hits.append("%s: Camera3D has Environment" % n.get_path())
	elif n is SubViewport:
		var w3d := (n as SubViewport).world_3d
		if w3d and w3d.environment:
			hits.append("%s: SubViewport.world_3d has Environment" % n.get_path())

	for c in n.get_children():
		_collect(c, hits)
