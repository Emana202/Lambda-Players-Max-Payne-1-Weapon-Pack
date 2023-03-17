local IsValid = IsValid
local CurTime = CurTime
local random = math.random
local Rand = math.Rand
local ents_Create = ents.Create

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_molotov = {
        model = "models/mp1/Weapons/w_molotov.mdl",
        origin = "Max Payne 1",
        prettyname = "Molotov Cocktail",
        holdtype = "grenade",
        killicon = "weapon_mp1_molotov",
        bonemerge = true,
        islethal = true,

        clip = 1,
        keepdistance = 500,
        attackrange = 800,

        OnAttack = function( self, wepent, target )            
            self.l_WeaponUseCooldown = CurTime() + Rand( 2.0, 4.0 )

            self:SimpleWeaponTimer( 0.5, function()                
                self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE )
                self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE )

                wepent:EmitSound( "MP1.ThrowableFire" )

                local fireSrc = wepent:GetPos()
                local targetPos = target:GetPos()

                local fireAng = ( targetPos - fireSrc ):Angle()
                local firePos = ( targetPos + fireAng:Up() * ( random( -50, 50 ) + ( fireSrc:Distance( targetPos ) / 4 ) ) + fireAng:Right() * random( -50, 50 ) )
                fireAng = ( firePos - fireSrc ):Angle()

                local prj = ents_Create( "ent_mp1_molotov_thrown" )
                prj:SetPos( fireSrc )
                prj:SetAngles( fireAng )
                prj:Spawn()
                prj:Activate() 

                prj:SetOwner( self )
                prj.swep = wepent
                prj.entOwner = self
                prj.Damage = 135
                prj.Radius = 175

                local phys = prj:GetPhysicsObject()
                if IsValid( phys ) then
                    phys:SetVelocity( fireAng:Forward() * 950 )
                    phys:SetAngleVelocity( fireAng:Forward() * 950 )
                end
            end )
            
            return true
        end
    }
} )