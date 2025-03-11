-- Note this is like start of development so everything is like really REALLY in beta so i dont really recommend using it !
repeat task.wait() until game:IsLoaded()


local function include(module)   
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/penguin-cmyk/legion/refs/heads/main/utils/"..module..".lua"))()
end 
-- Inclusions
local DhLibrary = include("dh_library")
local UiLibrary = include("new_ui")

local Animations = DhLibrary:Animations()
local Services   = DhLibrary:Services()
local Sounds     = DhLibrary:Sounds()

local Modules    = {}
local States     = {}
local Tools      = {}

local Flags      = UiLibrary.flags

local MainEvent  = Services.MainEvent
local PlaceId    = game.PlaceId

local TeleportService   = game:GetService("TeleportService")
local LightingService   = game:GetService("Lighting")
local UserInputService  = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local LocalPlayer       = Services.LocalPlayer
local RunService        = Services.RunService
local Workspace         = Services.Workspace

local Skins   = ReplicatedStorage:WaitForChild("Bike").Skins
local Camera  = Workspace.CurrentCamera 

local Starting = true 

UiLibrary:notification({text = "Legion loading..."})
-- Modules 
do 
    function Modules:GetChar(option: string): Instance
        return option ~= nil and LocalPlayer.Character:FindFirstChild(option) or LocalPlayer.Character
    end 

    function Modules:Void(character: Model)
        local BodyPosition = character.UpperTorso:FindFirstChild("BodyPosition")
        if BodyPosition then 
            BodyPosition:Destroy()
        end 

        for _,part in pairs(Character:GetChildren()) do 
            if part:IsA("BasePart") then 
                part.Velocity = Vector3.new(9e9,9e9,9e9)
            end 
        end 

        task.wait(.1)
        MainEvent:FireServer("Grabbing",false)
    end 

    function Modules:JoinServer(job_id: string)
        TeleportService:TeleportToPlaceInstance(PlaceId,job_id)
    end 

    function Modules:Modify(attribute: string, value: string | number)
        for _, skin in pairs(Skins:GetChildren()) do 
            if not skin:IsA("Model") then 
                continue
            end 

            local Attribute = skin:GetAttribute(attribute)
            if Attribute ~= nil then 
                skin:SetAttribute(attribute, value)
            end 
        end 
    end 

    function Modules:Delete(parent: Instance, options: { [any]: any })
        for _, instance in pairs(parent:GetDescendants()) do 
            if table.find(options,instance.Name) then 
                instance:Destroy()
            end 
        end 
    end 

    function Modules:GetForwardPosition(distance: number)
        local HumanoidRootPart = Modules:GetChar("HumanoidRootPart")
        return HumanoidRootPart.Position + ( HumanoidRootPart.CFrame.LookVector * distance )
    end 

    function Modules:CFrameSpeed(state: boolean)
        if not state or not States.CanCFrame then 
            DhLibrary:RemoveConnection("CFrameSpeed")
            return 
        end
        DhLibrary:AddConnection("CFrameSpeed",Services.RunService.Heartbeat:Connect(function()
            if not States.CanCFrame then 
                DhLibrary:RemoveConnection("CFrameSpeed")
                return 
            end 
            local Char: Model = Modules:GetChar()
            local Humanoid: Humanoid = Char:FindFirstChild("Humanoid")

            Char.HumanoidRootPart.CFrame = Char.HumanoidRootPart.CFrame + Humanoid.MoveDirection * States.CFrameSpeed.Speed
        end))
    end 

    function Modules:Fly()
        local HumanoidRootPart: Part = Modules:GetChar("HumanoidRootPart")
        local Humanoid: Humanoid = Modules:GetChar("Humanoid")

        if not States.CanFly or States.CurrentlyFlying then 
            DhLibrary:RemoveConnection("Fly")
            States.CurrentlyFlying = false 
            Humanoid.PlatformStand = false 
            return 
        end 

        States.CurrentlyFlying = true 
        Humanoid.PlatformStand = true 

        DhLibrary:AddConnection("Fly",RunService.Heartbeat:Connect(function()
            if not States.CanFly then 
                DhLibrary:RemoveConnection("Fly")
                States.CurrentlyFlying = false 
                Humanoid.PlatformStand = false 
                return
            end 
            
            local Speed: number = Flags["FlySpeed"] or 2
            local MoveDirection: Vector3 = Vector3.new(
                UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or ( UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0 ),
                UserInputService:IsKeyDown(Enum.KeyCode.Space) and 0.2,
                UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or ( UserInputService:IsKeyDown(Enum.KeyCode.W) and -1 or 0 )
            )

            HumanoidRootPart.Velocity = Vector3.zero 
            HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position) * 
                Camera.CFrame.Rotation * 
                CFrame.new(
                    MoveDirection.X * Speed,
                    MoveDirection.Y * Speed,
                    MoveDirection.Z * Speed
                )
        end))
    end
    
    function Modules:VehicleFly()
        local Vehicle: Model = DhLibrary:GetCar()
        if not Vehicle or States.CurrentlyVehicleFlying then 
            States.AllowedVehicleFly = false 
            States.CurrentlyVehicleFlying = false
            task.wait(.2)
            States.AllowedVehicleFly = true 
            return 
        end 

        States.CurrentlyVehicleFlying = true 

        local BodyPosition = DhLibrary:Create("BodyPosition",{
            Parent = Vehicle,
            MaxForce = Vector3.new(9e9, 9e9, 9e9),
            Position = Vehicle.Position,
        })
        local BodyGyro = DhLibrary:Create("BodyGyro",{
            Parent = Vehicle,
            MaxTorque = Vector3.new(9e9, 9e9, 9e9),
            CFrame = Vehicle.CFrame,
        })

        DhLibrary:AddConnection("VehicleFly",RunService.Heartbeat:Connect(function()
            if not States.AllowedVehicleFly then 
                DhLibrary:RemoveConnection("VehicleFly")
                BodyPosition:Destroy()
                BodyGyro:Destroy()
                return 
            end 

            local Speed: number = Flags["CarFlySpeed"] or 2
            local MoveDirection: Vector3 = Vector3.new(
                UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or ( UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0 ),
                UserInputService:IsKeyDown(Enum.KeyCode.Space) and 0.2,
                UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or ( UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0 )
            )

            BodyGyro.CFrame = CFrame.new(Vehicle.Position) * Camera.CFrame.Rotation
            BodyPosition.Position = BodyPosition.Position + (BodyGyro.CFrame.LookVector * MoveDirection.Z + BodyGyro.CFrame.RightVector * MoveDirection.X + Vector3.new(0, MoveDirection.Y, 0)) * Speed 
        end))
    end 

    function Modules:AntiStomp(state: boolean)
        if not state then 
            DhLibrary:RemoveConnection("AntiStomp")
            return 
        end 

        local Character: Model = Modules:GetChar()
        local BodyEffects: Folder = Character:WaitForChild("BodyEffects")
        local Ko_Value: BoolValue = BodyEffects:FindFirstChild("K.O")

        local HumanoidRootPart: Part = Character:WaitForChild("HumanoidRootPart")

        DhLibrary:AddConnection("AntiStomp",Ko_Value:GetPropertyChangedSignal("Value"):Connect(function()
            if Ko_Value.Value then 
                Character.Humanoid:ChangeState("Dead")
            end 
        end))
    end 

    function Modules:NoClip(state: boolean)
        if not state then 
            DhLibrary:CanCollide(Modules:GetChar(),true)
            DhLibrary:RemoveConnection("NoClip")
            return 
        end 

        DhLibrary:AddConnection("NoClip",RunService.Heartbeat:Connect(function()
            local Character: Model = Modules:GetChar()
            DhLibrary:CanCollide(Character,false)
        end))
    end 

    function Modules:NoJump(state: boolean)
        local Character: Model = Modules:GetChar()
        local Humanoid: Humanoid = Character:WaitForChild("Humanoid")

        Humanoid.UseJumpPower = not state 
    end 

    function Modules:AntiSlow(state: boolean)
        if not state then 
            DhLibrary:RemoveConnection("AntiSlow")
            return 
        end 

        DhLibrary:AddConnection("AntiSlow",RunService.Heartbeat:Connect(function()
            local BodyEffects: Folder = Modules:GetChar("BodyEffects")
            Modules:Delete(BodyEffects,{
                "NoWalkSpeed",
                "NoJumping",
                "ReduceWalk"
            })
            if BodyEffects:FindFirstChild("Reload") then 
                BodyEffects:FindFirstChild("Reload").Value = false 
            end 
        end))
    end 

    function Modules:AntiSit(state: boolean)
        for _, seat in pairs(Workspace:GetDescendants()) do 
            if seat:IsA("Seat") then 
                seat.Disabled = state 
            end 
        end 
    end 

    function Modules:NoGunCd(state: boolean)
        if not state then 
            for _, cooldown in pairs(game:GetDescendants()) do 
                if cooldown.Name == "ShootingCooldown" or cooldown.Name == "ToleranceCooldown" and cooldown:IsA("ValueBase") then 
                    cooldown.Value = 20
                end 
            end

            DhLibrary:RemoveConnection("NoGunCd")
            print("[DEUBG] Disabled Rapid fire")
            return 
        end 
        print("[DEUBG] Enabled Rapid fire")
        for _, cooldown in pairs(game:GetDescendants()) do 
            if cooldown.Name == "ShootingCooldown" or cooldown.Name == "ToleranceCooldown" and cooldown:IsA("ValueBase") then 
                cooldown.Value = 0
            end 
        end
        
        DhLibrary:AddConnection("NoGunCd",game.DescendantAdded:Connect(function(cooldown)
            if cooldown.Name == "ShootingCooldown" or cooldown.Name == "ToleranceCooldown" and cooldown:IsA("ValueBase") then 
                cooldown.Value = 0
            end
        end))
    end 
