local WhiteTexture = "rbxassetid://124776870209623"
local MaterialService = game:GetService("MaterialService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local RegisteredObject = 0

-- Lock a property to a fixed value
local blockLocking={"Trail", "ParticleEmitter", "Beam"}
local function lockProperty(instance, propertyName, lockedValue)
	instance[propertyName] = lockedValue
	--[[
	local blocked=false
	for i,v in blockLocking do
		if instance:IsA(v) then
			blocked=true
			break
		end
	end
	
	if not blocked then
		local rate = 0
		instance:GetPropertyChangedSignal(propertyName):Connect(function()
			rate+=1
			if rate>=5 then
				return
			end
			if instance[propertyName] ~= lockedValue then
				instance[propertyName] = lockedValue
			end
		end)
	end]]
end

local function checkProperty(instance, propertyName)
	local success,result = pcall(function()
		return instance[propertyName]
	end)
	return success and result or false
end

function registerObject(Object: Instance)
	if Object:IsA("BasePart") then
		lockProperty(Object, "Material", Enum.Material.Plastic)
		RegisteredObject += 1
		print("Registered BasePart:", RegisteredObject)
	elseif Object:IsA("Texture") then
		lockProperty(Object, "Texture", WhiteTexture)
		lockProperty(Object, "Color3", Object.Color3:Lerp(Color3.new(0,0,0),0.5))
	elseif Object:IsA("Atmosphere") then
		lockProperty(Object, "Density", 0)
		lockProperty(Object, "Offset", 0)
	elseif Object:IsA("BloomEffect") or Object:IsA("DepthOfFieldEffect") or Object:IsA("SunRaysEffect") then
		lockProperty(Object, "Enabled", false)
	elseif Object:IsA("Clouds") then
		lockProperty(Object, "Cover", 0)
	elseif Object:IsA("Sky") then
		lockProperty(Object, "SkyboxBk", WhiteTexture)
		lockProperty(Object, "SkyboxDn", WhiteTexture)
		lockProperty(Object, "SkyboxFt", WhiteTexture)
		lockProperty(Object, "SkyboxLf", WhiteTexture)
		lockProperty(Object, "SkyboxRt", WhiteTexture)
		lockProperty(Object, "SkyboxUp", WhiteTexture)
	elseif Object:IsA("ParticleEmitter") or Object:IsA("Beam") then
		lockProperty(Object, "Enabled", false)
	elseif Object:IsA("Trail") then
		lockProperty(Object, "Texture", WhiteTexture)
		lockProperty(Object, "TextureLength", 1)
	elseif Object:IsA("SurfaceAppearance") then
		Object:Destroy()
	elseif Object:IsA("Decal") then
		lockProperty(Object, "Texture", WhiteTexture)
	elseif Object:IsA("SurfaceGui") then
		lockProperty(Object, "Enabled", false)
	elseif Object:IsA("PointLight") or Object:IsA("SpotLight") or Object:IsA("SurfaceLight") then
		lockProperty(Object, "Enabled", false)
	elseif Object:IsA("Lighting") then
		lockProperty(Object, "Brightness", 3)
		lockProperty(Object, "ShadowSoftness", 0)
		lockProperty(Object, "GlobalShadows", false)
		lockProperty(Object, "ClockTime", 0)
		lockProperty(Object, "Ambient", Color3.new(1,1,1))
		lockProperty(Object, "ColorShift_Top", Color3.new(0,0,0))
		lockProperty(Object, "ColorShift_Bottom", Color3.new(0,0,0))
		lockProperty(Object, "OutdoorAmbient", Color3.new(0,0,0))
		lockProperty(Object, "ExposureCompensation", 0)
	elseif Object:IsA("Beam") then
		lockProperty(Object, "Texture", WhiteTexture)
	elseif Object:IsA("ParticleEmitter") then
		lockProperty(Object, "Texture", WhiteTexture)	
	
	end
	
	if checkProperty(Object,"Texture") then
		pcall(function()
			print(Object.ClassName,"has","Texture Property")
			Object["Texture"]=WhiteTexture
		end)
	end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Billboard = Instance.new("BillboardGui")
local Frame = Instance.new("Frame", Billboard)
local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius=UDim.new(1,0)
Frame.Size=UDim2.new(1,0,1,0)
Billboard.AlwaysOnTop=true
Billboard.Size=UDim2.new(0,12,0,12)
Frame.BackgroundTransparency=0.5

local Football = ReplicatedStorage:WaitForChild("Football") :: ObjectValue
local CurrentBillboard = Billboard:Clone()
CurrentBillboard.Parent=Football.Value
Frame=CurrentBillboard:FindFirstChildOfClass("Frame")

local Camera = workspace.CurrentCamera
Football:GetPropertyChangedSignal("Value"):Connect(function()
	if CurrentBillboard then
		CurrentBillboard:Destroy()
	end
	CurrentBillboard = Billboard:Clone()
	CurrentBillboard.Parent=Football.Value
	Frame=CurrentBillboard:FindFirstChildOfClass("Frame")
end)

RunService.RenderStepped:Connect(function(deltaTime)
	local distance = (Football.Value.Position - Camera.CFrame.Position).Magnitude
	local Color = Color3.new(0, 1, 0)	

	Frame.BackgroundColor3=Color:Lerp(Color3.new(1, 0, 0), 1-math.clamp(distance/100, 0 , 1))
	
end)

game.DescendantAdded:Connect(registerObject)
-- Apply to all existing instances
task.spawn(function()
	for i, v in game:GetDescendants() do
		registerObject(v)
		if i % 100 == 0 then
			task.wait()
		end
	end
end)

-- Apply to newly added instances

