import Vino.Camera.Components.CameraSpringArmComponent;
import Vino.Movement.Components.MovementComponent;
import Vino.Audio.Movement.PlayerMovementAudioComponent;
import Vino.Interactions.Widgets.InteractionWidgetsComponent;
import Vino.Camera.Components.CameraUserComponent;
import Vino.Camera.Components.CameraDetacherComponent;
import Peanuts.Foghorn.FoghornManager;

import Vino.Tutorial.TutorialComponent;
import Vino.Pickups.PlayerPickupComponent;

import Peanuts.ButtonMash.ButtonMashComponent;
import Vino.Interactions.TriggerUser.TriggerUserComponent;
import Vino.Camera.Components.CameraDetacherComponent;
import Vino.Movement.MovementSettings;
import Peanuts.Dialogue.DialogueComponent;
import Peanuts.Fades.FadeManagerComponent;

import Effects.PostProcess.PostProcessing;
import Vino.PlayerHealth.PlayerHealthComponent;
import Vino.PlayerHealth.PlayerRespawnComponent;
import Peanuts.Audio.HazeAudioManager.AudioManagerStatics;
import Vino.Movement.Grinding.GrindingActivationPointComponent;
import Vino.Movement.Grinding.GrindingTransferActivationPoint;
import Peanuts.SpeedEffect.SpeedEffectComponent;
import Vino.Camera.Settings.FocusTargetSettings;
import Vino.Time.Capabilities.TimeDilationCapability;
import Peanuts.Animation.Components.AnimationLookAtComponent;
import Peanuts.CharacterFresnel.characterFresnelStatics;

import Mods.ModVariables;

settings PlayerDefaultSettings for UMovementSettings
{
	PlayerDefaultSettings.MoveSpeed = 800.f;
	PlayerDefaultSettings.GravityMultiplier = 6.1f;
}

UFUNCTION()
void SetCameraParticleSystem(AHazePlayerCharacter Player, UNiagaraSystem CameraParticleEffect)
{
	Cast<APlayerCharacter>(Player).PostProcessingComponent.SetCameraParticleSystem(CameraParticleEffect);
}

UFUNCTION()
UNiagaraSystem GetCameraParticleSystem(AHazePlayerCharacter Player)
{
	return Cast<APlayerCharacter>(Player).PostProcessingComponent.CameraParticleEffect;
}

// Enables or Disables the rope mesh on the player models.
UFUNCTION()
void SetPlayerRopesEnabled(UMaterialParameterCollection CharacterParameterCollection, AHazePlayerCharacter Player, bool Enabled = false)
{
	if(Player == Game::Cody)
	{
		Material::SetScalarParameterValue(CharacterParameterCollection, n"CodyRopeEnabled", Enabled ? 1 : 0);
	}
	if(Player == Game::May)
	{
		Material::SetScalarParameterValue(CharacterParameterCollection, n"MayRopeEnabled", Enabled ? 1 : 0);
	}
}

class APlayerCharacter : AHazePlayerCharacter
{
	UPROPERTY(DefaultComponent, Attach = RootOffsetComponent)
    UCameraDetacherComponent CameraDetacher;

	UPROPERTY(DefaultComponent, Attach = CameraDetacher)
	UCameraSpringArmComponent CameraSpringArm;

	UPROPERTY(DefaultComponent, Attach = CameraSpringArm)
	UHazeCameraComponent Camera;

	UPROPERTY(DefaultComponent)
	UCameraAssetsComponent CameraAssets;

	UPROPERTY(DefaultComponent)
	UHazeMovementComponent CharacterMovementComponent;
	default CharacterMovementComponent.DefaultMovementSettings = PlayerDefaultSettings;
	default CharacterMovementComponent.MoveWithComponentAlphaMaxTime = 0.2f;

	// To keep track of actual velocity when movement component is disabled.
	UPROPERTY(DefaultComponent)
	UHazeActualVelocityComponent ActualVelocityComp; 

	UPROPERTY(DefaultComponent)
	UHazeCrumbComponent CrumbComponent;
	default CrumbComponent.SyncIntervalType = EHazeCrumbSyncIntervalType::VeryHigh;
	default CrumbComponent.DebugHistorySize = 10;
	default CrumbComponent.CrumbDebugRadius = 50;
	default CrumbComponent.CrumbDebugSize = 100;
	default CrumbComponent.UpdateSettings.OptimalCount = 2;
	//default CrumbComponent.SetCrumbDebugActive(this, true);

