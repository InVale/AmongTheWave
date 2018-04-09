using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using DarkTonic.MasterAudio;

//Hey Clarisse, content de voir que t'as envie de reprendre Among the Wave.
//J'ai donc commenté l'intégralité du code de contrôle du bateau ainsi que du code d'animation (FloatingObjectAnimation) afin de te donner un coup de main.
//Je n'ai commenté que c'est deux là puisque c'est là que ya eu tout l'engineering côté prog.
//Surtout n'hésite pas à me contacter si t'as la moindre question ou si tu veux un coup de main.

//Bon on commence direct avec ces deux trucs là.
//En gros je me sentais un peu trop chaud et j'ai décidé de faire les truc de façon propre (à peu près).
[RequireComponent(typeof(Rigidbody))] //Rigidbody obligatoire vu qu'on build par dessus.
[RequireComponent(typeof(FloatingObjectAnimations))] //Et le code gérant les animations du bateau, mandatory aussi.
public class Boat : MonoBehaviour {

	//DEBUG
	//(Tout à été mis sous FoldoutGroup("Debug") qui est un truc d'Odin qui permet de les regrouper.
	//C'est des valeurs pratiques à avoir pour du debug mais qui ne sont pas du tweaking en soit.
	//D'ailleurs, la plupart sont en ReadOnly (un truc d'Odin assez explicite) et en SerializeField pour apparaitre dans l'inspecteur en restant privée.
	[FoldoutGroup("Debug"), Tooltip("Permet de setup la direction et la force du courant affectant le bateau en attendant que le système soit fait autrement et que le bateau récupère lui même cette valeur.")]
	public Vector2 stream;
	[FoldoutGroup("Debug"), Tooltip("Permet d'immobiliser le bateau pour du Debug et le début de partie.")]
	public bool immobile;

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Vélocité du bateau."), Space]
	float currentVelocity;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Niveau d'accélération de Debug.")]
	float currentAcceleration = 1; //Relatif au système d'accélération pour le debug, voir en dessous.
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Vélocité angulaire du bateau.")]
	float currentTurnSpeed;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Angular Drag du rigidbody bateau.")]
	float currentTurnDrag; //Cette valeur est aussi visible dans le Rigidbody puis qu'on l'applique à l'Angular Drag du Rigidbody, mais je l'ai remis là pour rassembler les trucs.

	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Angle entre le forward du bateau et le sens du courant."), Space]
	float angleToStream;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Valeur d'angle maximale autorisée pour Angle To Stream.")]
	float currentMaxAngle;
	[ReadOnly, SerializeField, FoldoutGroup("Debug"), Tooltip("Quotient de Angle To Stream divisé par Current Max Angle. Sert à opposer une force de résistance à la rotation angulaire.")]
	float rFactor;


	//PUBLIC
	[Header("Tweak"), Tooltip("Volume du bateau. Permet de faire les calculs de force s'y appliquant pour fonctionner en paire avec la valeur de masse dans le Rigidbody.")]
	//En gros l'idée c'est que plus un object est gros, plus il offre de prise au courant et donc plus de force s'y applique.
	//Mais le problème c'est qu'en général, plus il est gros et plus il est lourd et donc plus il faut de force pour le faire bouger.
	//Normalement pour modéliser cette prise au courant j'aurais du faire un truc stylé en regardant le mesh.
	//Mais comme j'avais pas de mesh définitif et que j'avais la flemme, j'ai mobilisé ce truc à la shlag en mettant une valeur de Size qui vient multiplier la force du courant.
	//Cette augmentation de la force du courant est nécessaire car on set la masse dans le rigidbody pour les collisions et qu'à cause de ça, il faut bien plus de force pour atteindre la même vélocité.
	public float size; 
	[Tooltip("De combien le niveau d'accélération est augmenté à chaque input d'accélération (RB). La valeur de courant est multiplié par la niveau d'accélération.")]
	public float accelerationFactor; //Ce truc d'accélération c'est strictement que du debug.
	[Tooltip("Peut-on accélérer/deccélérer en utilisant l'axe Y du Joystick gauche ?")]
	public bool yControl;
	[ShowIf("yControl")] //Fonction d'Odin super pratique permettant de cacher/montrer une variable dans l'inspecteur en fonction de l'état d'une variable booléenne.
	[Tooltip("Par combien la force du courant est multiplié quand le joystick est vers le bas (freinage).")]
	public float brakeFactor;
	[ShowIf("yControl"), Tooltip("Par combien la force du courant est multiplié quand le joystick est vers le haut (accélération).")]
	public float speedFactor;

	[Tooltip("Force initiale de rotation angulaire."), Space]
	public float turnSpeed;
	[Tooltip("Drag Angulaire initiale du Rigidbody. Override la valeur d'Angular Drag du Rigidbody.")]
	public float turnDrag;
	[Tooltip("Vitesse de rotation du gouvernail à l'arrière du bateau. Purement cosmétique.")]
	public float rudderSpeed;

