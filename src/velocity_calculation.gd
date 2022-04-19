extends Resource

export(float) var turn_speed_per_sec := 7.0 * 11.0

func do(velocity: float, target_speed: float, input_direction: int, delta: float) -> float:
	target_speed = target_speed * input_direction
	if is_equal_approx(velocity, target_speed):
		return target_speed
	
	var direction := sign(target_speed - velocity)
	if direction < 0:
		velocity = velocity - turn_speed_per_sec * delta
		velocity = max(velocity, target_speed)
	elif direction > 0:
		velocity = velocity + turn_speed_per_sec * delta
		velocity = min(velocity, target_speed)
	
	return velocity
