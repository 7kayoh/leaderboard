local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local New = Fusion.New
local Tween = Fusion.Tween
local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value
local OnEvent = Fusion.OnEvent

return function(props)
    local isHovering = Value(false)
    local forceDisabled = Value(true)

    -- im so sorry for this horrible code solution
    task.delay(0.1, function()
        forceDisabled:set(false)
    end)

    return New "Frame" {
        BackgroundTransparency = 1,
        LayoutOrder = props.Order:get(),
        Size = Tween(Computed(function()
            if forceDisabled:get() or not props.Visible:get() then
                return UDim2.fromScale(1, 0)
            else
                return UDim2.new(1, 0, 0, 42)
            end
        end), TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.3)),
        ClipsDescendants = true,

        [Children] = {
            New "Frame" {
                BackgroundTransparency = 1,
                Position = Tween(Computed(function()
                    if forceDisabled:get() or not props.Visible:get() then
                        return UDim2.fromScale(1, 0)
                    else
                        return UDim2.fromScale(0, 0)
                    end
                end), TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false)),
                Size = UDim2.fromScale(1, 1),

                [Children] = {
                    New "ImageLabel" {
                        Image = "rbxassetid://8858987141",
                        ImageColor3 = Color3.fromHex("#000000"),
                        ImageTransparency = Computed(function()
                            return props.AtTop:get() and 1 or 0.5
                        end),
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(256, 256, 256, 256),
                        SliceScale = 0.01,
                        BackgroundTransparency = 1,
                        Size = UDim2.fromScale(1, 0.5),

                        [Children] = {
                            New "Frame" {
                                BackgroundColor3 = Color3.fromHex("#000000"),
                                BackgroundTransparency = 0.5,
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                                Visible = Computed(function()
                                    return props.AtTop:get()
                                end)
                            },
                        }
                    },

                    New "ImageLabel" {
                        Image = "rbxassetid://8858987793",
                        ImageColor3 = Color3.fromHex("#000000"),
                        ImageTransparency = Computed(function()
                            return props.AtBottom:get() and 0.5 or 1
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
                                BackgroundColor3 = Color3.fromHex("#000000"),
                                BackgroundTransparency = 0.5,
                                BorderSizePixel = 0,
                                Size = UDim2.fromScale(1, 1),
                                Visible = Computed(function()
                                    return not props.AtBottom:get()
                                end),
                            },
                        }
                    },

                    New "ImageLabel" {
                        Size = UDim2.fromOffset(60, 42),
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 1,
                        Image = ("rbxthumb://type=AvatarHeadShot&id=%s&w=60&h=60"):format(props.UserId),
                        ImageTransparency = 0.6,
                        ScaleType = Enum.ScaleType.Crop,
                        ZIndex = 2,

                        [Children] = {
                            New "UIGradient" {
                                Transparency = NumberSequence.new({
                                    NumberSequenceKeypoint.new(0, 0),
                                    NumberSequenceKeypoint.new(1, 1)
                                }),
                            }
                        }
                    },

                    New "TextLabel" {
                        Font = Enum.Font.GothamSemibold,
                        Text = props.DisplayName,
                        TextColor3 = Color3.fromHex("#FFFFFF"),
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        TextTransparency = Fusion.Tween(Computed(function()
                            return isHovering:get() and 1 or 0
                        end), TweenInfo.new(0.15)),
                        Position = Fusion.Tween(Computed(function()
                            return isHovering:get() and UDim2.fromScale(0, 0) or UDim2.fromOffset(16, 0)
                        end), TweenInfo.new(0.2, Enum.EasingStyle.Back)),
                        Size = UDim2.fromScale(0, 1),
                        ZIndex = 3,
                    },

                    New "Frame" {
                        AnchorPoint = Vector2.new(1, 1),
                        BackgroundColor3 = Color3.fromHex("#FFFFFF"),
                        BackgroundTransparency = 0.9,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(1, 1),
                        Size = UDim2.new(1, -16, 0, 1),
                        Visible = Computed(function()
                            return not props.AtBottom:get()
                        end),
                        ZIndex = 3,
                    },

                    New "TextLabel" {
                        Font = Enum.Font.Gotham,
                        Text = "@" .. props.Name,
                        TextColor3 = Color3.fromHex("#FFFFFF"),
                        TextSize = 14,
                        TextTransparency = Fusion.Tween(Computed(function()
                            return isHovering:get() and 0.5 or 1
                        end), TweenInfo.new(0.15)),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BackgroundTransparency = 1,
                        Position = Fusion.Tween(Computed(function()
                            return isHovering:get() and UDim2.fromOffset(16, 0) or UDim2.fromOffset(32, 0)
                        end), TweenInfo.new(0.2, Enum.EasingStyle.Back)),
                        Size = UDim2.fromScale(0, 1),
                        ZIndex = 3,
                    },

                    New "ImageLabel" {
                        BackgroundTransparency = 1,
                        Image = props.Icon,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Size = UDim2.fromOffset(16, 16),
                        Position = UDim2.new(1, -13, 0.5, 0),
                        ZIndex = 3,
                    }
                },

                [OnEvent "InputBegan"] = function()
                    isHovering:set(true)
                end,

                [OnEvent "InputEnded"] = function()
                    isHovering:set(false)
                end,
            },
        }
    }
end
