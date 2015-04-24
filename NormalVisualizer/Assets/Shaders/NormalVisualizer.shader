Shader "Custom/NormalVisualizer" {
	Properties {
		_NormalColor("Normal color", Color) = (0, 0, 0, 1)
		_FrontFacingColor("Front facing color", Color) = (0, 1, 0, 1)
		_BackFacingColor("Back facing color", Color) = (1, 0, 0, 1)
		_NormalLength("Normal length", Range(0, 1)) = 0.3
		_NormalWidth("Normal width", Range(0, 1)) = 0.3
	}

	CGINCLUDE
	#include "UnityCG.cginc"
	
	fixed4 _NormalColor;
	fixed4 _FrontFacingColor;
	fixed4 _BackFacingColor;
	float _NormalLength;
	float _NormalWidth;

	static const float4 POSITION_LIGHT = float4(-100, 100, 100, 1);

	struct v2f {
		float4 pos : SV_POSITION;
		float4 color : COLOR;
	};

	v2f vert_shaded(appdata_base v, float4 color) {
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		
		// Crude, pr. vertex lighting
		float4 light_modelSpace = mul(_World2Object, POSITION_LIGHT);
		half3 lightDir = normalize(light_modelSpace - o.pos.xyz);
		o.color = color* 0.7 + 0.3 * color * dot(v.normal, lightDir);
		return o;
	}
	
	v2f vert_front(appdata_base v) {
		return vert_shaded(v, _FrontFacingColor);
	}
	
	v2f vert_back(appdata_base v) {
		return vert_shaded(v, _BackFacingColor);
	}

	float4 frag(v2f IN) : COLOR{
		half4 c = IN.color;

		return c;
	}
	ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		 
		// Render all back facing triangles first.
		Pass{
			Cull front
			CGPROGRAM
			#pragma vertex vert_back
			#pragma fragment frag
			#include "UnityCG.cginc"

			ENDCG
		}

		// Then all front facing on top.
		Pass{
			Cull back
			CGPROGRAM
			#pragma vertex vert_front
			#pragma fragment frag
			#include "UnityCG.cginc"

			ENDCG
		}

		// Finally we render the normals
		Pass{
			Cull off

			CGPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#include "UnityCG.cginc"
						
			// In clip space, the vector (0,0,1) is perpendicular to the x,y-plane
			static const float3 perpToScreen_clipSpace = float3(0, 0, 1);
			static const float widthScaleFactor = 0.04;

			// Vertex to geometry struct
			struct v2g {
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
			};
			
			// Geometry to fragment struct 
			struct g2f {	
				float4 pos : SV_POSITION;
			};	

			// Vertex shader
			struct v2g vert(appdata_base v) {
				v2g o;
				o.pos = v.vertex;
				o.normal = v.normal;
				return o;
			};

			// Geometry shader
			[maxvertexcount(12)]
			void geom(triangle v2g verts[3], inout TriangleStream<g2f> triStream) {

				float width = _NormalWidth * widthScaleFactor;
				// Output
				g2f r1;
				g2f r2;
				g2f r3;
				g2f r4;

				for(int i=0; i < 3; i++) {
				
					// model space
					float4 start = verts[i].pos;
					float4 normal = float4(verts[i].normal.xyz,0); // Set w=0 to transform a direction, not a point.
					// clip space (-1 to 1)
					start = mul( UNITY_MATRIX_MVP, start);
					normal = normalize(mul(UNITY_MATRIX_MVP, normal)) * _NormalLength;
					float4 end = start+normal;
					
					// Here we build a vector which is perpendicular to the normal after it has been projected
					// to the xy-screen plane. By shifting the start and end position by 0.5 of the line width vector, 
					// we output a plane (2 triangles as 4 vertices in triangle strip) lying in the xy-screen plane, 
					// with a width of length(lineWidth)
					float4 billboardWidth_half = float4(normalize(cross(perpToScreen_clipSpace, start - end)), 0) * width * 0.5;
					
					// Create the vertices
					r1.pos = start + billboardWidth_half;
					r2.pos = start - billboardWidth_half;
					r3.pos = end + billboardWidth_half;
					r4.pos = end - billboardWidth_half;

					// Write to output stream
					triStream.Append(r1);
					triStream.Append(r3);
					triStream.Append(r2);
					triStream.Append(r4);
					// Since a normal is totally autonomous and should not be connected to any other geometry, the
					// triangle strip is restarted after each normal.
					triStream.RestartStrip();
				}
			}

			// Fragment shader
			float4 frag(g2f IN) : COLOR{
				half4 c = _NormalColor;
				return c;
			}
			
			ENDCG
		}

	} 
	
}
