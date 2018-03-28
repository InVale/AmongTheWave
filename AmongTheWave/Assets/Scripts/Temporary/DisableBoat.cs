using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisableBoat : MonoBehaviour {
	
	void OnTriggerEnter (Collider collider) {
		if (collider.tag == "Player") {
			Destroy (collider.GetComponent<Boat> ());
			Destroy (collider.GetComponent<FloatingObjectAnimations> ());
			Destroy (collider.GetComponent<Rigidbody> ());
			Destroy (collider.GetComponent<MeshCollider> ());
		}
	}
}
