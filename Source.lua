--[[
	MADE BY Pixeluted#5815
	DO NOT RESELL
	OR CLAIM TO BE YOURS
--]]

if not writefile or not readfile or not isfile or not isfolder or not hookfunction or not hookmetamethod then 
	game.Players.LocalPlayer:Kick("Unsupported Exploit! - Missing Functions writefile, readfile, isfile, isfolder, hookfunction, hookmetamethod")
end

if game.PlaceId ~= 2413927524 then 
	game.Players.LocalPlayer:Kick("Invalid Game! Please join Rake Remastered")
end

if _G.RakeEvolvedShutDownFunction and typeof(_G.RakeEvolvedShutDownFunction) == "function" then 
	_G.RakeEvolvedShutDownFunction()
end

-- [[ VARIABLES ]] --

local Player = game.Players.LocalPlayer 

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Timer = ReplicatedStorage:WaitForChild("Timer")

local FilterFolder = workspace:WaitForChild("Filter")
local ScrapFolder = FilterFolder:WaitForChild("ScrapSpawns")
local TrapsFolder = game:GetService("Workspace"):WaitForChild("Debris"):WaitForChild("Traps")
local CurrentLightingProperties = ReplicatedStorage:WaitForChild("CurrentLightingProperties")

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/RakeEvolved/Stable/MainUI.lua"))()
local Library = UI:Init()

local Labels = {
	ScrapLabels = {},
	SupplyDropLabels = {},
	PlayersLabels = {},
	WaypointLabels = {},
	RakeLabels = {},
	RakeInfoLabel = nil,
	FlareGunLabels = {}
}


local MapPoints = {
	["Safehouse"] = Vector3.new(-352.336, 16.1844, 63.7742),
	["Powerstation"] = Vector3.new(-311.052, 21.2032, -209.896),
	["Shop"] = Vector3.new(-24.9913, 16.3039, -252.213),
	["ObservationTower"] = Vector3.new(33.1612, 16.209, -45.1087),
	["Basecamp"] = Vector3.new(-75.4166, 16.7219, 214.085),
}

local Toggles = {
	sprint = false,
	scrapESP = false,
	rakeESP = false,
	playerESP = false,
	flaregunESP = false,
	flaregunNotification = false,
	supplydropESP = false,
	bypassSupplyDropLock = false,
	stunstickModifier = false,
	uvlampModifier = false,
	flashlightModifier = false,
	fullbright = false,
	nofog = false,
	alwaysDay = false,
	alwaysNight = false,
	waypoints = false,
	showRakeInfo = false,
	infiniteStamina = false,
	noFallDamage = false,
	viewCameras = false,
	timer = false,
	powerLevel = false,
	stunstickAura = false,
	unlockThirdPerson = false
}

------- [[ FUNCTIONS ]] -------

-- [[ DETECTION HOOK ]] --

local detectionCounter = 0
local detectionHook; detectionHook = hookmetamethod(game.StarterGui, '__namecall', function(self, ...)
	local Method = getnamecallmethod()

	if Method == 'SetCore' then
		detectionCounter = detectionCounter + 1
		return nil
	end 

	return detectionHook(self, ...)
end)

-- [[ SCRAPS ]] --

local function getScraps()
	local Scraps = {}

	for _,ScrapSpawn in pairs(ScrapFolder:GetChildren()) do 
		if ScrapSpawn:FindFirstChildOfClass("Model") and ScrapSpawn:FindFirstChildOfClass("Model"):FindFirstChild("Scrap")  then
			table.insert(Scraps, ScrapSpawn:FindFirstChildOfClass("Model")["Scrap"])
		end
	end

	return Scraps
end

-- [[ SUPPLY DROP FUNCTIONS ]] --

function viewSupplyDropItems(box)
	local MainViewer = Library:CreateSupplyDropUI()

	local ItemsFolder = box.Items_Folder

	for i, item in pairs(ItemsFolder:GetChildren()) do 
		MainViewer[i].Image = "rbxassetid://"..item.ImageID.Value

		if item.Taken.Value == true then
			MainViewer[i]:Destroy()
		end
	end
end

function bypassSupplyDropLock(box)
	for _,v in pairs(getconnections(box.GUIPart.ProximityPrompt.Triggered)) do 
		v:Disable()
	end

	local connection; connection = box.GUIPart.ProximityPrompt.Triggered:Connect(function(plr)
		if plr == Player and not box.DB_Folder:FindFirstChild(Player.Name) then
			local MainViewer = Library:CreateSupplyDropUI()

			local ItemsFolder = box.Items_Folder

			for i, item in pairs(ItemsFolder:GetChildren()) do 
				MainViewer[i].Image = "rbxassetid://"..item.ImageID.Value
				MainViewer[i].Modal = true

				if item.Taken.Value == true then 
					MainViewer[i].Visible = false
				else 
					local buttonConnection; buttonConnection = MainViewer[i].MouseButton1Click:Connect(function()
						ReplicatedStorage.SupplyClientEvent:FireServer("Collect", item.Name)
						buttonConnection:Disconnect()
						MainViewer:Destroy()
					end)
				end

			end

		end
	end)
end

-- [[ ESP ]] --

local colorTable = {
	["Scrap"] = Color3.fromRGB(255, 255, 255),
	["Rake"] = Color3.fromRGB(255, 0, 0),
	["Flare Gun"] = Color3.fromRGB(0, 170, 255),
	["Supply Crate"] = Color3.fromRGB(85, 170, 0),
	["Player"] = Color3.fromRGB(255, 128, 0),
	["Waypoint"] = Color3.fromRGB(255, 247, 0)
}

local MISCESP = {
	Player = "Player",
	Waypoint = "Waypoint"
}

local function insertObjectToProperTable(object, Text, isThisPlayer, isThisWaypoint)
	if Text == "Scrap" then 
		table.insert(Labels.ScrapLabels, object)
	elseif Text == "Rake" then
		table.insert(Labels.RakeLabels, object)
	elseif Text == "Flare Gun" then
		table.insert(Labels.FlareGunLabels, object)
	elseif Text == "Supply Crate" then
		table.insert(Labels.SupplyDropLabels, object)
	elseif isThisPlayer then
		table.insert(Labels.PlayersLabels, object)
	elseif isThisWaypoint then
		table.insert(Labels.WaypointLabels, object)
	end
