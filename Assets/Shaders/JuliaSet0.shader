Shader "Unlit/JuliaSet0"
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
            float mandelbrotSet(float2 st, float2 c, float e) {
                int i;
                for (i = 0; i < 500; i++) {
                    if (length(st) > 2.) {
                        return i * 1. / 20;
                    }
                    float2 preSt = st;
                    st = comPow(preSt, e) + c;
                }
                return 0;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float scale = 2.5;
                i.uv = scale * i.uv - scale / 2;

                float2 c = float2(-0.35 + 0.05 * sin(_Time.y * 0.4), 0.65 + 0.05 * sin(_Time.y * 0.8 + PI));
                float d = mandelbrotSet(i.uv, c, 2);

                float col_r = 0.5 + sin(d * 2 * PI + PI / 6) / 2;
                float col_g = 0.5 + sin(d * 2 * PI + PI / 2) / 2;
                float col_b = 0.5 + sin(d * 2 * PI + PI / 5) / 2;

                float4 col = float4(col_r, col_g, col_b, 1);
                return col;
            }
            ENDCG
        }
    }
}