	// This is a workaround due to movement component moving by teleporting. 
	default Mesh.bHazeAllowClothTeleport = false;
	default Mesh.bReceivesDecals = false;

	UPROPERTY(DefaultComponent)
	UHazeBurstForceComponent BurstForceComponent;

	UPROPERTY(DefaultComponent)
	UButtonMashComponent ButtonMashComponent;

	UPROPERTY(DefaultComponent)
	UCameraUserComponent CameraUserComp;

	default CapsuleComponent.SetCollisionProfileName(n"PlayerCharacter");

	UPROPERTY(DefaultComponent)
	UInteractionWidgetsComponent InteractionWidgets;

	UPROPERTY(DefaultComponent)
	UTutorialComponent TutorialComponent;

	UPROPERTY(DefaultComponent)
	UPlayerPickupComponent PickupComponent;
	
	UPROPERTY(DefaultComponent)
	UTriggerUserComponent TriggerUser;

	UPROPERTY(DefaultComponent)
	UDialogueComponent DialogueComponent;

	UPROPERTY(DefaultComponent)
	UOutlinesComponent OutlinesComponent;

	UPROPERTY(DefaultComponent)
	UPostProcessingComponent PostProcessingComponent;
	default PostProcessingComponent.OutlinesComponent = OutlinesComponent;


	UPROPERTY(DefaultComponent)
	UPlayerHazeAkComponent PlayerHazeAkComponent;	

	UPROPERTY(DefaultComponent)
	UFadeManagerComponent FadeManagerComponent;

	UPROPERTY(DefaultComponent)
	UHazeInputComponent InputComponent;
	default InputComponent.InputModifierCurve = Asset("/Game/Blueprints/Input/Curve_InputModifier.Curve_InputModifier");

	UPROPERTY(DefaultComponent)
	UFoghornManagerComponent FoghornComponent;

	UPROPERTY(DefaultComponent)
	UPlayerHealthComponent HealthComp;

	UPROPERTY(DefaultComponent)
	UPlayerRespawnComponent RespawnComp;

	UPROPERTY(DefaultComponent)
	UGrindingActivationComponent GrindingActivationComponent;

	UPROPERTY(DefaultComponent)
	UGrindingTransferActivationPoint GrindingTransferActivationPoint;

	UPROPERTY(DefaultComponent)
	USpeedEffectComponent SpeedEffect;

	UPROPERTY(DefaultComponent)
	UAnimationLookAtComponent AnimLookAtComp;

	UPROPERTY(DefaultComponent)
	UHazeCableComponent GrappleCableComponent;
	default GrappleCableComponent.AttachStartTo.ComponentProperty = n"Mesh";
	default GrappleCableComponent.AttachStartToSocketName = n"RightHand";
	default GrappleCableComponent.SolverIterations = 4;
	default GrappleCableComponent.bEnableStiffness = true;
	default GrappleCableComponent.CableLength = 200.f;
	default GrappleCableComponent.CableWidth = 6.f;
	default GrappleCableComponent.NumSides = 5;
	default GrappleCableComponent.TileMaterial = 32;
	default GrappleCableComponent.bEnableStiffness = false;
	default GrappleCableComponent.SubstepTime = 0.001f;

	UPROPERTY()
	UMaterialParameterCollection CharacterMaterialParameters = Asset("/Game/MasterMaterials/WorldParameters/CharacterMaterialParameters.CharacterMaterialParameters");

	UPROPERTY()
	UMaterialParameterCollection WorldShaderParameters = Asset("/Game/MasterMaterials/WorldParameters/WorldParameters.WorldParameters");
	
	UPROPERTY()
	UNiagaraParameterCollection WorldNiagaraParameters = Asset("/Game/MasterMaterials/WorldParameters/NiagaraWorldParameters.NiagaraWorldParameters");

	UPROPERTY(Category ="Debug Capabilities")
	TSubclassOf<UDebugTimeDilationCapability> DebugTimeDilation;