	[Tooltip("Comment est-ce que l'évolution des valeurs de Turn Speed et Turn Drag en fonction de la vitesse sera calculé ? Par multiplication ou addition du facteur ?"), Space]
	public TurnCalculTypeEnum turnFactorCalcul;
	[Tooltip("Facteur d'augmentation de la force de rotation avec la vitesse.")]
	public float turnFactor;
	[Tooltip("Facteur d'augmentation de l'angular drag du rigidbody avec la vitesse.")]
	public float turnDragFactor;
	[Tooltip("Valeur de référence de vélocité pour faciliter les calculs d'évolution des valeurs avec la vitesse.")]
	public float referenceVelocity;

	[Tooltip("Comment est-ce que l'évolution de la valeur d'angle maximale de rotation en fonction de la vitesse sera calculé ? Par multiplication ou addition du facteur ?"), Space]
	public TurnCalculTypeEnum turnAngleCalcul;
	[Tooltip("Valeur initiale d'angle maximale de rotation.")]
	public float turnMaxAngle;
	[Tooltip("Facteur d'augmentation (ou diminution en fonction de la valeur) de la valeur d'angle maximal de rotation avec la vitesse.")]
	public float turnAngleFactor;

	[Header("References"), Tooltip("Reference du Transform du gouvernail.")]
	public Transform rudder;
	[SoundGroup] //ça c'est lié au plugin audio. C'est dégueux, oublie.
	public string boatCreakSound;

	//INTERNAL
	Rigidbody _rb; //ref du rigidbody.
	FloatingObjectAnimations _floatAnim; //ref du script d'anim de flottaison.

	float _currentDir = 0; //Angle actuel du gouvernail.
	float _lastInput = 0; //Dernière position du stick pour le son de craquement.
	float _lastInputTime; //Cooldon pour le son de craquement.

	//Enum pour les différents mode de calcul
	public enum TurnCalculTypeEnum {
		ADDITIVE,
		MULTIPLICATIVE
	}
		
	//Assez classique, on setup les refs du rigidbody et du script d'anim qu'on est d'ailleurs sur d'avoir grâce au RequireComponent.
	void Start () {
		_rb = GetComponent<Rigidbody> ();
		_floatAnim = GetComponent<FloatingObjectAnimations> ();
	}

	void Update () {

		//Avec Start on peut immobiliser/remettre en marche le bateau. (DEBUG)
		if (Input.GetButtonDown ("Start")) {
			immobile = !immobile;
		}

		//On augmente le niveau d'accélération si on reçoit l'input (RB). (DEBUG)
		if (Input.GetButtonDown ("Accelerate"))
			currentAcceleration += accelerationFactor;

		//On reset le niveau d'accélération si on reçoit l'input (B). (DEBUG)
		if (Input.GetButtonDown("Cancel")) {
			currentAcceleration = 1;
		}
			
		//On appelle les mouvements du gouvernail.
		RudderDirection ();
	}

	//Fonction gérant le gouvernail.
	void RudderDirection () {
		float input = Input.GetAxis ("Horizontal") * -45; //Le 45 c'est l'angle maximal du gouvernail hardcodé. C'est -45 car le gouvernail doit rotate dans le sens opposé au sens désiré.
		float dir = input - _currentDir; //On calcul l'angle entre la rotation désirée par rapport à la position du stick et la rotation actuelle du gouvernail.

		if (dir != 0) { //Si l'angle obtenue est différent de 0, alors un mouvement est nécessaire.

			//On rotate le gouvernail dans la bonne direction par la vitesse de rotation * Time.deltaTime.
			dir = Mathf.Sign (dir);
			_currentDir += dir * rudderSpeed * Time.deltaTime;

			//On cap l'angle à 45 s'il est supérieur à cette valeur.
			_currentDir = (Mathf.Abs(_currentDir) > 45) ? dir * 45 : _currentDir;

			//ça c'est sensé évité que le gouvernail tremble lorsqu'il est à 0, mais ça marche moyen et j'ai eu la flemme de le recoder.
			_currentDir = ((input == 0) && (Mathf.Abs (_currentDir) < 0.15f)) ? 0 : _currentDir;

			//On change la rotation du gouvernail pour correspondre à la nouvelle valeur.
			Vector3 rudRot = rudder.localEulerAngles;
			rudRot.y = _currentDir;
			rudder.localEulerAngles = rudRot;
		}
	}

	//On fait les opérations de physiques dans le FixedUpdate
	void FixedUpdate () {

		//On ne fait aucune opération si le bateau doit être immobile.
		if (!immobile) {

			//On appelle la fonction s'occupant de faire le gros des opérations de rotation du bateau.
			Rotation ();

			//Code rapide pour le système d'accélération/deccélération en fonction de l'axe Y du Joystick gauche.
			float factor = 1;
			if (yControl) {
				factor = Input.GetAxis ("Vertical");
				factor = (factor < 0) ? brakeFactor : ((factor > 0) ? speedFactor : 1);
			}

			//On applique la force du courant au bateau pour le mouvoir.
			//La force s'applique en fonction du forward du bateau, ballec du sens du courant :^)
			//Enfin en vrai faudrait corriger ça pour quand on prend en coup.
			//Mais en temps normal le modèle marche bien vu que le forward du bateau est limité par le sens du courant.
			Vector3 mov = new Vector3(stream.x, 0, stream.y);
			mov *= size * currentAcceleration;
			_rb.AddForce (mov.magnitude * transform.forward * factor);
		}

		//La variable indiquant la vélocité du bateau est update même quand il est immobile.
		currentVelocity = _rb.velocity.magnitude;
	}

