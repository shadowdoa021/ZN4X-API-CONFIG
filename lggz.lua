-- ZN4X Access Loader
-- Execute este arquivo antes do zn4x.lua.

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
	warn("O loader precisa rodar no cliente.")
	return
end

local env = getgenv and getgenv() or _G
local ZN4XLoaderVersion = "0.0.3"
local ZN4XAutoLaunchRequested = env.ZN4XAutoLaunch == true
local ZN4XAutoLaunchServer = tostring(env.ZN4XAutoLaunchServer or "")
env.ZN4XAutoLaunch = nil
env.ZN4XAutoLaunchServer = nil
env.ZN4XLoginAccessWatchToken = nil

pcall(function()
	if type(env.ZN4XLoginCleanup) == "function" then
		env.ZN4XLoginCleanup()
	end
end)

local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 10)
if not playerGui then
	warn("PlayerGui nao encontrado.")
	return
end

local uiParent = playerGui
pcall(function()
	if type(gethui) == "function" then uiParent = gethui() end
end)

local oldGui = uiParent:FindFirstChild("ZN4X_Login") or playerGui:FindFirstChild("ZN4X_Login")
if oldGui then oldGui:Destroy() end

-- Ajuste estes valores caso o arquivo esteja em outro local ou hospedado.
env.ZN4XMenuFilePath = env.ZN4XMenuFilePath or "zn4x.lua"
env.ZN4XMenuAbsolutePath = env.ZN4XMenuAbsolutePath or [[C:\Users\Shadow\Desktop\ROBLOX ZN4X\zn4x.lua]]
env.ZN4XMenuSourceUrl = env.ZN4XMenuSourceUrl or ""
env.ZN4XPreferLocalMenu = env.ZN4XPreferLocalMenu == true
env.ZN4XReviveLoaderUrl = env.ZN4XReviveLoaderUrl
	or "https://raw.githubusercontent.com/shadowdoa021/ZN4X-API-CONFIG/refs/heads/main/lggz.lua"
env.ZN4XTeleportLoaderUrl = env.ZN4XTeleportLoaderUrl or env.ZN4XReviveLoaderUrl
-- A API do GitHub evita o cache atrasado do raw.githubusercontent.com.
env.ZN4XApiConfigUrl = "https://api.github.com/repos/shadowdoa021/ZN4X-API-CONFIG/contents/api-url.txt"
local function decodeBase64(value)
	local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	value = tostring(value or ""):gsub("[^" .. alphabet .. "=]", "")
	return (value:gsub(".", function(character)
		if character == "=" then return "" end
		local index = alphabet:find(character, 1, true)
		if not index then return "" end
		index -= 1
		local bits = ""
		for position = 6, 1, -1 do
			bits ..= index % 2 ^ position - index % 2 ^ (position - 1) > 0 and "1" or "0"
		end
		return bits
	end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(bits)
		if #bits ~= 8 then return "" end
		local byte = 0
		for position = 1, 8 do
			if bits:sub(position, position) == "1" then byte += 2 ^ (8 - position) end
		end
		return string.char(byte)
	end))
end
local function resolveKeyApiBaseUrl()
	local configUrl = tostring(env.ZN4XApiConfigUrl or "")
	if configUrl ~= "" then
		local ok, value = pcall(function()
			return game:HttpGet(configUrl .. "?zn4x=" .. tostring(os.time()), true)
		end)
		if ok and type(value) == "string" then
			local decodedOk, response = pcall(function()
				return HttpService:JSONDecode(value)
			end)
			if decodedOk and type(response) == "table" and type(response.content) == "string" then
				value = decodeBase64(response.content)
			end
			local publicUrl = value:match("https://[%w%-%.]+%.trycloudflare%.com")
			if publicUrl then return publicUrl end
		end
	end
	return "https://wool-buying-tools-deal.trycloudflare.com"
end
env.ZN4XKeyApiBaseUrl = resolveKeyApiBaseUrl()
local function fetchPublicConfig()
	local baseUrl = tostring(env.ZN4XKeyApiBaseUrl or ""):gsub("/+$", "")
	if baseUrl == "" then return nil end
	local ok, body = pcall(function()
		return game:HttpGet(baseUrl .. "/api/public-config?zn4x=" .. tostring(os.time()), true)
	end)
	if not ok or type(body) ~= "string" then return nil end
	local decodedOk, decoded = pcall(HttpService.JSONDecode, HttpService, body)
	if not decodedOk or type(decoded) ~= "table" or decoded.ok ~= true then return nil end
	return decoded
end

local ZN4XPublicConfig = fetchPublicConfig()
if type(ZN4XPublicConfig) == "table" then
	local requiredVersion = tostring(ZN4XPublicConfig.loaderVersion or "")
	if requiredVersion ~= "" and requiredVersion ~= ZN4XLoaderVersion then
		pcall(function()
			player:Kick("ZN4X desatualizado. Versao exigida: " .. requiredVersion)
		end)
		return
	end
