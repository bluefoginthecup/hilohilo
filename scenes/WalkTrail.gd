extends Node2D

const WALK_SEC := 600  # 10분

var _walking: bool = false
var _paused: bool = false
var _remain_sec: int = WALK_SEC

const SPEED_MIN := 0
const SPEED_MAX := 12

var _speed_level: int = 0


@onready var _btn_start: Button = $CanvasLayer/HBoxContainer/Start10mBtn
@onready var _btn_pause: Button = $CanvasLayer/HBoxContainer/PauseResumeBtn
@onready var _btn_back: Button = $CanvasLayer/HBoxContainer/BackBtn
@onready var _lbl_remain: Label = $CanvasLayer/HBoxContainer/LblRemain
@onready var _prog: ProgressBar = $CanvasLayer/HBoxContainer/Prog
@onready var _tick: Timer = $CanvasLayer/HBoxContainer/Tick


@onready var _btn_speed_down: Button = $CanvasLayer/HBoxContainer/SpeedDownBtn
@onready var _btn_speed_up: Button = $CanvasLayer/HBoxContainer/SpeedUpBtn
@onready var _lbl_speed: Label = $CanvasLayer/HBoxContainer/SpeedLabel

@onready var _bg := $BG  # BG 노드 이름이 다르면 여기만 바꿔줘



func _enter_tree() -> void:
	# 운동 씬 진입 즉시 가로 고정
	DisplayServer.screen_set_orientation(
		DisplayServer.ScreenOrientation.SCREEN_LANDSCAPE
	)

func _ready() -> void:
	print("[Trail] READY")
	_btn_start.pressed.connect(_on_start)
	_btn_pause.pressed.connect(_on_pause_resume)
	_btn_back.pressed.connect(_on_back)
	_tick.timeout.connect(_on_tick)
	_btn_speed_down.pressed.connect(_on_speed_down)
	_btn_speed_up.pressed.connect(_on_speed_up)

	_apply_speed() # 초기 라벨/배경 반영


	_btn_pause.disabled = true
	_update_ui()

# --------------------
# START
# --------------------
func _on_start() -> void:
	if _walking: return

	print("[Trail] START")
	_walking = true
	_paused = false
	_remain_sec = WALK_SEC

	_btn_start.disabled = true
	_btn_pause.disabled = false
	_btn_pause.text = "Pause"
	_apply_speed()


	_tick.start(1.0)
	_update_ui()
	

# --------------------
# PAUSE / RESUME
# --------------------
func _on_pause_resume() -> void:
	if not _walking: return

	if _paused:
		print("[Trail] RESUME")
		_paused = false
		_btn_pause.text = "Pause"
		_tick.start(1.0)
		_apply_speed() # ✅ paused=false 된 다음 호출
	else:
		print("[Trail] PAUSE")
		_paused = true
		_btn_pause.text = "Resume"
		_tick.stop()
		_apply_speed() # ✅ 멈출 때도 즉시 속도 0 적용

# --------------------
# TICK
# --------------------
func _on_tick() -> void:
	if _paused: return

	_remain_sec -= 1
	if _remain_sec <= 0:
		_finish_walk()
	else:
		_update_ui()

# --------------------
# FINISH
# --------------------
func _finish_walk() -> void:
	print("[Trail] FINISH")
	_walking = false
	_paused = false
	_tick.stop()

	_remain_sec = 0
	_btn_start.disabled = false
	_btn_back.disabled = false
	_btn_pause.disabled = true
	_btn_pause.text = "Pause"
	_apply_speed()

	_update_ui()
	# TODO: 보상 / 스탯 처리

# --------------------
# UI
# --------------------
func _update_ui() -> void:
	var m := _remain_sec / 60
	var s := _remain_sec % 60
	_lbl_remain.text = "남은 시간: %02d:%02d" % [m, s]

	var pct := 1.0 - float(_remain_sec) / float(WALK_SEC)
	_prog.value = clamp(pct * 100.0, 0.0, 100.0)
	
func _on_speed_up() -> void:
	_speed_level = clamp(_speed_level + 1, SPEED_MIN, SPEED_MAX)
	_apply_speed()

func _on_speed_down() -> void:
	_speed_level = clamp(_speed_level - 1, SPEED_MIN, SPEED_MAX)
	_apply_speed()

func _apply_speed() -> void:
	_lbl_speed.text = "속도: %d" % _speed_level

	# 걷기중 + 일시정지 아닐 때만 실제로 움직이게 하고 싶다면:
	var effective = _speed_level
	if (not _walking) or _paused:
		effective = 0

	# BG.gd에서 speed_level 변수를 쓰는 구조라면:
	if is_instance_valid(_bg):
		_bg.speed_level = effective


# --------------------
# BACK
# --------------------
func _on_back() -> void:
	# 걷는 중이면 정리
	if _walking:
		_tick.stop()
		_walking = false
		_paused = false
		_apply_speed()

	if has_node("/root/SceneManager"):
		SceneManager.goto_house_front()

func _exit_tree() -> void:
	print("[Trail] EXIT")
	
	# 씬 나가면 세로 고정으로 복귀
	DisplayServer.screen_set_orientation(
		DisplayServer.ScreenOrientation.SCREEN_PORTRAIT
	)

	if is_instance_valid(_tick):
		_tick.stop()
