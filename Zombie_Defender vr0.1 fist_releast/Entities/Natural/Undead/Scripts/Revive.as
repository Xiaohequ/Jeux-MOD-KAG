void onInit(CBlob@ this)
{
	this.getCurrentScript().runFlags = Script::tick_not_attached;
}
void onTick(CBlob@ this)
{
	if (this.getHealth()<=0.0 && (this.getTickSinceCreated() - this.get_u16("death ticks")) > 300)
	{
		this.server_SetHealth(0.5);
		this.getShape().setFriction( 0.75f );
		this.getShape().setElasticity( 0.2f );
	}
}