end
-- Aceita ID do Roblox ou URL direta de imagem (ex.: https://i.imgur.com/foto.png).
env.ZN4XStoreImage = "https://i.imgur.com/j1Gxnt6.png"
-- Cada servidor pode executar seu proprio codigo Lua.
-- O codigo entre [[ e ]] sera executado ao clicar em "Carregar menu".
env.ZN4XServers = {
	{
		Name = "Murderer Mystery 2",
		Value = "M",
		Image = "6500905731",
		Subtitle = "MENU EM BETA",
		PlaceIds = { 142823291 },
		NamePatterns = { "murder mystery", "murderer mystery" },
		Code = function()
			local sourceUrl = "https://raw.githubusercontent.com/rouboq33-crypto/ZN4X-MENU/refs/heads/main/mznx.lua"
			local source = game:HttpGet(sourceUrl .. "?zn4x=" .. tostring(os.time()), true)
			local runner, compileError = loadstring(source)
			assert(runner, "Falha ao compilar murderzn4x.lua: " .. tostring(compileError))
			return runner()
		end,
	},
	{
		Name = "Seek",
		Value = "Seek",
		Image = "https://i.imgur.com/1avhcef.png",
		Subtitle = "MENU EM BETA",
		PlaceIds = { 80787774803348 },
		NamePatterns = { "seek" },
		Code = function()
			local sourceUrl = "https://raw.githubusercontent.com/rouboq33-crypto/ZN4X-MENU/refs/heads/main/seek.lua"
			local source = game:HttpGet(sourceUrl .. "?zn4x=" .. tostring(os.time()), true)
			local runner, compileError = loadstring(source)
			assert(runner, "Falha ao compilar seek.lua: " .. tostring(compileError))
			return runner()
		end,
	},
	{
		Name = "Airsoft FE",
		Value = "AirsoftFE",
		Image = "",
		Subtitle = "MENU EM DESENVOLVIMENTO",
		PlaceIds = {},
		NamePatterns = { "airsoft" },
		Code = function()
			local sourceUrl = "https://raw.githubusercontent.com/rouboq33-crypto/ZN4X-MENU/refs/heads/main/airsoftzn.lua"
			local source = game:HttpGet(sourceUrl .. "?zn4x=" .. tostring(os.time()), true)
			assert(not source:match("^%s*<"), "A URL do Airsoft FE retornou HTML em vez de Lua")
			local runner, compileError = loadstring(source)
			assert(runner, "Falha ao compilar airsoftfezn4x.lua: " .. tostring(compileError))
			return runner()
		end,
	},
}

if type(ZN4XPublicConfig) == "table" and type(ZN4XPublicConfig.games) == "table" then
	local remoteServers = {}
	for _, remoteGame in ipairs(ZN4XPublicConfig.games) do
		if type(remoteGame) == "table" then
			local remoteName = tostring(remoteGame.name or ""):gsub("^%s+", ""):gsub("%s+$", "")
			local remoteValue = tostring(remoteGame.value or remoteGame.id or ""):gsub("^%s+", ""):gsub("%s+$", "")
			if remoteName ~= "" and remoteValue ~= "" then
				local configuredSourceUrl = tostring(remoteGame.sourceUrl or ""):gsub("^%s+", ""):gsub("%s+$", "")
				if remoteValue == "AirsoftFE" then
					configuredSourceUrl = "https://raw.githubusercontent.com/rouboq33-crypto/ZN4X-MENU/refs/heads/main/airsoftzn.lua"
				end
				local option = {
					Name = remoteName,
					Value = remoteValue,
					Image = tostring(remoteGame.image or ""),
					Subtitle = tostring(remoteGame.subtitle or "SCRIPT NAO CONFIGURADO"),
					PlaceIds = type(remoteGame.placeIds) == "table" and remoteGame.placeIds or {},
					GameIds = type(remoteGame.gameIds) == "table" and remoteGame.gameIds or {},
					NamePatterns = type(remoteGame.namePatterns) == "table" and remoteGame.namePatterns or {},
					Configured = configuredSourceUrl ~= "",
				}
				if configuredSourceUrl ~= "" then
					option.Code = function()
						local source = game:HttpGet(configuredSourceUrl .. (configuredSourceUrl:find("?", 1, true) and "&" or "?") .. "zn4x=" .. tostring(os.time()), true)
						assert(not source:match("^%s*<"), "A URL de " .. remoteName .. " retornou HTML em vez de Lua")
						local runner, compileError = loadstring(source)
						assert(runner, "Falha ao compilar o script de " .. remoteName .. ": " .. tostring(compileError))
						return runner()
					end
				end
				table.insert(remoteServers, option)
			end
		end
	end
	if #remoteServers > 0 then
		env.ZN4XServers = remoteServers
	end
end

local function getQueueOnTeleport()
	if type(queue_on_teleport) == "function" then return queue_on_teleport end
	if syn and type(syn.queue_on_teleport) == "function" then return syn.queue_on_teleport end
	if fluxus and type(fluxus.queue_on_teleport) == "function" then return fluxus.queue_on_teleport end
	return nil
end

local function queueZN4XTeleportState(options)
	options = type(options) == "table" and options or {}
	local queueTeleport = getQueueOnTeleport()
	if not queueTeleport then return false, "QUEUE_UNSUPPORTED" end
	local autoFarm = options.autoFarm
	if autoFarm == nil then
		autoFarm = env.ZN4XAirsoftAutoFarmEnabled == true or env.ZN4XPendingAutoFarm == true
	end
	local serverValue = tostring(options.server or env.ZN4XExploitSelectedList or "AirsoftFE")
	local loaderUrl = tostring(options.loaderUrl or env.ZN4XTeleportLoaderUrl or env.ZN4XReviveLoaderUrl)
	local referenceWidth = tonumber(options.referenceWidth or env.ZN4XAutoFarmReferenceWidth) or 1366
	local referenceHeight = tonumber(options.referenceHeight or env.ZN4XAutoFarmReferenceHeight) or 768
	local queuedScript = string.format([[
local env = getgenv and getgenv() or _G
env.ZN4XAutoLaunch = true
env.ZN4XAutoLaunchServer = %q
env.ZN4XPendingAutoFarm = %s
env.ZN4XAutoFarmReferenceWidth = %s
env.ZN4XAutoFarmReferenceHeight = %s
local source = game:HttpGet(%q .. "?zn4x=" .. tostring(os.time()), true)
local runner = assert(loadstring(source))
runner()
]], serverValue, tostring(autoFarm == true), tostring(referenceWidth), tostring(referenceHeight), loaderUrl)
	local queued, queueError = pcall(queueTeleport, queuedScript)
	if not queued then return false, tostring(queueError) end
	return true
end

local function fetchZN4XPublicServers(placeId, sortOrder, maxPages)
	local servers = {}
	local cursor = nil
	for _ = 1, math.clamp(tonumber(maxPages) or 3, 1, 10) do
		local url = string.format(
			"https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&excludeFullGames=true&limit=100",
			tostring(placeId),
			sortOrder == "Asc" and "Asc" or "Desc"
		)
		if cursor and cursor ~= "" then url = url .. "&cursor=" .. HttpService:UrlEncode(cursor) end
		local ok, body = pcall(function() return game:HttpGet(url, true) end)
		if not ok or type(body) ~= "string" then return nil, "SERVER_API_UNAVAILABLE" end
		local decodedOk, response = pcall(HttpService.JSONDecode, HttpService, body)
		if not decodedOk or type(response) ~= "table" then return nil, "SERVER_API_INVALID" end
		for _, server in ipairs(type(response.data) == "table" and response.data or {}) do
			local serverId = tostring(server.id or "")
			local playing = tonumber(server.playing) or 0
			local maxPlayers = tonumber(server.maxPlayers) or 0
			if serverId ~= "" and serverId ~= tostring(game.JobId) and playing < maxPlayers then
				table.insert(servers, server)
			end
		end
		cursor = tostring(response.nextPageCursor or "")
		if cursor == "" then break end
	end
	return servers
end

local function teleportZN4X(placeId, jobId, options)
	local queued, queueError = queueZN4XTeleportState(options)
	if not queued then warn("ZN4X teleport sem auto-retorno: " .. tostring(queueError)) end
	if queued then task.wait(0.25) end
	local ok, teleportError = pcall(function()
		if jobId and tostring(jobId) ~= "" then
			TeleportService:TeleportToPlaceInstance(tonumber(placeId) or game.PlaceId, tostring(jobId), player)
		else
			TeleportService:Teleport(tonumber(placeId) or game.PlaceId, player)
		end
	end)
	return ok, ok and nil or tostring(teleportError)
end

env.zn4xservers = function(sortOrder, maxPages, placeId)
	return fetchZN4XPublicServers(tonumber(placeId) or game.PlaceId, sortOrder, maxPages)
end

env.zn4xenterjob = function(jobId, options)
	return teleportZN4X(game.PlaceId, jobId, options)
end

env.zn4xenterplace = function(placeId, jobId, options)
	return teleportZN4X(placeId, jobId, options)
end

env.zn4xreenter = function(options)
	return teleportZN4X(game.PlaceId, game.JobId, options)
end

local function enterSortedZN4XServer(sortOrder, options)
	local servers, fetchError = fetchZN4XPublicServers(game.PlaceId, sortOrder, 3)
	if not servers then return false, fetchError end
	table.sort(servers, function(left, right)
		local leftPlaying = tonumber(left.playing) or 0
		local rightPlaying = tonumber(right.playing) or 0
		if sortOrder == "Asc" then return leftPlaying < rightPlaying end
		return leftPlaying > rightPlaying
	end)
	local server = servers[1]
	if not server then return false, "SERVER_NOT_FOUND" end
	return teleportZN4X(game.PlaceId, server.id, options)
end

env.zn4xentermax = function(options)
	return enterSortedZN4XServer("Desc", options)
end

env.zn4xenterempt = function(options)
	return enterSortedZN4XServer("Asc", options)
end
env.zn4xenterempty = env.zn4xenterempt

env.zn4xenterrandom = function(options)
	local servers, fetchError = fetchZN4XPublicServers(game.PlaceId, "Desc", 3)
	if not servers then return false, fetchError end
	if #servers == 0 then return false, "SERVER_NOT_FOUND" end
	local server = servers[math.random(1, #servers)]
	return teleportZN4X(game.PlaceId, server.id, options)
end

-- Uma linha por atualizacao. A lista possui rolagem automatica.
env.ZN4XUpdates = env.ZN4XUpdates or {
	"+ Matar Policial",
	"+ LanÃƒÂ§amento Da Beta",
}

local ZN4XLatestUpdateAt
if type(ZN4XPublicConfig) == "table" and type(ZN4XPublicConfig.updates) == "table" then
	local remoteUpdates = {}
	for _, entry in ipairs(ZN4XPublicConfig.updates) do
		if type(entry) == "table" and tostring(entry.text or "") ~= "" then
			local cleanText = tostring(entry.text):gsub("^%s*[%+%-]+%s*", "")
			table.insert(remoteUpdates, string.format("- %s (%s)", cleanText, tostring(entry.gameLabel or "Jogo")))
			ZN4XLatestUpdateAt = ZN4XLatestUpdateAt or tonumber(entry.createdAt)
		end
	end
	if #remoteUpdates > 0 then env.ZN4XUpdates = remoteUpdates end
end

local colors = {
	background = Color3.fromRGB(9, 10, 16),
	panel = Color3.fromRGB(13, 15, 23),
	panelSoft = Color3.fromRGB(18, 21, 31),
	field = Color3.fromRGB(10, 12, 19),
	text = Color3.fromRGB(235, 240, 255),
	muted = Color3.fromRGB(135, 143, 163),
	faint = Color3.fromRGB(75, 83, 105),
	line = Color3.fromRGB(34, 39, 54),
	accent = Color3.fromRGB(45, 135, 255),
	accentDark = Color3.fromRGB(20, 49, 88),
	success = Color3.fromRGB(80, 205, 130),
	danger = Color3.fromRGB(230, 82, 98),
}

local gui = Instance.new("ScreenGui")
gui.Name = "ZN4X_Login"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999999999
pcall(function()
	if syn and type(syn.protect_gui) == "function" then syn.protect_gui(gui) end
end)
gui.Parent = uiParent

pcall(function()
	gui.AutoLocalize = false
	gui.OnTopOfCoreBlur = true
end)

local function corner(parent, radius)
	local object = Instance.new("UICorner")
	object.CornerRadius = UDim.new(0, radius)
	object.Parent = parent
	return object
end

local function stroke(parent, color, transparency)
	local object = Instance.new("UIStroke")
	object.Color = color or colors.line
	object.Transparency = transparency or 0
	object.Thickness = 1
	object.Parent = parent
	return object
end

local function textLabel(parent, text, size, color, font)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Font = font or Enum.Font.Gotham
	label.Text = text or ""
	label.TextColor3 = color or colors.text
	label.TextSize = size or 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = parent
	pcall(function() label.AutoLocalize = false end)
	return label
end

local function button(parent, text)
	local object = Instance.new("TextButton")
	object.AutoButtonColor = false
	object.BackgroundColor3 = colors.panelSoft
	object.BorderSizePixel = 0
	object.Font = Enum.Font.GothamMedium
	object.Text = text
	object.TextColor3 = colors.text
	object.TextSize = 13
	object.Parent = parent
	pcall(function() object.AutoLocalize = false end)
	corner(object, 5)
	stroke(object, colors.line, 0.25)
	return object
end

local function imageAsset(value, cacheLabel)
	local image = tostring(value or "")
	local requestFunction = (syn and syn.request) or http_request or request
	if image:match("^https?://[^/]*imgur%.com/gallery/") or image:match("^https?://[^/]*imgur%.com/a/") then
		local okPage, pageBody = pcall(function()
			if type(requestFunction) == "function" then
				local response = requestFunction({ Url = image, Method = "GET" })
				return response and (response.Body or response.body)
			end
			return game:HttpGet(image, true)
		end)
		if okPage and type(pageBody) == "string" then
			local directImage = pageBody:match('<meta[^>]-property="og:image"[^>]-content="([^"]+)"')
				or pageBody:match('<meta[^>]-content="([^"]+)"[^>]-property="og:image"')
				or pageBody:match("<meta[^>]-property='og:image'[^>]-content='([^']+)'")
				or pageBody:match("<meta[^>]-content='([^']+)'[^>]-property='og:image'")
			if directImage then
				image = directImage:gsub("&amp;", "&")
			end
		end
	end
	if image:match("^%d+$") then
		return "rbxthumb://type=Asset&id=" .. image .. "&w=420&h=420"
	end
	if not image:match("^https?://") then
		return image
	end

	local assetLoader = getcustomasset or getsynasset
	if type(writefile) ~= "function" or type(assetLoader) ~= "function" then
		warn("ZN4X: imagem externa exige writefile e getcustomasset/getsynasset.")
		return ""
	end

	local hash = 5381
	for index = 1, #image do
		hash = (hash * 33 + image:byte(index)) % 1000000007
	end
	local extension = image:lower():match("%.(png)[%?%#]?")
		or image:lower():match("%.(jpe?g)[%?%#]?")
		or "png"
	local safeLabel = tostring(cacheLabel or "image"):gsub("[^%w_%-]", "_")
	local fileName = "ZN4X_" .. safeLabel .. "_" .. tostring(hash) .. "." .. extension

	local ok, asset = pcall(function()
		if type(isfile) ~= "function" or not isfile(fileName) then
			local body
			if type(requestFunction) == "function" then
				local response = requestFunction({ Url = image, Method = "GET" })
				body = response and (response.Body or response.body)
			else
				body = game:HttpGet(image)
			end
			if type(body) ~= "string" or #body == 0 then
				error("download vazio")
			end
			writefile(fileName, body)
		end
		return assetLoader(fileName)
	end)

	if ok and type(asset) == "string" then
		return asset
	end
	warn("ZN4X: nao foi possivel carregar a imagem externa " .. image)
	return ""
end

local function panel(parent, title, position, size)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = colors.panel
	frame.BorderSizePixel = 0
	frame.Position = position
	frame.Size = size
	frame.Parent = parent
	corner(frame, 5)
	stroke(frame, colors.line, 0.15)

	local heading = textLabel(frame, title, 12, colors.muted, Enum.Font.GothamMedium)
	heading.Position = UDim2.fromOffset(10, 4)
	heading.Size = UDim2.new(1, -20, 0, 22)

	local line = Instance.new("Frame")
	line.BackgroundColor3 = colors.line
	line.BackgroundTransparency = 0.2
	line.BorderSizePixel = 0
	line.Position = UDim2.fromOffset(10, 27)
	line.Size = UDim2.new(1, -20, 0, 1)
	line.Parent = frame

	return frame
end

local root = Instance.new("Frame")
root.Name = "Root"
root.AnchorPoint = Vector2.new(0.5, 0.5)
root.Position = UDim2.fromScale(0.5, 0.5)
root.Size = UDim2.fromOffset(360, 168)
root.BackgroundColor3 = colors.background
root.BorderSizePixel = 0
root.ClipsDescendants = true
root.Parent = gui
corner(root, 6)
stroke(root, colors.line, 0.05)

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.BackgroundTransparency = 1
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.Active = true
titleBar.Parent = root

local title = textLabel(titleBar, "ZN4X MENU - BETA", 18, colors.text, Enum.Font.GothamMedium)
title.Position = UDim2.fromOffset(12, 4)
title.Size = UDim2.new(1, -90, 0, 30)

local titleAccent = Instance.new("Frame")
titleAccent.BackgroundColor3 = colors.accent
titleAccent.BorderSizePixel = 0
titleAccent.Position = UDim2.fromOffset(4, 10)
titleAccent.Size = UDim2.fromOffset(4, 18)
titleAccent.Parent = titleBar
corner(titleAccent, 2)

local version = textLabel(titleBar, ZN4XLoaderVersion, 11, Color3.fromRGB(160, 205, 235), Enum.Font.GothamMedium)
version.AnchorPoint = Vector2.new(1, 0.5)
version.Position = UDim2.new(1, -12, 0.5, 0)
version.Size = UDim2.fromOffset(52, 22)
version.BackgroundTransparency = 0
version.BackgroundColor3 = Color3.fromRGB(28, 47, 58)
version.TextXAlignment = Enum.TextXAlignment.Center
corner(version, 4)

local loadingView = Instance.new("Frame")
loadingView.Name = "LoadingView"
loadingView.BackgroundTransparency = 1
loadingView.Position = UDim2.fromOffset(8, 38)
loadingView.Size = UDim2.new(1, -16, 1, -46)
loadingView.Parent = root

local loadingCard = panel(loadingView, "Carregando arquivos", UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1))

local loadingDescription = textLabel(loadingCard, "Preparando os arquivos necessarios para iniciar o menu.", 12, colors.muted, Enum.Font.Gotham)
loadingDescription.Position = UDim2.fromOffset(10, 32)
loadingDescription.Size = UDim2.new(1, -20, 0, 34)
loadingDescription.TextWrapped = true
loadingDescription.TextYAlignment = Enum.TextYAlignment.Top

local loadingStatus = textLabel(loadingCard, "Carregando...", 12, colors.muted, Enum.Font.GothamMedium)
loadingStatus.Position = UDim2.fromOffset(0, 70)
loadingStatus.Size = UDim2.new(1, -48, 0, 20)

local loadingPercent = textLabel(loadingCard, "0%", 12, colors.muted, Enum.Font.GothamMedium)
loadingPercent.AnchorPoint = Vector2.new(1, 0)
loadingPercent.Position = UDim2.new(1, 0, 0, 70)
loadingPercent.Size = UDim2.fromOffset(44, 20)
loadingPercent.TextXAlignment = Enum.TextXAlignment.Right

local progressBack = Instance.new("Frame")
progressBack.BackgroundColor3 = Color3.fromRGB(31, 34, 42)
progressBack.BorderSizePixel = 0
progressBack.Position = UDim2.fromOffset(0, 94)
progressBack.Size = UDim2.new(1, 0, 0, 14)
progressBack.Parent = loadingCard
corner(progressBack, 4)

local progressFill = Instance.new("Frame")
progressFill.BackgroundColor3 = colors.accent
progressFill.BorderSizePixel = 0
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.Parent = progressBack
corner(progressFill, 4)

local loadingProgress = 0
local function setLoadingProgress(progress, statusText)
	if not gui.Parent then return end
	progress = math.clamp(math.floor((tonumber(progress) or loadingProgress) + 0.5), loadingProgress, 100)
	loadingProgress = progress
	progressFill.Size = UDim2.new(progress / 100, 0, 1, 0)
	loadingPercent.Text = tostring(progress) .. "%"
	if statusText then loadingStatus.Text = statusText end
	task.wait()
end

setLoadingProgress(8, "Interface base pronta")

local mainView = Instance.new("Frame")
mainView.Name = "MainView"
mainView.BackgroundTransparency = 1
mainView.Position = UDim2.fromOffset(10, 40)
mainView.Size = UDim2.new(1, -20, 1, -50)
mainView.Visible = false
mainView.Parent = root

local userPanel = panel(mainView, "Informacoes do Usuario", UDim2.fromOffset(0, 0), UDim2.new(0.5, -6, 0, 108))
local serverPanel = panel(mainView, "Informacoes do Servidor", UDim2.new(0.5, 6, 0, 0), UDim2.new(0.5, -6, 0, 108))
local updatesPanel = panel(mainView, "Ultimas Atualizacoes", UDim2.fromOffset(0, 120), UDim2.new(0.5, -6, 1, -120))
local accessPanel = panel(mainView, "Acesso", UDim2.new(0.5, 6, 0, 120), UDim2.new(0.5, -6, 1, -120))

setLoadingProgress(18, "Criando paineis...")
setLoadingProgress(22, "Carregando imagens...")

local userIcon = Instance.new("ImageLabel")
userIcon.BackgroundColor3 = Color3.fromRGB(30, 34, 43)
userIcon.BorderSizePixel = 0
userIcon.Position = UDim2.fromOffset(12, 38)
userIcon.Size = UDim2.fromOffset(48, 48)
userIcon.Image = ""
userIcon.ScaleType = Enum.ScaleType.Crop
userIcon.Parent = userPanel
corner(userIcon, 6)
stroke(userIcon, colors.line, 0.2)

setLoadingProgress(26, "Preparando dados do perfil...")

local userInitial = textLabel(userIcon, "Z", 18, colors.text, Enum.Font.GothamBold)
userInitial.Size = UDim2.fromScale(1, 1)
userInitial.TextXAlignment = Enum.TextXAlignment.Center
userInitial.Visible = userIcon.Image == ""

task.spawn(function()
	local storeImage = imageAsset(env.ZN4XStoreImage, "store")
	if storeImage ~= "" and userIcon and userIcon.Parent then
		userIcon.Image = storeImage
		userInitial.Visible = false
	end
end)

local userName = textLabel(userPanel, "ZN4X MENU", 14, colors.text, Enum.Font.GothamMedium)
userName.Position = UDim2.fromOffset(70, 37)
userName.Size = UDim2.new(1, -150, 0, 24)

local userRole = textLabel(userPanel, "Free", 12, colors.accent, Enum.Font.GothamMedium)
userRole.Position = UDim2.fromOffset(70, 61)
userRole.Size = UDim2.new(1, -150, 0, 20)

local function formatAccessRole(lifetime, accessUntil)
	if lifetime == true then return "Lifetime" end
	local timestamp = tonumber(accessUntil)
	if not timestamp then return "Free" end
	local remaining = math.max(0, math.floor((timestamp / 1000) - os.time()))
	local hours = math.floor(remaining / 3600)
	local minutes = math.floor((remaining % 3600) / 60)
	if hours > 0 then return string.format("Free | %dh %02dm", hours, minutes) end
	return string.format("Free | %dm", minutes)
end

local licenseBadge
local function applyAccountProfile(data)
	if type(data) ~= "table" then return end
	local profileName = tostring(data.discordName or data.login or "ZN4X MENU")
	local profileImage = tostring(data.discordAvatar or "")
	local profileRole = formatAccessRole(data.lifetime, data.accessUntil)

	userName.Text = profileName
	userRole.Text = profileRole
	if licenseBadge then
		licenseBadge.Text = data.lifetime == true and "Premium" or "Free"
		licenseBadge.TextColor3 = data.lifetime == true and colors.success or Color3.fromRGB(170, 215, 235)
	end
	userIcon.Image = imageAsset(profileImage, "discord_profile")
	userInitial.Text = profileName:sub(1, 1):upper()
	userInitial.Visible = userIcon.Image == ""

	env.ZN4XAccessProfileName = profileName
	env.ZN4XAccessProfileImage = profileImage
	env.ZN4XAccessProfileRole = profileRole
end

licenseBadge = textLabel(userPanel, "Free", 11, Color3.fromRGB(170, 215, 235), Enum.Font.GothamMedium)
licenseBadge.AnchorPoint = Vector2.new(1, 0)
licenseBadge.Position = UDim2.new(1, -10, 0, 39)
licenseBadge.Size = UDim2.fromOffset(70, 22)
licenseBadge.BackgroundTransparency = 0
licenseBadge.BackgroundColor3 = Color3.fromRGB(26, 39, 48)
licenseBadge.TextXAlignment = Enum.TextXAlignment.Center
corner(licenseBadge, 4)

setLoadingProgress(34, "Preparando servidor...")

local serverIcon = Instance.new("ImageLabel")
serverIcon.BackgroundColor3 = colors.accentDark
serverIcon.BorderSizePixel = 0
serverIcon.Position = UDim2.fromOffset(12, 38)
serverIcon.Size = UDim2.fromOffset(48, 48)
serverIcon.Image = ""
serverIcon.ScaleType = Enum.ScaleType.Crop
serverIcon.Parent = serverPanel
corner(serverIcon, 6)

local serverInitial = textLabel(serverIcon, "S", 18, colors.text, Enum.Font.GothamBold)
serverInitial.Size = UDim2.fromScale(1, 1)
serverInitial.TextXAlignment = Enum.TextXAlignment.Center

local selectedServer
local serverSelector = button(serverPanel, "Selecionar servidor")
serverSelector.Position = UDim2.fromOffset(70, 38)
serverSelector.Size = UDim2.new(1, -80, 0, 30)
serverSelector.BackgroundColor3 = colors.accentDark
serverSelector.TextXAlignment = Enum.TextXAlignment.Left

local selectorPadding = Instance.new("UIPadding")
selectorPadding.PaddingLeft = UDim.new(0, 10)
selectorPadding.PaddingRight = UDim.new(0, 10)
selectorPadding.Parent = serverSelector

local serverHint = textLabel(serverPanel, "Escolha a lista correta", 11, colors.muted, Enum.Font.Gotham)
serverHint.Position = UDim2.fromOffset(70, 70)
serverHint.Size = UDim2.new(1, -80, 0, 18)

local dropdown = Instance.new("Frame")
dropdown.Name = "ServerDropdown"
dropdown.BackgroundColor3 = colors.field
dropdown.BorderSizePixel = 0
dropdown.Position = UDim2.new(0.5, 76, 0, 69)
dropdown.Size = UDim2.new(0.5, -86, 0, 0)
dropdown.ClipsDescendants = true
dropdown.Visible = false
dropdown.ZIndex = 20
dropdown.Parent = mainView
corner(dropdown, 5)
stroke(dropdown, colors.line, 0.1)

local dropdownLayout = Instance.new("UIListLayout")
dropdownLayout.Padding = UDim.new(0, 3)
dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
dropdownLayout.Parent = dropdown

local dropdownPadding = Instance.new("UIPadding")
dropdownPadding.PaddingTop = UDim.new(0, 4)
dropdownPadding.PaddingBottom = UDim.new(0, 4)
dropdownPadding.PaddingLeft = UDim.new(0, 4)
dropdownPadding.PaddingRight = UDim.new(0, 4)
dropdownPadding.Parent = dropdown

local serverOptions = env.ZN4XServers
if type(serverOptions) ~= "table" or #serverOptions == 0 then
	serverOptions = {
		{ Name = "M", Value = "M", Subtitle = "Servidor M", Image = "6500905731", Code = "" },
	}
end

setLoadingProgress(44, "Lendo jogos disponiveis...")

local latestUpdateDate = ZN4XLatestUpdateAt and os.date("%d/%m/%Y", math.floor(ZN4XLatestUpdateAt / 1000)) or "12/06/2026"
local updatesDate = textLabel(updatesPanel, latestUpdateDate, 11, Color3.fromRGB(165, 205, 230), Enum.Font.GothamMedium)
updatesDate.Position = UDim2.fromOffset(10, 34)
updatesDate.Size = UDim2.fromOffset(88, 22)
updatesDate.BackgroundTransparency = 0
updatesDate.BackgroundColor3 = Color3.fromRGB(27, 39, 48)
updatesDate.TextXAlignment = Enum.TextXAlignment.Center
corner(updatesDate, 4)

local updatesScroll = Instance.new("ScrollingFrame")
updatesScroll.BackgroundTransparency = 1
updatesScroll.BorderSizePixel = 0
updatesScroll.Position = UDim2.fromOffset(10, 62)
updatesScroll.Size = UDim2.new(1, -20, 1, -72)
updatesScroll.CanvasSize = UDim2.fromOffset(0, 0)
updatesScroll.ScrollBarThickness = 4
updatesScroll.ScrollBarImageColor3 = colors.accent
updatesScroll.ScrollBarImageTransparency = 0.1
updatesScroll.ScrollingDirection = Enum.ScrollingDirection.Y
updatesScroll.Parent = updatesPanel
pcall(function() updatesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y end)

local updateLines = env.ZN4XUpdates
if type(updateLines) ~= "table" then
	updateLines = { tostring(updateLines or "+ Nenhuma atualizacao informada") }
end
local updateTextLines = {}
for _, updateLine in ipairs(updateLines) do
	table.insert(updateTextLines, tostring(updateLine))
end

local updates = textLabel(updatesScroll,
	table.concat(updateTextLines, "\n\n"),
	12,
	colors.muted,
	Enum.Font.Gotham
)
updates.Position = UDim2.fromOffset(0, 0)
updates.Size = UDim2.new(1, -8, 0, 0)
updates.TextWrapped = true
updates.TextYAlignment = Enum.TextYAlignment.Top
pcall(function() updates.AutomaticSize = Enum.AutomaticSize.Y end)

local function updateUpdatesCanvas()
	local contentHeight = math.max(updates.TextBounds.Y + 8, updatesScroll.AbsoluteSize.Y)
	updates.Size = UDim2.new(1, -8, 0, contentHeight)
	updatesScroll.CanvasSize = UDim2.fromOffset(0, contentHeight)
end

updates:GetPropertyChangedSignal("TextBounds"):Connect(updateUpdatesCanvas)
updatesScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateUpdatesCanvas)
task.defer(updateUpdatesCanvas)

setLoadingProgress(58, "Montando updates...")

local terms = textLabel(accessPanel,
	"Selecione o servidor e entre com sua conta ZN4X.",
	12,
	colors.muted,
	Enum.Font.Gotham
)
terms.Position = UDim2.fromOffset(10, 34)
terms.Size = UDim2.new(1, -20, 0, 38)
terms.TextWrapped = true
terms.TextYAlignment = Enum.TextYAlignment.Top

local loginBox = Instance.new("TextBox")
loginBox.BackgroundColor3 = colors.field
loginBox.BorderSizePixel = 0
loginBox.Position = UDim2.fromOffset(10, 76)
loginBox.Size = UDim2.new(1, -20, 0, 32)
loginBox.ClearTextOnFocus = false
loginBox.Font = Enum.Font.GothamMedium
loginBox.PlaceholderText = "Login"
loginBox.PlaceholderColor3 = colors.faint
loginBox.Text = ""
loginBox.TextColor3 = colors.text
loginBox.TextSize = 12
loginBox.TextXAlignment = Enum.TextXAlignment.Left
loginBox.Parent = accessPanel
pcall(function() loginBox.AutoLocalize = false end)
corner(loginBox, 5)
stroke(loginBox, colors.line, 0.15)

local loginPadding = Instance.new("UIPadding")
loginPadding.PaddingLeft = UDim.new(0, 10)
loginPadding.PaddingRight = UDim.new(0, 10)
loginPadding.Parent = loginBox

local passwordBox = loginBox:Clone()
passwordBox.Name = "PasswordBox"
passwordBox.Position = UDim2.fromOffset(10, 116)
passwordBox.PlaceholderText = "Senha"
passwordBox.Text = ""
passwordBox.Parent = accessPanel

local createAccountButton = button(accessPanel, "Criar conta")
createAccountButton.Position = UDim2.fromOffset(10, 158)
createAccountButton.Size = UDim2.new(1, -20, 0, 32)

local injectButton = button(accessPanel, "Carregar menu")
injectButton.Position = UDim2.fromOffset(10, 198)
injectButton.Size = UDim2.new(1, -20, 0, 36)
injectButton.BackgroundColor3 = colors.accentDark

local accessStatus = textLabel(accessPanel, "Aguardando login e servidor", 11, colors.faint, Enum.Font.Gotham)
accessStatus.Position = UDim2.fromOffset(10, 240)
accessStatus.Size = UDim2.new(1, -20, 0, 20)
accessStatus.TextXAlignment = Enum.TextXAlignment.Center

local notificationHolder = Instance.new("Frame")
notificationHolder.Name = "ZN4XNotifications"
notificationHolder.Position = UDim2.fromOffset(20, 92)
notificationHolder.Size = UDim2.fromOffset(310, 420)
notificationHolder.BackgroundTransparency = 1
notificationHolder.ZIndex = 3000
notificationHolder.Parent = gui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.Padding = UDim.new(0, 8)
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.Parent = notificationHolder

local notificationSerial = 0
local function notify(message)
	if not notificationHolder or not notificationHolder.Parent then
		local activeGui = uiParent:FindFirstChild("ZN4X_Menu") or playerGui:FindFirstChild("ZN4X_Menu")
		if not activeGui then return end
		notificationHolder = activeGui:FindFirstChild("ZN4XNotifications")
		if not notificationHolder then
			notificationHolder = Instance.new("Frame")
			notificationHolder.Name = "ZN4XNotifications"
			notificationHolder.Position = UDim2.fromOffset(20, 92)
			notificationHolder.Size = UDim2.fromOffset(310, 420)
			notificationHolder.BackgroundTransparency = 1
			notificationHolder.ZIndex = 3000
			notificationHolder.Parent = activeGui

			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 8)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = notificationHolder
		end
	end
	notificationSerial = notificationSerial + 1
	local card = Instance.new("Frame")
	card.Name = "Notification"
	card.Size = UDim2.fromOffset(300, 62)
	card.BackgroundColor3 = Color3.fromRGB(9, 10, 15)
	card.BackgroundTransparency = 0.03
	card.BorderSizePixel = 0
	card.LayoutOrder = notificationSerial
	card.ZIndex = 3001
	card.Parent = notificationHolder
	corner(card, 5)
	stroke(card, Color3.fromRGB(35, 40, 54), 0.15)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.fromOffset(4, 48)
	accent.Position = UDim2.fromOffset(0, 7)
	accent.BackgroundColor3 = colors.accent
	accent.BorderSizePixel = 0
	accent.ZIndex = 3002
	accent.Parent = card
	corner(accent, 2)

	local toastTitle = textLabel(card, "ZN4X", 13, colors.muted, Enum.Font.GothamSemibold)
	toastTitle.Position = UDim2.fromOffset(14, 7)
	toastTitle.Size = UDim2.new(1, -24, 0, 18)
	toastTitle.ZIndex = 3002

	local toastText = textLabel(card, message, 13, colors.text, Enum.Font.GothamMedium)
	toastText.Position = UDim2.fromOffset(14, 25)
	toastText.Size = UDim2.new(1, -24, 0, 28)
	toastText.TextWrapped = true
	toastText.ZIndex = 3002

	local timer = Instance.new("Frame")
	timer.AnchorPoint = Vector2.new(0, 1)
	timer.Position = UDim2.new(0, 0, 1, 0)
	timer.Size = UDim2.new(1, 0, 0, 2)
	timer.BackgroundColor3 = colors.accent
	timer.BorderSizePixel = 0
	timer.ZIndex = 3002
	timer.Parent = card

	TweenService:Create(timer, TweenInfo.new(4, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 2),
	}):Play()

	task.delay(4, function()
		if card.Parent then card:Destroy() end
	end)
