using UnityEngine;
//来回旋转
class TweenPosition : MonoBehaviour
{
    public Vector3 fromPos = new Vector3(0,0,0);
    public Vector3 toPos = new Vector3(0,0,0);
    public AnimationCurve curve = AnimationCurve.Linear(0, 0, 1, 1);  
    public float duration = 1f;
    public bool isLoop = true;
    public bool isPingPong = true;       
    private float timer = 0f;
    private Vector3 lastOffset = Vector3.zero;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (duration > 0)
        {
            timer += Time.deltaTime;
            float curveValue;
            if (isLoop)
            {
                float remainTime = timer % duration;
                int loopCount = (int)(timer / duration);
                float evaluateTime = remainTime / duration;
                if (isPingPong)
                {
                    evaluateTime = loopCount % 2 == 0 ? evaluateTime : 1 - evaluateTime;
                }
                curveValue = curve.Evaluate(evaluateTime);
            }
            else
            {
                curveValue = curve.Evaluate(timer);
            }
            Vector3 curOffset = Vector3.Lerp(fromPos, toPos, curveValue);
            Vector3 deltaOffset = curOffset - lastOffset;
            lastOffset = curOffset;
            transform.position += deltaOffset;
        }
    }
}
