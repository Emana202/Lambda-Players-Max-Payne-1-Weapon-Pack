table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_ingram = {
        model = "models/mp1/Weapons/w_ingram.mdl",
        origin = "Max Payne 1",
        prettyname = "Ingram",
        holdtype = "pistol",
        killicon = "weapon_mp1_ingram",
        bonemerge = true,
        islethal = true,
        dropentity = "weapon_mp1_ingram",

        clip = 50,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 1.1,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
        reloadanimspeed = 1.8,
        reloadsounds = { 
            { 0, "MP1.IngramOut" },
            { 0.4, "MP1.IngramIn" },
            { 0.7, "MP1.IngramChamber" }
        },

        OnDeploy = function( self, wepent )
            wepent.MP1Data = {}
            wepent.MP1Data.Damage = 5
            wepent.MP1Data.Spread = 1.2
            wepent.MP1Data.Force = 3

            wepent.MP1Data.RateOfFire = 0.03125
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
            wepent.MP1Data.Sound = "MP1.IngramFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_ingram" )
            LAMBDA_MP1:SetMagazineData( wepent, "models/mp1/Weapons/w_ingram_clip.mdl" )
            LAMBDA_MP1:SetShellEject( wepent )
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