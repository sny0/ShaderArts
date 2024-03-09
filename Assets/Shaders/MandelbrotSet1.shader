Shader "Unlit/MandelbrotSet1"
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

            float2 comPow(float2 z, float n) {
                float r = length(z);
                float theta = 0;
                if (z.x != 0) {
                    theta = atan2(z.y, z.x);
                    theta += PI;
                }

                float2 ans;
                ans.x = pow(r, n) * cos(n * theta);
                ans.y = pow(r, n) * sin(n * theta);

                return ans;
            }

            //if st = float2(0, 0) then Mandelbrot Set
            float2 mandelbrotSet(float2 st, float2 c, float e) {
                int i;
                for (i = 0; i < 500; i++) {
                    if (length(st) > 2.) {
                        break;
                    }
                    float2 preSt = st;
                    st = comPow(preSt, e) + c;
                }

                int wari = 7;

                if (st.x >= 0 && st.y >= 0) {
                    return float2(0, i * 1.0 / wari);
                }
                else if (st.x >= 0 && st.y < 0) {
                    return float2(1, i * 1.0 / wari);
                }
                else if (st.x < 0 && st.y >= 0) {
                    return float2(2, i * 1.0 / wari);
                }
                else {
                    return float2(3, i * 1.0 / wari);
                }
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float scale = 2.5;
                i.uv = scale * i.uv - scale / 2;
                float2 c = float2(-0.3, -0.63);
                float f1 = floor(_Time.y / 6);
                float f2 = f1 % 2;
                float e = lerp(4 + _Time.y % 6, 10 - _Time.y % 6, f2);
                float2 d = mandelbrotSet(0, i.uv, e);

                float4 col;

                if (d.x == 0) {
                    col = float4(1, 0, 0, 1);
                }
                else if (d.x == 1) {
                    col = float4(0.5, 0.5, 0, 1);
                }
                else if (d.x == 2) {
                    col = float4(0, 1, 0, 1);
                }
                else {
                    col = float4(0, 0.5, 0.5, 1);
                }
                return col * d.y;
            }
            ENDCG
        }
    }
}
