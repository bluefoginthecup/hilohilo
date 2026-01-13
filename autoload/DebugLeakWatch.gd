# res://autoload/DebugLeakWatch.gd
extends Node

## 종료 직전에 누수 의심 노드/리소스를 출력
func dump_orphans(tag := "before_stop") -> void:
	print("==== ORPHAN DUMP [", tag, "] ====")
	print_orphan_nodes()
	print("===============================")