end 
-- DhLibrary playaudio fix
do 
    local FakeSound = Instance.new("Sound",Services.Workspace)

    function DhLibrary:StopAudio()
        FakeSound:Stop()
        Services.MainEvent:FireServer("BoomboxStop")
    end 
    function DhLibrary:PlayAudio(id: number)
        local BoomBox = Services.LocalPlayer.Backpack:FindFirstChild("[Boombox]")
        if Services.LocalPlayer.Backpack:FindFirstChild("[Boombox]") then 
            Services.LocalPlayer.Backpack:FindFirstChild("[Boombox]").RequiresHandle = false 
    
            Services.LocalPlayer.Backpack:FindFirstChild("[Boombox]").Parent = Services.LocalPlayer.Character
            BoomBox = Services.LocalPlayer.Character:FindFirstChild("[Boombox]")
            Services.MainEvent:FireServer("Boombox",tonumber(id))
            BoomBox.Parent = Services.LocalPlayer.Backpack
            task.wait(.2)
            Services.LocalPlayer.PlayerGui.MainScreenGui.BoomboxFrame.Visible = false 
            
            Services.LocalPlayer.Character.LowerTorso:WaitForChild("BOOMBOXSOUND")
            
            task.spawn(function()
                repeat wait() until Services.LocalPlayer.Character.LowerTorso:WaitForChild("BOOMBOXSOUND").SoundId == "rbxassetid://"..tostring(id)
                task.wait(Services.LocalPlayer.Character.LowerTorso:WaitForChild("BOOMBOXSOUND").TimeLength)
            end)
        else 
            task.spawn(function()
                    print("Sound playing")
                    FakeSound.SoundId = "rbxassetid://"..tostring(id)
                    FakeSound:Play()
                    task.wait(FakeSound.TimeLength)
            end)
        end 
        if BoomBox then 
            return Services.LocalPlayer.Character.LowerTorso:WaitForChild("BOOMBOXSOUND").TimeLength
        else 
            return FakeSound.TimeLength
        end 
    end 
 
