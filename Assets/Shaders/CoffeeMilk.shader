Shader "Unlit/CoffeeMilk"
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
                i.uv -= 0.5;
                i.uv *= 15 * pow(length(i.uv), 3);
                i.uv += 0.5;

                float dx = sin(i.uv.y * 20 - _Time.y * 1) * 0.05;
                i.uv.x += dx;
                
                float dy = sin(i.uv.x * 20 - _Time.y * 1) * 0.05;
                dy += cos(i.uv.y * 20 - _Time.y * 1) * 0.1;
                i.uv.y += dy;
                
                float d = 0;
                for (int j = -20; j < 30; j++) {
                    d += step(j*0.1, i.uv.y) * step(i.uv.y, j*0.1 + 0.05);
                }
                
                d = min(d, 1);
                float4 col = lerp(float4(0.9, 0.9, 0.9, 1), float4(0.482, 0.333, 0.267, 1), d);

                return col;
            }
            ENDCG
        }
    }
}
