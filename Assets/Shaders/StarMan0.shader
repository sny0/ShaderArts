Shader "Unlit/StarMan0"
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

                fixed4 frag(v2f i) : SV_Target
                {
                    float dx = sin(5 * i.uv.y - _Time.y * 1.25);
                    i.uv.x += 0.25 * dx;
                    i.uv.x *= 8;
                    i.uv.y *= 50;
                    int masux = floor(i.uv.x);
                    i.uv = frac(i.uv);

                    i.uv = 2 * i.uv - 1;
                    float d = step(-0.2, i.uv.x) * step(i.uv.x, 0.2) * step(-0.5, i.uv.y) * step(i.uv.y, 0.5);

                    float h = (masux * 1.0) / 20 + _Time.y * 0.1;
                    h = frac(h);
                    float3 hsl = float3(h, 0.3, 0.5);
                    float4 col = float4(hsl_to_rgb(hsl).xyz, 1);
                    return d * col;
                }
                ENDCG
            }
        }
}