end

setLoadingProgress(72, "Preparando acesso...")

local function handleRemoteCommand(command)
	if type(command) ~= "table" then return true end
	local commandId = tostring(command.id or "")
	if commandId == "" or env.ZN4XLastRemoteCommandId == commandId then return true end
	env.ZN4XLastRemoteCommandId = commandId

	if tostring(command.type or "") == "notification" then
		local message = tostring(command.message or "")
		local count = math.clamp(tonumber(command.count) or 1, 1, 20)
		if message ~= "" then
			task.spawn(function()
				for index = 1, count do
					notify(message)
					if index < count then task.wait(4.25) end
				end
			end)
		end
		return true
	end

	if tostring(command.type or "") == "deinject" then
		notify("O menu foi encerrado pelo administrador")
		task.wait(0.45)
		pcall(function()
			if type(env.ZN4XRuntimeCleanup) == "function" then
				env.ZN4XRuntimeCleanup(true)
			end
		end)
		pcall(function()
			local menuGui = uiParent:FindFirstChild("ZN4X_Menu") or playerGui:FindFirstChild("ZN4X_Menu")
			if menuGui then menuGui:Destroy() end
		end)
		env.ZN4XLoginAccessWatchToken = nil
		return false
	end

	return true
end

local accessWelcomeShown = false
local function showAccessWelcome(message)
	if type(message) ~= "string" or message == "" then return end
	if accessWelcomeShown then return end
	accessWelcomeShown = true
	notify(message)
