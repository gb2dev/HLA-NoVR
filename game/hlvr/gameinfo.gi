"GameInfo"
{
	game 		"Half-Life: Alyx"
	title 		"Half-Life: Alyx"
	type		singleplayer_only
	nomodels 1
	nohimodel 1

	nodegraph 0
	tonemapping 1 // Show tonemapping ui in tools mode
	GameData	"hlvr.fgd"

	FileSystem
	{
		//
		// The code that loads this file automatically does a few things here:
		//
		// 1. For each "Game" search path, it adds a "GameBin" path, in <dir>\bin
		// 2. For each "Game" search path, it adds another "Game" path in front of it with _<langage> at the end.
		//    For example: c:\hl2\cstrike on a french machine would get a c:\hl2\cstrike_french path added to it.
		// 3. If no "Mod" key, for the first "Game" search path, it adds a search path called "MOD".
		// 4. If no "Write" key, for the first "Game" search path, it adds a search path called "DEFAULT_WRITE_PATH".
		//

		//
		// Search paths are relative to the exe directory\..\
		//
		SearchPaths
		{
			Game				novr_viewmodels
			Game				novr
			Game				hlvr
			Game				core
			Mod					hlvr
			Write				hlvr
			AddonRoot			hlvr_addons
		}
	}
	
	MaterialSystem2
	{
		RenderModes
		{
			"game" "Default"
			"game" "VrForward"
			"game" "Depth"
			"game" "Decals"
			"game" "Reflex"

			"dev" "ToolsShadingComplexity"
			"dev" "ToolsVis" // Visualization modes for all shaders (lighting only, normal maps only, etc.)
			"dev" "ToolsWireframe" // This should use the ToolsVis mode above instead of being its own mode
			"tools" "ToolsUtil" // Meant to be used to render tools sceneobjects that are mod-independent, like the origin grid
		}

		ToolsShadingComplexity
		{
			"TargetRenderMode" "VrForward"
		}

		ShaderIDColors
		{
			"generic.vfx" "255 0 255"

			"vr_simple.vfx" "0 255 0"
			"vr_bloody_simple.vfx" "64 255 0"
			"vr_simple_2way_blend.vfx" "186 255 0"
			"vr_simple_2layer_parallax.vfx" "255 186 0"
			"vr_simple_3layer_parallax.vfx" "255 64 0"
			"vr_simple_blend_to_triplanar.vfx" "255 186 128"
			"vr_simple_blend_to_xen_membrane.vfx" "255 128 186"
			"vr_basic.vfx" "255 255 255"
			
			"vr_complex.vfx" "128 0 186"
			"vr_glass.vfx" "0 255 255"
			"vr_shatterglass.vfx" "0 0 255"
		}
	}

	MaterialEditor
	{
		"DefaultShader" "vr_simple"
	}

	Source1Import
	{
		"importmod"			"ep2"
		"importdir"			"..\hlvr"
	}

	Engine2
	{
		"HasModAppSystems" "1"
		"Capable64Bit" "1"
		"URLName" "hlvr"
		"UsesPanorama" "1"
		"UsesBink" "0"
		"PanoramaUIClientFromClient" "1"
		"RenderingPipeline"
		{
			"SkipPostProcessing" "0"
			"PostProcessingInMainPipeline" "1"
			"TonemappingVRForward" "1"
			"Tonemapping_UseLogLuminance" "1"
			"ToolsVisModes" "1"
			"OpaqueFade" "1"
			"AmbientOcclusionProxies" "1"
			"RetinaBurnFx" "1"
			"HighPrecisionLighting" "1"
		}
		// Default MSAA sample count when run in non-VR mode
		"MSAADefaultNonVR"	"4"
		"SuppressNonConsoleVGuiInVR" "1"
	}

	SceneSystem
	{
		"SunLightMaxCascadeSize" "0"
		"SunLightMaxShadowBufferSize" "0"
		"SunLightMaxCascadeSizeTools" "2"
		"SunLightMaxShadowBufferSizeTools" "2048"
		"SunLightShadowRenderMode" "Depth"
		"VrLightBinner" "1"
		"VrLightBinnerMaxLights" "128" // must be the same as MAX_LIGHTS in vr_lighting.fxc
		"VrLightBinnerSingleLightFastPath" "1"
		"VrDefaultShadowTextureWidth" "4096"
		"VrDefaultShadowTextureHeight" "4096"
		"VrShadowDepthMasks" "1"
		"VrLightBinnerShadowViewsNeedPerViewLightingConstants" "1"
		"PointLightShadowsEnabled" "1"
		"Tonemapping"	"1"
		"VolumetricFog" "1"
		"NonTexturedGradientFog" "1"
		"CubemapFog" "1"
		"BloomEnabled" "1"
		"HDRFrameBuffer" "1"
		"DisableShadowFullSort" "1"
		"PerObjectLightingSetup" "1"
		"CharacterDecals" "1"
		"EnvironmentalInteraction" "1"
		"VrTeleportPathRendering" "1"
		"MaxAutoPartitions" "8"
		"TransformFormat" "TINTRGBA8_ENVMAPIDX"
	}

	ToolsEnvironment
	{
		"Engine"	"Source 2"
		"ToolsDir"	"../sdktools"	// NOTE: Default Tools path. This is relative to the mod path.
	}
	
	Hammer
	{
		"fgd"							"hlvr.fgd"	// NOTE: This is relative to the 'game' path.
		"GameFeatureSet"				"HalfLife"
		"DefaultTextureScale"			"0.250000"
		"DefaultSolidEntity"			"trigger_multiple"
		"DefaultPointEntity"			"info_player_start"
		"DefaultPathEntity"				"path_particle_rope"
		"NavMarkupEntity"				"func_hlvr_nav_markup"
		"OverlayBoxSize"				"8"
		"UsesBakedLighting"				"1"
		"TileMeshesEnabled"				"1"
		"DefaultMinDrawVolumeSize"		"128"
		"RenderMode"					"ToolsVis"
		"DefaultMinTrianglesPerCluster"	"2048"
		"CreateRenderClusters"			"1"
		"ShadowAtlasWidth"				"6144"
		"ShadowAtlasHeight"				"6144"
		"TimeSlicedShadowMapRendering"	"1"
		"SteamAudioEnabled"				"1"
		"Required3dSkyboxEntities"		"sky_camera"
		"ModelStateAutoConversionEntities"
		{
			"0"	"prop_ragdoll"
		}
		"AddonMapCommand"				"addon_tools_map"
		"AddonMapCommandIsAddonImplied"	"1"
	}
	
	ModelDoc
	{
		"models_gamedata"			"models_gamedata.fgd"
		"export_modeldoc"			"1"
		"features"					"animgraph;modelconfig"
	}
	
	PostProcessingEditor
	{
		"supports_vignette"			"0"
	}
	
	RenderPipelineAliases
	{
		"Tools"			"VR"
		"EnvMapBake"	"VR"
	}

	SoundTool
	{
		"DefaultSoundEventType" "hlvr_default_3d"
	}
	
	BugReporter
	{
		"AutoBugProduct" "Half-Life VR"
	}

	ResourceCompiler
	{
		// Overrides of the default builders as specified in code, this controls which map builder steps
		// will be run when resource compiler is run for a map without specifiying any specific map builder
		// steps. Additionally this controls which builders are displayed in the hammer build dialog.
		DefaultMapBuilders
		{
			"bakedlighting"	"1"	// Enable lightmapping during compile time
			"envmap"		"0"	// Using env_cubemap entities
			"nav"			"1"	// Generate nav mesh data
			"sareverb"      "1" // Bake Steam Audio reverb
			"sapaths"		"1" // Bake Steam Audio pathing info
		}
		
		TextureCompiler
		{
			MinRoughness			"0.01"	// Minimum roughness value for PBR
			MaxRoughnessAnisotropy	"8.0"	// Maximum roughness anisotropy for PBR
			CompressMipsOnDisk      "1"
			CompressMinRatio        "95"
		}

        MeshCompiler
        {
            PerDrawCullingData      "1"
            EncodeVertexBuffer      "1"
            EncodeIndexBuffer       "1"
        }

		WorldRendererBuilder
		{
			FixTJunctionEdgeCracks	"1"
			VisibilityGuidedMeshClustering      "1"
			MinimumTrianglesPerClusteredMesh    "2048"
			MinimumVerticesPerClusteredMesh     "2048"
			MinimumVolumePerClusteredMesh       "768"       // ~9x9x9 cube
			MaxPrecomputedVisClusterMembership  "48"
			MaxCullingBoundsGroups              "64"
		}

		PhysicsBuilder
		{
			DefaultHammerMeshSimplification	"0.1"
		}

		BakedLighting
		{
			Version 1
			IndexResolutionDivisor 4
			IndexCountMax 256
			LightmapChannels
			{
				direct_light_indices 1
				direct_light_strengths 1
				irradiance 1
				debug_chart_color 1
				directional_irradiance 1
				// data is in directional_irradiance
				//ao 1
			}
		}

		SteamAudio
		{
			Probes
			{
				GridSpacing			"3.0"
				HeightAboveFloor	"1.5"
			}
			Reverb
			{
				NumRays				"32768"
				NumBounces			"64"
				IRDuration			"1.0"
				AmbisonicsOrder		"1"
			}
			Pathing
			{
				NumVisSamples		"1"
				ProbeVisRadius		"3.0"
				ProbeVisThreshold	"0.01"
				ProbePathRange		"1000.0"
			}
		}

		VisBuilder
		{
			MaxVisClusters "2048"
		}
	}

	WorldRenderer
	{
		"IrradianceVolumes"		"0"
		"EnvironmentMaps"		"1"
		"EnvironmentMapFaceSize" "256"
		"EnvironmentMapRenderSize" "1024"
		"EnvironmentMapFormat" "BC6H"
		"EnvironmentMapColorSpace" "linear"
		"EnvironmentMapMipProcessor" "GGXCubeMapBlur"
		// Build cubemaps into a cube array instead of individual cubemaps.
		"EnvironmentMapUseCubeArray" "1"
	}

	NavSystem
	{
		"NavTileSize" "128.0"
		"NavCellSize" "1.5"
		"NavCellHeight" "2.0"

		"NavAgentNumHulls" "3"

		"NavAgentRadius_0" "12.0"
		"NavAgentHeight_0" "24.0"
		"NavAgentMaxClimb_0" "15.5"
		"NavAgentMaxSlope_0" "50"
		"NavAgentMaxJumpDownDist_0" "0.0"
		"NavAgentMaxJumpUpDist_0" "0.0"
		"NavAgentMaxJumpHorizDistBase_0" "64.0"

		"NavAgentRadius_1" "16.0"
		"NavAgentHeight_1" "79.0"
		"NavAgentMaxClimb_1" "15.5"
		"NavAgentMaxSlope_1" "50"
		"NavAgentMaxJumpDownDist_1" "0.0"
		"NavAgentMaxJumpUpDist_1" "0.0"
		"NavAgentMaxJumpHorizDistBase_1" "64.0"

		"NavAgentRadius_2" "23.0"
		"NavAgentHeight_2" "69.0"
		"NavAgentMaxClimb_2" "15.5"
		"NavAgentMaxSlope_2" "50"
		"NavAgentMaxJumpDownDist_2" "240.0"
		"NavAgentMaxJumpUpDist_2" "240.0"
		"NavAgentMaxJumpHorizDistBase_2" "64.0"

		"NavRegionMinSize" "8"
		"NavRegionMergeSize" "20"
		"NavEdgeMaxLen" "1200"
		"NavEdgeMaxError" "51.0"
		"NavVertsPerPoly" "4"
		"NavDetailSampleDistance" "120.0"
		"NavDetailSampleMaxError" "2.0"
		"NavSmallAreaOnEdgeRemovalSize" "-1.0"
	}

	RenderingBudget
	{
		"ArtistTrianglesRendered"	"1000000"
	}

	PhysicsBudget
	{
		"HullBudgetMin" "16"
		"HullBudgetMax" "64"
		"MeshBudgetMin" "64"
		"MeshBudgetMax" "512"
	}

	RenderSystem
	{
		"AllowSampleableDepthInVr" "1"
		"AllowPartialMipChainImmediateTexLoads" "1"
		"MaxPreloadTextureResolution" "256"
		"MinStreamingPoolSizeMB" "1536"
		"SetInitialStreamingPoolSizeFromBudget" "1"
		"VulkanUseStreamingTextureManager" "1"
		"VulkanMutableSwapchain" "1"
		"VulkanSteamShaderCache" "1"
		"VulkanSteamAppShaderCache" "1"
		"VulkanSteamDownloadedShaderCache" "0"
		"VulkanAdditionalShaderCache" "vulkan_shader_cache.foz"
		"VulkanStagingPMBSizeLimitMB" "128"
	}
	
	Particles
	{
		FeatureID						324234
		PET_AllowScreenSpaceOverlay		1
		PET_SupportFadingOpaqueModels	1
		Budget_SimulationUS				100
		Budget_RenderUS					100
		Budget_InterectionTests			20
		Budget_RealTraces				5
		Budget_EstimatedTraceCostUS		15
		Budget_OverallocationThreshold	2.5
	}

	AnimationSystem
	{
		NumDecodeCaches "16"
		DecodeCacheMemoryKB "512"
	}

	SoundSystem
	{
		"SteamAudioEnabled"            "1"
		Budget_StackSimulationUS		25
		Budget_FirstStackSimulationUS	50
	}

	GameInstructor
	{
		"SaveToSavegames"				"1"
	}

	Vr
	{
		"PreAllocateScratchRenderTargets"	"0"
		"FilterFidelityLevelsByGPUMemoryRatio"	"1"
		"MultiviewInstancing"				"1"
		"TickRateLockedToDisplayRate"		"1"
		"VrFidelityConfigName"				"hlvr"
	}
}


