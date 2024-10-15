extends CharacterBody2D  # Extends the CharacterBody2D class, which provides 2D physics-based movement for the character
var enemy_inattack_range=false
var enemy_attack_cooldown=true
var health=100
var player_alive=true
const speed = 100  # Constant variable to define movement speed
var current_dir = "none"
var attack_ip=false


func _ready():
	$AnimatedSprite2D.play("front_idle")
		
	
# The physics process function is called every frame to handle physics-related updates
func _physics_process(delta):  
	player_movement(delta)  # Calls the player_movement function to handle character movement
	enemy_attack()
	attack()
	current_camera()
	update_health()
	
	
	if health <=0:
		player_alive=0 #go back to menu or respond
		health=0
		print("Player has been killed")
		self.queue_free()
# Function to handle the player's movement
func player_movement(delta): 
	if attack_ip == true:
		velocity.x = 0
		velocity.y = 0
		return  # Stop movement logic if attacking
	# Check if the right movement key is pressed
	if Input.is_action_pressed("ui_right"):  
		current_dir = "right"
		play_animation(1)
		velocity.x = speed  # Move right by setting the horizontal velocity to the speed value
		velocity.y = 0  # Ensure vertical velocity is zero to prevent diagonal movement
	
	# Check if the left movement key is pressed
	elif Input.is_action_pressed("ui_left"):  
		current_dir = "left"
		play_animation(1)
		velocity.x = -speed  # Move left by setting the horizontal velocity to negative speed
		velocity.y = 0  # Ensure vertical velocity is zero
	
	# Check if the down movement key is pressed
	elif Input.is_action_pressed("ui_down"):  
		current_dir = "down"
		play_animation(1)
		velocity.y = speed  # Move down by setting the vertical velocity to speed
		velocity.x = 0  # Ensure horizontal velocity is zero
	
	# Check if the up movement key is pressed
	elif Input.is_action_pressed("ui_up"): 
		current_dir = "up" 
		play_animation(1)
		velocity.y = -speed  # Move up by setting the vertical velocity to negative speed
		velocity.x = 0  # Ensure horizontal velocity is zero
	
	# If no movement keys are pressed, set the velocity to zero (stop movement)
	else:  
		velocity.x = 0  
		velocity.y = 0
		play_animation(0)  # Call play_animation with '0' to play idle animation

	move_and_slide()  # Apply the velocity and move the character, handling collisions automatically

# Function to play animations based on movement and direction
func play_animation(movement):
	var dir = current_dir
	var animation = $AnimatedSprite2D  # Reference to the animated sprite node
	if dir == "right":
		animation.flip_h = false  # Ensure the sprite is not flipped horizontally
		if movement == 1:
			animation.play("side_walk")  # Play walking animation
		elif movement == 0:
			if attack_ip==false:
				animation.play("side_idle")  # Play idle animation
	
	elif dir == "left":
		animation.flip_h = true  # Flip sprite horizontally to face left
		if movement == 1:
			animation.play("side_walk")
		elif movement == 0:
			if attack_ip==false:
				animation.play("side_idle")
	
	elif dir == "down":
		animation.flip_h = false
		if movement == 1:
			animation.play("front_walk")
		elif movement == 0:
			if attack_ip==false:
				animation.play("front_idle")
	
	elif dir == "up":
		animation.flip_h = false
		if movement == 1:
			animation.play("back_walk")
		elif movement == 0:
			if attack_ip==false:
				animation.play("back_idle")
func player():
	pass

func _on_player_hitbox_body_entered(body: Node2D):
	if body.has_method("enemy"):
		enemy_inattack_range=true

func _on_player_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range=false
	
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown == true:
		health=health-10
		enemy_attack_cooldown=false
		$attack_cooldown.start()
		print("player health=",health)
func _on_attack_cooldown_timeout():
	enemy_attack_cooldown=true
func attack():
	var dir = current_dir
	# When attack is pressed
	if Input.is_action_just_pressed("attack"):
		global.player_current_attack = true
		attack_ip = true
		$deal_attack_timer.start()

		# Choose the right attack animation based on direction
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("side_attack")
		elif dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("side_attack")
		elif dir == "down":
			$AnimatedSprite2D.play("front_attack")
		elif dir == "up":
			$AnimatedSprite2D.play("back_attack")

	# When attack is released
	if Input.is_action_just_released("attack"):
		global.player_current_attack = false
		attack_ip = false
		$AnimatedSprite2D.play("idle")  # Reset to idle animation


func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack=false
	attack_ip=false
	
func update_health():
	var healthbar=$healthbar
	healthbar.value=health
	if health>=100:
		healthbar.visible=false
	else:
		healthbar.visible=true


func _on_regen_time_timeout():
	if health<100:
		health=health+20
		if health>100:
			health=100
	if health<=0:
		health=0
func current_camera():
	if global.current_scene=="world":
		$world_camera.enabled=true
		$cliffside_camera.enabled=false
	elif global.current_scene=="cliff_side":
		$world_camera.enabled=false
		$cliffside_camera.enabled=true
	
