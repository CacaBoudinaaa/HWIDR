local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ⚠️ METS ICI L'URL RAW DE TON SCRIPT (ex: raw.githubusercontent.com/...)
-- Sans ça, l'autoload après téléportation ne fonctionnera pas.
local SCRIPT_URL = "https://raw.githubusercontent.com/CacaBoudinaaa/HWIDR/main/rivals.lua"
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/CacaBoudinaaa/Rayfield/refs/heads/main/RayfieldUI'))()

-- ========================================
-- WEAPON ICONS TABLE (Rivals)
-- ========================================
local WEAPON_ICONS = {
    ["Assault Rifle"]     = "rbxassetid://75480310531828",
    ["Revolver"]          = "rbxassetid://139314328910928",
    ["Shorty"]            = "rbxassetid://78526355119022",
    ["Handgun"]           = "rbxassetid://115137736353616",
    ["Shotgun"]           = "rbxassetid://78473164525526",
    ["Knife"]             = "rbxassetid://104596122491630",
    ["Bow"]               = "rbxassetid://96393141301809",
    ["Scythe"]            = "rbxassetid://73808098299850",
    ["Grenade"]           = "rbxassetid://119052162965074",
    ["Molotov"]           = "rbxassetid://80716785817363",
    ["RPG"]               = "rbxassetid://77997465931263",
    ["Burst Rifle"]       = "rbxassetid://133334115423599",
    ["Sniper"]            = "rbxassetid://106125986986438",
    ["Riot Shield"]       = "rbxassetid://100658552625628",
    ["Fists"]             = "rbxassetid://113415790288327",
    ["Freeze Ray"]        = "rbxassetid://134874010520949",
    ["Flashbang"]         = "rbxassetid://130665508011161",
    ["Subspace Tripmine"] = "rbxassetid://87069623830992",
    ["War Horn"]          = "rbxassetid://124249037297093",
    ["Smoke Grenade"]     = "rbxassetid://133932185935334",
    ["Satchel"]           = "rbxassetid://111496244824497",
    ["Medkit"]            = "rbxassetid://78614566613101",
    ["Trowel"]            = "rbxassetid://114347385255353",
    ["Chainsaw"]          = "rbxassetid://103572238781384",
    ["Spray"]             = "rbxassetid://112648170425088",
    ["Daggers"]           = "rbxassetid://124386216191091",
    ["Slingshot"]         = "rbxassetid://97114371048634",
    ["Flare Gun"]         = "rbxassetid://120510293691766",
    ["Exogun"]            = "rbxassetid://140236644009463",
    ["Paintball Gun"]     = "rbxassetid://104744682368202",
    ["Crossbow"]          = "rbxassetid://83511081732744",
    ["Battle Axe"]        = "rbxassetid://76119809648393",
    ["Hand"]              = "rbxassetid://126062997099192",
}

-- ========================================
-- UI CREATION
-- ========================================
local Window = Rayfield:CreateWindow({
   Name = "HWIDR",
   Icon = 78533660872848,
   LoadingTitle = "HWIDR",
   LoadingSubtitle = "Private Build",
   ShowText = "HWIDR",
   Theme = "Default",
   ToggleUIKeybind = Enum.KeyCode.RightShift,
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "HWIDRHub",
      FileName = "RivalsConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "https://discord.gg/hwidr",
      RememberJoins = true
   },
   KeySystem = false,
})

-- ========================================
-- VARIABLES
-- ========================================
local ESP = {
   Enabled = false,
   Config = {
      ShowName       = false,
      ShowDistance   = false,
      ShowHealth     = false,
      ShowWeapon     = false,
      ShowWeaponIcon = false,
      MaxDistance    = 350,
      Opacity        = 0.9,
      Color          = Color3.fromRGB(255, 0, 0),
      OutlineColor   = Color3.fromRGB(255, 0, 0),
   },
   _instances = {},
}

local Skeleton = {
   Enabled     = false,
   HeadDot     = false,
   HeadDotType = "fill",   -- "fill" | "holo"
   Color       = Color3.fromRGB(255, 255, 255),
   HeadColor   = Color3.fromRGB(255, 0, 0),
   Thickness   = 2,
   MaxDistance = 350,
   _instances  = {},
}

local SilentAim = {
   Enabled           = false,
   ShowFOV           = false,
   FOVRadius         = 150,
   TargetPart        = "Head",
   TargetPlayer      = nil,
   HitChance         = 100,
   NotWorkIfFlashed  = false,
}

local Triggerbot = { Enabled = false }

local targetStatusEnabled = false

local cframeSpeedEnabled    = false
local cframeSpeedMultiplier = 0.2
local cframeSpeedConn       = nil

local playerDragEnabled = false
local dragTarget        = nil
local dragHolding       = false

local slideEnabled = false
local slideSpeed   = 150
local slideConn    = nil

local fovCircle = nil

-- ========================================
-- AIMBOT MODULE (LEGIT / EXUNYS)
-- ========================================
local ExunysDeveloperAimbot = nil

