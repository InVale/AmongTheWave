// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/SH_Water"
{
	Properties
	{
		_TessValue( "Max Tessellation", Range( 1, 32 ) ) = 4
		_TessMin( "Tess Min Distance", Float ) = 1
		_TessMax( "Tess Max Distance", Float ) = 40
		_Cutoff( "Mask Clip Value", Float ) = 0.5
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
		[Toggle(_BORDEROPACITY_ON)] _BorderOpacity("BorderOpacity", Float) = 0
		_Height021("Height021", Float) = 0.5
		_Height022("Height022", Float) = 0.5
		_Noise_int("Noise_int", Float) = 0.5
		_Tiling_Noise("Tiling_Noise", Float) = 0.01
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "DisableBatching" = "True" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 5.0
		#pragma shader_feature _BORDEROPACITY_ON
		#pragma surface surf Standard keepalpha exclude_path:forward vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform sampler2D _T_Normal01;
		uniform float _Speed01;
		uniform float _Tiling_Noise;
		uniform float _Noise_int;
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
		uniform float _Cutoff = 0.5;
		uniform float _TessValue;
		uniform float _TessMin;
		uniform float _TessMax;


		float3 mod3D289( float3 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 mod3D289( float4 x ) { return x - floor( x / 289.0 ) * 289.0; }

		float4 permute( float4 x ) { return mod3D289( ( x * 34.0 + 1.0 ) * x ); }

		float4 taylorInvSqrt( float4 r ) { return 1.79284291400159 - r * 0.85373472095314; }

		float snoise( float3 v )
		{
			const float2 C = float2( 1.0 / 6.0, 1.0 / 3.0 );
			float3 i = floor( v + dot( v, C.yyy ) );
			float3 x0 = v - i + dot( i, C.xxx );
			float3 g = step( x0.yzx, x0.xyz );
			float3 l = 1.0 - g;
			float3 i1 = min( g.xyz, l.zxy );
			float3 i2 = max( g.xyz, l.zxy );
			float3 x1 = x0 - i1 + C.xxx;
			float3 x2 = x0 - i2 + C.yyy;
			float3 x3 = x0 - 0.5;
			i = mod3D289( i);
			float4 p = permute( permute( permute( i.z + float4( 0.0, i1.z, i2.z, 1.0 ) ) + i.y + float4( 0.0, i1.y, i2.y, 1.0 ) ) + i.x + float4( 0.0, i1.x, i2.x, 1.0 ) );
			float4 j = p - 49.0 * floor( p / 49.0 );  // mod(p,7*7)
			float4 x_ = floor( j / 7.0 );
			float4 y_ = floor( j - 7.0 * x_ );  // mod(j,N)
			float4 x = ( x_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 y = ( y_ * 2.0 + 0.5 ) / 7.0 - 1.0;
			float4 h = 1.0 - abs( x ) - abs( y );
			float4 b0 = float4( x.xy, y.xy );
			float4 b1 = float4( x.zw, y.zw );
			float4 s0 = floor( b0 ) * 2.0 + 1.0;
			float4 s1 = floor( b1 ) * 2.0 + 1.0;
			float4 sh = -step( h, 0.0 );
			float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
			float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
			float3 g0 = float3( a0.xy, h.x );
			float3 g1 = float3( a0.zw, h.y );
			float3 g2 = float3( a1.xy, h.z );
			float3 g3 = float3( a1.zw, h.w );
			float4 norm = taylorInvSqrt( float4( dot( g0, g0 ), dot( g1, g1 ), dot( g2, g2 ), dot( g3, g3 ) ) );
			g0 *= norm.x;
			g1 *= norm.y;
			g2 *= norm.z;
			g3 *= norm.w;
			float4 m = max( 0.6 - float4( dot( x0, x0 ), dot( x1, x1 ), dot( x2, x2 ), dot( x3, x3 ) ), 0.0 );
			m = m* m;
			m = m* m;
			float4 px = float4( dot( x0, g0 ), dot( x1, g1 ), dot( x2, g2 ), dot( x3, g3 ) );
			return 42.0 * dot( m, px);
		}


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityDistanceBasedTess( v0.vertex, v1.vertex, v2.vertex, _TessMin, _TessMax, _TessValue );
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float mulTime96 = _Time.y * _Speed01;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult27 = (float2(ase_worldPos.z , ( 1.0 - ase_worldPos.x )));
			float2 temp_output_131_0 = ( appendResult27 * _Tiling_Noise );
			float mulTime134 = _Time.y * 0.1;
			float3 appendResult133 = (float3(temp_output_131_0 , mulTime134));
			float simplePerlin3D130 = snoise( appendResult133 );
			float simplePerlin3D136 = snoise( float3( ( ( ( temp_output_131_0 * 2.0 ) + ( simplePerlin3D130 * 1 ) ) + ( mulTime134 * 5 ) ) ,  0.0 ) );
			float smoothstepResult152 = smoothstep( 0 , 1 , ( simplePerlin3D136 * _Noise_int ));
			float2 temp_output_147_0 = ( smoothstepResult152 + appendResult27 );
			float2 temp_output_28_0 = ( temp_output_147_0 * _Tiling01 );
			float2 panner43 = ( temp_output_28_0 + mulTime96 * float2( -0.15,0 ));
			float2 panner94 = ( ( temp_output_28_0 * 0.7 ) + mulTime96 * float2( -0.05,0 ));
			float mulTime106 = _Time.y * _Speed02;
			float2 temp_output_104_0 = ( temp_output_147_0 * _tiling02 );
			float2 panner109 = ( temp_output_104_0 + mulTime106 * float2( -0.15,0 ));
			float2 panner108 = ( ( temp_output_104_0 * 0.7 ) + mulTime106 * float2( -0.05,0 ));
			float2 uv_TexCoord26 = v.texcoord.xy * float2( 1,1 ) + float2( 0,0 );
			float smoothstepResult159 = smoothstep( -0.2 , 1 , sin( ( uv_TexCoord26.x * UNITY_PI ) ));
			v.vertex.xyz += ( ( ( _Height011 * ( tex2Dlod( _T_Height01, float4( panner43, 0, 0) ).r + -0.5 ) ) + ( _Height012 * ( tex2Dlod( _T_Height01, float4( panner94, 0, 0) ).r + -0.5 ) ) + ( ( _Height021 * ( tex2Dlod( _T_Height02, float4( panner109, 0, 0) ).r + -0.5 ) ) + ( _Height022 * ( tex2Dlod( _T_Height02, float4( panner108, 0, 0) ).r + -0.5 ) ) ) ) * float3(0,1,0) * smoothstepResult159 );
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float mulTime96 = _Time.y * _Speed01;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult27 = (float2(ase_worldPos.z , ( 1.0 - ase_worldPos.x )));
			float2 temp_output_131_0 = ( appendResult27 * _Tiling_Noise );
			float mulTime134 = _Time.y * 0.1;
			float3 appendResult133 = (float3(temp_output_131_0 , mulTime134));
			float simplePerlin3D130 = snoise( appendResult133 );
			float simplePerlin3D136 = snoise( float3( ( ( ( temp_output_131_0 * 2.0 ) + ( simplePerlin3D130 * 1 ) ) + ( mulTime134 * 5 ) ) ,  0.0 ) );
			float smoothstepResult152 = smoothstep( 0 , 1 , ( simplePerlin3D136 * _Noise_int ));
			float2 temp_output_147_0 = ( smoothstepResult152 + appendResult27 );
			float2 temp_output_28_0 = ( temp_output_147_0 * _Tiling01 );
			float2 panner94 = ( ( temp_output_28_0 * 0.7 ) + mulTime96 * float2( -0.05,0 ));
			float3 lerpResult89 = lerp( UnpackNormal( tex2D( _T_Normal01, panner94 ) ) , float3( 0,0,1 ) , _Normal012);
			float2 panner43 = ( temp_output_28_0 + mulTime96 * float2( -0.15,0 ));
			float3 lerpResult77 = lerp( UnpackNormal( tex2D( _T_Normal01, panner43 ) ) , float3( 0,0,1 ) , _Normal011);
			float3 appendResult7_g1 = (float3(( lerpResult89.x + lerpResult77.x ) , ( lerpResult89.y + lerpResult77.y ) , ( lerpResult89.z * lerpResult77.z )));
			float mulTime106 = _Time.y * _Speed02;
			float2 temp_output_104_0 = ( temp_output_147_0 * _tiling02 );
			float2 panner108 = ( ( temp_output_104_0 * 0.7 ) + mulTime106 * float2( -0.05,0 ));
			float3 lerpResult123 = lerp( UnpackNormal( tex2D( _T_Normal02, panner108 ) ) , float3( 0,0,1 ) , _Normal022);
			float2 panner109 = ( temp_output_104_0 + mulTime106 * float2( -0.15,0 ));
			float3 lerpResult125 = lerp( UnpackNormal( tex2D( _T_Normal02, panner109 ) ) , float3( 0,0,1 ) , _Normal021);
			float3 appendResult7_g2 = (float3(( lerpResult123.x + lerpResult125.x ) , ( lerpResult123.y + lerpResult125.y ) , ( lerpResult123.z * lerpResult125.z )));
			float3 appendResult7_g3 = (float3(( appendResult7_g1.x + appendResult7_g2.x ) , ( appendResult7_g1.y + appendResult7_g2.y ) , ( appendResult7_g1.z * appendResult7_g2.z )));
			float2 uv_TexCoord26 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float smoothstepResult159 = smoothstep( -0.2 , 1 , sin( ( uv_TexCoord26.x * UNITY_PI ) ));
			float3 lerpResult157 = lerp( float3( 0,0,1 ) , appendResult7_g3 , smoothstepResult159);
			o.Normal = lerpResult157;
			o.Albedo = _Color01.rgb;
			o.Metallic = 0.0;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
			float2 panner161 = ( uv_TexCoord26 + 1 * _Time.y * float2( 0.01,0 ));
			float dotResult163 = dot( panner161 , float2( 12.54158,79.156 ) );
			float smoothstepResult169 = smoothstep( 0.3 , 0.7 , uv_TexCoord26.y);
			#ifdef _BORDEROPACITY_ON
				float staticSwitch172 = ( frac( ( sin( dotResult163 ) * 41825.25 ) ) + smoothstepResult169 + -0.5 );
			#else
				float staticSwitch172 = (float)1;
			#endif
			clip( staticSwitch172 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15001
1919;51;1586;824;1623.134;-131.0245;1.607103;True;True
Node;AmplifyShaderEditor.WorldPosInputsNode;25;-5720.758,-782.6514;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;34;-5485.559,-769.2294;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;27;-5265.325,-752.865;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;132;-5086.861,-1162.94;Float;False;Property;_Tiling_Noise;Tiling_Noise;27;0;Create;True;0;0;False;0;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;134;-4715.828,-985.3602;Float;False;1;0;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;131;-4785.106,-1225.707;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;133;-4538.441,-1138.097;Float;False;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;130;-4344.007,-1077.13;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;141;-4434.763,-1268.337;Float;False;Constant;_Float1;Float 1;23;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;137;-4102.178,-1115.724;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-4264.871,-1222.265;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;138;-3946.687,-1253.939;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;144;-4273.509,-908.4;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;140;-3775.681,-1163.682;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;146;-3650.429,-1041.785;Float;False;Property;_Noise_int;Noise_int;26;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;136;-3637.151,-1164.802;Float;False;Simplex3D;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;145;-3430.791,-1065.566;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;152;-3281.664,-1125.71;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;147;-3188.241,-975.9388;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-2432.885,-1232.261;Float;False;Property;_tiling02;tiling02;17;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2832.403,-994.0307;Float;False;Property;_Speed02;Speed02;18;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2347.335,-35.1887;Float;False;Property;_Tiling01;Tiling01;9;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-2321.59,-1343.846;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2524.756,-842.5566;Float;False;Constant;_Float4;Float 4;8;0;Create;True;0;0;False;0;0.7;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-2492.961,363.4215;Float;False;Constant;_Tiling;Tiling;8;0;Create;True;0;0;False;0;0.7;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2800.608,211.9477;Float;False;Property;_Speed01;Speed01;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;-2380.088,-958.5909;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-2178.551,-140.0922;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;106;-2628.738,-1041.952;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;26;-1225.175,635.5268;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;127;-2002.772,-1179.556;Float;True;Property;_T_Height02;T_Height02;22;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;109;-2047.672,-1340.573;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.15,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-2348.293,247.3875;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;108;-2217.413,-953.0928;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.05,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;96;-2596.943,164.0264;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;162;-1126.255,1200.191;Float;False;Constant;_Vector1;Vector 1;21;0;Create;True;0;0;False;0;12.54158,79.156;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;161;-1149.455,986.0389;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.01,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;111;-1588.632,-1071.427;Float;True;Property;_TextureSample3;Texture Sample 3;28;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;94;-2185.618,252.8855;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.05,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;84;-1972.611,214.4473;Float;True;Property;_T_Normal01;T_Normal01;11;1;[Normal];Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;False;bump;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexturePropertyNode;128;-2004.406,-991.5313;Float;True;Property;_T_Normal02;T_Normal02;19;1;[Normal];Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;43;-2015.877,-134.5942;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.15,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;83;-1970.977,26.4227;Float;True;Property;_T_Height01;T_Height01;14;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;False;white;Auto;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;110;-1606.753,-1562.581;Float;True;Property;_TextureSample2;Texture Sample 2;27;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;163;-863.9182,1137.73;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;38;-1574.958,-356.6023;Float;True;Property;_T_Water_height;T_Water_height;14;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;115;-1237.712,-1096.894;Float;False;Property;_Height022;Height022;25;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;114;-1303.334,-1647.03;Float;False;Property;_Height021;Height021;24;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;113;-1277.638,-1578.407;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;112;-1215.531,-1022.997;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;78;-1556.837,134.552;Float;True;Property;_TextureSample0;Texture Sample 0;13;0;Create;True;0;0;False;0;5e41970cf49aaa144bc9db7003e6288e;5e41970cf49aaa144bc9db7003e6288e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;118;-1592.87,-882.2053;Float;True;Property;_TextureSample4;Texture Sample 4;12;0;Create;True;0;0;False;0;c6d1d22ad2eaf8843afc043435e6125a;c6d1d22ad2eaf8843afc043435e6125a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;88;-1547.82,537.6642;Float;False;Property;_Normal012;Normal012;13;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;81;-1171.905,770.3901;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;-1566.116,-160.8413;Float;True;Property;_T_Water_normal;T_Water_normal;11;0;Create;True;0;0;False;0;c6d1d22ad2eaf8843afc043435e6125a;c6d1d22ad2eaf8843afc043435e6125a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;-1533.249,48.60275;Float;False;Property;_Normal011;Normal011;12;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-1565.044,-1157.376;Float;False;Property;_Normal021;Normal021;20;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;79;-1561.075,323.7728;Float;True;Property;_TextureSample1;Texture Sample 1;12;0;Create;True;0;0;False;0;c6d1d22ad2eaf8843afc043435e6125a;c6d1d22ad2eaf8843afc043435e6125a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;120;-1579.615,-668.314;Float;False;Property;_Normal022;Normal022;21;0;Create;True;0;0;False;0;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;121;-1597.911,-1366.82;Float;True;Property;_TextureSample5;Texture Sample 5;11;0;Create;True;0;0;False;0;c6d1d22ad2eaf8843afc043435e6125a;c6d1d22ad2eaf8843afc043435e6125a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;164;-660.4733,1162.714;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;89;-1172.96,407.997;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-1205.917,109.0846;Float;False;Property;_Height012;Height012;16;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-1183.736,182.9815;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1271.539,-441.051;Float;False;Property;_Height011;Height011;15;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;125;-1245.764,-1369.216;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-1023.883,-1052.873;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;80;-933.1949,691.9111;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;123;-1204.755,-797.9811;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;57;-1245.843,-372.4288;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;-0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-1068.408,-1613.558;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;77;-1213.969,-163.2374;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;165;-537.3358,1173.422;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;41825.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-992.0881,153.1052;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;122;-748.1617,-1221.807;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;82;-786.0449,695.181;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-1036.613,-407.5798;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;75;-707.4626,141.5812;Float;False;MF_NormalCombine;-1;;1;08fe38fa7a5b79541bb55f178ddc7eb4;0;2;4;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;126;-739.2567,-1064.397;Float;False;MF_NormalCombine;-1;;2;08fe38fa7a5b79541bb55f178ddc7eb4;0;2;4;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;167;-341.0294,1155.576;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;170;-460.3792,1438.843;Float;False;Constant;_Float2;Float 2;22;0;Create;True;0;0;False;0;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;169;-482.0134,971.762;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;0.7;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;156;-676.998,-194.4397;Float;False;Constant;_Vector0;Vector 0;25;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SmoothstepOpNode;159;-608.5729,675.1263;Float;False;3;0;FLOAT;0;False;1;FLOAT;-0.2;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-716.3676,-15.82865;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;173;-144.5986,876.7204;Float;False;Constant;_Int0;Int 0;24;0;Create;True;0;0;False;0;1;0;0;1;INT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;171;-126.8772,1194.838;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;129;-412.3904,31.0703;Float;False;MF_NormalCombine;-1;;3;08fe38fa7a5b79541bb55f178ddc7eb4;0;2;4;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;148;-447.9542,-493.2879;Float;False;Property;_Color02;Color02;7;0;Create;True;0;0;False;0;0.2904412,0.4219574,0.5,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;157;-188.7961,151.1331;Float;False;3;0;FLOAT3;0,0,1;False;1;FLOAT3;0,0,1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;1;-437.0303,-683.5993;Float;False;Property;_Color01;Color01;6;0;Create;True;0;0;False;0;0.2904412,0.4219574,0.5,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-341.2642,-165.8449;Float;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;172;82.00295,862.2565;Float;False;Property;_BorderOpacity;BorderOpacity;23;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-229.1755,384.4392;Float;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-278.1755,468.4393;Float;False;Property;_Smoothness;Smoothness;8;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;125.4728,-2.007274;Float;False;True;7;Float;ASEMaterialInspector;0;0;Standard;Custom/SH_Water;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Masked;0.5;True;False;0;False;TransparentCutout;;AlphaTest;DeferredOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;0;4;1;40;False;0.5;True;0;SrcAlpha;OneMinusSrcAlpha;0;Zero;Zero;OFF;OFF;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;5;-1;-1;0;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;34;0;25;1
WireConnection;27;0;25;3
WireConnection;27;1;34;0
WireConnection;131;0;27;0
WireConnection;131;1;132;0
WireConnection;133;0;131;0
WireConnection;133;2;134;0
WireConnection;130;0;133;0
WireConnection;137;0;130;0
WireConnection;139;0;131;0
WireConnection;139;1;141;0
WireConnection;138;0;139;0
WireConnection;138;1;137;0
WireConnection;144;0;134;0
WireConnection;140;0;138;0
WireConnection;140;1;144;0
WireConnection;136;0;140;0
WireConnection;145;0;136;0
WireConnection;145;1;146;0
WireConnection;152;0;145;0
WireConnection;147;0;152;0
WireConnection;147;1;27;0
WireConnection;104;0;147;0
WireConnection;104;1;102;0
WireConnection;107;0;104;0
WireConnection;107;1;105;0
WireConnection;28;0;147;0
WireConnection;28;1;29;0
WireConnection;106;0;103;0
WireConnection;109;0;104;0
WireConnection;109;1;106;0
WireConnection;93;0;28;0
WireConnection;93;1;92;0
WireConnection;108;0;107;0
WireConnection;108;1;106;0
WireConnection;96;0;95;0
WireConnection;161;0;26;0
WireConnection;111;0;127;0
WireConnection;111;1;108;0
WireConnection;94;0;93;0
WireConnection;94;1;96;0
WireConnection;43;0;28;0
WireConnection;43;1;96;0
WireConnection;110;0;127;0
WireConnection;110;1;109;0
WireConnection;163;0;161;0
WireConnection;163;1;162;0
WireConnection;38;0;83;0
WireConnection;38;1;43;0
WireConnection;113;0;110;1
WireConnection;112;0;111;1
WireConnection;78;0;83;0
WireConnection;78;1;94;0
WireConnection;118;0;128;0
WireConnection;118;1;108;0
WireConnection;32;0;84;0
WireConnection;32;1;43;0
WireConnection;79;0;84;0
WireConnection;79;1;94;0
WireConnection;121;0;128;0
WireConnection;121;1;109;0
WireConnection;164;0;163;0
WireConnection;89;0;79;0
WireConnection;89;2;88;0
WireConnection;86;0;78;1
WireConnection;125;0;121;0
WireConnection;125;2;116;0
WireConnection;117;0;115;0
WireConnection;117;1;112;0
WireConnection;80;0;26;1
WireConnection;80;1;81;0
WireConnection;123;0;118;0
WireConnection;123;2;120;0
WireConnection;57;0;38;1
WireConnection;119;0;114;0
WireConnection;119;1;113;0
WireConnection;77;0;32;0
WireConnection;77;2;36;0
WireConnection;165;0;164;0
WireConnection;87;0;90;0
WireConnection;87;1;86;0
WireConnection;122;0;119;0
WireConnection;122;1;117;0
WireConnection;82;0;80;0
WireConnection;56;0;42;0
WireConnection;56;1;57;0
WireConnection;75;4;77;0
WireConnection;75;1;89;0
WireConnection;126;4;125;0
WireConnection;126;1;123;0
WireConnection;167;0;165;0
WireConnection;169;0;26;2
WireConnection;159;0;82;0
WireConnection;91;0;56;0
WireConnection;91;1;87;0
WireConnection;91;2;122;0
WireConnection;171;0;167;0
WireConnection;171;1;169;0
WireConnection;171;2;170;0
WireConnection;129;4;126;0
WireConnection;129;1;75;0
WireConnection;157;1;129;0
WireConnection;157;2;159;0
WireConnection;39;0;91;0
WireConnection;39;1;156;0
WireConnection;39;2;159;0
WireConnection;172;1;173;0
WireConnection;172;0;171;0
WireConnection;0;0;1;0
WireConnection;0;1;157;0
WireConnection;0;3;4;0
WireConnection;0;4;2;0
WireConnection;0;10;172;0
WireConnection;0;11;39;0
ASEEND*/
//CHKSM=1DF1B5AD1918B45C02968C704188DCD8B8F8F008