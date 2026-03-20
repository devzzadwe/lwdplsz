repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("PlayerGui") and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local Folder = workspace:FindFirstChild("NewFolder")
if not Folder then
    Folder = Instance.new("Folder", workspace)
    Folder.Name = "NewFolder"
end

for i,v in next, workspace:GetChildren() do
    if v.Name:find("Island") or v.Name:find("Station") or v.Name:find("Mundo") then
        v.Parent = Folder
    end
end

local Service = {}
setmetatable(Service, {
    __index = function(_, key)
        local success, result = pcall(function()
            return cloneref(game:GetService(tostring(key)))
        end)
        return success and result or game:GetService(tostring(key))
    end
})
local CoreGui = Service.CoreGui
local Players = Service.Players
local UserInputService = Service.UserInputService
local Workspace = Service.Workspace
local HttpService = Service.HttpService
local ReplicatedStorage = Service.ReplicatedStorage
local RunService = Service.RunService
local VirtualUser = Service.VirtualUser
local VirtualInputManager = Service.VirtualInputManager
local TeleportService = Service.TeleportService
local GuiService = Service.GuiService
local TweenService = Service.TweenService
local LocalPlayer = Players.LocalPlayer
local Char = LocalPlayer.Character
local LocalUserId = LocalPlayer.UserId
local TeleportToPortal_Event = ReplicatedStorage.Remotes.TeleportToPortal
local TraitConfig = require(ReplicatedStorage.Modules.TraitConfig)
local ClanConfig = require(ReplicatedStorage.Modules.ClanConfig)
local RaceConfig = require(ReplicatedStorage.Modules.RaceConfig)
local Clanlist = {}
local traitlist = {}
local racelist = {}
local Weapon = {}
local Tween = nil
GuiService:SetGameplayPausedNotificationEnabled(false)
local questConfigModule = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("QuestConfig")
local QuestConfig = require(questConfigModule)
local NPCFolder = workspace:WaitForChild("NPCs")

local Islandlist = {"SoulSociety","Dungeon","StarterIsland","BossIsland","JungleIsland","SnowIsland","DesertIsland","Shibuya","HuecoMundo","SailorIsland","ValentineIsland","Judgement","SlimeIsland","ShinjukuIsland","AcademyIsland"}
local code = {"UPD5","7.5KFOLLOWTY","10KFOLLOWTY","12.5KFOLLOWTY","ROGUE","30KCCU","25KCCU","TYFOR10KCCU","SORRYFORMOREISSUES","UPD4.5","GILGAGOAT","5KFOLLOWAGAINTY","HUGEUPDATESOONFR","VALENTINEEVENT","BIGUPDATEFR","UPD4"}

local WeaponGroups = {
    ["Combat"] = { "Combat", "Gojo", "Sukuna", "Qin Shi", "Yuji", "Strongest Of Today", "Strongest In History", "Alucard", "Madoka", "Gilgamesh", "Anos" },
    ["Sword"] = { "Katana", "Dark Blade", "Ragna", "Saber", "Jinwoo", "Aizen", "Shadow", "Ichigo", "Rimuru", "Shadow Monarch", "Escanor" }
}

ReplicatedStorage.RemoteEvents.GetPlayerStats:InvokeServer()
ReplicatedStorage.RemoteEvents.GetSkillTreeData:InvokeServer()

local EqData
local wolrd = nil
local WeaponDropdown
local BlessDropdown
if game.PlaceId == 77747658251236 then
    wolrd = true
end

if wolrd then
    EqData = require(ReplicatedStorage.Backups.WeaponClassification_v1_BEFORE_POWER_INVENTORY)
else
    EqData = require(ReplicatedStorage.Modules.WeaponClassification)
end

