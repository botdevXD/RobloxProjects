local Timer = {}
Timer.__index = Timer

function Timer.new()
	local self = setmetatable({}, Timer)
	
	self._Timer = Instance.new("BindableEvent", script)
	self._Countdown = Instance.new("BindableEvent", script)
	
	self.Timer = self._Timer.Event
	self.Countdown = self._Countdown.Event
	
	self.TimerUUID = nil
	self.CountDownUUID = nil
	
	return self
end

function Timer:StartCountDown(StartSeconds)
	self:EndCountDown()
	local UUID = Timer.Services.HttpService:GenerateGUID(false)
	local TotalSeconds = StartSeconds
	
	task.spawn(function()
		self.CountDownUUID = UUID
		
		self._Countdown:Fire("count_down_update", TotalSeconds)
		task.wait(1)
		
		repeat
			TotalSeconds = math.clamp(TotalSeconds - 1, 0, math.huge)
			
			self._Countdown:Fire("count_down_update", TotalSeconds)
			
			if TotalSeconds <= 0 then
				break
			end
			
			task.wait(1)
		until self.CountDownUUID == nil or self.CountDownUUID ~= UUID or TotalSeconds <= 0
		
		if self.CountDownUUID == nil or self.CountDownUUID ~= UUID then
			self._Countdown:Fire("stopped")
		elseif self.CountDownUUID == UUID then
			self._Countdown:Fire("finished")
		end
		
		self.CountDownUUID = nil
	end)
end

function Timer:EndCountDown()
	self.CountDownUUID = nil
end

function Timer:StartTimer(EndSeconds)
	self:EndTimer()
	local UUID = Timer.Services.HttpService:GenerateGUID(false)
	local TotalSeconds = 0
	
	self.TimerUUID = UUID
	
	task.spawn(function()
		
		self._Timer:Fire("timer_update", TotalSeconds)
		task.wait(1)
		
		repeat
			TotalSeconds = math.clamp(TotalSeconds, 0, EndSeconds)
			TotalSeconds += 1
			
			self._Timer:Fire("timer_update", TotalSeconds)
			
			if TotalSeconds >= EndSeconds then
				break
			end

			task.wait(1)
		until self.TimerUUID == nil or self.TimerUUID ~= UUID
		
		if self.TimerUUID == nil or self.TimerUUID ~= UUID then
			self._Timer:Fire("stopped")
		elseif self.TimerUUID == UUID then
			self._Timer:Fire("finished")
		end

		self.TimerUUID = nil
	end)
end

function Timer:EndTimer()
	self.TimerUUID = nil
end

function Timer:Destroy()
	self:EndCountDown()
	self:EndTimer()
	
	for Index, Key in pairs(self) do
		if typeof(Key) == "Instance" then
			if Key:IsA("BindableEvent") then
				Key:Destroy()
				self[Index] = nil
			end
		end
	end
	
	self.Timer = nil
	self.Countdown = nil

	self.TimerUUID = nil
	self.CountDownUUID = nil
end

return Timer
