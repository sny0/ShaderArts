Shader "Unlit/StarInStar0"
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

            float isStar(float2 st, float scale) {
                float theta = atan2(st.y, st.x);
                float b = 0.5;
                float a = 0.3;
                float d = a * pow(abs(sin(theta * 5 / 2 + PI / 4)), 2) + b;
                float r = length(st);

                d = step(r * scale, d);
                return d;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv -= 0.5;
                i.uv *= 3 + 2.95 * sin(_Time.y);
                i.uv += 0.5;

                float2 iiv = floor(i.uv);
                i.uv = frac(i.uv);

                float2 scale = float2(30, 30);

                float2 st = i.uv;
                st = 2 * st - 1;

                i.uv *= 1 + scale * pow(length(i.uv), 0.5);
                
                float2 iv = floor(i.uv);
                i.uv = frac(i.uv);

                float2 center = iv + float2(0.5, 0.5);
                center = 2 * center / scale - 1;

                i.uv = 2 * i.uv - 1;

                float d = isStar(i.uv, 0.85);

                float star = isStar(center, 0.8 * pow(3, 2 + 1.999 * sin(_Time.y - 3 * random(iiv))));

                float h = random(iiv * PI);
                float3 hsl = float3(h, 0.8, 0.5);
                float4 col = lerp(0, float4(hsl_to_rgb(hsl).xyz, 1), d * star);
                return col;
            }
            ENDCG
        }
    }
}
