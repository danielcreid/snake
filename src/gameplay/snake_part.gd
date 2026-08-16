class_name SnakePart extends Area2D

signal food_eaten
signal obstacle_hit(obstacle)

var last_position: Vector2

func _ready() -> void:
	self.area_entered.connect(_on_collision)
	self.body_entered.connect(_on_collision)
	
	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = $Sprite2D.texture.atlas
	atlas_texture.region = Rect2(0, 0, Global.GRID_SIZE, Global.GRID_SIZE)
	atlas_texture.filter_clip = true
	$Sprite2D.texture = atlas_texture

func move_to(new_position) -> void:
	last_position = self.position
	self.position = new_position

func _on_collision(object) -> void:
	if object.is_in_group("food"):
		food_eaten.emit()
		object.call_deferred("queue_free")
	else:
		obstacle_hit.emit(object)
