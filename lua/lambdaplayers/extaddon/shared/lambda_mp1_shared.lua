local IsValid = IsValid
local net = net
local EffectData = EffectData
local util_Effect = util.Effect

util.PrecacheModel( "models/mp1/Projectiles/casing_9mm.mdl" )
util.PrecacheModel( "models/mp1/Projectiles/casing_40mm.mdl" )
util.PrecacheModel( "models/mp1/Projectiles/casing_50cal.mdl" )
util.PrecacheModel( "models/mp1/Projectiles/casing_12ga.mdl" )
util.PrecacheModel( "models/mp1/Projectiles/casing_300cal.mdl" )

util.PrecacheModel( "models/mp1/Weapons/w_beretta_clip.mdl" )
util.PrecacheModel( "models/mp1/Weapons/w_coltcommando_clip.mdl" )
util.PrecacheModel( "models/mp1/Weapons/w_ingram_clip.mdl" )
util.PrecacheModel( "models/mp1/Weapons/w_jackhammer_clip.mdl" )
util.PrecacheModel( "models/mp1/Weapons/w_mp5_clip.mdl" )
util.PrecacheModel( "models/mp1/Weapons/w_sniperrifle_clip.mdl" )

if ( CLIENT ) then

	net.Receive( "lambda_mp1_setmuzzlename", function()
		local weapon = net.ReadEntity()
		if !IsValid( weapon ) then return end
		
		weapon.MuzzleName = net.ReadString()
	end )

	net.Receive( "lambda_mp1_setshelldata", function()
		local weapon = net.ReadEntity()
		if !IsValid( weapon ) then return end

		weapon.shellmodel = net.ReadString()
		weapon.shellcollidesound = net.ReadString()
	end )
	
	net.Receive( "lambda_mp1_setmagazinedata", function()
		local weapon = net.ReadEntity()
		if !IsValid( weapon ) then return end

		weapon.magazinemodel = net.ReadString()
		weapon.magazinecollidesound = net.ReadString()
	end )

	net.Receive( "lambda_mp1_createmuzzleflash", function()
		local weapon = net.ReadEntity()
		if !IsValid( weapon ) or !weapon:GetAttachment( 1 ) then return end

		local fx = EffectData()
		fx:SetEntity( weapon )
		fx:SetAttachment( net.ReadUInt( 3 ) )
		util_Effect( "mp1_muzzle", fx, true, true )
	end )

	local function GetWeaponSmokeBlastParticle( weapon )
		local lambda = weapon:GetParent()
		if IsValid( lambda ) then
			local wepData = _LAMBDAPLAYERSWEAPONS[ lambda:GetWeaponName() ]
			if wepData and wepData.origin == "Max Payne 2" then return "mp2_smokeblast_eject" end
		end
		return "mp1_smokeblast_eject"
	end

	local function GetWeaponMuzzleFlashPos( weapon, muzzleAttach )
		local attach = weapon:GetAttachment( muzzleAttach )
		return ( attach and attach.Pos or weapon:GetPos() )
	end

	local function OnLambdaInitialize( lambda, weapon )
		if !IsValid( weapon ) then return end
		
		weapon.MuzzleName = "mp1_muzzleflash_beretta"
		weapon.BulletSize = 1
		weapon.GetSmokeBlastParticle = GetWeaponSmokeBlastParticle
		weapon.GetMuzzleFlashPos = GetWeaponMuzzleFlashPos
	end

	hook.Add( "LambdaOnInitialize", "Lambda_MP1_OnLambdaInitialize", OnLambdaInitialize )

end

