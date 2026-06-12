extends Node3D

var damage: float
var fire_rate: float
var range: float
@export var data:WeaponResource

@onready var raycast: RayCast3D = $ShootRaycast
@onready var muzzle: Marker3D = $Muzzle

var can_shoot: bool = true

func _ready() -> void:
	damage = data.damage
	fire_rate = data.fire_rate
	range = data.range

func shoot(aim_direction: Vector3) -> bool:
	if not can_shoot:
		return false
	raycast.global_position = muzzle.global_position
	
	#Calculate target position relative to where the raycast node is
	var global_target_point = muzzle.global_position + (aim_direction * range)
	raycast.target_position = raycast.to_local(global_target_point)
	
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		var hit_object = raycast.get_collider()
		
		if hit_object.has_method("take_damage"):
			hit_object.take_damage(damage)
			print(hit_object,"took: ", damage)
			
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
	return true
