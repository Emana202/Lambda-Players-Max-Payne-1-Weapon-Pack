table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_jackhammer = {
        model = "models/mp1/Weapons/w_jackhammer.mdl",
        origin = "Max Payne 1",
        prettyname = "Jackhammer",
        holdtype = "ar2",
        killicon = "weapon_mp1_jackhammer",
        bonemerge = true,
        islethal = true,
        dropentity = "weapon_mp1_jackhammer",

        clip = 12,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 1.3,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        reloadanimspeed = 1.66,
        reloadsounds = { 
            { 0.25, "MP1.JackhammerOut" },
            { 0.7, "MP1.JackhammerIn" },
            { 1.1, "MP1.JackhammerChamber" }
        },

        OnDeploy = function( self, wepent )
            wepent.MP1Data = {}
            wepent.MP1Data.Damage = 5
            wepent.MP1Data.Spread = 1.2
            wepent.MP1Data.Force = 15
            wepent.MP1Data.BulletModel = "models/mp1/Projectiles/tracer_12ga.mdl"
            wepent.MP1Data.Pellets = 13
            wepent.MP1Data.IsShotgun = true

            wepent.MP1Data.RateOfFire = 0.333
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN
            wepent.MP1Data.Sound = "MP1.JackhammerFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_jack" )
            LAMBDA_MP1:SetShellEject( wepent, "models/mp1/Projectiles/casing_12ga.mdl", "MP1.Shell12Ga" )
            LAMBDA_MP1:SetMagazineData( wepent, "models/mp1/Weapons/w_jackhammer_clip.mdl" , "MP1.ClipJackhammer" )
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