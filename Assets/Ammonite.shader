Shader "Unlit/Ammonite"
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
            #define ArrayCount 100

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
                float2 prePolarP0 = cartesian_to_polar(i.uv.x, i.uv.y);
                float2 prePolarP1 = float2(1, -1 * _Time.y * 2);

                i.uv = Rotate(prePolarP0, prePolarP1);
                float theta = atan2(i.uv.y, i.uv.x) + PI;
                float r = length(i.uv);

                float a = 0;
                float b = 0.01;
                float spiral[ArrayCount];
                //float rp = a + b * theta;
                for (int i = 0; i < ArrayCount; i++) {
                    spiral[i] = a + b * (theta + 2 * PI * i);
                }

                float d = 0;
                for (int i = 0; i < ArrayCount; i++) {
                    d += step(spiral[i] - 0.01, r) * step(r, spiral[i]);
                }

                //float d = step(rp - 0.01, r) * step(r, rp);

                return d;

                /*
                i.uv -= 0.5;
                float theta = atan2(i.uv.y, i.uv.x) + PI;
                float r = length(i.uv);

                //float d = exp(b * 2 * PI);

                float b = 0.15;
                float rp = exp(b * theta) * 0.01;
               
                //float r = exp(b * a) * 0.1;
                //float d = length(i.uv);

                //float c = step(r, d);

                float c = step(0.01, abs(r - rp));

                return c;
                */
            }
            ENDCG
        }
    }
}
