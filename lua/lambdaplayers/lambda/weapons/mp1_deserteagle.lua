table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_deserteagle = {
        model = "models/mp1/Weapons/w_deagle.mdl",
        origin = "Max Payne 1",
        prettyname = "Desert Eagle",
        holdtype = "revolver",
        killicon = "weapon_mp1_deserteagle",
        bonemerge = true,
        islethal = true,
        dropentity = "ent_mp1_deserteagle",

        clip = 12,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 1.7,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
        reloadanimspeed = 1,
        reloadsounds = { 
            { 0.2, "MP1.DeagleOut" },
            { 0.7, "MP1.DeagleIn" },
            { 1.4, "MP1.DeagleChamber" }
        },

        OnDeploy = function( self, wepent )
            LAMBDA_MP1:InitializeWeapon( self, wepent, "weapon_mp1_deserteagle" )

            wepent.MP1Data.Damage = 10
            wepent.MP1Data.Spread = 0.15
            wepent.MP1Data.Force = 10
            wepent.MP1Data.BulletModel = "models/mp1/Projectiles/tracer_50cal.mdl"

            wepent.MP1Data.RateOfFire = 0.333
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_REVOLVER
            wepent.MP1Data.Sound = "MP1.DesertEagleFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_deagle" )
            LAMBDA_MP1:SetShellEject( wepent, "models/mp1/Projectiles/casing_50cal.mdl" )
            LAMBDA_MP1:SetMagazineData( wepent )
        end,

        OnReload = function( self, wepent )
            LAMBDA_MP1:DropMagazine( wepent )
        end,

        OnAttack = function( self, wepent, target )
            LAMBDA_MP1:FireWeapon( self, wepent, target )
            return true
        end
    }
} )