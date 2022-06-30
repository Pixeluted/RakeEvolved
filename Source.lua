local Player = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ScrapFolder = workspace:WaitForChild("Filter"):WaitForChild("ScrapSpawns")
local Timer = ReplicatedStorage:WaitForChild("Timer")
local CurrentLightingProperties = ReplicatedStorage:WaitForChild("CurrentLightingProperties")

local ScrapLabels = {}
local RakeLabel = nil
local FlareGunLabel = nil
local SupplyDropLabels = {}
local PlayersLabels = {}

local independentStamina = false

local damageRunOnce = false
local hookedStamina = false
local bypassOnceEnabled = false

local StunStickModified = false
local UVModified = false

local TopBar, TabContent, Tabs, Template, Notifications, PowerLevel, Main = loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/hi/main/Ilikedogs.lua'))()

local DragMousePosition
local FramePosition

local Dragabble

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then 
		Dragabble = true
		DragMousePosition = Vector2.new(input.Position.X, input.Position.Y)
		FramePosition = Vector2.new(Main.Position.X.Scale, Main.Position.Y.Scale)
	end
end)

TopBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragabble = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if Dragabble then
		local NewPosition = FramePosition + ((Vector2.new(input.Position.X, input.Position.Y)  - DragMousePosition) / workspace.Camera.ViewportSize)
		Main.Position = UDim2.new(NewPosition.X, 0, NewPosition.Y, 0)
	end
end)

--// GUI Functions

local function createNotification(Title, Description, timeDelay)
	local newNotification = Template:Clone()

	newNotification.Title.Text = Title
	newNotification.Description.Text = Description
	newNotification.Parent = Notifications
	newNotification.Visible = true

	task.spawn(function()
		task.wait(timeDelay)
		newNotification:Destroy()
	end)
end

--// Tab handling

local CurrentOpenTab = "ESPTab"
TabContent[CurrentOpenTab].Visible = true

for _,v in pairs(Tabs:GetChildren()) do 
	if v:IsA("Frame") then
		v.DetectButton.MouseButton1Click:Connect(function()
			TabContent[CurrentOpenTab].Visible = false
			Tabs[CurrentOpenTab].BackgroundTransparency = 1

			CurrentOpenTab = v.Name

			v.BackgroundTransparency = 0
			TabContent[CurrentOpenTab].Visible = true
		end)
	end
end

--// Interactive shit handling

local callbacks = {}
local toggles = {}
local keybinds = {}

function handleButtonClick(input, v)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if callbacks[v.TextLabel.Text] then
			callbacks[v.TextLabel.Text]()
		else
			print("no callback defined")
		end
	end
end

function handleToggleClick(v)
	if toggles[v.TextLabel.Text] then
		toggles[v.TextLabel.Text] = not toggles[v.TextLabel.Text]
	else
		toggles[v.TextLabel.Text] = true
	end


	if toggles[v.TextLabel.Text] == true then
		v.ToggleBackground.TheToggle:TweenPosition(UDim2.new(0.747, 0, 0.543, 0), nil, nil, 0.1)
	else
		v.ToggleBackground.TheToggle:TweenPosition(UDim2.new(0.247, 0, 0.5, 0), nil, nil, 0.1)
	end
end

function handleKeyBind(v)
	v.KeybindText.Text = "..."

	local connection
	connection = UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode ~= nil then
			v.KeybindText.Text = input.KeyCode.Name
			keybinds[v.TextLabel.Text] = input.KeyCode
			connection:Disconnect()
		end
	end)

end

for _,Thetab in pairs(TabContent:GetChildren()) do
	if Thetab:IsA("ScrollingFrame") then

		for _,v in pairs(Thetab:GetChildren()) do 
			if v:IsA("Frame") then
				if v.Name == "Button" then

					v.InputBegan:Connect(function(input)
						handleButtonClick(input, v)
					end)

				elseif v.Name == "Toggle" then

					v.ToggleBackground.MouseButton1Click:Connect(function()
						handleToggleClick(v)
					end)

				elseif v.Name == "Keybind" then

					keybinds[v.TextLabel.Text] = v.KeybindText.Text

					v.KeybindText.MouseButton1Click:Connect(function()
						handleKeyBind(v)
					end)

				end
			end
		end

	end
end

--// ESP Functions

