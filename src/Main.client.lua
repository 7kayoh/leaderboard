local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local Player = Players.LocalPlayer

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local ForPairs = Fusion.ForPairs
local Computed = Fusion.Computed

local PlayerComponent = require(script.Parent.Components.Player)
local TeamHeaderComponent = require(script.Parent.Components.TeamHeader)

local UISize = Value(UDim2.fromOffset(165, 300))
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
            Position = UDim2.new(1, -5, 0, 4),
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
                            }),
                            ForPairs(value.Players, function(index, player)
                                return index, PlayerComponent({
                                    Name = player.Name,
                                    DisplayName = player.DisplayName,
                                    AtTop = Value(index == 1),
                                    AtBottom = Value(index == #value.Players),
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
    local data = {
        Color = team.TeamColor.Color,
        Name = team.Name,
        Players = team:GetPlayers(),
    }
    local function update()
        local newTeamsData = teamsData:get()
        newTeamsData[team.Name] = newTeamsData[team.Name] or {}
        newTeamsData[team.Name].Players = data.Players
        newTeamsData[team.Name].Color = data.Color
        newTeamsData[team.Name].Name = data.Name
        newTeamsData[team.Name].Collapsed = newTeamsData[team.Name].Collapsed or Value(false)
        if #data.Players == 0 then
            newTeamsData[team.Name].Collapsed:set(true)
        end
        teamsData:set(newTeamsData)
    end
    team.PlayerAdded:Connect(function(player)
        table.insert(data.Players, player)
        update()
    end)
    team.PlayerRemoved:Connect(function(player)
        table.remove(data.Players, table.find(data.Players, player))
        update()
    end)
    update()
end

Teams.ChildAdded:Connect(registerTeam)
Teams.ChildRemoved:Connect(function(team)
    if not team:IsA("Team") then return end
    local newTeamsData = teamsData:get()
    newTeamsData[team.Name] = nil
    teamsData:Set(newTeamsData)
end)

for _, team in ipairs(Teams:GetTeams()) do
    registerTeam(team)
end

if UI.AbsoluteSize.Y > 500 then
    UISize:set(UDim2.fromOffset(165, 300))
else
    UISize:set(UDim2.new(0, 165, 0.4, 0))
end