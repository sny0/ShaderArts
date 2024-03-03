Shader "Unlit/StrawberryAuLait"
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

                float fbm(float2 st) {
                    const int octaves = 10;
                    float lacunarity = 2;
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

                fixed4 frag(v2f i) : SV_Target
                {
                    float2 p = 0;
                    p.x = fbm(i.uv + 0.01 * _Time.y);
                    p.y = fbm(i.uv + 1);

                    float2 q = 0;
                    q.x = fbm(i.uv + p + float2(1.7, 9.2) + 0.1 * _Time.y);
                    q.y = fbm(i.uv + p + float2(8.3, 2.8) + 0.01 * _Time.y);

                    float d = fbm(i.uv + q + 0.012 * _Time.y);

                    float3 c[4];
                    c[0] = float3(250, 34, 34) / 255;
                    c[1] = float3(238, 232, 170) / 255;
                    c[2] = float3(200, 150, 255) / 255;
                    c[3] = float3(255, 100, 130) / 255;

                    float3 col = lerp(c[0], c[1], clamp(length(d), 0, 1));
                    col = lerp(col, c[2], clamp(length(p), 0, 1));
                    col = lerp(col, c[3], clamp(length(q), 0, 1));

                    return float4(col.xyz, 1);
                }
                ENDCG
            }
        }
}
