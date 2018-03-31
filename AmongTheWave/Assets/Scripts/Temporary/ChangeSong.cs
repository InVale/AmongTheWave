using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DarkTonic.MasterAudio;

public class ChangeSong : MonoBehaviour {

	public string playlist;

	void OnTriggerEnter (Collider collider) {
		if (collider.tag == "Player") {
			MasterAudio.ChangePlaylistByName (playlist);
		}
	}
}
