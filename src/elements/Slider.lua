local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)
local TweenService = game:GetService("TweenService")
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))

local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local Element = {}
local IconDatabase = require("../modules/IconDatabase")
local IsSliderHolding = false

function Element:New(Config)
	local Slider = {
		__type = "Slider",
		Title = Config.Title or nil,
		Desc = Config.Desc or nil,
		Locked = Config.Locked or nil,
		LockedTitle = Config.LockedTitle,
		Value = Config.Value or {},
		Icons = Config.Icons or nil,
		IsTooltip = Config.IsTooltip or false,
		IsTextbox = Config.IsTextbox,
		Step = Config.Step or 1,
		Callback = Config.Callback or function() end,
		UIElements = {},
		IsFocusing = false,

		Width = Config.Width or 130,
		TextBoxWidth = Config.Window.NewElements and 40 or 30,
		ThumbSize = 13,
		IconSize = 26,
	}
	if Slider.Icons == {} then
		Slider.Icons = {
			From = "sfsymbols:sunMinFill",
			To = "sfsymbols:sunMaxFill",
		}
	end
	if Slider.IsTextbox == nil and Slider.Title == nil then
		Slider.IsTextbox = false
	else
		Slider.IsTextbox = Slider.IsTextbox ~= false
	end

	Slider.Value.Min = Slider.Value.Min or 1
	Slider.Value.Max = Slider.Value.Max or 100

	local isTouch
	local moveconnection
	local releaseconnection
	local Value = Slider.Value.Default or Slider.Value.Min or 0

	local LastValue = Value
	local delta = (Value - (Slider.Value.Min or 0)) / ((Slider.Value.Max or 100) - (Slider.Value.Min or 0))

	local CanCallback = true
	local IsFloat = Slider.Step % 1 ~= 0

	local function FormatValue(val)
		if IsFloat then
			return tonumber(string.format("%.2f", val))
		end
		return math.floor(val + 0.5)
	end

	local function CalculateValue(rawValue)
		if IsFloat then
			return math.floor(rawValue / Slider.Step + 0.5) * Slider.Step
		else
			return math.floor(rawValue / Slider.Step + 0.5) * Slider.Step
		end
	end
    local IconFrom, IconTo
local TotalSliderWidth = 32

-- Helper to create an icon instance (font or image)
local function CreateIconInstance(iconString, parent, size, name)
    local resolved = IconDatabase.Resolve(iconString)
    if not resolved then return nil end

    local instance
    if resolved.Type == "font" then
        instance = New("TextLabel", {
            Name = name,
            Parent = parent,
            Size = size,
            BackgroundTransparency = 1,
            FontFace = Font.new(resolved.Path),
            Text = resolved.Icon,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = size.Y.Offset,  -- assume size is UDim2 with offset
            TextScaled = true,
            TextTransparency = 0,
            ImageTransparency = 1,  -- hide any image overlay
        })
    else -- image
        instance = Creator.Image(
            resolved.AssetId,
            resolved.AssetId,
            0,
            parent,
            name,
            true,
            true,
            name
        )
        instance.Size = size
        instance.ImageTransparency = 0
        instance.TextTransparency = 1  -- hide text overlay
    end
    return instance
end

if Slider.Icons then
    if Slider.Icons.From then
        IconFrom = CreateIconInstance(
            Slider.Icons.From,
            Config.Window.Folder,
            UDim2.new(0, Slider.IconSize, 0, Slider.IconSize),
            "SliderIconFrom"
        )
        if IconFrom then
            TotalSliderWidth = TotalSliderWidth + Slider.IconSize - 2
        end
    end
    if Slider.Icons.To then
        IconTo = CreateIconInstance(
            Slider.Icons.To,
            Config.Window.Folder,
            UDim2.new(0, Slider.IconSize, 0, Slider.IconSize),
            "SliderIconTo"
        )
        if IconTo then
            TotalSliderWidth = TotalSliderWidth + Slider.IconSize - 2
        end
    end