local function initializeAimbot()
   if ExunysDeveloperAimbot then return ExunysDeveloperAimbot end

   local Environment = {
       Settings = {
           Enabled     = false,
           AliveCheck  = true,
           WallCheck   = false,
           Sensitivity = 0.2,
           LockPart    = "Head",
           StickyAim   = true,
           StickyRadius = 120,
           StickyTime  = 0.8,
           PredictionX = 0,
           PredictionY = 0,
       },
       FOVSettings = {
           Enabled      = false,
           Visible      = false,
           Amount       = 90,
           Color        = Color3.fromRGB(255, 255, 255),
           LockedColor  = Color3.fromRGB(255, 70, 70),
           Transparency = 0.5,
           Sides        = 60,
           Thickness    = 1,
           Filled       = false,
       },
       Locked          = nil,
       LastLockTime    = 0,
       StickyLockActive = false,
   }

   local FOVCircle = Drawing.new("Circle")

   local function CancelLock()
       Environment.Locked = nil
       Environment.StickyLockActive = false
       Environment.LastLockTime = 0
       FOVCircle.Color = Environment.FOVSettings.Color
   end

   local function GetClosestPlayer()
       local S = Environment.Settings
       local now = tick()

       if Environment.Locked and S.StickyAim then
           local char = Environment.Locked.Character
           local hum  = char and char:FindFirstChildOfClass("Humanoid")
           if char and char:FindFirstChild(S.LockPart) and hum then
               if S.AliveCheck and hum.Health <= 0 then CancelLock() return end
               local vec, onScreen = Camera:WorldToViewportPoint(char[S.LockPart].Position)
               if onScreen then
                   local ml   = UserInputService:GetMouseLocation()
                   local dist = (Vector2.new(ml.X, ml.Y) - Vector2.new(vec.X, vec.Y)).Magnitude
                   if dist <= S.StickyRadius then
                       Environment.StickyLockActive = true
                       Environment.LastLockTime = now
                       return
                   end
               end
               if Environment.StickyLockActive and (now - Environment.LastLockTime) < S.StickyTime then return end
           end
           CancelLock()
       end

       if not Environment.Locked then
           local maxDist = Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000
           local ml = UserInputService:GetMouseLocation()
           for _, v in pairs(Players:GetPlayers()) do
               if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(S.LockPart) then
                   local hum = v.Character:FindFirstChildOfClass("Humanoid")
                   if not hum or (S.AliveCheck and hum.Health <= 0) then continue end
                   if S.WallCheck then
                       local obs = Camera:GetPartsObscuringTarget({v.Character[S.LockPart].Position}, v.Character:GetDescendants())
                       if #obs > 0 then continue end
                   end
                   local vec, onScreen = Camera:WorldToViewportPoint(v.Character[S.LockPart].Position)
                   local dist = (Vector2.new(ml.X, ml.Y) - Vector2.new(vec.X, vec.Y)).Magnitude
                   if dist < maxDist and onScreen then
                       maxDist = dist
                       Environment.Locked = v
                       Environment.StickyLockActive = true
                       Environment.LastLockTime = now
                   end
               end
           end
       end
   end

   RunService.RenderStepped:Connect(function()
       if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
           FOVCircle.Radius      = Environment.FOVSettings.Amount
           FOVCircle.Thickness   = Environment.FOVSettings.Thickness
           FOVCircle.Filled      = Environment.FOVSettings.Filled
           FOVCircle.NumSides    = Environment.FOVSettings.Sides
           FOVCircle.Color       = Environment.FOVSettings.Color
           FOVCircle.Transparency = Environment.FOVSettings.Transparency
           FOVCircle.Visible     = Environment.FOVSettings.Visible
           local ml = UserInputService:GetMouseLocation()
           FOVCircle.Position = Vector2.new(ml.X, ml.Y)
       else
           FOVCircle.Visible = false
       end

       if Environment.Settings.Enabled then
           if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
               GetClosestPlayer()
               if Environment.Locked then
                   local char = Environment.Locked.Character
                   if char and char:FindFirstChild(Environment.Settings.LockPart) then
                       local part = char[Environment.Settings.LockPart]
                       local vec, onScreen = Camera:WorldToViewportPoint(part.Position)
                       if onScreen then
                           local ml = UserInputService:GetMouseLocation()
                           local dx = (vec.X - ml.X) * Environment.Settings.Sensitivity + Environment.Settings.PredictionX
                           local dy = (vec.Y - ml.Y) * Environment.Settings.Sensitivity + Environment.Settings.PredictionY
                           if mousemoverel then mousemoverel(dx, dy) end
                       end
                       FOVCircle.Color = Environment.FOVSettings.LockedColor
                   else
                       CancelLock()
                   end
               end
           else
               if Environment.Locked then CancelLock() end
           end
       end
   end)

   ExunysDeveloperAimbot = Environment
   return Environment
end

pcall(function()
   if not ExunysDeveloperAimbot then ExunysDeveloperAimbot = initializeAimbot() end
end)


-- ========================================
-- TAB: HOME
-- ========================================
local MainTab = Window:CreateTab("Home", 4483362458)
MainTab:CreateSection("Information")
MainTab:CreateParagraph({Title = "STATUS", Content = "Creator: LeDivineEnfant\ndiscord.gg/hwidr"})


-- ========================================
-- TAB: COMBAT
-- ========================================
local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateSection("Silent Aim")

CombatTab:CreateToggle({
   Name = "Silent Aim", CurrentValue = false, Flag = "togglesilentaim",
   Callback = function(v) SilentAim.Enabled = v end,
})
CombatTab:CreateToggle({
   Name = "Show FOV", CurrentValue = false, Flag = "togglesfovsilent",
   Callback = function(v)
       SilentAim.ShowFOV = v
       if fovCircle then fovCircle.Visible = v end
   end,
})
CombatTab:CreateToggle({
   Name = "Not Work If Flashed", CurrentValue = false, Flag = "togglesilentflash",
   Callback = function(v) SilentAim.NotWorkIfFlashed = v end,
})
CombatTab:CreateSlider({
   Name = "Silent FOV Radius", Range = {25, 900}, Increment = 1, CurrentValue = 150, Flag = "slidefovsilent",
   Callback = function(v)
      SilentAim.FOVRadius = math.max(v, 25)
      if fovCircle then fovCircle.Radius = SilentAim.FOVRadius end
   end,
})
CombatTab:CreateSlider({
   Name = "Hit Chance", Range = {1, 100}, Increment = 1, Suffix = "%", CurrentValue = 100, Flag = "slidehitchance",
   Callback = function(v) SilentAim.HitChance = v end,
})
CombatTab:CreateDropdown({
   Name = "Target Part", Options = {"Head","Body","Legit"}, CurrentOption = {"Legit"}, Flag = "targetsilent",
   Callback = function(opt) SilentAim.TargetPart = opt[1] end,
})

