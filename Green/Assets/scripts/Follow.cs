using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Follow : MonoBehaviour
{

    public GameObject followed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        GetComponent<Rigidbody>().velocity = 0.95f * GetComponent<Rigidbody>().velocity +
                                             0.05f * (followed.transform.position - transform.position);
        
    }
}
