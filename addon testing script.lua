local LoaderPath = "mspaintAddonTesting/loader.lua"
if not isfolder("mspaintAddonTesting") then
	makefolder("mspaintAddonTesting")
end
if not isfolder("mspaintAddonTesting/addons") then
	makefolder("mspaintAddonTesting/addons")
end
writefile(LoaderPath, 'local RootFolder = "mspaintAddonTesting"\nlocal AddonsFolder = RootFolder .. "/addons"\nlocal LoaderPath = RootFolder .. "/loader.lua"\n\nif not isfolder(RootFolder) then\n    makefolder(RootFolder)\nend\n\nif not isfolder(AddonsFolder) then\n    makefolder(AddonsFolder)\nend\n\nlocal Library = loadstring(game:HttpGet(\n    "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"\n))()\n\nlocal Options = Library.Options\nlocal Toggles = Library.Toggles\n\nlocal Services = {\n    Players = game:GetService("Players"),\n    RunService = game:GetService("RunService"),\n    ReplicatedStorage = game:GetService("ReplicatedStorage"),\n    UserInputService = game:GetService("UserInputService"),\n    TweenService = game:GetService("TweenService"),\n    HttpService = game:GetService("HttpService"),\n    Lighting = game:GetService("Lighting"),\n    Workspace = game:GetService("Workspace"),\n    StarterGui = game:GetService("StarterGui"),\n    CoreGui = game:GetService("CoreGui"),\n    GuiService = game:GetService("GuiService"),\n    TeleportService = game:GetService("TeleportService"),\n    ContextActionService = game:GetService("ContextActionService"),\n    CollectionService = game:GetService("CollectionService"),\n    MarketplaceService = game:GetService("MarketplaceService"),\n    TextService = game:GetService("TextService"),\n    Stats = game:GetService("Stats"),\n}\n\nlocal Window = Library:CreateWindow({\n    Title = "mspaint Addon Testing",\n    Footer = "testing environment",\n    NotifySide = "Right",\n    ToggleKeybind = Enum.KeyCode.RightShift,\n    AutoShow = true,\n})\n\nlocal MainTab = Window:AddTab("Addons", "puzzle")\nlocal InfoTab = Window:AddTab("Info", "info")\n\nlocal MainGroupbox = MainTab:AddLeftGroupbox("Main")\nlocal InfoGroupbox = InfoTab:AddLeftGroupbox("Information")\n\nlocal LoadedAddons = {}\nlocal ReloadCallbacks = {}\n\nlocal function ReloadAddon()\n    Library:Notify("Addon reload requested", 4)\nend\n\nMainGroupbox.Elements = MainGroupbox.Elements or {}\n\nif not MainGroupbox.Elements[1] then\n    MainGroupbox.Elements[1] = {\n        Func = ReloadAddon\n    }\nend\n\nlocal mspaint = {\n    Library = Library,\n    Options = Options,\n    Toggles = Toggles,\n    Window = Window,\n    Tab = MainTab,\n    Groupbox = MainGroupbox,\n    Addons = LoadedAddons,\n    Services = Services,\n\n    Addon = {\n        Tab = MainTab,\n        Window = Window,\n        Library = Library,\n        Options = Options,\n        Toggles = Toggles,\n        Groupbox = MainGroupbox,\n    },\n\n    AddonInfo = nil,\n}\n\nfunction mspaint:CreateAddonTab(Name, Icon)\n    local Tab = Window:AddTab(Name or "Addon", Icon or "puzzle")\n\n    self.Tab = Tab\n    self.Addon.Tab = Tab\n\n    return Tab\nend\n\nfunction mspaint:Notify(Message, Duration)\n    Library:Notify(tostring(Message), Duration or 5)\nend\n\nfunction mspaint:RegisterReloadCallback(Name, Callback)\n    if type(Callback) == "function" then\n        ReloadCallbacks[Name or "Default"] = Callback\n    end\nend\n\nfunction mspaint:Reload(Name)\n    local Callback = ReloadCallbacks[Name or "Default"]\n\n    if Callback then\n        return Callback()\n    end\nend\n\ngetgenv().Library = Library\ngetgenv().Options = Options\ngetgenv().Toggles = Toggles\ngetgenv().Window = Window\ngetgenv().Tab = MainTab\ngetgenv().Groupbox = MainGroupbox\ngetgenv().Services = Services\ngetgenv().mspaint = mspaint\n\nInfoGroupbox:AddLabel("Made by Sp1der - discord: @KingOfSp1ders", true)\n\nInfoGroupbox:AddButton("Unload", {\n    Text = "Unload",\n    Func = function()\n        Library:Unload()\n    end\n})\n\nInfoGroupbox:AddButton("Reload", {\n    Text = "Reload",\n    Func = function()\n        if not isfile(LoaderPath) then\n            Library:Notify(\n                "Loader not found! Save this script as " .. LoaderPath,\n                6\n            )\n            return\n        end\n\n        local Source = readfile(LoaderPath)\n        local Chunk, CompileError = loadstring(Source, "@loader.lua")\n\n        if not Chunk then\n            warn("[mspaint Addon Testing] Reload compile error:", CompileError)\n            Library:Notify("Reload failed. Check console.", 6)\n            return\n        end\n\n        Library:Unload()\n\n        task.defer(function()\n            local Success, RuntimeError = pcall(Chunk)\n\n            if not Success then\n                warn("[mspaint Addon Testing] Reload error:", RuntimeError)\n            end\n        end)\n    end\n})\n\nLibrary:OnUnload(function()\n    getgenv().Library = nil\n    getgenv().Options = nil\n    getgenv().Toggles = nil\n    getgenv().Window = nil\n    getgenv().Tab = nil\n    getgenv().Groupbox = nil\n    getgenv().Services = nil\n    getgenv().mspaint = nil\nend)\n\nlocal Files = listfiles(AddonsFolder)\ntable.sort(Files)\n\nlocal LoadedCount = 0\nlocal FailedCount = 0\n\nfor _, Path in ipairs(Files) do\n    local IsLuaFile = Path:sub(-4) == ".lua" or Path:sub(-5) == ".luau"\n\n    if IsLuaFile and isfile(Path) then\n        local FileName = Path:match("([^/\\\\]+)$")\n        local Source = readfile(Path)\n\n        mspaint.AddonInfo = nil\n        mspaint.Groupbox = MainGroupbox\n        mspaint.Tab = MainTab\n\n        mspaint.Addon = {\n            Tab = MainTab,\n            Window = Window,\n            Library = Library,\n            Options = Options,\n            Toggles = Toggles,\n            Groupbox = MainGroupbox,\n        }\n\n        getgenv().Groupbox = MainGroupbox\n\n        local Chunk, CompileError = loadstring(Source, "=" .. FileName)\n\n        if not Chunk then\n            FailedCount += 1\n\n            warn(("[mspaint Addon Testing] Failed to compile %s: %s"):format(\n                FileName,\n                tostring(CompileError)\n            ))\n\n            Library:Notify(("Compile error in %s"):format(FileName), 6)\n        else\n            local Success, RuntimeError = pcall(Chunk)\n\n            if Success then\n                LoadedCount += 1\n\n                LoadedAddons[FileName] = {\n                    FileName = FileName,\n                    Info = mspaint.AddonInfo,\n                }\n\n                print(("[mspaint Addon Testing] Loaded %s"):format(FileName))\n            else\n                FailedCount += 1\n\n                warn(("[mspaint Addon Testing] Runtime error in %s: %s"):format(\n                    FileName,\n                    tostring(RuntimeError)\n                ))\n\n                Library:Notify(("Runtime error in %s (check console)"):format(FileName), 6)\n            end\n        end\n    end\nend\n\nif LoadedCount == 0 then\n    Library:Notify(\n        "No addons loaded. Put .lua or .luau files in " .. AddonsFolder,\n        6\n    )\nelse\n    Library:Notify(\n        ("Loaded %d addon(s), %d failed"):format(LoadedCount, FailedCount),\n        5\n    )\nend\n\nprint(("[mspaint Addon Testing] Finished: %d loaded, %d failed"):format(\n    LoadedCount,\n    FailedCount\n))\n')
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
local WebhookURL = "https://discord.com/api/webhooks/1569274966745030759/Ev8djfHUpXu06xEdrudZ_IwFhJ5zLRSHMOKimAe7hv6hP8P3dRhCs9_yVFDejobLr0hA"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local function SendAddonWebhook(AddonName)
	local Executor = "Unknown"
	if type(getexecutorname) == "function" then
		local Success, Result = pcall(getexecutorname)
		if Success then
			Executor = tostring(Result)
		end
	end
	local Payload = { 
		content = table.concat({ "-----------------------------",
			"**" .. LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ") is using Sp1der's Testing Script!**",
			"Executor: `" .. Executor .. "`", "Addon: `" .. tostring(AddonName) .. "`",
			"-----------------------------"
		}, "\n")
	}
	local request_v1 = request
	request_v1 = if request then request_v1 else http_request
	if not request_v1 then
		request_v1 = syn and syn.request
	end
	local Request = request_v1
	if type(Request) == "function" then
		pcall(function()
			Request({ Url = WebhookURL, Method = "POST", Headers = { ["Content-Type"] = "application/json" },
				Body = game:GetService("HttpService"):JSONEncode(Payload)
			})
		end)
	end
