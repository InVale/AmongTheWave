using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

public class FloatingObjectAnimations : MonoBehaviour {

	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float aimedSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentSideAngle;

	[Header("Basic Floating")]
	public float restStrenght;
	public float restLength;
	public AnimationCurve restCurve;

	[Header("Basic Floating")]
	public float sideStrenght;
	public float sideSpeed;
	public float sideGravity;
	public float sideDrag;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void FixedUpdate () {
		Buoyancy ();
		Pendulum ();
	}

	void Buoyancy () {
		float value = restCurve.Evaluate ((Time.time % restLength) / restLength) * restStrenght;
		Vector3 pos = transform.position;
		pos.y = value;
		transform.position = pos;
	}

	void Pendulum () {
		//if ()
	}

	public void SetSideMovement (float force) {
		aimedSideAngle = force / sideStrenght;
	}
}
