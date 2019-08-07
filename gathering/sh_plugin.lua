local PLUGIN = PLUGIN
PLUGIN.name = "Gathering"
PLUGIN.author = "La Corporativa | ported to Helix by B4tr1p"
PLUGIN.desc = "Adds resources and ways to get them."
PLUGIN.resEntities = {"nut_tree", "nut_rock"}
PLUGIN.spawnedGathers = PLUGIN.spawnedGathers or {}
PLUGIN.gatherPoints = PLUGIN.gatherPoints or {}

ix.config.Add("gathering", true, "Whether gathering is active or not.", nil, {
	category = "Gathering"
})

ix.config.Add("gDamage", true, "Whether the trees and rocks will deplete from gathering resources from them", nil, {
	category = "Gathering"
})

ix.config.Add("gatheringSpawn", 3600, "How much time it will take for a gathering entity to spawn.", nil, {
	data = {min = 1, max = 84600},
	category = "Gathering"
})

ix.config.Add("gMaxWorldGather", 12, "Number of gathering entitites the World will have.", nil, {
	data = {min = 1, max = 50},
	category = "Gathering"
})

ix.config.Add("lifeDrain", 10, "How much life will be drain from the entities that are being gathered.", nil, {
	category = "Gathering",
	data = {min=1, max=200}
})

ix.config.Add("treeLife", 150, "How much life the trees will have.", nil, {
	category = "Gathering",
	data = {min=1, max=2000}
})

ix.config.Add("rockLife", 100, "How much life the rocks will have.", nil, {
	category = "Gathering",
	data = {min=1, max=2000}
})

local gatherItems = {
	["rock"] = {
		["default"] = {
			["iron_ore"] = 10,
			["coal"] = 3,
			["sulphur"] = 3,
			["iron_copper"] = 8
		}
	},
	["tree"] = {
		["default"] = {
			["wood"] = 15
		}
	}
}

