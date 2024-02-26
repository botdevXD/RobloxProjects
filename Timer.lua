-- Made by _Ben#2020 / 0x74_Dev /

local Timer = {}
Timer.__index = Timer

function Timer.new()
	local self = setmetatable({}, Timer)
	
	self._Timer = Instance.new("BindableEvent", script)
	self._Countdown = Instance.new("BindableEvent", script)
	
	self.Timer = self._Timer.Event
	self.Countdown = self._Countdown.Event

	self.TimerPause = false
	self.CountdownPause = false
	self.AllowedToResumeCountdown = true
	self.AllowedToResumeTimer = true
	
	self.TimerUUID = nil
	self.CountDownUUID = nil
	
	return self
end

function Timer:CountDownResumeAbleToggle(bool)
	self.AllowedToResumeCountdown = bool
end

function Timer:TimerResumeAbleToggle(bool)
	self.AllowedToResumeTimer = bool
end

function Timer:CanResumeCountDown()
	return self.AllowedToResumeCountdown
end

function Timer:CanResumeTimer()
	return self.AllowedToResumeTimer
end

function Timer:PauseCountDown()
	self.CountdownPause = true
end

function Timer:ResumeCountDown()
	self.CountdownPause = false
end

function Timer:StartCountDown(StartSeconds)
	self:EndCountDown()
	local UUID = Timer.Services.HttpService:GenerateGUID(false)
	local TotalSeconds = StartSeconds
	
	task.spawn(function()
		self.CountDownUUID = UUID
		
		self._Countdown:Fire("started")
		self._Countdown:Fire("count_down_update", TotalSeconds)
		task.wait(1)
		
		repeat
			if self.CountdownPause == false then
				TotalSeconds = math.clamp(TotalSeconds - 1, 0, math.huge)
				
				self._Countdown:Fire("count_down_update", TotalSeconds)
				
				if TotalSeconds <= 0 then
					break
				end
			end
			
			task.wait(1)
		until self.CountDownUUID == nil or self.CountDownUUID ~= UUID or TotalSeconds <= 0
		
		if self.CountDownUUID == nil or self.CountDownUUID ~= UUID then
			self._Countdown:Fire("stopped")
		elseif self.CountDownUUID == UUID then
			self._Countdown:Fire("finished")
			
			self.CountDownUUID = nil
		end
	end)
end

function Timer:EndCountDown()
	self.CountdownPause = false
	self.CountDownUUID = nil
end

function Timer:PauseTimer()
	self.TimerPause = true
end

function Timer:ResumeTimer()
	self.TimerPause = false
end

function Timer:StartTimer(EndSeconds)
	self:EndTimer()
	local UUID = Timer.Services.HttpService:GenerateGUID(false)
	local TotalSeconds = 0
	
	self.TimerUUID = UUID
	
	task.spawn(function()
		
		self._Timer:Fire("started")
		self._Timer:Fire("timer_update", TotalSeconds)
		task.wait(1)
		
		repeat
			if self.TimerPause == false then
				TotalSeconds = math.clamp(TotalSeconds, 0, EndSeconds)
				TotalSeconds += 1
				
				self._Timer:Fire("timer_update", TotalSeconds)
				
				if TotalSeconds >= EndSeconds then
					break
				end
			end

			task.wait(1)
		until self.TimerUUID == nil or self.TimerUUID ~= UUID
		
		if self.TimerUUID == nil or self.TimerUUID ~= UUID then
			self._Timer:Fire("stopped")
		elseif self.TimerUUID == UUID then
			self._Timer:Fire("finished")
			
			self.TimerUUID = nil
		end
	end)
end

function Timer:EndTimer()
	self.TimerPause = false
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
