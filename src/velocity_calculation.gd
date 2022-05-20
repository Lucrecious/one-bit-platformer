extends Resource

export(float) var on_target_acceleration := 70.0
export(float) var over_target_against := 40.0
export(float) var over_target_neutral := 20.0
export(float) var over_target_parallel := 10.0

func do(velocity: float, target_speed: float, input_direction: int, delta: float) -> float:
	target_speed = target_speed * input_direction
	if is_equal_approx(velocity, target_speed):
		return target_speed
	
	var over_target := target_speed != 0 and abs(velocity) > abs(target_speed) + 1.0
	
	if over_target:
		var velocity_direction := sign(velocity)
		if input_direction == 0:
			velocity = velocity - velocity_direction * over_target_neutral * delta
		elif input_direction  == velocity_direction:
			velocity = velocity - velocity_direction * over_target_parallel * delta
		else: # input_direction != velocity_direction and input_direction != 0
			velocity = velocity - velocity_direction * over_target_against * delta
	else:
		var direction := sign(target_speed - velocity)
		if direction < 0:
			velocity = velocity - on_target_acceleration * delta
			velocity = max(velocity, target_speed)
		elif direction > 0:
			velocity = velocity + on_target_acceleration * delta
			velocity = min(velocity, target_speed)
	
	return velocity
