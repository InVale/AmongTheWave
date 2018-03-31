using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using System;
using DarkTonic.MasterAudio;

[RequireComponent(typeof(Rigidbody))]
public class FloatingObjectAnimations : MonoBehaviour {

	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentSpeedFactor;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Space]
	float currentBuoyancyValue;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentBuoyancyAnimationPoint;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentBuoyancyStrength;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentBuoyancyLength;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Space]
	float currentForwardTiltAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentForwardTiltStrength;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Space]
	float currentSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float aimedSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentSideAngularVelocity;

	[Header("Basic Buoyancy")]
	public float restStrength;
	public float restLength;
	public AnimationCurve restCurve;

	[Header("High Speed Buoyancy")]
	public float fastSpeedReference;
	[Space]
	public float fastSpeedStrenght;
	public float fastSpeedLenght;
	[Space]
	public float fastSpeedTiltStrength;
	public AnimationCurve fastSpeedTiltCurve;

	[Header("Side Tilt")]
	public float sideStrength;
	public float sideSpeed;
	public float sideGravity;
	public float sideDrag;

	[Header("Sound"), SoundGroup]
	public string waterSound;
	public AnimationCurve waterVolume;
	public float waterTimeStamp;
	[Space]
	public AudioSource waterAmbient;
	public float waterAmbientVolumeMultiplier;

	Rigidbody _rb;

	[NonSerialized]
	public Vector3 boatsNormal = Vector3.up;

	bool _waterCanPlay = true;

	void Start () {
		_rb = GetComponent<Rigidbody> ();
	}

	void Update () {
		waterAmbient.volume = waterVolume.Evaluate ((_rb.velocity.magnitude > fastSpeedReference) ? 1 : _rb.velocity.magnitude / fastSpeedReference) * waterAmbientVolumeMultiplier;
	}

	void FixedUpdate () {
		currentSpeedFactor = _rb.velocity.magnitude / fastSpeedReference;
		currentSpeedFactor = (currentSpeedFactor > 1) ? 1 : currentSpeedFactor;

		Buoyancy (Time.fixedDeltaTime);
		Pendulum (Time.fixedDeltaTime);
		ForwardTilt (Time.fixedDeltaTime);

		transform.localEulerAngles = new Vector3(currentForwardTiltAngle, transform.localEulerAngles.y, currentSideAngle);
	}

	void Buoyancy (float timeTick) {
		currentBuoyancyLength = Mathf.Lerp (restLength, fastSpeedLenght, currentSpeedFactor);
		currentBuoyancyAnimationPoint += timeTick / currentBuoyancyLength;
		currentBuoyancyAnimationPoint %= 1;

		currentBuoyancyStrength = Mathf.Lerp (restStrength, fastSpeedStrenght, currentSpeedFactor);

		currentBuoyancyValue = restCurve.Evaluate (currentBuoyancyAnimationPoint) * currentBuoyancyStrength;
		Vector3 pos = transform.position;
		pos.y = currentBuoyancyValue;
		transform.position = pos;
	}

	void Pendulum (float timeTick) {
		if (aimedSideAngle != 0) {
			float sign = Mathf.Sign(aimedSideAngle);
			float factor = 1 - (currentSideAngle / aimedSideAngle);
			currentSideAngularVelocity += factor * sign * sideSpeed * timeTick;
		}
		else {
			float sign = (currentSideAngle != 0 ) ? Mathf.Sign(currentSideAngle) : 0;
			currentSideAngularVelocity -= sideGravity * timeTick * sign;
		}

		currentSideAngularVelocity *= (1 - Time.fixedDeltaTime * sideDrag); //Drag Formula ! Fucking useful !
		currentSideAngle += currentSideAngularVelocity * timeTick;
	}

	void ForwardTilt (float timeTick) {
		currentForwardTiltStrength = Mathf.Lerp (0, fastSpeedTiltStrength, currentSpeedFactor);

		currentForwardTiltAngle = fastSpeedTiltCurve.Evaluate (currentBuoyancyAnimationPoint) * currentForwardTiltStrength;

		if ((currentBuoyancyAnimationPoint >= waterTimeStamp) && _waterCanPlay) {
			MasterAudio.PlaySound3DAtVector3AndForget (waterSound, transform.position, waterVolume.Evaluate ((_rb.velocity.magnitude > fastSpeedReference) ? 1 : _rb.velocity.magnitude / fastSpeedReference));
			_waterCanPlay = false;
		}
		else if (currentBuoyancyAnimationPoint < waterTimeStamp) {
			_waterCanPlay = true;
		}
	}

	public void SetSideMovement (float force) {
		aimedSideAngle = -force * sideStrength;
	}
}
