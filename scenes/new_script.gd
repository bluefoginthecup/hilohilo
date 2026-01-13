extends Node2D

# 메인 게임 씬
# 씬 구조:
# - Node2D (Main) <- 이 스크립트
#   - ParallaxBackground
#     - ParallaxLayer (Sky)
#       - Sprite2D
#     - ParallaxLayer (LeftWall)
#       - Sprite2D
#     - ParallaxLayer (RightWall)
#       - Sprite2D
#     - ParallaxLayer (Floor)
#       - Sprite2D
#   - UI (CanvasLayer)
#     - Label (Speed)

var base_speed = 300.0
var current_speed = 300.0
var max_speed = 600.0
var acceleration = 50.0

@onready var parallax_bg = $ParallaxBackground
@onready var speed_label = $UI/SpeedLabel

func _ready():
	setup_parallax_layers()
	
func _process(delta):
	# 속도 증가 (시간이 지날수록 빨라짐)
	current_speed = min(current_speed + acceleration * delta, max_speed)
	
	# ParallaxBackground 스크롤
	if parallax_bg:
		parallax_bg.scroll_offset.x -= current_speed * delta
	
	# UI 업데이트
	if speed_label:
		speed_label.text = "Speed: %.0f" % current_speed

func _input(event):
	# 스페이스바로 속도 부스트
	if event.is_action_pressed("ui_accept"):
		current_speed = min(current_speed + 100, max_speed)

func setup_parallax_layers():
	# ParallaxBackground가 없으면 생성
	if not parallax_bg:
		parallax_bg = ParallaxBackground.new()
		add_child(parallax_bg)
		
		# 하늘 레이어
		var sky_layer = create_parallax_layer("Sky", 0.1, Color(0.53, 0.81, 0.92), Vector2(1920, 400), Vector2(0, 0))
		parallax_bg.add_child(sky_layer)
		
		# 왼쪽 벽 레이어
		var left_wall_layer = create_parallax_layer("LeftWall", 0.5, Color(0.7, 0.5, 0.4), Vector2(400, 1080), Vector2(0, 0))
		parallax_bg.add_child(left_wall_layer)
		
		# 오른쪽 벽 레이어
		var right_wall_layer = create_parallax_layer("RightWall", 0.5, Color(0.7, 0.5, 0.4), Vector2(400, 1080), Vector2(1520, 0))
		parallax_bg.add_child(right_wall_layer)
		
		# 바닥 레이어
		var floor_layer = create_parallax_layer("Floor", 1.0, Color(0.4, 0.4, 0.4), Vector2(1920, 300), Vector2(0, 780))
		parallax_bg.add_child(floor_layer)

func create_parallax_layer(layer_name: String, motion_scale: float, color: Color, size: Vector2, position: Vector2) -> ParallaxLayer:
	var layer = ParallaxLayer.new()
	layer.name = layer_name
	layer.motion_scale = Vector2(motion_scale, 0)
	layer.motion_mirroring = Vector2(size.x, 0)
	
	# 스프라이트 생성
	var sprite = Sprite2D.new()
	sprite.texture = create_colored_texture(size, color, layer_name)
	sprite.centered = false
	sprite.position = position
	
	layer.add_child(sprite)
	return layer

func create_colored_texture(size: Vector2, base_color: Color, layer_name: String) -> ImageTexture:
	var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	
	match layer_name:
		"Sky":
			# 그라데이션 하늘
			for y in range(int(size.y)):
				var t = float(y) / size.y
				var color = base_color.lerp(Color(0.9, 0.95, 1.0), t)
				for x in range(int(size.x)):
					image.set_pixel(x, y, color)
		
		"LeftWall", "RightWall":
			# 벽돌 패턴
			for y in range(int(size.y)):
				for x in range(int(size.x)):
					var brick_x = int(x / 80)
					var brick_y = int(y / 40)
					var offset = (brick_y % 2) * 40
					var is_border = (x + offset) % 80 < 4 or y % 40 < 4
					var color = base_color.darkened(0.2) if is_border else base_color
					image.set_pixel(x, y, color)
		
		"Floor":
			# 도로 패턴
			for y in range(int(size.y)):
				for x in range(int(size.x)):
					var line_pos = x % 200
					var is_line = line_pos > 90 and line_pos < 110 and y > size.y * 0.3
					var color = Color.WHITE if is_line else base_color
					image.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(image)
