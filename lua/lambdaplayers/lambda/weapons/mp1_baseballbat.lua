local Vector = Vector
local util_Decal = util.Decal
local isstring = isstring
local EffectData = EffectData
local util_Effect = util.Effect
local IsValid = IsValid
local CurTime = CurTime
local random = math.random
local DamageInfo = DamageInfo
local ParticleEffect = ParticleEffect
local ConVarNumber = cvars.Number
local bit_bor = bit.bor
local TraceLine = util.TraceLine
local TraceHull = util.TraceHull
local meleeTrTbl = {
    filter = { NULL, NULL },
    mins = Vector( -16, -16, -8 ),
    maxs = Vector( 16, 16, 8 ),
    mask = MASK_SHOT_HULL
}

local mat_types = {
    [ MAT_DEFAULT ] =      { sound = "MP1.BaseballDefaultHit", decal = "mp1_meleeimpact", particle = "mp1_melee_impact" },
    [ MAT_WOOD ] =         { sound = "MP1.BaseballWoodHit", decal = "mp1_meleeimpact", particle = "mp1_melee_impact" },
    [ MAT_METAL ] =        { sound = "MP1.BaseballMetalHit", decal = "mp1_meleeimpact", particle = "mp1_melee_impact" },
    [ MAT_VENT ] =         { sound = "MP1.BaseballMetalSolidHit", decal = "mp1_meleeimpact", particle = "mp1_melee_impact" },
    [ MAT_GLASS ] =        { sound = "MP1.BaseballGlassHit", decal = "mp1_meleeimpact_glass", particle = "mp1_melee_impact" },

    [ MAT_FLESH ] =        { sound = "MP1.MeleeHit", decal = "Impact.Flesh", effect = "BloodImpact" },
    [ MAT_BLOODYFLESH ] =  { sound = "MP1.MeleeHit", decal = "Impact.Flesh", effect = "BloodImpact" },
    [ MAT_ANTLION ] =      { sound = "MP1.MeleeHit", decal = "Impact.Antlion", effect = "BloodImpact" },
    [ MAT_ALIENFLESH ] =   { sound = "MP1.MeleeHit", decal = "Impact.Antlion", effect = "BloodImpact" },
    [ MAT_EGGSHELL ] =     { sound = "MP1.MeleeHit", decal = "Impact.Antlion", effect = "BloodImpact" }
}

local function getMatTypeTemplates( mat_type ) 
    local tab = ( mat_types[ mat_type ] or mat_types[ MAT_DEFAULT ] )
    return { sound = tab.sound, decal = tab.decal, effect = tab.effect }
end

local function BaseballBatAttack( self, wepent, dir, right )
    meleeTrTbl.start = wepent:GetPos()
    meleeTrTbl.endpos = meleeTrTbl.start + dir:Forward() * 96
    meleeTrTbl.filter[1] = self
    meleeTrTbl.filter[2] = wepent

    local tr = TraceLine( meleeTrTbl )

    local first_trace_hitpos = tr.HitPos
    local first_trace_normal = tr.HitNormal
    local first_trace_mattype = tr.MatType

    if !IsValid( tr.Entity ) then tr = TraceHull( meleeTrTbl ) end

    if tr.Hit then
        local effect_tab = getMatTypeTemplates( tr.MatType )
        wepent:EmitSound( effect_tab.sound )
        
        local hitEnt = tr.Entity
        if IsValid( hitEnt ) then
            util_Decal( effect_tab.decal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal, self )

            local particle = effect_tab.particle
            if particle then
                ParticleEffect( particle, ( tr.HitPos + tr.HitNormal ), tr.HitNormal:Angle() )
            elseif isstring( effect_tab.effect ) then 
                local effectData = EffectData()
                effectData:SetOrigin( first_trace_hitpos )
                effectData:SetNormal( tr.HitNormal )
                effectData:SetEntity( hitEnt )
                util_Effect( effect_tab.effect, effectData, true, true )
            end

            local dmginfo = DamageInfo()
            dmginfo:SetDamage( 15 * ConVarNumber("mp1_damage_mul") )
            dmginfo:SetAttacker( self )
            dmginfo:SetInflictor( wepent )
            dmginfo:SetDamagePosition( tr.HitPos )
            dmginfo:SetDamageForce( dir:Forward() * 8000 + dir:Right() * ( 4000 * ( right and 1 or -1 ) ) )

            dmginfo:SetDamageType( DMG_CLUB )
            if hitEnt:IsNPC() and hitEnt:GetClass() == "npc_manhack" then dmginfo:SetDamageType( bit_bor( DMG_CLUB, DMG_BLAST ) ) end

            hitEnt:DispatchTraceAttack( dmginfo, tr )
        else
            util_Decal( effect_tab.decal, first_trace_hitpos + first_trace_normal, first_trace_hitpos - first_trace_normal, self )
            
            local particle = effect_tab.particle
            if particle then
                ParticleEffect( particle, first_trace_hitpos + first_trace_normal, tr.HitNormal:Angle() )
            elseif isstring( effect_tab.effect ) then 
                local effectData = EffectData()
                effectData:SetOrigin( tr.HitPos )
                effectData:SetNormal( first_trace_normal )
                util_Effect( effect_tab.effect, effectData, true, true )
            end
        end
    end

    wepent:EmitSound( "MP1.BaseballBatFire" )
end

table.Merge( _LAMBDAPLAYERSWEAPONS, {
    mp1_baseballbat = {
        model = "models/mp1/Weapons/w_baseballbat.mdl",
        origin = "Max Payne 1",
        prettyname = "Baseball Bat",
        holdtype = "melee2",
        killicon = "weapon_mp1_baseballbat",
        ismelee = true,
        bonemerge = true,
        islethal = true,
        dropentity = "ent_mp1_baseballbat",

        keepdistance = 10,
        attackrange = 100,

        OnAttack = function( self, wepent, target )            
            self.l_WeaponUseCooldown = CurTime() + 0.86

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )

            self:SimpleWeaponTimer( 0.645, function()
                local attackDir = self:GetAngles()
                if LambdaIsValid( target ) then
                    local wepPos = wepent:GetPos()
                    local targetPos = target:WorldSpaceCenter()
                    attackDir = ( targetPos - wepPos ):Angle()
                    attackDir = ( ( targetPos + attackDir:Up() * random( -32, 32 ) + attackDir:Right() * random( -16, 16 ) ) - wepPos ):Angle()
                end

                BaseballBatAttack( self, wepent, attackDir, true )

                self:SimpleWeaponTimer( 0.43, function()
                    self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )
                    self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2 )

                    attackDir = self:GetAngles()
                    if LambdaIsValid( target ) then
                        local wepPos = wepent:GetPos()
                        local targetPos = target:WorldSpaceCenter()
                        attackDir = ( targetPos - wepPos ):Angle()
                        attackDir = ( ( targetPos + attackDir:Up() * random( -32, 32 ) + attackDir:Right() * random( -16, 16 ) ) - wepPos ):Angle()
                    end

                    BaseballBatAttack( self, wepent, attackDir, false )
                end )
            end )

            return true
        end
    }
} )