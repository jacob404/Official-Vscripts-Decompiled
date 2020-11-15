//****************************************************************************************
//																						//
//									rd_damage_controll.nut								//
//																						//
//****************************************************************************************



// Fix grenade launcher applying damage to the player on multiple ticks 
// ----------------------------------------------------------------------------------------------------------------------------

lastDamageTimes <- {}

function AllowGrenadeLauncherDamage(player){
	
	if(!(player in lastDamageTimes)){
		lastDamageTimes[player] <- Time() - 1
	}
	
	if( Time() > lastDamageTimes[player] + 0.06 ){
			lastDamageTimes[player] <- Time()
			return true
	}else{
		lastDamageTimes[player] <- Time()
		return false
	}
}




// When to allow damage
// ----------------------------------------------------------------------------------------------------------------------------

function AllowTakeDamage(damageTable){
	local damageType = damageTable["DamageType"]
	local attacker = damageTable["Attacker"]
	local victim = damageTable["Victim"]
	local damageDone = damageTable["DamageDone"]

	// TANK ROCK
	if(damageTable.Victim.GetClassname() == "tank_rock"){
		if(attacker != null && attacker.IsPlayer() && attacker.GetZombieType() == 9){
			
			victim.ValidateScriptScope()
			if(!("dealtDamage" in victim.GetScriptScope())){
				victim.GetScriptScope()["dealtDamage"] <- damageDone
			}else{
				victim.GetScriptScope()["dealtDamage"] += damageDone
			}
			if(victim.GetScriptScope()["dealtDamage"] >= 50){
				victim.GetScriptScope()["dealtDamage"] <- -500
				if(attacker.IsIncapacitated()){
					if(!missionFailed){
						if(last_chance_active){
							stopLastChanceMode()
							attacker.ReviveFromIncap()
						}else{
							if(!allSurvivorsIncap()){
								attacker.ReviveFromIncap()
							}else{
								ClientPrint(null, 5, BLUE + "Time to say goodbye")
							}
						}
						EmitAmbientSoundOn("player/orch_hit_csharp_short", 1, 100, 100, attacker);	
					}
				}else{
					if((attacker.GetHealth() + 5) <= 200){
							attacker.SetHealth(attacker.GetHealth() + 5)
					}else{
						attacker.SetHealth(200)
					}
					attacker.UseAdrenaline(1)
				}
			}
		}
	return true
	}


	// DISABLE FALL DAMAGE
	if(damageType == 32){
		return false
	}
	
	// DISABLE FF
	if(attacker.IsPlayer() && victim.IsPlayer())
	{
		if(attacker.GetZombieType() == 9 && victim.GetZombieType() == 9)
		{
			if(IsPlayerABot(attacker)){ return false }
			
			if(damageTable.Weapon == null)
			{
				if(!AllowGrenadeLauncherDamage(victim))
				{
					return false
				}
				else
				{
					damageTable.DamageDone = 1
					return true
				}
			}
		}
	}
	return true
}