	UFocusTargetSettings FocusTargetSettings;
	
	void SetupComponents()
	{
		CharacterMovementComponent.Setup(CapsuleComponent);
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// DEBUG
	#if TEST
		Debug::RegisterActorLogger(this, 300);
	#endif

		// Input
		AddCapability(n"MovementDirectionInputCapability");
		AddCapability(n"TutorialCapability");

		// Physics
		AddCapability(n"PushDynamicObjectsCapability");

		// Pre Movement
		AddCapability(n"UpdateGroundedStateEventAction");
		AddCapability(n"UpdateAirTimeCapability");
		AddCapability(n"CharacterFaceDirectionCapability");

		AddCapability(n"CharacterSquishedCapability");

		//PlaneLock
		AddCapability(n"LockCharacterToPlaneCapability");

		// Core Movement
		{	// Floor Move
			AddCapability(n"CharacterFloorMoveCapability");
			AddCapability(n"CharacterFloorTurnAroundCapability");
			AddCapability(n"CharacterUnwalkableSurfaceMoveCapability");
			AddCapability(n"CharacterStartMovementGroundCheckCapability");
		}
		{	// Jump
			AddCapability(n"CharacterJumpCapability");
			AddCapability(n"CharacterAirJumpCapability");
			AddCapability(n"CharacterResetAirJumpsCapability");
			AddCapability(n"CharacterLongJumpCapability");
			
			AddCapability(n"CharacterJumpToCapability");
		}
		{	// Dash
			AddCapability(n"CharacterDashCapability");
			AddCapability(n"CharacterPerfectDashCapability");
			AddCapability(n"CharacterDashSlowdownCapability");
			AddCapability(n"CharacterAirDashCapability");
			AddCapability(n"CharacterDashWallHitPrediction");

			AddCapability(n"CharacterPerfectDashCameraCapability");
		}
		{	// Skydive
			AddCapability(n"CharacterSkydiveCapability");
			AddCapability(n"CharacterSkydiveCameraCapability");
		}
		{	// Sprint
			AddCapability(n"CharacterSprintCapability");
			AddCapability(n"CharacterSprintActivationCapability");
			AddCapability(n"CharacterSprintSlowdownCapability");
			AddCapability(n"CharacterSprintTurnAroundCapability");
		}
		{	// Ledge Grab
			AddCapability(n"CharacterEnterLedgeGrabCapability");
			AddCapability(n"CharacterLedgeGrabHangCapability");
			AddCapability(n"CharacterLedgeGrabClimbUpCapability");
			AddCapability(n"CharacterLedgeGrabJumpOffCapability");
			AddCapability(n"CharacterLedgeGrabJumpUpCapability");
			AddCapability(n"CharacterLedgeVaultCapability");
			AddCapability(n"CharacterLedgeGrabDropCapability");
			AddCapability(n"CharacterLedgeGrabEvaluateCapability");
		}
		{	// Ground Pound
			AddCapability(n"CharacterEvaluateGroundPoundCapability");
			AddCapability(n"CharacterGroundPoundEnterCapability");
			AddCapability(n"CharacterGroundPoundFallCapability");
			AddCapability(n"CharacterGroundPoundLandCapability");
			AddCapability(n"CharacterGroundPoundStandUpCapability");
			AddCapability(n"CharacterGroundPoundJumpCapability");
			AddCapability(n"CharacterGroundPoundDashCapability");
			AddCapability(n"CharacterGroundPoundLandOnSlopeCapability");
 
			//AddCapability(n"CharacterGroundPoundStartCapability");
			//AddCapability(n"CharacterGroundPoundFallCapability");
			//AddCapability(n"CharacterGroundPoundLandCapability");
			//AddCapability(n"CharacterGroundPoundLandOnSlopeCapability");
			//AddCapability(n"CharacterGroundPoundJumpCapability");
			//AddCapability(n"CharacterGroundPoundDashCapability");
			//AddCapability(n"CharacterGroundPoundExitCapability");
		}
		{	// Grinding	
			AddCapability(n"CharacterGrindingEvaluateCapability");

			// Enters
			AddCapability(n"CharacterProximityEnterGrindingCapability");
			AddCapability(n"CharacterGrindingGrappleEvaluateCapability");
			AddCapability(n"CharacterGrappleEnterGrindingCapability");
			AddCapability(n"CharacterTransferEnterGrindingCapability");
			AddCapability(n"CharacterGrindJumpGrindSplineCapability");
			
			// Grinding
			AddCapability(n"CharacterGrindingSpeedCapability");
			AddCapability(n"CharacterGrindingCapability");
			AddCapability(n"CharacterGrindingDashCapability");
			AddCapability(n"CharacterGrindingTurnAroundCapability");
			AddCapability(n"CharacterGrindingAudioCapability");

			// ImpactHandling
			AddCapability(n"CharacterGrindHitObstructionCapability");
			AddCapability(n"CharacterGrindingGroundExitCapability");

			// Exits
			AddCapability(n"CharacterGrindingJumpCapability");
			AddCapability(n"CharacterGrindJumpToLocationCapability");
			AddCapability(n"CharacterGrindingCancelGrindCapability");

			// Locking
			AddCapability(n"CharacterGrindAirSplineLockCapability");

			// Cameras
			AddCapability(n"CharacterGrindingGrappleEnterCameraCapability");
			AddCapability(n"CharacterGrindingCameraCapability");			
		}
		{	// Wall Sliding
			AddCapability(n"CharacterWallSlideCapability");
			AddCapability(n"CharacterWallSlideEvalutationCapability");
			AddCapability(n"CharacterAirDashWallSlideEvaluationsCapability");
			AddCapability(n"CharacterWallSlideVerticalJumpCapability");
			AddCapability(n"CharacterWallSlideHorizontalJumpCapability");
			AddCapability(n"CharacterWallSlideAudioCapability");
			AddCapability(n"CharacterWallSlideVerticalJumpReattachBlockerCapability");
			AddCapability(n"CharacterDashWallSlideEnterCapability");
			AddCapability(n"CharacterWallSlideCancelCapability");
		}
		{	// Wall Run
			// AddCapability(n"CharacterWallRunCapability");
			// AddCapability(n"CharacterWallRunJumpCapability");
		}
		{	// Swinging
			AddCapability(n"SwingSeekNearbyCapability");
			AddCapability(n"SwingCameraCapability");
			AddCapability(n"SwingDetachCameraCapability");
			
			AddCapability(n"SwingAttachCapability");
			AddCapability(n"SwingDetachCapability");
			AddCapability(n"SwingGrappleAttachCapability");
			
			AddCapability(n"SwingRadialMovementCapability");
		}
		{	// Sliding
			AddCapability(n"CharacterSlidingCapability");
			AddCapability(n"CharacterSlidingCameraCapability");
			AddCapability(n"CharacterSlidingJumpCapability");
		}
		{	// Crouch
			AddCapability(n"CharacterCrouchCapability");		
		}	//SplineLocking
		{
			AddCapability(n"LockCharacterToSplineCapability");
		}
		{	// Grapple
			AddCapability(n"CharacterGrappleCapability");
			GrappleCableComponent.SetVisibility(false);
			GrappleCableComponent.Deactivate();
		}		
		{	// Totem 			
			//AddCapability(n"CharacterSpeedBoostCapability");

			// Totem Head
			// AddCapability(n"TotemHeadCapability");
			// AddCapability(n"TotemHeadTravelToBodyCapability");
			// AddCapability(n"TotemHeadLeaveCapability");
			// AddCapability(n"TotemHeadReceiveLaunchedCapability");
			// AddCapability(n"TotemHeadSpeedBoostBodyCapability");

			//Totem Body
			//AddCapability(n"TotemBodyCapability");
			//AddCapability(n"TotemBodyInitializeHeadLaunchCapability");
			//AddCapability(n"TotemBodyTriggerHeadLaunchCapability");
			//AddCapability(n"TotemBodyGroundPoundStartCapability");
			//AddCapability(n"TotemHeadGroundPoundStartCapability");
		}
		
		//AddCapability(n"CharacterFaceCameraCapability");
		AddCapability(n"CancelMoveToCapability");
		AddCapability(n"CharacterDefaultMoveToCapability");
		AddCapability(n"MovementNetworkReplicationCapability");

		//BurstForces
		AddCapability(n"BurstForceCapability");		

		// Camera
		AddCapability(n"CameraUpdateCapability");
		AddCapability(n"CameraControlCapability");
		AddCapability(n"CameraLazyChaseCapability");
		AddCapability(n"CameraAdjustExtremePitchChaseCapability");
		AddCapability(n"CameraForcedClampedPointOfInterestCapability");		
		AddCapability(n"CameraClampedPointOfInterestCapability");
		AddCapability(n"CameraInputAssistPointOfInterestCapability");
		AddCapability(n"CameraPointOfInterestCapability");
		AddCapability(n"CameraNonControlledCapability");
		AddCapability(n"CameraNonControlledTransitionCapability");
		AddCapability(n"CameraCutsceneBlendInCapability");
		AddCapability(n"CameraNetworkSyncCapability");
		AddCapability(n"CameraModifierCapability");
		AddCapability(n"CameraImpulseCapability");
		AddCapability(n"CameraHideOverlappersCapability");
		AddCapability(n"CameraMatchOthersCutsceneRotationCapability");

		// Interaction
		AddCapability(n"InteractionCapability");

		// Collision
		AddCapability(n"PlayerCollisionCapability");

		// Visibility
		AddCapability(n"PlayerVisibilityCapability");
	
		// Death & Health
		AddCapability(n"CanActivateCheckpointVolumesCapability");
		AddCapability(n"PlayerCanRespawnCapability");
		AddCapability(n"PlayerRespawnCapability");
		AddCapability(n"PlayerRespawnHUDCapability");
		AddCapability(n"PlayerRespawnTimerCapability");
		AddCapability(n"PlayerTensionModeCapability");
		AddCapability(n"PlayerDieCapability");
		AddCapability(n"PlayerGameOverCapability");
		AddCapability(n"PlayerHealthDisplayCapability");
		AddCapability(n"PlayerHealthRegenerationCapability");
		AddCapability(n"PlayerDeathVelocityCapability");
		AddCapability(n"PlayerHealthAudioCapability");
		AddCapability(n"PlayerRespawnAudioCapability");
		AddCapability(n"PlayerDeathFadeToBlackAudioCapability");		
		AddCapability(n"PlayerGameOverAudioCapability");
		AddCapability(n"PlayerHealthAudioFilteringCapability");

		// Animation
		AddCapability(n"CancelThreeShotCapability");
		AddCapability(n"FullscreenDisableAnimLookAtCapability");

		// Pickup
		AddCapability(n"PickupCapability");

		// Dialogue
		AddCapability(n"PlayerDialogueCapability");
		AddCapability(n"PlayerStationaryDialogueCapability");

		// Effect
		AddCapability(n"SpeedEffectCapability");		

		// Player location
		AddCapability(n"PlayerMarkerCapability");
		AddCapability(n"FindOtherPlayerCapability");

		// Audio
		AddCapability(n"DefaultListenerCapability");
		AddCapability(n"DefaultPlayerPanningCapability");
		AddCapability(n"PlayerGameplayStatusUpdateCapability");
		AddCapability(n"PlayerMovementAudioCapability");
		AddCapability(n"PlayerFoghornCapability");
		AddCapability(n"CutsceneListenerCapability");
		AddCapability(n"FullScreenListenerCapability");
		AddCapability(n"HorizontalSplitScreenListenerCapability");
		AddCapability(n"ReflectionTraceCapability");
		AddCapability(n"ReflectionTraceStaticCapability");
		AddCapability(n"ReflectionTraceFullScreenCapability");

		if(IsMay())
			AddCapability(n"AudioTimeDialationCapability");

		// AudioMovementData
		AddCapability(n"PlayerVelocityDataUpdateCapability");

		// Sequencer
		AddCapability(n"SkipCutsceneCapability");

		// Pendulum
		AddCapability(n"CharacterPendulumCapability");

		// AutoMove
		AddCapability(n"CharacterAutoMoveCapability");

		// Knockdown
		AddCapability(n"CharacterKnockDownCapability");

		// Focus points
		AddCapability(n"LookAtFocusPointCapability");

		// Strafe
		AddCapability(n"CharacterSlowStrafeCapability");

#if TEST
		// Debug
		AddDebugCapability(n"DebugShortcutsEnableCapability");
		if (Network::IsNetworked())
		{
			AddDebugCapability(n"DebugNetworkFreezeCapability");
			if(Game::IsEditorBuild())
			{
				AddDebugCapability(n"DebugViewSwapCapability");
				AddDebugCapability(n"SkeletalMeshNetworkVisualizationCapability");	
				if (IsMay())
					AddDebugCapability(n"AudioDebugNetworkCapability");
			}

		}
		AddDebugCapability(n"DebugControllerSwapCapability");
 		AddDebugCapability(n"DebugFastForwardCutscenesCapability");

		AddDebugCapability(n"DebugCameraCapability");
		AddDebugCapability(n"DebugTemporalCapability");
		AddDebugCapability(n"DebugViewModeCapability");
		AddDebugCapability(n"DebugGodModeCapability");
		AddDebugCapability(n"DebugCameraListenerCapability");
		AddDebugCapability(n"CopyCameraTransformDebugCapability");
		AddDebugCapability(n"DebugAnimationInspectionCameraCapability");

		// Movement
		AddDebugCapability(n"DebugPlayerLocationCapability");
		AddDebugCapability(n"DebugPlayerLocationVisualizerCapability");
		AddDebugCapability(n"FlipNoClipMovementCapability");

		AddDebugCapability(DebugTimeDilation);

		//Audio
		if(IsMay())
		{
			AddDebugCapability(n"AudioDebugMemoryProfilingCapability");
			AddDebugCapability(n"AudioDebugActiveSequencesCapability");
		}
		
		// This is broken in some levels so it can't be here by default, tyko
		//AddDebugCapability(n"DebugMovementSurfaceCapability");
#endif

		// Modded Capabilities
		AddCapability(n"FullscreenCapability");
		AddCapability(n"OtherPlayerFullscreenCapability");
		AddCapability(n"FOVCapability");
		AddCapability(n"NoClipCapability");
		AddCapability(n"FlyCapability");
		AddCapability(n"InvisibleCapability");
		AddCapability(n"SpeedStateSaveCapability");
		AddCapability(n"SpeedStateRestoreCapability");
		AddCapability(n"SpeedStateTeleportCapability");

		SetupComponents();

		if(IsMay())
		{
			FHazeResetFunction ResetFunc;
			ResetFunc.BindUFunction(this, n"ResetAudioManager");
			Reset::BindResetFunctionOneOff(this, ResetFunc);
		}

		AddCustomPostProcessSettings(PostProcessingComponent.GlobalPostProcess, 1.f, this);	

		// Make sure any settings remain after reset
		CameraUserComp.RecordInitialState();

        // Nuke camera frustrum and proxy editor comps which we don't use in-game        
        Camera.ClearEditorProxies();
		
		DisableDecals(Mesh);
		Mesh.OnAttachedChild.AddUFunction(this, n"DisableDecals");

		FocusTargetSettings = UFocusTargetSettings::GetSettings(this);
		UFocusTargetSettings::SetComponent(this, Mesh, this, EHazeSettingsPriority::Defaults);

		Material::SetScalarParameterValue(WorldShaderParameters, n"IsEditor", 0);

	}

