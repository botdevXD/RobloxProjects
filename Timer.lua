local Timer = {
	LoadPosition = 0
}
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
	
	local TotalSeconds = StartSeconds
	
	task.spawn(function()
		local UUID = Timer.Services.HttpService:GenerateGUID(false)
		
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

end

function Timer:EndTimer()

end

function Timer:Destroy()
	self:EndCountDown()
	self:EndTimer()
end

return Timer