local function newLabel(Part, Text, isPlayer)
	local billgui = Instance.new("BillboardGui")
	billgui.Parent = Part
	billgui.Adornee = Part
	billgui.AlwaysOnTop = true
	billgui.Size = UDim2.new(1, 1, 1)
	billgui.Name = "Isguied"
	billgui.Active = true
	billgui.Enabled = true
	billgui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local label = Instance.new("TextLabel")
	label.Parent = billgui
	label.Size = UDim2.new(1, 1, 1)
	label.TextColor3 = Color3.new(23,45,67)
	label.Active = true
	label.Text = Text
	label.ZIndex = 1
	label.Visible = true
	label.BackgroundTransparency = 1
	label.TextStrokeTransparency = 1
	label.Name = "Label"

	if Text == "Scrap" then
		table.insert(ScrapLabels, billgui)
	elseif Text == "Rake" then
		label.TextColor3 = Color3.fromRGB(255, 0, 0)
		RakeLabel = billgui
	elseif Text == "Flare Gun" then
		label.TextColor3 = Color3.fromRGB(0, 170, 255)
		FlareGunLabel = billgui
	elseif Text == "Supply Crate" then
		label.TextColor3 = Color3.fromRGB(85, 170, 0)
		table.insert(SupplyDropLabels, billgui)
	elseif isPlayer == true then
		table.insert(PlayersLabels, billgui)
	end
end

local function getScraps()
	local Scraps = {}

	for _,ScrapSpawn in pairs(ScrapFolder:GetChildren()) do 
		if ScrapSpawn:FindFirstChildOfClass("Model") and ScrapSpawn:FindFirstChildOfClass("Model"):FindFirstChild("Scrap")  then
			table.insert(Scraps, ScrapSpawn:FindFirstChildOfClass("Model")["Scrap"])
		end
	end

	return Scraps
end

local function ESPScrap()
	local Scraps = getScraps()

	for _,Scrap in pairs(Scraps) do 
		if Scrap:FindFirstChild("Isguied") == nil then
			newLabel(Scrap, "Scrap")
		end
	end
end

--// Timer UI

local TimeInfo = Instance.new("TextLabel")

TimeInfo.Name = "TimeInfo"
TimeInfo.Parent = Main.Parent
TimeInfo.AnchorPoint = Vector2.new(0.5, 0.5)
TimeInfo.BackgroundTransparency = 1
TimeInfo.BorderSizePixel = 0
TimeInfo.Position = UDim2.new(0.5, 0, 0.0350000001, 0)
TimeInfo.Size = UDim2.new(0.103, 0, 0.0719999969, 0)
TimeInfo.Font = Enum.Font.SourceSansBold
TimeInfo.Text = "3:25"
TimeInfo.TextColor3 = Color3.fromRGB(243, 243, 243)
TimeInfo.TextSize = 100.000
TimeInfo.TextWrapped = true
TimeInfo.Visible = false

local function toMS(s)
	return string.format("%02i:%02i", s/60%60, s%60)
end

--// Camera Viewer

local CamerasFolder = workspace:WaitForChild("Map"):WaitForChild("Cameras")
CamerasFolder = CamerasFolder:GetChildren()

local selectedCamera = CamerasFolder[1]
local currentIndex = 1

--// Supply Drop Functions

function viewSupplyDropItems(Box)
	local MainViewer = loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/hi/main/viewer.lua'))()

	local ItemsFolder = Box.Items_Folder

	for i, item in pairs(ItemsFolder:GetChildren()) do 
		MainViewer[i].Image = "rbxassetid://"..item.ImageID.Value

		if item.Taken.Value == true then
			MainViewer[i]:Destroy()
		end
	end

	MainViewer.Parent = Main.Parent
	MainViewer.Visible = true 

	local connection; connection = MainViewer.exit.MouseButton1Click:Connect(function()
		MainViewer:Destroy()
		connection:Disconnect()
	end)
end

function bypassSupplyDropLock(Box)
	for _,v in pairs(getconnections(Box.GUIPart.ProximityPrompt.Triggered)) do 
		v:Disable()
	end

	local connection
	connection = Box.GUIPart.ProximityPrompt.Triggered:Connect(function(plr)
		if plr == Player and not Box.DB_Folder:FindFirstChild(Player.Name) then
			local MainViewer = loadstring(game:HttpGet('https://raw.githubusercontent.com/Pixeluted/hi/main/viewer.lua'))()

			local ItemsFolder = Box.Items_Folder

			for i, item in pairs(ItemsFolder:GetChildren()) do 
				MainViewer[i].Image = "rbxassetid://"..item.ImageID.Value
				MainViewer[i].Modal = true

				if item.Taken.Value == true then 
					MainViewer[i].Visible = false
				else 
					local oke 
					oke = MainViewer[i].MouseButton1Click:Connect(function()
						ReplicatedStorage.SupplyClientEvent:FireServer("Collect", item.Name)
						oke:Disconnect()
						MainViewer:Destroy()
					end)
				end

			end

			MainViewer.Parent = Main.Parent
			MainViewer.Visible = true 

			local connection; connection = MainViewer.exit.MouseButton1Click:Connect(function()
				MainViewer:Destroy()
				connection:Disconnect()
			end)
		end
	end)
end
--// View Supply Drop 

