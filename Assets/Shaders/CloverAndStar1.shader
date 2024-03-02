Shader "Unlit/CloverAndStar1"
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float random(float2 st)
            {
                return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453);
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

            float isHeart(float2 st) {
                float l = pow(pow(st.x, 2) + pow(st.y, 2) - 1, 3);
                float r = pow(st.x, 2) * pow(st.y, 3);
                float d = step(l, r);
                return d;
            }

            float isStar(float2 st) {
                float theta = atan2(st.y, st.x);
                float b = 0.5;
                float a = 0.3;
                float d = a * pow(abs(sin(theta * 5 / 2 + PI / 4)), 2) + b;
                float r = length(st);

                d = step(r, d);
                return d;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv *= 10;
                int2 masu = floor(i.uv);
                i.uv = frac(i.uv);

                int rnd = floor(random(masu * PI - floor(_Time.y * 0.5)) * 10);

                float s = abs(sin(_Time.y * PI / 2));

                if (rnd == 0) {
                    i.uv = i.uv * 5 - 2.5;
                    i.uv.y -= 0.75;

                    float d0 = isHeart(i.uv);

                    float2 st = i.uv;
                    float2 prePolarP0 = cartesian_to_polar(st.x, st.y);
                    float2 prePolarP1 = float2(1, 2 * PI / 3);

                    i.uv = Rotate(prePolarP0, prePolarP1);
                    i.uv.y -= 1.5;
                    i.uv.x -= 0.85;
                    float d1 = isHeart(i.uv);

                    prePolarP0 = cartesian_to_polar(st.x, st.y);
                    prePolarP1 = float2(1, -2 * PI / 3);

                    i.uv = Rotate(prePolarP0, prePolarP1);
                    i.uv.y -= 1.5;
                    i.uv.x += 0.85;
                    float d2 = isHeart(i.uv);

                    float4 col = float4(0, d0 + d1 + d2, 0, 1) * s;
                    return col;
                }
                else if (rnd == 1) {
                    i.uv = i.uv * 2 - 1;
                    float d = isStar(i.uv);
                    float4 col = float4(d, d, 0, 1) * s;
                    return col;
                }
                else {
                    return 0;
                }
            }
            ENDCG
        }
    }
}
