Shader "Custom/VertexFragment" {
	SubShader{
		Pass{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom

			// Vertex to geometry struct
			struct v2g {
				float4 position : SV_POSITION;
			};

			// Geometry to fragment struct
			struct g2f {
				float4 position : SV_POSITION;
			};

			// Vertex shader
			v2g vert(appdata_base v) {
				v2g o;
				o.position = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}

			// TODO: Geometry shader
			??? geom( ??? ) {
				???
			}

			// Geometry shader
			fixed4 frag(v2g IN) : COLOR{
				return fixed4(1.0, 0.0, 0.0, 1.0);
			}

			ENDCG
		}
	}
}
