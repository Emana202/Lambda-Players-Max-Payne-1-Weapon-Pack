local random = math.random

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_sawedoffshotgun = {
        model = "models/mp1/Weapons/w_sawedshotgun.mdl",
        origin = "Max Payne 1",
        prettyname = "Sawed-Off Shotgun",
        holdtype = "pistol",
        killicon = "weapon_mp1_sawedshotgun",
        bonemerge = true,
        islethal = true,
        dropentity = "weapon_mp1_sawedshotgun",

        clip = 2,
        keepdistance = 500,
        attackrange = 1000,

        reloadtime = 1.3,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        reloadanimspeed = 1.75,
        reloadsounds = { 
            { 0.2, "MP1.SawnOffOut" },
            { 0.7, "MP1.SawnOffIn" },
            { 1.1, "MP1.SawnOffChamber" }
        },

        OnDeploy = function( self, wepent )
            wepent.MP1Data = {}
            wepent.MP1Data.Damage = 5
            wepent.MP1Data.Spread = 1.5
            wepent.MP1Data.Force = 20
            wepent.MP1Data.BulletModel = "models/mp1/Projectiles/tracer_12ga.mdl"
            wepent.MP1Data.Pellets = 13
            wepent.MP1Data.IsShotgun = true

            wepent.MP1Data.EjectShell = false
            wepent.MP1Data.RateOfFire = 0.5
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER
            wepent.MP1Data.Sound = "MP1.SawedShotgunFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_sawed" )
            LAMBDA_MP1:SetShellEject( wepent, "models/mp1/Projectiles/casing_12ga.mdl", "MP1.Shell12Ga" )
        
            if random( 1, 3 ) == 1 then wepent:EmitSound( "MP1.SawnOffChamber" ) end
        end,

        OnAttack = function( self, wepent, target )
            LAMBDA_MP1:FireWeapon( self, wepent, target )
            return true
        end,

        OnReload = function( self, wepent )
            self:SimpleWeaponTimer( 0.35, function()
                LAMBDA_MP1:CreateShellEject( wepent  )
                if self.l_Clip == 0 then LAMBDA_MP1:CreateShellEject( wepent ) end
            end )
        end,
    }
} )