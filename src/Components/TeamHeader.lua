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
        Size = UDim2.new(1, 0, 0, 32),
    
        [Children] = {
            New "TextButton" {
                BackgroundTransparency = 1,
                TextTransparency = 1,
                Text = "",
                Size = UDim2.fromScale(1, 1),
    
                [Children] = {
                    New "ImageLabel" {
                        Image = "rbxassetid://8858987141",
                        ImageColor3 = props.Color,
                        ImageTransparency = 0.5,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(256, 256, 256, 256),
                        SliceScale = 0.01,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.5),
                    },
    
                    New "ImageLabel" {
                        Image = "rbxassetid://8858987793",
                        ImageColor3 = props.Color,
                        ImageTransparency = Computed(function()
                            return props.Collapsed:get() and 0.5 or 1
                        end),
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(256, 256, 256, 256),
                        SliceScale = 0.01,
                        AnchorPoint = Vector2.new(0, 1),
                        BackgroundTransparency = 1,
                        Position = UDim2.fromScale(0, 1),
                        Size = UDim2.fromScale(1, 0.5),
    
                        [Children] = {
                            New "Frame" {
                                BackgroundColor3 = props.Color,
                                BackgroundTransparency = 0.5,
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                                Visible = Computed(function()
                                    return not props.Collapsed:get()
                                end)
                            },
                        }
                    },
    
                    New "TextLabel" {
                        Font = Enum.Font.GothamBold,
                        Text = props.Name,
                        TextColor3 = Color3.fromHex("#FFFFFF"),
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(16, 0),
                        Size = UDim2.fromScale(0, 1),
                    },
    
                    New "Frame" {
                        AnchorPoint = Vector2.new(0, 1),
                        BackgroundColor3 = Color3.fromHex("#FFFFFF"),
                        BackgroundTransparency = 0.9,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0, 1),
                        Size = UDim2.new(1, 0, 0, 2),
                        Visible = Computed(function()
                            return not props.Collapsed:get()
                        end)
                    },
                },

                [OnEvent "Activated"] = function()
                    print(props.Collapsed:get())
                    props.Collapsed:set(not props.Collapsed:get())
                end,
            },
        }
    }
end