
app = new p2.WebGLRenderer ->

	# Create a World
	world = new p2.World
		gravity: [0, -10] # Set gravity to -10 in y direction
	

	@setWorld world

	# Set high friction so the wheels don't slip
	world.defaultContactMaterial.friction = 100

	# Create ground shape (plane)
	groundShape = new p2.Plane

	# Create a body for the ground
	ground = new p2.Body mass: 0 # Mass of 0 makes the body static
	ground.addShape groundShape
	world.addBody ground

	# Add circle bump in the center
	circleShape = new p2.Circle 2
	circleBody = new p2.Body position: [0, -1]

	circleBody.addShape circleShape
	world.addBody circleBody
	
	# Create chassis for our car
	chassisBody = new p2.Body mass: 1, position: [-4, 1]
	chassisShape = new p2.Rectangle 1, 0.5
	chassisBody.addShape chassisShape
	world.addBody chassisBody
	
	# Create wheels
	wheelBody1 = new p2.Body mass: 1, position: [chassisBody.position[0] - 0.5, 0.7]
	wheelBody2 = new p2.Body mass: 1, position: [chassisBody.position[0] + 0.5, 0.7]
	wheelShape1 = new p2.Circle 0.2
	wheelShape2 = new p2.Circle 0.2
	wheelBody1.addShape wheelShape1
	wheelBody2.addShape wheelShape2
	world.addBody wheelBody1
	world.addBody wheelBody2
	
	# Constrain wheels to chassis with revolute constraints.
	# Revolutes lets the connected bodies rotate around a shared point.
	revoluteBack = new p2.RevoluteConstraint chassisBody, wheelBody1,
		localPivotA: [-0.5, -0.3] # Where to hinge first wheel on the chassis
		localPivotB: [0, 0] # Where the hinge is in the wheel (center)
		collideConnected: no
	
	revoluteFront = new p2.RevoluteConstraint chassisBody, wheelBody2,
		localPivotA: [0.5, -0.3] # Where to hinge second wheel on the chassis
		localPivotB: [0, 0] # Where the hinge is in the wheel (center)
		collideConnected: no
	
	world.addConstraint revoluteBack
	world.addConstraint revoluteFront
	
	# Enable the constraint motor for the back wheel
	revoluteBack.enableMotor()
	revoluteBack.setMotorSpeed 10 # Rotational speed in radians per second
	
	@frame 0, 0, 8, 6
