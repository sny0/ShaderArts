Shader "Unlit/Move0"
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
                i.uv *= 10;
                int2 masu = floor(i.uv);

                int t = floor(_Time.y) / 4;
                int amari = floor(_Time.y) % 4;

                i.uv.x += step(1, masu.y % 2) * step(1, floor(_Time.y) % 2) * frac(_Time.y);
                i.uv.x -= step(1, (masu.y + 1) % 2) * step(1, floor(_Time.y) % 2) * frac(_Time.y);


                i.uv.y += step(1, masu.x % 2) * step(1, floor(_Time.y + 1) % 2) * frac(_Time.y);
                i.uv.y -= step(1, (masu.x + 1) % 2) * step(1, floor(_Time.y + 1) % 2) * frac(_Time.y);

                int2 masu2 = (floor(i.uv)) % 10;
                masu2 += 10;
                masu2 %= 10;

                int dx = 0;
                if (amari >= 2) dx += lerp(-1, 1, masu2.y % 2);
                dx += 10;
                dx %= 10;

                int dy = 0;
                if (amari >= 1) dy += lerp(-1, 1, masu2.x % 2);
                if (amari >= 3) dy += lerp(-1, 1, masu2.x % 2);
                dy += 10;
                dy %= 10;

                i.uv = frac(i.uv);

                i.uv = 2 * i.uv - 1;

                float d = step(length(i.uv), 0.5);

                if (masu2.x % 2 == (dx + 10) % 2 && masu2.y % 2 == (dy + 10) % 2) {
                    return float4(d, 0, 0, 1);
                }
                else if (masu2.x % 2 == (dx + 10) % 2 && masu2.y % 2 == (dy + 11) % 2) {
                    return float4(0, d, 0, 1);
                }
                else if (masu2.x % 2 == (dx + 11) % 2 && masu2.y % 2 == (dy + 10) % 2) {
                    return float4(0, 0, d, 1);
                }
                else {
                    return float4(d, d, d, 1);
                }

            }
            ENDCG
        }
    }
}
