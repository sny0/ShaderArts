Shader "Unlit/StainedGlass"
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
                float2 st = 2 * i.uv - 1;
                i.uv *= 25;

                float2 iv = floor(i.uv);
                float2 fv = frac(i.uv);

                float d = 10;
                float d2 = 10;
                float2 pp = float2(0, 0);

                for (int y = -1; y <= 1; y++) {
                    for (int x = -1; x <= 1; x++) {
                        float2 neighbor = float2(x, y);

                        float2 p = float2(random(iv + neighbor), random(iv + neighbor + 57));
                        p = 0.5 + 0.5 * sin(_Time.y + 6.2 * p);

                        float2 dif = neighbor + p - fv;

                        float tmp_d = length(dif);

                        if (d > tmp_d) {
                            d2 = d;
                            d = tmp_d;
                            pp = iv + neighbor;
                        }
                        else if (d2 > tmp_d) {
                            d2 = tmp_d;
                        }
                    }
                }

                i.uv -= 25 * 1.0 / 2;
                float2 ppp = pp - 25 * 1.0 / 2;
                float star = isStar(ppp * (1.28 - abs(sin(_Time.y * 0.25)) * 1.25));

                float v = length(i.uv * 0.3);
                v = sin(v - _Time.y);

                d = step(2, d);
                d = 1 - d;
                d *= star;

                float h = random(pp);
                float s = (0.75 + 0.25 * sin(random(pp * 2 * PI))) * lerp(0.5, 0.1, d);
                float l = lerp(0.5, 0.1, d);

                float3 hsl = float3(random(pp), s, l);
                float4 col = float4(hsl_to_rgb(hsl).xyz, 1);

                return col;
            }
            ENDCG
        }
    }
}