CombatTab:CreateSection("Triggerbot")

CombatTab:CreateToggle({
   Name = "Triggerbot", CurrentValue = false, Flag = "toggletriggerbot",
   Callback = function(v) Triggerbot.Enabled = v end,
})

CombatTab:CreateSection("Legit Aimbot")

CombatTab:CreateToggle({
   Name = "Legit Aimbot", CurrentValue = false, Flag = "toggleaimbot",
   Callback = function(v)
      if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.Enabled = v end
   end,
})
CombatTab:CreateToggle({
   Name = "Wall Check", CurrentValue = false, Flag = "togglewallcheck",
   Callback = function(v)
      if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.WallCheck = v end
   end,
})
CombatTab:CreateToggle({
   Name = "Show Aimbot FOV", CurrentValue = false, Flag = "toggleaimbotfov",
   Callback = function(v)
      if ExunysDeveloperAimbot then
          ExunysDeveloperAimbot.FOVSettings.Enabled = v
          ExunysDeveloperAimbot.FOVSettings.Visible = v
      end
   end,
})
CombatTab:CreateSlider({
   Name = "Aimbot FOV Size", Range = {30, 200}, Increment = 5, CurrentValue = 90, Flag = "aimbotfovsize",
   Callback = function(v)
      if ExunysDeveloperAimbot then ExunysDeveloperAimbot.FOVSettings.Amount = v end
   end,
})
CombatTab:CreateSlider({
   Name = "Smoothness", Range = {0.1, 1}, Increment = 0.05, Suffix = "x", CurrentValue = 0.2, Flag = "aimbotsmooth",
   Callback = function(v)
      if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.Sensitivity = v end
   end,
})
CombatTab:CreateSlider({
   Name = "Prediction X", Range = {0, 1}, Increment = 0.01, CurrentValue = 0, Flag = "aimbotpredx",
   Callback = function(v)
      if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.PredictionX = v end
   end,
})
CombatTab:CreateSlider({
   Name = "Prediction Y", Range = {0, 1}, Increment = 0.01, CurrentValue = 0, Flag = "aimbotpredy",
   Callback = function(v)
      if ExunysDeveloperAimbot then ExunysDeveloperAimbot.Settings.PredictionY = v end
   end,
})


-- ========================================
-- TAB: VISUALS
-- ========================================
local VisualTab = Window:CreateTab("Visuals", 4483362458)

VisualTab:CreateSection("Player ESP")

VisualTab:CreateToggle({
   Name = "Enable ESP", CurrentValue = false, Flag = "toggleenableesp",
   Callback = function(v)
      ESP.Enabled = v
      if not v then
         for plr, _ in pairs(ESP._instances) do
            pcall(function()
                if ESP._instances[plr].Highlight then ESP._instances[plr].Highlight:Destroy() end
                if ESP._instances[plr].Billboard then ESP._instances[plr].Billboard:Destroy() end
                if ESP._instances[plr].Conn then ESP._instances[plr].Conn:Disconnect() end
            end)
            ESP._instances[plr] = nil
         end
      end
   end,
})
VisualTab:CreateToggle({
   Name = "Show Name", CurrentValue = false, Flag = "toggleespname",
   Callback = function(v) ESP.Config.ShowName = v end,
})
VisualTab:CreateToggle({
   Name = "Show Distance", CurrentValue = false, Flag = "toggleespdist",
   Callback = function(v) ESP.Config.ShowDistance = v end,
})
VisualTab:CreateToggle({
   Name = "Show Health (colored)", CurrentValue = false, Flag = "toggleesphealth",
   Callback = function(v) ESP.Config.ShowHealth = v end,
})
VisualTab:CreateToggle({
   Name = "Show Weapon Name", CurrentValue = false, Flag = "toggleespweapon",
   Callback = function(v) ESP.Config.ShowWeapon = v end,
})
VisualTab:CreateToggle({
   Name = "Show Weapon Icon", CurrentValue = false, Flag = "toggleespweaponicon",
   Callback = function(v) ESP.Config.ShowWeaponIcon = v end,
})
VisualTab:CreateSlider({
   Name = "ESP Max Distance", Range = {50, 1000}, Increment = 10, Suffix = "m", CurrentValue = 350, Flag = "slidermaxdist",
   Callback = function(v) ESP.Config.MaxDistance = v end,
})
VisualTab:CreateSlider({
   Name = "ESP Opacity", Range = {0, 50}, Increment = 1, CurrentValue = 40, Flag = "slideresp",
   Callback = function(v) ESP.Config.Opacity = math.clamp(v / 50, 0, 1) end,
})
VisualTab:CreateColorPicker({
   Name = "ESP Color", Color = ESP.Config.Color, Flag = "espcolor",
   Callback = function(c)
      ESP.Config.Color = c
      ESP.Config.OutlineColor = c
   end,
})

VisualTab:CreateSection("Skeleton ESP")

VisualTab:CreateToggle({
   Name = "Enable Skeleton", CurrentValue = false, Flag = "toggleskeleton",
   Callback = function(v) Skeleton.Enabled = v end,
})
VisualTab:CreateToggle({
   Name = "Head Dot", CurrentValue = false, Flag = "toggleheaddot",
   Callback = function(v) Skeleton.HeadDot = v end,
})
VisualTab:CreateDropdown({
   Name = "Head Dot Type", Options = {"fill","holo"}, CurrentOption = {"fill"}, Flag = "headdottype",
   Callback = function(opt) Skeleton.HeadDotType = opt[1] end,
})
VisualTab:CreateColorPicker({
   Name = "Skeleton Color", Color = Skeleton.Color, Flag = "skelcolor",
   Callback = function(c) Skeleton.Color = c end,
})
VisualTab:CreateColorPicker({
   Name = "Head Dot Color", Color = Skeleton.HeadColor, Flag = "headdotcolor",
   Callback = function(c) Skeleton.HeadColor = c end,
})