	bool bFresnelDisabledByCutscene = false;
	FVector AccumulatedVelocity = FVector(0,0,0);

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		// Global player shader location, used for various effects such as bushes moving out of the way.
		FVector PlayerLocation = GetActorLocation();
		FVector PlayerVelocity = GetActorVelocity();

		AccumulatedVelocity += PlayerVelocity;
		AccumulatedVelocity = FMath::Lerp(AccumulatedVelocity, FVector::ZeroVector, FMath::Clamp(DeltaTime * 4.0f, 0.0f, 1.0f));
		
		Material::SetVectorParameterValue(WorldShaderParameters,
			IsCody() ? n"CodyLocation" : n"MayLocation",
			FLinearColor(PlayerLocation.X, PlayerLocation.Y, PlayerLocation.Z, AccumulatedVelocity.Size()));

		auto Parameter = Niagara::GetNiagaraParameterCollection(WorldNiagaraParameters);
		Parameter.SetVectorParameter(
			IsCody() ? n"NPC.NiagaraWorldParameters.CodyLocation"
					 : n"NPC.NiagaraWorldParameters.MayLocation",
			PlayerLocation);
			
		// global character material fresnel effect used for making characters show up more clearly against backgrounds.
		if(bFresnelDisabledByCutscene != bIsParticipatingInCutscene)
		{	
			if(bIsParticipatingInCutscene)
			{
				DisableCharacterFresnel(CharacterMaterialParameters, 1.0f);
				bFresnelDisabledByCutscene = true;
			}
			else
			{
				if(!GetOtherPlayer().bIsParticipatingInCutscene) // only enable outline if no players are in a cutscene
				{
					EnableCharacterFresnel(CharacterMaterialParameters, 1.0f);
					bFresnelDisabledByCutscene = false;
				}
			}
		}
	}

	UFUNCTION(BlueprintOverride)
	FVector GetFocusLocation() const
	{
		UFocusTargetSettings Settings = FocusTargetSettings; 
		if (FocusTargetSettings == nullptr)
			Settings = UFocusTargetSettings::GetSettings(this); // In case we call this before beginplay

		USceneComponent FocusRootComponent = Settings.Component;
		if ((CapsuleComponent == nullptr) || (FocusRootComponent == nullptr))
			return GetActorCenterLocation();

		// Don't want to use head bone or something that will move with animation.
		FVector Offset = FVector(0.f, 0.f, CapsuleComponent.GetUnscaledCapsuleHalfHeight() * Settings.CapsuleHeightOffset * 2.f);
		FTransform FocusRootTransform = FocusRootComponent.GetWorldTransform();
		return FocusRootTransform.TransformPosition(Offset);
	}

