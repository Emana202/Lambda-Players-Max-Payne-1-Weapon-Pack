local IsValid = IsValid
local CurTime = CurTime
local random = math.random
local Rand = math.Rand
local ents_Create = ents.Create
local util_Effect = util.Effect
local EffectData = EffectData

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_m79 = {
        model = "models/mp1/Weapons/w_m79.mdl",
        origin = "Max Payne 1",
        prettyname = "M79",
        holdtype = "shotgun",
        killicon = "weapon_mp1_m79",
        bonemerge = true,
        islethal = true,
        dropentity = "ent_mp1_m79",

        clip = 1,
        keepdistance = 750,
        attackrange = 1000,

        reloadtime = 1.3,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        reloadanimspeed = 1.66,
        reloadsounds = { 
            { 0.2, "MP1.M79Out" },
            { 0.5, "MP1.M79In" },
            { 1.0, "MP1.M79Chamber" }
        },

        OnDeploy = function( self, wepent )
            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_m79" )
            LAMBDA_MP1:SetMagazineData( wepent, "models/mp1/Projectiles/casing_40mm.mdl", "MP1.Shell40mm" )
        end,

        OnReload = function( self, wepent )
            LAMBDA_MP1:DropMagazine( wepent )
        end,

        OnAttack = function( self, wepent, target )            
            if self.l_Clip <= 0 then self:ReloadWeapon() return true end

            self.l_Clip = self.l_Clip - 1
            self.l_WeaponUseCooldown = CurTime() + Rand( 1.0, 1.5 )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW )

            wepent:EmitSound( "MP1.M79Fire" )

            local fireSrc = wepent:GetPos()
            local targetPos = target:GetPos()

            local fireAng = ( targetPos - fireSrc ):Angle()
            local firePos = ( targetPos + fireAng:Up() * ( random( -50, 50 ) + ( fireSrc:Distance( targetPos ) / 20 ) ) + fireAng:Right() * random( -50, 50 ) )
            fireAng = ( firePos - fireSrc ):Angle()

            local bullet = ents_Create( "ent_mp1_grenade_m79" )
            bullet:SetOwner( self )
            bullet.entOwner = self

            bullet.damage = 166
            bullet.radius = 393.7
            bullet.hotspot = 196.8
            bullet.dmgtype = ( DMG_BLAST + DMG_AIRBOAT )

            bullet:SetPos( fireSrc )
            bullet:SetAngles( fireAng )
            bullet:Spawn()
            bullet:Activate() 

            bullet.l_UseLambdaDmgModifier = true
            bullet.l_killiconname = wepent.l_killiconname

            local phys = bullet:GetPhysicsObject()
            if IsValid( phys ) then phys:SetVelocity( fireAng:Forward() * 2250 ) end

            if IsFirstTimePredicted() then
                net.Start( "lambda_mp1_createmuzzleflash" )
                    net.WriteEntity( wepent )
                    net.WriteUInt( 1, 3 )
                net.Broadcast()
            end
            
            return true
        end
    }
} )