VisualTab:CreateSection("World & Lighting")

local function toggleCustomSky(bool)
    if bool then
        local sky = Lighting:FindFirstChild("RivalsCustomSky") or Instance.new("Sky")
        sky.Name = "RivalsCustomSky"
        sky.SkyboxBk = "rbxassetid://218955819" sky.SkyboxDn = "rbxassetid://218953419"
        sky.SkyboxFt = "rbxassetid://218954524" sky.SkyboxLf = "rbxassetid://218958493"
        sky.SkyboxRt = "rbxassetid://218957134" sky.SkyboxUp = "rbxassetid://218950090"
        sky.Parent = Lighting
    else
        local sky = Lighting:FindFirstChild("RivalsCustomSky")
        if sky then sky:Destroy() end
    end
end

VisualTab:CreateToggle({
   Name = "Custom Skybox", CurrentValue = false, Flag = "togglecustomsky",
   Callback = function(v) toggleCustomSky(v) end,
})

local function toggle4KGraphics(bool)
    if bool then
        Lighting.Brightness = 0.5
        Lighting.GlobalShadows = true
        Lighting.EnvironmentDiffuseScale = 0.4
        Lighting.EnvironmentSpecularScale = 0.85
        task.spawn(function()
            for i, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = math.min(obj.Reflectance + 0.3, 0.5)
                end
                if i % 500 == 0 then task.wait() end
            end
        end)
    else
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end
end

VisualTab:CreateToggle({
   Name = "4K/Wet Graphics (Laggy)", CurrentValue = false, Flag = "toggle4kgraphics",
   Callback = function(v) toggle4KGraphics(v) end,
})


-- ========================================
-- TAB: BLATANT
-- ========================================
local BlatantTab = Window:CreateTab("Blatant", 4483362458)

BlatantTab:CreateSection("Movement")

BlatantTab:CreateButton({
   Name = "Infinite Jump",
   Callback = function()
      _G.infiniteJumpEnabled = not _G.infiniteJumpEnabled
      if not _G.infiniteJumpStarted then
         _G.infiniteJumpStarted = true
         UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode.Space and _G.infiniteJumpEnabled then
               local char = LocalPlayer.Character
               local hum = char and char:FindFirstChildOfClass("Humanoid")
               if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
         end)
      end
      Rayfield:Notify({Title = "HWIDR", Content = "Infinite Jump: " .. (_G.infiniteJumpEnabled and "ON" or "OFF"), Duration = 2})
   end,
})

BlatantTab:CreateButton({
   Name = "No Clip",
   Callback = function()
      _G.noclipEnabled = not _G.noclipEnabled
      if _G.noclipEnabled then
         _G.noclipConnection = RunService.Stepped:Connect(function()
            pcall(function()
               local char = LocalPlayer.Character
               if char then
                  for _, part in pairs(char:GetChildren()) do
                     if part:IsA("BasePart") then part.CanCollide = false end
                  end
               end
            end)
         end)
         Rayfield:Notify({Title = "HWIDR", Content = "Noclip Enabled", Duration = 2})
      else
         if _G.noclipConnection then _G.noclipConnection:Disconnect() _G.noclipConnection = nil end
         Rayfield:Notify({Title = "HWIDR", Content = "Noclip Disabled", Duration = 2})
      end
   end,
})

local flySpeed = 50
local isFlying = false
BlatantTab:CreateToggle({
   Name = "Fly", CurrentValue = false, Flag = "togglefly",
   Callback = function(val)
      isFlying = val
      if val then
          local char = LocalPlayer.Character
          local hrp = char and char:FindFirstChild("HumanoidRootPart")
          if not hrp then return end
          local bv = Instance.new("BodyVelocity", hrp)
          bv.Name = "FlyVel"
          bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
          local bg = Instance.new("BodyGyro", hrp)
          bg.Name = "FlyGyro"
          bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
          bg.P = 9e4
          task.spawn(function()
              while isFlying and char.Parent do
                  local cam = Workspace.CurrentCamera
                  local move = Vector3.zero
                  if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                  if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                  if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                  if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                  if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                  if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
                  bv.Velocity = move * flySpeed
                  bg.CFrame = cam.CFrame
                  RunService.Heartbeat:Wait()
              end
              bv:Destroy()
              bg:Destroy()
          end)
      end
   end,
})
BlatantTab:CreateSlider({
   Name = "Fly Speed", Range = {0, 500}, Increment = 10, CurrentValue = 50, Flag = "sliderflyspeed",
   Callback = function(v) flySpeed = v end,
})

-- CFrame Speed
BlatantTab:CreateToggle({
   Name = "CFrame Speed", CurrentValue = false, Flag = "togglecframespeed",
   Callback = function(val)
      cframeSpeedEnabled = val
      if val then
          cframeSpeedConn = RunService.Stepped:Connect(function()
              local char = LocalPlayer.Character
              local hrp = char and char:FindFirstChild("HumanoidRootPart")
              local hum = char and char:FindFirstChildOfClass("Humanoid")
              if hrp and hum then
                  local dir = hum.MoveDirection
                  if dir.Magnitude > 0 then
                      hrp.CFrame = hrp.CFrame + dir * cframeSpeedMultiplier
                  end
              end
          end)
      else
          if cframeSpeedConn then cframeSpeedConn:Disconnect() cframeSpeedConn = nil end
      end
   end,
})
BlatantTab:CreateSlider({
   Name = "CFrame Speed Multiplier", Range = {1, 10}, Increment = 1, Suffix = "x", CurrentValue = 2, Flag = "slidercframespeed",
   Callback = function(v) cframeSpeedMultiplier = v / 10 end,
})