end
	end
	Slider.SliderFrame = require("../components/window/Element")({
		Title = Slider.Title,
		Desc = Slider.Desc,
		Parent = Config.Parent,
		TextOffset = Slider.Width,
		Hover = false,
		Tab = Config.Tab,
		Index = Config.Index,
		Window = Config.Window,
		ElementTable = Slider,
		ParentConfig = Config,
		Tags = Config.Tags,
	})

	Slider.UIElements.SliderIcon = Creator.NewRoundFrame(99, "Squircle", {
		ImageTransparency = 0.95,
		Size = UDim2.new(1, not Slider.IsTextbox and -TotalSliderWidth or (-Slider.TextBoxWidth - 8), 0, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Name = "Frame",
		ThemeTag = {
			ImageColor3 = "Text",
		},
	}, {
		Creator.NewRoundFrame(99, "Squircle", {
			Name = "Frame",
			Size = UDim2.new(delta, 0, 1, 0),
			ImageTransparency = 0.1,
			ThemeTag = {
				ImageColor3 = "Slider",
			},
		}, {
			Creator.NewRoundFrame(99, "Squircle", {
				Size = UDim2.new(
					0,
					Config.Window.NewElements and (Slider.ThumbSize * 2) or (Slider.ThumbSize + 2),
					0,
					Config.Window.NewElements and (Slider.ThumbSize + 4) or (Slider.ThumbSize + 2)
				),
				Position = UDim2.new(1, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ThemeTag = {
					ImageColor3 = "SliderThumb",
				},
				Name = "Thumb",
			}, {
				Creator.NewRoundFrame(999, "SquircleGlass", {
					Size = UDim2.new(1, 0, 1, 0),
					ImageColor3 = Color3.new(1, 1, 1),
					Name = "Highlight",
					ImageTransparency = 0.5,
				}),
			}),
		}),
	})

	Slider.UIElements.SliderContainer = New("Frame", {
		Size = UDim2.new(Slider.Title == nil and 1 or 0, Slider.Title == nil and 0 or Slider.Width, 0, 0),
		AutomaticSize = "Y",
		Position = UDim2.new(1, Slider.IsTextbox and (Config.Window.NewElements and -12 - 4 or 0) or 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Parent = Slider.SliderFrame.UIElements.Main,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, Slider.Title ~= nil and 8 or 12),
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
			HorizontalAlignment = Slider.Icons
					and (Slider.Icons.From and (Slider.Icons.To and "Center" or "Left") or Slider.Icons.To and "Right")
				or "Center",
		}),
		IconFrom,
		Slider.UIElements.SliderIcon,
		IconTo,
		New("TextBox", {
			Size = UDim2.new(0, Slider.TextBoxWidth, 0, 0),
			TextXAlignment = "Left",
			Text = FormatValue(Value),
			ThemeTag = {
				TextColor3 = "Text",
			},
			TextTransparency = 0.4,
			AutomaticSize = "Y",
			TextSize = 15,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			BackgroundTransparency = 1,
			LayoutOrder = -1,
			Visible = Slider.IsTextbox,
		}),
	})

	local Tooltip
	if Slider.IsTooltip then
		Tooltip = require("../components/ui/Tooltip").New(
			Value,
			Slider.UIElements.SliderIcon.Frame.Thumb,
			true,
			"Secondary",
			"Small",
			false
		)
		Tooltip.Container.AnchorPoint = Vector2.new(0.5, 1)
		Tooltip.Container.Position = UDim2.new(0.5, 0, 0, -8)
	end

	function Slider:Lock()
		Slider.Locked = true
		CanCallback = false
		return Slider.SliderFrame:Lock(Slider.LockedTitle)
	end
	function Slider:Unlock()
		Slider.Locked = false
		CanCallback = true
		return Slider.SliderFrame:Unlock()
	end

	if Slider.Locked then
		Slider:Lock()
	end

	local ScrollingFrameParent = Config.Tab.UIElements.ContainerFrame

	function Slider:Set(Value, input)
		local minVal = Slider.Value.Min or 0
		local maxVal = Slider.Value.Max or 100
		Slider.Value.Min = minVal
		Slider.Value.Max = maxVal

		if CanCallback then
			if
				not Slider.IsFocusing
				and not IsSliderHolding
				and (
					not input
					or (
						input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch
					)
				)
			then
				if input then
					isTouch = (input.UserInputType == Enum.UserInputType.Touch)
					ScrollingFrameParent.ScrollingEnabled = false
					IsSliderHolding = true

					local inputPosition = isTouch and input.Position.X or UserInputService:GetMouseLocation().X
					local delta = math.clamp(
						(inputPosition - Slider.UIElements.SliderIcon.AbsolutePosition.X)
							/ Slider.UIElements.SliderIcon.AbsoluteSize.X,
						0,
						1
					)
					
					Value = CalculateValue(minVal + delta * (maxVal - minVal))
					Value = math.clamp(Value, minVal, maxVal)

					if Value ~= LastValue then
						Tween(Slider.UIElements.SliderIcon.Frame, 0.05, { Size = UDim2.new(delta, 0, 1, 0) }):Play()
						Slider.UIElements.SliderContainer.TextBox.Text = FormatValue(Value)
						if Tooltip then
							Tooltip.TitleFrame.Text = FormatValue(Value)
						end
						Slider.Value.Default = FormatValue(Value)
						LastValue = Value
						Creator.SafeCallback(Slider.Callback, FormatValue(Value))
					-- Animate icon if both From and To icons exist
                      if IconFrom and IconTo then
                     local newIcon = GetIconForValue(Value, minVal, maxVal, Slider.Icons.From, Slider.Icons.To)
                     if newIcon then
     -- Determine which icon to animate based on current value
                   if Value < (minVal + maxVal) / 2 then
                AnimateIcon(IconFrom, newIcon, 0.15)
            else
                AnimateIcon(IconTo, newIcon, 0.15)
            end
        end
    end
						end
					end

					moveconnection = RunService.RenderStepped:Connect(function()
						local inputPosition = isTouch and input.Position.X or UserInputService:GetMouseLocation().X
						local delta = math.clamp(
							(inputPosition - Slider.UIElements.SliderIcon.AbsolutePosition.X)
								/ Slider.UIElements.SliderIcon.AbsoluteSize.X,
							0,
							1
						)
						Value = CalculateValue(minVal + delta * (maxVal - minVal))

						if Value ~= LastValue then
							Tween(Slider.UIElements.SliderIcon.Frame, 0.05, { Size = UDim2.new(delta, 0, 1, 0) }):Play()
							Slider.UIElements.SliderContainer.TextBox.Text = FormatValue(Value)
							if Tooltip then
								Tooltip.TitleFrame.Text = FormatValue(Value)
							end
							Slider.Value.Default = FormatValue(Value)
							LastValue = Value
							Creator.SafeCallback(Slider.Callback, FormatValue(Value))
						end
					end)

					releaseconnection = UserInputService.InputEnded:Connect(function(endInput)
						if
							(
								endInput.UserInputType == Enum.UserInputType.MouseButton1
								or endInput.UserInputType == Enum.UserInputType.Touch
							) and input == endInput
						then
							moveconnection:Disconnect()
							releaseconnection:Disconnect()
							IsSliderHolding = false
							ScrollingFrameParent.ScrollingEnabled = true

							Config.WindUI.CurrentInput = nil

							if Config.Window.NewElements then
								Tween(Slider.UIElements.SliderIcon.Frame.Thumb, 0.2, {
									ImageTransparency = 0,
									Size = UDim2.new(
										0,
										Config.Window.NewElements and (Slider.ThumbSize * 2) or (Slider.ThumbSize + 2),
										0,
										Config.Window.NewElements and (Slider.ThumbSize + 4) or (Slider.ThumbSize + 2)
									),
								}, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut):Play()
							end
							if Tooltip then
								Tooltip:Close(false)
							end
						end
					end)
				else
					Value = math.clamp(Value, minVal, maxVal)

					local delta = math.clamp(
						(Value - minVal) / (maxVal - minVal),
						0,
						1
					)
					Value = CalculateValue(minVal + delta * (maxVal - minVal))

					if Value ~= LastValue then
						Slider.UIElements.SliderIcon.Frame.Size = UDim2.new(delta, 0, 1, 0)
						Slider.UIElements.SliderContainer.TextBox.Text = FormatValue(Value)
						if Tooltip then
							Tooltip.TitleFrame.Text = FormatValue(Value)
						end
						Slider.Value.Default = FormatValue(Value)
						LastValue = Value
						Creator.SafeCallback(Slider.Callback, FormatValue(Value))
					end
				end
			end
		end
	end

	function Slider:SetMax(newMax)
		newMax = newMax or 100
		Slider.Value.Max = newMax
		if Slider.Value.Min == nil then Slider.Value.Min = 0 end

		local currentValue = tonumber(Slider.Value.Default) or LastValue
		if currentValue > newMax then
			Slider:Set(newMax)
		else
			local newDelta =
				math.clamp((currentValue - (Slider.Value.Min or 0)) / (newMax - (Slider.Value.Min or 0)), 0, 1)
			Tween(Slider.UIElements.SliderIcon.Frame, 0.1, { Size = UDim2.new(newDelta, 0, 1, 0) }):Play()
		end
	end

	function Slider:SetMin(newMin)
		newMin = newMin or 0
		Slider.Value.Min = newMin
		if Slider.Value.Max == nil then Slider.Value.Max = 100 end

		local currentValue = tonumber(Slider.Value.Default) or LastValue
		if currentValue < newMin then
			Slider:Set(newMin)
		else
			local newDelta = math.clamp((currentValue - newMin) / ((Slider.Value.Max or 100) - newMin), 0, 1)
			Tween(Slider.UIElements.SliderIcon.Frame, 0.1, { Size = UDim2.new(newDelta, 0, 1, 0) }):Play()
		end
	end

	Creator.AddSignal(Slider.UIElements.SliderContainer.TextBox.FocusLost, function(enterPressed)
    local input = Slider.UIElements.SliderContainer.TextBox.Text:gsub(",", ".")  -- normalize comma to dot
    local newValue = tonumber(input)
    if newValue then
        -- Clamp to min/max and quantize according to Step
        local minVal = Slider.Value.Min or 0
        local maxVal = Slider.Value.Max or 100
        newValue = math.clamp(newValue, minVal, maxVal)
        Slider:Set(newValue)
    else
        -- Revert to last valid value
        Slider.UIElements.SliderContainer.TextBox.Text = FormatValue(LastValue)
        if Tooltip then
            Tooltip.TitleFrame.Text = FormatValue(LastValue)
        end
    end
end)

	
local function AnimateIcon(iconInstance, newIconString, speed)
    if not iconInstance then return end
    
    local resolved = IconDatabase.Resolve(newIconString)
    if not resolved then return end
    
    -- Fade out
    local fadeOut = TweenService:Create(iconInstance, TweenInfo.new(speed or 0.15), {
        ImageTransparency = 1,
        TextTransparency = 1,
    })
    fadeOut:Play()
    fadeOut.Completed:Wait()
    
    -- Update icon
    if resolved.Type == "font" then
        iconInstance.FontFace = Font.new(resolved.Path)
        iconInstance.Text = resolved.Icon
        iconInstance.TextTransparency = 0
        iconInstance.ImageTransparency = 1
    else
        iconInstance.Image = resolved.AssetId
        iconInstance.ImageTransparency = 0
        iconInstance.TextTransparency = 1
    end
    
    -- Fade in
    local fadeIn = TweenService:Create(iconInstance, TweenInfo.new(speed or 0.15), {
        ImageTransparency = 0,
        TextTransparency = 0,
    })
    fadeIn:Play()
