using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using System;
using DarkTonic.MasterAudio;

//Hey, si tu l'as pas déjà vu, tu ferais mieux de d'abord check le script Boat !

//J'avais écrit ce script en me disant qu'à terme il ferait partie d'une série de script basé sur l'héritage qui permetterait de gérer le fonctionnement de tout les objets flottant.
//Mais j'ai fait des trucs un peu crade en fait.

[RequireComponent(typeof(Rigidbody))]
public class FloatingObjectAnimations : MonoBehaviour {

	//DEBUG
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Facteur de blend entre les animations normales et les animations à haute vitesse. Basé sur la vitesse du bateau.")]
	float currentSpeedFactor;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Valeur de position en y du bateau dans son animation de flottaison."), Space]
	float currentBuoyancyValue;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Valeur indiquant la progression dans l'animation de flottaison (allant de 0 à 1).")]
	float currentBuoyancyAnimationPoint;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Amplitude de l'animation de flottaison.")]
	float currentBuoyancyStrength;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Durée d'un cycle de l'animation de flottaison.")]
	float currentBuoyancyLength;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Valeur de rotation en x dans l'animation d'inclinaison du bateau du à la vitesse."), Space]
	float currentForwardTiltAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Amplitude de l'animation d'inclinaison du bateau.")]
	float currentForwardTiltStrength;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Valeur de rotation en z dans l'animation de tanguage du bateau."), Space]
	float currentSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Valeur d'angle d'inclinaison du bateau recherchée.")]
	float aimedSideAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Vélocité d'inclinaison du bateau en z.")]
	float currentSideAngularVelocity;

	//PUBLIC
	[Header("Basic Buoyancy"), Tooltip("Amplitude de l'animation de flottaison au niveau 0 de blend.")]
	public float restStrength;
	[Tooltip("Durée d'un cycle de l'animation de flottaison au niveau 0 de blend.")]
	public float restLength;
	[Tooltip("Courbe de l'évolution de la position en y du bateau pour l'animation de flottaison. La durée de la courbe doit être de 1 unité.")]
	public AnimationCurve restCurve;

	[Header("High Speed Buoyancy"), Tooltip("Vitesse à laquelle le blend des animations doit être égal à 1. Autrement dit, valeur de vitesse à laquelle le bateau est considéré comme \"allant vite\".")]
	public float fastSpeedReference;

	[Tooltip("Amplitude de l'animation de flottaison au niveau 1 de blend."), Space]
	public float fastSpeedStrenght;
	[Tooltip("Durée d'un cycle de l'animation de flottaison au niveau 1 de blend.")]
	public float fastSpeedLenght;

	[Tooltip("Amplitude de l'animation d'inclinaison au niveau 1 de blend."), Space]
	public float fastSpeedTiltStrength;
	[Tooltip("Courbe de l'évolution de la rotation en x du bateau pour l'animation d'inclinaison du bateau du à la vitesse. La durée de la courbe doit être de 1 unité.")]
	public AnimationCurve fastSpeedTiltCurve;

	[Header("Side Tilt"), Tooltip("Amplitude de l'animation de tanguage en fonction de la vitesse.")]
	public float sideStrength;
	[Tooltip("Vitesse de tanguage du bateau pour atteindre l'angle désiré.")]
	public float sideSpeed;
	[Tooltip("Vitesse de tanguage du bateau quand il revient au point neutre.")]
	public float sideGravity;
	[Tooltip("Drag sur la vélocté du tanguage du bateau (vitesse à laquelle la vélocité du tanguage du bateau diminue).")]
	public float sideDrag;

	[Header("Sound"), SoundGroup]
	public string waterSound; //C'est lié au plugin audio, oublie
	[Tooltip("Courbe d'évolution du volume des bruitages d'eau en fonction de la vitesse. La durée de la courbe doit être de 1 unité.")]
	public AnimationCurve waterVolume;
	[Tooltip("Quand est-ce que le son doit être joué dans le cycle d'animation du bateau. Doit être compris entre 0 et 1.")]
	public float waterTimeStamp;

	[Space]
	public AudioSource waterAmbient; //C'est lié au plugin audio, oublie
	[Tooltip("Amplitude des sons d'eau.")]
	public float waterAmbientVolumeMultiplier;

	//Internal
	Rigidbody _rb;
	[NonSerialized] //Pratique quand tu veux une variable accessible depuis l'extérieur mais qui n'a pas besoin d'être serialisé/apparaitre dans l'inspecteur.
	public Vector3 boatsNormal = Vector3.up; //Une constante en attendant de recup la normal aux vague.
	bool _waterCanPlay = true; //Un buffer pour jouer le son d'eau uniquement à certains points de l'anim'.

	void Start () {
		_rb = GetComponent<Rigidbody> ();
	}

	void Update () {
		//Dans l'update on met le volume du son d'eau au bon niveau en fonction de la vitesse.
		waterAmbient.volume = waterVolume.Evaluate ((_rb.velocity.magnitude > fastSpeedReference) ? 1 : _rb.velocity.magnitude / fastSpeedReference) * waterAmbientVolumeMultiplier;
	}

