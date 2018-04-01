// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SH_Water"
{
	Properties
	{
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 4
		_TessMin( "Tess Min Distance", Float ) = 4.4
		_TessMax( "Tess Max Distance", Float ) = 55
		_Color01("Color01", Color) = (0.2904412,0.4219574,0.5,0)
		_Smoothness("Smoothness", Range( 0 , 1)) = 1
		_Tiling01("Tiling01", Float) = 1
		_Speed01("Speed01", Float) = 1
		[Normal]_T_Normal01("T_Normal01", 2D) = "bump" {}
		_Normal011("Normal011", Range( 0 , 1)) = 0.5
		_Normal012("Normal012", Range( 0 , 1)) = 0.5
		_T_Height01("T_Height01", 2D) = "white" {}
		_Height011("Height011", Float) = 0.5
		_Height012("Height012", Float) = 0.5
		_tiling02("tiling02", Float) = 1
		_Speed02("Speed02", Float) = 1
		[Normal]_T_Normal02("T_Normal02", 2D) = "white" {}
		_Normal021("Normal021", Range( 0 , 1)) = 0.5
		_Normal022("Normal022", Range( 0 , 1)) = 0.5
		_T_Height02("T_Height02", 2D) = "white" {}
		_Height021("Height021", Float) = 0.5
		_Height022("Height022", Float) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "DisableBatching" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 5.0
		#pragma surface surf Standard keepalpha exclude_path:forward vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _T_Normal01;
		uniform float _Speed01;
		uniform float _Tiling01;
		uniform float _Normal012;
		uniform float _Normal011;
		uniform sampler2D _T_Normal02;
		uniform float _Speed02;
		uniform float _tiling02;
		uniform float _Normal022;
		uniform float _Normal021;
		uniform float4 _Color01;
		uniform float _Smoothness;
		uniform float _Height011;
		uniform sampler2D _T_Height01;
		uniform float _Height012;
		uniform float _Height021;
		uniform sampler2D _T_Height02;
		uniform float _Height022;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float mulTime96 = _Time.y * _Speed01;
			float2 uv_TexCoord160 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float2 appendResult27 = (float2(( 1.0 - uv_TexCoord160.y ) , uv_TexCoord160.x));
			float2 temp_output_147_0 = ( appendResult27 + float2( 0,0 ) );
			float2 temp_output_28_0 = ( temp_output_147_0 * _Tiling01 );
			float2 panner43 = ( temp_output_28_0 + mulTime96 * float2( -0.15,0 ));
			float2 panner94 = ( ( temp_output_28_0 * 0.7 ) + mulTime96 * float2( -0.05,0 ));
			float mulTime106 = _Time.y * _Speed02;
			float2 temp_output_104_0 = ( temp_output_147_0 * _tiling02 );
			float2 panner109 = ( temp_output_104_0 + mulTime106 * float2( -0.15,0 ));
			float2 panner108 = ( ( temp_output_104_0 * 0.7 ) + mulTime106 * float2( -0.05,0 ));
			float3 ase_vertexNormal = v.normal.xyz;
			float2 uv_TexCoord26 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float temp_output_166_0 = ( 1.0 - uv_TexCoord26.y );
			float smoothstepResult167 = smoothstep( -0.1 , 0.7 , temp_output_166_0);
			v.vertex.xyz += ( ( ( _Height011 * ( tex2Dlod( _T_Height01, float4( panner43, 0, 0) ).r + -0.5 ) ) + ( _Height012 * ( tex2Dlod( _T_Height01, float4( panner94, 0, 0) ).r + -0.5 ) ) + ( ( _Height021 * ( tex2Dlod( _T_Height02, float4( panner109, 0, 0) ).r + -0.5 ) ) + ( _Height022 * ( tex2Dlod( _T_Height02, float4( panner108, 0, 0) ).r + -0.5 ) ) ) ) * ase_vertexNormal * smoothstepResult167 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float mulTime96 = _Time.y * _Speed01;
			float2 uv_TexCoord160 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float2 appendResult27 = (float2(( 1.0 - uv_TexCoord160.y ) , uv_TexCoord160.x));
			float2 temp_output_147_0 = ( appendResult27 + float2( 0,0 ) );
			float2 temp_output_28_0 = ( temp_output_147_0 * _Tiling01 );
			float2 panner94 = ( ( temp_output_28_0 * 0.7 ) + mulTime96 * float2( -0.05,0 ));
			float3 lerpResult89 = lerp( UnpackNormal( tex2D( _T_Normal01, panner94 ) ) , float3( 0,0,1 ) , _Normal012);
			float2 panner43 = ( temp_output_28_0 + mulTime96 * float2( -0.15,0 ));
			float3 lerpResult77 = lerp( UnpackNormal( tex2D( _T_Normal01, panner43 ) ) , float3( 0,0,1 ) , _Normal011);
			float3 appendResult7_g3 = (float3(( lerpResult89.x + lerpResult77.x ) , ( lerpResult89.y + lerpResult77.y ) , ( lerpResult89.z * lerpResult77.z )));
			float mulTime106 = _Time.y * _Speed02;
			float2 temp_output_104_0 = ( temp_output_147_0 * _tiling02 );
			float2 panner108 = ( ( temp_output_104_0 * 0.7 ) + mulTime106 * float2( -0.05,0 ));
			float3 lerpResult123 = lerp( UnpackNormal( tex2D( _T_Normal02, panner108 ) ) , float3( 0,0,1 ) , _Normal022);
			float2 panner109 = ( temp_output_104_0 + mulTime106 * float2( -0.15,0 ));
			float3 lerpResult125 = lerp( UnpackNormal( tex2D( _T_Normal02, panner109 ) ) , float3( 0,0,1 ) , _Normal021);
			float3 appendResult7_g2 = (float3(( lerpResult123.x + lerpResult125.x ) , ( lerpResult123.y + lerpResult125.y ) , ( lerpResult123.z * lerpResult125.z )));
			float3 appendResult7_g4 = (float3(( appendResult7_g3.x + appendResult7_g2.x ) , ( appendResult7_g3.y + appendResult7_g2.y ) , ( appendResult7_g3.z * appendResult7_g2.z )));
			float2 uv_TexCoord26 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float temp_output_166_0 = ( 1.0 - uv_TexCoord26.y );
			float smoothstepResult167 = smoothstep( -0.1 , 0.7 , temp_output_166_0);
			float3 lerpResult157 = lerp( float3( 0,0,1 ) , appendResult7_g4 , smoothstepResult167);
			o.Normal = lerpResult157;
			o.Albedo = _Color01.rgb;
			o.Metallic = 0.0;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
1927;29;1586;824;2340.384;683.9255;2.519814;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;160;-4104.129,-1062.178;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;163;-3804.146,-1110.282;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-3596.28,-1006.91;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-3188.241,-975.9388;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2432.885,-1232.261;Float;False;Property;_tiling02;tiling02;17;0;Create;True;0;0;False;0;1;1.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-2321.59,-1343.846;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2832.403,-994.0307;Float;False;Property;_Speed02;Speed02;18;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2524.756,-842.5566;Float;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;False;0;0.7;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2347.335,-35.1887;Float;False;Property;_Tiling01;Tiling01;9;0;Create;True;0;0;False;0;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-2178.551,-140.0922;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-2380.088,-958.5909;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2800.608,211.9477;Float;False;Property;_Speed01;Speed01;10;0;Create;True;0;0;False;0;1;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;106;-2628.738,-1041.952;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2492.961,363.4215;Float;False;Constant;_Tiling;Tiling;8;0;Create;True;0;0;False;0;0.7;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;109;-2047.672,-1340.573;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.15,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;108;-2217.413,-953.0928;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.05,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-2348.293,247.3875;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;127;-2002.772,-1179.556;Float;True;Property;_T_Height02;T_Height02;22;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleTimeNode;96;-2596.943,164.0264;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;110;-1606.753,-1562.581;Float;True;Property;_TextureSample2;Texture Sample 2;27;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;84;-1972.611,214.4473;Float;True;Property;_T_Normal01;T_Normal01;11;1;[Normal];Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;c6d1d22ad2eaf8843afc043435e6125a;True;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;43;-2015.877,-134.5942;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.15,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;111;-1588.632,-1071.427;Float;True;Property;_TextureSample3;Texture Sample 3;28;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;83;-1970.977,26.4227;Float;True;Property;_T_Height01;T_Height01;14;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;128;-2004.406,-991.5313;Float;True;Property;_T_Normal02;T_Normal02;19;1;[Normal];Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;b653e83659aca6b49ad60d31185c12ca;True;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;94;-2185.618,252.8855;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.05,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;78;-1556.837,134.552;Float;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-1215.531,-1022.997;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;38;-1574.958,-356.6023;Float;True;Property;_T_Water_height;T_Water_height;14;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;121;-1597.911,-1366.82;Float;True;Property;_TextureSample5;Texture Sample 5;11;0;Create;True;0;0;False;0;c6d1d22ad2eaf8843afc043435e6125a;c6d1d22ad2eaf8843afc043435e6125a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;120;-1579.615,-668.314;Float;False;Property;_Normal022;Normal022;21;0;Create;True;0;0;False;0;0.5;0.44;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-1565.044,-1157.376;Float;False;Property;_Normal021;Normal021;20;0;Create;True;0;0;False;0;0.5;0.421;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1566.116,-160.8413;Float;True;Property;_T_Water_normal;T_Water_normal;11;0;Create;True;0;0;False;0;c6d1d22ad2eaf8843afc043435e6125a;c6d1d22ad2eaf8843afc043435e6125a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;115;-1237.712,-1096.894;Float;False;Property;_Height022;Height022;24;0;Create;True;0;0;False;0;0.5;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;79;-1561.075,323.7728;Float;True;Property;_TextureSample1;Texture Sample 1;12;0;Create;True;0;0;False;0;c6d1d22ad2eaf8843afc043435e6125a;c6d1d22ad2eaf8843afc043435e6125a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;88;-1547.82,537.6642;Float;False;Property;_Normal012;Normal012;13;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1533.249,48.60275;Float;False;Property;_Normal011;Normal011;12;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-1303.334,-1647.03;Float;False;Property;_Height021;Height021;23;0;Create;True;0;0;False;0;0.5;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-1277.638,-1578.407;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;118;-1592.87,-882.2053;Float;True;Property;_TextureSample4;Texture Sample 4;12;0;Create;True;0;0;False;0;c6d1d22ad2eaf8843afc043435e6125a;c6d1d22ad2eaf8843afc043435e6125a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-1183.736,182.9815;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-1068.408,-1613.558;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;77;-1213.969,-163.2374;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1271.539,-441.051;Float;False;Property;_Height011;Height011;15;0;Create;True;0;0;False;0;0.5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1169.996,653.1611;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-1023.883,-1052.873;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;123;-1204.755,-797.9811;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-1205.917,109.0846;Float;False;Property;_Height012;Height012;16;0;Create;True;0;0;False;0;0.5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-1245.843,-372.4288;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;125;-1245.764,-1369.216;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;89;-1172.96,407.997;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-992.0881,153.1052;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1036.613,-407.5798;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;166;-792.2458,645.165;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;126;-739.2567,-1064.397;Float;False;MF_NormalCombine;-1;;2;08fe38fa7a5b79541bb55f178ddc7eb4;0;2;4;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;-748.1617,-1221.807;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;75;-707.4626,141.5812;Float;False;MF_NormalCombine;-1;;3;08fe38fa7a5b79541bb55f178ddc7eb4;0;2;4;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;165;-675.4423,-243.6723;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;129;-412.3904,31.0703;Float;False;MF_NormalCombine;-1;;4;08fe38fa7a5b79541bb55f178ddc7eb4;0;2;4;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-716.3676,-15.82865;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;167;-605.0457,611.1436;Float;False;3;0;FLOAT;0;False;1;FLOAT;-0.1;False;2;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;169;-602.6442,971.4003;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;172;-79.75552,989.2462;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;168;-864.9816,1033.861;Float;False;Constant;_Vector0;Vector 0;21;0;Create;True;0;0;False;0;12.54158,79.156;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SmoothstepOpNode;176;-220.7395,805.4318;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.19;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;175;-315.3235,1151.646;Float;False;Constant;_Opacity;Opacity;22;0;Create;True;0;0;False;0;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;173;-888.1808,819.7087;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.01,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;170;-399.1993,996.3846;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;171;-276.0618,1007.092;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;41825.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-278.1755,468.4393;Float;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;134.3967,1028.508;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-229.1755,384.4392;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;157;-188.7961,151.1331;Float;False;3;0;FLOAT3;0,0,1;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-341.2642,-165.8449;Float;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1;-437.0303,-683.5993;Float;False;Property;_Color01;Color01;6;0;Create;True;0;0;False;0;0.2904412,0.4219574,0.5,0;0.1470588,0.1903651,0.25,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;148;-447.9542,-493.2879;Float;False;Property;_Color02;Color02;7;0;Create;True;0;0;False;0;0.2904412,0.4219574,0.5,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;237.9029,-5.576482;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Custom/SH_Water;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;0;False;0;Masked;0.5;True;False;0;False;TransparentCutout;;AlphaTest;DeferredOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;4;4.4;55;False;1;True;0;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;5;-1;-1;0;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;163;0;160;2
WireConnection;27;0;163;0
WireConnection;27;1;160;1
WireConnection;147;0;27;0
WireConnection;104;0;147;0
WireConnection;104;1;102;0
WireConnection;28;0;147;0
WireConnection;28;1;29;0
WireConnection;107;0;104;0
WireConnection;107;1;105;0
WireConnection;106;0;103;0
WireConnection;109;0;104;0
WireConnection;109;1;106;0
WireConnection;108;0;107;0
WireConnection;108;1;106;0
WireConnection;93;0;28;0
WireConnection;93;1;92;0
WireConnection;96;0;95;0
WireConnection;110;0;127;0
WireConnection;110;1;109;0
WireConnection;43;0;28;0
WireConnection;43;1;96;0
WireConnection;111;0;127;0
WireConnection;111;1;108;0
WireConnection;94;0;93;0
WireConnection;94;1;96;0
WireConnection;78;0;83;0
WireConnection;78;1;94;0
WireConnection;112;0;111;1
WireConnection;38;0;83;0
WireConnection;38;1;43;0
WireConnection;121;0;128;0
WireConnection;121;1;109;0
WireConnection;32;0;84;0
WireConnection;32;1;43;0
WireConnection;79;0;84;0
WireConnection;79;1;94;0
WireConnection;113;0;110;1
WireConnection;118;0;128;0
WireConnection;118;1;108;0
WireConnection;86;0;78;1
WireConnection;119;0;114;0
WireConnection;119;1;113;0
WireConnection;77;0;32;0
WireConnection;77;2;36;0
WireConnection;117;0;115;0
WireConnection;117;1;112;0
WireConnection;123;0;118;0
WireConnection;123;2;120;0
WireConnection;57;0;38;1
WireConnection;125;0;121;0
WireConnection;125;2;116;0
WireConnection;89;0;79;0
WireConnection;89;2;88;0
WireConnection;87;0;90;0
WireConnection;87;1;86;0
WireConnection;56;0;42;0
WireConnection;56;1;57;0
WireConnection;166;0;26;2
WireConnection;126;4;125;0
WireConnection;126;1;123;0
WireConnection;122;0;119;0
WireConnection;122;1;117;0
WireConnection;75;4;77;0
WireConnection;75;1;89;0
WireConnection;129;4;126;0
WireConnection;129;1;75;0
WireConnection;91;0;56;0
WireConnection;91;1;87;0
WireConnection;91;2;122;0
WireConnection;167;0;166;0
WireConnection;169;0;173;0
WireConnection;169;1;168;0
WireConnection;172;0;171;0
WireConnection;176;0;166;0
WireConnection;173;0;26;0
WireConnection;170;0;169;0
WireConnection;171;0;170;0
WireConnection;174;0;172;0
WireConnection;174;1;176;0
WireConnection;174;2;175;0
WireConnection;157;1;129;0
WireConnection;157;2;167;0
WireConnection;39;0;91;0
WireConnection;39;1;165;0
WireConnection;39;2;167;0
WireConnection;0;0;1;0
WireConnection;0;1;157;0
WireConnection;0;3;4;0
WireConnection;0;4;2;0
WireConnection;0;11;39;0
ASEEND*/
//CHKSM=F62A595FC8553792E201F8D643A7B8DA25EE6B9F