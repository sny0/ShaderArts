﻿Shader "Unlit/SierpinskiTriangle"
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

            float lines(float2 st, float b, float s) {
                st *= s;
                float v = smoothstep(0, 0.5 + b * 0.5, abs((sin(st.x * PI) + b * 2)) * 0.5);
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


            float clamp(float v, float minv, float maxv) {
                return max(min(v, maxv), minv);
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

            float2 comPow(float2 z, float n) {
                float r = length(z);
                float theta = 0;
                if (z.x != 0) {
                    theta = atan2(z.y, z.x);
                    theta += PI;
                }

                float2 ans;
                ans.x = pow(r, n) * cos(n * theta);
                ans.y = pow(r, n) * sin(n * theta);

                return ans;
            }

            float func(float x) {
                return x * x * (3 - 2 * x);
            }

            //if st = float2(0, 0) then Mandelbrot Set
            //if st = float2(0, 0) then Mandelbrot Set
            float mandelbrotSet(float2 st, float2 c, float e) {
                int i;
                for (i = 0; i < 500; i++) {
                    if (length(st) > 2.) {
                        return i * 1. / 7;
                    }
                    float2 preSt = st;
                    st = comPow(preSt, e) + c;
                }
                return 0;
            }

            float flower(float2 p, float n, float radius, float angle, float waveAmp)
            {
                float theta = atan2(p.y, p.x);
                float d = length(p) - radius + sin(theta * n + angle) * waveAmp;
                float b = 0.02 / abs(d);
                return b;
            }

            bool isInSierpinski(float2 uv, int iter)
            {
                for (int i = 0; i < iter; i++)
                {
                    if (uv.x > 0.5 && uv.y < 0.5)
                        return false;
                    uv = frac(uv * 2.0);
                }
                return true;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //i.uv = i.uv * 2 - 1;
                float t = _Time.y * 2.0;
                float wave = abs(fmod(t, 18.0) - 9.0);
                int iterCount = 1 + int(wave); // 1〜10〜1

                float2 uv = frac(i.uv * float2(1, 1));
                float2 uv90 = float2(uv.y, 1.0 - uv.x);
                float2 uv270 = float2(1.0 - uv.y, uv.x);
                float4 col = float4(0.0, 0.0, 0.0, 1.0);

                if (isInSierpinski(uv, iterCount))
                    col += float4(1.0, 0.0, 0.0, 0.0);
                if (isInSierpinski(uv90, iterCount))
                    col += float4(0.0, 1.0, 0.0, 0.0);
                if (isInSierpinski(uv270, iterCount))
                    col += float4(0.0, 0.0, 1.0, 0.0);

                return col;
            }
            ENDCG
        }
    }
}

