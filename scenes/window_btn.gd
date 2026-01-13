# res://ui/WindowButton.gd
extends TextureButton

# 필요하면 프리로드(성능/GC 안정)
const TEX_CLEAR  = preload("res://assets/ui/window/window.png")
const TEX_RAIN   = preload("res://assets/ui/window/window.png")
const TEX_SNOW   = preload("res://assets/ui/window/window.png")
const TEX_CLOUDY = preload("res://assets/ui/window/window.png")

# 눌림 텍스처(선택)
# const TEX_CLEAR_P  = preload("res://assets/ui/window/window_clear_pressed.png")
# ...

func _ready():
	pressed.connect(_on_pressed)

	# 1) 초기에 한 번 세팅
	_apply_weather(_get_weather_state())

	# 2) 날씨 서비스가 있으면 신호 연결 (없으면 이 라인은 건너뛰어도 됨)
	#if #Engine.has_singleton("WeatherService"):
		#WeatherService.weather_changed.connect(_apply_weather)

func _apply_weather(state: String):
	match state:
		"rain":
			texture_normal = TEX_RAIN
			# texture_pressed = TEX_RAIN_P
		"snow":
			texture_normal = TEX_SNOW
		"cloudy":
			texture_normal = TEX_CLOUDY
		_:
			texture_normal = TEX_CLEAR

func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/GardenScene.tscn")

# 임시/대체용: 날씨 서비스 없을 때 쓰는 함수
func _get_weather_state() -> String:
	# TODO: 실사용에선 WeatherService.state 리턴
	# 지금은 테스트 편하게 여기 값만 바꿔가며 확인해라
	return "clear"  # "rain", "snow", "cloudy"
