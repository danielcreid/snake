class_name SnakePart extends Area2D

signal food_eaten
signal obstacle_hit(obstacle)

const SHADOW_OFFSET := Vector2(2, 2)

@onready var snake_sprite = %SnakeSprite
@onready var snake_shadow_sprite = %SnakeShadowSprite

var last_position: Vector2

func _ready() -> void:
	self.area_entered.connect(_on_collision)
	self.body_entered.connect(_on_collision)
	
	var atlas_texture: AtlasTexture = AtlasTexture.new()
	atlas_texture.atlas = snake_sprite.texture.atlas
	atlas_texture.region = Rect2(0, 0, Global.GRID_SIZE, Global.GRID_SIZE)
	atlas_texture.filter_clip = true
	snake_sprite.texture = atlas_texture
	
	var shadow_atlas_texture: AtlasTexture = AtlasTexture.new()
	shadow_atlas_texture.atlas = snake_sprite.texture.atlas
	shadow_atlas_texture.region = atlas_texture.region
	shadow_atlas_texture.filter_clip = true
	snake_shadow_sprite.texture = shadow_atlas_texture
	snake_shadow_sprite.position = snake_sprite.position + SHADOW_OFFSET
	snake_shadow_sprite.z_index = snake_sprite.z_index - 1

func move_to(new_position) -> void:
	last_position = self.position
	self.position = new_position

func set_region(region: Rect2) -> void:
	snake_sprite.texture.region = region
	snake_shadow_sprite.texture.region = region

func _on_collision(object) -> void:
	if object.is_in_group("food"):
		food_eaten.emit()
		object.call_deferred("queue_free")
	else:
		obstacle_hit.emit(object)
