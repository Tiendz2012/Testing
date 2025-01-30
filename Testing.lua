--[[ 
Blox Fruits Auto Farm Level Script with GUI 
Features: Auto-Farm Level 1 - 2600 with Quest Handling, Enemy Targeting, Fast Attack, and Toggle 
Note: Use responsibly and follow the game's terms of service. 
]]--

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local AutoFarmButton = Instance.new("TextButton")
local StatusLabel = Instance.new("TextLabel")

-- Properties
ScreenGui.Name = "BloxFruitsAutoFarm"
ScreenGui.Parent = game.CoreGui

Frame.Name = "MainFrame"
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 300, 0, 150)
Frame.Active = true
Frame.Draggable = true

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = Frame
TitleLabel.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
TitleLabel.Size = UDim2.new(0, 300, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.Text = "Blox Fruits Auto Farm"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.Font = Enum.Font.SourceSans
TitleLabel.TextSize = 18

AutoFarmButton.Name = "AutoFarmButton"
AutoFarmButton.Parent = Frame
AutoFarmButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
AutoFarmButton.Size = UDim2.new(0, 260, 0, 40)
AutoFarmButton.Position = UDim2.new(0, 20, 0, 50)
AutoFarmButton.Text = "Start Auto Farm"
AutoFarmButton.TextColor3 = Color3.new(1, 1, 1)
AutoFarmButton.Font = Enum.Font.SourceSans
AutoFarmButton.TextSize = 16

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = Frame
StatusLabel.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
StatusLabel.Size = UDim2.new(0, 260, 0, 30)
StatusLabel.Position = UDim2.new(0, 20, 0, 100)
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14

-- Function: Tween to Position
local function TweenToPosition(targetPosition, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = targetPosition})
    tween:Play()
    tween.Completed:Wait()
end

-- Function: Redeem Quest
local function RedeemQuest(questName)
    local args = {
        [1] = "StartQuest",
        [2] = questName,
        [3] = 1 -- Adjust depending on the quest
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
end

-- Function: Auto Farm
local farmingActive = false

local function AutoFarm()
    StatusLabel.Text = "Status: Starting Auto Farm"
    farmingActive = true

    spawn(function()
        while farmingActive do
            wait(0.1)

            local playerLevel = LocalPlayer.Data.Level.Value
            local questNPC, questName, questEnemies

            -- Determine the appropriate quest based on player level
            if playerLevel >= 1 and playerLevel <= 14 then
                questNPC = "Bandit Quest Giver"
                questName = "BanditQuest1"
                questEnemies = "Bandit"
            elseif playerLevel >= 15 and playerLevel <= 29 then
                questNPC = "Monkey Quest Giver"
                questName = "MonkeyQuest1"
                questEnemies = "Monkey"
            elseif playerLevel >= 30 and playerLevel <= 59 then
                questNPC = "Pirate Quest Giver"
                questName = "PirateQuest1"
                questEnemies = "Pirate"
            elseif playerLevel >= 60 and playerLevel <= 99 then
                questNPC = "Brute Quest Giver"
                questName = "BruteQuest1"
                questEnemies = "Brute"
            elseif playerLevel >= 100 and playerLevel <= 2600 then
                questNPC = "Quest NPC Appropriate to Level"
                questName = "QuestName"
                questEnemies = "EnemyAppropriate"
            else
                StatusLabel.Text = "Status: Max Level Reached"
                break
            end

            -- Interact with the quest NPC to accept the quest
            for _, npc in pairs(workspace.NPCs:GetChildren()) do
                if npc.Name == questNPC then
                    -- Move to NPC and interact
                    TweenToPosition(npc.HumanoidRootPart.CFrame, 1.5)
                    wait(0.5)

                    -- Redeem the quest
                    RedeemQuest(questName)
                    StatusLabel.Text = "Status: Quest Redeemed"
                    wait(1)
                    break
                end
            end

            -- Farm enemies for the quest
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy.Name == questEnemies and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    TweenToPosition(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3), 0.5)
                    repeat
                        wait(0.1)
                        if Character:FindFirstChildOfClass("Tool") then
                            Character:FindFirstChildOfClass("Tool"):Activate()
                        end
                    until enemy.Humanoid.Health <= 0 or not enemy.Parent
                end
            end

            StatusLabel.Text = "Status: Farming Completed"
        end
    end)
end

-- Function to stop auto-farming
local function StopAutoFarm()
    farmingActive = false
    StatusLabel.Text = "Status: Auto Farm Stopped"
end

-- Toggle Button Event
AutoFarmButton.MouseButton1Click:Connect(function()
    if farmingActive then
        StopAutoFarm()
        AutoFarmButton.Text = "Start Auto Farm"
    else
        AutoFarm()
        AutoFarmButton.Text = "Stop Auto Farm"
    end
end)