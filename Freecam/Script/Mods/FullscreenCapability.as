import Mods.ModVariables;

class UFullscreenCapability : UHazeCapability 
{
	default CapabilityTags.Add(CapabilityTags::Camera);

	AHazePlayerCharacter Player;
	//AHazeCameraActor Camera;

	bool isCamActive = false;

	UFUNCTION(BlueprintOverride)
	void Setup(FCapabilitySetupParams SetupParams)
	{
		Player = Cast<AHazePlayerCharacter>(Owner);
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkActivation ShouldActivate() const
	{
		if(!HasControl())
			return EHazeNetworkActivation::DontActivate;

		if (CVar_FullscreenEnabled.GetInt() == 0)
			return EHazeNetworkActivation::DontActivate;	

        return EHazeNetworkActivation::ActivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	void OnActivated(FCapabilityActivationParams ActivationParams)
	{
		if(HasControl())
			ActivateFullscreen();
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkDeactivation ShouldDeactivate() const
	{
		if (CVar_FullscreenEnabled.GetInt() == 0)
			return EHazeNetworkDeactivation::DeactivateLocal;	

		return EHazeNetworkDeactivation::DontDeactivate;
	}

	UFUNCTION(BlueprintOverride)
	void OnDeactivated(FCapabilityDeactivationParams DeactivationParams)
	{
		if(HasControl())
			DeactivateFullscreen();
	}

	void ActivateFullscreen()
	{
		isCamActive = true;
		Player.OtherPlayer.DisableOutlineByInstigator(this);
		Player.BlockCapabilities(n"PlayerMarker", this);
	}

	void DeactivateFullscreen()
	{
		isCamActive = false;
		Player.ClearViewSizeOverride(this);
		Player.OtherPlayer.EnableOutlineByInstigator(this);
		Player.UnblockCapabilities(n"PlayerMarker", this);
	}

	UFUNCTION(BlueprintOverride)
	void TickActive(float DeltaTime)
	{
		if (isCamActive)
			Player.ApplyViewSizeOverride(this, EHazeViewPointSize::Fullscreen, EHazeViewPointBlendSpeed::Instant, Priority = EHazeViewPointPriority::Override);
	}
}

class UOtherPlayerFullscreenCapability : UHazeCapability 
{
	default CapabilityTags.Add(CapabilityTags::Camera);

	AHazePlayerCharacter Player;
	AHazePlayerCharacter Cody;
	AHazePlayerCharacter May;

	bool isCamActive = false;

	UFUNCTION(BlueprintOverride)
	void Setup(FCapabilitySetupParams SetupParams)
	{
		Player = Cast<AHazePlayerCharacter>(Owner);
		Cody = Game::Cody;
		May = Game::May;
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkActivation ShouldActivate() const
	{
		if(!HasControl())
			return EHazeNetworkActivation::DontActivate;

		if (CVar_OtherPlayerFullscreenEnabled.GetInt() == 0)
			return EHazeNetworkActivation::DontActivate;	

        return EHazeNetworkActivation::ActivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	void OnActivated(FCapabilityActivationParams ActivationParams)
	{
		if(HasControl())
			ActivateFullscreen();
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkDeactivation ShouldDeactivate() const
	{
		if (CVar_OtherPlayerFullscreenEnabled.GetInt() == 0)
			return EHazeNetworkDeactivation::DeactivateLocal;	

		return EHazeNetworkDeactivation::DontDeactivate;
	}

	UFUNCTION(BlueprintOverride)
	void OnDeactivated(FCapabilityDeactivationParams DeactivationParams)
	{
		if(HasControl())
			DeactivateFullscreen();
	}

	void ActivateFullscreen()
	{
		isCamActive = true;
		Player.DisableOutlineByInstigator(this);
		Player.OtherPlayer.BlockCapabilities(n"PlayerMarker", this);
	}

	void DeactivateFullscreen()
	{
		isCamActive = false;
		Player.OtherPlayer.ClearViewSizeOverride(this);
		Player.ClearViewSizeOverride(this);
		Player.EnableOutlineByInstigator(this);
		Player.OtherPlayer.UnblockCapabilities(n"PlayerMarker", this);
	}

	UFUNCTION(BlueprintOverride)
	void TickActive(float DeltaTime)
	{
		if (isCamActive)
		{
			auto Lobby = Lobby::GetLobby();
			if (Lobby.LobbyOwner.IsLocal())
			{
				Cody.ApplyViewSizeOverride(this, EHazeViewPointSize::Fullscreen, EHazeViewPointBlendSpeed::Instant, Priority = EHazeViewPointPriority::Override);
				May.ApplyViewSizeOverride(this, EHazeViewPointSize::Hide, EHazeViewPointBlendSpeed::Instant, Priority = EHazeViewPointPriority::Override);
			}
			else
			{
				Player.OtherPlayer.ApplyViewSizeOverride(this, EHazeViewPointSize::Fullscreen, EHazeViewPointBlendSpeed::Instant, Priority = EHazeViewPointPriority::Override);
				Player.ApplyViewSizeOverride(this, EHazeViewPointSize::Hide, EHazeViewPointBlendSpeed::Instant, Priority = EHazeViewPointPriority::Override);
			}
		}
	}
}