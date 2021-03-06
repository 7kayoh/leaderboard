local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicatedStorage.Packages.Fusion)
local PlayerComponent = require(script.Parent.Player)
local TeamHeaderComponent = require(script.Parent.TeamHeader)
local Player = Players.LocalPlayer

local DEV_GRP = 7
local DEV_LOWEST_RANK = 255

local New = Fusion.New
local Children = Fusion.Children
local Value = Fusion.Value
local ComputedPairs = Fusion.ComputedPairs
local Computed = Fusion.Computed
local OnChange = Fusion.OnChange

return function(props)
    local absoluteContentSize = Value(Vector2.new(0, 0))

    return New "Frame" {
        BackgroundTransparency = 1,
        Size = Computed(function()
            return UDim2.new(1, 0, 0, absoluteContentSize:get().Y)
        end),

        [Children] = {
            New "UIListLayout" {
                SortOrder = Enum.SortOrder.LayoutOrder,

                [OnChange "AbsoluteContentSize"] = function(newValue)
                    absoluteContentSize:set(newValue)
                end
            },

            Computed(function()
                if #Teams:GetTeams() > 0 then
                    return TeamHeaderComponent({
                        Color = props.Color,
                        Name = if props.Name == "@no_team" then "No Team" else props.Name,
                        Collapsed = props.Collapsed,
                        Count = #props.Players,
                    })
                else
                    return nil
                end
            end),

            ComputedPairs(props.Players, function(index, player)
                return PlayerComponent({
                    UserId = player.UserId,
                    Name = player.Name,
                    DisplayName = player.DisplayName,
                    Icon = Computed(function()
                        local success, result = pcall(player.IsFriendsWith, player, Player)
                        local success2, result2 = pcall(player.GetRankInGroup, player, DEV_GRP)
                        if player == Players.LocalPlayer then
                            return "rbxassetid://9308617156"
                        elseif success and result then
                            return "rbxasset://textures/ui/PlayerList/FriendIcon.png"
                        elseif success2 and result2 >= DEV_LOWEST_RANK then
                            return "rbxasset://textures/ui/PlayerList/developer.png"
                        elseif player.MembershipType == Enum.MembershipType.Premium then
                            return "rbxasset://textures/ui/PlayerList/PremiumIcon.png"
                        else
                            return "rbxasset://"
                        end
                    end),
                    Order = Value(index),
                    AtTop = Value(true),
                    AtBottom = Computed(function()
                        return index == #props.Players
                    end),
                    Visible = Computed(function()
                        return not props.Collapsed:get()
                    end),
                })
            end)
        },
    }
end