end

local function ESP(object, Text, markObject, misc)
	local isThisLiveEntity = object.Parent:FindFirstChild("Humanoid")

	if isThisLiveEntity == nil then isThisLiveEntity = false else isThisLiveEntity = true end

	local colorToUse = nil
	local isThisPlayer = false
	local isThisWaypoint = false
	
	if colorTable[Text] then
		colorToUse = colorTable[Text]
	elseif misc == MISCESP.Player then
		colorToUse = colorTable[MISCESP.Player]
		isThisPlayer = true
	elseif misc == MISCESP.Waypoint then
		colorToUse = colorTable[MISCESP.Waypoint]
		isThisWaypoint = true
	end

	local BillboardGUI = Instance.new("BillboardGui")
	BillboardGUI.Parent = object
	BillboardGUI.Adornee = object
	BillboardGUI.AlwaysOnTop = true
	BillboardGUI.Size = UDim2.new(1, 1, 1)
	BillboardGUI.Name = "Isguied"
	BillboardGUI.Active = true
	BillboardGUI.Enabled = true
	BillboardGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	insertObjectToProperTable(BillboardGUI, Text, isThisPlayer, isThisWaypoint)

	local Label = Instance.new("TextLabel")
	Label.Parent = BillboardGUI
	Label.Size = UDim2.new(1, 1, 1)
	Label.TextColor3 = colorToUse
	Label.Active = true
	Label.Text = Text
	Label.ZIndex = 1
	Label.Visible = true
	Label.BackgroundTransparency = 1
	Label.TextStrokeTransparency = 1
	Label.Name = "Label"

	if isThisLiveEntity then
		BillboardGUI.ExtentsOffset = Vector3.new(0, 2.7, 0)
	end

	if markObject then
		if isThisLiveEntity then
			local allChildrens = object.Parent:GetDescendants()

			for _,part in pairs(allChildrens) do 
				if part:IsA("BasePart") then
					local Box = Instance.new("BoxHandleAdornment")
					Box.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
					Box.Name = "ESPPart"
					Box.Adornee = part
					Box.AlwaysOnTop = true
					Box.ZIndex = 5
					Box.Transparency = 0.5
					Box.Color3 = colorToUse
					Box.Parent = part

					insertObjectToProperTable(Box, Text, isThisPlayer, isThisWaypoint)
				end
			end
		else 
			local Box = Instance.new("BoxHandleAdornment")
			Box.Size = object.Size + Vector3.new(0.1, 0.1, 0.1)
			Box.Name = "ESPPart"
			Box.Adornee = object
			Box.AlwaysOnTop = true
			Box.ZIndex = 5
			Box.Transparency = 0.5
			Box.Color3 = colorToUse
			Box.Parent = object

			insertObjectToProperTable(Box, Text, isThisPlayer, isThisWaypoint)
		end
	end

end

------------------------------------------------------------------------

function indexAllScraps()
	for _,Scrap in pairs(getScraps()) do 
		if not Scrap:FindFirstChild("Isguied") then
			ESP(Scrap, "Scrap", true)
		end
	end
end

function addScrapLabel(Scrap)
	if not Scrap:FindFirstChild("Isguied") then
		ESP(Scrap, "Scrap", true)
	end
end

function setupScrapDetection()
	for _,ScrapSpawn in pairs(ScrapFolder:GetChildren()) do 
		ScrapSpawn.ChildAdded:Connect(function(object)
			if Toggles.scrapESP then 
				addScrapLabel(object:WaitForChild("Scrap"))
			end
		end)
	end

	print("Scrap detection has been loaded!")
end

function destroyScrapLabels()
	for _,scrapBill in pairs(Labels.ScrapLabels) do 
		scrapBill:Destroy()
	end
end

------------------------------------------------------------------------

function indexRake()
	local RakeInWorkspace = workspace:FindFirstChild("Rake")

	if RakeInWorkspace then
		if not RakeInWorkspace.HumanoidRootPart:FindFirstChild("Isguied") then 

			if Toggles.rakeESP then
				ESP(RakeInWorkspace.HumanoidRootPart, "Rake", true)
			end

			if RakeInWorkspace:FindFirstChild("AttackHitbox") then
				RakeInWorkspace.AttackHitbox.Size = Vector3.new(2048,2048,2048)
			end
		end
	end
end

function addRakeLabel(Rake)
	if Toggles.rakeESP then 
		if not Rake.HumanoidRootPart:FindFirstChild("Isguied") then 
			ESP(Rake.HumanoidRootPart, "Rake", true)

			if Rake:FindFirstChild("AttackHitbox") then
				Rake.AttackHitbox.Size = Vector3.new(2048,2048,2048)
			end
		end
	end

	Rake:WaitForChild("Head")
	if Toggles.showRakeInfo then 
		if not Labels.RakeInfoLabel  then 
			local BillboardGui = Instance.new("BillboardGui")
			local HPStatus = Instance.new("TextLabel")
			local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
			local Stunned = Instance.new("TextLabel")
			local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")

			BillboardGui.Parent = Rake.Head
			BillboardGui.Active = true
			BillboardGui.AlwaysOnTop = true
			BillboardGui.LightInfluence = 1.000
			BillboardGui.Size = UDim2.new(5, 0, 3, 0)
			BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)

			HPStatus.Name = "HPStatus"
			HPStatus.Parent = BillboardGui
			HPStatus.AnchorPoint = Vector2.new(0.5, 0.5)
			HPStatus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			HPStatus.BackgroundTransparency = 1.000
			HPStatus.Position = UDim2.new(0.5, 0, 0.200000003, 0)
			HPStatus.Size = UDim2.new(0.75757575, 0, 0.316455692, 0)
			HPStatus.Font = Enum.Font.SourceSans
			HPStatus.Text = "HP: 500"
			HPStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
			HPStatus.TextScaled = true
			HPStatus.TextSize = 14.000
			HPStatus.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
			HPStatus.TextWrapped = true

			UITextSizeConstraint.Parent = HPStatus

			Stunned.Name = "Stunned"
			Stunned.Parent = BillboardGui
			Stunned.AnchorPoint = Vector2.new(0.5, 0.5)
			Stunned.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Stunned.BackgroundTransparency = 1.000
			Stunned.Position = UDim2.new(0.5, 0, 0.5, 0)
			Stunned.Size = UDim2.new(0.75757575, 0, 0.316455692, 0)
			Stunned.Font = Enum.Font.SourceSans
			Stunned.Text = "Stunned: No"
			Stunned.TextColor3 = Color3.fromRGB(255, 255, 255)
			Stunned.TextScaled = true
			Stunned.TextSize = 14.000
			Stunned.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
			Stunned.TextWrapped = true

			UITextSizeConstraint_2.Parent = Stunned

			Labels.RakeInfoLabel = BillboardGui
		end
	end