end

local function getClientId()
	if type(gethwid) == "function" then
		local ok, value = pcall(gethwid)
		if ok and type(value) == "string" and #value >= 6 then
			return "hwid:" .. value
		end
	end

	local ok, value = pcall(function()
		return game:GetService("RbxAnalyticsService"):GetClientId()
	end)
	if ok and type(value) == "string" and #value >= 6 then
		return "client:" .. value
	end

	return string.format("fallback:%s:%s:%s", tostring(player.UserId), tostring(game.GameId), tostring(game.PlaceId))
end

local function keyApiRequest(endpoint, payload)
	local baseUrl = tostring(env.ZN4XKeyApiBaseUrl or ""):gsub("/+$", "")
	if baseUrl == "" then
		return nil, "API_NOT_CONFIGURED"
	end

	local requestFunction = (syn and syn.request) or http_request or request
	if type(requestFunction) ~= "function" then
		return nil, "REQUEST_UNSUPPORTED"
	end

	local okEncode, body = pcall(HttpService.JSONEncode, HttpService, payload)
	if not okEncode then
		return nil, "JSON_ENCODE_FAILED"
	end

	local okRequest, response = pcall(requestFunction, {
		Url = baseUrl .. endpoint,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json",
		},
		Body = body,
	})
	if not okRequest or type(response) ~= "table" then
		return nil, "API_UNAVAILABLE"
	end

	local responseBody = response.Body or response.body or ""
	local okDecode, decoded = pcall(HttpService.JSONDecode, HttpService, responseBody)
	if not okDecode or type(decoded) ~= "table" then
		return nil, "INVALID_RESPONSE"
	end

	local statusCode = tonumber(response.StatusCode or response.Status or response.status_code) or 0
	if statusCode < 200 or statusCode >= 300 or decoded.ok ~= true then
		return nil, tostring(decoded.error or "API_REJECTED")
	end

	return decoded
