table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_pumpshotgun = {
        model = "models/mp1/Weapons/w_shotgun.mdl",
        origin = "Max Payne 1",
        prettyname = "Pump-Action Shotgun",
        holdtype = "shotgun",
        killicon = "weapon_mp1_pumpshotgun",
        bonemerge = true,
        islethal = true,

        clip = 7,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 3.0,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_SHOTGUN,
        reloadanimspeed = 1.0,

        OnDeploy = function( self, wepent )
            wepent.MP1Data = {}
            wepent.MP1Data.Damage = 5
            wepent.MP1Data.Spread = 0.55
            wepent.MP1Data.Force = 15
            wepent.MP1Data.BulletModel = "models/mp1/Projectiles/tracer_12ga.mdl"
            wepent.MP1Data.Pellets = 13
            wepent.MP1Data.IsShotgun = true

            wepent.MP1Data.EjectShell = false
            wepent.MP1Data.RateOfFire = 1
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_SHOTGUN
            wepent.MP1Data.Sound = "MP1.PumpShotgunFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_pump" )
            LAMBDA_MP1:SetShellEject( wepent, "models/mp1/Projectiles/casing_12ga.mdl", "MP1.Shell12Ga" )
        end,

        OnAttack = function( self, wepent, target )
            if LAMBDA_MP1:FireWeapon( self, wepent, target ) != true then
                self:SimpleWeaponTimer( 0.5, function()
                    wepent:EmitSound( "MP1.ShotgunPump" )
                    LAMBDA_MP1:CreateShellEject( wepent )
                end )
            end

            return true
        end
    }
} )