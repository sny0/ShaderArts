Shader "Unlit/Spirograph"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Rc("Rc", Range(0, 100)) = 1
        _Rm("Rm", Range(0, 100)) = 0.3
        _Rd("Rd", Range(0, 100)) = 0.15
        _Length("Length", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            #define LAP 30

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

            float _Rc;
            float _Rm;
            float _Rd;
            float _Length;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
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

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv += 0.3 * float2(cos(_Time.y), sin(_Time.y));
                float2 rot_uv = i.uv - 0.5;

                float2 prePolarP0 = cartesian_to_polar(rot_uv.x, rot_uv.y);
                float2 prePolarP1 = float2(1, -1 * _Time.y * 2);

                i.uv = Rotate(prePolarP0, prePolarP1);

                i.uv *= 2;

                float2 ist = floor(i.uv) % 3;

                i.uv = frac(i.uv);


                float2 uv = i.uv * 2 - 1;

                float theta = atan2(uv.y, uv.x) + 2 * PI;
                theta %= 2 * PI;

                float thetas[LAP];
                for (int i = 0; i < LAP; i++) {
                    thetas[i] = theta + 2 * PI * i;
                }

                float rc = 1;
                float rm = 0.3;
                float rd = 0.15;

                //_Rc = (_Time.y * 2) % 10;
                //_Rd = (_Time.y * 2) % 3;

                float4 col = float4(0, 0, 0, 1);
                float d = length(uv);
                for (int i = 0; i < LAP; i++) {
                    float x = (_Rc - _Rm) * cos(thetas[i]) + _Rd * cos((_Rc - _Rm) * thetas[i] / _Rm);
                    float y = (_Rc - _Rm) * sin(thetas[i]) - _Rd * sin((_Rc - _Rm) * thetas[i] / _Rm);

                    //float x = (_Rc + _Rm) * cos(thetas[i]) - _Rd * cos((_Rc + _Rm) * thetas[i] / _Rm);
                    //float y = (_Rc + _Rm) * sin(thetas[i]) - _Rd * sin((_Rc + _Rm) * thetas[i] / _Rm);

                    x *= _Length;
                    y *= _Length;

                    float2 p = cartesian_to_polar(x, y);

                    int v = (ist.x - ist.y + 3) % 3;

                    if (v == 0) col += step(p.x - 0.02, d) * step(d, p.x) * float4(1, 0, 0, 0);
                    if (v == 1) col += step(p.x - 0.02, d) * step(d, p.x) * float4(0, 1, 0, 0);
                    if (v == 2) col += step(p.x - 0.02, d) * step(d, p.x) * float4(0, 0, 1, 0);

                    //col += step(p.x - 0.01, d) * step(d, p.x);
                }

                //col = min(col, 1);
                return col;
            }
            ENDCG
        }
    }
}