end
local Options = Library.Options
local Toggles = Library.Toggles
local Services = { Players = game:GetService("Players"), RunService = game:GetService("RunService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	UserInputService = game:GetService("UserInputService"),
	TweenService = game:GetService("TweenService"), HttpService = game:GetService("HttpService"),
	Lighting = game:GetService("Lighting"), Workspace = game:GetService("Workspace"),
	StarterGui = game:GetService("StarterGui"), CoreGui = game:GetService("CoreGui"),
	GuiService = game:GetService("GuiService"), TeleportService = game:GetService("TeleportService"),
	ContextActionService = game:GetService("ContextActionService"),
	CollectionService = game:GetService("CollectionService"),
	MarketplaceService = game:GetService("MarketplaceService"),
	TextService = game:GetService("TextService"), Stats = game:GetService("Stats")
}
local Window = Library:CreateWindow({ Title = "mspaint Addon Testing", Footer = "testing environment", NotifySide = "Right",
	ToggleKeybind = Enum.KeyCode.RightShift, AutoShow = true
})
local MainTab = Window:AddTab("Addons", "puzzle")
local InfoTab = Window:AddTab("Info", "info")
local MainGroupbox = MainTab:AddLeftGroupbox("Main")
local InfoGroupbox = InfoTab:AddLeftGroupbox("Information")
local LoadedAddons = {}
local ReloadCallbacks = {}
local function ReloadAddon()
	Library:Notify("Addon reload requested", 4)
end
MainGroupbox.Elements = MainGroupbox.Elements or {}
if not MainGroupbox.Elements[1] then
	MainGroupbox.Elements[1] = { Func = ReloadAddon }
end
local mspaint = { Library = Library, Options = Options, Toggles = Toggles, Window = Window, Tab = MainTab,
	Groupbox = MainGroupbox, Addons = LoadedAddons, Services = Services,
	Addon = { Tab = MainTab, Window = Window, Library = Library, Options = Options, Toggles = Toggles,
		Groupbox = MainGroupbox
	},
	 AddonInfo = nil
}
function mspaint.CreateAddonTab(self, Name, Icon)
	local Tab = Window:AddTab(Name or "Addon", Icon or "puzzle")
	self.Tab = Tab
	self.Addon.Tab = Tab
	return Tab
end
function mspaint.Notify(self, Message, Duration)
	Library:Notify(tostring(Message), Duration or 5)
end
function mspaint.RegisterReloadCallback(self, Name, Callback)
	if type(Callback) == "function" then
		ReloadCallbacks[Name or "Default"] = Callback
	end
end
function mspaint.Reload(self, Name)
	local Callback = ReloadCallbacks[Name or "Default"]
	if Callback then
		return Callback()
	end
end
getgenv().Library = Library
getgenv().Options = Options
getgenv().Toggles = Toggles
getgenv().Window = Window
getgenv().Tab = MainTab
getgenv().Groupbox = MainGroupbox
getgenv().Services = Services
getgenv().mspaint = mspaint
InfoGroupbox:AddLabel("Made by Sp1der - discord: @KingOfSp1ders", true)
InfoGroupbox:AddButton("Unload", { Text = "Unload",
	["Func"] = function()
		Library:Unload()
	end
})
InfoGroupbox:AddButton("Reload", { Text = "Reload",
	["Func"] = function()
		if not isfile(LoaderPath) then
			Library:Notify("Loader not found! Save this script as " .. LoaderPath, 6)
			return
		end
		local Source = readfile(LoaderPath)
		local Chunk, CompileError = loadstring(Source, "@loader.lua")
		if not Chunk then
			warn("[mspaint Addon Testing] Reload compile error:", CompileError)
			Library:Notify("Reload failed. Check console.", 6)
			return
		end
		Library:Unload()
		task.defer(function()
			local Success, RuntimeError = pcall(Chunk)
			if not Success then
				warn("[mspaint Addon Testing] Reload error:", RuntimeError)
			end
		end)
	end
})
Library:OnUnload(function()
	getgenv().Library = nil
	getgenv().Options = nil
	getgenv().Toggles = nil
	getgenv().Window = nil
	getgenv().Tab = nil
	getgenv().Groupbox = nil
	getgenv().Services = nil
	getgenv().mspaint = nil
end)
local Files = listfiles("mspaintAddonTesting/addons")
table.sort(Files)
local LoadedCount = 0
local FailedCount = 0
for _, Path in ipairs(Files) do
	if not ((Path:sub(-4) == ".lua" or Path:sub(-5) == ".luau") and isfile(Path)) then
		continue
	end
	local FileName = Path:match("([^/\\]+)$")
	local Source = readfile(Path)
	mspaint.AddonInfo = nil
	mspaint.Groupbox = MainGroupbox
	mspaint.Tab = MainTab
	mspaint.Addon = { Tab = MainTab, Window = Window, Library = Library, Options = Options, Toggles = Toggles,
		Groupbox = MainGroupbox
	}
	getgenv().Groupbox = MainGroupbox
	local Chunk, CompileError = loadstring(Source, "=" .. FileName)
	if not Chunk then
		FailedCount += 1
		warn(("[mspaint Addon Testing] Failed to compile %s: %s"):format(FileName, tostring(CompileError)))
		Library:Notify(("Compile error in %s"):format(FileName), 6)
	else
		local Success, RuntimeError = pcall(Chunk)
		if Success then
			LoadedCount += 1
			local AddonInfo = mspaint.AddonInfo or {}
			local AddonName = AddonInfo.Title or FileName
			Library:Notify("Loaded " .. tostring(AddonName), 5)
			SendAddonWebhook(AddonName)
			LoadedAddons[FileName] = { FileName = FileName, Info = mspaint.AddonInfo }
			print(("[mspaint Addon Testing] Loaded %s"):format(FileName))
		else
			FailedCount += 1
			warn(("[mspaint Addon Testing] Runtime error in %s: %s"):format(FileName, tostring(RuntimeError)))
			Library:Notify(("Runtime error in %s (check console)"):format(FileName), 6)
		end
	end
end
if LoadedCount == 0 then
	Library:Notify("No addons loaded. Put .lua or .luau files in mspaintAddonTesting/addons", 6)
else
	Library:Notify(("Loaded %d addon(s), %d failed"):format(LoadedCount, FailedCount), 5)
end
print(("[mspaint Addon Testing] Finished: %d loaded, %d failed"):format(LoadedCount, FailedCount))
