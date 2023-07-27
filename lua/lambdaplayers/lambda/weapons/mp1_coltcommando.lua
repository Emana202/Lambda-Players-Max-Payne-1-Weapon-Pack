table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_coltcommando = {
        model = "models/mp1/Weapons/w_coltcommando.mdl",
        origin = "Max Payne 1",
        prettyname = "Colt Commando",
        holdtype = "ar2",
        killicon = "weapon_mp1_coltcommando",
        bonemerge = true,
        islethal = true,
        dropentity = "weapon_mp1_coltcommando",

        clip = 30,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 1.4,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        reloadanimspeed = 1.33,
        reloadsounds = { 
            { 0, "MP1.CommandoOut" },
            { 0.3, "MP1.CommandoIn" },
            { 1.1, "MP1.CommandoChamber" }
        },

        OnDeploy = function( self, wepent )
            wepent.MP1Data = {}
            wepent.MP1Data.Damage = 10
            wepent.MP1Data.Spread = 0.075
            wepent.MP1Data.Force = 6
            wepent.MP1Data.BulletModel = "models/mp1/Projectiles/tracer_50cal.mdl"

            wepent.MP1Data.RateOfFire = 0.166
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_AR2
            wepent.MP1Data.Sound = "MP1.ColtCommandoFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_colt" )
            LAMBDA_MP1:SetMagazineData( wepent, "models/mp1/Weapons/w_coltcommando_clip.mdl" )
            LAMBDA_MP1:SetShellEject( wepent, "models/mp1/Projectiles/casing_300cal.mdl" )
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