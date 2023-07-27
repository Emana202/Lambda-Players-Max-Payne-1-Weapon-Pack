local random = math.random

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_ingramdual = {
        model = "models/mp1/Weapons/w_ingram_dual.mdl",
        origin = "Max Payne 1",
        prettyname = "Dual Ingrams",
        holdtype = "duel",
        killicon = "weapon_mp1_ingramdual",
        bonemerge = true,
        islethal = true,
        dropentity = "weapon_mp1_ingramdual",

        clip = 100,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 1.4,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_DUEL,
        reloadanimspeed = 2.5,
        reloadsounds = { 
            { 0.2, "MP1.IngramOut" },
            { 0.5, "MP1.IngramIn" },
            { 1.0, "MP1.IngramChamber" }
        },

        OnDeploy = function( self, wepent )
            wepent.MP1Data = {}
            wepent.MP1Data.Damage = 5
            wepent.MP1Data.Spread = 1.5
            wepent.MP1Data.Force = 3
            wepent.MP1Data.RateOfFire = 0.00625
            wepent.MP1Data.Sound = "MP1.IngramFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_ingram" )
            LAMBDA_MP1:SetMagazineData( wepent, "models/mp1/Weapons/w_ingram_clip.mdl" )
            LAMBDA_MP1:SetShellEject( wepent )
        end,

        OnReload = function( self, wepent )
            LAMBDA_MP1:DropMagazine( wepent )
            LAMBDA_MP1:DropMagazine( wepent, 6 )
        end,

        OnAttack = function( self, wepent, target )
            LAMBDA_MP1:FireWeapon( self, wepent, target )

            if ( self.l_Clip % 2 ) != 1 then
                wepent.MP1Data.MuzzleAttachment = 1
                wepent.MP1Data.ShellAttachment = 2
            else
                wepent.MP1Data.MuzzleAttachment = 4
                wepent.MP1Data.ShellAttachment = 5
            end

            return true
        end
    }
} )