// generates from a KAGGen config
// fileName is "" on client!
#include "ModName.as";
#include "ZS_Technology.as";  

bool loadMap( CMap@ _map, const string& in filename)
{
	printf("generate map with: "+ getFilenameWithoutPath(getCurrentScriptName()) );
	CMap@ map = _map;
	SetupScrolls(getRules());	
	if (!getNet().isServer() || filename == "")
	{
		SetupMap(map,0,0);
		SetupBackgrounds(map);
		return true;
	}

    string configstr = "../Mods/" + mod_name + "/Rules/" + sv_gamemode + "/config.cfg";
	ConfigFile gamecfg = ConfigFile( configstr );
	bool techstuff_spawn = gamecfg.read_bool("techstuff_spawn",false);
	warn("Tech Stuff spawning: "+techstuff_spawn);
	bool scrolls_spawn = gamecfg.read_bool("scrolls_spawn",false);
	warn("Scrolls spawning: "+scrolls_spawn);
	Random@ map_random = Random(map.getMapSeed());
	
	Noise@ map_noise = Noise(map_random.Next());
	
	Noise@ material_noise = Noise(map_random.Next());
	
	//read in our config stuff -----------------------------
	
	ConfigFile cfg = ConfigFile( filename );
	
	//boring vars
	s32 width = cfg.read_s32("m_width",m_width);
	s32 height = cfg.read_s32("m_height",m_height);
	
	s32 baseline = cfg.read_s32("baseline",50);
	s32 baseline_tiles = height * (1.0f - (baseline/100.0f));
	
	s32 deviation = cfg.read_s32("deviation",20);
	
	//margin for teams
	s32 map_margin = cfg.read_s32("map_margin",30);
	s32 lerp_distance = cfg.read_s32("lerp_distance",30);
	
	//erosion
	s32 erode_cycles = cfg.read_s32("erode_cycles",10);
	
	//purturbation vars
	f32 purturb = cfg.read_f32("purturb", 5.0f);
	f32 purt_scale = cfg.read_f32("purt_scale", 0.0075);
	f32 purt_width = cfg.read_f32("purt_width", deviation);
	if(purt_width <= 0)
		purt_width = deviation;
	
	//cave vars
	Random@ cave_random = Random(map.getMapSeed() ^ 0xff00);
	Noise@ cave_noise = Noise(cave_random.Next());
	
	f32 cave_amount = cfg.read_f32("cave_amount", 0.2f);
	f32 cave_amount_var = cfg.read_f32("cave_amount_var", 0.1f);
	if(cave_amount > 0)
		cave_amount = Maths::Min(1.0f,Maths::Max(0.0f,cave_amount + cave_amount_var * (cave_random.NextFloat() - 0.5f)));
	
	f32 cave_scale = cfg.read_f32("cave_scale", 5.0f);
		cave_scale = 1.0f / Maths::Max(cave_scale,0.001);
		
	f32 cave_detail_amp = cfg.read_f32("cave_detail_amp", 0.5f);
	f32 cave_distort = cfg.read_f32("cave_distort", 2.0f);
	f32 cave_width = cfg.read_f32("cave_width", 0.5f);
	f32 cave_lerp = cfg.read_f32("cave_lerp", 10.0f);
	if(cave_width <= 0)
		cave_width = 0;
	
	f32 cave_depth = cfg.read_f32("cave_depth", 20.0f);
	f32 cave_depth_var = cfg.read_f32("cave_depth_var", 10.0f);
	cave_depth += cave_depth_var * (cave_random.NextFloat() - 0.5f);
	
	cave_width *= width; //convert from ratio to tiles
	
	//ruins vars
	
	Random@ ruins_random = Random(map.getMapSeed() ^ 0x8ff000);
	
	s32 ruins_count = cfg.read_f32("ruins_count", 3);
	s32 ruins_count_var = cfg.read_f32("ruins_count_var", 2);
	s32 ruins_size = cfg.read_f32("ruins_size", 10);
	f32 ruins_width = cfg.read_f32("ruins_width", 0.5f);
	
	if(ruins_count > 0)
	{
		// do variation
		ruins_count += ruins_random.NextRanged(ruins_count_var+1) - ruins_count_var/2;
		//convert from ratio to tiles
		ruins_width *= width;
	}
	
	//done with vars! --------------------------------
	
	SetupMap(map, width, height);
	
	//gen heightmap
	array<int> heightmap(width);
	for(int x = 0; x < width; ++x)
	{
		heightmap[x] = baseline_tiles - deviation/2 +
						(map_noise.Fractal((x + 100)*0.05, 0) * deviation);
	}
	
	//erode gradient
	
	for(int erode_cycle = 0; erode_cycle < erode_cycles; ++erode_cycle) //cycles
	{
		for(int x = 1; x < width-1; x++)
		{
			s32 diffleft = heightmap[x] - heightmap[x-1];
			s32 diffright = heightmap[x] - heightmap[x+1];
			
			if(diffleft > 0 && x > map_margin && diffleft > diffright)
			{
				heightmap[x] -= (diffleft+1) / 2;
				heightmap[x-1] += diffleft / 2;
			}
			else if(diffright > 0 && width-x > map_margin && diffright > diffleft)
			{
				heightmap[x] -= (diffright+1) / 2;
				heightmap[x+1] += diffright / 2;
			}
			else if(diffleft == diffright && diffleft > 0)
			{
				heightmap[x] -= (diffright+1) / 2;
				heightmap[x-1] += (diffleft+3) / 4;
				heightmap[x+1] += (diffleft+3) / 4;
			}
		}
	}
	
	
	//map margin
	
	for(int x = 0; x < map_margin + lerp_distance; ++x)
	{
		if(x < map_margin)
		{
			heightmap[x] = baseline_tiles;
			heightmap[width-1-x] = baseline_tiles;
		}
		else
		{
			f32 lerp = Maths::Min(1.0f, (x - map_margin) / f32(lerp_distance));
			heightmap[x] = baseline_tiles * (1.0f-lerp) + heightmap[x] * lerp;
			heightmap[width-1-x] = baseline_tiles * (1.0f-lerp) + heightmap[width-1-x] * lerp;
			
		}
	}
	
	//gen terrain
	s32 bush_skip = 0;
	s32 tree_skip = 0;
	const s32 tree_limit = 6;
	const s32 bush_limit = 10;
	
	array<int> naturemap(width);
	for(int x = 0; x < width; ++x)
	{
		naturemap[x] = -1; //no nature
	}
	//gen cave
	for(int x = 0; x < width; ++x)
	{
		f32 overhang = 0;
		for(int y = 0; y < height; y++)
		{
			u32 offset = x + y*width;
			
			if(y <= height -5)
			{
				f32 midline_dist = y - heightmap[x];
				
				f32 midline_frac = (midline_dist + deviation/2) / (deviation + 0.01f);
				
				f32 edge_dist = Maths::Max(Maths::Min(x - map_margin, width - x - map_margin), 0);
				f32 lerp = Maths::Min(1.0f, edge_dist / f32(lerp_distance));
				
				f32 amp = Maths::Max(0.0f, purturb * Maths::Min(1.0f, 1.0f - Maths::Abs(midline_dist) / (purt_width/2 + 0.01f)) * lerp);
				f32 _n = map_noise.Fractal(x*purt_scale,y*purt_scale);
				
				f32 n = midline_frac * ( 1.0f + (_n - 0.5f) * amp);
				
				if(n > 0.6f)
				{
					bool add_dirt = true;
					
					const f32 bedrock_thresh = 4.5f;
					
					const f32 material_frac = (material_noise.Fractal(x*0.1f,y*0.1f) - 0.5f) * 2.0f;
					
					const f32 n_plus = n + (material_frac * 0.4f);
					
					f32 cave_n = 0.0f;
					if(cave_amount > 0.0f) //any chance of caves
					{
						const f32 cave_dist = Maths::Max(Maths::Abs(x - width*0.5f) - cave_width*0.5f + cave_lerp, 0.0f);
						const f32 cave_mul = 1.0f - (cave_dist / cave_lerp);
						
						if(cave_mul > 0.0f) //don't bother sampling if theres no cave
						{
							
							f32 target = heightmap[x] + (cave_depth * cave_mul);
							
							f32 mul = 0.15f + //- (Maths::Abs(y - target) / 10.0f) +
										(cave_noise.Sample(x*0.1f + 31.0f, y*0.1f + 10.0f) - 0.5f) * cave_distort * cave_mul;
							
							cave_n = (cave_noise.Fractal(x*cave_scale + 132.0f, y*cave_scale*0.1f + 993.0f) * cave_amount - 
									  (cave_noise.Fractal(x*0.1f + 31.0f, y*0.1f + 10.0f) - 0.5f) * cave_detail_amp * 2.0f
									  + mul
									 ) * 0.5f;
						}
					}
					
					if(cave_n > 1.0f - cave_amount)
					{
						map.SetTile(offset, CMap::tile_ground_back );
						add_dirt = false;
						
						overhang -= _n * 2.0f + 0.5f;
						continue;
					}
					else if((n > 0.55f && n_plus < bedrock_thresh - 0.2f) || n > bedrock_thresh)
					{
						add_dirt = false;
						
						if(material_frac < 0.7f && n > bedrock_thresh)
						{
							map.SetTile(offset, CMap::tile_bedrock );
						}
						else if(lerp > 0.5f &&
								material_frac > -0.5f && material_frac < -0.35f &&
								n_plus < 0.8f)
						{
							map.SetTile(offset, CMap::tile_gold );
						}
						else if(material_frac > 0.4f && n > 0.9f)
						{
							map.SetTile(offset, CMap::tile_thickstone );
						}
						else if(material_frac > 0.1f && n_plus > 0.8f)
						{
							map.SetTile(offset, CMap::tile_stone );
						}
						else
						{
							add_dirt = true;
						}
					}
					
					if(add_dirt)
					{
						map.SetTile(offset, CMap::tile_ground );
						if(overhang == 0 && y > 1)
						{
							naturemap[x] = y;
						}
					}
					
					overhang = 10.0f;
				}
				else if(overhang > 0.3f)
				{
					overhang -= _n * 2.0f + 0.5f;
					map.SetTile(offset, CMap::tile_ground_back );
				}
			}
			else
			{
				map.SetTile(offset, CMap::tile_bedrock );
			}
		}
	}
	
	//generate vegetation
	for(int x = 0; x < width; ++x)
	{
		if(naturemap[x] == -1)
			continue;
		
		int y = naturemap[x];
		
		f32 edge_dist = Maths::Max(Maths::Min(x - map_margin, width - x - map_margin), 0);
		f32 lerp = Maths::Min(1.0f, edge_dist / f32(lerp_distance));
		
		u32 offset = x + y*width;
		
		bool force_tree = (x == map_margin - 2 || width-x == map_margin - 2); // least 2 trees
						
		f32 grass_frac = material_noise.Fractal(x*0.02f,y*0.02f) + ((1.0f-lerp) * 0.5f);
		

		// if(force_tree || grass_frac > 0.5f)
		// {
			map.SetTile(offset - width, CMap::tile_grass + map_random.NextRanged(4) ); //todo grass random
		
			if( force_tree ||
				( x > map_margin && width-x > map_margin) && (x % 3 == 0 || x % 11 == 0) )
			{
				f32 _g = map_random.NextFloat();
				
				Vec2f pos = (Vec2f(x,y-1)*map.tilesize) +
							Vec2f(4.0f, 4.0f);
				
				if( tree_skip < tree_limit &&
					(!force_tree && _g > 0.5f || bush_skip > bush_limit) ) //bush
				{
					bush_skip = 0;
					server_CreateBlob( "bush", -1, pos );
					tree_skip++;
				}
				else if ( tree_skip >= tree_limit || force_tree || _g > 0.25f) //tree
				{
					tree_skip = 0;
					//CBlob@ tree = server_CreateBlobNoInit( y < baseline_tiles ? "tree_pine" : "tree_bushy" );
					CBlob@ tree = server_CreateBlobNoInit( map_random.NextFloat()>0.5f ? "tree_pine" : "tree_bushy" );
					if (tree !is null)
					{
						tree.Tag("startbig");
						tree.setPosition( pos );
						tree.Init();
						
						if (map.getTile(offset).type == CMap::tile_empty)
							map.SetTile(offset, CMap::tile_grass + map_random.NextRanged(3) );
					}
					bush_skip++;
				}
			}
		// }
	}
	
	SetupBackgrounds(map);
	return true;
}


