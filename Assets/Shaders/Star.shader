Shader "Unlit/Star"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            #define PI 3.1415926535898

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _SideLength;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float2 cartesian_to_polar(float x, float y) {
                float r = sqrt(x * x + y * y);
                float theta = atan2(y, x);

                return float2(r, theta);
            }

            float2 polar_to_cartesian(float r, float theta) {
                float x = r * cos(theta);
                float y = r * sin(theta);

                return float2(x, y);
            }

            float2 polar_multiplication(float r0, float theta0, float r1, float theta1) {
                float new_r = r0 * r1;
                float new_theta = theta0 + theta1;

                return float2(new_r, new_theta);
            }

            float2 Rotate(float2 polarP0, float2 polarP1) {
                float2 newPolarP = polar_multiplication(polarP0.x, polarP0.y, polarP1.x, polarP1.y);
                float2 newCartesianP = polar_to_cartesian(newPolarP.x, newPolarP.y);

                return newCartesianP;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv += 0.3 * float2(cos(_Time.y), sin(_Time.y));
                i.uv *= ((_Time.y * 1000) % 10000) / 1000;
                i.uv = frac(i.uv);

                i.uv = i.uv * 2 - 1;
                float theta = atan2(i.uv.y, i.uv.x);
                float b = 0.5;
                float a = 0.3;
                float d = a * pow(abs(sin(theta * 5 / 2 - _Time.y * 5)), 2) + b;
                //float a = atan2(i.uv.y, i.uv.x) + ;
                //float d = abs(sin(a * 2 - _Time.y * 2)) * 0.3 + abs(sin(a * 5 - _Time.y * 3)) * 0.1 + abs(sin(a * 7 - _Time.y * 7)) * 0.2;
                //float d = abs(sin(a - _Time.y * 2)) * abs(sin(a * 5 - _Time.y * 3)) * abs(sin(a * 9 - _Time.y * 7)) * 0.5;
                float r = length(i.uv);
                
                d = step(r, d);

                return float4(d, d, 0, 1);
            }
            ENDCG
        }
    }
}
