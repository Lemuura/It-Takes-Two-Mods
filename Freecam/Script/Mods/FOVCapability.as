import Mods.ModVariables;

class UFOVCapability : UHazeCapability 
{
	default CapabilityTags.Add(CapabilityTags::Camera);

	AHazePlayerCharacter Player;

	UFUNCTION(BlueprintOverride)
	void Setup(FCapabilitySetupParams SetupParams)
	{
		Player = Cast<AHazePlayerCharacter>(Owner);
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkActivation ShouldActivate() const
	{
        return EHazeNetworkActivation::ActivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	void TickActive(float DeltaTime)
	{
		float FOV = Console::GetConsoleVariableFloat("Mod.FOV");

		if (FOV == 0)
			Player.ClearFieldOfViewByInstigator(this);
		else
			Player.ApplyFieldOfView(FOV, FHazeCameraBlendSettings(1.f), Instigator = this);
	}
}