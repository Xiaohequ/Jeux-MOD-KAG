
#include "BuildBlock.as"
#include "CommonBuilderBlocks.as"

#include "WARCosts.as"
//should really make ctf costs at some point.. :)

void onSetPlayer( CRules@ this, CBlob@ blob, CPlayer@ player )
{
	if (blob !is null && player !is null && blob.getName() == "builder") 
	{
		BuildBlock[] blocks;
		
		addCommonBuilderBlocks( blocks );
		
		{   // workbench
			BuildBlock b( 0, "workbench", "$workbench$", "Workbench" );
			AddRequirement( b.reqs, "blob", "mat_wood", "Wood", 120 );
			b.buildOnGround = true;
			b.size.Set( 32,16 );
			blocks.push_back( b );
		}
		
		{   // building
			BuildBlock b( 0, "building", "$building$",
						"Workshop\nStand in an open space\nand tap this button." );
			AddRequirement( b.reqs, "blob", "mat_wood", "Wood", COST_WOOD_WORKSHOP );
			b.buildOnGround = true;
			b.size.Set( 40,24 );
			blocks.push_back( b );
		}
		
		blob.set( blocks_property, blocks );
	}
}
