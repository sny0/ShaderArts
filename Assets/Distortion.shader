Shader "Unlit/Distortion"
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
                i.uv *= 1 + 0.1 * sin(i.uv.x * 5 + _Time.y) + 0.1 * sin(i.uv.y * 3 + _Time.y);

                //i.uv -= 0.5;
                //i.uv *= 1 + 15 * pow(length(i.uv), 1.5);
                //i.uv += 0.5;
                
                i.uv *= 3;
                i.uv = frac(i.uv);

                i.uv = i.uv * 2 - 1;
                float d = step(-0.1, i.uv.x) * step(i.uv.x, 0.1) + step(-0.1, i.uv.y) * step(i.uv.y, 0.1);
                return d;
            }
            ENDCG
        }
    }
}
