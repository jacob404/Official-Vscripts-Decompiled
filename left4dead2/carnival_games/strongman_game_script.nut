// initialize
FlashDelay <- 0


function PickRandomTierOneCase()
{
	local animcase = RandomInt( 1, 3 )
	
	switch( animcase )
	{
		case 1:
			EntFire( EntityGroup[0].GetName(), "setanimation", "1" )
			break
		
		case 2:
			EntFire( EntityGroup[0].GetName(), "setanimation", "2" )
			break
			
		case 3:
			EntFire( EntityGroup[0].GetName(), "setanimation", "3" )
			break
		
		default:
			break
	}
}



function PickRandomTierTwoCase()
{
	local animcase = RandomInt( 4, 5 )
	
	switch(animcase)
	{
		case 4:
			EntFire( EntityGroup[0].GetName(), "setanimation", "4" )
			break
		
		case 5:
			EntFire( EntityGroup[0].GetName(), "setanimation", "5" )
			break

		default:
			return
	}
}

function PickRandomTierThreeCase()
{
	local animcase = RandomInt( 6, 7 )
	
	switch(animcase)
	{
		case 6:
			EntFire( EntityGroup[0].GetName(), "setanimation", "6" )
			break
			
		case 7:
			EntFire( EntityGroup[0].GetName(), "setanimation", "7" )
			break
		

		default:
			return
	}
} 

function PickRandomTierFourCase()
{
	local animcase = RandomInt( 8, 9 )
	
	switch(animcase)
	{
		
		case 8:
			EntFire( EntityGroup[0].GetName(), "setanimation", "8" )
			break
		
		case 9:
			EntFire( EntityGroup[0].GetName(), "setanimation", "9" )
			break
			
		
		default:
			return
	}
}



function TierOneLightFlash( FlashDelay )
{
	EntFire( EntityGroup[1].GetName(), "Skin", "0", FlashDelay + 0.0 )

	
	EntFire( EntityGroup[1].GetName(), "Skin", "1", FlashDelay + 0.20 )
	EntFire( EntityGroup[1].GetName(), "Skin", "3", FlashDelay + 0.40 )
	
	EntFire( EntityGroup[2].GetName(), "ShowSprite", 0, FlashDelay + 0.0 )
	EntFire( EntityGroup[2].GetName(), "HideSprite", 0, FlashDelay + 0.2 )
}

function TierTwoLightFlash( FlashDelay )
{
	EntFire( EntityGroup[3].GetName(), "Skin", "0", FlashDelay + 0.0 )

	
	EntFire( EntityGroup[3].GetName(), "Skin", "1", FlashDelay + 0.20 )
	EntFire( EntityGroup[3].GetName(), "Skin", "3", FlashDelay + 0.40 )
	
	EntFire( EntityGroup[4].GetName(), "ShowSprite", 0, FlashDelay + 0.0 )
	EntFire( EntityGroup[4].GetName(), "HideSprite", 0, FlashDelay + 0.2 )
}

function TierThreeLightFlash( FlashDelay )
{
	EntFire( EntityGroup[5].GetName(), "Skin", "0", FlashDelay + 0.0 )

	
	EntFire( EntityGroup[5].GetName(), "Skin", "1", FlashDelay + 0.20 )
	EntFire( EntityGroup[5].GetName(), "Skin", "3", FlashDelay + 0.40 )
	
	EntFire( EntityGroup[6].GetName(), "ShowSprite", 0, FlashDelay + 0.0 )
	EntFire( EntityGroup[6].GetName(), "HideSprite", 0, FlashDelay + 0.2 )
}

function TierFourLightFlash( FlashDelay )
{
	EntFire( EntityGroup[7].GetName(), "Skin", "0", FlashDelay + 0.0 )

	
	EntFire( EntityGroup[7].GetName(), "Skin", "1", FlashDelay + 0.20 )
	EntFire( EntityGroup[7].GetName(), "Skin", "3", FlashDelay + 0.40 )
	
	EntFire( EntityGroup[8].GetName(), "ShowSprite", 0, FlashDelay + 0.0 )
	EntFire( EntityGroup[8].GetName(), "HideSprite", 0, FlashDelay + 0.2 )
}

function TierTopLightFlash( FlashDelay )
{
	EntFire( EntityGroup[9].GetName(), "Skin", "0", FlashDelay + 0.0 )

	
	EntFire( EntityGroup[9].GetName(), "Skin", "1", FlashDelay + 0.20 )
	EntFire( EntityGroup[9].GetName(), "Skin", "3", FlashDelay + 0.40 )
	
	EntFire( EntityGroup[10].GetName(), "ShowSprite", 0, FlashDelay + 0.0 )
	EntFire( EntityGroup[10].GetName(), "HideSprite", 0, FlashDelay + 0.2 )
}


function FlashAllTierLights( FlashDelay )
{
	TierOneLightFlash( FlashDelay )
	TierTwoLightFlash( FlashDelay ) 
	TierThreeLightFlash( FlashDelay )
	TierFourLightFlash( FlashDelay )
	TierTopLightFlash( FlashDelay )
}

function RepeatFlashAllTierLights()
{
	FlashAllTierLights(0.0)
	FlashAllTierLights(0.5)
	FlashAllTierLights(1.0)
	FlashAllTierLights(1.5)
	FlashAllTierLights(2.0)
	FlashAllTierLights(2.5)
	FlashAllTierLights(3.0)
}

function AttractModeTierLights()
{
	TierOneLightFlash(0.0)
	TierTwoLightFlash(0.5)
	TierThreeLightFlash(1.0)
	TierFourLightFlash(1.5)
	
	TierThreeLightFlash(2.0)
	TierTwoLightFlash(2.5)
	TierOneLightFlash(3.0)
	
	FlashAllTierLights(3.5)
	FlashAllTierLights(4.5)
	FlashAllTierLights(5.5)
	FlashAllTierLights(6.5)
}

