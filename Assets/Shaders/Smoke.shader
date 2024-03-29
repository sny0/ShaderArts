Shader "Unlit/Smoke"
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

                fixed4 frag(v2f i) : SV_Target
                {
                    float d = fbm(i.uv * 0.5 - _Time.y * 0.2, 10, 2.75);

                    float2 prePolarP0 = cartesian_to_polar(i.uv.x, i.uv.y);
                    float2 prePolarP1 = float2(1, -1 * d + PI / 4);

                    i.uv = Rotate(prePolarP0, prePolarP1);

                    d = lines(i.uv, 0.5, 20);

                    return d;

                }
                ENDCG
            }
        }
}
