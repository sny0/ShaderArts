Shader "Unlit/WonderHeatMap"
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

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv *= 50;
                float2 iv = floor(i.uv);
                float2 fv = frac(i.uv);

                float2 u = fv * fv * (3.0 - 2.0 * fv);
                float v = lerp(random(iv.x), random(iv.x + 1.0), u.x);
                v += lerp(random(iv.y), random(iv.y + 1.0), u.y);
                v /= 2;
                //float v = lerp(random(iv.x), random(iv.x + 1.0), smoothstep(0., 1., fv.x));
                //v += lerp(random(iv.y), random(iv.y + 1.0), smoothstep(0., 1., fv.y));
                //v /= 2;

                float h = 0.5 * v + 0.5 * sin(_Time.y * 0.5);
                float s = 0.5 + 0.25 * sin(_Time.y * 2);
                float l = 0.5 + 0.25 * sin(_Time.y * 0.1);

                float3 hsl = float3(h, s, l);
                float4 col = float4(hsl_to_rgb(hsl).xyz, 1);

                return col;
            }
            ENDCG
        }
    }
}
