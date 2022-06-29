local SupplyDropView = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local TextButton = Instance.new("TextButton")
local _1 = Instance.new("ImageButton")
local UICorner_2 = Instance.new("UICorner")
local _2 = Instance.new("ImageButton")
local UICorner_3 = Instance.new("UICorner")
local _3 = Instance.new("ImageButton")
local UICorner_4 = Instance.new("UICorner")
local _4 = Instance.new("ImageButton")
local UICorner_5 = Instance.new("UICorner")
local _5 = Instance.new("ImageButton")
local UICorner_6 = Instance.new("UICorner")
local _6 = Instance.new("ImageButton")
local UICorner_7 = Instance.new("UICorner")
local exit = Instance.new("TextButton")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")

SupplyDropView.Name = "SupplyDropView"
SupplyDropView.AnchorPoint = Vector2.new(0.5, 0.5)
SupplyDropView.BackgroundColor3 = Color3.fromRGB(49, 53, 58)
SupplyDropView.BackgroundTransparency = 0.500
SupplyDropView.BorderColor3 = Color3.fromRGB(27, 42, 53)
SupplyDropView.Position = UDim2.new(0.5, 0, 0.182546735, 0)
SupplyDropView.Size = UDim2.new(0.200000003, 0, 0.335273385, 0)

UICorner.Parent = SupplyDropView

TextButton.Parent = SupplyDropView
TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextButton.Position = UDim2.new(0.499264538, 0, 0.496008396, 0)
TextButton.Size = UDim2.new(0.618046939, 0, 0.263019443, 0)
TextButton.Visible = false
TextButton.Modal = true
TextButton.Font = Enum.Font.SourceSans
TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
TextButton.TextScaled = true
TextButton.TextSize = 14.000
TextButton.TextWrapped = true

_1.Name = "1"
_1.Parent = SupplyDropView
_1.Active = false
_1.AnchorPoint = Vector2.new(0.5, 0.5)
_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_1.BackgroundTransparency = 1.000
_1.Position = UDim2.new(0.211872712, 0, 0.239167869, 0)
_1.Selectable = false
_1.Size = UDim2.new(0.234857842, 0, 0.383671284, 0)
_1.AutoButtonColor = false

UICorner_2.Parent = _1

_2.Name = "2"
_2.Parent = SupplyDropView
_2.Active = false
_2.AnchorPoint = Vector2.new(0.5, 0.5)
_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_2.BackgroundTransparency = 1.000
_2.Position = UDim2.new(0.496174306, 0, 0.239167869, 0)
_2.Selectable = false
_2.Size = UDim2.new(0.234857842, 0, 0.383671284, 0)
_2.AutoButtonColor = false

UICorner_3.Parent = _2

_3.Name = "3"
_3.Parent = SupplyDropView
_3.Active = false
_3.AnchorPoint = Vector2.new(0.5, 0.5)
_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_3.BackgroundTransparency = 1.000
_3.Position = UDim2.new(0.783566177, 0, 0.239167869, 0)
_3.Selectable = false
_3.Size = UDim2.new(0.234857842, 0, 0.383671284, 0)
_3.AutoButtonColor = false

UICorner_4.Parent = _3

_4.Name = "4"
_4.Parent = SupplyDropView
_4.Active = false
_4.AnchorPoint = Vector2.new(0.5, 0.5)
_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_4.BackgroundTransparency = 1.000
_4.Position = UDim2.new(0.208782479, 0, 0.702082098, 0)
_4.Selectable = false
_4.Size = UDim2.new(0.234857842, 0, 0.383671284, 0)
_4.AutoButtonColor = false

UICorner_5.Parent = _4

_5.Name = "5"
_5.Parent = SupplyDropView
_5.Active = false
_5.AnchorPoint = Vector2.new(0.5, 0.5)
_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_5.BackgroundTransparency = 1.000
_5.Position = UDim2.new(0.493084073, 0, 0.702082098, 0)
_5.Selectable = false
_5.Size = UDim2.new(0.234857842, 0, 0.383671284, 0)
_5.AutoButtonColor = false

UICorner_6.Parent = _5

_6.Name = "6"
_6.Parent = SupplyDropView
_6.Active = false
_6.AnchorPoint = Vector2.new(0.5, 0.5)
_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
_6.BackgroundTransparency = 1.000
_6.Position = UDim2.new(0.780475914, 0, 0.702082098, 0)
_6.Selectable = false
_6.Size = UDim2.new(0.234857842, 0, 0.383671284, 0)
_6.AutoButtonColor = false

UICorner_7.Parent = _6

exit.Name = "exit"
exit.Parent = SupplyDropView
exit.AnchorPoint = Vector2.new(0.5, 0.5)
exit.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
exit.BackgroundTransparency = 41.000
exit.Position = UDim2.new(0.5, 0, 1.01678681, 0)
exit.Size = UDim2.new(0.618046939, 0, 0.115728468, 0)
exit.Font = Enum.Font.GothamMedium
exit.Text = "Exit"
exit.TextColor3 = Color3.fromRGB(255, 255, 255)
exit.TextScaled = true
exit.TextSize = 14.000
exit.TextWrapped = true

UIAspectRatioConstraint.Parent = SupplyDropView
UIAspectRatioConstraint.AspectRatio = 1.702

return SupplyDropView