end 

-- Ui Library
local MainWindow = UiLibrary:window({
    name = "Legion [GRABS]",
    Size = UDim2.fromOffset(500,650)
})

local MainTab    = MainWindow:tab({ name = "Main" })
local MiscTab    = MainWindow:tab({ name = "Misc" })

local MainSection = MainTab:section({ name = "Main", fill = 0.2 })

MainWindow.toggle_playerlist(false)
MainWindow.toggle_list(false)

MainTab.open_tab()

-- Grab Modules
do 
    -- Was too bored to rewrite InitGrab and Grab
    function Modules:InitGrab()
        DhLibrary:RemoveConnection("Grab")
        DhLibrary:RemoveConnection("GrabMovement")
        repeat task.wait() until LocalPlayer.Character:FindFirstChild("BodyEffects") ~= nil 
        DhLibrary:AddConnection("Grab",Modules:GetChar("BodyEffects").Grabbed:GetPropertyChangedSignal("Value"):Connect(function()
            local GrabbedChar = Modules:GetChar("BodyEffects").Grabbed.Value 
            if GrabbedChar ~= nil then
                Modules:Delete(GrabbedChar,{"BodyVelocity","BodyGyro","BodyPosition"})
                Modules:Grab(GrabbedChar)
                DhLibrary:NoVelocity(GrabbedChar)
                DhLibrary:CanCollide(GrabbedChar,false)
                
                return 
            end 

            DhLibrary:StopAnimation(LocalPlayer.Character,3135389157)
        end))
    end 

    function Modules:Grab(char: Model)
        assert(char ~= nil,"Character is nil")
        if not States.Grab then 
            DhLibrary:RemoveConnection("GrabMovement")
            return 
        end 

        States.GrabbedChar = char 
        States.LastGrabbed = char
        Modules:Delete(char,{"BodyVelocity","BodyGyro","BodyPosition"})
        DhLibrary:StopAnimation(Services.LocalPlayer.Character,11075367458)
        

        repeat task.wait() until char:FindFirstChild("GRABBING_CONSTRAINT")
        local GrabbingConstraint = char:FindFirstChild("GRABBING_CONSTRAINT")
        local Character  = Modules:GetChar("")
        local UpperTorso = char:FindFirstChild("UpperTorso")
        if not GrabbingConstraint:FindFirstChild("H")  or not Character then return end 

        local BodyPosition = DhLibrary:Create("BodyPosition",{
            D = 200,
            MaxForce = Vector3.new(10000, 10000, 10000),
            Position = Character:FindFirstChild("RightHand").Position - Vector3.new(0,1,0),
            Parent = UpperTorso
        })

        local BodyGyro = DhLibrary:Create("BodyGyro",{
            D = 100,
            MaxTorque = Vector3.new(10000, 10000, 10000),
            CFrame = CFrame.new(UpperTorso.Position,Character:FindFirstChild("HumanoidRootPart").Position),
            Parent = UpperTorso
        })

        GrabbingConstraint.H.Length = 9e9 
        DhLibrary:PlayAudio(Flags["CustomSound"] or 4799902666) 

        task.spawn(function()
            task.wait(LocalPlayer.Character.LowerTorso:WaitForChild("BOOMBOXSOUND").TimeLength - 0.1)
            DhLibrary:StopAudio()
        end)

        DhLibrary:PlayAnimation(Services.LocalPlayer.Character,3135389157,0,.1)
        DhLibrary:AddConnection("GrabMovement",Services.RunService.Heartbeat:Connect(function()
            local Character = Modules:GetChar()
            local UpperTorso = char:FindFirstChild("UpperTorso")
            if not States.Grab then 
                DhLibrary:StopAnimation(Character,3135389157)
                DhLibrary:RemoveConnection("GrabMovement")
                return 
            end  
            if States.GrabbedChar ~= nil 
            and Character ~= nil
             and Character:FindFirstChild("BodyEffects") 
             and Modules:GetChar("BodyEffects").Grabbed.Value  ~= nil 
             and States.Grab and char.UpperTorso:FindFirstChild("BodyPosition") then  
                local Position = Character:FindFirstChild("RightHand").Position - Vector3.new(0,1,0) 
                if Flags["grab_mode"] == "Grab" then 
                    Position = Character:FindFirstChild("RightHand").Position - Vector3.new(0,1,0)
                    if not DhLibrary:IsAnimPlaying(Character,3135389157) then 
                        DhLibrary:PlayAnimation(Character,3135389157,0,.1)
                    end 
                elseif Flags["grab_mode"] == "Behind" then 
                    Position = Character:FindFirstChild("HumanoidRootPart").Position - Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 3
                    DhLibrary:StopAnimation(Character,3135389157)
                    DhLibrary:StopAnimation(Character,11075367458)
                elseif Flags["grab_mode"] == "Infront" then 
                    Position = Modules:GetForwardPosition(3)
                    DhLibrary:StopAnimation(Character,3135389157)
                    DhLibrary:StopAnimation(Character,11075367458)
                elseif Flags["grab_mode"] == "Custom" then 
                    Position = Character:FindFirstChild("HumanoidRootPart").Position + Vector3.new(Flags["xAxis"],Flags["yAxis"],Flags["zAxis"])
                    DhLibrary:StopAnimation(Character,3135389157)
                    DhLibrary:StopAnimation(Character,11075367458)
                end 
                local Orientation = CFrame.new(UpperTorso.Position,Character:FindFirstChild("HumanoidRootPart").Position)
                
                if Flags["grab_mode"] == "Infront" then 
                    Orientation = CFrame.new(UpperTorso.Position,Character:FindFirstChild("HumanoidRootPart").Position + Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * -5)
                else 
                    Orientation = CFrame.new(UpperTorso.Position,Character:FindFirstChild("HumanoidRootPart").Position)
                end 

                BodyGyro.CFrame = Orientation
				BodyPosition.Position = Position
                
             elseif Modules:GetChar("BodyEffects"):FindFirstChild("Grabbed") and Modules:GetChar("BodyEffects").Grabbed.Value  == nil then 
                DhLibrary:StopAnimation(Character,3135389157)
                States.GrabbedChar = nil
            end 
        end))
    end 

    function Modules:DestroyTool(name: string)
        local Tool: Tool = LocalPlayer.Backpack:FindFirstChild(name) or LocalPlayer.Character:FindFirstChild(name)
        if Tool then 
            Tool:Destroy()
        end 

        DhLibrary:RemoveConnection(name.."_tool")
    end 

    function Modules:GrabTool(options: { [any]: any })
        local Character: Model = Modules:GetChar()
        local Backpack: Backpack = LocalPlayer.Backpack

        local tool_callback: (...any) -> ...any = options.Callback 
        local name: string = options.Name or options.name 
        local description: string = options.Description
        local stopanimation: boolean = options.StopAnimations

        Tools[name] = {}

        local NewTool: Tool = DhLibrary:Create("Tool",{
            Name = name,
            RequiresHandle = false,
            ToolTip = description
        })
        DhLibrary:AddConnection(name.."_tool",NewTool.Activated:Connect(function()
            Tools[name]["State"] = true

            if not States.Grab or not States.GrabbedChar then 
                return 
            end

            States.Grab = false 

            local success,err = pcall(function()
                local Character: Model = LocalPlayer.Character
                local GrabbedChar: Model =  Character.BodyEffects:FindFirstChild("Grabbed").Value 

                if Character == nil then 
                    error("Localplayers character doesn't exist wth???")
                end 

                if GrabbedChar == nil then 
                    return 
                end 

                if stopanimation then 
                    DhLibrary:StopAnimation(Character,3135389157)
                    DhLibrary:StopAnimation(Character,11075367458)
                end 

                tool_callback(GrabbedChar,Character)

                NewTool.Parent = LocalPlayer.Backpack
                NewTool.Parent = LocalPlayer.Character
            end)

            if not success then 
                print(err)
            end 
        end))

        MainSection:toggle({
            name = name,
            default = false,
            callback = function(state)
                if state then 
                    NewTool.Parent = LocalPlayer.Backpack
                else 
                    NewTool.Parent = nil 
                end 
            end 
        })
    end 
