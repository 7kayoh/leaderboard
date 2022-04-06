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

local PlayerComponent = require(script.Parent.Components.Player)
local TeamHeaderComponent = require(script.Parent.Components.TeamHeader)

local UISize = Value(UDim2.fromOffset(165, 300))
local UIVisible = Value(true)
local teamsData = Value({})
local UI = New "ScreenGui" {
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = Player:WaitForChild("PlayerGui"),

    [Children] = {
        New "ScrollingFrame" {
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            AnchorPoint = Vector2.new(1, 0),
            BackgroundTransparency = 1,
            Position = Tween(Computed(function()
                return UIVisible:get() and UDim2.new(1, -5, 0, 4) or UDim2.new(1.145, -5, 0, 4)
            end), TweenInfo.new(0.3, Enum.EasingStyle.Quint)),
            Size = UISize,
        
            [Children] = {
                New "UIListLayout" {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                },

                ForPairs(teamsData, function(index, value)
                    return index, New "Frame" {
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0),
                
                        [Children] = {
                            New "UIListLayout" {
                                SortOrder = Enum.SortOrder.LayoutOrder,
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
                                    Order = Value(index + 1),
                                    AtTop = Value(index == 1),
                                    AtBottom = Value(index == #value.Players:get()),
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
    if state == Enum.UserInputState.End then
        UIVisible:set(not UIVisible:get())
    end
end, false, 4000, Enum.KeyCode.Tab)

for _, team in ipairs(Teams:GetTeams()) do
    registerTeam(team)
end
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
if UI.AbsoluteSize.Y > 500 then
    UISize:set(UDim2.fromOffset(165, 300))
else
    UISize:set(UDim2.new(0, 165, 0.4, 0))
end