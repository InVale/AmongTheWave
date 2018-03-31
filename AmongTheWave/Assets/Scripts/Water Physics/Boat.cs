using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using DarkTonic.MasterAudio;

[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(FloatingObjectAnimations))]
public class Boat : MonoBehaviour {

	//Debug
	[FoldoutGroup("Debug")]
	public Vector2 stream;
	[FoldoutGroup("Debug")]
	public bool immobile;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Space]
	float currentVelocity;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentAcceleration = 1;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentTurnSpeed;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentTurnDrag;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Space]
	float angleToStream;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentMaxAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float rFactor;

	//Public
	[Header("Tweak")]
	public float size;
	public float accelerationFactor;
	public bool yControl;
	[ShowIf("yControl")]
	public float brakeFactor;
	[ShowIf("yControl")]
	public float speedFactor;
	[Space]
	public float turnSpeed;
	public float turnDrag;
	public float rudderSpeed;
	[Space]
	public TurnCalculTypeEnum turnFactorCalcul;
	public float turnFactor;
	public float turnDragFactor;
	public float referenceVelocity;
	[Space]
	public TurnCalculTypeEnum turnAngleCalcul;
	public float turnMaxAngle;
	public float turnAngleFactor;

	//[Header("Sound")]

	[Header("References")]
	public Transform rudder;
	[SoundGroup]
	public string boatCreakSound;

	//Internal
	Rigidbody _rb;
	FloatingObjectAnimations _floatAnim;

	float _currentDir = 0;
	float _lastInput = 0;
	float _lastInputTime;

	public enum TurnCalculTypeEnum {
		ADDITIVE,
		MULTIPLICATIVE
	}

	// Use this for initialization
	void Start () {
		_rb = GetComponent<Rigidbody> ();
		_floatAnim = GetComponent<FloatingObjectAnimations> ();
	}
	
	// Update is called once per frame
	void Update () {

		if (Input.GetButtonDown ("Start")) {
			immobile = !immobile;
		}

		if (Input.GetButtonDown ("Accelerate"))
			currentAcceleration += accelerationFactor;

		if (Input.GetButtonDown("Cancel")) {
			currentAcceleration = 1;
		}

		RudderDirection ();
	}

	void RudderDirection () {
		float input = Input.GetAxis ("Horizontal") * -45;
		float dir = input - _currentDir;

		if (dir != 0) {
			dir = Mathf.Sign (dir);
			_currentDir += dir * rudderSpeed * Time.deltaTime;
			_currentDir = (Mathf.Abs(_currentDir) > 45) ? dir * 45 : _currentDir;
			_currentDir = ((input == 0) && (Mathf.Abs (_currentDir) < 0.15f)) ? 0 : _currentDir;
			rudder.localEulerAngles = Vector3.up * _currentDir;
		}
	}

	void FixedUpdate () {
		if (!immobile) {
			Rotation ();

			float factor = 1;
			if (yControl) {
				factor = Input.GetAxis ("Vertical");
				factor = (factor < 0) ? brakeFactor : ((factor > 0) ? speedFactor : 1);
			}

			Vector3 mov = new Vector3(stream.x, 0, stream.y);
			mov *= size * currentAcceleration;
			_rb.AddForce (mov.magnitude * transform.forward * factor);
		}
			
		currentVelocity = _rb.velocity.magnitude;
	}

	void Rotation () {
		float xInput = Input.GetAxis ("Horizontal");
		float factor = _rb.velocity.magnitude / referenceVelocity;

		//Calculate Turn Factor
		float tFactor = 1;
		float dFactor = 1;
		if (turnFactorCalcul == TurnCalculTypeEnum.ADDITIVE) {
			tFactor += factor * turnFactor;
			if (tFactor <= 0)
				Debug.Log("Your turnFactor value is too negative for additive calcul considering the reachable speed; factor ended up being negative.");
			dFactor += factor * turnDragFactor;
		}
		else if (turnFactorCalcul == TurnCalculTypeEnum.MULTIPLICATIVE) {
			tFactor = Mathf.Pow (turnFactor, factor);
			dFactor = Mathf.Pow (turnDragFactor, factor);
		}

		//Calculate Water Resistance
		if (turnAngleCalcul == TurnCalculTypeEnum.ADDITIVE) {
			float buffer = 1 + factor * turnAngleFactor;
			if (tFactor <= 0)
				Debug.Log("Your turnAngleFactor value is too negative for additive calcul considering the reachable speed; factor ended up being negative.");
			currentMaxAngle = turnMaxAngle * buffer;
		}
		else if (turnAngleCalcul == TurnCalculTypeEnum.MULTIPLICATIVE) {
			currentMaxAngle = turnMaxAngle * Mathf.Pow (turnAngleFactor, factor);
		}
		angleToStream = Vector2.SignedAngle(stream.normalized, new Vector2(transform.forward.x, transform.forward.z));
		rFactor = angleToStream / currentMaxAngle;

		//Add Forces
		currentTurnSpeed = tFactor * turnSpeed * (xInput + rFactor);
		_rb.AddTorque (_floatAnim.boatsNormal * currentTurnSpeed);
		_floatAnim.SetSideMovement (tFactor * turnSpeed * xInput);

		currentTurnDrag = dFactor * turnDrag;
		_rb.angularDrag = currentTurnDrag;

		//Play Sound
		if (xInput == 1 || xInput == -1 || xInput == 0) {
			if (xInput != _lastInput && _lastInputTime <= Time.time) {
				_lastInputTime = Time.time + 1f;
				MasterAudio.PlaySound3DAtTransformAndForget(boatCreakSound, transform);
			} 
			_lastInput = xInput;
		}
	}
}
