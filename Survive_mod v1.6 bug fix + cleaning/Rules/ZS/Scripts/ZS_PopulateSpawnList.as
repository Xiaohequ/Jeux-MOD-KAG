// get spawn points for ZS

#include "HallCommon.as"

shared void populateSpawnList( CBlob@[]@ respawns, const int teamNum )
{
    CBlob@[] posts;
    // getBlobsByTag( "player", @posts );
	CBlob@[] posts2;
	getBlobsByTag( "respawn", @posts );
    getBlobsByTag( "player", @posts2 );

    for (uint i=0; i < posts.length; i++)
    {
        CBlob@ blob = posts[i];

        if (blob.getTeamNum() == teamNum &&
            !isUnderRaid(blob))
		{
            respawns.push_back( blob );
        }
    }
	
	for (uint j=0; j < posts2.length; j++)
    {
        CBlob@ blob = posts2[j];
 
        if ((blob.getTeamNum() == teamNum) && !blob.isMyPlayer() && !blob.hasTag("dead"))
		{
            respawns.push_back( blob );
        }
    }
	

}