end

-- Get icon based on slider value
local function GetIconForValue(value, min, max, fromIcon, toIcon)
    local percent = (value - min) / (max - min)
    
    -- If from and to are the same or no icons, return nil
    if not fromIcon or not toIcon or fromIcon == toIcon then
        return nil
    end
    
    -- Simple threshold: switch at 50%
    if percent < 0.5 then
        return fromIcon
    else
        return toIcon
    end
	end
	local CurInput = Config.WindUI.GenerateGUID()

	Creator.AddSignal(Slider.UIElements.SliderContainer.InputBegan, function(input)
		if Slider.Locked or IsSliderHolding then
			return
		end
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if Config.WindUI.CurrentInput and Config.WindUI.CurrentInput ~= CurInput then
				return
			end
			Config.WindUI.CurrentInput = CurInput

			Slider:Set(Value, input)

			if Config.Window.NewElements then
				Tween(Slider.UIElements.SliderIcon.Frame.Thumb, 0.24, {
					ImageTransparency = 0.85,
					Size = UDim2.new(
						0,
						(Config.Window.NewElements and (Slider.ThumbSize * 2) or Slider.ThumbSize) + 8,
						0,
						Slider.ThumbSize + 8
					),
				}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			end
			if Tooltip then
				Tooltip:Open()
			end
		end
	end)

	return Slider.__type, Slider
end

return Element