	void FixedUpdate () {
		//On calcul le facteur de vitesse. Le pragma permet de caper le facteur à 1.
		currentSpeedFactor = _rb.velocity.magnitude / fastSpeedReference;
		currentSpeedFactor = (currentSpeedFactor > 1) ? 1 : currentSpeedFactor;

		//On appelle l'anim de flottaison.
		Buoyancy (Time.fixedDeltaTime);
		//On appelle l'anim de tanguage.
		Pendulum (Time.fixedDeltaTime);
		//On appelle l'anim d'inclinaison.
		ForwardTilt (Time.fixedDeltaTime);

		//On modifie la rotation du bateau grâce aux données calculées.
		transform.localEulerAngles = new Vector3(currentForwardTiltAngle, transform.localEulerAngles.y, currentSideAngle);
	}

	//Fonction gérant la flottaison.
	void Buoyancy (float timeTick) {
		//On calcule l'avancée dans le cycle de l'animation.
		currentBuoyancyLength = Mathf.Lerp (restLength, fastSpeedLenght, currentSpeedFactor); //D'abord on trouve la durée actuelle par rapport à la vitesse.
		currentBuoyancyAnimationPoint += timeTick / currentBuoyancyLength; //Ensuite on augmente l'avancée dans le cycle.
		currentBuoyancyAnimationPoint %= 1; //Et enfin on cap le cycle pour qu'il boucle entre 0 et 1.

		//On calcule l'amplitude actuel de l'animation.
		currentBuoyancyStrength = Mathf.Lerp (restStrength, fastSpeedStrenght, currentSpeedFactor);

		//On maintenant recupérer la valeur lambda à ce moment du cycle et la multiplié par l'ampleur.
		currentBuoyancyValue = restCurve.Evaluate (currentBuoyancyAnimationPoint) * currentBuoyancyStrength;
		//Et on applique bien sûr.
		Vector3 pos = transform.position;
		pos.y = currentBuoyancyValue;
		transform.position = pos;
	}

	//Fonction gérant la tanguage.
	void Pendulum (float timeTick) {
		//Le tanguage se comporte différement si le stick est au point neutre ou non.
		if (aimedSideAngle != 0) {
			//Si le stick n'est pas au point neutre, on gagne de la vélocité pour rejoindre le point visé.
			float sign = Mathf.Sign(aimedSideAngle); //On recupère le signe pour aller dans le bon sens.
			float factor = 1 - (currentSideAngle / aimedSideAngle); //Ce truc vas servir à modeler une force de résistance.
			currentSideAngularVelocity += factor * sign * sideSpeed * timeTick; //On ajoute la vélocité.
		}
		else {
			//Si le stick est au point neutre, il doit y revenir et tanguer avant de se stabiliser.
			float sign = (currentSideAngle != 0 ) ? Mathf.Sign(currentSideAngle) : 0; //On récupère le signe de l'angle pour appliquer la gravité dans le sens inverse.
			currentSideAngularVelocity -= sideGravity * timeTick * sign; //On ajoute la vélocité.
		}
		
		//Formule permettant de calculer le drag sur la vélocité. En gros la résistance de l'air pour qu'il n'y est pas de mouvement infini.
		//UPDATE : J'ai récemment trouvé que la formule que j'utilisais (*= 1 - drag) n'était pas la formule de drag du Rigidbody contrairement à ce que j'avais vu. La nouvelle formule est meilleure car pas de risque de valeurs négatives.
		currentSideAngularVelocity /= (1 + Time.fixedDeltaTime * sideDrag);
		//UPDATE : Pendant que j'y suis, j'ai rajouté un threshold à la vélocité angulaire pour éviter les vibrations. Je l'ai hardcodé, mais tu peux modifier le Threshold si tu veux.
		currentSideAngularVelocity = (currentSideAngularVelocity <= 0.001f) ? 0 : currentSideAngularVelocity;
		currentSideAngle += currentSideAngularVelocity * timeTick; //On fait bouger l'angle grâce à la vélocité angulaire.
	}

	//Fonction gérant l'inclinaison.
	void ForwardTilt (float timeTick) {
		//On choppe l'amplitude d'inclinaison en fonction de la vitesse.
		currentForwardTiltStrength = Mathf.Lerp (0, fastSpeedTiltStrength, currentSpeedFactor);
		//On récupère la valeur de base à ce point du cycle et la multiplie à l'amplitude.
		//Pas besoin de plus puisqu'on se base sur le cycle de flottaison et qu'on a tout calculé avant.
		currentForwardTiltAngle = fastSpeedTiltCurve.Evaluate (currentBuoyancyAnimationPoint) * currentForwardTiltStrength;

		//Permet de jouer le deuxième son d'eau.
		if ((currentBuoyancyAnimationPoint >= waterTimeStamp) && _waterCanPlay) {
			MasterAudio.PlaySound3DAtVector3AndForget (waterSound, transform.position, waterVolume.Evaluate ((_rb.velocity.magnitude > fastSpeedReference) ? 1 : _rb.velocity.magnitude / fastSpeedReference));
			_waterCanPlay = false;
		}
		else if (currentBuoyancyAnimationPoint < waterTimeStamp) {
			_waterCanPlay = true;
		}
	}

	//La fonction permettant au script du Bateau de fixer l'angle visée pour le tanguage (en fonction de la force de rotation).
	public void SetSideMovement (float force) {
		//On fait un calcul simple en passant la force dans un facteur pour obtenir l'angle visée.
		aimedSideAngle = -force * sideStrength; 
	}
}