#if TEST
	// Quick and dirty way to visualize data in AS
	void DrawDebugGraph(FDebugFloatHistory GraphData, FLinearColor InColor = FLinearColor(0.f, 0.f, 0.f, 0.f))
	{

		FVector GraphDrawOffset = FVector(-1.f, 0.5f, -0.5f);
		FVector2D GraphScale = FVector2D(2.f, 1.f); 
		const float DesiredAngleFromCamera = 10.f;

		const FVector PlayerProjectedOnCameraDirection = FMath::ClosestPointOnInfiniteLine(
			GetViewLocation() - GetViewRotation().Vector(),
			GetViewLocation() + GetViewRotation().Vector(),
			GetActorCenterLocation()
		);

		const float DistanceToCamera = (PlayerProjectedOnCameraDirection - GetViewLocation()).Size();
        const float ScalerFactor = FMath::Tan(FMath::DegreesToRadians(DesiredAngleFromCamera)) * DistanceToCamera;

		GraphDrawOffset *= ScalerFactor;
		GraphScale *= ScalerFactor;

		FVector DrawLocation = PlayerProjectedOnCameraDirection;
		DrawLocation += GetViewTransform().GetRotation().RotateVector(GraphDrawOffset);

		const FLinearColor DrawDebugGraphColor = InColor == FLinearColor(0.f, 0.f, 0.f, 0.f) ? GetDebugColor() : InColor;

		System::DrawDebugFloatHistoryTransform(
			GraphData,
			FTransform(GetViewRotation(), DrawLocation),
			GraphScale,
			DrawDebugGraphColor,
			0.f
		);
	}
