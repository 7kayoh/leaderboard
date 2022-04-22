local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed
local OnEvent = Fusion.OnEvent
local Value = Fusion.Value

return function(props)
    props.Collapsed = props.Collapsed or Value(false)
    return New "Frame" {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
    
        [Children] = {
            New "Frame" {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
    
                [Children] = {
                    New "Frame" {
                        BackgroundColor3 = props.Color,
                        BackgroundTransparency = 0.3,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                    },
    
                    New "TextLabel" {
                        Font = Enum.Font.GothamBold,
                        Text = props.Name,
                        TextColor3 = Color3.fromHex("#FFFFFF"),
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(16, 0),
                        Size = UDim2.fromScale(0.75, 1),
                        TextWrapped = true,
                        ZIndex = 2,
                    },

                    New "TextLabel" {
                        Font = Enum.Font.Gotham,
                        Text = props.Count,
                        TextColor3 = Color3.fromHex("#FFFFFF"),
                        TextTransparency = 0.5,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.new(1, -16, 0, 0),
                        Size = UDim2.fromScale(0, 1),
                        ZIndex = 2,
                    },
                },

                [OnEvent "InputEnded"] = function(input)
                    if table.find({ Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch }, input.UserInputType) then
                        props.Collapsed:set(not props.Collapsed:get())
                    end
                end,
            },
        }
    }
end