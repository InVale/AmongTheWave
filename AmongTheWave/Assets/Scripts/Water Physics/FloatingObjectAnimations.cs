using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

public class FloatingObjectAnimations : MonoBehaviour {

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Space]
	float currentFloatValue;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float aimedSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug")]
	float currentSideGravity;

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
		currentFloatValue = restCurve.Evaluate ((Time.time % restLength) / restLength) * restStrenght;
		Vector3 pos = transform.position;
		pos.y = currentFloatValue;
		transform.position = pos;
	}

	void Pendulum () {
		float sign = (aimedSideAngle != 0) ? Mathf.Sign(aimedSideAngle) : ((currentSideAngle != 0 ) ? Mathf.Sign(currentSideAngle) : 0);

		if (sign != 0 && (sign * currentSideAngle <= sign * aimedSideAngle)) {
			float factor = (aimedSideAngle - currentSideAngle) / aimedSideAngle;
			factor *= sign;
			currentSideAngle += factor * sideSpeed * Time.fixedDeltaTime;
			currentSideGravity = 0;
		}
		else {
			currentSideGravity += sideGravity * Time.fixedDeltaTime * sign;
			currentSideGravity *= (1 - Time.fixedDeltaTime * sideDrag); //Drag Formula ! Fucking useful !
			currentSideAngle -= currentSideGravity * Time.fixedDeltaTime;
		}

		transform.localEulerAngles = new Vector3(0, transform.localEulerAngles.y, currentSideAngle);
	}

	public void SetSideMovement (float force) {
		aimedSideAngle = -force * sideStrenght;
	}
}
