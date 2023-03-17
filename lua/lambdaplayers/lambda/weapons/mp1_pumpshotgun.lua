local coroutine_wait = coroutine.wait
local random = math.random

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
        end,

        OnReload = function( self, wepent )
            self:RemoveGesture( ACT_HL2MP_GESTURE_RELOAD_AR2 )
            local reloadLayer = self:AddGesture( ACT_HL2MP_GESTURE_RELOAD_AR2 )

            self:SetIsReloading( true )
            self:Thread( function()
                coroutine_wait( 0.1 )

                while ( self.l_Clip < self.l_MaxClip ) do
                    if self.l_Clip > 0 and random( 1, 2 ) == 1 and self:InCombat() and self:IsInRange( self:GetEnemy(), 512 ) and self:CanSee( self:GetEnemy() ) then break end 

                    if !self:IsValidLayer( reloadLayer ) then
                        reloadLayer = self:AddGesture( ACT_HL2MP_GESTURE_RELOAD_AR2 )
                    end                    
                    self:SetLayerCycle( reloadLayer, 0.2 )
                    self:SetLayerPlaybackRate( reloadLayer, 1.6 )

                    self.l_Clip = self.l_Clip + 1
                    wepent:EmitSound( "MP1.PumpShotgunReload" )
                    coroutine_wait( 0.4 )
                end

                self:RemoveGesture( ACT_HL2MP_GESTURE_RELOAD_AR2 )
                self:SetIsReloading( false )
            end, "MP1_ShotgunReload" )

            return true
        end
    }
} )