end

function setupRakeDetection()
	workspace.ChildAdded:Connect(function(object)
		if object.Name == "Rake" then 
			object:WaitForChild("HumanoidRootPart")
			addRakeLabel(object)
		end
	end)

	print("Rake detection has been loaded!")
end

function destroyRakeLabel()
	if Labels.RakeLabels then 
		for _,obj in pairs(Labels.RakeLabels) do 
			obj:Destroy()
		end
		Labels.RakeLabel = {}
	end
end

------------------------------------------------------------------------

function indexAllPlayers()
	if Toggles.playerESP then
		local playerList = game.Players:GetPlayers()

		for _,player in pairs(playerList) do 
			if player.Name ~= Player.Name then 
				local char = player.Character

				if char and char:FindFirstChild("HumanoidRootPart") then 
					if not char.HumanoidRootPart:FindFirstChild("Isguied") then 
						ESP(char.HumanoidRootPart, player.Name, true, MISCESP.Player)
					end
				end
			end
		end	
	end
end

function addPlayerLabel(character)
	if character and character:FindFirstChild("HumanoidRootPart") then 
		if not character.HumanoidRootPart:FindFirstChild("Isguied") then 
			ESP(character.HumanoidRootPart, character.Name, true, MISCESP.Player)
		end
	end
end

function setupPlayerDetection()
	RunService.RenderStepped:Connect(function()
		indexAllPlayers()
	end)

	print("Player detection has been loaded!")
end

function destroyPlayerLabels()
	print("Called destroy players")

	for _,billgui in pairs(Labels.PlayersLabels) do 
		billgui:Destroy()
		print("destroyed in players")
	end
    Labels.PlayersLabels = {}
end

------------------------------------------------------------------------

function indexFlareGun()
	local FlareGunInWorkspace = workspace:FindFirstChild("FlareGunPickUp")

	if FlareGunInWorkspace then
		if not FlareGunInWorkspace:FindFirstChild("Isguied") then
			ESP(FlareGunInWorkspace, "Flare Gun", true)

			if Toggles.flaregunNotification then
				Library:CreateNotification("Flare Gun Spawned!", "You can now teleport to the flare gun!", 5)
			end
		end
	end
end

function addFlareGunLabel(flareGun)
	if not flareGun:FindFirstChild("Isguied") then
		ESP(flareGun, "Flare Gun", true)
	end
end

function setupFlareGunDetection()
	RunService.RenderStepped:Connect(function()
		indexFlareGun()
	end)

	print("Flare Gun Detection has been loaded!")
end

function destroyFlareGunLabel()
	if Labels.FlareGunLabels then 
		for _,obj in pairs(Labels.FlareGunLabels) do 
			obj:Destroy()
		end
		Labels.FlareGunLabels = {}
	end
end

------------------------------------------------------------------------

function createWaypoints()
	for mapPoint, point in pairs(MapPoints) do 
		local part = Instance.new("Part")
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false 
		part.Position = point
		part.Parent = workspace

		ESP(part, mapPoint, false, MISCESP.Waypoint)
	end
end

function destroyWaypoints()
	for _,bill in pairs(Labels.WaypointLabels) do 
		bill.Parent:Destroy()
	end

	Labels.WaypointLabels = {}
end

------------------------------------------------------------------------

function indexAllSupplyDrops()
	local SupplyCrates = workspace.Debris.SupplyCrates

	for _,box in pairs(SupplyCrates:GetChildren()) do 
		if box.Name == "Box" then 
			if not box.HitBox:FindFirstChild("Isguied") then 
				if Toggles.supplydropESP then 
					ESP(box.HitBox, "Supply Crate", true)
				end

				Library:CreateNotification("Supply crate spawned!", "You can now view items in the supply crate", 5)
			end

			if Toggles.bypassSupplyDropLock then
				bypassSupplyDropLock(box)
			end
		end
	end
end

function setupSupplyDropDetection()
	local SupplyCrates = workspace.Debris.SupplyCrates

	SupplyCrates.ChildAdded:Connect(function(object)
		if object.Name == "Box" then 
			if not object.HitBox:FindFirstChild("Isguied") then
				if Toggles.supplydropESP then 
					ESP(object.HitBox, "Supply Crate", true)
				end

				Library:CreateNotification("Supply crate spawned!", "You can now view items in the supply crate", 5)

				if Toggles.bypassSupplyDropLock then
					bypassSupplyDropLock(object)
				end
			end
		end
	end)

	print("Supply Drop Detection has been loaded!")
end

function destroySupplyDropLabels()
	for _,bill in pairs(Labels.SupplyDropLabels) do 
		bill:Destroy()
	end
end

-- [[ INFINITE STAMINA ]] --

function hookInfiniteStamina()
	for _,v in pairs(getloadedmodules()) do 
		if v.Name == "M_H" then
			local module = require(v)
			local old; old = hookfunction(module.TakeStamina, function(smth, amount)
				if amount > 0 then return old(smth, -0.5) end 
				return old(smth, amount)
			end)
		end
	end

	Library:CreateNotification("Notice", "To disable infinite stamina, you need to disable this and then reset your character!", 5)
end

-- [[ NO FALL DAMAGE ]] --

function hookNoFallDamage()
	local NoFallDamage; NoFallDamage = hookmetamethod(game, "__namecall", function(...)
		local Method = getnamecallmethod()
		local Args = {...}

		if Method == "FireServer" then 
			if tostring(...) == "FD_Event" then 
				return
			end
		end

		return NoFallDamage(...)
	end)
