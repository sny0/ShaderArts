Shader "Unlit/LiquidNoise"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _ScaleX("Scale X", float) = 1
        _ScaleY("Scale Y", float) = 1
        _LineScale("Scale", float) = 1
        _ColorIntensity("Color Intensity", float) = 0.5
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

                float _ScaleX;
                float _ScaleY;
                float _LineScale;
                float _ColorIntensity;

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
                    i.uv.x *= _ScaleX;
                    i.uv.y *= _ScaleY;

                    float v = noise(i.uv + _Time.y * 0.2);

                    float2 prePolarP0 = cartesian_to_polar(i.uv.x, i.uv.y);
                    float2 prePolarP1 = float2(1, -1 * v);

                    i.uv = Rotate(prePolarP0, prePolarP1);

                    float d = lines(i.uv, _ColorIntensity, _LineScale);

                    return d;
                }
                ENDCG
            }
        }
}
