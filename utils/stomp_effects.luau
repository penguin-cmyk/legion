local DhLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/penguin-cmyk/legion/refs/heads/main/utils/dh_library.lua"))()
local Services   = DhLibrary:Services()

local LightingService   = game:GetService("Lighting")
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer       = Services.LocalPlayer
local RunService        = Services.RunService
local Workspace         = Services.Workspace
local Players           = Services.Players 
------------------------------------------------------------------------------------------------------------

local HollowPurple = game:GetObjects("rbxassetid://113021961115483")[1]
local RoadRoller = game:GetObjects("rbxassetid://85904556439762")[1]
local SonicRings = game:GetObjects("rbxassetid://107016840921635")[1]
local BlackHole  = game:GetObjects("rbxassetid://107558636253769")[1]
local Spirit     = game:GetObjects("rbxassetid://89731535148122")[1]
local Charm      = game:GetObjects("rbxassetid://139067309930404")[1]
local Thanos     = game:GetObjects("rbxassetid://129891025243944")[1]
local AfterSlash = game:GetObjects("rbxassetid://102168430997910")[1]
local Rune       = game:GetObjects("rbxassetid://139139192547301")[1]


local TweenService = game:GetService("TweenService")
local AssetService = game:GetService("AssetService")

local Train = AssetService:CreateMeshPartAsync("rbxassetid://743576537")
local Aura = AssetService:CreateMeshPartAsync("http://www.roblox.com/asset/?id=1323306")

local Camera  = Workspace.CurrentCamera 

-- For Rune
local Shock = AssetService:CreateMeshPartAsync("rbxassetid://5139788115")
local Wind  = AssetService:CreateMeshPartAsync("rbxassetid://4681227436")
local Root  = AssetService:CreateMeshPartAsync("rbxassetid://5139788213")

Shock.Color = Color3.fromRGB(248, 248, 248)
Shock.Anchored = true 
Shock.Parent = workspace
Shock.CastShadow = false 
Shock.CanCollide = false 
Shock.Material = "Neon"

Wind.Color = Color3.fromRGB(248, 248, 248)
Wind.Anchored = true 
Wind.Parent = workspace
Wind.CastShadow = false 
Wind.CanCollide = false 
Wind.Material = "Neon"

Root.Color = Color3.fromRGB(248, 248, 248)
Root.Anchored = true 
Root.Parent = workspace
Root.CastShadow = false 
Root.CanCollide = false 
Root.Material = "Neon"



Aura.Color = Color3.fromRGB(4, 175, 236)
Aura.Anchored = true 
Aura.Parent = workspace
Aura.CanCollide = false 
Aura.CastShadow = false 

Train.TextureID = "rbxassetid://743576568"
Train.Anchored = true 
Train.Parent = workspace
Train.CFrame = Train.CFrame * CFrame.Angles(0,-math.rad(90),0)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
-- Ts shake Module was NOT made by me
local ShakeModule = {}

local shakeActive = false
local shakeStartTime = 0
local shakeDuration = 0.8
local initialIntensity = 1

local noise = math.noise 

local function updateCameraShake()
    if not shakeActive then return end
    
    local elapsed = os.clock() - shakeStartTime
    if elapsed >= shakeDuration then
        shakeActive = false
        return
    end
    
    local progress = elapsed / shakeDuration
    local currentIntensity = initialIntensity * (1 - progress^2)
    
    local downwardOffset = Vector3.new(0, -0.5 * currentIntensity, 0)
    local bounceOffset = Vector3.new(0, 0.3 * currentIntensity * math.sin(progress * 10), 0)
    
    local timeFactor = os.clock() * 10
    local shakeX = noise(timeFactor, 0) * currentIntensity * 0.1
    local shakeY = noise(timeFactor, 100) * currentIntensity * 0.1
    local shakeZ = noise(timeFactor, 200) * currentIntensity * 0.1
    
    local rotX = noise(timeFactor, 300) * currentIntensity * 0.05 
    local rotY = noise(timeFactor, 400) * currentIntensity * 0.05 
    local rotZ = noise(timeFactor, 500) * currentIntensity * 0.05 
    
    local offsetPosition = downwardOffset + bounceOffset + Vector3.new(shakeX, shakeY, shakeZ)
    local offsetRotation = CFrame.Angles(rotX, rotY, rotZ)
    
    Camera.CFrame = Camera.CFrame * CFrame.new(offsetPosition) * offsetRotation