end

-- [[ STUN STICK MODIFIER ]] --

function modifyCurrentStunStick()
	local theTool = Player.Backpack:FindFirstChild("StunStick") or Player.Character:FindFirstChild("StunStick")

	if theTool == nil then return end

	if theTool:FindFirstChild("Modified") then return end

	task.wait(1)
	Player.Character.Humanoid:EquipTool(theTool)
	task.wait(1)

	for _,v in pairs(getconnections(theTool.Activated)) do 
		v:Disable()
	end

	theTool.Activated:Connect(function()
		local anim = Player.Character.Humanoid:LoadAnimation(theTool.SwingAnim)
		anim:Play()

		theTool.Event:FireServer("S")

		if workspace:FindFirstChild("Rake") then 
			if workspace.Rake:FindFirstChild("Torso") then 
				for i = 0, 20, 1 do 
					theTool.Event:FireServer("H", workspace.Rake.Torso)
				end
			end
		end
	end)

	local modifiedTag = Instance.new("BoolValue")
	modifiedTag.Name = "Modified"
	modifiedTag.Parent = theTool
end

-- [[ UV LAMP MODIFIER ]] --

function modifyCurrentUVLamp()
	local theTool = Player.Backpack:FindFirstChild("UV_Lamp") or Player.Character:FindFirstChild("UV_Lamp")

	if theTool == nil then return end

	if theTool:FindFirstChild("Modified") then return end

	task.wait(1)
	Player.Character.Humanoid:EquipTool(theTool)
	task.wait(1)

	for _,v in pairs(getconnections(theTool.Activated)) do 
		v:Disable()
	end

	theTool.Activated:Connect(function()
		theTool.Event:FireServer()
	end)

	local modifiedTag = Instance.new("BoolValue")
	modifiedTag.Name = "Modified"
	modifiedTag.Parent = theTool
end

-- [[ FLASHLIGHT MODIFIER ]] --

function modifyCurrentFlashlight()
	local theTool = Player.Backpack:FindFirstChild("Flashlight") or Player.Character:FindFirstChild("Flashlight")

	if theTool == nil then 
		theTool = Player.Backpack:FindFirstChild("UpgradedFlashlight") or Player.Character:FindFirstChild("UpgradedFlashlight")
	end

	if theTool == nil then return end

	if theTool:FindFirstChild("Modified") then return end

	theTool.Handle.Flashlight.Light.Light1.Brightness = 10 
	theTool.Handle.Flashlight.Light.Light1.Angle = 100

	local modifiedTag = Instance.new("BoolValue")
	modifiedTag.Name = "Modified"
	modifiedTag.Parent = theTool
end

-- [[ BACKPACK ADDED EVENT ]] --

local isBackpackSetup = false

function handleBackpackAdd(object)
	print("New Backpack object was added!")

	if object.Name == "StunStick" then 
		if Toggles.stunstickModifier then
			if not object:FindFirstChild("Modified") then 
				modifyCurrentStunStick()
			end
		end
	elseif object.Name == "UV_Lamp" then
		if Toggles.uvlampModifier then
			if not object:FindFirstChild("Modified") then 
				modifyCurrentUVLamp()
			end
		end
	elseif object.Name == "Flashlight" or object.Name == "UpgradedFlashlight" then 
		if Toggles.flashlightModifier then 
			if not object:FindFirstChild("Modified") then 
				modifyCurrentFlashlight()
			end
		end
	end
end

function setupBackpackAddedEvent()
	Player.Backpack.ChildAdded:Connect(function(object)
		if object:IsA("Tool") then 
			handleBackpackAdd(object)
		end
	end)

	print("Backpack Added Event has been loaded!")
end

-- [[ TIMER ]] --

local currentTimeUI = nil 

function createTheTimer()
	currentTimeUI = Library:CreateTimerUI()
end

function timerLoop()
	currentTimeUI.Visible = true

	local s = Timer.Value
	local formated = string.format("%02i:%02i", s/60%60, s%60)
	currentTimeUI.Text = formated
end

function disableTimer()
	currentTimeUI.Visible = false
end

function setupTimerLoop()
	Timer:GetPropertyChangedSignal("Value"):Connect(function()
		if Toggles.timer then 
			timerLoop()
		end
	end)
end

-- [[ COLLECT SCRAPS ]] -- 

local isScrapFarmOnDebaunce = false
local isSrapFarmRunning = false 

function collectScraps()
	if isSrapFarmRunning == false and isScrapFarmOnDebaunce == false then 
		isScrapFarmOnDebaunce = true 
		isSrapFarmRunning = true 

		if #getScraps() == 0 then
			Library:CreateNotification("No Scraps Found!", "There are currently no spawned scraps!", 5)
			isScrapFarmOnDebaunce = false
			isSrapFarmRunning = false 
			return
		end

		for _,scrap in pairs(getScraps()) do 
			if Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("Humanoid").SeatPart then
				Player.Character:FindFirstChild("Humanoid").Sit = false
			end

			if detectionCounter >= 3 then 
				Library:CreateNotification("Farming Stopped!", "We have stopped to prevent your death! You will have 1 minute cooldown!", 5)
				break
			end

			task.wait(0.1)
			Player.Character.HumanoidRootPart.CFrame = scrap.CFrame
			if not (scrap == nil) then
				if detectionCounter >= 3 then 
					Library:CreateNotification("Farming Stopped!", "We have stopped to prevent your death! You will have 1 minute cooldown!", 5)
					break
				end

				task.wait(0.5)
				Player.Character.HumanoidRootPart.CFrame = scrap.CFrame
			end
			task.wait(1)
		end

		if detectionCounter >= 3 then
			task.spawn(function()
				task.wait(60)
				isScrapFarmOnDebaunce = false
				detectionCounter = 0
			end)
		else 
			isScrapFarmOnDebaunce = false
		end

		isSrapFarmRunning = false 
	elseif isSrapFarmRunning == true then 
		Library:CreateNotification("The Farm is Running", "You are now collections scraps", 5)
	elseif isScrapFarmOnDebaunce == true then 
		Library:CreateNotification("Debaunce!", "You are on cooldown!", 5)
	end
