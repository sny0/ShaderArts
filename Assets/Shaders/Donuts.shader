Shader "Unlit/Donuts"
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

                float lines(float2 st, float b, float s) {
                    st *= s;
                    float v = smoothstep(0, 0.5 + b * 0.5, abs((sin(st.x * PI) + b * 2)) * 0.5);
                    return v;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    i.uv.x *= 1;
                    i.uv.y *= 1;

                    i.uv = 2 * i.uv - 1;

                    float r = 0.5 + 0.5 * noise(i.uv * 1.5 + _Time.y);
                    float len = length(i.uv);
                    float w = 0.3;
                    float d = step(r - w, len) * step(len, r);

                    float h = frac(r * 10);
                    float s = lerp(0, 0.5, frac(r * _Time.y));
                    float l = 0.5 * d;
                    float3 hsl = float3(h, s, l);
                    float4 col = float4(hsl_to_rgb(hsl).xyz, 1);

                    return col;
                }
                ENDCG
            }
        }
}
