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
local ForValues = Fusion.ForValues
local Computed = Fusion.Computed
local Tween = Fusion.Tween
local Out = Fusion.Out
local Ref = Fusion.Ref

local size = Value(UDim2.fromOffset(200, 300))
local isVisible = Value(true)
local canvasSize = Value(Vector2.new(0, 0))
local allTeams = Value({})
local UI = Value()

New "ScreenGui" {
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = Player:WaitForChild("PlayerGui"),
	Name = "Player List",

	[Ref] = UI,

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
			Position = UDim2.new(1, -5, 0, 4),
			Size = size,

			[Children] = {
				New "UIListLayout" {
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder,
					[Out "AbsoluteContentSize"] = canvasSize,
				},

				ForValues(allTeams, function(team)
					if #team.Players >= 1 then
						return List(team)
					else
						return {}
					end
				end),
			}
		}
	},
}

local function registerTeam(team: Team)
	if not team:IsA("Team") then return false end
	local function update()
		local allTeamsTbl = allTeams:get()
		local currentTeam = allTeamsTbl[team.Name]
		if team:GetAttribute("Hidden") or #team:GetPlayers() == 0 then
			allTeamsTbl[team.Name] = nil
			allTeams:set(allTeamsTbl, true)
		end
		local newData =  {
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

Teams.ChildAdded:Connect(registerTeam)
Teams.ChildRemoved:Connect(function(team)
	if not team:IsA("Team") then return end
	local newTeamsData = allTeams:get()
	newTeamsData[team.Name] = nil
	allTeams:set(newTeamsData, true)
end)
for _, team in ipairs(Teams:GetTeams()) do
	registerTeam(team)
end

ContextActionService:BindActionAtPriority("TogglePlayerList", function(_, state)
	if state == Enum.UserInputState.Begin then
		isVisible:set(not isVisible:get())
	end
end, false, 4000, Enum.KeyCode.Tab)

if UI:get().AbsoluteSize.Y > 500 then
	size:set(UDim2.fromOffset(200, 300))
else
	size:set(UDim2.new(0, 180, 0.4, 0))
end

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
