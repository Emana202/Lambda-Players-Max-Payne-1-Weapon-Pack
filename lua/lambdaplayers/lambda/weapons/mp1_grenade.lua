local IsValid = IsValid
local CurTime = CurTime
local random = math.random
local Rand = math.Rand
local ents_Create = ents.Create

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_grenade = {
        model = "models/mp1/Weapons/w_grenade.mdl",
        origin = "Max Payne 1",
        prettyname = "Grenade",
        holdtype = "grenade",
        killicon = "weapon_mp1_grenade",
        bonemerge = true,
        islethal = true,

        clip = 1,
        keepdistance = 600,
        attackrange = 1000,

        OnAttack = function( self, wepent, target )            
            self.l_WeaponUseCooldown = CurTime() + Rand( 3.0, 5.0 )

            self:SimpleWeaponTimer( 0.5, function()                
                self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE )
                self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE )

                wepent:EmitSound( "MP1.ThrowableFire" )

                local fireSrc = wepent:GetPos()
                local targetPos = target:GetPos()

                local fireAng = ( targetPos - fireSrc ):Angle()
                local firePos = ( targetPos + fireAng:Up() * ( random( -50, 50 ) + ( fireSrc:Distance( targetPos ) / 15 ) ) + fireAng:Right() * random( -50, 50 ) )
                fireAng = ( firePos - fireSrc ):Angle()

                local prj = ents_Create( "ent_mp1_grenade_thrown" )
                prj:SetPos( fireSrc )
                prj:SetAngles( fireAng )
                prj:Spawn()
                prj:Activate() 

                prj:SetOwner( self )
                prj.swep = wepent
                prj.entOwner = self
                prj.Damage = 150
                prj.Radius = 375

                local phys = prj:GetPhysicsObject()
                if IsValid( phys ) then
                    phys:SetVelocity( fireAng:Forward() * 1000 )
                    phys:SetAngleVelocity( fireAng:Forward() * 1000 )
                end
            end )
            
            return true
        end
    }
} )