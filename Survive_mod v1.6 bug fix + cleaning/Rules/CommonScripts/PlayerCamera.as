
// set camera on local player
// this just sets the target, specific camera vars are usually set in StandardControls.as

#define CLIENT_ONLY

#include "Spectator.as"

int deathTime = 0;
const float fixeCameraTime = 1.5f;
bool playerSet = false;
Vec2f deathLock;
bool switchedtospec = false;
bool spectatorhelp = true;
int helptime = 0;

void onRestart(CRules@ this)
{
	CCamera@ camera = getCamera();
	if(camera !is null)
	{
		camera.targetDistance = 1.0f;
		camera.setTarget(null);
	}

}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	CCamera@ camera = getCamera();
	if(camera !is null && player !is null && player is getLocalPlayer())
	{
		camera.setPosition(blob.getPosition());
		camera.setTarget(blob);
		camera.mousecamstyle = 1; // follow
	}
}

//change to spectator cam on team change
void onPlayerChangedTeam(CRules@ this, CPlayer@ player, u8 oldteam, u8 newteam)
{
	CCamera@ camera = getCamera();
	CBlob@ playerBlob = player is null ? player.getBlob() : null;

	if(camera !is null && newteam == this.getSpectatorTeamNum() && getLocalPlayer() is player)
	{
		camera.setTarget(null);
		switchedtospec = true;
		if(playerBlob !is null)
		{	
			playerBlob.ClearButtons();
			playerBlob.ClearMenus();

			camera.setPosition(playerBlob.getPosition());
			deathTime = getGameTime();

		}

	}

}

//Change to spectator cam on death
void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	CCamera@ camera = getCamera();
	CBlob@ victimBlob = victim !is null ? victim.getBlob() : null;
	CBlob@ attackerBlob = attacker !is null ? attacker.getBlob() : null;

	//Player died to someone
	if(camera !is null && victim is getLocalPlayer())
	{	
		//Player killed themselves
		if(victim is attacker || attacker is null)
		{
			camera.setTarget(null);
			if(victimBlob !is null)
			{
				victimBlob.ClearButtons();
				victimBlob.ClearMenus();

				camera.setPosition(victimBlob.getPosition());
				deathLock = victimBlob.getPosition();

			}

		}
		else
		{
			if(victimBlob !is null)
			{
				victimBlob.ClearButtons();
				victimBlob.ClearMenus();

			}

			if(attackerBlob !is null)	//set camera target = killer
			{
				camera.setPosition(attackerBlob.getPosition());
				deathLock = victimBlob.getPosition();
				camera.setTarget(attackerBlob);

			}
			else
			{
				camera.setTarget(null);

			}
			
		}
		deathTime = getGameTime() + fixeCameraTime*getTicksASecond();
	}

}

// death effect
void onTick(CRules@ this)
{
	CCamera@ camera = getCamera();
	CBlob@ playerBlob = getLocalPlayerBlob();

	if(camera !is null && playerBlob is null)
	{
		// death effect
		const int diffTime = deathTime - getGameTime();
		
		if(diffTime > 0) //in the dead time, camera zoom out 
		{
			camera.setPosition(deathLock);
			if(camera.targetDistance < 2.0f)
			{
				camera.targetDistance += 0.1f;
			}
		}
		else
		{
			//SPECTATOR
			if(spectatorhelp && helptime == 0 && switchedtospec)
			{
				helptime = getGameTime();
			}
			Spectator(this);
		}

	}

}

void onRender( CRules@ this )
{
	if(helptime == 0 || !spectatorhelp)
		return;

	int time = getGameTime();
	const int endTime1 = helptime + (getTicksASecond() * 12);
	const int endTime2 = helptime + (getTicksASecond() * 24);

	bool draw = false;
	Vec2f ul, lr;
	string text = "";

	if(getControls().isKeyPressed(KEY_F1))
	{
		spectatorhelp = false;

	}

	if (time < endTime1) {
		text = "You can use the movement keys to move the camera.";
		ul = Vec2f( getScreenWidth()/2 - 70, 3.5*getScreenHeight()/4 );
		Vec2f size;
		GUI::GetTextDimensions(text, size);
		lr = ul + size;
		draw = true;
	}
	else if (time < endTime2) {
		text =  "If you click on a player the camera will follow them.\nSimply press the movement keys to stop following a player.";
		ul = Vec2f( getScreenWidth()/2 - 70, 3.5*getScreenHeight()/4 );
		Vec2f size;
		GUI::GetTextDimensions(text, size);
		lr = ul + size;
		draw = true;
	}
	else
	{
		spectatorhelp = false;

	}

	if(draw)
	{
		f32 wave = Maths::Sin(getGameTime() / 10.0f) * 5.0f;
		ul.y += wave;
		lr.y += wave;
		GUI::DrawButtonPressed( ul - Vec2f(10,10), lr + Vec2f(10,10) );
		GUI::DrawText( text, ul, SColor(0xffffffff) );
	}
}