table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_berettadual = {
        model = "models/mp1/Weapons/w_beretta_dual.mdl",
        origin = "Max Payne 1",
        prettyname = "Dual Berettas",
        holdtype = "duel",
        killicon = "weapon_mp1_berettadual",
        bonemerge = true,
        islethal = true,
        dropentity = "ent_mp1_berettadual",

        clip = 36,
        keepdistance = 750,
        attackrange = 2000,

        reloadtime = 1.4,
        reloadanim = ACT_HL2MP_GESTURE_RELOAD_DUEL,
        reloadanimspeed = 2.5,
        reloadsounds = { 
            { 0.2, "MP1.BerettaOut" },
            { 0.4, "MP1.BerettaIn" },
            { 1.2, "MP1.BerettaChamber" }
        },

        OnDeploy = function( self, wepent )
            LAMBDA_MP1:InitializeWeapon( self, wepent, "weapon_mp1_berettadual" )

            wepent.MP1Data.Damage = 5
            wepent.MP1Data.Spread = 0.65
            wepent.MP1Data.Force = 4
            
            wepent.MP1Data.MuzzleAttachment = 1
            wepent.MP1Data.ShellAttachment = 2

            wepent.MP1Data.RateOfFire = 0.25
            wepent.MP1Data.Animation = ACT_HL2MP_GESTURE_RANGE_ATTACK_DUEL
            wepent.MP1Data.Sound = "MP1.BerettaFire"

            LAMBDA_MP1:SetMuzzleName( wepent, "mp1_muzzleflash_beretta" )
            LAMBDA_MP1:SetMagazineData( wepent )
            LAMBDA_MP1:SetShellEject( wepent )
        end,

        OnReload = function( self, wepent )
            LAMBDA_MP1:DropMagazine( wepent )
            LAMBDA_MP1:DropMagazine( wepent, 6 )
        end,

        OnAttack = function( self, wepent, target )
            if LAMBDA_MP1:FireWeapon( self, wepent, target ) != true then
                wepent.MP1Data.MuzzleAttachment = 4
                wepent.MP1Data.ShellAttachment = 5

                self:SimpleWeaponTimer( 0.08, function()                    
                    if !self:GetIsDead() and self.l_Clip > 0 then
                        LAMBDA_MP1:FireWeapon( self, wepent, target )
                    end
                    
                    wepent.MP1Data.MuzzleAttachment = 1
                    wepent.MP1Data.ShellAttachment = 2
                end, true )
            end

            return true
        end
    }
} )