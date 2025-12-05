local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

-- Settings
local holdDuration = 3 -- how long to hold E
local teleportDelay = 1.1 -- equal delay between teleports
local cycleDelay = 480 -- 8 minutes in seconds
local running = false -- controlled by Rayfield toggle

-- Training hitboxes
local btTrain = workspace.Main.TrainingAreasHitBoxes.BT["1No"]
local fsTrain = workspace.Main.TrainingAreasHitBoxes.FS["1No"]
local psTrain = workspace.Main.TrainingAreasHitBoxes.PS["1No"]

-- Default return area
local returnArea = psTrain

-- Guard function that can dynamically sink or pass E key press inputs
local function blockE(actionName, inputState, inputObject)
    if running then
        -- Swallow the input completely so the game ignores your manual E press
        return Enum.ContextActionResult.Sink
    end
    -- Otherwise let E behave normally
    return Enum.ContextActionResult.Pass
end

-- Initial bind, does not need to be unbinded!! 
ContextActionService:BindAction("BlockE", blockE, false, Enum.KeyCode.E)

-- Function to simulate holding E
local function Press()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
end

-- Function to simulate releasing E
local function releaseE()
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Full cycle here for hold and release
local function holdE(seconds)
    pressE()
    task.wait(seconds)
    releaseE()
end

-- Teleport to true centre function
local function returnToArea(area)
    if area and area:IsA("BasePart") then
        humanoidRootPart.CFrame = CFrame.new(area.Position)
    end
end

-- Guard against manual E presses while automation is running
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if running and input.KeyCode == Enum.KeyCode.E then
        -- Block your own E keypress so it doesn't interfere
        return
    end
end)

-- Main loop
task.spawn(function()
    while true do
        if running then
            -- Run through all present spawns once
            for _, spawn in ipairs(workspace.ChristmasEventMap.PresentSpawns:GetChildren()) do
                humanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.25)
                holdE(3) -- 3s
                task.wait(teleportDelay)
            end

            -- Return to selected training area
            returnToArea(returnArea)

            -- Wait until next cycle (10 minutes)
            task.wait(cycleDelay)
        else
            task.wait(0.5) -- idle check
        end
    end
end)

-- Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Auto presents",
    LoadingTitle = "Auto Presents",
    LoadingSubtitle = "by MisterWaffles :3",
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateToggle({
    Name = "Auto Presents",
    CurrentValue = false,
    Flag = "AutoPresents",
    Callback = function(Value)
        running = Value
    end,
})

Tab:CreateDropdown({
    Name = "Return Area (1No)",
    Options = {"BT","FS","PS"},
    CurrentOption = "PS",
    Flag = "ReturnArea",
    Callback = function(Option)
        if Option == "BT" then
            returnArea = btTrain
        elseif Option == "FS" then
            returnArea = fsTrain
        elseif Option == "PS" then
            returnArea = psTrain
        end
    end,
})
