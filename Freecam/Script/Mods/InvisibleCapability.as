import Mods.ModVariables;

class UInvisibleCapability : UHazeCapability 
{
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
		int value = Console::GetConsoleVariableInt("Mod.Invisible");

		if (value == 0)
			Player.UnblockCapabilities(n"Visibility", this);
		else
			Player.BlockCapabilities(n"Visibility", this);
	}
}