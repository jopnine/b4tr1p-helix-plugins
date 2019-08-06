if (SERVER) then
	SWEP.Weight				= 10
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if ( CLIENT ) then
	SWEP.PrintName      = "Axe"
	SWEP.Author    = "Black Tea"
	SWEP.Instructions 	= "Left click to attack."
	SWEP.ShowWorldModel		= false

	SWEP.ViewModelBoneMods = {
		["v_weapon.Knife_Handle"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.Bip01_L_Clavicle"] = { scale = Vector(.1, .1, .1), pos = Vector(300, -300, 0), angle = Angle(0, 0, 0) }
	}
-- fixed
	SWEP.VElements = {
		["weapon"] = { type = "Model", model = "models/warz/melee/hatchet.mdl", bone = "v_weapon.Knife_Handle", rel = "", pos = Vector(1, 0.6, 8.5), angle = Angle(0, 105.341, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0 },
	}
	SWEP.WElements = {
		["weapon"] = { type = "Model", model = "models/warz/melee/hatchet.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.5, 0.85, -6.818), angle = Angle(180, 13.295, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

end

SWEP.Base = "hl2_melee"
SWEP.Category			= "Black Tea"
SWEP.Spawnable      = true
SWEP.AdminSpawnable  = true
SWEP.UseHands = true
SWEP.Slot				= 1							// Slot in the weapon selection menu
SWEP.SlotPos			= 1							// Position in the slot
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.HoldType = "melee"
SWEP.Primary.Automatic		= true
SWEP.Primary.Damage			= 15
SWEP.Primary.Reach			= 60
SWEP.Primary.Spread			= .4
SWEP.Primary.Angle			= -.3

SWEP.SwingPos = Vector(3.7, -16, 10.314)
SWEP.SwingAng = Vector(11.85, 0, 70)
SWEP.DisoriginPos = Vector(-16.143, 20.26, 4.015)
SWEP.DisoriginAng = Vector(-90, 42.165, 60.354)

SWEP.SwingPos = Vector(0.7, -16, 10.314)
SWEP.SwingAng = Vector(11.85, 0, 65)
SWEP.DisoriginPos = Vector(-16.143, 30.26, 4.015)
SWEP.DisoriginAng = Vector(-90, 42.165, 60.354)
