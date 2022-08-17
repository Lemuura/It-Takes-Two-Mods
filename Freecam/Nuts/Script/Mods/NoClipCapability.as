import Mods.ModVariables;

import Vino.Movement.Components.MovementComponent;
import Peanuts.Movement.DefaultCharacterCollisionSolver;
import Peanuts.Movement.NoCollisionSolver;
import Peanuts.Movement.DefaultCharacterRemoteCollisionSolver;

class UNoClipCapability : UHazeCapability 
{	
    default CapabilityTags.Add(CapabilityTags::Debug);
    default CapabilityTags.Add(CapabilityTags::Collision);

	default TickGroup = ECapabilityTickGroups::Input;

	bool bNoClipActive = false;

	AHazePlayerCharacter Player;
	UHazeMovementComponent MoveComp;
	TSubclassOf<UHazeCollisionSolver> LastUsedSolver;

	UFUNCTION(BlueprintOverride)
	void Setup(FCapabilitySetupParams SetupParams)
	{
		MoveComp = UHazeMovementComponent::Get(Owner);
		Player = Cast<AHazePlayerCharacter>(Owner);
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkActivation ShouldActivate() const
	{
		if (CVar_NoClip.GetInt() == 0)
			return EHazeNetworkActivation::DontActivate;

		return EHazeNetworkActivation::ActivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkDeactivation ShouldDeactivate() const
	{
		if (CVar_NoClip.GetInt() == 0)
			return EHazeNetworkDeactivation::DeactivateLocal;

		return EHazeNetworkDeactivation::DontDeactivate;
	}

	UFUNCTION(BlueprintOverride)
	void OnActivated(FCapabilityActivationParams ActivationParams)
	{
			LastUsedSolver = MoveComp.GetCollisionSolver().Class;
			MoveComp.UseCollisionSolver(UNoCollisionSolver::StaticClass(), UDefaultCharacterRemoteCollisionSolver::StaticClass());
			Player.BlockCapabilities(n"CanDie", this);
	}

	UFUNCTION(BlueprintOverride)
	void OnDeactivated(FCapabilityDeactivationParams DeactivationParams)
	{
			MoveComp.UseCollisionSolver(LastUsedSolver, UDefaultCharacterRemoteCollisionSolver::StaticClass());
			Player.UnblockCapabilities(n"CanDie", this);
	}

	UFUNCTION(BlueprintOverride)
	void TickActive(float DeltaTime)
	{
		PrintToScreen("" + Owner.GetName() + " Wall collision disabled", 0.f, FLinearColor::Red);
	}
}