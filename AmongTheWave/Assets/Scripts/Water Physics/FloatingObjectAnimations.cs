using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

public class FloatingObjectAnimations : MonoBehaviour {

	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentBuoyancyValue;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Space]
	float currentSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float aimedSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentSideAngularVelocity;

	[Header("Basic Floating")]
	public float restStrenght;
	public float restLength;
	public AnimationCurve restCurve;

	[Header("Basic Floating")]
	public float sideStrenght;
	public float sideSpeed;
	public float sideGravity;
	public float sideDrag;

	void FixedUpdate () {
		Buoyancy ();
		Pendulum ();
	}

	void Buoyancy () {
		currentBuoyancyValue = restCurve.Evaluate ((Time.time % restLength) / restLength) * restStrenght;
		Vector3 pos = transform.position;
		pos.y = currentBuoyancyValue;
		transform.position = pos;
	}

	void Pendulum () {
		if (aimedSideAngle != 0) {
			float sign = Mathf.Sign(aimedSideAngle);
			float factor = 1 - (currentSideAngle / aimedSideAngle);
			currentSideAngularVelocity += factor * sign * sideSpeed * Time.fixedDeltaTime;
		}
		else {
			float sign = (currentSideAngle != 0 ) ? Mathf.Sign(currentSideAngle) : 0;
			currentSideAngularVelocity -= sideGravity * Time.fixedDeltaTime * sign;
		}

		currentSideAngularVelocity *= (1 - Time.fixedDeltaTime * sideDrag); //Drag Formula ! Fucking useful !
		currentSideAngle += currentSideAngularVelocity * Time.fixedDeltaTime;

		transform.localEulerAngles = new Vector3(0, transform.localEulerAngles.y, currentSideAngle);
	}

	public void SetSideMovement (float force) {
		aimedSideAngle = -force * sideStrenght;
	}
}