	//Fonction s'occupant de la rotation du bateau.
	void Rotation () {
		//Input Horizontal qu'on garde en ref.
		float xInput = Input.GetAxis ("Horizontal");
		//Facteur de vitesse pour les calculs.
		float factor = _rb.velocity.magnitude / referenceVelocity;

		//On calcul d'abord le facteur pour la force de rotation et la valeur d'angular drag pour les faire évoluer avec la vitesse.
		float tFactor = 1;
		float dFactor = 1;
		//En additif, facteur = 1 + (facteur de vitesse) * (valeur de facteur).
		if (turnFactorCalcul == TurnCalculTypeEnum.ADDITIVE) {
			tFactor += factor * turnFactor;
			if (tFactor <= 0)
				//L'idée de ce debug log, c'est au cas où une valeur négative de facteur est usité.
				//Si la valeur ou la vitesse est suffisament grande, au lieu d'une simple diminution, on peut obtenir un facteur négatif, donnant des résultats bizarres.
				Debug.Log("Your turnFactor value is too negative for additive calcul considering the reachable speed; factor ended up being negative.");
			dFactor += factor * turnDragFactor;
		}
		//En multiplicatif, facteur = (valeur de facteur) ^ (facteur de vitesse).
		else if (turnFactorCalcul == TurnCalculTypeEnum.MULTIPLICATIVE) {
			tFactor = Mathf.Pow (turnFactor, factor);
			dFactor = Mathf.Pow (turnDragFactor, factor);
			//Pas besoin de check dans ce cas, il n'est pas possible d'obtenir un facteur négatif "involontairement".
		}

		//On calcule ensuite l'angle maximale de rotation en fonction de la vitesse.
		//La valeur d'angle vas servir à calculer la résistance à la rotation du bateau pour faire un truc smooth.
		//Le mode de calcul est différent au cas où.
		if (turnAngleCalcul == TurnCalculTypeEnum.ADDITIVE) {
			float buffer = 1 + factor * turnAngleFactor;
			if (tFactor <= 0)
				Debug.Log("Your turnAngleFactor value is too negative for additive calcul considering the reachable speed; factor ended up being negative.");
			currentMaxAngle = turnMaxAngle * buffer;
		}
		else if (turnAngleCalcul == TurnCalculTypeEnum.MULTIPLICATIVE) {
			currentMaxAngle = turnMaxAngle * Mathf.Pow (turnAngleFactor, factor);
		}
		//Une fois qu'on a l'angle max, on choppe l'angle du bateau par rapport au courant.
		//On choppe l'angle avec son signe afin d'avoir le sens dans lequel appliqué la résistance.
		angleToStream = Vector2.SignedAngle(stream.normalized, new Vector2(transform.forward.x, transform.forward.z));
		//Et on obtient ainsi le facteur de résistance.
		rFactor = angleToStream / currentMaxAngle;

		//On ajoute enfin les forces.
		//La force de rotation dépend ainsi du facteur de rotation (qui dépend de la vitesse), de l'input horizontal, et de la force de résistance qui essaye de ramener le bateau dans le droit chemin.
		//L'angular drag de base du bateau couplé à la résistance permet d'éviter de (trop) dépasser l'angle maximal de rotation du bateau.
		currentTurnSpeed = tFactor * turnSpeed * (xInput + rFactor);
		_rb.AddTorque (_floatAnim.boatsNormal * currentTurnSpeed); //On applique la force par rapport à la normal du bateau qui aurait ultimement dépendu des vagues.
		_floatAnim.SetSideMovement (tFactor * turnSpeed * xInput); //On balance une valeur au script d'anim' afin qu'il est des infos pour gérer l'inclinaison du bateau sur l'axe z.

		//On change la valeur d'angular drag calculé en fonction de la vitesse.
		//ça permet d'avoir un bateau plus réactif plus on va vite (moins d'inertie).
		currentTurnDrag = dFactor * turnDrag;
		_rb.angularDrag = currentTurnDrag;

		//Le truc qui gère les craquements.
		//On check d'abord si le stick est dans une position "absolue" (full gauche, full droite, neutre).
		if (xInput == 1 || xInput == -1 || xInput == 0) {
			//Si oui, on check si le cooldown est fini et si la position est différente de la dernière position enregistré.
			if (xInput != _lastInput && _lastInputTime <= Time.time) {
				//Auquel cas on joue le son.
				_lastInputTime = Time.time + 1f; //Ce truc là c'est une manière stylé de faire un cooldown. En gros tu choppes le Time.time du jeu et tu lui ajoutes une valeur. Puis tu attends que ton Time.time lui soit supérieur.
				MasterAudio.PlaySound3DAtTransformAndForget(boatCreakSound, transform);
			} 
			_lastInput = xInput;
		}
	}
}
