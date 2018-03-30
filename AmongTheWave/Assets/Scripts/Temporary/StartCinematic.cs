using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class StartCinematic : MonoBehaviour {

    public PlayableDirector timeline;

    void OnTriggerEnter(Collider collider)
    {
        if (collider.tag == "Player")
        {
            timeline.Play();
        }
    }
}
