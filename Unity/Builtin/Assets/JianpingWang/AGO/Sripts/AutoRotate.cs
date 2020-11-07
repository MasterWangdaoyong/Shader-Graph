using UnityEngine;
//来回旋转2
public class AutoRotate : MonoBehaviour
{
    public bool isLocal;
    public Vector3 rotateSpeed;
    public Transform targetCenter;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (targetCenter == null)
        {
            var rot = Quaternion.Euler(rotateSpeed * Time.deltaTime);
            if (isLocal)
            {
                transform.localRotation = rot * transform.localRotation;
            }
            else
            {
                transform.rotation = rot * transform.rotation;
            }
        }
        else
        {
            var rot = Quaternion.Euler(rotateSpeed * Time.deltaTime);
            transform.position = targetCenter.position + rot * (transform.position - targetCenter.position);
        }
    }
}
