extends Node
# 전역 BGM 크로스페이드 매니저 (Godot 4)
# - 두 AudioStreamPlayer로 교차 페이드
# - 동일 트랙 재요청 시 스킵
# - 앱 포커스 아웃 시 일시정지
# - stop_bgm 시 finished→play 루프 연결을 확실히 해제하여 재시작 레이스 방지

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const MIN_DB := -80.0  # 무음으로 간주할 안전한 최소 데시벨

var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _active: AudioStreamPlayer
var _inactive: AudioStreamPlayer
var _current_stream: AudioStream = null
var _master_volume_linear := 1.0  # 0.0~1.0, BGM 전체 스케일

@export var use_stream_loop := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT 
	_player_a = AudioStreamPlayer.new()
	_player_b = AudioStreamPlayer.new()
	_player_a.bus = MUSIC_BUS
	_player_b.bus = MUSIC_BUS
	add_child(_player_a)
	add_child(_player_b)
	_active = _player_a
	_inactive = _player_b

func _db_for_linear(x: float) -> float:
	if x <= 0.0:
		return MIN_DB
	return linear_to_db(x)

func _disconnect_loop_if_connected(p: AudioStreamPlayer) -> void:
	if not p: return
	if p.finished.is_connected(p.play):
		p.finished.disconnect(p.play)

func _clear_player(p: AudioStreamPlayer) -> void:
	if not p: return
	_disconnect_loop_if_connected(p)
	p.stop()
	p.stream = null
	p.volume_db = MIN_DB

func play_bgm(stream: AudioStream, loop: bool = true, fade_sec: float = 0.8) -> void:
	if stream == null: return
	if _current_stream == stream and _active and _active.playing:
		return

	_disconnect_loop_if_connected(_player_a)
	_disconnect_loop_if_connected(_player_b)

	_inactive.stop()
	_inactive.stream = stream
	_inactive.pitch_scale = 1.0
	_inactive.volume_db = MIN_DB
	_inactive.stream_paused = false

	if use_stream_loop:
		if _inactive.stream and _inactive.stream.has_method("set_loop"):
			_inactive.stream.set_loop(loop)
		elif _inactive.stream and "loop" in _inactive.stream:
			_inactive.stream.loop = loop
	else:
		if loop and not _inactive.finished.is_connected(_inactive.play):
			_inactive.finished.connect(_inactive.play)

	_inactive.play()

	var old_active := _active
	var t := create_tween()
	t.set_parallel(true)
	t.tween_property(_inactive, "volume_db", _db_for_linear(_master_volume_linear), fade_sec)

	if old_active and old_active.playing:
		t.tween_property(old_active, "volume_db", MIN_DB, fade_sec)
		t.tween_callback(func():
			if is_instance_valid(old_active):
				_clear_player(old_active))

	_active = _inactive
	_inactive = old_active
	_current_stream = stream

func stop_bgm(fade_sec: float = 0.5) -> void:
	if not _active or not _active.playing:
		_current_stream = null
		_disconnect_loop_if_connected(_player_a)
		_disconnect_loop_if_connected(_player_b)
		if _player_a: _player_a.volume_db = MIN_DB
		if _player_b: _player_b.volume_db = MIN_DB
		return

	var cur := _active
	_disconnect_loop_if_connected(cur)

	var t := create_tween()
	t.tween_property(cur, "volume_db", MIN_DB, fade_sec)
	t.tween_callback(func():
		if is_instance_valid(cur):
			cur.stop()
			cur.stream = null
		_current_stream = null
	)

# 🔥 새로 추가: 씬 전환 전에 안전하게 쓸 수 있는 await 함수
func fade_out_bgm(fade_sec: float = 0.5) -> void:
	if not _active or not _active.playing:
		_current_stream = null
		return
	_disconnect_loop_if_connected(_active)

	var t := get_tree().create_tween() # 씬 교체에도 안 죽음
	t.tween_property(_active, "volume_db", MIN_DB, fade_sec)
	await t.finished
	if is_instance_valid(_active):
		_active.stop()
		_active.stream = null
	_current_stream = null

func set_bgm_volume_linear(v: float) -> void:
	_master_volume_linear = clampf(v, 0.0, 1.0)
	for p in [_player_a, _player_b]:
		if p:
			p.volume_db = _db_for_linear(_master_volume_linear) if p.playing else MIN_DB

func mute_bgm(mute: bool) -> void:
	set_bgm_volume_linear(0.0 if mute else 1.0)

func play_sfx(stream: AudioStream) -> void:
	if stream == null: return
	var p := AudioStreamPlayer.new()
	p.bus = SFX_BUS
	p.stream = stream
	add_child(p)
	p.finished.connect(p.queue_free, Object.CONNECT_ONE_SHOT)
	p.play()

func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			if is_instance_valid(_active) and _active.playing:
				_active.stream_paused = true
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED:
			if is_instance_valid(_active) and _active.stream:
				_active.stream_paused = false
