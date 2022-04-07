local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Player = Players.LocalPlayer

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local ForPairs = Fusion.ForPairs
local Computed = Fusion.Computed
local Tween = Fusion.Tween
local Out = Fusion.Out

local PlayerComponent = require(script.Parent.Components.Player)
local TeamHeaderComponent = require(script.Parent.Components.TeamHeader)

local UISize = Value(UDim2.fromOffset(200, 300))
local UIVisible = Value(true)
local UICanvasSize = Value(Vector2.new(0, 0))
local teamsData = Value({})
local UI = New "ScreenGui" {
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = Player:WaitForChild("PlayerGui"),

	[Children] = {
		New "ScrollingFrame" {
			ScrollBarThickness = 0,
			AnchorPoint = Tween(Computed(function()
				return UIVisible:get() and Vector2.new(1, 0) or Vector2.new(0, 0)
			end), TweenInfo.new(0.3, Enum.EasingStyle.Quint)),
			BackgroundTransparency = 1,
			CanvasSize = Tween(Computed(function()
				return UDim2.fromOffset(0, UICanvasSize:get().Y)
			end), TweenInfo.new(0.3, Enum.EasingStyle.Quint)),
			Position = UDim2.new(1, -5, 0, 4),
			Size = UISize,

			[Children] = {
				New "UIListLayout" {
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder,
					[Out "AbsoluteContentSize"] = UICanvasSize,
				},

				ForPairs(teamsData, function(index, value)
					local absoluteContentSize = Value(Vector2.new(0, 0))

					return index, New "Frame" {
						BackgroundTransparency = 1,
						Size = Computed(function()
							return UDim2.new(1, 0, 0, absoluteContentSize:get().Y)
						end),
						Visible = Computed(function()
							return #value.Players:get() > 0 
						end),

						[Children] = {
							New "UIListLayout" {
								SortOrder = Enum.SortOrder.LayoutOrder,
								[Out "AbsoluteContentSize"] = absoluteContentSize,
							},
							TeamHeaderComponent({
								Color = value.Color,
								Name = value.Name,
								Collapsed = value.Collapsed,
								Count = Computed(function()
									return #value.Players:get()
								end)
							}),
							ForPairs(value.Players, function(index, player)
								return index, PlayerComponent({
									Name = player.Name,
									DisplayName = player.DisplayName,
									Order = Computed(function()
										return table.find(value.Players:get(), player)	
									end),
									AtTop = Value(true),
									AtBottom = Computed(function()
										return table.find(value.Players:get(), player) == #value.Players:get()
									end),
									Visible = Computed(function()
										return not value.Collapsed:get()
									end),
								})
							end),
						},
					}
				end)
			}
		}
	},
}

local function registerTeam(team: Team)
	if not team:IsA("Team") then return false end
	if team:GetAttribute("REDACTED") then return false end
	local function update()
		local currentTeamsData = teamsData:get()
		currentTeamsData[team.Name] = currentTeamsData[team.Name] or {
			Players = Value({}),
			Name = team.Name,
			Color = team.TeamColor.Color,
			Collapsed = Value(false),
			CollapsedDueToNoPlayers = Value(true)
		}
		currentTeamsData[team.Name].Players:set(team:GetPlayers())
		if #currentTeamsData[team.Name].Players:get() == 0 then
			currentTeamsData[team.Name].Collapsed:set(true)
			currentTeamsData[team.Name].CollapsedDueToNoPlayers:set(true)
		elseif currentTeamsData[team.Name].CollapsedDueToNoPlayers:get() then
			currentTeamsData[team.Name].Collapsed:set(false)
			currentTeamsData[team.Name].CollapsedDueToNoPlayers:set(false)
		end
		teamsData:set(currentTeamsData)
	end

	team.PlayerAdded:Connect(update)
	team.PlayerRemoved:Connect(update)
	update()
end

Teams.ChildAdded:Connect(registerTeam)
Teams.ChildRemoved:Connect(function(team)
	if not team:IsA("Team") then return end
	local newTeamsData = teamsData:get()
	newTeamsData[team.Name] = nil
	teamsData:Set(newTeamsData)
end)
ContextActionService:BindActionAtPriority("TogglePlayerList", function(_, state)
	if state == Enum.UserInputState.Begin then
		UIVisible:set(not UIVisible:get())
	end
end, false, 4000, Enum.KeyCode.Tab)

for _, team in ipairs(Teams:GetTeams()) do
	registerTeam(team)
end
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
if UI.AbsoluteSize.Y > 500 then
	UISize:set(UDim2.fromOffset(200, 300))
else
	UISize:set(UDim2.new(0, 180, 0.4, 0))
end
