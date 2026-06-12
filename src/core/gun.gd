extends Node3D

var damage: float
var fire_rate: float
var range: float
@export var data:WeaponResource

@onready var raycast: RayCast3D = $ShootRaycast
@onready var muzzle: Marker3D = $Muzzle
@onready var muzzle_flash_mesh: MeshInstance3D = $Muzzle/MuzzleFlashMesh

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
	
func trigger_muzzle_flash():
	var material = muzzle_flash_mesh.get_active_material(0) as ShaderMaterial
	if material:
		material.set_shader_parameter("seed", randf())
		material.set_shader_parameter("flash_intensity", 5.0)
		# Reset any running tweens on this object to prevent overlap glitching
		var tween = create_tween()
		
		# Instantly spike the flash intensity to blinding levels
		material.set_shader_parameter("flash_intensity", 10.0)
		
		# Smoothly drop it back down to absolute 0 over 0.05 seconds
		tween.tween_property(material, "shader_parameter/flash_intensity", 0.0, 0.05)