end

local function validateAccess(loginText, passwordText)
	local clientId = getClientId()
	local status, statusError = keyApiRequest("/api/status", {
		clientId = clientId,
		robloxUserId = tostring(player.UserId),
		loaderVersion = ZN4XLoaderVersion,
	})
	if status and status.active == true then
		return true, status
	end
	if statusError == "CLIENT_OUTDATED" then
		pcall(function() player:Kick("ZN4X desatualizado. Baixe o loader mais recente.") end)
		return false, "13"
	end
	if statusError == "LOGIN_RESET_REQUIRED" then return false, "14" end
	if statusError == "API_NOT_CONFIGURED" then
		return false, "08"
	end
	if statusError == "REQUEST_UNSUPPORTED" or statusError == "API_UNAVAILABLE" or statusError == "INVALID_RESPONSE" then
		return false, "09"
	end

	local cleanLogin = tostring(loginText or ""):gsub("^%s+", ""):gsub("%s+$", "")
	local cleanPassword = tostring(passwordText or "")
	if cleanLogin == "" or cleanPassword == "" then
		return false, "03"
	end

	local loggedIn, loginError = keyApiRequest("/api/account-login", {
		clientId = clientId,
		robloxUserId = tostring(player.UserId),
		login = cleanLogin,
		password = cleanPassword,
		loaderVersion = ZN4XLoaderVersion,
	})
	if loggedIn and loggedIn.active == true then
		return true, loggedIn
	end
	if loginError == "CLIENT_OUTDATED" then
		pcall(function() player:Kick("ZN4X desatualizado. Baixe o loader mais recente.") end)
		return false, "13"
	end
	if loginError == "API_NOT_CONFIGURED" then
		return false, "08"
	end
	if loginError == "REQUEST_UNSUPPORTED" or loginError == "API_UNAVAILABLE" or loginError == "INVALID_RESPONSE" then
		return false, "09"
	end
	if loginError == "ACCESS_EXPIRED" then return false, "11" end
	if loginError == "ACCOUNT_BANNED" then return false, "12" end
	if loginError == "LOGIN_RESET_REQUIRED" then return false, "14" end
	return false, "10"
