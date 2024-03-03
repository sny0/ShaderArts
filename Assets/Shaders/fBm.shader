Shader "Unlit/fBm"
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

                i.uv *= 3;
                //i.uv += float2(cos(_Time.y), sin(_Time.y));
                float d = fbm(i.uv, 10 + 5 * sin(_Time.y * 5), 2 + sin(_Time * 7.5));

                d = 1 - d;
                d = pow(d, 4 + 2 * cos(_Time.x * 10));
                d = 1 - d;
                return d;

            }
            ENDCG
        }
        }
}