end

-- [[ COLLECT FLARE GUN ]] -- 

function collectFlareGun()
	local theFlareGun = workspace:FindFirstChild("FlareGunPickUp")

	if theFlareGun then
		local theModel = theFlareGun.FlareGun 

		Player.Character.HumanoidRootPart.CFrame = theModel.CFrame

		Library:CreateNotification("Collected!", "If you don't have the flare gun just click on it again!", 5)
	else 
		Library:CreateNotification("No Flare Gun Spawned!", "Hmmm, sherlock there is not flare gun", 5)
	end
end

-- [[ RAKE INFO ]] -- 

function addToRakeInfo(rake)
	local BillboardGui = Instance.new("BillboardGui")
	local HPStatus = Instance.new("TextLabel")
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	local Stunned = Instance.new("TextLabel")
	local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")

	BillboardGui.Parent = rake.Head
	BillboardGui.Active = true
	BillboardGui.AlwaysOnTop = true
	BillboardGui.LightInfluence = 1.000
	BillboardGui.Size = UDim2.new(5, 0, 3, 0)
	BillboardGui.StudsOffsetWorldSpace = Vector3.new(0, 2, 0)

	HPStatus.Name = "HPStatus"
	HPStatus.Parent = BillboardGui
	HPStatus.AnchorPoint = Vector2.new(0.5, 0.5)
	HPStatus.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HPStatus.BackgroundTransparency = 1.000
	HPStatus.Position = UDim2.new(0.5, 0, 0.200000003, 0)
	HPStatus.Size = UDim2.new(0.75757575, 0, 0.316455692, 0)
	HPStatus.Font = Enum.Font.SourceSans
	HPStatus.Text = "HP: 500"
	HPStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
	HPStatus.TextScaled = true
	HPStatus.TextSize = 14.000
	HPStatus.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
	HPStatus.TextWrapped = true

	UITextSizeConstraint.Parent = HPStatus

	Stunned.Name = "Stunned"
	Stunned.Parent = BillboardGui
	Stunned.AnchorPoint = Vector2.new(0.5, 0.5)
	Stunned.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Stunned.BackgroundTransparency = 1.000
	Stunned.Position = UDim2.new(0.5, 0, 0.5, 0)
	Stunned.Size = UDim2.new(0.75757575, 0, 0.316455692, 0)
	Stunned.Font = Enum.Font.SourceSans
	Stunned.Text = "Stunned: No"
	Stunned.TextColor3 = Color3.fromRGB(255, 255, 255)
	Stunned.TextScaled = true
	Stunned.TextSize = 14.000
	Stunned.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
	Stunned.TextWrapped = true

	UITextSizeConstraint_2.Parent = Stunned

	Labels.RakeInfoLabel = BillboardGui
end

function updateRakeInfo()
	if Labels.RakeInfoLabel then 
		local RakeInWorkspace = workspace:FindFirstChild("Rake")

		if RakeInWorkspace and RakeInWorkspace:FindFirstChild("Monster") then 
			Labels.RakeInfoLabel.HPStatus.Text = "HP: "..RakeInWorkspace.Monster.Health
			if RakeInWorkspace.Monster.WalkSpeed <= 0 then
				Labels.RakeInfoLabel.Stunned.Text = "Stunned: Yes"
			else 
				Labels.RakeInfoLabel.Stunned.Text = "Stunned: No"
			end
		end
	else 
		local RakeInWorkspace = workspace:FindFirstChild("Rake")

		if RakeInWorkspace then 
			RakeInWorkspace:WaitForChild("Head")

			if #Labels.RakeLabels <= 0 then
				if Toggles.rakeESP then
					ESP(RakeInWorkspace.HumanoidRootPart, "Rake", true)	
				end
			end

			if not Labels.RakeInfoLabel then 
				addToRakeInfo(RakeInWorkspace)
			end
		end
	end
end

function destroyRakeInfo()
	Labels.RakeInfoLabel:Destroy()
end

function setupRakeInfoLoop()
	RunService.RenderStepped:Connect(function()
		if Toggles.showRakeInfo then 
			indexRake()
			updateRakeInfo()
		end
	end)
end

-- [[ VIEW CAMERAS ]] -- 

local CamerasFolder = workspace:WaitForChild("Map"):WaitForChild("Cameras")
CamerasFolder = CamerasFolder:GetChildren()

local currentIndex = 1
local selectedCamera = CamerasFolder[1]

function handleCameraInput(input)
	if input.KeyCode == Enum.KeyCode.Q then 
		if (currentIndex-1) > 0 then 
			selectedCamera = CamerasFolder[currentIndex-1]
			currentIndex =- 1
		else
			currentIndex = #CamerasFolder
			selectedCamera = CamerasFolder[currentIndex]
		end
	elseif input.KeyCode == Enum.KeyCode.E then 
		if (currentIndex+1) <= #CamerasFolder then 
			selectedCamera = CamerasFolder[currentIndex+1]
			currentIndex = currentIndex + 1
		else 
			currentIndex = 1 
			selectedCamera = CamerasFolder[currentIndex]
		end
	end
end

function updateCameraCFrame()
	if selectedCamera ~= nil then
		workspace.CurrentCamera.CFrame = selectedCamera.DefaultPosition.CFrame + (selectedCamera.DefaultPosition.CFrame.LookVector * 1.5)
	end
end

function setupViewCameraLoop()
	UserInputService.InputBegan:Connect(function(input, isChat)
		if isChat then return end 

		if Toggles.viewCameras then 
			handleCameraInput(input)
		end
	end)

	RunService.RenderStepped:Connect(function()
		if Toggles.viewCameras then 
			updateCameraCFrame()
		end
	end)
end

-- [[ POWER LEVEL ]] --

local PowerLevelUI = nil 

function createPowerLevel()
	PowerLevelUI = Library:CreatePowerLevelUI()
end

function updatePowerLevel()
	PowerLevelUI.Visible = true 

	PowerLevelUI.Text = "Power Level: "..ReplicatedStorage.PowerValues.PowerLevel.Value
end

function destroyPowerLevel()
	PowerLevelUI.Visible = false
end

