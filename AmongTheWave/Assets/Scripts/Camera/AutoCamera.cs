using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;

public class AutoCamera : MonoBehaviour {

	public Transform target;

	//[Header("Camera Parameters")]

	[Header("Camera Tweaking")]
	public bool canControl;
	[ShowIf("canControl")]
	public Vector2 turnLimit;
	[ShowIf("canControl")]
	public float cameraSpeed;
	[ShowIf("canControl")]
	public AnimationCurve turnEase;

	[Header("References")]
	public GameObject actualCamera;

	Camera _cam;
	float currentX;
	float currentY;
	Vector3 baseRotGlobal;

	void Start () {
		_cam = actualCamera.GetComponent<Camera> ();
		baseRotGlobal = actualCamera.transform.eulerAngles;
	}

	void Update () {
		if (canControl) {
			float xAxis = Input.GetAxis ("Camera Horizontal");
			float yAxis = Input.GetAxis ("Camera Vertical");

			currentX = MoveAxis (xAxis, currentX);
			currentY = MoveAxis (yAxis, currentY);

			float x = Mathf.Sign (currentX) * turnEase.Evaluate (Mathf.Abs (currentX)) * turnLimit.x;
			float y = Mathf.Sign (currentY) * turnEase.Evaluate (Mathf.Abs (currentY)) * turnLimit.y;

			Vector3 rotGlobal = baseRotGlobal;
			rotGlobal.y += x;
			actualCamera.transform.eulerAngles = rotGlobal;

			Vector3 rotLocal = actualCamera.transform.localEulerAngles;
			rotLocal.x = y;
			actualCamera.transform.localEulerAngles = rotLocal;


		}
	}

	float MoveAxis (float axis, float current) {
		if (axis == 0 && current == 0)
			return 0;

		float dir = (axis > current) ? 1 : -1;
		current += dir * cameraSpeed * Time.deltaTime;
		float pos = (axis > current) ? 1 : -1;
		current = (pos != dir) ? axis : current;
		return current;
	}

	void FixedUpdate () {
		transform.position = target.position;
	}
}