end 

-- MainTab: Grabs
-- MiscTab planned: Player (fly,cframepseed,antistomp,etcc)
do 
    local Movement = MiscTab:section({ name = "Movement", side = "left" })
    local Player = MiscTab:section({ name = "Player", side = "left" })
    local Server = MiscTab:section({ name = "Server", side = "right" })
    local UiSettings = MiscTab:section({ name = "Ui Settings", side = "right" })
    -- Movement
    Movement:toggle({
        name = "Toggle Vehicle Fly",
        default = false,
        callback = function(state)
            States.AllowedVehicleFly = state 
        end 
    })
    Movement:keybind({
        default = Enum.KeyCode.End,
        callback = function()
            Modules:VehicleFly()
        end 
    })
    Movement:toggle({
        name = "Toggle Player Fly",
        default = false,
        callback = function(state)
            States.CanFly = state 
        end 
    })

    Movement:keybind({
        default = Enum.KeyCode.End,
        callback = function()
            Modules:Fly()
        end 
    })
    Movement:slider({
        name  = "Player Fly Speed",
        suffix = "",
        flag = "FlySpeed",
        default = 2,
        min = 1,
        max = 20,
    })
    Movement:slider({
        name  = "Vehicle Fly Speed",
        suffix = "",
        flag = "CarFlySpeed",
        default = 2,
        min = 1,
        max = 20,
    })
    -- Player
    Player:toggle({
        name = "NoClip",
        default = false,
        callback = function(state)
            Modules:NoClip(state)
        end 
    })
    Player:toggle({
        name = "No Jump Cooldown",
        default = false,
        callback = function(state)
            if not Starting then 
                States.Jumpcooldown = state 
                Modules:NoJump(state)
            end 
        end 
    })
    Player:toggle({
        name = "Anti sit",
        default = false,
        callback = function(state)
            if not Starting then 
                Modules:AntiSit(state)
            end 
        end 
    })
    Player:toggle({
        name = "Anti Slow",
        default = false,
        callback = function(state)
            if not Starting then 
                Modules:AntiSlow(state)
            end 
        end 
    })
    Player:toggle({
        name = "Anti Stomp",
        default = false,
        callback = function(state)
            if not Starting then 
                States.AntiStomp = state
                Modules:AntiStomp(state)
            end 
        end 
    })
    Player:toggle({
        name = "Rapid Fire",
        default = false,
        callback = function(state)
            if not Starting then 
                Modules:NoGunCd(state)
            end 
        end 
    })
    --Server
    Server:textbox({flag = "job_id"})
    Server:button({
        name = "Join Server",
        callback = function()
            Modules:JoinServer(game.JobId or Flags["job_id"])
        end 
    })
    Server:button({
        name = "Copy JobId",
        callback = function()
            setclipboard(`game:GetService("TeleportService"):TeleportToPlaceInstance({PlaceId},"{game.JobId}")`)
        end 
    })
    --- UiSettings
    UiSettings:toggle({
        name = "Watermark",
        default = true,
        callback = function(state)
            if not Starting then 
                MainWindow.toggle_watermark(state)
            end 
        end 
    })
    local last = Color3.fromHex("#6464FF");
    UiSettings:colorpicker({
        name = "Ui Color",
        color = Color3.fromHex("#6464FF"), 
        callback = function(color)
            if not Starting and color ~= last then 
                last = color 
                UiLibrary:update_theme("accent", color)
            end 
        end
    })

    UiSettings:keybind({
        name = "Ui Keybind",
        default = Enum.KeyCode.V,
        callback = MainWindow.set_menu_visibility
    })