void SetupMap(CMap@ map, int width, int height )
{
	map.CreateTileMap( width, height, 8.0f, "Sprites/world.png" );
}

void SetupBackgrounds(CMap@ map)
{
	// sky

	map.CreateSky( color_black, Vec2f(1.0f,1.0f), 200, "Sprites/Back/cloud", 0);
	map.CreateSkyGradient( "Sprites/skygradient.png" ); // override sky color with gradient

	// plains

	map.AddBackground( "Sprites/Back/BackgroundPlains.png", Vec2f(0.0f, 0.0f), Vec2f(0.3f, 0.3f), color_white ); 
	map.AddBackground( "Sprites/Back/BackgroundTrees.png", Vec2f(0.0f,  19.0f), Vec2f(0.4f, 0.4f), color_white ); 
	//map.AddBackground( "Sprites/Back/BackgroundIsland.png", Vec2f(0.0f, 50.0f), Vec2f(0.5f, 0.5f), color_white ); 
	map.AddBackground( "Sprites/Back/BackgroundCastle.png", Vec2f(0.0f, 50.0f), Vec2f(0.6f, 0.6f), color_white ); 

	// fade in 				   
	SetScreenFlash( 255, 0, 0, 0 );

	SetupBlocks(map);
}

void SetupBlocks(CMap@ map)
{
	
}

bool LoadMap( CMap@ map, const string& in fileName )
{
    print("GENERATING KAGGen MAP " + getFilenameWithoutPath(fileName));
   	
    return loadMap(map, fileName);
}
