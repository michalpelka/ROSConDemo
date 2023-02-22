local PathFollower = {
	Properties = {
		Path = {default = EntityId()},
		Speed = 1.0,
		LookAheadAmount = 1.0,
		Start = 0.0,
		StoppingDistance = 300,
	},
	Spline = nil,
	SplineTransform = nil,
	Address = SplineAddress(0,0),
	Distance = 0.0,
	SpeedMultiplier = 1.0,
	StartTime = 0.0,
}

function PathFollower:OnActivate()
	self.tickHandler = TickBus.Connect(self,0)
	self.Distance = self.Properties.Start
	self.SpeedMultiplier = 1.0
	self.StoppingDistance = self.Properties.StoppingDistance
	
	local currentTime = TickRequestBus.Broadcast.GetTimeAtCurrentTick()
	self.StartTime = currentTime:GetSeconds()
end

function PathFollower:OnTick(deltaTime, scriptTime)
	if self.Spline == nil then
		self.Spline = SplineComponentRequestBus.Event.GetSpline(self.Properties.Path)
		self.SplineTransform = TransformBus.Event.GetWorldTM(self.Properties.Path)
		self.Address.segmentIndex = 0
		self.Address.segmentFraction = 0
	end
	
	if self.Spline ~= nil then
		self.Address = self.Spline:GetAddressByDistance(self.Distance)
		local position = self.Spline:GetPosition(self.Address)
		-- get the player speed
		local speed = self.Properties.Speed * self.SpeedMultiplier
		
		local totalDistance = self.Spline:GetSplineLength()

		if (self.Distance >= (totalDistance - self.StoppingDistance)) then
		    speed = speed * ((totalDistance - self.Distance) / self.StoppingDistance)
			if speed < 0.1 then
				speed = 0.0
				self.tickHandler:Disconnect()
				self.tickHandler = nil
			end
		end

		self.Distance = self.Distance + deltaTime * speed
		
		if self.Distance >= totalDistance then
			self.Distance = totalDistance
			self.tickHandler:Disconnect()
			self.tickHandler = nil
		end
		
		local lookAhead = self.Distance + self.Properties.LookAheadAmount
		local lookAheadAddress = self.Spline:GetAddressByDistance(lookAhead)
		local lookAheadPosition = self.Spline:GetPosition(lookAheadAddress)
		
		local tm = self.SplineTransform * MathUtils.CreateLookAt(position, lookAheadPosition, AxisType.YPositive)
		TransformBus.Event.SetWorldTM(self.entityId, tm)
	end
end

function PathFollower:OnDeactivate()
	if self.tickHandler ~= nil then
		self.tickHandler:Disconnect()
	end
end

return PathFollower
	

