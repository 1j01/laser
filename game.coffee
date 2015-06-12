
new p2.WebGLRenderer ->
	
	# Create a World
	@setWorld world = new p2.World
		gravity: [0, -10] # Set gravity to -10 in y direction
	
	# Set high friction so the wheels don't slip
	world.defaultContactMaterial.friction = 100
	
	# Create a body for the ground
	ground = new p2.Body
	ground.addShape new p2.Plane
	world.addBody ground

	# Add circle bump in the center
	bump = new p2.Body position: [0, -1]
	bump.addShape new p2.Circle 2
	world.addBody bump
	
	# Create chassis for our car
	carX = -4
	carY = 1
	chassis = new p2.Body mass: 1, position: [carX, carY]
	chassis.addShape new p2.Rectangle 1, 0.5
	world.addBody chassis
	
	# Create wheels
	backWheel = new p2.Body mass: 1, position: [carX - 0.5, carY - 0.3]
	frontWheel = new p2.Body mass: 1, position: [carX + 0.5, carY - 0.3]
	backWheel.addShape new p2.Circle 0.2
	frontWheel.addShape new p2.Circle 0.2
	world.addBody backWheel
	world.addBody frontWheel
	
	# Constrain wheels to chassis with revolute constraints.
	# Revolutes lets the connected bodies rotate around a shared point.
	backAxle = new p2.RevoluteConstraint chassis, backWheel,
		localPivotA: [-0.5, -0.3] # Where to hinge first wheel on the chassis
		localPivotB: [0, 0] # Where the hinge is in the wheel (center)
		collideConnected: no
	
	frontAxle = new p2.RevoluteConstraint chassis, frontWheel,
		localPivotA: [0.5, -0.3] # Where to hinge second wheel on the chassis
		localPivotB: [0, 0] # Where the hinge is in the wheel (center)
		collideConnected: no
	
	world.addConstraint backAxle
	world.addConstraint frontAxle
	
	# Enable the constraint motor for the back wheel
	backAxle.enableMotor()
	backAxle.setMotorSpeed 10 # Rotational speed in radians per second
	
	@frame 0, 0, 8, 6
