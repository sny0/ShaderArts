Shader "Unlit/MiracleEyes"
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

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv *= 3;

                float2 iv = floor(i.uv);
                float2 fv = frac(i.uv);

                float d = 10;
                float d2 = 10;

                for (int y = -1; y <= 1; y++) {
                    for (int x = -1; x <= 1; x++) {
                        float2 neighbor = float2(x, y);

                        float2 p = float2(random(iv + neighbor), random(iv + neighbor));
                        p = 0.5 + 0.5 * sin(_Time.y + 6.2 * p);

                        float2 dif = neighbor + p - fv;

                        float tmp_d = length(dif);

                        if (d > tmp_d) {
                            d2 = d;
                            d = tmp_d;
                        }
                        else if (d2 > tmp_d) {
                            d2 = tmp_d;
                        }
                    }
                }

                float ib = (d2 - d) * 100 / 10;
                float fb = (d2 - d) * 100 % 10 / 10;
                d = step(0, fb) * step(fb, 0.8);
                float h = ((ib * 1.5) % 10) / 10;
                float3 hsl = float3(h, 10, 0.5);
                float4 col = float4((1 - d) * hsl_to_rgb(hsl).xyz, 1);

                return col;

            }
            ENDCG
        }
    }
}
