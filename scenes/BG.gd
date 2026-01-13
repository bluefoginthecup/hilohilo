extends Node2D

@export var speed_level := 0   # 0~12
@export var max_speed_px := 1600.0  # 레벨 12일 때 px/s (원하면 조절)

@onready var a: Sprite2D = $A
@onready var b: Sprite2D = $B

var w := 0.0
var half_w := 0.0

func _ready():
	w = a.texture.get_width() * a.scale.x
	half_w = w * 0.5
	b.position = a.position + Vector2(w, 0)

func _process(delta):
	# speed_level(0~12) -> 실제 속도(px/s)
	var speed_px := max_speed_px * (float(speed_level) / 12.0)
	if speed_px <= 0.0:
		return

	var dx: float = speed_px * delta

	a.position.x -= dx
	b.position.x -= dx

	# 픽셀 스냅
	a.position.x = round(a.position.x)
	b.position.x = round(b.position.x)

	# 랩
	if (a.position.x + half_w) < 0.0:
		a.position.x = b.position.x + w
	if (b.position.x + half_w) < 0.0:
		b.position.x = a.position.x + w
