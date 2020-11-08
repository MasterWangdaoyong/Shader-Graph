// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)
 //004a
#ifndef UNITY_STANDARD_CORE_FORWARD_INCLUDED
#define UNITY_STANDARD_CORE_FORWARD_INCLUDED

#if defined(UNITY_NO_FULL_STANDARD_SHADER)
//如果没有定义，使用完全版本 
    #define UNITY_STANDARD_SIMPLE 1
    //新定义一个简化版
#endif

#include "UnityStandardConfig.cginc"

#if UNITY_STANDARD_SIMPLE
//如果启用简化版
    #include "UnityStandardCoreForwardSimple.cginc"
    //引入UnityStandardCoreForwardSimple
    //forward base function
    VertexOutputBaseSimple vertBase (VertexInput v) { return vertForwardBaseSimple(v); } //vertex pragma
    //调取UnityStandardCoreForwardSimple 内的函数 vertForwardBaseSimple，输入VertexInput 并输出结构体VertexOutputBaseSimple
    half4 fragBase (VertexOutputBaseSimple i) : SV_Target { return fragForwardBaseSimpleInternal(i); } //fragment pragma
    //输入VertexOutputBaseSimple结构体 并调用fragForwardBaseSimpleInternal function 返回最终颜色
    //forward add function
    VertexOutputForwardAddSimple vertAdd (VertexInput v) { return vertForwardAddSimple(v); }   //vertex add pragma
    //输入VertexInput 调取vertForwardAddSimple function 返回VertexOutputForwardAddSimple结构体
    half4 fragAdd (VertexOutputForwardAddSimple i) : SV_Target { return fragForwardAddSimpleInternal(i); } //fragment add pragma
    //输入VertexOutputForwardAddSimple结构体 调取fragForwardAddSimpleInternal function 返回最终add 颜色
#else
//如果没有启用简化版
    //跟上述类似，优先梳理这个标准模式
    #include "UnityStandardCore.cginc" 
    //引入UnityStandardCore    
    VertexOutputForwardBase vertBase (VertexInput v) { return vertForwardBase(v); } //vertex pragma //005a
    VertexOutputForwardAdd vertAdd (VertexInput v) { return vertForwardAdd(v); }//vertex add pragma
    half4 fragBase (VertexOutputForwardBase i) : SV_Target { return fragForwardBaseInternal(i); } //fragment pragma 
    half4 fragAdd (VertexOutputForwardAdd i) : SV_Target { return fragForwardAddInternal(i); } //fragment add pragma
#endif
#endif // UNITY_STANDARD_CORE_FORWARD_INCLUDED
