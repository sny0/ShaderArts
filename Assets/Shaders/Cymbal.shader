Shader "Unlit/Cymbal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _xFactor("X Factor", Integer) = 1
        _yFactor("Y Factor", Integer) = 1
        _Repetitions("Repetitions", Range(1, 10)) = 1
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

            int _xFactor;
            int _yFactor;
            int _Repetitions;


            v2f vert (appdata v)
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
                i.uv = i.uv * 2 - 1;
                float2 prePolarP2 = cartesian_to_polar(i.uv.x, i.uv.y);
                float2 prePolarP3 = float2(1, -1 * _Time.y * 2);
                i.uv = Rotate(prePolarP2, prePolarP3);
                float dx = sin(_xFactor * i.uv.y - _Time.y * 3);
                float dy = sin(_yFactor * i.uv.x - _Time.y * 3);

                i.uv.x += 0.5 * dx;
                i.uv.y += 0.5 * dy;
                i.uv *= _Repetitions;
                i.uv = frac(i.uv);

                float2 prePolarP0 = cartesian_to_polar(i.uv.x, i.uv.y);
                float2 prePolarP1 = float2(1, -1 * _Time.y * 2);

                i.uv = Rotate(prePolarP0, prePolarP1);

                float d = length(i.uv);

                float s = step(abs(sin(d * 20)), 0.95) * (0.5 * abs(sin(d * 10)) + 0.5);

                float theta = atan2(i.uv.y, i.uv.x);
                theta += 2 * PI;
                theta %= 2 * PI;
                float4 gold[5];
                gold[0] = float4(1, 0.87843, 0.6, 1);
                gold[1] = float4(0.90196, 0.705882, 0.13333, 1);
                gold[2] = float4(0.8509, 0.65098, 0.18039, 1);
                gold[3] = float4(0.8, 0.61176, 0.16862, 1);
                gold[4] = float4(0.6, 0.45882, 0.12549, 1);
                d = step(d, 1);

                int index = floor(theta / (PI / 10));
                index %= 10;
                if (index >= 5) {
                    index = 5 - (index - 4);
                }

                index += floor(_Time.y * 2);
                index %= 5;

                return d * gold[index] * s;
            }
            ENDCG
        }
    }
}
