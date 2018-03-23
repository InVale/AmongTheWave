using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Boat : MonoBehaviour {

	public Vector2 current;
	public float accelerationFactor;

	Rigidbody _rb;
	Animator _anim;

	bool _immobile = false;
	bool _accelerate = false;

	// Use this for initialization
	void Start () {
		_rb = GetComponent<Rigidbody> ();
		_anim = GetComponent<Animator> ();
	}
	
	// Update is called once per frame
	void Update () {

		if (Input.GetButtonDown ("Fire1"))
			_immobile = !_immobile;

		if (Input.GetButton ("Accelerate"))
			_accelerate = true;
		else
			_accelerate = false;


	}

	void FixedUpdate () {
		if (!_immobile) {
			Vector3 mov = new Vector3(current.x, 0, current.y);
			mov = (_accelerate) ? mov * accelerationFactor : mov;
			_rb.AddForce (mov);
		}

		//_anim.SetFloat("ForwardSpeed")
	}
}
