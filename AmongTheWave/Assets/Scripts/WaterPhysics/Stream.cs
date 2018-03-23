using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Stream : MonoBehaviour {

	public static Stream current;

	[SerializeField]
	Vector2 streamDirection;
	[SerializeField]
	float streamForce;

	public Vector3 MainStream {
		get {
			return new Vector3(streamDirection.x, 0, streamDirection.y).normalized * streamForce;
		}
	}

	void Start() 
	{
		current = this;
	}
}