function setupPowerLevelLoop()
	RunService.RenderStepped:Connect(function()
		if Toggles.powerLevel then 
			updatePowerLevel()
		end
	end)
end

-- [[ WALKSPEED CHEAT ]] --

function updateWalkSpeed()
	if Toggles.sprint then 
		Player.Character.Humanoid.WalkSpeed = 30
	end
end

function setupWalkSpeedLoop()
	RunService.RenderStepped:Connect(function()
		updateWalkSpeed()
	end)
end

-- [[ STUN STICK AURA ]] --

local isStunStickAuraOnDebaunce = false

function auraLoop()
	local Rake = workspace:FindFirstChild("Rake")    

	if Rake then
		if Rake:FindFirstChild("HumanoidRootPart") then
			local theTool = Player.Character:FindFirstChild("StunStick")    

			if theTool then
				if (Player.Character.HumanoidRootPart.Position - Rake.HumanoidRootPart.Position).Magnitude <= 12 then
					if isStunStickAuraOnDebaunce == false then
						theTool.Event:FireServer("S")
						theTool.Event:FireServer("H", workspace.Rake.Torso)
						isStunStickAuraOnDebaunce = true 
						task.wait(0.5)
						isStunStickAuraOnDebaunce = false
					end
				end

			end
		end
	end
end

function setupAuraLoop()
	RunService.RenderStepped:Connect(function()
		if Toggles.stunstickAura then 
			auraLoop()
		end
	end)
end

-- [[ SAFEHOUSE DOOR ]] --

function modifySafehouseDoor()
	for _,v in pairs(getconnections(game:GetService("Workspace").Map.SafeHouse.Door.Door.DoorGUIPart.ProximityPrompt.Triggered)) do 
		v:Disable()
	end

	game:GetService("Workspace").Map.SafeHouse.Door.Door.DoorGUIPart.ProximityPrompt.Triggered:Connect(function(plr)
		if plr == game.Players.LocalPlayer then 
			workspace.Map.SafeHouse.Door.RemoteEvent:FireServer("Door")
		end
	end)
end

-- [[ ALWAYS DAY ]] --

function updateVisualsToAlwaysDay()
	for _,v in pairs(ReplicatedStorage.DayProperties:GetChildren()) do 
		game.Lighting[v.Name] = v.Value
		if CurrentLightingProperties:FindFirstChild(v.Name) then 
			CurrentLightingProperties[v.Name].Value = v.Value
		end
	end
end

function setupAlwaysDayLoop()
	RunService.RenderStepped:Connect(function()
		if Toggles.alwaysDay then 
			updateVisualsToAlwaysDay()
		end
	end)
end

-- [[ ALWAYS NIGHT ]] --

function updateVisualsToAlwaysNight()
	for _,v in pairs(ReplicatedStorage.NightProperties:GetChildren()) do 
		game.Lighting[v.Name] = v.Value
		if CurrentLightingProperties:FindFirstChild(v.Name) then 
			CurrentLightingProperties[v.Name].Value = v.Value
		end
	end
end

function setupAlwaysNightLoop()
	RunService.RenderStepped:Connect(function()
		if Toggles.alwaysNight then 
			updateVisualsToAlwaysNight()
		end
	end)
end

-- [[ NO FOG ]] --

function handleNoFogLoop()
	if Toggles.nofog then 
		game.Lighting.FogEnd = 999999
		CurrentLightingProperties.FogEnd.Value = 999999
	end
end

function setupNoFogLoop()
	RunService.RenderStepped:Connect(handleNoFogLoop)
end

-- [[ FULLBRIGHT ]] --

function updateVisualsToFullbright()
	game.Lighting.Brightness = 2
	CurrentLightingProperties.Brightness.Value = 2
end

function disableFullbright()
	game.Lighting.Brightness = 0.45
	CurrentLightingProperties.Brightness.Value = 0.45
end

function handleFullbrightLoop()
	if Toggles.fullbright then 
		updateVisualsToFullbright()
	else 
		disableFullbright()
	end
end

function setupFullbrightLoop()
	RunService.RenderStepped:Connect(handleFullbrightLoop)
end

-- [[ UNLOCK THIRD PERSON ]] --

function unlockThirdPersonLoop()
	if Toggles.unlockThirdPerson then 
		Player.CameraMaxZoomDistance = 1000
	end
end

function setupThirdPersonLoop()
	RunService.RenderStepped:Connect(unlockThirdPersonLoop)

	local cameraHook; cameraHook = hookmetamethod(game, "__newindex", function(Self, Key, NewValue)
		if not checkcaller() and Self == Player and Key == "CameraMaxZoomDistance" then 
			return cameraHook(Self, Key, 1000)    
		end

		return cameraHook(Self, Key, NewValue)
	end)
end

-- [[ DISABLE MAP BORDERS ]] --

function destroyMapBorders()
	for _, border in pairs(workspace.Filter.InvisibleWalls:GetChildren()) do 
		border:Destroy()
	end

	Library:CreateNotification("Done!", "All borders around the map were disabled. (Server borders are not possible to remove)", 5)
end

-- [[ NO JUMP DELAY ]] --

function enableNoJumpDelay()
	UserInputService.JumpRequest:Connect(function()
		if Player.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
			Player.Character.Humanoid:ChangeState("Jumping")
		end
	end)
end

-- [[ HANDLE DEATH ]] --

function handleDeath()
	Player.CharacterAdded:Wait()
	Player.Character:WaitForChild("HumanoidRootPart")

	if Toggles.infiniteStamina then 
		hookInfiniteStamina()
	end

	if Toggles.stunstickModifier then 
		modifyCurrentStunStick()
	end

	if Toggles.uvlampModifier then 
		modifyCurrentUVLamp()
	end

	if Toggles.flashlightModifier then 
		modifyCurrentFlashlight()
	end
end

function setupDeathDetection()
	Player.Character.Humanoid.Died:Connect(function()
		handleDeath()
		setupDeathDetection()
	end)
end

------- [[ TOGGLES SAVING/LOADING ]] -------

function updateSettings()
	writefile("RakeEvolvedV2/settings.json", game.HttpService:JSONEncode(Toggles))
end