if SERVER then
	resource.AddWorkshop("152429256")

	function PLUGIN:SaveData()
		self:SetData(self.gatherPoints)
	end

	function PLUGIN:LoadData()
		self.gatherPoints = self:GetData()
		self:Initialize()
	end

	function PLUGIN:Initialize()
		if ix.config.Get("gathering") then
			for k, v in pairs(self.gatherPoints) do
				self:setGathering(v)
			end
		end
	end

	function PLUGIN:Think()

		if ix.config.Get("gathering") then
			self:removeInvalidGathers()

			if (#self.spawnedGathers <= ix.config.Get("gMaxWorldGather") and (!curTime or curTime + ix.config.Get("gatheringSpawn") <= CurTime())) then
					local curTime = CurTime()
					local point = table.Random(self.gatherPoints)

					if (!point) then return end

					for _, v in pairs(self.spawnedGathers) do
						if point == v[2] then return end
					end

					if #self.spawnedGathers >= ix.config.Get("gMaxWorldGather") then return end

					self:setGathering(point)
			end
		end
	end

	local function getRandomModel()
		local trees = {
			"models/props_foliage/tree_poplar_01.mdl",
			"models/props_foliage/tree_springers_01a-lod.mdl",
			"models/props_foliage/tree_springers_01a.mdl",
			"models/props_foliage/tree_deciduous_03b.mdl",
			"models/props_foliage/tree_deciduous_03a.mdl",
			"models/props_foliage/tree_deciduous_02a.mdl",
			"models/props_foliage/tree_deciduous_01a.mdl",
			"models/props_foliage/tree_deciduous_01a-lod.mdl",
			"models/props_foliage/tree_cliff_01a.mdl",
		}
		local random = math.random(1,table.getn(trees))
		return trees[random]
	end

	function PLUGIN:setGathering(point)
		local entity = ents.Create("nut_"..point[2])
		entity:SetPos(point[1])
		entity:SetNetVar("resTable", point[3])
		entity:SetAngles(entity:GetAngles())

		if (point[2] == "rock") then
			entity:SetModel("models/props_wasteland/rockgranite02a.mdl")
		elseif (point[2] == "tree") then
			entity:SetModel(getRandomModel())
		end

		entity:Spawn()
		table.insert(self.spawnedGathers, {entity, point})
	end

	function PLUGIN:removeInvalidGathers()
		for k, v in ipairs(self.spawnedGathers) do
			if !IsValid(v[1]) then
				table.remove(self.spawnedGathers, k)
			end
		end
	end
end

local function give(client, item)
	local given = false
	given = client:GetCharacter():GetInv():Add(item.uniqueID)
	return given
end

local function getGatheredItem(client, ent)
	local randomZ = math.Rand(0,100)
	local localProb = 0
	for k, v in pairs(gatherItems[string.sub(ent:GetClass(), 5)]) do
		if k == ent:GetNetVar("resTable") then
			for k2,v2 in pairs(v) do
				-- randomZ must be between localProb and the sum of the localProb and the probability of each good
				if localProb <= randomZ and (v2+localProb) > randomZ then
					return k2
				end
				localProb = localProb + v2
			end
		end
	end
	return nil
end

local function getItemEntity(item)

	 for k, v in SortedPairs(ix.item.list) do
		  if (item == v.uniqueID) then
			  return v
		  end
	 end
	
	return nil
end


netstream.Hook("nut_lc_gather", function(client, ent, tool)
	if (IsValid(ent)) then
		if (ent:GetClass() == "nut_rock" and tool:GetClass() == "hl2_m_pickaxe") or (ent:GetClass() == "nut_tree" and tool:GetClass() == "hl2_m_axe") then
			client:EmitSound( Format( "physics/concrete/rock_impact_hard%d.wav",math.random(1, 6)), 80, math.random(150,170))
			local itemID = getGatheredItem(client, ent)
			if (itemID != nil) then
				local itemEntity = getItemEntity(itemID)
				if (give(client, itemEntity)) then
					if (ix.config.Get("gDamage")) then
						ent:SetHealth(ent:Health() - ix.config.Get("lifeDrain"))
						if (ent:Health() < 0) then
							ent:Remove()
						end
					end
					client:NotifyLocalized("lc_youGathered", itemEntity.name)
				else
					client:NotifyLocalized("lc_noSpace")
				end
			end
		end
	end
end)

netstream.Hook("nut_displayGatherSpawnPoints", function(data)
	for k, v in pairs(data) do
		local emitter = ParticleEmitter(v[1])
		local smoke = emitter:Add("sprites/glow04_noz", v[1])
		smoke:SetVelocity(Vector(0, 0, 1))
		smoke:SetDieTime(15)
		smoke:SetStartAlpha(255)
		smoke:SetEndAlpha(255)
		smoke:SetStartSize(64)
		smoke:SetEndSize(64)
		smoke:SetColor(255,0,0)
		smoke:SetAirResistance(300)
	end
end)

ix.command.Add("badairadd", {
	description = "Add an area",
	adminOnly = true,
	OnRun = function(self, client, arguments)
		local pos = client:GetEyeTraceNoCursor().HitPos

		if (!client:GetNetVar("badairMin")) then
			client:SetNetVar("badairMin", pos, client)
			client:Notify(L("badairCommand", client))
		else
			local vMin = client:GetNetVar("badairMin")
			local vMax = pos
			ix.badair.addArea(vMin, vMax)

			client:SetNetVar("badairMin", nil, client)
			client:Notify(L("badairAdded", client))
		end
	end
})

ix.command.Add("gatheraddspawn", {
	adminOnly = true,
	description = "Add some resource spawn ",
	arguments = {ix.type.string, ix.type.string},

	OnRun = function(self, client, entity, tablee)

		if (!entity) then
			return "@lc_noEntity"
		end
		if (!tablee) then
			return "@lc_noTable"
		else
			for k, v in pairs(gatherItems[entity]) do
				if k == tablee then
					local trace = client:GetEyeTraceNoCursor()
					local hitpos = trace.HitPos + Vector(trace.HitNormal*5)
					table.insert(PLUGIN.gatherPoints, {hitpos, entity, tablee})
					PLUGIN:setGathering(PLUGIN.gatherPoints[#PLUGIN.gatherPoints])
					client:NotifyLocalized("lc_gatherSpawn")
				else
					client:NotifyLocalized("lc_noTableName")
				end
			end
		end
	end
})

ix.command.Add("gatherremovespawn", {
	adminOnly = true,
	syntax = "<number distance>",
	OnRun = function(self, client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local hitpos = trace.HitPos + trace.HitNormal*5
		local range = arguments[1] or 128
		local count = 0
		for k, v in pairs(PLUGIN.gatherPoints) do
			local distance = v[1]:Distance(hitpos)
			if distance <= tonumber(range) then
				PLUGIN.gatherPoints[k] = nil
				count = count+1
			end
		end
		client:NotifyLocalized("lc_removedSpawners", count)
	end
})

ix.command.Add("gatherdisplayspawn", {
	adminOnly = true,
	OnRun = function(client)
		if SERVER then
			netstream.Start(client, "nut_displayGatherSpawnPoints", PLUGIN.gatherPoints)
			client:notifyLocalized("lc_display")
		end
	end
})