-- Player Drag
BlatantTab:CreateToggle({
   Name = "Player Drag (Hold LMB)", CurrentValue = false, Flag = "toggleplayerdrag",
   Callback = function(v) playerDragEnabled = v end,
})

-- Slide to Enemy
BlatantTab:CreateToggle({
   Name = "Slide to Enemy (Press N)", CurrentValue = false, Flag = "toggleslide",
   Callback = function(val)
      slideEnabled = val
      if not val then
          if slideConn then slideConn:Disconnect() slideConn = nil end
      end
   end,
})
BlatantTab:CreateSlider({
   Name = "Slide Speed", Range = {50, 500}, Increment = 10, CurrentValue = 150, Flag = "sliderspeedslide",
   Callback = function(v) slideSpeed = v end,
})

BlatantTab:CreateSection("Teleport")

BlatantTab:CreateToggle({
   Name = "TP Behind (Press P)", CurrentValue = false, Flag = "tpbehind_toggle",
   Callback = function(val)
      if val then
         _G.tpBehindConn = UserInputService.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == Enum.KeyCode.P then
               local target = SilentAim.TargetPlayer
               if not target then target = getClosestTargetToCursor(500) end
               if target and target.Character then
                   local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
                   local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                   if targetHRP and myHRP then
                       myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 5)
                   end
               end
            end
         end)
      else
         if _G.tpBehindConn then _G.tpBehindConn:Disconnect() end
      end
   end,
})


-- ========================================
-- TAB: SETTINGS
-- ========================================
local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("HUD")

SettingsTab:CreateToggle({
   Name = "Target Status HUD", CurrentValue = false, Flag = "toggletargetstatus",
   Callback = function(v) targetStatusEnabled = v end,
})

-- ========================================
-- TAB: GUN MODS (Level 8 executor needed)
-- ========================================
local GunTab = Window:CreateTab("Gun Mods", 4483362458)
GunTab:CreateSection("Requires Level 8 Executor")

local function patchGunValue(key, value)
    pcall(function()
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, key) then
                v[key] = value
            end
        end
    end)
end

GunTab:CreateButton({
   Name = "Rapid Fire",
   Callback = function()
       patchGunValue("ShootCooldown", 0)
       Rayfield:Notify({Title = "HWIDR", Content = "Rapid Fire Applied", Duration = 2})
   end,
})
GunTab:CreateButton({
   Name = "No Spread",
   Callback = function()
       patchGunValue("ShootSpread", 0)
       Rayfield:Notify({Title = "HWIDR", Content = "No Spread Applied", Duration = 2})
   end,
})
GunTab:CreateButton({
   Name = "No Recoil",
   Callback = function()
       patchGunValue("ShootRecoil", 0)
       Rayfield:Notify({Title = "HWIDR", Content = "No Recoil Applied", Duration = 2})
   end,
})


-- ========================================
-- SILENT AIM LOGIC
-- ========================================
pcall(function()
    if Drawing then
        fovCircle           = Drawing.new('Circle')
        fovCircle.Thickness = 1
        fovCircle.NumSides  = 64
        fovCircle.Radius    = SilentAim.FOVRadius
        fovCircle.Color     = Color3.new(1, 1, 1)
        fovCircle.Filled    = false
        fovCircle.Visible   = false
    end
end)

-- Armes qui ne doivent PAS déclencher le silent aim
local THROWABLES = {
    ["Grenade"]           = true,
    ["Molotov"]           = true,
    ["Flashbang"]         = true,
    ["Smoke Grenade"]     = true,
    ["Satchel"]           = true,
    ["Subspace Tripmine"] = true,
    ["War Horn"]          = true,
}

local function isHoldingThrowable()
    local char = LocalPlayer.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and THROWABLES[tool.Name] == true
end

local function getClosestTargetToCursor(radius)
    local mouse = LocalPlayer:GetMouse()
    local closestPart, closestPlayer, closestDist = nil, nil, radius
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local sv, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(sv.X, sv.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                    if dist <= closestDist then
                        closestDist   = dist
                        closestPart   = part
                        closestPlayer = plr
                    end
                end
            end
        end
    end
    SilentAim.TargetPlayer = closestPlayer
    return closestPlayer, closestPart
end

local prevCamCFrame
local holdingSilent = false
local mouse = LocalPlayer:GetMouse()

mouse.Button1Down:Connect(function()
    if not SilentAim.Enabled then return end
    if isHoldingThrowable() then return end
    if SilentAim.NotWorkIfFlashed and Lighting:FindFirstChild("Flashbang") then return end
    if math.random(1, 100) > SilentAim.HitChance then return end
    holdingSilent = true
    prevCamCFrame = Camera.CFrame
    local _, targetPart = getClosestTargetToCursor(SilentAim.FOVRadius)
    if targetPart then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    end
end)

mouse.Button1Up:Connect(function()
    if holdingSilent and prevCamCFrame then Camera.CFrame = prevCamCFrame end
    holdingSilent = false
end)

RunService.RenderStepped:Connect(function()
    if fovCircle then
        fovCircle.Visible  = SilentAim.ShowFOV
        fovCircle.Radius   = SilentAim.FOVRadius
        local m = UserInputService:GetMouseLocation()
        fovCircle.Position = Vector2.new(m.X, m.Y)
    end
end)


-- ========================================
-- TRIGGERBOT LOGIC
-- ========================================
RunService.RenderStepped:Connect(function()
    if not Triggerbot.Enabled then return end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = Workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1000, params)
    if result then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model and model:FindFirstChildOfClass("Humanoid") and model.Name ~= LocalPlayer.Name then
            mouse1click()
        end
    end
end)


