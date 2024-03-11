Shader "Unlit/ColorFlame"
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

            fixed4 hsl_to_rgb(float3 hsl)
            {
                float H = hsl.x;
                float S = hsl.y;
                float L = hsl.z;

                float C = (1 - abs(2 * L - 1)) * S;
                float X = C * (1 - abs(fmod(H * 6, 2) - 1));
                float m = L - C / 2;

                float3 rgb;

                if (H < 1.0 / 6.0)
                    rgb = float3(C, X, 0);
                else if (H < 2.0 / 6.0)
                    rgb = float3(X, C, 0);
                else if (H < 3.0 / 6.0)
                    rgb = float3(0, C, X);
                else if (H < 4.0 / 6.0)
                    rgb = float3(0, X, C);
                else if (H < 5.0 / 6.0)
                    rgb = float3(X, 0, C);
                else
                    rgb = float3(C, 0, X);

                return float4(rgb + m, 1.0);
            }

            float noise(float2 st) {
                float2 i = floor(st);
                float2 f = frac(st);
                float2 u = f * f * (3 - 2 * f);

                //float l = lerp(random(i), random(i + float2(1, 0)), u.x);
                //float r = lerp(random(i + float2(0, 1)), random(i + float2(1, 1)), u.x);

                float l = lerp(random(i), random(i + float2(1, 0)), u.x);
                float r = lerp(random(i + float2(0, 1)), random(i + float2(1, 1)), u.x);

                float v = lerp(l, r, u.y);

                return v;
            }

            float fbm(float2 st, float oc, float la) {
                const int octaves = oc;
                float lacunarity = la;
                float gain = 0.5;

                float amplitude = 0.5;
                float frequency = 3;

                float v = 0;
                for (int j = 0; j < octaves; j++) {
                    v += amplitude * abs(noise(frequency * st) * 2 - 1);
                    frequency *= lacunarity;
                    amplitude *= gain;
                }

                return v;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv = 3 * i.uv - 1.5;

                float2 p = 0;
                p.x = fbm(i.uv - _Time.y, 10, 2);
                p.y = fbm(i.uv - _Time.y, 10, 2);

                float2 q = 0;
                q.x = fbm(i.uv + p + float2(0.2, 0.3), 2, 1);
                q.y = fbm(i.uv + p + float2(0.2, 0.3), 2, 1);

                i.uv += q;
                float2 polarP = cartesian_to_polar(i.uv.x, i.uv.y);
                polarP.y += 2 * PI;
                polarP.y %= 2 * PI;

                polarP.y += _Time.y * 3;
                polarP.y += 100 * PI;
                polarP.y %= 2 * PI;
                float h = polarP.y / (2 * PI);
                float s = 0.7 + 0.1 * sin(_Time.y * 10);
                float l = step(polarP.x, 100) * (1 - 0.7 * pow(polarP.x, 1 + 0.3 * sin(_Time.y)));
                float3 hsl = float3(h, s, l);
                float4 col = float4(hsl_to_rgb(hsl).xyz, 1);

                return col;
        }
        ENDCG
    }
    }
}