local loadData = nil
if isfolder("RakeEvolvedV2") then 
	if isfile("RakeEvolvedV2/settings.json") then
		loadData = readfile("RakeEvolvedV2/settings.json")
		loadData = game.HttpService:JSONDecode(loadData)
	end 
else 
	makefolder("RakeEvolvedV2")
	local defaultData = Toggles
	defaultData = game.HttpService:JSONEncode(defaultData)
	writefile("RakeEvolvedV2/settings.json", defaultData)
	loadData = defaultData
end

------- [[ UI ]] -------

local ESPTab = Library:NewTab("ESP", "ESP")
local VisualsTab = Library:NewTab("Visuals", "Visuals")
local ClientTab = Library:NewTab("Client", "Client")
local SupplyDropTab = Library:NewTab("Supply Drops", "Supply_Drops")
local ToolsTab = Library:NewTab("Tools", "Tools")
local TPTab = Library:NewTab("TP", "TP")
local SettingsTab = Library:NewTab("Settings", "Settings")

local isRakeESPSetup = false
ESPTab:NewToggle("Rake ESP", "Rake_ESP", loadData.rakeESP, function(newValue)
	Toggles.rakeESP = newValue

	if newValue == true then 
		indexRake()
		if isRakeESPSetup == false then
			setupRakeDetection()
			isRakeESPSetup = true 
		end
	else 
		destroyRakeLabel()
	end

	updateSettings()
end)

local isScrapESPSetup = false
ESPTab:NewToggle("Scrap ESP", "Scrap_ESP", loadData.scrapESP, function(newValue)
	Toggles.scrapESP = newValue

	if newValue == true then
		indexAllScraps()
		if isScrapESPSetup == false then 
			setupScrapDetection()
			isScrapESPSetup = true
		end
	else 
		destroyScrapLabels()
	end

	updateSettings()
end)

local isSupplyDropESPSetup = false 
ESPTab:NewToggle("Supply Drop ESP", "Supply_Drop_ESP", loadData.supplydropESP, function(newValue)
	Toggles.supplydropESP = newValue

	if newValue == true then 
		indexAllSupplyDrops()
		if isSupplyDropESPSetup == false then 
			setupSupplyDropDetection()
			isSupplyDropESPSetup = true
		end
	else 
		destroySupplyDropLabels()
	end

	updateSettings()
end)

local isPlayersESPSetup = false 
ESPTab:NewToggle("Players ESP", "Players_ESP", loadData.playerESP, function(newValue)
	Toggles.playerESP = newValue

	if newValue == true then 
		indexAllPlayers()
		if isPlayersESPSetup == false then 
			setupPlayerDetection()
			isPlayersESPSetup = true 
		end
	else 
		destroyPlayerLabels()
	end

	updateSettings()
end)

local isFlareGunESPSetup = false 
ESPTab:NewToggle("Flare Gun ESP", "Flare_Gun_ESP", loadData.flaregunESP, function(newValue)
	Toggles.flaregunESP = newValue

	if newValue == true then 
		indexFlareGun()
		if isFlareGunESPSetup == false then 
			setupFlareGunDetection()
			isFlareGunESPSetup = true 
		end
	else 
		destroyFlareGunLabel()
	end

	updateSettings()
end)

ESPTab:NewToggle("Flare Gun Notifications", "Flare_Gun_Notifications", loadData.flaregunNotification, function(newValue)
	Toggles.flaregunNotification = newValue

	if newValue == true then 
		if isFlareGunESPSetup == false then 
			setupFlareGunDetection()
			isFlareGunESPSetup = true
		end
	end

	updateSettings()
end)

local isFullbrightSetup = false
VisualsTab:NewToggle("Fullbright", "Fullbright", loadData.fullbright, function(newValue)
	Toggles.fullbright = newValue

	if newValue == true then
		if isFullbrightSetup == false then 
			setupFullbrightLoop()
			isFullbrightSetup = true
		end
	end

	updateSettings()
end)

local isNoFogSetup = false
VisualsTab:NewToggle("No Fog", "No_Fog", loadData.nofog, function(newValue)
	Toggles.nofog = newValue

	if newValue == true then
		if isNoFogSetup == false then 
			setupNoFogLoop()
			isNoFogSetup = true
		end
	end

	updateSettings()
end)

local isAlwaysDaySetup = false 
VisualsTab:NewToggle("Always Day", "Always_Day", loadData.alwaysDay, function(newValue)
	Toggles.alwaysDay = newValue

	if newValue == true then 
		if isAlwaysDaySetup == false then
			setupAlwaysDayLoop()
			isAlwaysDaySetup = true
		end
	end

	updateSettings()
end)

local isAlwaysNightSetup = false
VisualsTab:NewToggle("Always Night", "Always_Night", loadData.alwaysNight, function(newValue)
	Toggles.alwaysNight = newValue

	if newValue == true then
		if isAlwaysNightSetup == false then 
			setupAlwaysNightLoop()
			isAlwaysNightSetup = true 
		end
	end

	updateSettings()
end)

VisualsTab:NewToggle("Waypoints", "Waypoints", loadData.waypoints, function(newValue)
	Toggles.waypoints = newValue

	if newValue == true then 
		createWaypoints()
	else 
		destroyWaypoints()
	end

	updateSettings()
end)

local isRakeInfoSetup = false
VisualsTab:NewToggle("Show Rake Info", "Show_Rake_Info", loadData.showRakeInfo, function(newValue)
	Toggles.showRakeInfo = newValue

	if newValue == true then 
		local rake = workspace:FindFirstChild("Rake")

		if rake then 
			addToRakeInfo(rake)
		end

		if isRakeESPSetup == false then 
			setupRakeDetection()
			isRakeESPSetup = true
		end

		if isRakeInfoSetup == false then 
			setupRakeInfoLoop()
			isRakeInfoSetup = true
		end
	else 
		destroyRakeInfo()
	end

	updateSettings()
end)

local isThirdPersonSetup = false
VisualsTab:NewToggle("Unlock Third Person", "Unlock_Third_Person", loadData.unlockThirdPerson, function(newValue)
	Toggles.unlockThirdPerson = newValue

	if newValue == true then 
		if isThirdPersonSetup == false then 
			setupThirdPersonLoop()
			isThirdPersonSetup = true
		end
	end

	updateSettings()
end)

