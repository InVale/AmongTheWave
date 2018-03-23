using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoCamera : MonoBehaviour {

	public Transform target;

	[Header("Camera Parameters")]
	public Vector3 offset;

	[Header("Tweaking")]
	public float lerpForce;

	[Header("References")]
	public GameObject actualCamera;

	Camera _cam;

	//Constante
	float leniencyLimit = 0.05f;

	// Use this for initialization
	void Start () {
		_cam = actualCamera.GetComponent<Camera> ();
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void FixedUpdate () {
		transform.position = target.position;
	}
}
