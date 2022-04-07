local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PlayerComponent = require(script.Parent.Components.Player)
local TeamHeaderComponent = require(script.Parent.Components.TeamHeader)
local Player = Players.LocalPlayer

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local ForValues = Fusion.ForValues
local Computed = Fusion.Computed
local Tween = Fusion.Tween
local Out = Fusion.Out

local UISize = Value(UDim2.fromOffset(200, 300))
local UIVisible = Value(true)
local UICanvasSize = Value(Vector2.new(0, 0))
local teamsData = Value({})
local UI = New "ScreenGui" {
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = Player:WaitForChild("PlayerGui"),
	Name = "Player List",

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

				ForValues(teamsData, function(value)
					local absoluteContentSize = Value(Vector2.new(0, 0))

					return New "Frame" {
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
									return #value.Players:get() or "0"
								end)
							}),
							ForValues(value.Players, function(player)
								local index = table.find(value.Players:get(), player)
								return PlayerComponent({
									Name = player.Name,
									DisplayName = player.DisplayName,
									Icon = Computed(function()
										local success, result = pcall(player.IsFriendsWith, player, Player)
										if success and result then
											return "rbxasset://textures/ui/PlayerList/FriendIcon@3x.png"
										elseif player.MembershipType == Enum.MembershipType.Premium then
											return "rbxasset://textures/ui/PlayerList/PremiumIcon@3x.png"
										else
											return "rbxasset://"
										end
									end),
									Order = Computed(function()
										return index
									end),
									AtTop = Value(true),
									AtBottom = Computed(function()
										return index == #value.Players:get()
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
