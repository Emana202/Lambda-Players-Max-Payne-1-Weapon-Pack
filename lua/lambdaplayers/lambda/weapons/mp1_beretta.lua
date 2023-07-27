table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_beretta = {
        model = "models/mp1/Weapons/w_beretta.mdl",
        origin = "Max Payne 1",
        prettyname = "Beretta",
        holdtype = "pistol",
        killicon = "weapon_mp1_beretta",
        bonemerge = true,
        islethal = true,
        dropentity = "weapon_mp1_beretta",

        clip = 18,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 1.4,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_PISTOL,
        reloadanimspeed = 1,
        reloadsounds = { 
            { 0.2, "MP1.BerettaOut" },
            { 0.4, "MP1.BerettaIn" },
            { 1.2, "MP1.BerettaChamber" }
        },

        OnDeploy = function( self, wepent )
            wepent.MP1Data = {}
            wepent.MP1Data.Damage = 5
            wepent.MP1Data.Spread = 0.35
            wepent.MP1Data.Force = 4

            wepent.MP1Data.RateOfFire = 0.25
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_PISTOL
            wepent.MP1Data.Sound = "MP1.BerettaFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_beretta" )
            LAMBDA_MP1:SetMagazineData( wepent )
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