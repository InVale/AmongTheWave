using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoCamera : MonoBehaviour {

	public Transform target;

	//[Header("Camera Parameters")]

	[Header("Camera Tweaking")]
	public Vector2 turnLimit;
	public float cameraSpeed;
	public AnimationCurve turnEase;

	[Header("References")]
	public GameObject actualCamera;

	Camera _cam;
	float currentX;
	float currentY;

	void Start () {
		_cam = actualCamera.GetComponent<Camera> ();
	}

	void Update () {
		float xAxis = Input.GetAxis ("Camera Horizontal");
		float yAxis = Input.GetAxis ("Camera Vertical");

		currentX = MoveAxis (xAxis, currentX);
		currentY = MoveAxis (yAxis, currentY);

		float x = Mathf.Sign (currentX) * turnEase.Evaluate (Mathf.Abs (currentX)) * turnLimit.x;
		float y = Mathf.Sign (currentY) * turnEase.Evaluate (Mathf.Abs (currentY)) * turnLimit.y;

		actualCamera.transform.localEulerAngles = new Vector3(y, x, 0);
	}

	float MoveAxis (float axis, float current) {
		if (axis == 0 && current == 0)
			return 0;

		float dir = (axis > currentX) ? 1 : -1;
		current += dir * cameraSpeed * Time.deltaTime;
		float pos = (axis > currentX) ? 1 : -1;
		current = (pos != dir) ? axis : current;
		return current;
	}

	void FixedUpdate () {
		transform.position = target.position;
	}
}