for i,v in next, ClanConfig.Clans do
    if v.rarity == "Legendary" then
        Clanlist[#Clanlist+1] = i
    end
end

for i,v in next, RaceConfig.Races do
    if v.rarity == "Mythical" then
        racelist[#racelist+1] = i
    end
end

racelist[#racelist+1] = "Shadowborn"

for i,v in next, TraitConfig.Traits do
    if v.Rarity == "Secret" then
        traitlist[#traitlist+1] = i
    end
end

local Summonconfig = require(ReplicatedStorage.Modules.SummonableBossConfig)
local SummonBossList = {}
for i, v in next, Summonconfig.Bosses do
    SummonBossList[#SummonBossList+1] = (v.displayName:gsub("%s+", ""))
end

local bossconfig = require(ReplicatedStorage.Modules.BossConfig)
local BossList = {}
for i, v in next, bossconfig.Bosses do
    BossList[#BossList+1] = (v.displayName:gsub("%s+", ""))
end


local Dungeonconfig = require(ReplicatedStorage.Modules.DungeonConfig)
local DungeonList = {}
for i, v in next, Dungeonconfig.Dungeons do
    DungeonList[#DungeonList+1] = (v.DisplayName:gsub("%s+", ""))
end
if not task then
    task = {}
    task.wait = wait
    task.spawn = function(f) coroutine.wrap(f)() end
    task.delay = function(t,f)
        delay(t,f)
    end
end

local function RefreshWeapon()
    table.clear(Weapon)
    for _, V in next, {LocalPlayer.Backpack, LocalPlayer.Character} do
        for _, tool in next, V:GetChildren() do
            if tool:IsA("Tool") then
                Weapon[#Weapon+1] = tool.Name
            end
        end
    end
    if BlessDropdown then
        BlessDropdown:SetValues(Weapon)
    end
end

Config = {}

local Ex_Function = {}

local SaveFolder = "Sailor piece"
local SaveFile = SaveFolder .. "/Config.json"

pcall(function()
    CoreGui:FindFirstChild("WindowToggle"):Destroy()
end)

local Func = {}
Func.__index = Func

local SetFunc = setmetatable({}, Func)

local interactduplicated = false

local function EquipWeapon()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
            if v:IsA("Tool") then
                local Type = EqData.GetToolStatType(v.Name)
                if Type == Config["Select Weapon"] or v.Name == "Gryphon" then
                    LocalPlayer.Character.Humanoid:EquipTool(v)
                end
            end
        end
    end 
end

for _, connection in next, getconnections(LocalPlayer.Idled) do
    connection:Disable()
end 

function ClickGui(path)
    if interactduplicated then return end
    interactduplicated = true
    xpcall(function()
        if typeof(path) ~= "Instance" or not path:IsA("GuiObject") then
            interactduplicated = false
            return
        end
        repeat
            task.wait()
            GuiService.SelectedObject = path
        until GuiService.SelectedObject == path or not path:IsDescendantOf(game)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        repeat
            task.wait()
            GuiService.SelectedObject = nil
        until GuiService.SelectedObject == nil
        interactduplicated = false
    end, function(err)
        warn("ClickGui Error:", err)
        interactduplicated = false
    end)
end

function SendKey(Key)
    VirtualInputManager:SendKeyEvent(true, Key, false, game)
    VirtualInputManager:SendKeyEvent(false, Key, false, game)
end


function PV(cf)
    local Root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Root then
        Root:PivotTo(cf)
    end
end

local function EncodeCFrame(cf)
    local posX, posY, posZ = cf.Position.X, cf.Position.Y, cf.Position.Z
    local rotX, rotY, rotZ = cf:ToOrientation()
    return {X = posX, Y = posY, Z = posZ, RX = rotX, RY = rotY, RZ = rotZ}
end


local function DecodeCFrame(data)
    if typeof(data) == "table" and data.X and data.Y and data.Z and data.RX and data.RY and data.RZ then
        return CFrame.new(data.X, data.Y, data.Z) * CFrame.Angles(data.RX, data.RY, data.RZ)
    end
    return nil
end

function GetCustomIcon()
    if not (readfile and writefile and isfile and isfolder and makefolder and getcustomasset) then
        return false, warn("Executor Not Support Save System")
    end
    if not isfolder(SaveFolder) then
        makefolder(SaveFolder)
    end
    if not isfile(SaveFolder .. "/Icon.png") then
        return false, warn("Not Found Icon.png")
    end
    return getcustomasset(SaveFolder .. "/Icon.png")
end

function LoadSettings()
    if not (readfile and writefile and isfile and isfolder and makefolder) then
        return warn("Executor Not Support Save System")
    end
    if not isfolder(SaveFolder) then
        makefolder(SaveFolder)
    end
    if not isfile(SaveFile) then
        SaveSettings()
        return
    end
    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(SaveFile))
    end)
    if success and type(data) == "table" then
        for key, value in next, data do
            if key == "Save Position" then
                Config[key] = DecodeCFrame(value) or value
            elseif type(value) == "table" then
                local arr = {}
                for _, v in next, value do
                    arr[#arr+1] = tostring(v)
                end
                Config[key] = arr
            else
                Config[key] = value
            end
        end
    else
        warn("Failed to load config file")
    end
end

function SaveSettings()
    if not (readfile and writefile and isfile and isfolder and makefolder) then
        return warn("Executor Not Support Save System")
    end
    local saveData = {}
    for key, value in next, Config do
        if typeof(value) == "CFrame" then
            saveData[key] = EncodeCFrame(value)
        else
            saveData[key] = value
        end
    end
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(saveData)
    end)
    if success and encoded then
        if not isfile(SaveFile) or readfile(SaveFile) ~= encoded then
            writefile(SaveFile, encoded)
        end
    end
end

LoadSettings()

local function AddToggle(where, data)
    local defaultValue = Config[data.Title]
    if defaultValue == nil then
        defaultValue = data.Default or false
        Config[data.Title] = defaultValue
    end
    local toggle = where:AddToggle(data.Title, {
        Title = data.Title,
        Description = data.Desc or "",
        Default = defaultValue,
        Flag = data.Title
    })
    local threadRunning
    toggle:OnChanged(function(state)
        Config[data.Title] = state
        local fn = Ex_Function[data.Title]
        if fn then
            if state then
                threadRunning = task.spawn(fn)
            elseif threadRunning then
                task.cancel(threadRunning)
                threadRunning = nil
            end
        end
        if data.Callback then
            data.Callback(state)
        end
        SaveSettings()
    end)
    return toggle
end

function AddDropdown(where, data)
    local savedVal = Config[data.Title]
    if data.Multi then
        if type(savedVal) == "table" then
            local dict = {}
            for _, v in next, savedVal do
                dict[tostring(v)] = true
            end
            data.Default = dict
        else
            data.Default = {}
        end
    else
        data.Default = type(savedVal) == "string" and savedVal or ""
    end

    local dropdown = where:AddDropdown(data.Title, {
        Title = data.Title,
        Description = data.Desc or "",
        Values = data.Values or {},
        Multi = data.Multi or false,
        Default = data.Default,
        Flag = data.Title
    })
    dropdown:OnChanged(function(value)
        if data.Multi and typeof(value) == "table" then
            local arr = {}
            for k, v in next, value do
                if v then arr[#arr+1] = k end
            end
            value = arr
        end
        Config[data.Title] = value
        if data.Callback then data.Callback(value) end
        SaveSettings()
    end)
    return dropdown
end

function AddSlider(where, data)
    data.Min = data.Min or 0
    data.Max = data.Max or 100
    data.Rounding = data.Rounding or 0

    local flag = data.Flag or data.Title
    data.Default = Config[flag] or data.Default or data.Min

    local slider = where:AddSlider(data.Title, {
        Title = data.Title,
        Description = data.Desc or data.Description or "",
        Default = data.Default,
        Min = data.Min,
        Max = data.Max,
        Rounding = data.Rounding,
        Compact = true,
        DisplayMethod = "Value",
        Flag = flag
    })

    slider:OnChanged(function(value)
        Config[flag] = value
        if data.Callback then
            data.Callback(value)
        end
        SaveSettings()
    end)

    return slider
end

function AddTextbox(where, data)
    data.Default = Config[data.Title] or data.Default or ""
    local textbox = where:AddInput(data.Title, {
        Title = data.Title,
        Description = data.Desc or "",
        Placeholder = data.Placeholder or "",
        Default = data.Default,
        Flag = data.Title
    })
    textbox:OnChanged(function(text)
        Config[data.Title] = text
        if data.Callback then data.Callback(text) end
        SaveSettings()
    end)
    return textbox
end

MobList = {}
local added = {}

for _, v in ipairs(NPCFolder:GetChildren()) do
    if v:IsA("Model") then
        local baseName = v.Name:match("^(%D+)") 
        
        if baseName and not added[baseName] then
            added[baseName] = true
            table.insert(MobList, baseName)
        end
    end
end

local function UpdateLevel()
    local Level = LocalPlayer.Data.Level.Value
    local BestQuest = nil
    local BestLevel = -math.huge
    for npcName, questData in pairs(QuestConfig.RepeatableQuests) do
        local recLevel = questData.recommendedLevel
        if recLevel and recLevel <= Level and recLevel > BestLevel then
            BestLevel = recLevel
            BestQuest = {
                NPC = npcName,
                Data = questData,
                Level = recLevel
            }
        end
    end
    return BestQuest
end

local TweenConnection = nil

function TW(CF)
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    if Tween then
        Tween:Cancel()
        Tween = nil
    end
    if TweenConnection then
        TweenConnection:Disconnect()
        TweenConnection = nil
    end

    local Distance = (CF.Position - HRP.Position).Magnitude
    if Distance < 0.5 then
        HRP.CFrame = CF
        return
    end

    HRP.Anchored = false
    LocalPlayer.Character.Humanoid.WalkSpeed = 0

    local tweenInfo = TweenInfo.new(Distance / 140, Enum.EasingStyle.Linear)
    Tween = TweenService:Create(HRP, tweenInfo, {CFrame = CFrame.new(CF.Position)})
    Tween:Play()

    TweenConnection = Tween.Completed:Connect(function(playbackState)
        if playbackState == Enum.PlaybackState.Completed then
            HRP.CFrame = CF
        end
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
        Tween = nil
        TweenConnection:Disconnect()
        TweenConnection = nil
    end)
end

function StopTW()
    if Tween then
        Tween:Cancel()
        Tween = nil
    end
    if TweenConnection then
        TweenConnection:Disconnect()
        TweenConnection = nil
    end
    local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if HRP then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end



function TPboss(CF)
    if LocalPlayer:DistanceFromCharacter(CF.Position) <= 1200 then
        TW(CF)
    else
        local nearest, di = nil, math.huge
        for _,v in next, Folder:GetChildren() do
            if v:IsA("Folder") then
                for _,v2 in next, v:GetChildren() do
                    if v2:IsA("Model") and string.find(v2.Name,"SpawnPointCrystal") then
                        local dist = (CF.Position - v2:GetPivot().Position).Magnitude
                        if dist < di then
                            di = dist
                            nearest = v2
                        end
                    end
                end
            end
        end
        if nearest then
            local IslandName = nearest.Name:gsub("SpawnPointCrystal_", "")
            ReplicatedStorage.Remotes.TeleportToPortal:FireServer(IslandName)
            task.wait(0.5)
        end
    end
end

function TP(CF)
    if LocalPlayer:DistanceFromCharacter(CF.Position) < 600 then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CF
    else
        local nearest, di = nil, math.huge
        for _,v in next, Folder:GetChildren() do
            if v:IsA("Folder") then
                for _,v2 in next, v:GetChildren() do
                    if v2:IsA("Model") and string.find(v2.Name,"SpawnPointCrystal") then
                        local dist = (CF.Position - v2:GetPivot().Position).Magnitude
                        if dist < di then
                            di = dist
                            nearest = v2
                        end
                    end
                end
            end
        end
        if nearest then
            local IslandName = nearest.Name:gsub("SpawnPointCrystal_", "")
            ReplicatedStorage.Remotes.TeleportToPortal:FireServer(IslandName)
            task.wait(0.5)
        end
    end
end

local function CollectHogyoku()
    for i,v in pairs(workspace:GetChildren()) do
        if v.Name:find("HogyokuFragment") then
            local prompt = v:FindFirstChild("HogyokuCollectPrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end
end

local function CollectDungeonPiece()
    for _, v in next, workspace.NewFolder:GetChildren() do
        if not v:IsA("Folder") then continue end
        local piece = v:FindFirstChild("DungeonPuzzlePiece")
        if piece then
            local prompt = piece:FindFirstChild("PuzzlePrompt")
            if prompt then
                fireproximityprompt(prompt)
            end
        end
    end
end
------------------------------------------------------------------------------------------------------------
Ex_Function["Delete Island"] = function()
    while Config["Delete Island"] and task.wait() do
        pcall(function()
            for _,v in ipairs(Folder:GetChildren()) do
                if v:IsA("Folder") then
                    for _,v1 in ipairs(v:GetChildren()) do
                        if not string.find(v1.Name,"SpawnPointCrystal") and v1.Name ~= "HogyokuQuestNPC" then
                            v1:Destroy()
                        end
                    end
                end
            end
            for _,v in ipairs(workspace:GetChildren()) do
                if v.Name == "Model" or v.Name == "Npc Circle" or v.Name == "TimedBossSpawn_AizenBoss_container" or v.Name == "Trees" or v:IsA("Part") then
                    v:Destroy()
                end
            end
            if LocalPlayer and LocalPlayer.GameplayPaused then
                LocalPlayer.GameplayPaused = false
            end
        end)
    end
end
Ex_Function["Bypass Game Pauses"] = function()
    while Config["Bypass Game Pauses"] and task.wait() do
        local networkPause = CoreGui.RobloxGui:FindFirstChild("CoreScripts/NetworkPause")
        if networkPause then
            networkPause:Destroy()
        end
    end
end

Ex_Function["Auto Bless item"] = function()
    ReplicatedStorage.Remotes.GetBlessingData:InvokeServer(Config["Select Bless Weapon"])
    while Config["Auto Bless item"] and task.wait() do
        ReplicatedStorage.Remotes.BlessWeapon:FireServer(Config["Select Bless Weapon"])
    end
end


Ex_Function["Auto Spin Clan"] = function()
    local clanLabel = LocalPlayer.PlayerGui.StatsPanelUI.MainFrame.Frame.Content.SideFrame.UserStats.ClanEquipped.StatName
    while Config["Auto Spin Clan"] and task.wait(0.5) do
        local currentClan = clanLabel.Text:gsub("Clan: ", "")

        if currentClan == Config["Select Clan"] then
            break
        end
        ReplicatedStorage.Remotes.UseItem:FireServer("Use", "Clan Reroll", 10000, true)
    end
end

Ex_Function["Auto Spin Race"] = function()
    local raceLabel = LocalPlayer.PlayerGui.StatsPanelUI.MainFrame.Frame.Content.SideFrame.UserStats.RaceEquipped.StatName

    while Config["Auto Spin Race"] and task.wait(0.5) do
        local currentRace = raceLabel.Text:gsub("Race: ", "")
        local selected = Config["Select Race"]

        if selected and table.find(selected, currentRace) then
            break
        end

        ReplicatedStorage.Remotes.UseItem:FireServer("Use", "Race Reroll", 10000, true)
    end
end

local traitlist = {}
for i, v in next, TraitConfig.Traits do
    if v.Rarity == "Secret" then
        traitlist[#traitlist + 1] = i
    end
end

Ex_Function["Auto Spin trait"] = function()
    local traitLabel = LocalPlayer.PlayerGui.StatsPanelUI.MainFrame.Frame.Content.SideFrame.UserStats.TraitEquipped.StatName

    while Config["Auto Spin trait"] and task.wait() do
        local currentTrait = traitLabel.Text:gsub("Trait: ", "")
        local selected = Config["Select trait"]

        local isSelected = type(selected) == "table" and table.find(selected, currentTrait) ~= nil or currentTrait == selected
        if isSelected then
            break
        end

        ReplicatedStorage.RemoteEvents.TraitReroll:FireServer()
    end
end

Ex_Function["Auto upgrade Skill Tree"] = function()
    ReplicatedStorage.RemoteEvents.GetSkillTreeData:InvokeServer()
    while Config["Auto upgrade Skill Tree"] and task.wait() do
        local tree = Config["Select Skill Tree"]
        if not tree then return end
        for i = 1,10 do
            local skillName = tree .. "_" .. i
            task.wait(0.5)
            ReplicatedStorage.RemoteEvents.SkillTreeUpgrade:FireServer(skillName)
        end
    end
end


Ex_Function["Auto Use Finger"] = function()
    while Config["Auto Use Finger"] and task.wait(1) do
        ReplicatedStorage.Remotes.UseItem:FireServer("Use","Awakened Cursed Finger",1)
    end
end

Ex_Function["Auto Use Everything"] = function()
    while Config["Auto Use Everything"] and task.wait() do
        if LocalPlayer.PlayerGui.ConfirmUI.MainFrame.Visible then
            ClickGui(LocalPlayer.PlayerGui.ConfirmUI.MainFrame.ButtonsHolder.Yes)
        end
    end 
end

Ex_Function["Auto Craft Grail"] = function()
    while Config["Auto Craft Grail"] and task.wait() do
        ReplicatedStorage.Remotes.RequestGrailCraft:InvokeServer("DivineGrail",99)
    end
end

Ex_Function["Auto Farm Rimuru"] = function()
    while Config["Auto Farm Rimuru"] and task.wait() do
        local success, err = pcall(function()
            local difficulty = Config["Select Difficulty Rimuru"]

            if not difficulty then return end
            local baseName = "RimuruBoss_"

            local bossName = baseName .. difficulty
            local bossModel = NPCFolder:FindFirstChild(bossName)

            if bossModel then
                TP(bossModel:GetPivot() * CFrame.new(0,Config["Distance Farm"],0) * CFrame.Angles(math.rad(-90),0,0))
            else
                ReplicatedStorage.RemoteEvents.RequestSpawnRimuru:FireServer(Config["Select Difficulty Rimuru"])
            end
        end)
    end
end

Ex_Function["Auto Farm Aizen"] = function()
    while Config["Auto Farm Aizen"] and task.wait() do
        local success, err = pcall(function()
            local difficulty = Config["Select Difficulty Aizen"]

            if not difficulty then return end
            local baseName = "TrueAizenBoss_"

            local bossName = baseName .. difficulty
            local bossModel = NPCFolder:FindFirstChild(bossName)

            if bossModel then
                TP(bossModel:GetPivot() * CFrame.new(0,Config["Distance Farm"],0) * CFrame.Angles(math.rad(-90),0,0))
            else
                ReplicatedStorage.RemoteEvents.RequestSpawnTrueAizen:FireServer(Config["Select Difficulty Aizen"])
            end
        end)
    end
end

Ex_Function["Auto Craft Slime Key"] = function()
    while Config["Auto Craft Slime Key"] and task.wait() do
        ReplicatedStorage.Remotes.RequestSlimeCraft:InvokeServer("SlimeKey",99)
    end
end
Ex_Function["Auto Farm Boss Rush"] = function()
    while Config["Auto Farm Boss Rush"] and task.wait() do
        local success, err = pcall(function()
            if not wolrd and LocalPlayer.PlayerGui.DungeonUI.ContentFrame.Actions.EasyDifficultyFrame.Visible then
                ReplicatedStorage.Remotes.DungeonWaveVote:FireServer(Config["Select Difficulty Boss Rush"])
            end
            if not wolrd then
                for i,v in next, NPCFolder:GetChildren() do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        TW(v:GetPivot() * CFrame.new(0,Config["Distance Farm"],0) * CFrame.Angles(math.rad(-90),0,0))
                    end
                end
            end
        end)
    end
end

Ex_Function["Auto Join Boss Rush"] = function()
    while Config["Auto Join Boss Rush"] and task.wait() do
        if not LocalPlayer.PlayerGui.DungeonPortalJoinUI.LeaveButton.Visible and wolrd then
            ReplicatedStorage.Remotes.RequestDungeonPortal:FireServer(Config["Select Boss Rush"])
            task.wait(1)
        end 
    end
end

Ex_Function["Auto Replay"] = function()
    while Config["Auto Replay"] and task.wait() do
        if LocalPlayer.PlayerGui.DungeonUI.ReplayDungeonFrameVisibleOnlyWhenClearingDungeon.Visible  then
            ReplicatedStorage.Remotes.DungeonWaveReplayVote:FireServer("sponsor")
            task.wait(1)
        end
    end
end


Ex_Function["Auto Farm Dungeon"] = function()
    while Config["Auto Farm Dungeon"] and task.wait() do
        local success, err = pcall(function()
            if not wolrd and LocalPlayer.PlayerGui.DungeonUI.ContentFrame.Actions.EasyDifficultyFrame.Visible then
                ReplicatedStorage.Remotes.DungeonWaveVote:FireServer(Config["Select Difficulty Dungeon"])
            end 
            if not wolrd then
                for i,v in next, NPCFolder:GetChildren() do
                    if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        TW(v:GetPivot() * CFrame.new(0,Config["Distance Farm"],0) * CFrame.Angles(math.rad(-90),0,0))
                    end
                end
            end
        end)
    end
end

Ex_Function["Auto Join Dungeon"] = function()
    while Config["Auto Join Dungeon"] and task.wait() do
        if not LocalPlayer.PlayerGui.DungeonPortalJoinUI.LeaveButton.Visible and wolrd then
            ReplicatedStorage.Remotes.RequestDungeonPortal:FireServer(Config["Select Dungeon"])
            task.wait(1)
        end 
    end
end

Ex_Function["Auto Farm Wolrd Boss"] = function()
    while Config["Auto Farm Wolrd Boss"] and task.wait() do
        pcall(function()
            local selected = Config["Select Wolrd Boss"]
            if not selected or #selected == 0 then return end
            for _, v in next, NPCFolder:GetChildren() do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and table.find(selected, v.Name) then
                    repeat task.wait()
                        TP(v:GetPivot() * CFrame.new(0, Config["Distance Farm"], 0) * CFrame.Angles(math.rad(-90), 0, 0))
                    until v.Humanoid.Health <= 0 or not Config["Auto Farm Wolrd Boss"]
                end
            end
        end)
    end
end 

Ex_Function["Auto Dungeon Quest"] = function()
    local done = false
    while Config["Auto Dungeon Quest"] and task.wait() do
        pcall(function()
            local questui = LocalPlayer.PlayerGui.QuestUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
            local questrequirement = LocalPlayer.PlayerGui.QuestUI.Quest.Quest.Holder.Content.QuestInfo.QuestRequirement.Text

            if not LocalPlayer.PlayerGui.QuestUI.Quest.Visible or questui ~= "Dungeon Discovery" and questui ~= "Prove Your Strength" then
                TPboss(workspace.ServiceNPCs.DungeonPortalsNPC:GetPivot() * CFrame.new(0, 0, -3))
                local prompt = workspace.ServiceNPCs.DungeonPortalsNPC.HumanoidRootPart:FindFirstChild("DungeonNPCPrompt")
                if prompt then fireproximityprompt(prompt) end

            elseif string.find(questrequirement, "/6 Completed") then
                local positions = {
                    ["0/6 Completed"] = CFrame.new(87.46497344970703, 10.03686237335205, -138.07081604003906),
                    ["1/6 Completed"] = CFrame.new(-395.6279296875, 0.40371960401535034, 511.6241760253906),
                    ["2/6 Completed"] = CFrame.new(-1056.518798828125, 6.581114292144775, -305.04876708984375),
                    ["3/6 Completed"] = CFrame.new(-313.4259033203125, -1.1388468742370605, -1189.2462158203125),
                    ["4/6 Completed"] = CFrame.new(1716.766357421875, 139.93643188476562, -26.91476058959961),
                    ["5/6 Completed"] = CFrame.new(-688.0877685546875, 99.77131652832031, 1336.18115234375),
                }
                local target = positions[questrequirement]
                if target then
                    TW(target)
                    CollectDungeonPiece()
                end

            elseif questui == "Prove Your Strength" or string.find(questrequirement, "/25 Completed") then
                if NPCFolder:FindFirstChild("SaberBoss") then
                    for _, v in next, NPCFolder:GetChildren() do
                        if v.Name == "SaberBoss" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                            repeat task.wait()
                                TP(v:GetPivot() * CFrame.new(0, Config["Distance Farm"], 0) * CFrame.Angles(math.rad(-90), 0, 0))
                            until v.Humanoid.Health <= 0 or not Config["Auto Dungeon Quest"]
                        end
                    end
                else
                    ReplicatedStorage.Remotes.RequestSummonBoss:FireServer("SaberBoss")
                    task.wait(1)
                end
                done = true
            end
        end)
    end
end

Ex_Function["Quest SoulSociety Island"] = function()
    local done = false
    ReplicatedStorage.RemoteEvents.QuestAbandon:FireServer("HogyokuUnlock")
    while Config["Quest SoulSociety Island"] and task.wait() do
        local questui = LocalPlayer.PlayerGui.QuestUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text
        local questrequirement = LocalPlayer.PlayerGui.QuestUI.Quest.Quest.Holder.Content.QuestInfo.QuestRequirement.Text
        if not LocalPlayer.PlayerGui.QuestUI.Quest.Visible or questui ~= "Hogyoku Fragments" then
            TW(workspace.ServiceNPCs.HogyokuQuestNPC:GetPivot() * CFrame.new(0, 0, -3))
            task.wait(1)
            local prompt = workspace.ServiceNPCs.HogyokuQuestNPC:FindFirstChild("HogyokuQuestPrompt", true)
            if prompt then fireproximityprompt(prompt) end
        elseif questui == "Hogyoku Fragments" then
            local positions = {
                ["0/6 Completed"] = CFrame.new(-634.873046875, 25.230960845947266, 1205.6680908203125),
                ["1/6 Completed"] = CFrame.new(-425.7921142578125, 58.82389450073242, -1236.732421875),
                ["2/6 Completed"] = CFrame.new(1640.3404541015625, 87.5283203125, 247.1608428955078),
                ["3/6 Completed"] = CFrame.new(648.3509521484375, 140.04721069335938, -2064.03271484375),
                ["4/6 Completed"] = CFrame.new(-1204.71630859375, 33.14242935180664, 464.4945983886719),
                ["5/6 Completed"] = CFrame.new(-906.6015625, 19.32540512084961, -1259.5352783203125),
            }
            local target = positions[questrequirement]
            if target then
                TPboss(target)
                CollectHogyoku()
            end
            done = true
        end
    end
end

Ex_Function["Auto Haki Quest"] = function()
    while Config["Auto Haki Quest"] and task.wait() do
        pcall(function()
            local questVisible = LocalPlayer.PlayerGui.QuestUI.Quest.Visible
            local questui = questVisible and LocalPlayer.PlayerGui.QuestUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text or ""

            if not questVisible then
                -- ยังไม่มี quest → เดินไป NPC รับ quest
                TW(workspace.ServiceNPCs.HakiQuestNPC:GetPivot() * CFrame.new(0,0,-3))
                task.wait(1)
            ReplicatedStorage.RemoteEvents.QuestAccept:FireServer("HakiQuestNPC")
            elseif questui == "Path to Haki 1" then
                -- มี quest อยู่ → ไปตี Thief
            for i,v in next, NPCFolder:GetChildren() do
                    if v.Name == "Thief" and v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                TP(v:GetPivot() * CFrame.new(0,0,3))
                end
            end
        end
        end)
    end
end

Ex_Function["Auto Detect Players"] = function()
    while Config["Auto Detect Players"] and task.wait() do
        for _,v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer then
                LocalPlayer:Kick("อย่าอยู่เซิฟรวมไอกาก")
            end
        end
    end
end

Ex_Function["Auto Haki"] = function()
    while Config["Auto Haki"] and task.wait() do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Right Arm") and char:FindFirstChild("Left Arm")and (char["Right Arm"].Color ~= Color3.new(0,0,0) or char["Left Arm"].Color ~= Color3.new(0,0,0)) then
            ReplicatedStorage.RemoteEvents.HakiRemote:FireServer("Toggle")
            task.wait(2)
        end
    end
end

Ex_Function["Auto Farm Anos"] = function()
    while Config["Auto Farm Anos"] and task.wait() do
        local success, err = pcall(function()
            local difficulty = Config["Select Difficulty Anos"]

            if not difficulty then return end
            local baseName = "AnosBoss_"

            local bossName = baseName .. difficulty
            local bossModel = NPCFolder:FindFirstChild(bossName)

            if bossModel then
                TP(bossModel:GetPivot() * CFrame.new(0,Config["Distance Farm"],0) * CFrame.Angles(math.rad(-90),0,0))
            else
                ReplicatedStorage.Remotes.RequestSpawnAnosBoss:FireServer("Anos", difficulty)
            end

        end)
    end
end

Ex_Function["Auto Farm Strongest Boss"] = function()
    while Config["Auto Farm Strongest Boss"] and task.wait() do
        local success, err = pcall(function()

            local selectedBoss = Config["Select Strongest Boss"]
            local difficulty = Config["Select Difficulty"]

            if not selectedBoss or not difficulty then return end
            local baseName
            if selectedBoss == "StrongestHistory" then
                baseName = "StrongestinHistoryBoss_"
            elseif selectedBoss == "StrongestToday" then
                baseName = "StrongestofTodayBoss_"
            end

            local bossName = baseName .. difficulty
            local bossModel = NPCFolder:FindFirstChild(bossName)

            if bossModel then
                TPboss(bossModel:GetPivot() * CFrame.new(0,Config["Distance Farm"],0) * CFrame.Angles(math.rad(-90),0,0))
            else
                ReplicatedStorage.Remotes.RequestSpawnStrongestBoss:FireServer(selectedBoss, difficulty)
            end

        end)
    end
end 

Ex_Function["TP Strongest in History"] = function()
    while Config["TP Strongest in History"] and task.wait() do
        TPboss(workspace.ServiceNPCs.StrongestinHistoryBuyerNPC:GetPivot() * CFrame.new(0,0,-3))
    end
end

lastReturnedQuest = lastReturnedQuest or nil
Ex_Function["Auto Farm Level"] = function()
    while Config["Auto Farm Level"] and task.wait() do
        local success, err = pcall(function()
            local data = UpdateLevel()
            if not data then return end
            local questTitle = data.Data.title
            local mobName = data.Data.requirements[1].npcType
            local npcName = data.NPC
            local questui = LocalPlayer.PlayerGui.QuestUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle.Text

            if not LocalPlayer.PlayerGui.QuestUI.Quest.Visible then
                ReplicatedStorage.RemoteEvents.QuestAccept:FireServer(npcName)
                task.wait(1)
            elseif questui ~= questTitle then
                ReplicatedStorage.RemoteEvents.QuestAbandon:FireServer("repeatable")
                task.wait(2)
            elseif lastReturnedQuest and lastReturnedQuest ~= questTitle then
                ReplicatedStorage.RemoteEvents.QuestAbandon:FireServer("repeatable")
                task.wait(2)
            else
                local cleanMob = string.lower(mobName):gsub("warrior",""):gsub("hunter","")
                for _,v in pairs(NPCFolder:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        local npcNameLower = string.lower(v.Name):gsub("warrior",""):gsub("hunter","")

                        if npcNameLower == cleanMob then
                            repeat task.wait()
                                TW(v:GetPivot()* CFrame.new(0, Config["Distance Farm"], 0)* CFrame.Angles(math.rad(-90),0,0))
                            until v.Humanoid.Health <= 0 or not Config["Auto Farm Level"] 
                        end
                    end
                end
            end
            lastReturnedQuest = questTitle
        end)
        if not success then
            print(err)
        end
    end
end

Ex_Function["Auto Farm Select Boss"] = function()
    while Config["Auto Farm Select Boss"] and task.wait() do
        local sun, err = pcall(function()
            local selected = Config["Select Summon Boss"]
            if not selected then return end

            local bossName = selected .. "Boss"

            if NPCFolder:FindFirstChild(bossName) then
                for _, v in next, NPCFolder:GetChildren() do
                    if string.find(v.Name, bossName) == 1 and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                        TP(v:GetPivot() * CFrame.new(0, Config["Distance Farm"], 0) * CFrame.Angles(math.rad(-90), 0, 0))
                    end
                end
            elseif selected == "Gilgamesh" and not NPCFolder:FindFirstChild(bossName) then
                ReplicatedStorage.Remotes.RequestSummonBoss:FireServer(bossName,Config["Select Difficulty Boss"])
                task.wait()
            elseif not NPCFolder:FindFirstChild(bossName) then
                ReplicatedStorage.Remotes.RequestSummonBoss:FireServer(bossName)
                task.wait()
            end
        end)
    end
end

Ex_Function["Auto Farm Mob"] = function()
    while Config["Auto Farm Mob"] do task.wait()
        pcall(function()
            local selected = Config["Select Mob"]
            if not selected or #selected == 0 then return end
            for _, v in next, NPCFolder:GetChildren() do
                if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    local name = v.Name:gsub("%s*%d+%s*$", "")
                    if table.find(selected, name) then
                        repeat task.wait()
                            TW(v:GetPivot() * CFrame.new(0, Config["Distance Farm"], 0) * CFrame.Angles(math.rad(-90), 0, 0))
                        until not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0 or not Config["Auto Farm Mob"]
                    end
                end
            end
        end)
    end
end

-- (duplicate Ex_Function["Auto Farm Wolrd Boss"] removed — defined above at line ~830)

Ex_Function["Fast Attack"] = function() 
    while Config["Fast Attack"] and task.wait(0.05) do 
        ReplicatedStorage.CombatSystem.Remotes.RequestHit:FireServer()
    end   
end


Ex_Function["Auto Stats"] = function() 
    while Config["Auto Stats"] and task.wait(0.05) do 
        local selected = Config["Select Stats"]
        if not selected then return end
        for _, v in next, selected do
            ReplicatedStorage.RemoteEvents.AllocateStat:FireServer(v, 10)
            task.wait(0.1)
        end
    end   
end

Ex_Function["GODInwza Farm v2"] = function()
    while Config["GODInwza Farm v2"] and task.wait() do
        local sun, err = pcall(function()
            for i,v in next, NPCFolder:GetChildren() do
                if v:IsA("Model") and v.Name ~= "TrainingDummy" and v.Humanoid.Health > 0 then
                    repeat task.wait()
                        TP(v:GetPivot() *CFrame.new(0,0,5))
                    until not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0 or not Config["GODInwza Farm v2"]
                end
            end
        end)
    end
end

Ex_Function["GODInwza Farm"] = function()
    while Config["GODInwza Farm"] and task.wait() do
        local sun, err = pcall(function()
            for i,v in next, NPCFolder:GetChildren() do
                if v:IsA("Model") and v.Name ~= "TrainingDummy" and v.Humanoid.Health > 0 then
                    repeat task.wait()
                        TW(v:GetPivot() *CFrame.new(0,0,5))
                    until not v:FindFirstChild("Humanoid") or v.Humanoid.Health <= 0 or not Config["GODInwza Farm"]
                end
            end
        end)
    end
end

Ex_Function["Auto Skills"] = function()
    while Config["Auto Skills"] and task.wait(0.05) do
        local selected = Config["Select Skills"]
        if not selected then return end
        for _, v in next, selected do
            ReplicatedStorage.AbilitySystem.Remotes.RequestAbility:FireServer(tonumber(v))
        end
    end
end

Ex_Function["Auto Strongest in History"] = function()
    while Config["Auto Strongest in History"] and task.wait() do
        TW(workspace.ServiceNPCs.StrongestinHistoryBuyerNPC:GetPivot() * CFrame.new(0,0,-3))
    end
end

Ex_Function["Equip Weapon"] = function()
    while Config["Equip Weapon"] and task.wait() do
        pcall(function()
            EquipWeapon()
        end)
    end
end

local Library = loadstring(request({
    Url = "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    Method = "GET"
}).Body)()

local Window = Library:CreateWindow({
    Title = "[🗡️Alter Update🔥] Sailor Piece",
    SubTitle = "By x2punniez",
    TabWidth = 160,
    Size = UDim2.fromOffset(580,400),
    Theme = "Dark",
    Transparency = 0.85,
    FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
})

repeat task.wait() until Library and Library.GUI

local function Toggle()
    Window:Minimize()
end

local old = CoreGui:FindFirstChild("WindowToggle")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "WindowToggle"
gui.ResetOnSpawn = false

local btn = Instance.new("ImageButton", gui)
btn.AnchorPoint = Vector2.new(0.5,0)
btn.Position = UDim2.new(0.5,0,0,20)
btn.Size = UDim2.fromOffset(45,45)
btn.BackgroundTransparency = 0.5
btn.BorderSizePixel = 0
btn.Draggable = true
btn.Image = "rbxassetid://108559968423771"

Instance.new("UICorner",btn).CornerRadius = UDim.new(0.25,0)

btn.MouseButton1Click:Connect(Toggle)

UserInputService.InputBegan:Connect(function(i,g)
    if not g and i.KeyCode == Enum.KeyCode.LeftControl then
        Toggle()
    end
end)
------------------------------------------------------------------------------------------------------------
RefreshWeapon()

local Tabs = {
    Main = Window:AddTab({Title = "Main", Icon = "crown"}),
}

local WeaponSection = Tabs.Main:AddSection("Weapon")

AddSlider(WeaponSection, {
    Title = "Distance Farm",
    Min = 0,
    Max = 100,
    Rounding = 0,
    Default = 10,
    Callback = function(value)
    end
})


WeaponDropdown = AddDropdown(WeaponSection,{
    Title = "Select Weapon",
    Values = {"Melee","Sword","Power"},
    Multi = false,
    Callback = function(Value)
        Config["Weapon Type"] = Value
    end
})


AddToggle(WeaponSection, {
    Title = "Equip Weapon",
})

local SkillsSection = Tabs.Main:AddSection("Auto Skills")

AddDropdown(SkillsSection, {
    Title = "Select Skills",
    Desc = "",
    Values = {"1", "2", "3", "4"},
    Multi = true,
})

AddToggle(SkillsSection, {
    Title = "Fast Attack",
})

AddToggle(SkillsSection, {
    Title = "Auto Skills",
})

local StatsSection = Tabs.Main:AddSection("Stats")

AddDropdown(StatsSection, {
    Title = "Select Stats",
    Desc = "",
    Values = {"Melee", "Defense", "Sword", "Power"},
    Multi = true,
})

AddToggle(StatsSection, {
    Title = "Auto Stats",
})

Tabs.Main:AddButton({
    Title = "Restat Stats",
    Callback = function()
        ReplicatedStorage.RemoteEvents.ResetStats:FireServer()
    end
})

local haki = Tabs.Main:AddSection("Haki")

AddToggle(haki, {
    Title = "Auto Haki",
})

AddToggle(haki, {
    Title = "Auto Haki Quest",
})

local Tabs = {
    Farm = Window:AddTab({Title = "Automatic", Icon = "gamepad-2"}),
}

local Mob = Tabs.Farm:AddSection("Mob") 

AddDropdown(Mob, {
    Title = "Select Mob",
    Desc = "",
    Values = MobList,
    Multi = true
})

AddToggle(Mob, {
    Title = "Auto Farm Mob",
})

local Mob = Tabs.Farm:AddSection("GODInwza") 

AddToggle(Mob, {
    Title = "GODInwza Farm v2",
})

AddToggle(Mob, {
    Title = "GODInwza Farm",
    Callback = function()
        if tween then
            tween:Cancel()
        end
    end,
})

local level = Tabs.Farm:AddSection("Farm Level") 

AddToggle(level, {
    Title = "Auto Farm Level",
    Callback = function(state)
        if not state then 
            StopTW() 
        end
    end,
})

local Tabs = {
    Boss = Window:AddTab({Title = "Boss", Icon = "skull"}),
}
local Boss = Tabs.Boss:AddSection("Wolrd Boss") 

AddDropdown(Boss, {
    Title = "Select Wolrd Boss",
    Desc = "",
    Values = BossList,
    Multi = true
})

AddToggle(Boss, {
    Title = "Auto Farm Wolrd Boss",
})

local Boss = Tabs.Boss:AddSection("Select Summon Boss") 

AddDropdown(Boss, {
    Title = "Select Summon Boss",
    Desc = "",
    Values = SummonBossList,
    Multi = false
})
AddDropdown(Boss, {
    Title = "Select Difficulty Boss",
    Desc = "",
    Values = {"Normal","Medium","Hard","Extreme"},
    Multi = false
})

AddToggle(Boss, {
    Title = "Auto Craft Grail",
})

AddToggle(Boss, {
    Title = "Auto Farm Select Boss",
})

local Boss = Tabs.Boss:AddSection("Strongest Boss") 

AddDropdown(Boss, {
    Title = "Select Strongest Boss",
    Desc = "",
    Values = {"StrongestHistory","StrongestToday"},
    Multi = false
})

AddDropdown(Boss, {
    Title = "Select Difficulty",
    Desc = "",
    Values = {"Normal","Medium","Hard","Extreme"},
    Multi = false
})

AddToggle(Boss, {
    Title = "Auto Farm Strongest Boss",
    Callback = function(state)
        if not state then 
            StopTW() 
        end
    end,
})

local Anos = Tabs.Boss:AddSection("Anos Boss") 

AddDropdown(Anos, {
    Title = "Select Difficulty Anos",
    Desc = "",
    Values = {"Normal","Medium","Hard","Extreme"},
    Multi = false
})


AddToggle(Anos, {
    Title = "Auto Farm Anos",
})

local slime = Tabs.Boss:AddSection("Rimuru Boss") 

AddDropdown(slime, {
    Title = "Select Difficulty Rimuru",
    Desc = "",
    Values = {"Normal","Medium","Hard","Extreme"},
    Multi = false
})

AddToggle(slime, {
    Title = "Auto Farm Rimuru",
})

AddToggle(slime, {
    Title = "Auto Craft Slime Key",
})

local Aizen = Tabs.Boss:AddSection("Aizen Boss") 

AddDropdown(Aizen, {
    Title = "Select Difficulty Aizen",
    Desc = "",
    Values = {"Normal","Medium","Hard","Extreme"},
    Multi = false
})

AddToggle(Aizen, {
    Title = "Auto Farm Aizen",
})

local Tabs = {
    Dun = Window:AddTab({Title = "Dungeon", Icon = "swords"}),
}

local Duns = Tabs.Dun:AddSection("Quest Dungeon") 

AddToggle(Duns, {
    Title = "Auto Dungeon Quest",
    Callback = function(state)
        if not state then 
            StopTW() 
        end
    end,
})

local Duns = Tabs.Dun:AddSection("Farm Dungeon") 

AddDropdown(Duns, {
    Title = "Select Dungeon",
    Desc = "",
    Values = DungeonList,
    Multi = false
})

AddToggle(Duns, {
    Title = "Auto Join Dungeon",
})

local inDuns = Tabs.Dun:AddSection("In Dungeon")

AddDropdown(inDuns, {
    Title = "Select Difficulty Dungeon",
    Desc = "",
    Values = {"Easy","Medium","Hard","Extreme"},
    Multi = false
})

AddToggle(inDuns, {
    Title = "Auto Farm Dungeon",
})

AddToggle(inDuns, {
    Title = "Auto Replay",
})

local Tabs = {
    BS = Window:AddTab({Title = "BossRush", Icon = "bone"}),
}

local rush = Tabs.BS:AddSection("Boss Rush") 

AddDropdown(rush, {
    Title = "Select Boss Rush",
    Desc = "",
    Values = {"BossRush"},
    Multi = false
})

AddToggle(rush, {
    Title = "Auto Join Boss Rush",
})

local inrush = Tabs.BS:AddSection("In Boss Rush") 

AddDropdown(inrush, {
    Title = "Select Difficulty Boss Rush",
    Desc = "",
    Values = {"Easy","Medium","Hard","Extreme"},
    Multi = false
})

AddToggle(inrush, {
    Title = "Auto Farm Boss Rush",
})

AddToggle(inrush, {
    Title = "Auto Replay",
})

local Tabs = {
    General = Window:AddTab({Title = "General", Icon = "globe"}),
}

local trait = Tabs.General:AddSection("Trait") 

AddDropdown(trait, {
    Title = "Select trait",
    Desc = "",
    Values = traitlist,
    Multi = true
})
AddToggle(trait, {
    Title = "Auto Spin trait",
})

local Clan = Tabs.General:AddSection("Clan") 

AddDropdown(Clan, {
    Title = "Select Clan",
    Desc = "",
    Values = Clanlist,
    Multi = false
})
AddToggle(Clan, {
    Title = "Auto Spin Clan",
})

local race = Tabs.General:AddSection("Race") 

AddDropdown(race, {
    Title = "Select Race",
    Desc = "",
    Values = racelist,
    Multi = true
})
AddToggle(race, {
    Title = "Auto Spin Race",
})

local Bless = Tabs.General:AddSection("Bless item") 

BlessDropdown = AddDropdown(Bless, {
    Title = "Select Bless Weapon",
    Desc = "",
    Values = Weapon,
    Multi = false,
})

Tabs.General:AddButton({
    Title = "Refresh Weapon",
    Callback = function()
        RefreshWeapon()
    end
})

AddToggle(Bless, {
    Title = "Auto Bless item",
})

local Tabs = {
    TP = Window:AddTab({Title = "Teleport", Icon = "map-pin"}),
}

local Island = Tabs.TP:AddSection("Island") 

AddToggle(Island, {
    Title = "Quest SoulSociety Island",
    Callback = function(state)
        if not state then 
            StopTW() 
        end
    end,
})

AddDropdown(Island, {
    Title = "Select Island",
    Desc = "",
    Values = Islandlist,
    Multi = false
})

Tabs.TP:AddButton({ 
    Title = "Teleport Island",
    Callback = function()
        local selected = Config["Select Island"]
        if selected then
            local cleaned = selected:gsub("Island$", "")
            ReplicatedStorage.Remotes.TeleportToPortal:FireServer(cleaned)
        end
    end
})
local Tabs = {
    Misc = Window:AddTab({Title = "Misc", Icon = "settings"}),
}

local Performance = Tabs.Misc:AddSection("Performance") 

AddToggle(Performance, {
    Title = "Delete Island",
})

AddToggle(Performance, {
    Title = "Auto Detect Players",
})

AddToggle(Performance, {
    Title = "Bypass Game Pauses",
})

Tabs.Misc:AddButton({
    Title = "Boost Fps",
    Callback = function()
        local rs = game:GetService("RunService")
        local lighting = game:GetService("Lighting")
        getgenv()._BoostFPS = not getgenv()._BoostFPS
        if getgenv()._BoostFPS then
            pcall(function()
                rs:Set3dRenderingEnabled(false)
            end)
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            workspace.GlobalShadows = false
            lighting.FogEnd = 9e9
            for _,v in next, workspace:GetDescendants() do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
        else
            pcall(function()
                rs:Set3dRenderingEnabled(true)
            end)
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            workspace.GlobalShadows = true
        end
    end
})

local buy = Tabs.Misc:AddSection("Misc") 

Tabs.Misc:AddButton({
    Title = "Buy Katana",
    Callback = function()
        local npc = Workspace:FindFirstChild("ServiceNPCs") and Workspace.ServiceNPCs:FindFirstChild("Katana")
        pcall(function()
            if npc and npc:FindFirstChild("HumanoidRootPart") then
                TP(npc.HumanoidRootPart.CFrame * CFrame.new(0,0,-3))

                local prompt = npc.HumanoidRootPart:FindFirstChild("KatanaShopPrompt")
                if prompt then
                    prompt.HoldDuration = 0
                    SendKey("E")
                end
            end 
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "Buy Ichigo",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Remotes.ExchangeItem:InvokeServer("Ichigo")
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "TP Haki Quest",
    Callback = function()
        pcall(function()
            TP(workspace.ServiceNPCs.HakiQuestNPC:GetPivot() * CFrame.new(0,0,-3))
        end)
    end
})

AddToggle(buy, {
    Title = "TP Strongest in History",
    Callback = function(state)
        if not state then 
            StopTW() 
        end
    end,
})

local use = Tabs.Misc:AddSection("Use Everything") 

AddToggle(use, {
    Title = "Auto Use Everything",
})
AddToggle(use, {
    Title = "Auto Use Finger",
})

local tree = Tabs.Misc:AddSection("Skill Tree") 

AddDropdown(tree, {
    Title = "Select Skill Tree",
    Desc = "",
    Values = {"Luck","CritDmg","Damage","CritCh","HP"},
    Multi = false
})

AddToggle(tree, {
    Title = "Auto upgrade Skill Tree",
})

Tabs.Misc:AddButton({
    Title = "Unlock Artifact",
    Callback = function()
        ReplicatedStorage.RemoteEvents.ArtifactUnlockSystem:FireServer()
    end
})

Tabs.Misc:AddButton({
    Title = "Unlock Skill Tree",
    Callback = function()
        ReplicatedStorage.RemoteEvents.SkillTreeUnlock:FireServer()  
    end
})

task.spawn(function()
    while task.wait() do
        pcall(function()
            local FarmEnabled =
                Config["Auto Farm Strongest Boss"] or
                Config["Auto Farm Rimuru"] or
                Config["Auto Haki Quest"] or
                Config["Auto Farm Anos"] or
                Config["Auto Farm Boss Rush"] or
                Config["Auto Farm Dungeon"] or
                Config["Auto Farm Wolrd Boss"] or
                Config["Auto Farm Mob"] or
                Config["Auto Farm Select Boss"] or
                Config["GODInwza Farm"] or
                Config["GODInwza Farm v2"] or
                Config["Auto Farm Level"] or 
                Config["Auto Farm Aizen"] or 
                Config["Quest SoulSociety Island"] or
                Config["Auto Dungeon Quest"] or
                Config["TP Strongest in History"]

            local character = LocalPlayer.Character
            if not character then return end

            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            if FarmEnabled then

                if humanoid and humanoid.Sit then
                    humanoid.Sit = false
                end

                local bv = root:FindFirstChild("BodyVelocity1")
                if not bv then
                    bv = Instance.new("BodyVelocity")
                    bv.Name = "BodyVelocity1"
                    bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                    bv.Velocity = Vector3.zero
                    bv.Parent = root
                end

                root.Velocity = Vector3.zero

                for _,v in ipairs(character:GetChildren()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    elseif v:IsA("Accessory") then
                        local h = v:FindFirstChild("Handle")
                        if h then h.CanCollide = false end
                    end
                end

            else
                local bv = root:FindFirstChild("BodyVelocity1")
                if bv then
                    bv:Destroy()
                end
            end

        end)
    end
end)

task.defer(function()
    for key, value in pairs(Config) do
        if value == true and Ex_Function[key] then
            task.spawn(Ex_Function[key])
        end
    end
end)


NPCFolder.ChildAdded:Connect(function(v)
    if v:IsA("Model") then
        v.Name = v.Name:gsub("%d+", "")
    end
end)

for _,v in ipairs(workspace.NPCs:GetChildren()) do
    if v:IsA("Model") then
        v.Name = v.Name:gsub("%d+", "")
    end
end