-- ========================================
-- PLAYER DRAG LOGIC
-- ========================================
local function getClosestVisibleEnemy()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myChar = LocalPlayer.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local closest, closestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local sv, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local rp = RaycastParams.new()
                    rp.FilterType = Enum.RaycastFilterType.Blacklist
                    rp.FilterDescendantsInstances = {myChar, Camera}
                    local ray = Workspace:Raycast(Camera.CFrame.Position, hrp.Position - Camera.CFrame.Position, rp)
                    local visible = ray == nil or ray.Instance:IsDescendantOf(plr.Character)
                    if visible then
                        local d = (Vector2.new(sv.X, sv.Y) - center).Magnitude
                        if d < closestDist then closest = plr closestDist = d end
                    end
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not playerDragEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local target = getClosestVisibleEnemy()
        if target then dragTarget = target dragHolding = true end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragHolding = false
        dragTarget  = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not playerDragEnabled or not dragHolding or not dragTarget then return end
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myHRP and dragTarget.Character and dragTarget.Character:FindFirstChild("HumanoidRootPart") then
        dragTarget.Character.HumanoidRootPart.CFrame = myHRP.CFrame * CFrame.new(0, 0, -2)
    end
end)


-- ========================================
-- SLIDE TO ENEMY LOGIC
-- ========================================
local function getClosestPlayerToCenter()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myHRP  = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return nil end
    local closest, closestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            if (hrp.Position - myHRP.Position).Magnitude <= 350 then
                local sv, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = (Vector2.new(sv.X, sv.Y) - center).Magnitude
                    if d < closestDist then closest = plr closestDist = d end
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe or not slideEnabled then return end
    if input.KeyCode == Enum.KeyCode.N then
        local target = getClosestPlayerToCenter()
        if not target then return end
        if slideConn then slideConn:Disconnect() end
        slideConn = RunService.Heartbeat:Connect(function(dt)
            if not slideEnabled or not target.Character then
                slideConn:Disconnect() slideConn = nil return
            end
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local tHRP  = target.Character:FindFirstChild("HumanoidRootPart")
            if myHRP and tHRP then
                local dest = tHRP.CFrame * CFrame.new(0, 0, 5)
                local dir  = (dest.Position - myHRP.Position)
                if dir.Magnitude > 1 then
                    myHRP.CFrame = myHRP.CFrame + dir.Unit * slideSpeed * dt
                end
            end
        end)
    end
end)