callbacks["View Supply Drop Items"] = function()
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
		createNotification("No supply crate!", "There is currently no supply crate spawned!", 5)
	end
end

--// Modifiying


function modifyStunStick(theTool)
	for _,v in pairs(getconnections(theTool.Activated)) do 
		v:Disable()
	end

	theTool.Activated:Connect(function()
		local anim = Player.Character.Humanoid:LoadAnimation(theTool.SwingAnim)
		anim:Play()

		theTool.Event:FireServer("S")

		if workspace.Rake then 
			if workspace.Rake.Torso then 
				theTool.Event:FireServer("H", workspace.Rake.Torso)
			end
		end
	end)

	StunStickModified = true 
end

function modifyUV_Lamp(theTool)
	for _,v in pairs(getconnections(theTool.Activated)) do 
		v:Disable()
	end

	theTool.Activated:Connect(function()
		theTool.Event:FireServer()
	end)

	UVModified = true
end

function handleBackpackAdd(object)
	if object.Name == "StunStick" then 
		if toggles["Stun Stick Modifier"] == true then
			modifyStunStick(object)	
		end
	elseif object.Name == "UV_Lamp" then
		if toggles["UV Lamp Modifier"] == true then
			modifyUV_Lamp(object)
		end
	end
end

Player.Backpack.ChildAdded:Connect(handleBackpackAdd)

--// RenderStepped

RunService.RenderStepped:Connect(function()

	--// Visuals

	if toggles["Always Day"] == true then 
		for _,v in pairs(ReplicatedStorage.DayProperties:GetChildren()) do 
			game.Lighting[v.Name] = v.Value
			if CurrentLightingProperties:FindFirstChild(v.Name) then 
				CurrentLightingProperties[v.Name].Value = v.Value
			end
		end
	end

	if toggles["Always Night"] == true then 
		for _,v in pairs(ReplicatedStorage.NightProperties:GetChildren()) do 
			game.Lighting[v.Name] = v.Value
			if CurrentLightingProperties:FindFirstChild(v.Name) then 
				CurrentLightingProperties[v.Name].Value = v.Value
			end
		end
	end

	if toggles["No Fog"] == true then
		game.Lighting.FogEnd = 999999
		CurrentLightingProperties.FogEnd.Value = 999999
	end

	if toggles["Fullbright"] == true then 
		game.Lighting.Brightness = 2
		CurrentLightingProperties.Brightness.Value = 2
	else 
		game.Lighting.Brightness = 0.45
		CurrentLightingProperties.Brightness.Value = 0.45
	end

	-- ESPs

	if toggles["Scrap ESP"] == true then
		ESPScrap()	   
	else 
		for _,scrapBil in pairs(ScrapLabels) do 
			scrapBil:Destroy()
		end
	end

	if toggles["Rake ESP"] == true then
		local RakeInWorkspace = workspace:FindFirstChild("Rake")

		if RakeInWorkspace then
			if not RakeInWorkspace.HumanoidRootPart:FindFirstChild("Isguied") then 
				newLabel(RakeInWorkspace.HumanoidRootPart, "Rake")

				if RakeInWorkspace:FindFirstChild("AttackHitbox") then
					RakeInWorkspace.AttackHitbox.Size = Vector3.new(2048,2048,2048)
				end
			end
		end
	else 
		if RakeLabel then 
			RakeLabel:Destroy()
			RakeLabel = nil 
		end

	end

	if toggles["Supply Drop ESP"] == true then 
		local SupplyCrates = workspace.Debris.SupplyCrates

		if SupplyCrates:FindFirstChild("Box") then
			local Box = SupplyCrates:FindFirstChild("Box")

			if not Box.HitBox:FindFirstChild("Isguied") then 
				newLabel(Box.HitBox, "Supply Crate")
				createNotification("Supply crate spawned!", "You can now view items in the supply crate", 5)

				if toggles["Bypass Supply Drop Lock"] == true then
					bypassSupplyDropLock(Box)
				end
			end
		end 
	else 
		for _,v in pairs(SupplyDropLabels) do 
			v:Destroy()    
		end
	end

	if toggles["Players ESP"] == true then 

		for _,v in pairs(game.Players:GetPlayers()) do 
			if v.Name ~= game.Players.LocalPlayer.Name then
				if v.Character ~= nil then 
					local theirCharacter = v.Character 

					if theirCharacter:FindFirstChild("HumanoidRootPart") then 
						if not theirCharacter.HumanoidRootPart:FindFirstChild("Isguied") then 
							newLabel(theirCharacter.HumanoidRootPart, v.Name, true)
						end
					end
				end
			end
		end

	else
		for _,bill in pairs(PlayersLabels) do 
			bill:Destroy()
		end
	end

	--// Client

	if toggles["Infinite Stamina"] == true then
		if hookedStamina == false then
			for _,v in ipairs(getloadedmodules()) do 
				if v.Name == "M_H" then 
					--LPH_JIT_ULTRA(function(v)
						local module = require(v)
						local old 
						old = hookfunction(module.TakeStamina, function(smth, amount)
							if amount > 0 then return old(smth, -0.5) end
							return old(smth, amount)
						end)
					--end)(v)
				end
			end

			hookedStamina = true
			createNotification("Notice", "You cannot disable Infinite Stamina unless you turn it off and die", 5)
		end
	end

	if damageRunOnce == false then
		local NoFallDamage
		NoFallDamage = hookmetamethod(game, '__namecall', function(...)
			local Method = getnamecallmethod()
			local Args = {...}

			if Method == 'FireServer' then
				if tostring(...) == 'FD_Event' then
					return    
				end
			end

			return NoFallDamage(...)
		end)

		damageRunOnce = true
	end

	if toggles["View Cameras"] == true then
		if selectedCamera ~= nil then
			workspace.CurrentCamera.CFrame = selectedCamera.DefaultPosition.CFrame + (selectedCamera.DefaultPosition.CFrame.LookVector * 1.5)  
		end
	end

	if toggles["Timer"] == true then
		TimeInfo.Visible = true 
	else 
		TimeInfo.Visible = false  
	end

	if toggles["Flare Gun ESP"] == true then
		local FlareGunInWorkspace = workspace:FindFirstChild("FlareGunPickUp")

		if FlareGunInWorkspace then
			if not FlareGunInWorkspace:FindFirstChild("Isguied") then
				newLabel(FlareGunInWorkspace, "Flare Gun")
			end
		end
	else 
		if FlareGunLabel then
			FlareGunLabel:Destroy()
			FlareGunLabel = nil
		end
	end

	if independentStamina then
		Player.Character.Humanoid.WalkSpeed = 30
	end

	--// Supply Drop

	if toggles["Bypass Supply Drop Lock"] == true then
		if bypassOnceEnabled == false then

			for _,Box in pairs(game.Workspace.Debris.SupplyCrates:GetChildren()) do 
				if Box.Name == "Box" then
					bypassSupplyDropLock(Box)
				end
			end

			bypassOnceEnabled = true
		end
	end

	--// Tools

	if toggles["Stun Stick Modifier"] == true then
		if StunStickModified == false then
			local theTool = Player.Backpack:FindFirstChild("StunStick") or Player.Character:FindFirstChild("StunStick")

			if theTool then
				modifyStunStick(theTool)

				createNotification("Done!", "Sucessfully modified your Stun Stick!", 5)
			end
		end
	end

	if toggles["UV Lamp Modifier"] == true then
		if UVModified == false then
			local theTool = Player.Backpack:FindFirstChild("UV_Lamp") or Player.Character:FindFirstChild("UV_Lamp")

			if theTool then
				modifyUV_Lamp(theTool)

				createNotification("Done!", "Sucessfully modified your UV Lamp!", 5)
			end
		end
	end

	if toggles["Power Level"] == true then
		PowerLevel.Visible = true
		PowerLevel.Text = "Power Level: "..ReplicatedStorage.PowerValues.PowerLevel.Value
	else 
		PowerLevel.Visible = false
	end
end)

