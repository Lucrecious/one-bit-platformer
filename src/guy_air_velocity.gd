extends Resource

export(float) var acceleration := 70.0

func do(velocity: float, target_speed: float, input_direction: int, delta: float) -> float:
	var speed := abs(velocity)
	var direction := sign(velocity)
	
	var input_dir_not_oppose_vel_dir := input_direction == direction
	
	# if user is not trying to oppose moving direction and the current speed
	# is already higher than target speed, then continue with currently velocity
	if input_dir_not_oppose_vel_dir and speed >= target_speed:
		return velocity
	
	var acc_direction := sign(target_speed * input_direction - velocity)
	var increment := acc_direction * acceleration * delta * delta
	velocity = ((velocity * delta) + increment) / delta
	
	return velocity
