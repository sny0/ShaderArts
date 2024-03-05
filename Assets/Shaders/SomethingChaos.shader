Shader "Unlit/SomethingChaos"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
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

            v2f vert(appdata v)
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

            float isStar(float2 st, float scale) {
                float theta = atan2(st.y, st.x);
                float b = 0.5;
                float a = 0.3;
                float d = a * pow(abs(sin(theta * 5 / 2 + PI / 4)), 1) + b;
                float r = length(st);

                d = step(r * scale, d);
                return d;
            }

            float func(float x) {
                return x * x * (2. * x + 3.) / 3.;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv = 2 * i.uv - 1;
                float2 st = i.uv;

                float wave = pow(sin(length(st) * 5 - _Time.y * 0.5), 2);

                for (int j = 0; j < 2; j++) {
                    float2 p = cartesian_to_polar(i.uv.x, i.uv.y);

                    i.uv = polar_to_cartesian(func(p.x), p.y);
                }

                i.uv = (i.uv + 1.) / 2.;
                i.uv *= 3;
                float2 iv = floor(i.uv);
                i.uv = frac(i.uv);

                i.uv = 2 * i.uv - 1;

                float d = abs(sin(length(i.uv)));

                float2 masuPhase = (iv + 100) % 10;
                masuPhase / 10;

                masuPhase = max(masuPhase.x, masuPhase.y);

                float threshold[3];
                threshold[0] = 0.5 + 0.5 * sin(_Time.y);
                threshold[1] = 0.5 + 0.5 * sin(_Time.y * 3 + PI / 4);
                threshold[2] = 0.5 + 0.5 * sin(_Time.y * 5 + 3 * PI / 4);

                float r[2], g[2], b[2];

                r[0] = step(abs(i.uv.x), threshold[0]) * step(abs(i.uv.y), threshold[0]);
                g[0] = step(abs(i.uv.x), threshold[1]) * step(abs(i.uv.y), threshold[1]);
                b[0] = step(abs(i.uv.x), threshold[2]) * step(abs(i.uv.y), threshold[2]);


                r[1] = isStar(i.uv, threshold[0] + 0.5);
                g[1] = isStar(i.uv, threshold[1] + 0.5);
                b[1] = isStar(i.uv, threshold[2] + 0.5);

                float4 squareCol = float4(r[0], g[0], b[0], 1);
                float4 StarCol = float4(r[1], g[1], b[1], 1);

                float4 col = lerp(squareCol, StarCol, wave);

                return col;
            }
            ENDCG
        }
    }
}