end 

do 
    function Modules:ImpactFrame()
        local Black = DhLibrary:Create("ColorCorrectionEffect",{
            TintColor = Color3.fromRGB(0,0,0),
        })
        local White = DhLibrary:Create("Highlight",{
            FillColor = Color3.fromRGB(255,255,255),
            FillTransparency = 0
        })
        task.wait(.1)
        Black.Parent = LightingService
        White.Parent = Modules:GetCharacter("")
        task.wait(.1)
        White.FillColor = Color3.fromRGB(0,0,0)
        Black.TintColor = Color3.fromRGB(255,255,255)
        Black.Brightness = 1
        task.wait(.1)
        White:Destroy()
        Black:Destroy()
    end 
    
    function Modules:CloneChar(Character)
        local LocalChar = Modules:GetChar("")
        LocalChar.Archivable = true 
        
        local ClonedChar = LocalChar:Clone() 
        ClonedChar.Parent = Services.Workspace
        ClonedChar.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0,2,0)
    
        ClonedChar.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

        if ClonedChar:FindFirstChild("ForceField") then 
            ClonedChar:FindFirstChild("ForceField"):Destroy()
        end 
    
        local Player = Services.Players:FindFirstChild(Character.Name)
        
        if not Player then 
            return 
        end 
    
        local HumanoidDescription = Services.Players:GetHumanoidDescriptionFromUserId(Player.UserId)
        ClonedChar.Humanoid:ApplyDescription(HumanoidDescription)
    
        LocalChar.Archivable = false

        ClonedChar.Humanoid.BodyWidthScale.Value = Character.Humanoid.BodyWidthScale.Value
        ClonedChar.Humanoid.BodyProportionScale.Value = Character.Humanoid.BodyProportionScale.Value
        ClonedChar.Humanoid.BodyDepthScale.Value = Character.Humanoid.BodyDepthScale.Value
        ClonedChar.Humanoid.HeadScale.Value = Character.Humanoid.HeadScale.Value

        for _, accessory in pairs(ClonedChar:GetDescendants()) do 
            if accessory:IsA("Accessory") or accessory:IsA("ShirtGraphic") or accessory:IsA("Shirt") or accessory:IsA("Pants") then
                accessory:Destroy()
            end
            if accessory:IsA("BasePart") then 
                accessory.Transparency = 1
            end 
        end

        return ClonedChar 
    end 
    
    function Modules:AlignControl(part,part1,Offset)
        part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        part.Velocity = Vector3.new(0, 0, 0)
        part.CFrame = part1.CFrame * (Offset or CFrame.new())
        part.CanCollide = false
        part1.CanCollide = false
    end
