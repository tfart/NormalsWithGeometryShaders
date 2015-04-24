using UnityEngine;
using System.Collections;

public class NormalAnimator : MonoBehaviour {

	private Material mat;
	private const float length_min = 0.16f;
	private const float length_max = 0.3f;
	private const float length_frequency = 1.6f;
	
	private const float width_min = 0.15f;
	private const float width_max = 0.3f;
	private const float width_frequency = 1.1f;

	private const float rotation_min = 130f;
	private const float rotation_max = 160f;
	private const float rotation_frequency = 0.6f;

	// Use this for initialization
	void Start () {
		mat = this.GetComponentInChildren<MeshRenderer>().sharedMaterial;
	}

	private static float Interpolate(float min, float max, float frequency) {
		float delta = max - min;
		return min + (Mathf.Sin(Time.time * frequency)*1) * delta/2;
	}
	
	// Update is called once per frame
	void Update () {
		
		float length = Interpolate(length_min, length_max, length_frequency);
		mat.SetFloat("_NormalLength", length);

		float width = Interpolate(width_min, width_max, width_frequency);
		mat.SetFloat("_NormalWidth", width);

		float rotation = Interpolate(rotation_min, rotation_max, rotation_frequency);
		this.transform.rotation = Quaternion.Euler(0f, rotation, 0f);
	}
}
