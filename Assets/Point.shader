Shader "Unlit/Point"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #define P_NUM 25

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


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 p[P_NUM];
                float2 a[P_NUM];
                    
                for (int j = 0; j < P_NUM; j++) {
                    p[j].x = random(float(j));
                    p[j].y = random(float(j * 12 - 32));
                }

                for (int j = 0; j < P_NUM; j++) {
                    p[j].x += (2 * step(0.5, frac(random(j))) - 1) * (floor(random(j) * 100) % 3 + 1) * _Time.y * 0.3;
                    p[j].y += (2 * step(0.5, frac(random(j * -1))) - 1) * (floor(random(j*100) * 100) % 3 + 1) * _Time.y * 0.3;

                    float2 tmp = (floor(p[j])) % 2;
                    tmp = (tmp + 2) % 2;
                    p[j] = frac(p[j]);
                    p[j] = (1 - tmp) * p[j] + tmp * (1 - p[j]);
                    a[j] = tmp;
                }



                float d = 99;
                float dd = 99;
                float ddd = 99;
                int index = 0;

                for (int j = 0; j < P_NUM; j++) {
                    float dp = distance(p[j], i.uv);
                    if(a[j].x == 0) d = min(d, dp);
                    if(a[j].y == 0) dd = min(dd, dp);
                    if (dp < ddd) index = j;
                    ddd = min(ddd, dp);
                }

                float col = min(ddd * 2, 1);

                //float4 col = float4(step(0, d) * step(d, 0.01), step(0, dd) * step(dd, 0.01), step(0, ddd) * step(ddd, 0.01), 1);

                /*
                float4 col = float4(0, 0, 0, 1);
                if (index % 3 == 0) col += float4(1, 0, 0, 0) * (index % P_NUM + 1) / P_NUM;
                if (index % 3 == 1) col += float4(0, 1, 0, 0) * (index % P_NUM + 1) / P_NUM;
                if (index % 3 == 2) col += float4(0, 0, 1, 0) * (index % P_NUM + 1) / P_NUM;
                */
                return col;
            }
            ENDCG
        }
    }
}