#endif

	UFUNCTION(BlueprintOverride)
	void EnableOutlineByInstigator(UObject InInstigator)
	{
		PostProcessingComponent.EnableOutlineByInstigator(InInstigator);
	}

	UFUNCTION(BlueprintOverride)
	void DisableOutlineByInstigator(UObject InInstigator)
	{
		PostProcessingComponent.DisableOutlineByInstigator(InInstigator);
	}

	UFUNCTION(NotBlueprintCallable)
	void DisableDecals(USceneComponent Component)
	{
		TArray<USceneComponent> Components;
		Component.GetChildrenComponents(true, Components);
		Components.Add(Component);
		for (USceneComponent Comp : Components)
		{
			UPrimitiveComponent PrimComp = Cast<UPrimitiveComponent>(Comp);
			if (PrimComp != nullptr)
				PrimComp.SetReceivesDecals(false);
		}
	}

	UFUNCTION()
	void ResetAudioManager(EComponentResetType ResetType)
	{
		UHazeAudioManager AudioManager = GetAudioManager();
		AudioManager.OnReset(ResetType);

		FHazeResetFunction ResetFunc;
		ResetFunc.BindUFunction(this, n"ResetAudioManager");
		Reset::BindResetFunctionOneOff(this, ResetFunc);
	}

	// Modded functions

	UFUNCTION(DevFunction)
	void Freecam()
	{
		Fullscreen();
		NoClip();
		Fly();
		Invisible();
	}

	bool isFullscreen = false;

	UFUNCTION(DevFunction)
	void Fullscreen()
	{
		int LastValue = Console::GetConsoleVariableInt("Mod.Fullscreen");
		int NewValue = (LastValue == 0) ? 1 : 0;
		Console::SetConsoleVariableInt("Mod.Fullscreen", NewValue, "", true);
	}

	UFUNCTION(DevFunction)
	void OtherPlayer_Fullscreen()
	{
		int LastValue = Console::GetConsoleVariableInt("Mod.OtherPlayerFullscreen");
		int NewValue = (LastValue == 0) ? 1 : 0;
		Console::SetConsoleVariableInt("Mod.OtherPlayerFullscreen", NewValue, "", true);
	}

	UFUNCTION(DevFunction)
	void FOV(float FOV)
	{
		Console::SetConsoleVariableFloat("Mod.FOV", FOV, "", true);
	}

	UFUNCTION(DevFunction)
	void NoClip()
	{
		int LastValue = Console::GetConsoleVariableInt("Mod.NoClip");
		int NewValue = (LastValue == 0) ? 1 : 0;
		Console::SetConsoleVariableInt("Mod.NoClip", NewValue, "", true);
	}

	UFUNCTION(DevFunction)
	void Fly()
	{
		int LastValue = Console::GetConsoleVariableInt("Mod.Fly");
		int NewValue = (LastValue == 0) ? 1 : 0;
		Console::SetConsoleVariableInt("Mod.Fly", NewValue, "", true);
	}

	UFUNCTION(DevFunction)
	void Fly_Horizontal_Speed(float Speed)
	{
		if (Speed == 0)
			Console::SetConsoleVariableFloat("Mod.Fly.HorizontalSpeed", 2500, "", true);
		else
			Console::SetConsoleVariableFloat("Mod.Fly.HorizontalSpeed", Speed, "", true);
	}

	UFUNCTION(DevFunction)
	void Fly_Vertical_Speed(float Speed)
	{
		if (Speed == 0)
			Console::SetConsoleVariableFloat("Mod.Fly.VerticalSpeed", 2500, "", true);
		else
			Console::SetConsoleVariableFloat("Mod.Fly.VerticalSpeed", Speed, "", true);
	}

	UFUNCTION(DevFunction)
	void Fly_Horizontal_InterpSpeed(float Speed)
	{
		if (Speed == 0)
			Console::SetConsoleVariableFloat("Mod.Fly.HorizontalInterpSpeed", 13000, "", true);
		else
			Console::SetConsoleVariableFloat("Mod.Fly.HorizontalInterpSpeed", Speed, "", true);
	}

	UFUNCTION(DevFunction)
	void Fly_Vertical_InterpSpeed(float Speed)
	{
		if (Speed == 0)
			Console::SetConsoleVariableFloat("Mod.Fly.VerticalInterpSpeed", 13000, "", true);
		else
			Console::SetConsoleVariableFloat("Mod.Fly.VerticalInterpSpeed", Speed, "", true);
	}

	UFUNCTION(DevFunction)
	void Invisible()
	{
		int LastValue = Console::GetConsoleVariableInt("Mod.Invisible");
		int NewValue = (LastValue == 0) ? 1 : 0;
		Console::SetConsoleVariableInt("Mod.Invisible", NewValue, "", true);
	}

	UFUNCTION(DevFunction)
	void Show_FPS()
	{
		System::ExecuteConsoleCommand("stat fps");
	}

	UFUNCTION(DevFunction)
	void Show_Volumes()
	{
		System::ExecuteConsoleCommand("show volumes");
	}

	UFUNCTION(DevFunction)
	void Swap_Controllers()
	{
		System::ExecuteConsoleCommand("Haze.SwapControllers");
	}
};