ClientTab:NewToggle("Infinite Stamina", "Infinite_Stamina", loadData.infiniteStamina, function(newValue)
	Toggles.infiniteStamina = newValue    

	if newValue == true then 
		hookInfiniteStamina()
	end

	updateSettings()
end)

ClientTab:NewToggle("No Fall Damage", "No_Fall_Damage", loadData.noFallDamage, function(newValue)
	Toggles.noFallDamage = newValue

	if newValue == true then 
		hookNoFallDamage()
	end

	updateSettings()
end)

local isViewCamerasSetup = false
ClientTab:NewToggle("View Cameras", "View_Cameras", loadData.viewCameras, function(newValue)
	Toggles.viewCameras = newValue

	if newValue == true then 
		Library:CreateNotification("Notice!", "Use Q and E to switch between cameras!", 5)

		if isViewCamerasSetup == false then 
			setupViewCameraLoop()
			isViewCamerasSetup = true
		end
	end

	updateSettings()
end)

local isTimerSetup = false
ClientTab:NewToggle("Timer", "Timer", loadData.timer, function(newValue)
	Toggles.timer = newValue

	if newValue == true then 
		if currentTimeUI == nil then 
			createTheTimer()
			currentTimeUI.Visible = true
		end

		if isTimerSetup == false then 
			setupTimerLoop()
			isTimerSetup = true
		end
	else 
		currentTimeUI:Destroy()
		currentTimeUI = nil
	end

	updateSettings()
end)

local isPowerLevelSetup = false
ClientTab:NewToggle("Power Level", "Power_Level", loadData.powerLevel, function(newValue)
	Toggles.powerLevel = newValue

	if newValue == true then 
		--if PowerLevelUI == nil then 
		createPowerLevel()
		PowerLevelUI.Visible = true
		--end

		if isPowerLevelSetup == false then 
			setupPowerLevelLoop()
			isPowerLevelSetup = true
		end
	else 
		destroyPowerLevel()
	end

	updateSettings()
end)

ClientTab:NewButton("Disable Map Borders", "Disable_Map_Borders", destroyMapBorders)

local isSprintSetup = false
ClientTab:NewKeybind("Sprint without Stamina", "Sprint_without_Stamina", Enum.KeyCode.Q, function()
	Toggles.sprint = not Toggles.sprint

	if isSprintSetup == false then 
		setupWalkSpeedLoop()
		isSprintSetup = true
	end
end)

SupplyDropTab:NewToggle("Bypass Supply Drop Lock", "Bypass_Supply_Drop_Lock", loadData.bypassSupplyDropLock, function(newValue)
	Toggles.bypassSupplyDropLock = newValue

	if newValue == true then 
		indexAllSupplyDrops()
	end

	updateSettings()
end)

SupplyDropTab:NewButton("View Supply Drop Items", "View_Supply_Drop_Items", function()
	local SupplyCratesFolder = workspace.Debris.SupplyCrates

	if SupplyCratesFolder:FindFirstChild("Box") then 
		local selected

		if #SupplyCratesFolder:GetChildren() >= 2 then 
			for _,box in pairs(SupplyCratesFolder:GetChildren()) do 
				if box:FindFirstChild("UnlockValue") then 
					if box.UnlockValue.Value <= 0 or not box.DB_Folder:FindFirstChild(Player.Name) then 
						selected = box 
						break
					end
				end
			end
		else 
			selected = SupplyCratesFolder["Box"]
		end

		viewSupplyDropItems(selected)
	else 
		Library:CreateNotification("No supply crate!", "There is currently no supply crate spawned!", 5)
	end

	updateSettings()
end)

ToolsTab:NewToggle("Stun Stick Modifier", "Stun_Stick_Modifer", loadData.stunstickModifier, function(newValue)
	Toggles.stunstickModifier = newValue

	if newValue == true then 
		modifyCurrentStunStick()

		if isBackpackSetup == false then 
			setupBackpackAddedEvent()
			isBackpackSetup = true
		end
	end

	updateSettings()
end)

ToolsTab:NewToggle("UV Lamp Modifier", "UV_Lamp_Modifier", loadData.uvlampModifier, function(newValue)
	Toggles.uvlampModifier = newValue

	if newValue == true then 
		modifyCurrentUVLamp()

		if isBackpackSetup == false then 
			setupBackpackAddedEvent()
			isBackpackSetup = true
		end
	end

	updateSettings()
end)

local isStunStickSetup = false
ToolsTab:NewToggle("Stun Stick Aura", "Stun_Stick_Aura", loadData.stunstickAura, function(newValue)
	Toggles.stunstickAura = newValue

	if newValue == true then 
		if isStunStickSetup == false then 
			setupAuraLoop()
			isStunStickSetup = true
		end
	end

	updateSettings()
end)

ToolsTab:NewToggle("Flashlight Modifier", "Flashlight_Modifier", loadData.flashlightModifier, function(newValue)
	Toggles.flashlightModifier = newValue

	if newValue == true then 
		modifyCurrentFlashlight()

		if isBackpackSetup == false then 
			setupBackpackAddedEvent()
			isBackpackSetup = true
		end
	end

	updateSettings()
end)

TPTab:NewButton("Collect Scraps", "Collect_Scraps", collectScraps)
TPTab:NewButton("Collect Flare Gun", "Collect_Flare_Gun", collectFlareGun)

SettingsTab:NewKeybind("Toggle UI", "Toggle_UI", Enum.KeyCode.RightControl, function()
	Library:ToggleUI()
end)

_G.RakeEvolvedShutDownFunction = function()
	destroyFlareGunLabel()
	destroyRakeInfo()
	destroyRakeLabel()
	destroyPowerLevel()
	destroyScrapLabels()
	destroyWaypoints()
	destroySupplyDropLabels()
	game.CoreGui.NewUI:Destroy()
	script:Destroy()
end

game.Lighting.BloodHourColor:Destroy()
modifySafehouseDoor()
setupDeathDetection()
enableNoJumpDelay()

Library:ViewTab("ESP")
Library:CreateNotification("Script Loaded!", "Thanks for using Rake Evolved V2", 5)
