Shader "Unlit/CircleDistortion"
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
                i.uv += 0.1 * float2(cos(_Time.y * 3), sin(_Time.y * 3));
                i.uv -= 0.5;
                i.uv *= 15 * pow(length(i.uv), 3);
                i.uv += 0.5;
                
                i.uv.x += sin(i.uv.y * 5 - _Time.y * 3) * 0.05;
                
                float d = distance(float2(0.5, 0.5), i.uv);
                d = abs(sin(d * 15 - _Time.y * 3));

                float v = 0;

                v += 0.2 * step(0, d) * step(d, 0.1);
                v += 0.4 * step(0.1, d) * step(d, 0.5);
                v += 0.75 * step(0.5, d) * step(d, 0.75);
                v += 0.9 * step(0.75, d) * step(d, 1);

                return v;
            }
            ENDCG
        }
    }
}