end 
do 
    local Chain = DhLibrary:Create("Beam",{
        Texture = "rbxassetid://12706577665",
        Enabled = true,
        Parent  = Services.Workspace,
        Width0  = 1,
        Width1  = 1,
        TextureSpeed = 0,
        Segments = 10,
        CurveSize0 = 0,
        CurveSize1 = 0,
        TextureLength = 5,
        Transparency = NumberSequence.new(0),
        FaceCamera = true,
        Color = ColorSequence.new(Color3.fromRGB(170,170,170),Color3.fromRGB(170,170,170),Color3.fromRGB(170,170,170))
    })
    MainSection:toggle({
        name = "Grab",
        default = false,
        callback = function(state)
            States.Grab = state
            if state then 
                Tools["GrabReal"] = DhLibrary:Create("Tool",{
                    Parent = LocalPlayer.Backpack,
                    RequiresHandle = false,
                    ToolTip = "Enabled Grab",
                    Name = "Activate"
                })

                Tools["GrabReal"].Activated:Connect(function()
                    MainEvent:FireServer("Grabbing",true)
                    repeat task.wait() until LocalPlayer.Character:FindFirstChild("BodyEffects") and LocalPlayer.Character:FindFirstChild("BodyEffects").Grabbed.Value ~= nil 
                    local Character: Model = LocalPlayer.Character:FindFirstChild("BodyEffects").Grabbed.Value 
                    if Character:FindFirstChild("GRABBING_CONSTRAINT"):FindFirstChild("H") then 
                        Modules:Grab(Character)
                    end 
                end)
            else 
                if Tools["GrabReal"] then Tools["GrabReal"]:Destroy() end 
            end 
        end 
    })
    MainSection:dropdown({
        flag = "grab_mode",
        items = {
            "Grab",
            "Behind",
            "Infront",
            "Custom"
        },
        multi = false,
        tooltip = "Changes the grabbing mode"
    })
    MainSection:textbox({
        placeholdertext = "Custom sound id",
        flag = "CustomSound"
    })
    MainSection:slider({
        suffix = "",
        flag = "xAxis",
        default = 2,
        min = 0,
        max = 20,
    })
    MainSection:slider({
        suffix = "",
        flag = "yAxis",
        default = 2,
        min = 0,
        max = 20,
    })
    MainSection:slider({
        suffix = "",
        flag = "zAxis",
        default = 2,
        min = 0,
        max = 20,
    })
    MainSection:toggle({
        name = "Effects",
        default = true,
        callback = function(state)
            States.Effects = state
        end 
    })
    Modules:GrabTool({
        Name = "Get Over Here",
        StopAnimations = true,
        Description = "Mortal combat get over here",
        Callback = function(Grabbed,Character)
            DhLibrary:PlayAudio(8643750815)
            task.wait(1.6)
            DhLibrary:StopAudio()
            DhLibrary:PlayAudio(7592607446)
            DhLibrary:PlayAnimation(Character,16768625968)
            if GrabStates.Effects then 
                Chain.Attachment0 = DhLibrary:Create("Attachment",{
                    Parent = Grabbed:FindFirstChild("UpperTorso"),
                })
                Chain.Attachment1 = DhLibrary:Create("Attachment",{
                    Parent = Character:FindFirstChild("RightHand"),
                })
            end
            task.wait(1.1)
            
            DhLibrary:Tween(
                Grabbed.UpperTorso:FindFirstChild("BodyPosition"),
                0.6,
                { Position = Character.HumanoidRootPart.Position }
            )
         
            task.wait(0.6)
            Chain.Attachment0 = nil
            Chain.Attachment1 = nil 
            DhLibrary:StopAudio()
            States.Grab = true 
        end, 
    })

    Modules:GrabTool({
        Name = "Made In Heaven",
        StopAnimation = true,
        Description = "",
        Callback = function(Grabbed,Character)
            local OldFov,OldFog,OldFogColor = Camera.FieldOfView,LightingService.FogEnd,LightingService.FogColor
            
            DhLibrary:PlayAudio(8004825017)
            DhLibrary:Chat("Made In Heaven...")
    
            Character:FindFirstChild("HumanoidRootPart").CFrame = Grabbed:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(1,0,3)
            DhLibrary:PlayAnimation(Character,11394033602)
    
            if States.Effects then 
                DhLibrary:Tween(Camera,1,{ FieldOfView = 120 })
                DhLibrary:Tween(LightingService,1, { FogEnd = 20 })
                DhLibrary:Tween(LightingService,1, { FogColor = Color3.fromRGB(255,255,255) })
            end 
            DhLibrary:Tween(Character:FindFirstChild("Humanoid"), 1,{ HipHeight = 3.6 })
            task.wait(1)
    
            DhLibrary:Chat("Heaven has arrived..")
            DhLibrary:Tween(Grabbed:FindFirstChild("UpperTorso").BodyPosition,0.5,{ Position = Modules:GetForwardPosition(10) + Vector3.new(0,10,0) })
            task.wait(7)
            DhLibrary:Void(Grabbed)
            task.wait(0.6)
            DhLibrary:StopAudio()

            DhLibrary:StopAnimation(Character,11394033602)
            States.Grab = true
    
            DhLibrary:Tween(Camera,1,{ FieldOfView = OldFov })
            DhLibrary:Tween(LightingService,1, { FogEnd = OldFog })
            DhLibrary:Tween(LightingService,1, { FogColor = OldFogColor })
    
            DhLibrary:Tween(Character:FindFirstChild("Humanoid"), 1,{ HipHeight = 2 })
        end,
    })

    Modules:GrabTool({
        Name = "Orbit",
        Description = "Orbits the players parts around you",
        StopAnimations = true,
        Callback = function(Grabbed,Character)
            local currentTime: number = 0;
            local Character: Model = Modules:GetChar()

            DhLibrary:AddConnection("Orbit",RunService.Heartbeat:Connect(function(delta)
                if Character.BodyEffects.Grabbed.Value == nil or not Tools["Orbit"]["State"] then 
                    States.Grab = true 
                    DhLibrary:RemoveConnection("Orbit")
                    return 
                end 
                currentTime = currentTime + delta
                Grabbed.UpperTorso.CFrame      = CFrame.Angles(math.pi * 0.1, 1.5 * math.pi * currentTime, 0)* CFrame.new(1, 2, 5) + Character.HumanoidRootPart.Position
                Grabbed.LowerTorso.CFrame      = CFrame.Angles(math.pi * -0.1, 1.5 * math.pi * -currentTime, 0)* CFrame.new(1, 2, 5) + Character.HumanoidRootPart.Position
                Grabbed.LeftUpperArm.CFrame    = CFrame.Angles(math.pi * .25, 3 * math.pi * currentTime, 0)* CFrame.new(1, 2, 5) + Character.HumanoidRootPart.Position
                Grabbed.RightUpperArm.CFrame   = CFrame.Angles(math.pi * -.25, 3 * math.pi * -currentTime, 0)* CFrame.new(1, 2, 5) + Character.HumanoidRootPart.Position
                Grabbed.LeftUpperLeg.CFrame    = CFrame.Angles(math.pi * .3, 2.5 * math.pi * currentTime, 0)* CFrame.new(1, 2, 5) + Character.HumanoidRootPart.Position
                Grabbed.RightUpperLeg.CFrame   = CFrame.Angles(math.pi * -.3, 2.5 * math.pi * -currentTime, 0)* CFrame.new(1, 0, 5) + Character.HumanoidRootPart.Position
                Grabbed.LeftLowerLeg.CFrame    = CFrame.Angles(math.pi * .7, 2 * math.pi * currentTime, 0)* CFrame.new(1, 2, 7) + Character.HumanoidRootPart.Position
                Grabbed.RightLowerLeg.CFrame   = CFrame.Angles(math.pi * .8, 2 * math.pi * -currentTime, 0)* CFrame.new(1, 2, 7) + Character.HumanoidRootPart.Position
                Grabbed.LeftLowerArm.CFrame    = CFrame.Angles(math.pi * .9, 2 * math.pi * currentTime, 0)* CFrame.new(1, 2, 7) + Character.HumanoidRootPart.Position
                Grabbed.RightLowerArm.CFrame   = CFrame.Angles(math.pi * 1, 2 * math.pi * -currentTime, 0)* CFrame.new(1, 2, 7) + Character.HumanoidRootPart.Position
            end))
        end
    })

    Modules:GrabTool({
        Name = "Make Player Stand",
        Description = "Turns the player into your 'stand'",
        StopAnimations = true,
        Callback = function(Grabbed,Character)
            local ClonedChar: Model = Modules:CloneChar(Grabbed)
            local Cross: boolean = false 
            Modules:Delete(Grabbed, {  "BodyGyro", "BodyPosition" })

            DhLibrary:AddConnection("Make Player Stand",RunService.Heartbeat:Connect(function()
                if Character.BodyEffects and Character.BodyEffects.Grabbed.Value == nil or not Tools["Make Player Stand"]["State"] then 
                    States.Grab = true 
                    ClonedChar:Destroy()
                    DhLibrary:RemoveConnection("Make Player Stand")
                end 

                DhLibrary:NoVelocity(ClonedChar)
                DhLibrary:NoVelocity(Grabbed)
                DhLibrary:CanCollide(Grabbed,false)

                local BodyGyro = ClonedChar:FindFirstChild("UpperTorso") and ClonedChar.UpperTorso:FindFirstChild("BodyGyro") or DhLibrary:Create("BodyGyro",{
                    Parent = ClonedChar:FindFirstChild("UpperTorso") ,
                    D = 100,
                })
                -- _____GYAT <3
                for _, _____GYAT in pairs(Grabbed:GetChildren()) do 
                    if _____GYAT:IsA("BasePart") and ClonedChar:FindFirstChild(_____GYAT.Name) then 
                        Modules:AlignControl(_____GYAT,ClonedChar:FindFirstChild(_____GYAT.Name),CFrame.new(0,0,0))
                    end 
                end 


                BodyGyro.CFrame = CFrame.lookAt(ClonedChar.UpperTorso.Position, Character.HumanoidRootPart.Position)
                BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

                DhLibrary:Tween(ClonedChar.HumanoidRootPart, 0.4, {
                    CFrame = CFrame.new(
                        Character.HumanoidRootPart.Position + 
                        Character.HumanoidRootPart.CFrame.LookVector * -3 +
                        Character.HumanoidRootPart.CFrame.RightVector * -1 +
                        Vector3.new(0, 4.2, 0)
                    )
                })
            end))

            DhLibrary:PlayAnimation(ClonedChar,3541114300)
        end 
    })

end 
do 
    Modules:InitGrab()
    DhLibrary:AddConnection("CharacterAdded",LocalPlayer.CharacterAdded:Connect(function()
        Modules:AntiStomp(States.AntiStomp)
        Modules:NoJump(States.NoJumpCooldown)
    end))
end 

UiLibrary:notification({text = "Legion loaded!"})
Starting = false 