end

local function readMenuSource()
	if type(readfile) == "function" then
		local candidates = {
			env.ZN4XMenuFilePath,
			env.ZN4XMenuAbsolutePath,
			"zn4x.lua",
		}
		for _, path in ipairs(candidates) do
			if type(path) == "string" and path ~= "" then
				local ok, source = pcall(readfile, path)
				if ok and type(source) == "string" and #source > 100 then
					return source
				end
			end
		end
	end

	if type(env.ZN4XMenuSourceUrl) == "string" and env.ZN4XMenuSourceUrl ~= "" then
		local ok, source = pcall(function()
			return game:HttpGet(env.ZN4XMenuSourceUrl)
		end)
		if ok and type(source) == "string" and #source > 100 then
			return source
		end
	end

	return nil
end

local selectedServerConfig
local currentExperienceNames = { tostring(game.Name or ""):lower() }
pcall(function()
	local productInfo = MarketplaceService:GetProductInfo(game.PlaceId)
	if type(productInfo) == "table" and type(productInfo.Name) == "string" then
		table.insert(currentExperienceNames, productInfo.Name:lower())
	end
end)

local function selectServerOption(option, index, detected)
	local optionName = tostring(option.Name or option.name or option.Value or option.value or ("Servidor " .. index))
	local optionValue = tostring(option.Value or option.value or optionName)
	local optionSubtitle = tostring(option.Subtitle or option.subtitle or "Servidor selecionado")
	local optionImage = imageAsset(option.Image or option.image, "server_" .. tostring(index))
	selectedServer = optionValue
	selectedServerConfig = option
	serverSelector.Text = optionName
	serverHint.Text = detected and ("Detectado: " .. optionSubtitle) or optionSubtitle
	serverIcon.Image = optionImage
	serverInitial.Visible = optionImage == ""
	dropdown.Visible = false
	dropdown.Size = UDim2.new(0.5, -86, 0, 0)
