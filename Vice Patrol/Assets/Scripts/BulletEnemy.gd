extends RigidBody2D

export (int) var projectile_speed = 50
export (int) var life_time = 1.5
export (bool) var direction_down = false
var animation = preload ("res://Scenes/EnemyAboveExplosionBulletAnimation.tscn")
var hole = preload ("res://Scenes/SmallHole_Enemy.tscn")
onready var position_bomb = get_node("Position2D")
var animationInstance = null
export (bool) var is_bomb = false
var holeInstance = null
var was_aimed_to_hole = false
func _ready():
	if !direction_down:
		apply_impulse(Vector2(),Vector2(-projectile_speed,0).rotated(rotation))
		SelfDead()
	else:
		animationInstance = animation.instance()
		add_child(animationInstance)
		animationInstance.visible = false
		animationInstance.playing = false
		var xvelocity = 0
		if is_bomb:
			xvelocity = GlobalVariables.playerVelocity_x+randi()%100+200
			add_force(Vector2(),Vector2(xvelocity,projectile_speed).rotated(rotation))
#			yield(get_tree().create_timer(1),"timeout")
#			add_force(Vector2(),Vector2(-xvelocity,projectile_speed).rotated(rotation))
		else:
			xvelocity = GlobalVariables.playerVelocity_x
			apply_impulse(Vector2(),Vector2(xvelocity,projectile_speed).rotated(rotation))
func SelfDestruct():
	set_collision_mask_bit(0,false)
	$Sprite.visible = false
	if !is_bomb:
		add_force(Vector2(0,0),Vector2(0,1000))
	else:
		life_time +=5
#		set_collision_mask_bit(2,false)
	mass = 0
	weight = 1000
	friction =1000
	yield(get_tree().create_timer(life_time),"timeout")
	queue_free()
	
func dead():
	queue_free()
func SelfDead():
	yield(get_tree().create_timer(life_time),"timeout")
	queue_free()

func _on_BulletEnemy_FlyingType1_body_entered(body):
	if "Player" in body.name:
		body.process_damage_enemy()
	elif "Terrain" in body.name:
		if !was_aimed_to_hole and is_bomb:
			holeInstance = hole.instance()
			body.add_child(holeInstance)
			holeInstance.scale = Vector2(1,1)
			holeInstance.global_position = position_bomb.global_position - Vector2(0,-64)
		else:
			animationInstance.playing = true
			animationInstance.visible = true
	elif "Hole" in body.name:
		$CollisionShape2D.disabled = true
		set_collision_mask_bit(4,false)
		was_aimed_to_hole = true
		animationInstance.playing = true
		animationInstance.visible = true
		queue_free()
	SelfDestruct()
	
func _on_BulletEnemy_body_entered(body):
	if "Player" in body.name:
		body.process_damage_enemy()
		dead()
	elif "Terrain" in body.name:
		if is_bomb:
			body.add_child(holeInstance)
			holeInstance.scale = Vector2(1,1)
			holeInstance.global_position = position_bomb.global_position - Vector2(0,-64)		
		else:
			animationInstance.playing = true
			animationInstance.visible = true
		SelfDestruct()
