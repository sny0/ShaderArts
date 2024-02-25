Shader "Unlit/SquareRotate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SideLength("Square Side Length", Range(0, 1)) = 0.8
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

            float _SideLength;

            v2f vert (appdata v)
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

            float SquareRotate(float2 polarP0, float2 polarP1) {
                float2 newP = Rotate(polarP0, polarP1);

                float2 centerPoint = float2(0, 0);

                //float isX = (1 - step(centerPoint.x + _SideLength / 2, newCartesianP.x)) * step(centerPoint.x - _SideLength / 2, newCartesianP.x);
                //float isY = (1 - step(centerPoint.y + _SideLength / 2, newCartesianP.y)) * step(centerPoint.y - _SideLength / 2, newCartesianP.y);

                float isX = (1 - step(centerPoint.x + abs(sin(_Time.y * 5)) / 3, newP.x)) * step(centerPoint.x - abs(sin(_Time.y * 5)) / 3, newP.x);
                float isY = (1 - step(centerPoint.y + abs(sin(_Time.y * 5)) / 3, newP.y)) * step(centerPoint.y - abs(sin(_Time.y * 5)) / 3, newP.y);

                float v = isX * isY;
                return v;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                i.uv -= 0.5;
                float2 prePolarP0 = cartesian_to_polar(i.uv.x, i.uv.y);
                float2 prePolarP1 = float2(1, -1 * _Time.y * 2);

                i.uv = Rotate(prePolarP0, prePolarP1);

                int n = floor(_Time.y * 5 / PI) % 10 + 1;
                i.uv = frac(i.uv * n);
                i.uv -= 0.5;

                float2 polarP0 = cartesian_to_polar(i.uv.x, i.uv.y);
                float2 polarP1_r = float2(1, -1 * _Time.y * 1 * 2);
                float2 polarP1_g = float2(1, -1 * _Time.y * 2 * 2);
                float2 polarP1_b = float2(1, -1 * _Time.y * 3 * 2);

                float r = SquareRotate(polarP0, polarP1_r);
                float g = SquareRotate(polarP0, polarP1_g);
                float b = SquareRotate(polarP0, polarP1_b);


                fixed4 col = float4(r, g, b, 1);

                return col;
            }
            ENDCG
        }
    }
}
