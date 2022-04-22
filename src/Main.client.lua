local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local List = require(script.Parent.Components.TeamList)
local Player = Players.LocalPlayer

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local ComputedPairs = Fusion.ComputedPairs
local Computed = Fusion.Computed
local Tween = Fusion.Tween
local OnChange = Fusion.OnChange

local size = Value(UDim2.fromOffset(200, 300))
local isVisible = Value(true)
local canvasSize = Value(Vector2.new(0, 0))
local absoluteSize = Value(Vector2.new(0, 0))
local allTeams = Value({})

local UI = New "ScreenGui" {
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = Player:WaitForChild("PlayerGui"),
	Name = "Player List",

	[Children] = {
		New "ScrollingFrame" {
			ScrollBarThickness = 0,
			AnchorPoint = Tween(Computed(function()
				return isVisible:get() and Vector2.new(1, 0) or Vector2.new(0, 0)
			end), TweenInfo.new(0.3, Enum.EasingStyle.Quint)),
			BackgroundTransparency = 1,
			CanvasSize = Tween(Computed(function()
				return UDim2.fromOffset(0, canvasSize:get().Y)
			end), TweenInfo.new(0.3, Enum.EasingStyle.Quint)),
			ScrollingEnabled = Computed(function()
				return canvasSize:get().Y >= absoluteSize:get().Y
			end),
			Position = UDim2.new(1, -5, 0, 4),
			Size = size,

			[Children] = {
				New "UIListLayout" {
					Padding = UDim.new(0, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					[OnChange "AbsoluteContentSize"] = function(newValue)
						canvasSize:set(newValue)
					end
				},

				New "ImageLabel" {
					Image = "rbxassetid://8858987141",
					ImageColor3 = Color3.fromHex("#000000"),
					ImageTransparency = 0.5,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(256, 256, 256, 256),
					SliceScale = 0.01,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 24),
					LayoutOrder = -1,

					[Children] = {
						New "TextLabel" {
							BackgroundTransparency = 1,
							Font = Enum.Font.GothamBold,
							Text = "Players",
							TextColor3 = Color3.fromHex("#FFFFFF"),
							TextSize = 12,
							TextTransparency = 0.2,
							Position = UDim2.fromOffset(16, 0),
							Size = UDim2.fromScale(0, 1),
							TextXAlignment = Enum.TextXAlignment.Left,
						},

						New "Frame" {
							BackgroundTransparency = 0.9,
							BorderSizePixel = 0,
							Position = UDim2.fromScale(0, 1),
							AnchorPoint = Vector2.new(0, 1),
							Size = UDim2.new(1, 0, 0, 1),
						}
					}
				},

				New "ImageLabel" {
					Image = "rbxassetid://8858987793",
					ImageColor3 = Color3.fromHex("#000000"),
					ImageTransparency = 0.5,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(256, 256, 256, 256),
					SliceScale = 0.01,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 6),
					LayoutOrder = 10000,

					[Children] = {
						New "Frame" {
							BackgroundTransparency = 0.9,
							BorderSizePixel = 0,
							Size = UDim2.new(1, 0, 0, 1),
						}
					}
				},

				ComputedPairs(allTeams, function(_, team)
					return List(team)
				end),
			},

			[OnChange "AbsoluteSize"] = function(newValue)
				absoluteSize:set(newValue)
			end,
		}
	},
}

local function registerTeam(team: Team)
	if not team:IsA("Team") then return false end
	local function update()
		local allTeamsTbl = allTeams:get()
		local currentTeam = allTeamsTbl[team.Name]
		if team:GetAttribute("Hidden") then
			allTeamsTbl[team.Name] = nil
			allTeams:set(allTeamsTbl, true)
		end
		local newData = {
			Players = team:GetPlayers(),
			Name = team.Name,
			Color = team.TeamColor.Color,
			Collapsed = if currentTeam then currentTeam.Collapsed else Value(false)
		}
		allTeamsTbl[team.Name] = newData
		allTeams:set(allTeamsTbl, true)
	end

	team.PlayerAdded:Connect(update)
	team.PlayerRemoved:Connect(update)
	update()
end

local function updateNeutral()
	local allTeamsTbl = allTeams:get()
	local currentTeam = allTeamsTbl.Neutral
	local neutralPlayers = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team == nil then
			table.insert(neutralPlayers, player)
		end
	end
	local newData = {
		Players = neutralPlayers,
		Name = "@no_team",
		Color = Color3.new(),
		Collapsed = if currentTeam then currentTeam.Collapsed else Value(false)
	}
	allTeamsTbl.Neutral = newData
	allTeams:set(allTeamsTbl, true)
end

local function registerPlayerEvent(player)
	local pastTeam = if player.Team then player.Team.Name else "@no_team"
	player:GetPropertyChangedSignal("Team"):Connect(function()
		if not player.Team then
			updateNeutral()
		elseif pastTeam == "@no_team" and player.Team.Name ~= pastTeam then
			updateNeutral()
		end
		pastTeam = if player.Team then player.Team.Name else "@no_team"
	end)

	if pastTeam == "@no_team" then
		updateNeutral()
	end
end

Teams.ChildAdded:Connect(registerTeam)
Teams.ChildRemoved:Connect(function(team)
	if not team:IsA("Team") then return end
	local newTeamsData = allTeams:get()
	newTeamsData[team.Name] = nil
	allTeams:set(newTeamsData, true)
end)

Players.PlayerAdded:Connect(registerPlayerEvent)
for _, team in ipairs(Teams:GetTeams()) do
	registerTeam(team)
end
for _, team in ipairs(Players:GetPlayers()) do
	registerPlayerEvent(team)
end

ContextActionService:BindActionAtPriority("TogglePlayerList", function(_, state)
	if state == Enum.UserInputState.Begin then
		isVisible:set(not isVisible:get())
	end
end, false, 4000, Enum.KeyCode.Tab)

if UI.AbsoluteSize.Y > 500 then
	size:set(UDim2.fromOffset(200, 300))
else
	size:set(UDim2.new(0, 180, 0.4, 0))
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
