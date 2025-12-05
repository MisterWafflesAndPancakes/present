local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Settings
local holdDuration = 2.8 -- how long to hold E
local teleportDelay = 4 -- equal delay between teleports
local cycleDelay = 600 -- 10 minutes in seconds
local running = false -- controlled by Rayfield toggle

-- Training hitboxes
local btTrain = workspace.Main.TrainingAreasHitBoxes.BT["1No"]
local fsTrain = workspace.Main.TrainingAreasHitBoxes.FS["1No"]
local psTrain = workspace.Main.TrainingAreasHitBoxes.PS["1No"]

-- Default return area
local returnArea = psTrain

-- Function to simulate holding E
local function holdE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(holdDuration)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Teleports to true centre
local function returnToArea(area)
    if area and area:IsA("BasePart") then
        humanoidRootPart.CFrame = CFrame.new(area.Position)
    end
end


-- Main loop
task.spawn(function()
    while true do
        if running then
            -- Run through all present spawns once
            for _, spawn in ipairs(workspace.ChristmasEventMap.PresentSpawns:GetChildren()) do
                humanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
                holdE()
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
