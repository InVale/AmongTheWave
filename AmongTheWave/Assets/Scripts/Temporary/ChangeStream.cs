using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeStream : MonoBehaviour {

	public Vector2 streamDirection;
	public float streamVelocity;
	
	void OnTriggerEnter (Collider collider) {
		if (collider.tag == "Player") {
			Boat script = collider.transform.parent.GetComponent<Boat> ();
			script.stream = streamDirection.normalized * streamVelocity;
		}
	}
}
