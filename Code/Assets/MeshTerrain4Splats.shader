//1.�ܹ�����ͼӰ��
//2.����ЧӰ��
Shader "Custom/Mesh Terrain 4 Splats" {
Properties {
	_Control ("SplatMap (RGBA)", 2D) = "red" {}
	_Splat0 ("Layer 0 (R)", 2D) = "black" {}
	_Splat1 ("Layer 1 (G)", 2D) = "black" {}
	_Splat2 ("Layer 2 (B)", 2D) = "black" {}
	_BaseMap ("BaseMap (RGB)", 2D) = "black" {}
}
/************************************************************************************************************************/
/************************************************************************************************************************/
CGINCLUDE
	#include "UnityCG.cginc"

	struct appdata_lightmap {
		float4 vertex : POSITION;
		float2 texcoord : TEXCOORD0;
		float2 texcoord1 : TEXCOORD1;
	};

	struct v2f_vertex {
		float4 pos : SV_POSITION;
		float4 uv[3] : TEXCOORD0;
		UNITY_FOG_COORDS(4)
	};

	uniform sampler2D _Control;
	uniform float4 _Control_ST;

	uniform sampler2D _Splat0, _Splat1, _Splat2, _BaseMap;
	uniform float4 _Splat0_ST, _Splat1_ST, _Splat2_ST, _BaseMap_ST;

	v2f_vertex vert(appdata_lightmap v)
	{
		v2f_vertex o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv[0].xy = TRANSFORM_TEX(v.texcoord.xy, _Control);
#ifndef LIGHTMAP_OFF
		o.uv[0].zw = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#else
		o.uv[0].zw = half2(0, 0);
#endif
		o.uv[1].xy = v.texcoord.xy * _Splat0_ST.xy;//layer0 uv
		o.uv[1].zw = v.texcoord.xy * _Splat1_ST.xy;//layer1 uv
		o.uv[2].xy = v.texcoord.xy * _Splat2_ST.xy;//layer2 uv
		o.uv[2].zw = v.texcoord.xy * _BaseMap_ST.xy;//baseMap uv

		UNITY_TRANSFER_FOG(o, o.pos);
		return o;
	}

	half4 frag(v2f_vertex i) : COLOR
	{
		half4 splat_control = tex2D(_Control, i.uv[0].xy);

		half3 splat_color = half3(0, 0, 0);
		splat_color += splat_control.r * tex2D(_Splat0, i.uv[1].xy).rgb;
		splat_color += splat_control.g * tex2D(_Splat1, i.uv[1].zw).rgb;
		splat_color += splat_control.b * tex2D(_Splat2, i.uv[2].xy).rgb;
		splat_color += splat_control.a * tex2D(_BaseMap, i.uv[2].zw).rgb;
	

#ifndef LIGHTMAP_OFF
		//fixed3 lm = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv[0].zw));
		//splat_color.rgb *= lm;
#endif		

		half4 result = half4 (splat_color, 0.0);
		UNITY_APPLY_FOG(i.fogCoord, result);
		UNITY_OPAQUE_ALPHA(result.a);

		return result;
	}
ENDCG
/************************************************************************************************************************/
/************************************************************************************************************************/
SubShader {
	LOD 200
	Tags { 
		"Queue" = "Geometry"	
		"RenderType" = "Opaque" 
	}

	Pass { 		
CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fog
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF//��֤��InspectorԤ������
ENDCG
 	}
}
/************************************************************************************************************************/
/************************************************************************************************************************/
//�Ѿ�ͨ������ShaderStripping��������, ����Ҫ�Լ����⴦����
/*
SubShader {
	LOD 200
	Tags{
	"Queue" = "Geometry"
	"RenderType" = "Opaque"
	}
	Pass{
		Tags{ "LightMode" = "Always" }

CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fog
		#pragma fragmentoption ARB_precision_hint_fastest
		//#pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF//��InspectorԤ��������
ENDCG
		}
	}
*/
/************************************************************************************************************************/
/************************************************************************************************************************/
//SubShader {
//	Tags { "RenderType" = "Opaque" }
//	Pass { 
//		Tags { "LightMode" = "Vertex" }
//		SetTexture [_BaseMap] { constantColor(0,0,0,0) combine texture, constant }
// 	}
//	Pass { 
//		Tags { "LightMode" = "VertexLM" }
//		SetTexture [unity_Lightmap] { combine texture }
//		SetTexture [_BaseMap] { constantColor(0,0,0,0) combine texture * previous, constant }
// 	}
//	Pass { 
//		Tags { "LightMode" = "VertexLMRGBM" }
//		SetTexture [unity_Lightmap] { combine texture * texture alpha DOUBLE }
//		SetTexture [_BaseMap] { constantColor(0,0,0,0) combine texture * previous DOUBLE, constant }
// 	}
//}
/************************************************************************************************************************/
/************************************************************************************************************************/
FallBack Off
}