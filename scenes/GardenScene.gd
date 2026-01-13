extends "res://scenes/BaseSceneUI.gd"


const GARDEN_THEME := preload("res://assets/audio/garden_theme.ogg")




@onready var bg: TextureRect = $Background
@onready var jordy: Sprite2D = $Jordy
@onready var bubble: Label = $Bubble

var messages := [
	"오늘은 맑고 화창하데이!",
	"오후에 비 온다 카더라. 우산 챙기이소.",
	"구름 좀 끼었는데 바람은 선선하이 좋다.",
	"눈 예보 있데이, 따뜻하게 입고 다니소."
]

func _ready() -> void:
	AudioManager.play_bgm(GARDEN_THEME, true, 0.8)

	# 대사 랜덤
	bubble.text = messages[randi() % messages.size()]
	# 조르디 좌우 왔다갔다
	_start_walk()
	# 말풍선은 조르디 머리 위에 고정
	_update_bubble_pos()

func _process(_dt: float) -> void:
	_update_bubble_pos()

func _update_bubble_pos() -> void:
	# 조르디 머리 위로 살짝
	var offset := Vector2(0, -110)
	var pos := jordy.global_position + offset
	# 라벨 중앙을 조르디 가운데에 맞추기
	pos.x -= bubble.size.x * 0.5
	bubble.global_position = pos

func _start_walk() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(jordy, "position:x", jordy.position.x + 140, 2.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(jordy, "position:x", jordy.position.x, 2.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