end

local function serverMatchesCurrentGame(option)
	local placeIds = option.PlaceIds or option.placeIds or option.PlaceId or option.placeId
	if type(placeIds) == "number" or type(placeIds) == "string" then
		if tonumber(placeIds) == game.PlaceId then return true end
	end
	if type(placeIds) == "table" then
		for _, placeId in ipairs(placeIds) do
			if tonumber(placeId) == game.PlaceId then return true end
		end
	end

	local gameIds = option.GameIds or option.gameIds or option.GameId or option.gameId
	if type(gameIds) == "number" or type(gameIds) == "string" then
		if tonumber(gameIds) == game.GameId then return true end
	elseif type(gameIds) == "table" then
		for _, gameId in ipairs(gameIds) do
			if tonumber(gameId) == game.GameId then return true end
		end
	end

	local namePatterns = option.NamePatterns or option.namePatterns or option.NamePattern or option.namePattern
	if type(namePatterns) == "string" then namePatterns = { namePatterns } end
	if type(namePatterns) == "table" then
		for _, pattern in ipairs(namePatterns) do
			local normalizedPattern = tostring(pattern or ""):lower()
			if normalizedPattern ~= "" then
				for _, experienceName in ipairs(currentExperienceNames) do
					if experienceName:find(normalizedPattern, 1, true) then return true end
				end
			end
		end
	end
	return false
end

for index, option in ipairs(serverOptions) do
	local optionName = tostring(option.Name or option.name or option.Value or option.value or ("Servidor " .. index))
	local optionButton = button(dropdown, optionName)
	optionButton.Name = optionName:gsub("%s+", "") .. "Button"
	optionButton.LayoutOrder = index
	optionButton.Size = UDim2.new(1, 0, 0, 26)
	optionButton.ZIndex = 21
	optionButton.MouseButton1Click:Connect(function()
		selectServerOption(option, index, false)
	end)
end

for index, option in ipairs(serverOptions) do
	if serverMatchesCurrentGame(option) then
		selectServerOption(option, index, true)
		break
	end
end

setLoadingProgress(86, "Detectando servidor...")