end

function ShakeModule.StartShake(intensity, duration)
    initialIntensity = intensity or 1
    shakeDuration = duration or 0.8
    shakeStartTime = os.clock()
    shakeActive = true
end

DhLibrary:AddConnection("ShakeModule", RunService.Heartbeat:Connect(updateCameraShake))
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local StompModule = {
    StompEffect = "HollowPurple",
    StompCooldown = 2,
    lastStompTime = 0,
    CurrentEffects = {}
}
StompModule.StartShake = ShakeModule.StartShake

local Effects = {
    ["RoadRoller"] = function(targetCharacter)
        RoadRoller.Parent = workspace
        RoadRoller.Anchored = true 
        RoadRoller.CFrame = targetCharacter.HumanoidRootPart.CFrame * CFrame.new(0, 40, 0)
        local Sound = Instance.new("Sound",workspace)
        Sound.SoundId = "rbxassetid://4877348549"
        Sound.PlayOnRemove = true 
        Sound:Destroy()    
        
        TweenService:Create(
            RoadRoller,
            TweenInfo.new(0.2), 
            { 
                CFrame = targetCharacter.HumanoidRootPart.CFrame * 
                        CFrame.new(0, 3, 0) * 
                        CFrame.Angles(math.rad(200), -math.rad(200), math.rad(90)) 
            }
        ):Play()

        ShakeModule.StartShake(7, 0.5)

        task.wait(2)
        RoadRoller.CFrame = CFrame.new(20,2000,20)
    end,

    ["Rings"] = function(targetCharacter) 
        local Sound = Instance.new("Sound",workspace)
        Sound.SoundId = "rbxassetid://7456436580"
        Sound.PlayOnRemove = true 
        Sound:Destroy()

        local FakePart = Instance.new("Part",workspace)
        FakePart.Transparency = 1
        FakePart.Position = targetCharacter.Head.Position
        FakePart.Anchored = true 
        FakePart.CanCollide = false 
    
        SonicRings.Parent = FakePart
        task.wait(0.5)
        SonicRings.Parent = workspace
        FakePart:Destroy()
    end,

    ["BlackHole"] = function(targetCharacter)
        BlackHole.Parent = workspace
        BlackHole.Position = targetCharacter:FindFirstChild("UpperTorso").Position + Vector3.new(0,1,0)
        BlackHole.open:Play()
        ShakeModule.StartShake(7, 0.5)

        
        for _, emitter in pairs(BlackHole:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") or emitter:IsA("Beam") then 
                emitter.Enabled = true  
            end 
        end 

        task.wait(1.5)
        task.spawn(function()
            BlackHole.wind:Play()
            BlackHole.bring:Play()

            for _, part in pairs(targetCharacter:GetChildren()) do 
                if not part:IsA("BasePart") then continue end 
                TweenService:Create(part,TweenInfo.new(1.4),{
                    Position = BlackHole.Event.WorldPosition
                }):Play()
            end 
            task.wait(1.5)
            targetCharacter:Destroy()
        end)

        task.wait(3)
        TweenService:Create(BlackHole.wind,TweenInfo.new(0.5),{
            Volume = 0
        }):Play()

        for _, emitter in pairs(BlackHole:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") or emitter:IsA("Beam") then 
                emitter.Enabled = false 
            end 
        end 

        task.wait(2)
        BlackHole.Parent = ReplicatedStorage
    end,

    ["Spirit"] = function(targetCharacter)
        Spirit.Stomp:Play()
        Aura.Transparency = 0
        Aura.Position = targetCharacter:FindFirstChild("UpperTorso").Position 

        ShakeModule.StartShake(7, 0.5)

        TweenService:Create(Aura,TweenInfo.new(2),{
            Position = targetCharacter:FindFirstChild("UpperTorso").Position + Vector3.new(0,50,0),
            Size = Vector3.new(120, 90, 120),
            Transparency = 1
        }):Play()
        local Sound = Instance.new("Sound",workspace)
        Sound.SoundId = "rbxassetid://6290067239"
        Sound.PlayOnRemove = true 
        Sound:Destroy()

        for _, asset in pairs(targetCharacter:GetDescendants()) do 
            if not asset:IsA("BasePart") or not asset:IsA("Decal") then continue end 

            TweenService:Create(asset,TweenInfo.new(0.5),{
                Transparency = 1
            }):Play()
        end 
    end,

    ["Charm"] = function(targetCharacter)
        local Stomp = Charm.FX.Stomp 
        local Sound = Charm.SFX:FindFirstChild("Explosive Hit 5")
        local TargetPos = targetCharacter:FindFirstChild("UpperTorso").Position

        local Emitters = {}

        local PartOne = Stomp.PartOne:Clone()
        local Part    = Stomp.Part:Clone()

        Charm.Parent = workspace

        PartOne.Position = TargetPos
        PartOne.Anchored = true 
        PartOne.Parent = workspace

        Part.Position = TargetPos
        Part.Anchored = true 
        Part.Parent = workspace

        for _, emitter in pairs(PartOne:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                table.insert(Emitters,emitter)
            end 
        end 

        for _, emitter in pairs(Part:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                table.insert(Emitters,emitter)
            end 
        end

        for _, emitter in pairs(Emitters) do 
            emitter.Enabled = true   
        end 

        local old_color = LightingService.FogColor
        Sound:Play()
        for _, asset in pairs(targetCharacter:GetDescendants()) do 
            if not asset:IsA("BasePart") or not asset:IsA("Decal") then continue end 

            TweenService:Create(asset,TweenInfo.new(0.5),{
                Transparency = 1
            }):Play()
        end 
        TweenService:Create(LightingService,TweenInfo.new(0.5),{
            FogColor = Color3.fromRGB(255, 42, 191)
        }):Play()

        task.wait(0.8)
        Part:Destroy()
        PartOne:Destroy()

        TweenService:Create(LightingService,TweenInfo.new(0.5),{
            FogColor = old_color
        }):Play()
        Charm.Parent = ReplicatedStorage
    end,

    ["Thanos"] = function(targetCharacter)
        local Sound = Instance.new("Sound",workspace)
        Sound.SoundId = "rbxassetid://3050376525"
        Sound:Play()

        for _, part in pairs(targetCharacter:GetDescendants()) do 
            if part:IsA("BasePart") or part:IsA("MeshPart") then 
                local Thanos_Effect = Thanos:Clone() 
                Thanos_Effect.Parent = part 
                Thanos_Effect.Color =  ColorSequence.new({ ColorSequenceKeypoint.new(0, part.Color), ColorSequenceKeypoint.new(0.6, Color3.fromRGB(65, 33, 18)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)) })

                TweenService:Create(part,TweenInfo.new(0.5),{
                    Transparency = 1
                }):Play()

                task.delay(0.5,function()
                    Thanos_Effect.Enabled = false 
                end)
                task.wait(.1)
            end 
        end
        repeat task.wait() until Sound.TimeLength == 0
        Sound:Destroy()
    end,

    ["Afterslash"] = function(targetCharacter)
        local AfterSlashEfx = AfterSlash:Clone()
        local UpperTorso = targetCharacter:FindFirstChild("UpperTorso")

        local Part = AfterSlashEfx.Part
        Part.Position = UpperTorso.Position
        Part.Parent = UpperTorso
        Part.Size = Vector3.new(5,7,5)

        for _ = 1, 25 do 
            task.wait(math.random(1,9) / 100)
            local Sound = Instance.new("Sound",Part)
            Sound.SoundId = "rbxassetid://5989945551"
            local DistortionSoundEffect = Instance.new("DistortionSoundEffect",Sound)
            Sound.PlayOnRemove = true 
            Sound:Destroy()
            Part.Position = UpperTorso.Position
        end

        UpperTorso.Position = (CFrame.new(UpperTorso.Position) * CFrame.new(0, -5, 0)).Position
        for _, emitter in pairs(Part:GetDescendants()) do
            if emitter:IsA("ParticleEmitter") then
                emitter.Enabled = false
            end
        end

        task.wait(0.25)
        local Attachment = Instance.new("Attachment",workspace.Terrain)
        Attachment.WorldPosition = UpperTorso.Position

        local Sound = Instance.new("Sound",Part)
        Sound.SoundId = "rbxassetid://4471648128" 
        Sound.PlayOnRemove = true
        Sound:Destroy()

        for _, emitter in pairs(AfterSlashEfx.Burst:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                emitter.Parent = Attachment
                emitter:Emit(emitter:GetAttribute("EmitCount"))
            end 
        end 

        for _, part in pairs(targetCharacter:GetDescendants()) do
            if part:IsA("BasePart") then
                TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
                    Transparency = 1
                }):Play()
            end
        end 
    end,

    ["Rune"] = function(targetCharacter)
        local Rune_fx = Rune:Clone()
            
        local UpperTorso = targetCharacter:FindFirstChild("UpperTorso")
        local OutPosition = UpperTorso.Position + Vector3.new(0,120,0)

        local Effects = {}

        Rune_fx.Parent = workspace

        for i = 5,1, -1 do 
            if i == 1 then 
                local Part = Rune_fx["1"]
                Part.Position = OutPosition
                Part.Sound:Play()

                TweenService:Create(Part,TweenInfo.new(1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0), {
                    Size = Vector3.new(60,0,60),
                    Position = OutPosition
                }):Play()

                table.insert(Effects,Part)

                for _, decal in pairs(Part:GetChildren()) do 
                    if decal:IsA("Decal") then 
                        TweenService:Create(decal,TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                            Transparency = 0
                        }):Play()
                    end 
                end 
            elseif i <= 4 then 
                local Part = Rune_fx[tostring(i)]
                Part.Position = OutPosition
                Part.Sound:Play()

                TweenService:Create(Part,TweenInfo.new(1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0), {
                    Size = Vector3.new(20 * i,0,20 * i),
                    Position = OutPosition
                }):Play()

                table.insert(Effects,Part)

                for _, decal in pairs(Part:GetChildren()) do 
                    if decal:IsA("Decal") then
                        TweenService:Create(decal,TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                            Transparency = 0
                        }):Play()
                    end 
                end 
            elseif i == 5 then 
                local Part = Rune_fx.Part3
                Part.Position = OutPosition
                table.insert(Effects,Part)

                TweenService:Create(Part,TweenInfo.new(1.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, 0), {
                    Size = Vector3.new(89,0,89),
                    Position = OutPosition
                }):Play()

                for _, decal in pairs(Part:GetChildren()) do 
                    if decal:IsA("Decal") then 
                        TweenService:Create(decal,TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                            Transparency = 0
                        }):Play()
                    end 
                end
            end 
            OutPosition = OutPosition - Vector3.new(0,15,0)
            task.wait(i / 6)
        end
        
        task.wait(1)
        for index, effect in pairs(Effects) do 
            TweenService:Create(effect,TweenInfo.new(0.7 + index / 4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0),{
                Size = effect.Size + Vector3.new(effect.Size.Z / 2 + 80 + index * 3,0, effect.Size.Z / 2 + 80 + index * 3),
                Position = effect.Position + Vector3.new(0,effect.Position.Y + 20 + index * 5,0)
            })

            for i, decal in pairs(effect:GetChildren()) do 
                if decal:IsA("Decal") then 
                    TweenService:Create(decal,TweenInfo.new(0.7 + i / 4, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut), {
                        Transparency = 1
                    }):Play()
                end 
            end
        end 

        local CYLD = Rune_fx.CYLD
        CYLD.Anchored = true 
        CYLD.CanCollide = false 
        CYLD.Color = Color3.fromRGB(20,122,255)
        CYLD.Transparency = 0.2
        CYLD.Material = Enum.Material.Neon
        CYLD.Shape = Enum.PartType.Cylinder 

        local Sound = Instance.new("Sound",workspace)
        Sound.SoundId = "rbxassetid://6808975002"
        Sound:Play()

        local UpperTorsoPos = UpperTorso.Position
        local rayOrigin = Vector3.new(UpperTorsoPos.X,UpperTorsoPos.Y + 400,UpperTorsoPos.Z)
        local rayDirection = Vector3.new(UpperTorsoPos.X,UpperTorsoPos.Y - 20 ,UpperTorsoPos.Z)

        local hitPart,hitPosition = workspace:FindPartOnRayWithIgnoreList(
            Ray.new(rayOrigin, ( rayDirection - rayOrigin ).unit * 500),
            { workspace.Ignored, workspace.Players }
        )
        local Magnitude = ( rayOrigin - hitPosition ).Magnitude
        CYLD.Size = Vector3.new(Magnitude,0.5,0.5)
        CYLD.CFrame = CFrame.new(rayOrigin,rayDirection) * CFrame.new(0,0, -Magnitude / 2) * CFrame.Angles(0, 1.5707963267948966, 0)

        coroutine.wrap(function()
            task.spawn(function()
                while task.wait() do 
                    for _, beam in pairs(CYLD:GetChildren()) do
                        if beam:IsA("Beam") then
                            CYLD.Attachment.WorldPosition = CYLD.Position + Vector3.new(0, CYLD.Size.X, 0);
                            CYLD.ATT.WorldPosition = CYLD.Position + Vector3.new(0, -CYLD.Size.X, 0);
                            beam.Width0 = CYLD.Size.Z / 1.5;
                            beam.Width1 = CYLD.Size.Z / 1.5;
                        end
                    end
                    if CYLD.Parent == nil then 
                        break 
                    end 
                end
            end) 

            local Tween = TweenService:Create(CYLD,TweenInfo.new(0.5),{
                Transparency = 0.8,
                Size = Vector3.new(Magnitude,30,30)
            })
            Tween:Play()
            Tween.Completed:Wait()

            TweenService:Create(CYLD,TweenInfo.new(2), {
                Transparency = 1,
                Size = Vector3.new(Magnitude,0,0)
            }):Play()
        end)()
        local Shock_fx = Shock:Clone()
        Shock_fx.Parent = targetCharacter
        Shock_fx.Position = UpperTorsoPos
        TweenService:Create(Shock_fx,TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In),{
            Transparency = 1,
            Size = Shock_fx.Size + Vector3.new(100,20,100),
            Orientation = Vector3.new(0,200,0),
            Position = UpperTorsoPos
        }):Play()

        local Wind_fx = Wind:Clone()
        Wind_fx.Parent = targetCharacter
        Wind_fx.Position = UpperTorsoPos

        TweenService:Create(Wind_fx,TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In),{
            Transparency = 1,
            Size = Wind_fx.Size + Vector3.new(100,5,100),
            Orientation = Vector3.new(0,-200,0),
            Position = UpperTorsoPos
        }):Play()

        local Root_fx = Root:Clone()
        Root_fx.Parent = targetCharacter
        Root_fx.Position = UpperTorsoPos

        TweenService:Create(Root_fx,TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.In),{
            Transparency = 1,
            Size = Root_fx.Size + Vector3.new(100,100,100),
            Orientation = Vector3.new(0,-200,0),
            Position = UpperTorsoPos
        }):Play()
        ShakeModule.StartShake(7, 0.5)

        local Sound = Instance.new("Sound",targetCharacter)
        Sound.SoundId = "rbxassetid://6554844728"
        Sound:Play()

        local Sound = Instance.new("Sound",targetCharacter)
        Sound.SoundId = "rbxassetid://6230611917"
        Sound:Play()

        task.wait(2.5)
        Shock_fx:Destroy()
        task.wait(0.5)
        Rune_fx:Destroy()
        Root_fx:Destroy()
        Wind_fx:Destroy()      
    end,

    ["HollowPurple"] = function(targetCharacter)
        local HollowPurple_fx = HollowPurple:Clone()
        HollowPurple_fx.Parent = workspace

        local HollowRed = HollowPurple_fx.HollowRed
        HollowRed.spawn:Play()

        for _, emitter in pairs(HollowRed:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                emitter:Emit(emitter:GetAttribute("EmitCount"))
            end 
        end 

        local HumanoidRootPart = LocalPlayer.Character.HumanoidRootPart
        local UpperTorso = targetCharacter.UpperTorso

        DhLibrary:AddConnection("Hollow_Red_Tp",RunService.Heartbeat:Connect(function()
            HollowRed.CFrame = CFrame.lookAt(HumanoidRootPart.Position,UpperTorso.Position) * CFrame.new(-8,2,-8)
        end))

        task.wait(.65)

        local HollowBlue = HollowPurple_fx.HollowBlue
        HollowBlue.spawn:Play()

        DhLibrary:AddConnection("Hollow_Blue_Tp",RunService.Heartbeat:Connect(function()
            HollowBlue.CFrame = CFrame.lookAt(HumanoidRootPart.Position,UpperTorso.Position) * CFrame.new(8,2,-8)
        end))

        for _, emitter in pairs(HollowBlue:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                emitter:Emit(emitter:GetAttribute("EmitCount"))
            end 
        end

        task.wait(.65)
        DhLibrary:RemoveConnection("Hollow_Blue_Tp")
        DhLibrary:RemoveConnection("Hollow_Red_Tp")

        local time = os.clock() + 1

        DhLibrary:AddConnection("Hollow_Red_Tp",RunService.Heartbeat:Connect(function()
            HollowRed.CFrame = (CFrame.lookAt(HumanoidRootPart.Position,UpperTorso.Position) * CFrame.new(-8,2,-8)):Lerp(
                CFrame.lookAt(
                    HumanoidRootPart.Position, 
                    UpperTorso.Position
                ) * CFrame.new(0, 2, -8), 1 - math.clamp(time - os.clock(), 0.001, 1)
            )
        end))

        DhLibrary:AddConnection("Hollow_Blue_Tp",RunService.Heartbeat:Connect(function()
            HollowBlue.CFrame = (CFrame.lookAt(HumanoidRootPart.Position, UpperTorso.Position) * CFrame.new(8, 2, -8)):Lerp(
                CFrame.lookAt(
                    HumanoidRootPart.Position, 
                    UpperTorso.Position
                ) * CFrame.new(0, 2, -8), 1 - math.clamp(time - os.clock(), 0.001, 1)
            )
        end))

        local HollowPurple_p = HollowPurple_fx.Purple 
        HollowPurple_p.Anchored = true 
        local SpawnSound = HollowPurple_p.Spawn
        SpawnSound.Parent = HumanoidRootPart
        SpawnSound:Play()
        task.wait(.7)

        for _, emitter in pairs(HollowBlue:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                emitter.Enabled = false
            end 
        end

        for _, emitter in pairs(HollowRed:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                emitter.Enabled = false
            end 
        end 
        DhLibrary:AddConnection("HollowPurpleTP",RunService.Heartbeat:Connect(function(time)
            HollowPurple_p.CFrame = CFrame.lookAt(HumanoidRootPart.Position,UpperTorso.Position) * CFrame.new(0,2,-8)
        end))
        task.wait(.9)
        DhLibrary:RemoveConnection("HollowPurpleTP")
        DhLibrary:RemoveConnection("Hollow_Blue_Tp")
        DhLibrary:RemoveConnection("Hollow_Red_Tp")
        -- Launch Sound
        local Sound = HollowPurple_p:FindFirstChildOfClass("Sound")
        Sound.Parent = HumanoidRootPart
        Sound:Play()
        ShakeModule.StartShake(7, 0.5)

        HollowPurple_p.Smoke.Dust.Enabled = true 
        HollowPurple_p.Smoke.Rocks.Enabled = true 

        for _, emitter in pairs(HollowPurple_p.Wind:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                emitter.Enabled = true 
            end 
        end 

        for _, emitter in pairs(HollowPurple_p.Launch:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                emitter:Emit(emitter:GetAttribute("EmitCount"))
            end 
        end

        local LookVector = CFrame.lookAt(HumanoidRootPart.Position,UpperTorso.Position).LookVector.Unit * 140 * Vector3.new(1,0,1)
        DhLibrary:AddConnection("HollowPurpleTP",RunService.Heartbeat:Connect(function(time)
            HollowPurple_p.Position = HollowPurple_p.Position + LookVector * time 
        end))

        DhLibrary:AddConnection("TeleportPlayer",RunService.Heartbeat:Connect(function()
            for _, part in pairs(targetCharacter:GetChildren()) do 
                if part:IsA("BasePart") then 
                    part.CFrame = CFrame.new(HollowPurple_p.Position)
                end 
            end 
        end))


        local Blur = HollowPurple_fx.Blur 
        local ColorCorrection = HollowPurple_fx.ColorCorrection

        Blur.Parent = Camera 
        ColorCorrection.Parent = Camera 

        TweenService:Create(Blur,TweenInfo.new(0.15),{
            Size = 24
        }):Play()

        TweenService:Create(ColorCorrection,TweenInfo.new(0.15),{
            Contrast = 6
        }):Play()

        task.delay(0.05,function()  
            TweenService:Create(Blur,TweenInfo.new(0.15),{
                Size = 0
            }):Play()

            TweenService:Create(ColorCorrection,TweenInfo.new(0.15),{
                Contrast = 0
            }):Play()
            task.wait(0.5)
        end)

        task.wait(3)

        for _, emitter in pairs(HollowPurple_p:GetDescendants()) do 
            if emitter:IsA("ParticleEmitter") then 
                emitter.Enabled = false  
            end 
        end 

        task.wait(3)
        HollowPurple_fx:Destroy()
        DhLibrary:RemoveConnection("HollowPurpleTP")
        DhLibrary:RemoveConnection("TeleportPlayer")        
    end,
}
-- local function cause global is useless
local function effect(targetCharacter)
    local currentTime = tick()
    if currentTime - StompModule.lastStompTime < StompModule.StompCooldown then 
        return 
    end
    StompModule.lastStompTime = currentTime
    if Effects[StompModule.StompEffect] then 
        Effects[StompModule.StompEffect](targetCharacter,LocalPlayer.Character)
    end 
end 

function StompModule:AddStompEffect(options)
    local Name: String = options.Name
    local Callack:  (...any) -> ...any = options.Callback
    
    Effects[Name] = Callback
    table.insert(StompModule.CurrentEffects,Name)
end 

function StompModule:Toggle(state)
    if not state then 
        DhLibrary:RemoveConnection("StompEffect")
        return 
    end 

    DhLibrary:AddConnection("StompEffect", RunService.Heartbeat:Connect(function()
        local playerCharacter = LocalPlayer.Character
        if not playerCharacter or not playerCharacter:FindFirstChild("LowerTorso") or not playerCharacter:FindFirstChild("UpperTorso") then
            return
        end
        
        local rayOrigin = playerCharacter.LowerTorso.Position
        local rayDirection = Vector3.new(0, -playerCharacter.UpperTorso.Size.y * 4.5, 0)
        
        local whitelist = {}
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= Services.LocalPlayer and player.Character and not  whitelist[player.Character] then
                table.insert(whitelist, player.Character)
            end
        end
        
        if #whitelist > 0 then
            local hitPart, hitPosition, hitNormal = workspace:FindPartOnRayWithWhitelist(
                Ray.new(rayOrigin, rayDirection),
                whitelist,
                false,
                true
            )
            
            if hitPart then
                local stompedCharacter = hitPart:FindFirstAncestorOfClass("Model")
                if stompedCharacter and stompedCharacter:FindFirstChild("HumanoidRootPart") and stompedCharacter:FindFirstChild("BodyEffects") and stompedCharacter.BodyEffects.SDeath.Value and DhLibrary:IsAnimPlaying(playerCharacter,2816431506) then
                    effect(stompedCharacter)
                end
            end
        end
    end))
end 

for name, func in pairs(Effects) do 
    table.insert(StompModule.CurrentEffects,name)
end 

return StompModule,DhLibrary,"Legion is back"