-- ========================================
-- ESP LOGIC
-- ========================================
local function createESPForPlayer(plr)
   if not plr or not plr.Character then return end
   local char = plr.Character

   if ESP._instances[plr] and ESP._instances[plr].Character == char then return end

   if ESP._instances[plr] then
       pcall(function()
           if ESP._instances[plr].Highlight then ESP._instances[plr].Highlight:Destroy() end
           if ESP._instances[plr].Billboard then ESP._instances[plr].Billboard:Destroy() end
           if ESP._instances[plr].Conn      then ESP._instances[plr].Conn:Disconnect() end
       end)
       ESP._instances[plr] = nil
   end

   local highlight = Instance.new('Highlight', char)
   highlight.FillColor          = ESP.Config.Color
   highlight.FillTransparency   = 0.8
   highlight.OutlineColor       = ESP.Config.OutlineColor
   highlight.OutlineTransparency = 0

   local billboard = Instance.new('BillboardGui', char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
   billboard.Size         = UDim2.new(0, 220, 0, 130)
   billboard.StudsOffset  = Vector3.new(0, 2.5, 0)
   billboard.AlwaysOnTop  = true

   -- Name / Distance
   local nameLabel = Instance.new('TextLabel', billboard)
   nameLabel.Size                 = UDim2.new(1, 0, 0, 20)
   nameLabel.Position             = UDim2.new(0, 0, 0, 0)
   nameLabel.BackgroundTransparency = 1
   nameLabel.TextColor3           = ESP.Config.Color
   nameLabel.TextStrokeTransparency = 0
   nameLabel.Font                 = Enum.Font.GothamBold
   nameLabel.TextSize             = 14
   nameLabel.RichText             = true
   nameLabel.Text                 = plr.Name
   nameLabel.Visible              = false

   -- HP (colored)
   local healthLabel = Instance.new('TextLabel', billboard)
   healthLabel.Size                 = UDim2.new(1, 0, 0, 20)
   healthLabel.Position             = UDim2.new(0, 0, 0, 22)
   healthLabel.BackgroundTransparency = 1
   healthLabel.TextColor3           = Color3.fromRGB(255,255,255)
   healthLabel.TextStrokeTransparency = 0
   healthLabel.Font                 = Enum.Font.GothamBold
   healthLabel.TextSize             = 13
   healthLabel.RichText             = true
   healthLabel.Text                 = ""
   healthLabel.Visible              = false

   -- Weapon name
   local weaponLabel = Instance.new('TextLabel', billboard)
   weaponLabel.Size                 = UDim2.new(1, -40, 0, 20)
   weaponLabel.Position             = UDim2.new(0, 0, 0, 44)
   weaponLabel.BackgroundTransparency = 1
   weaponLabel.TextColor3           = Color3.fromRGB(255, 220, 50)
   weaponLabel.TextStrokeTransparency = 0
   weaponLabel.Font                 = Enum.Font.GothamBold
   weaponLabel.TextSize             = 13
   weaponLabel.TextXAlignment       = Enum.TextXAlignment.Left
   weaponLabel.Text                 = ""
   weaponLabel.Visible              = false

   -- Weapon icon
   local iconFrame = Instance.new('Frame', billboard)
   iconFrame.Size                = UDim2.new(0, 32, 0, 32)
   iconFrame.Position            = UDim2.new(1, -34, 0, 38)
   iconFrame.BackgroundColor3    = Color3.fromRGB(0,0,0)
   iconFrame.BackgroundTransparency = 0.6
   iconFrame.BorderSizePixel     = 0
   iconFrame.Visible             = false
   Instance.new('UICorner', iconFrame).CornerRadius = UDim.new(0, 6)

   local weaponIcon = Instance.new('ImageLabel', iconFrame)
   weaponIcon.Size                 = UDim2.new(1, 0, 1, 0)
   weaponIcon.BackgroundTransparency = 1
   weaponIcon.Image                = ""

   local conn = RunService.Heartbeat:Connect(function()
       if not char or not char.Parent then return end

       local myChar = LocalPlayer.Character
       local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
       local charHRP = char:FindFirstChild("HumanoidRootPart")

       -- Max distance cull
       if myHRP and charHRP and (myHRP.Position - charHRP.Position).Magnitude > ESP.Config.MaxDistance then
           nameLabel.Visible = false healthLabel.Visible = false
           weaponLabel.Visible = false iconFrame.Visible = false
           return
       end

       local hum    = char:FindFirstChildOfClass("Humanoid")
       local hp     = hum and math.floor(hum.Health) or 0
       local isDead = hp <= 0

       -- Name / Distance
       if ESP.Config.ShowName or ESP.Config.ShowDistance then
           if isDead then
               nameLabel.Text = '<font color="#7370ff">✦ DEAD ✦</font>'
           else
               local text = plr.Name
               if ESP.Config.ShowDistance and myHRP and charHRP then
                   text = text .. "  [" .. math.floor((myHRP.Position - charHRP.Position).Magnitude) .. "m]"
               end
               nameLabel.Text = text
           end
           nameLabel.TextColor3 = ESP.Config.Color
           nameLabel.Visible    = true
       else
           nameLabel.Visible = false
       end

       -- HP colored
       if ESP.Config.ShowHealth and not isDead then
           local col = hp < 15 and "#de4433" or (hp < 30 and "#FFFF00" or "#2fde4c")
           healthLabel.Text    = 'HP: <font color="' .. col .. '"><b>' .. hp .. '</b></font>'
           healthLabel.Visible = true
       else
           healthLabel.Visible = false
       end

       -- Weapon name + icon
       local tool       = char:FindFirstChildOfClass("Tool")
       local weaponName = tool and tool.Name or "Hand"

       if ESP.Config.ShowWeapon and not isDead then
           weaponLabel.Text    = weaponName
           weaponLabel.Visible = true
       else
           weaponLabel.Visible = false
       end

       if ESP.Config.ShowWeaponIcon and not isDead then
           local iconId = WEAPON_ICONS[weaponName]
           if iconId then
               weaponIcon.Image  = iconId
               iconFrame.Visible = true
           else
               iconFrame.Visible = false
           end
       else
           iconFrame.Visible = false
       end

       highlight.FillColor    = ESP.Config.Color
       highlight.OutlineColor = ESP.Config.OutlineColor
   end)

   ESP._instances[plr] = {Highlight = highlight, Billboard = billboard, Conn = conn, Character = char}
end

RunService.Heartbeat:Connect(function()
    if ESP.Enabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if not ESP._instances[plr] or ESP._instances[plr].Character ~= plr.Character then
                    createESPForPlayer(plr)
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESP._instances[plr] then
        pcall(function() ESP._instances[plr].Conn:Disconnect() end)
        ESP._instances[plr] = nil
    end
end)


-- ========================================
-- SKELETON ESP LOGIC
-- ========================================
local BONE_PAIRS = {
    {"Head",       "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm","RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg","RightLowerLeg"},
}

local ALL_BONES = {"Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","RightUpperArm","RightLowerArm","LeftUpperLeg","LeftLowerLeg","RightUpperLeg","RightLowerLeg"}

local function createSkeletonForPlayer(plr, char)
    -- Clean up old
    if Skeleton._instances[plr] then
        for _, l in pairs(Skeleton._instances[plr].lines)   do pcall(function() l:Remove() end) end
        if Skeleton._instances[plr].headDot then pcall(function() Skeleton._instances[plr].headDot:Remove() end) end
    end

    local lines = {}
    for _, pair in pairs(BONE_PAIRS) do
        local line = Drawing.new("Line")
        line.Thickness   = Skeleton.Thickness
        line.Color       = Skeleton.Color
        line.Transparency = 1
        line.Visible     = false
        lines[pair[2]]   = line
    end

    local headDot = Drawing.new("Circle")
    headDot.Color       = Skeleton.HeadColor
    headDot.Filled      = true
    headDot.Transparency = 1
    headDot.Visible     = false

    Skeleton._instances[plr] = {lines = lines, headDot = headDot, char = char}

    task.spawn(function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            if not char or not char.Parent then
                for _, l in pairs(lines) do l.Visible = false end
                headDot.Visible = false
                conn:Disconnect()
                return
            end

            if not Skeleton.Enabled then
                for _, l in pairs(lines) do l.Visible = false end
                headDot.Visible = false
                return
            end

            local myHRP   = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local charHRP = char:FindFirstChild("HumanoidRootPart")
            local hum     = char:FindFirstChildOfClass("Humanoid")
            local mag     = (myHRP and charHRP) and (myHRP.Position - charHRP.Position).Magnitude or 0

            local tooFar = mag > Skeleton.MaxDistance
            local dead   = hum and hum.Health <= 0

            if tooFar or dead then
                for _, l in pairs(lines) do l.Visible = false end
                headDot.Visible = false
                return
            end

            -- Build viewport positions
            local pos = {}
            for _, boneName in pairs(ALL_BONES) do
                local bone = char:FindFirstChild(boneName)
                if bone then
                    local sv, onScreen = Camera:WorldToViewportPoint(bone.Position)
                    pos[boneName] = onScreen and Vector2.new(sv.X, sv.Y) or nil
                end
            end

            -- Draw lines
            for _, pair in pairs(BONE_PAIRS) do
                local line = lines[pair[2]]
                if line then
                    local from, to = pos[pair[1]], pos[pair[2]]
                    if from and to then
                        line.From    = from
                        line.To      = to
                        line.Color   = Skeleton.Color
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                end
            end

            -- Head dot
            if Skeleton.HeadDot and pos.Head then
                headDot.Position = pos.Head
                headDot.Radius   = math.clamp(300 / math.max(mag, 1), 4, 14)
                headDot.Color    = Skeleton.HeadColor
                if Skeleton.HeadDotType == "holo" then
                    headDot.Filled    = false
                    headDot.Thickness = 2
                else
                    headDot.Filled = true
                end
                headDot.Visible = true
            else
                headDot.Visible = false
            end
        end)
    end)
