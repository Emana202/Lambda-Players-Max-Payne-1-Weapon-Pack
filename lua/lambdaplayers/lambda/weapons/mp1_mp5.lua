table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_mp5 = {
        model = "models/mp1/Weapons/w_mp5.mdl",
        origin = "Max Payne 1",
        prettyname = "MP5",
        holdtype = "ar2",
        killicon = "weapon_mp1_mp5",
        bonemerge = true,
        islethal = true,
        dropentity = "ent_mp1_mp5",

        clip = 30,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 1.4,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SMG1,
        reloadanimspeed = 1.5,
        reloadsounds = { 
            { 0.2, "MP1.IngramOut" },
            { 0.7, "MP1.IngramIn" },
            { 0.95, "MP1.MP5Chamber" }
        },

        OnDeploy = function( self, wepent )
            LAMBDA_MP1:InitializeWeapon( self, wepent, "weapon_mp1_mp5" )

            wepent.MP1Data.Damage = 5
            wepent.MP1Data.Spread = 0.25
            wepent.MP1Data.Force = 3

            wepent.MP1Data.RateOfFire = 0.11
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_SMG1
            wepent.MP1Data.Sound = "MP1.MP5Fire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_mp5" )
            LAMBDA_MP1:SetMagazineData( wepent, "models/mp1/Weapons/w_mp5_clip.mdl" )
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