serverSelector.MouseButton1Click:Connect(function()
	local opening = not dropdown.Visible
	dropdown.Visible = true
	TweenService:Create(dropdown, TweenInfo.new(0.14), {
		Size = UDim2.new(0.5, -86, 0, opening and math.min(8 + (#serverOptions * 29), 240) or 0),
	}):Play()
	if not opening then
		task.delay(0.15, function()
			if dropdown.Size.Y.Offset == 0 then dropdown.Visible = false end
		end)
	end
end)

createAccountButton.MouseButton1Click:Connect(function()
	local inviteUrl = "https://discord.gg/RmuR2USZUN"
	local copied = false
	if type(setclipboard) == "function" then
		copied = pcall(setclipboard, inviteUrl)
	end
	local openFunction = openurl or open_url or (syn and syn.open_url)
	local opened = false
	if type(openFunction) == "function" then
		opened = pcall(openFunction, inviteUrl)
	end
	notify(opened and "Discord aberto para criar sua conta" or (copied and "Convite do Discord copiado" or "Entre em discord.gg/RmuR2USZUN"))
end)

task.spawn(function()
	task.wait(0.35)
	local status = keyApiRequest("/api/status", {
		clientId = getClientId(),
		robloxUserId = tostring(player.UserId),
		loaderVersion = ZN4XLoaderVersion,
	})
	if status and status.active == true then
		env.ZN4XAccessWelcomeMessage = status.welcomeMessage
		env.ZN4XAccessLifetime = status.lifetime == true
		env.ZN4XAccessUntil = status.accessUntil
		env.ZN4XAccessLogin = status.login
		applyAccountProfile(status)
		accessStatus.Text = status.lifetime == true and "Acesso Lifetime ativo" or "Acesso salvo ativo"
		accessStatus.TextColor3 = colors.success
		showAccessWelcome(status.welcomeMessage)
	end
end)

local mouseReleaseConnection
local loadingMenu = false
local function loadSelectedMenu()
	if loadingMenu then
		notify("Error 01: aguarde o carregamento terminar")
		return
	end
	if not selectedServer then
		notify("Error 02: servidor nao suportado")
		accessStatus.Text = "Error 02 - servidor nao suportado"
		accessStatus.TextColor3 = colors.danger
		return
	end
	if selectedServerConfig and selectedServerConfig.Configured == false then
		notify("Error 05: este jogo ainda nao possui script configurado")
		accessStatus.Text = "Error 05 - script nao configurado"
		accessStatus.TextColor3 = colors.danger
		return
	end
	local configuredCode = selectedServerConfig and (selectedServerConfig.Code or selectedServerConfig.code)
	if type(loadstring) ~= "function" and type(configuredCode) ~= "function" then
		notify("Error 04: executor sem suporte a loadstring")
		accessStatus.Text = "Error 04 - executor sem suporte"
		accessStatus.TextColor3 = colors.danger
		return
	end

	loadingMenu = true
	injectButton.Text = "Carregando..."
	injectButton.BackgroundColor3 = colors.accentDark
	accessStatus.Text = "Validando e carregando arquivos"
	accessStatus.TextColor3 = colors.accent

	task.spawn(function()
		local accessAllowed, accessResult = validateAccess(loginBox.Text, passwordBox.Text)
		if not accessAllowed then
			loadingMenu = false
			injectButton.Text = "Carregar menu"
			injectButton.BackgroundColor3 = colors.accentDark
			accessStatus.TextColor3 = colors.danger

			if accessResult == "13" then
				accessStatus.Text = "Error 13 - loader desatualizado"
				notify("Error 13: baixe o loader mais recente")
			elseif accessResult == "03" then
				accessStatus.Text = "Error 03 - informe login e senha"
				notify("Error 03: informe login e senha")
			elseif accessResult == "08" then
				accessStatus.Text = "Error 08 - API nao configurada"
				notify("Error 08: configure a API de keys")
			elseif accessResult == "09" then
				accessStatus.Text = "Error 09 - API indisponivel"
				notify("Error 09: nao foi possivel validar o acesso")
			elseif accessResult == "14" then
				accessStatus.Text = "Resete seu login no Discord"
				notify("Resete seu login no Discord")
			else
				if accessResult == "11" then
					accessStatus.Text = "Error 11 - tempo expirado"
					notify("Error 11: renove seu tempo no Discord")
				elseif accessResult == "12" then
					accessStatus.Text = "Error 12 - conta bloqueada"
					notify("Error 12: conta bloqueada")
				else
					accessStatus.Text = "Error 10 - login recusado"
					notify("Error 10: login ou senha invalidos")
				end
			end
			return
		end

		env.ZN4XAccessWelcomeMessage = accessResult and accessResult.welcomeMessage or nil
		env.ZN4XAccessLifetime = accessResult and accessResult.lifetime == true or false
		env.ZN4XAccessUntil = accessResult and accessResult.accessUntil or nil
		env.ZN4XAccessLogin = accessResult and accessResult.login or nil
		applyAccountProfile(accessResult)
		showAccessWelcome(env.ZN4XAccessWelcomeMessage)
		env.ZN4XValidateCurrentAccess = function()
			local status, statusError = keyApiRequest("/api/status", {
				clientId = getClientId(),
				robloxUserId = tostring(player.UserId),
				loaderVersion = ZN4XLoaderVersion,
			})
			if not status then
				if statusError == "LOGIN_RESET_REQUIRED" then
					return false, { error = statusError }
				end
				return nil, statusError
			end
			if status.active == true then
				env.ZN4XAccessLifetime = status.lifetime == true
				env.ZN4XAccessUntil = status.accessUntil
				env.ZN4XAccessLogin = status.login
				applyAccountProfile(status)
			end
			if handleRemoteCommand(status.remoteCommand) == false then
				return false, status
			end
			return status.active == true, status
		end

		local runner
		local compileError
		local prepareErrorCode = "06"
		local serverCode = configuredCode
		if type(serverCode) == "function" then
			runner = serverCode
		elseif type(serverCode) == "string" and serverCode:gsub("%-%-[^\r\n]*", ""):match("%S") then
			runner, compileError = loadstring(serverCode)
		else
			local source = readMenuSource()
			if source then
				runner, compileError = loadstring(source)
			else
				prepareErrorCode = "05"
				compileError = "Configure o Code deste servidor ou o caminho do zn4x.lua"
			end
		end

		if not runner then
			loadingMenu = false
			injectButton.Text = "Carregar menu"
			injectButton.BackgroundColor3 = colors.accentDark
			accessStatus.Text = "Error " .. prepareErrorCode .. " - falha ao preparar"
			accessStatus.TextColor3 = colors.danger
			if prepareErrorCode == "05" then
				notify("Error 05: script nao encontrado")
			else
				notify("Error 06: falha ao compilar o script")
			end
			warn("ZN4X Error " .. prepareErrorCode .. ": " .. tostring(compileError))
			return
		end

		env.ZN4XExploitSelectedList = selectedServer
		env.ZN4XSkipBoot = true
		local loaderSession = {
			Authorized = true,
			UserId = player.UserId,
			Server = selectedServer,
			CreatedAt = os.time(),
			Nonce = HttpService:GenerateGUID(false),
		}
		env.ZN4XLoaderSession = loaderSession

		local ok, runtimeError = pcall(runner)
		if env.ZN4XLoaderSession == loaderSession then
			env.ZN4XLoaderSession = nil
		end
		if not ok then
			loadingMenu = false
			injectButton.Text = "Carregar menu"
			injectButton.BackgroundColor3 = colors.accentDark
			accessStatus.Text = "Error 07 - erro durante a execucao"
			accessStatus.TextColor3 = colors.danger
			notify("Error 07: falha ao executar o script")
			warn("ZN4X Error 07: " .. tostring(runtimeError))
			return
		end

		local accessWatchToken = {}
		env.ZN4XLoginAccessWatchToken = accessWatchToken
		task.spawn(function()
			while env.ZN4XLoginAccessWatchToken == accessWatchToken do
				task.wait(12)
				local validator = env.ZN4XValidateCurrentAccess
				if type(validator) == "function" then
					local checked, active = pcall(validator)
					if checked and active == false then
						pcall(function()
							if type(env.ZN4XRuntimeCleanup) == "function" then
								env.ZN4XRuntimeCleanup(true)
							end
						end)
						pcall(function()
							local menuGui = uiParent:FindFirstChild("ZN4X_Menu") or playerGui:FindFirstChild("ZN4X_Menu")
							if menuGui then menuGui:Destroy() end
						end)
						env.ZN4XLoginAccessWatchToken = nil
						break
					end
				end
			end
		end)

		notify("Menu carregado com sucesso", true)
		task.wait(0.35)
		if mouseReleaseConnection then mouseReleaseConnection:Disconnect() end
		if gui.Parent then gui:Destroy() end
		env.ZN4XLoginCleanup = nil
	end)
end
injectButton.MouseButton1Click:Connect(loadSelectedMenu)

local dragging = false
local dragStart
local rootStart

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		rootStart = root.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		root.Position = UDim2.new(rootStart.X.Scale, rootStart.X.Offset + delta.X, rootStart.Y.Scale, rootStart.Y.Offset + delta.Y)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		root.Visible = not root.Visible
	end
end)

mouseReleaseConnection = RunService.RenderStepped:Connect(function()
	if gui.Parent and root.Visible then
		pcall(function()
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
			player.CameraMode = Enum.CameraMode.Classic
		end)
	end
end)

env.ZN4XLoginCleanup = function()
	if mouseReleaseConnection then mouseReleaseConnection:Disconnect() end
	if gui and gui.Parent then gui:Destroy() end
	env.ZN4XLoginCleanup = nil
end

task.spawn(function()
	setLoadingProgress(96, "Finalizando eventos...")
	setLoadingProgress(100, "Concluido")
	TweenService:Create(root, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(760, 470),
	}):Play()
	task.wait(0.18)
	loadingView.Visible = false
	mainView.Visible = true

	if ZN4XAutoLaunchRequested then
		for index, option in ipairs(serverOptions) do
			local optionValue = tostring(option.Value or option.value or "")
			if optionValue == ZN4XAutoLaunchServer then
				selectServerOption(option, index, false)
				break
			end
		end
		if selectedServer then
			task.wait(0.15)
			loadSelectedMenu()
		else
			notify("Error 02: servidor do Reviver nao encontrado")
		end
	end
end)