--// Time Handler

task.spawn(function()
	while task.wait(1) do 
		if toggles["Timer"] == true then 
			TimeInfo.Text = toMS(Timer.Value)
		end
	end
end)

--// Camera Input Handler

UserInputService.InputBegan:Connect(function(input, isChat)
	if isChat then return end 

	if toggles["View Cameras"] == true then 
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
end)

--// Indepent Sprint/Toggle

UserInputService.InputBegan:Connect(function(input, isChat)
	if isChat then return end 

	if typeof(keybinds["Sprint without stamina"]) == 'string' then 
		if input.KeyCode == Enum.KeyCode[keybinds["Sprint without stamina"]] then 
			independentStamina = not independentStamina
		end
	else 
		if input.KeyCode == keybinds["Sprint without stamina"] then 
			independentStamina = not independentStamina
		end
	end

	if typeof(keybinds["Toggle UI"]) == 'string' then 
		if input.KeyCode == Enum.KeyCode[keybinds["Toggle UI"]] then 
			Main.Visible = not Main.Visible
		end
	else 
		if input.KeyCode == keybinds["Toggle UI"] then 
			Main.Visible = not Main.Visible
		end
	end
end)

--// Died Event

function handleDeath()
	Player.CharacterAdded:Wait()
	Player.Character:WaitForChild("HumanoidRootPart")
	hookedStamina = false
	UVModified = false 
	StunStickModified = false
	
	Player.Character.Humanoid.Died:Connect(handleDeath)
end

Player.Character.Humanoid.Died:Connect(handleDeath)

createNotification("Script Loaded!", "Thanks for using Rake Evolved!", 5)