if ( SERVER ) then

	local random = math.random
	local Rand = math.Rand
	local ents_Create = ents.Create
	local sound_Play = sound.Play
	local IsFirstTimePredicted = IsFirstTimePredicted
	local isvector = isvector
	local isentity = isentity
	local CurTime = CurTime
	local Vector = Vector
	local GetConVar = GetConVar
	local weapons_Get = weapons.Get

	local damageMult, fireProjectiles, projVelMult, infiniteAmmo
	local fireBulletTbl = {
		AmmoType = "mp1_ammo",
		Tracer = 1,
		HullSize = 2
	}

	util.AddNetworkString( "lambda_mp1_setmuzzlename" )
	util.AddNetworkString( "lambda_mp1_setshelldata" )
	util.AddNetworkString( "lambda_mp1_setmagazinedata" )
	util.AddNetworkString( "lambda_mp1_createmuzzleflash" )

	LAMBDA_MP1 = LAMBDA_MP1 or {}

	function LAMBDA_MP1:SetMuzzleName( weapon, name )
		net.Start( "lambda_mp1_setmuzzlename" )
			net.WriteEntity( weapon )
			net.WriteString( name )
		net.Broadcast()
	end

	function LAMBDA_MP1:SetShellEject( weapon, model, collideSnd )
		model = model or "models/mp1/Projectiles/casing_9mm.mdl"
		collideSnd = collideSnd or "MP1.Shell"

		net.Start( "lambda_mp1_setshelldata" )
			net.WriteEntity( weapon )
			net.WriteString( model )
			net.WriteString( collideSnd )
		net.Broadcast()
	end

	function LAMBDA_MP1:SetMagazineData( weapon, model, collideSnd )
		model = model or "models/mp1/Weapons/w_beretta_clip.mdl"
		collideSnd = collideSnd or "MP1.Clip"

		net.Start( "lambda_mp1_setmagazinedata" )
			net.WriteEntity( weapon )
			net.WriteString( model )
			net.WriteString( collideSnd )
		net.Broadcast()
	end

	function LAMBDA_MP1:CreateShellEject( weapon, attach )
        if !IsFirstTimePredicted() then return end

		local fx = EffectData()
		fx:SetEntity( weapon )
		fx:SetOrigin( weapon:GetPos() )
		fx:SetNormal( weapon:GetForward() )
		fx:SetAttachment( attach or weapon.MP1Data.ShellAttachment or 2 )
		util_Effect( "mp1_shell", fx, true, true )
	end

	function LAMBDA_MP1:DropMagazine( weapon, attach )
        if !IsFirstTimePredicted() then return end

		local fx = EffectData()
        fx:SetEntity( weapon )
        fx:SetOrigin( weapon:GetPos() )
        fx:SetAngles( angle_zero )
        fx:SetAttachment( attach or 3 )
        util_Effect( "mp1_magazine", fx, true, true )
	end

	local function LambdaGetActiveWeapon( lambda )
		return lambda.WeaponEnt
	end
	local function NullFunction() end

	local function WeaponFireCallBack( weapon, attacker, tr, dmginfo, phys_bullet_ent )
		if !IsValid( attacker ) then return end

		local hitEnt = tr.Entity
		if !IsValid( hitEnt ) then return end

		dmginfo:SetAttacker( attacker )
		dmginfo:SetInflictor( phys_bullet_ent or weapon )

		if weapon.MP1Data.IsShotgun and ( hitEnt:IsPlayer() or hitEnt:IsRagdoll() ) then 
			dmginfo:SetDamageForce( dmginfo:GetDamageForce() / 6 ) 
		end	

		local class = hitEnt:GetClass()
		if class == "npc_rollermine" or class == "npc_turret_floor" or class == "npc_manhack" then 
			dmginfo:SetDamageType( DMG_PREVENT_PHYSICS_FORCE ) 
		end
		
		if hitEnt:IsNPC() or hitEnt:IsPlayer() then 
			dmginfo:SetDamageForce( dmginfo:GetDamageForce() + vector_up * ( weapon.MP1Data.Force * 575 ) )
		end
	end
	local WeaponFireCallBackImpact = {
		default = function( weapon, attacker, tr, dmginfo, muzzleAttach )
			if ( CLIENT ) then return end

			net.Start( "MPX_ShootBulletDefault" )
				net.WriteEntity( weapon )
				net.WriteVector( tr.StartPos )
				net.WriteVector( tr.HitPos )
				net.WriteUInt( muzzleAttach, 4 )
			net.Broadcast()							

			local impact_sound = mp1_lib.hit_sound[tr.MatType]
			if impact_sound and !tr.HitSky then sound_Play( impact_sound, tr.HitPos ) end	
		end,
		physics = function( weapon, attacker, tr, dmginfo )
			local sound = mp1_lib.hit_sound[ tr.MatType ]
			if sound and !tr.HitSky then weapon:EmitSound( sound ) end	
		end
	}

	function LAMBDA_MP1:InitializeWeapon( lambda, weapon, class )
		weapon.MP1Data = {}
		weapon.MP1Data.StoredClass = class
		weapon.MP1Data.StoredTable = weapons_Get( class )
		weapon.MP1Data.DoImpactEffect = weapon.MP1Data.StoredTable.DoImpactEffect

		lambda.GetActiveWeapon = LambdaGetActiveWeapon
		weapon.SetClip1 = NullFunction
		weapon.FireCallBack = WeaponFireCallBack
		weapon.FireCallBackImpact = WeaponFireCallBackImpact
	end

	local function OnBulletDoImpactEffect( bullet, ... )
		if !bullet.l_Lambdified or !IsValid( bullet.entOwner ) then return end
		return bullet.wp_DoImpactEffect( bullet.wp_stored, ... ) 
	end

	function LAMBDA_MP1:FireWeapon( lambda, weapon, target )
	    if lambda.l_Clip <= 0 then lambda:ReloadWeapon() return true end
	    local mp1Data = weapon.MP1Data
	    
	    infiniteAmmo = infiniteAmmo or GetConVar( "mp1_infinite_ammo" )
	    if infiniteAmmo:GetInt() != 2 then lambda.l_Clip = lambda.l_Clip - ( mp1Data.ClipUsage or 1 ) end

	    lambda.l_WeaponUseCooldown = CurTime() + ( mp1Data.RateOfFire or 0.1 )

	    local fireAnim = mp1Data.Animation
	    if fireAnim then lambda:RemoveGesture( fireAnim ); lambda:AddGesture( fireAnim ) end

	    local fireSnd = mp1Data.Sound
	    if fireSnd then weapon:EmitSound( fireSnd ) end

		local shootPos = weapon:GetPos()
	    local firePos = ( isvector( target ) and target or ( ( isentity( target ) and IsValid( target ) ) and target:WorldSpaceCenter() or nil ) )
	    if !firePos then firePos = ( shootPos + lambda:GetForward() * 8197 ) end

		local aimVec = ( firePos - shootPos ):Angle()
		local targPos = firePos + aimVec:Up() * random( -25, 25 ) + aimVec:Right() * random( -25, 25 )
		aimVec = ( targPos - shootPos ):Angle()

		local muzzleAttach = ( mp1Data.MuzzleAttachment or 1 )
		if IsFirstTimePredicted() then
			net.Start( "lambda_mp1_createmuzzleflash" )
				net.WriteEntity( weapon )
				net.WriteUInt( muzzleAttach, 3 )
			net.Broadcast()
		end
		
		if mp1Data.EjectShell != false then 
			LAMBDA_MP1:CreateShellEject( weapon ) 
		end

		damageMult = damageMult or GetConVar( "mp1_damage_mul" )
		local dmg_mul = damageMult:GetFloat()

		local spread = mp1Data.Spread
		local numShots = ( mp1Data.Pellets or 1 )
		local dmg = mp1Data.Damage
		local force = mp1Data.Force

		fireProjectiles = fireProjectiles or GetConVar( "mp1_projectiles" )
		if fireProjectiles:GetBool() then
			local mul = ( mp1Data.BulletSpeedScale or 5 )
			local bulletVel = ( mp1Data.BulletVelocity or 1968.5 )
			local model = ( mp1Data.BulletModel or "models/mp1/Projectiles/tracer_9mm.mdl" )

			projVelMult = projVelMult or GetConVar( "mp1_prj_vel_mul" )
			local velMult = projVelMult:GetFloat()

			if isentity( target ) and IsValid( target ) then
				local targVel = ( target:IsNextBot() and target.loco:GetVelocity() or target:GetVelocity() )
				aimVec = ( ( targPos + targVel * ( ( targPos:Distance(shootPos) / bulletVel ) * Rand( 0.33, 1.0 ) ) ) - shootPos ):Angle()
			end

			for i = 1, numShots do 
				local bullet = ents_Create( "ent_mp1_bullet_easy" )
				local spread = ( ( spread * 5 ) / ( random( 1, 100 ) > 75 and 1 or 3 ) )
				local vel = ( ( bulletVel + ( bulletVel / 100 ) * random( -mul, mul ) ) * velMult )

				bullet.data = {
					model = model,
					vel = vel,
					force = force,
					damage = ( dmg * dmg_mul ),
					spread = spread,
					bullcam = false,
					owner = lambda
				}
				
				local ang = aimVec
				if !mp1Data.IsShotgun or i != numShots then
					ang:RotateAroundAxis( ang:Forward(), Rand( -spread, spread ) )
					ang:RotateAroundAxis( ang:Right(), Rand( -spread, spread ) )
					ang:RotateAroundAxis( ang:Up(), Rand( -spread, spread ) )
				end

				bullet.ForwardDir = ang:Forward() 
				bullet.DistanceLimit = ( mp1Data.Distance or 0 )
				bullet.muzzleAttach = muzzleAttach
				bullet.DoImpactEffect = OnBulletDoImpactEffect

				bullet:SetAngles( ang )
				bullet:SetPos( shootPos )
				bullet:Spawn()
				bullet:Activate() 
				
				bullet.l_Lambdified = true
            	bullet.l_UseLambdaDmgModifier = true
            	bullet.l_killiconname = mp1Data.StoredClass

				bullet.swep = nil
				bullet.swep_recovery_class = weapon.MP1Data.StoredTable
				bullet.wp_DoImpactEffect = mp1Data.DoImpactEffect
				bullet.wp_stored_class = mp1Data.StoredClass
				bullet.wp_stored = mp1Data.StoredTable
				bullet.wp = weapon
			end
		else
			fireBulletTbl.Attacker = lambda
			fireBulletTbl.IgnoreEntity = lambda
			fireBulletTbl.Damage = ( mp1Data.Damage * dmg_mul )
			fireBulletTbl.Force = ( mp1Data.Force or 1 )
			fireBulletTbl.Dir = aimVec:Forward()
			fireBulletTbl.Src = shootPos
			fireBulletTbl.Callback = function( attacker, tr, dmginfo )
				weapon:FireCallBack( attacker, tr, dmginfo )
			end

			for i = 1, numShots do 
				local newSpread = ( ( spread * 0.1 ) / ( random( 1, 100 ) > 75 and 1 or 3 ) )
				fireBulletTbl.Spread = Vector( newSpread, newSpread, 0 )
				weapon:FireBullets( fireBulletTbl )
			end
		end
	end

end