table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_sniperrifle = {
        model = "models/mp1/Weapons/w_sniperrifle.mdl",
        origin = "Max Payne 1",
        prettyname = "Sniper Rifle",
        holdtype = "rpg",
        killicon = "weapon_mp1_sniperrifle",
        bonemerge = true,
        islethal = true,

        clip = 5,
        keepdistance = 1500,
        attackrange = 3000,

        reloadtime = 1.4,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_AR2,
        reloadanimspeed = 1.5,
        reloadsounds = { 
            { 0.25, "MP1.CommandoOut" },
            { 0.6, "MP1.SniperIn" },
            { 0.9, "MP1.SniperChamber" }
        },

        OnDeploy = function( self, wepent )
            wepent.MP1Data = {}
            wepent.MP1Data.Damage = 70
            wepent.MP1Data.Spread = 0
            wepent.MP1Data.Force = 14
            wepent.MP1Data.BulletModel = "models/mp1/Projectiles/bullet_762mm.mdl"
            wepent.MP1Data.BulletVelocity = 10000
            wepent.MP1Data.BulletSpeedScale = 0

            wepent.MP1Data.EjectShell = false
            wepent.MP1Data.RateOfFire = 1.8
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_RPG
            wepent.MP1Data.Sound = "MP1.SniperFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_sniper" )
            LAMBDA_MP1:SetShellEject( wepent, "models/mp1/Projectiles/casing_300cal.mdl" )
            LAMBDA_MP1:SetMagazineData( wepent, "models/mp1/Weapons/w_sniperrifle_clip.mdl" )
        end,

        OnReload = function( self, wepent )
            LAMBDA_MP1:DropMagazine( wepent )
        end,

        OnAttack = function( self, wepent, target )
            if LAMBDA_MP1:FireWeapon( self, wepent, target ) != true then
                self:SimpleWeaponTimer( 0.4, function()
                    wepent:EmitSound( "MP1.SniperBolt" )
                    LAMBDA_MP1:CreateShellEject( wepent )
                end )
            end

            return true
        end
    }
} )