end

local function initSkeletonForPlayer(plr)
    if plr.Character then
        task.spawn(createSkeletonForPlayer, plr, plr.Character)
    end
    plr.CharacterAdded:Connect(function(char)
        task.wait(1)
        createSkeletonForPlayer(plr, char)
    end)
end

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then task.spawn(initSkeletonForPlayer, plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then initSkeletonForPlayer(plr) end
end)


-- ========================================
-- TARGET STATUS HUD
-- ========================================
task.spawn(function()
    local CoreGui = game:GetService("CoreGui")

    -- Build ScreenGui
    local hudGui = Instance.new("ScreenGui")
    hudGui.Name = "HWIDRTargetHUD"
    hudGui.ResetOnSpawn = false
    hudGui.Parent = CoreGui
    hudGui.Enabled = false

    -- Main frame (bottom center)
    local frame = Instance.new("Frame", hudGui)
    frame.Size = UDim2.new(0, 210, 0, 64)
    frame.Position = UDim2.new(0.5, 0, 0.87, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1.5
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Transparency = 0

    -- Avatar background box
    local avatarBox = Instance.new("Frame", frame)
    avatarBox.Size = UDim2.new(0, 46, 0, 46)
    avatarBox.Position = UDim2.new(0, 9, 0, 9)
    avatarBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    avatarBox.BackgroundTransparency = 0.5
    avatarBox.BorderSizePixel = 0
    Instance.new("UICorner", avatarBox).CornerRadius = UDim.new(0, 8)

    local avatarImg = Instance.new("ImageLabel", avatarBox)
    avatarImg.Size = UDim2.new(1, 0, 1, 0)
    avatarImg.BackgroundTransparency = 1
    avatarImg.Image = ""
    Instance.new("UICorner", avatarImg).CornerRadius = UDim.new(0, 8)

    -- Name label
    local nameLabel = Instance.new("TextLabel", frame)
    nameLabel.Size = UDim2.new(1, -65, 0, 22)
    nameLabel.Position = UDim2.new(0, 62, 0, 8)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Text = ""

    -- HP bar background
    local barBg = Instance.new("Frame", frame)
    barBg.Size = UDim2.new(1, -65, 0, 10)
    barBg.Position = UDim2.new(0, 62, 0, 44)
    barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)

    -- HP bar fill
    local barFill = Instance.new("Frame", barBg)
    barFill.Size = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    barFill.BorderSizePixel = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 4)

    -- HP text
    local hpText = Instance.new("TextLabel", frame)
    hpText.Size = UDim2.new(1, -65, 0, 16)
    hpText.Position = UDim2.new(0, 62, 0, 26)
    hpText.BackgroundTransparency = 1
    hpText.TextColor3 = Color3.fromRGB(200, 200, 200)
    hpText.Font = Enum.Font.Gotham
    hpText.TextSize = 12
    hpText.TextXAlignment = Enum.TextXAlignment.Left
    hpText.RichText = true
    hpText.Text = ""

    local lastHp = nil
    local lastTarget = nil

    local function getClosestEnemy()
        local myChar = LocalPlayer.Character
        local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end
        local closest, closestDist = nil, math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local dist = (hrp.Position - myHRP.Position).Magnitude
                        if dist <= 350 and dist < closestDist then
                            closest = plr
                            closestDist = dist
                        end
                    end
                end
            end
        end
        return closest
    end

    RunService.RenderStepped:Connect(function()
        if not targetStatusEnabled then
            hudGui.Enabled = false
            return
        end

        local myChar = LocalPlayer.Character
        local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
        if not myChar or not myHum or myHum.Health <= 0 then
            hudGui.Enabled = false
            return
        end

        local target = getClosestEnemy()
        if not target then
            hudGui.Enabled = false
            lastTarget = nil
            return
        end

        hudGui.Enabled = true
        nameLabel.Text = target.DisplayName

        -- Fetch avatar only when target changes
        if target ~= lastTarget then
            lastTarget = target
            lastHp = nil
            task.spawn(function()
                local ok, img = pcall(function()
                    return Players:GetUserThumbnailAsync(target.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size150x150)
                end)
                avatarImg.Image = (ok and img) or ""
            end)
        end

        -- HP bar update with tween
        local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local hp    = hum.Health
            local maxHp = hum.MaxHealth
            local ratio = math.clamp(hp / math.max(maxHp, 1), 0, 1)

            if hp ~= lastHp then
                lastHp = hp

                local hpColor = Color3.fromRGB(0, 255, 0)
                if hp <= 30 then hpColor = Color3.fromRGB(255, 255, 0) end
                if hp <= 15 then hpColor = Color3.fromRGB(220, 50, 50) end

                TweenService:Create(barFill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(ratio, 0, 1, 0),
                    BackgroundColor3 = hpColor,
                }):Play()

                local hpStr = math.floor(hp) .. " / " .. math.floor(maxHp)
                hpText.Text = '<font color="' .. (hp <= 15 and "#de4433" or (hp <= 30 and "#FFFF00" or "#2fde4c")) .. '">' .. hpStr .. '</font>'
            end
        end
    end)
end)

-- ========================================
-- AUTOLOAD
-- ========================================
if queue_on_teleport then
    queue_on_teleport(string.format([[
        task.wait(3)
        loadstring(game:HttpGet('%s'))()
    ]], SCRIPT_URL))
end

Rayfield:LoadConfiguration()
Rayfield:Notify({Title = "HWIDR", Content = "Script Loaded", Duration = 3})
