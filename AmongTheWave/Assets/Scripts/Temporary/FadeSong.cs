using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DarkTonic.MasterAudio;

public class FadeSong : MonoBehaviour {

	public float toVolume;
	public float fadeTime;
	[Space]
	public PlaylistController myController;

	void OnTriggerEnter (Collider collider) {
		if (collider.tag == "Player") {
			myController.FadeToVolume (toVolume, fadeTime);
		}
	}
}
