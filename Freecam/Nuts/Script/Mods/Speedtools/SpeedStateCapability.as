class USpeedStateComponent : UActorComponent
{
	FTransform SavedTransform;
	FVector SavedVelocity;
}

class USpeedStateSaveCapability : UHazeCapability 
{
	AHazePlayerCharacter Player;
	USpeedStateComponent StateComp;

	default TickGroup = ECapabilityTickGroups::Input;

	UFUNCTION(BlueprintOverride)
	void Setup(FCapabilitySetupParams SetupParams)
	{
		Player = Cast<AHazePlayerCharacter>(Owner);
		StateComp = USpeedStateComponent::GetOrCreate(Player);
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkActivation ShouldActivate() const
	{
		if (!IsActioning(ActionNames::SwingAttach))
			return EHazeNetworkActivation::DontActivate;

		if (!WasActionStarted(ActionNames::FindOtherPlayer))
			return EHazeNetworkActivation::DontActivate;

		return EHazeNetworkActivation::ActivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkDeactivation ShouldDeactivate() const
	{
		return EHazeNetworkDeactivation::DeactivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	void OnActivated(FCapabilityActivationParams ActivationParams)
	{
		auto MoveComp = UHazeBaseMovementComponent::Get(Owner);
		StateComp.SavedTransform = Player.ActorTransform;
		StateComp.SavedVelocity = MoveComp.Velocity;

		ConsumeAction(ActionNames::FindOtherPlayer);
	}
}

class USpeedStateRestoreCapability : UHazeCapability 
{
	AHazePlayerCharacter Player;
	USpeedStateComponent StateComp;

	default TickGroup = ECapabilityTickGroups::Input;

	UFUNCTION(BlueprintOverride)
	void Setup(FCapabilitySetupParams SetupParams)
	{
		Player = Cast<AHazePlayerCharacter>(Owner);
		StateComp = USpeedStateComponent::GetOrCreate(Player);
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkActivation ShouldActivate() const
	{
		if (!IsActioning(ActionNames::MovementSprintToggle))
			return EHazeNetworkActivation::DontActivate;

		if (!WasActionStarted(ActionNames::SwingAttach))
			return EHazeNetworkActivation::DontActivate;

		return EHazeNetworkActivation::ActivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkDeactivation ShouldDeactivate() const
	{
		return EHazeNetworkDeactivation::DeactivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	void OnActivated(FCapabilityActivationParams ActivationParams)
	{
		auto MoveComp = UHazeBaseMovementComponent::Get(Player);
		Player.ActorTransform = StateComp.SavedTransform;
		MoveComp.Velocity = StateComp.SavedVelocity;

		ConsumeAction(ActionNames::SwingAttach);
	}
}

class USpeedStateTeleportCapability : UHazeCapability
{
	AHazePlayerCharacter Player;
	AHazePlayerCharacter OtherPlayer;

	default TickGroup = ECapabilityTickGroups::Input;

	UFUNCTION(BlueprintOverride)
	void Setup(FCapabilitySetupParams SetupParams)
	{
		Player = Cast<AHazePlayerCharacter>(Owner);
		OtherPlayer = Player.OtherPlayer;
	}

	UFUNCTION(BlueprintOverride)
	EHazeNetworkActivation ShouldActivate() const
	{
		if (!IsActioning(ActionNames::Cancel))
			return EHazeNetworkActivation::DontActivate;

		if (!WasActionStarted(ActionNames::FindOtherPlayer))
			return EHazeNetworkActivation::DontActivate;

		return EHazeNetworkActivation::ActivateLocal;
	}
	
	UFUNCTION(BlueprintOverride)
	EHazeNetworkDeactivation ShouldDeactivate() const
	{
		return EHazeNetworkDeactivation::DeactivateLocal;
	}

	UFUNCTION(BlueprintOverride)
	void OnActivated(FCapabilityActivationParams ActivationParams)
	{
		Player.ActorTransform = OtherPlayer.ActorTransform;

		ConsumeAction(ActionNames::FindOtherPlayer);
	}
}