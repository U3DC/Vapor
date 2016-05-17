﻿// Upgrade NOTE: replaced 'unity_World2Shadow' with 'unity_WorldToShadow'

// Collects cascaded shadows into screen space buffer
Shader "Hidden/Vapor/ShadowProperties" {
	Properties{
		_MainTex("", any) = "" {}
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "VaporCommon.cginc"
	
	#pragma target 5.0

	// Configuration
	sampler2D _MainTex;

	RWStructuredBuffer<float4x4> _MatrixBuf : register(u1);
	RWStructuredBuffer<float4> _LightSplits : register(u2);

	v2f vert_vapor_fs_buf(appdata v)
	{
		v2f o;
		//hack to make quad draw fullscreen - just convert UV into n. device coordinates
		o.pos = float4(float2(v.texcoord.x, 1.0f - v.texcoord.y) * 2.0f - 1.0f, 0.0f, 1.0f);
		o.uv = v.texcoord;
		return o;
	}


	float4 frag(v2f i) : SV_Target{
		_MatrixBuf[0] = unity_WorldToShadow[0];
		_MatrixBuf[1] = unity_WorldToShadow[1];
		_MatrixBuf[2] = unity_WorldToShadow[2];
		_MatrixBuf[3] = unity_WorldToShadow[3];

		_LightSplits[0] = _LightSplitsFar;

		return 0.0f;
	}
	
	//Spot lights only need VP matrix
	float4 frag_spot(v2f i) : SV_Target{
		uint index = floor(i.uv.x * 4.0f);
		return UNITY_MATRIX_VP[index];
	}

	ENDCG


	SubShader {
		//Pass for directional light properties
		Pass{
			ZWrite Off ZTest Always Cull Off

			CGPROGRAM
				#pragma vertex vert_vapor_fs_buf
				#pragma fragment frag

			ENDCG
		}

	}

	Fallback Off
}
