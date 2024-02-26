Shader "Unlit/WaterDrop"
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
                i.uv.y += _Time.y * 0.5;
                i.uv.x += _Time.y * 0.1;
                i.uv = frac(i.uv);
                i.uv *= 5;
                i.uv = frac(i.uv);

                i.uv = 2 * i.uv - 1;

                i.uv *= 2 * float2(0.3 * abs(cos(_Time.y)) + 0.8, abs(sin(_Time.y)) + 0.5);

                float separatorValue = -0.36;
                float b = 1;
                float a = 0.9;

                float ellipseInterceptY = -0.375;
                float slope = -3.2;
                float lineInterceptX = 0.352;
                float d;
                if (i.uv.y >= ellipseInterceptY) {
                    d = step(i.uv.y, slope * (i.uv.x - lineInterceptX) + ellipseInterceptY)
                        * step(i.uv.y, slope * (-1 * i.uv.x - lineInterceptX) + ellipseInterceptY);
                }
                else {
                    d = step(pow(b * i.uv.x, 2) + pow(a * i.uv.y + 0.5, 2), 0.15);
                }
                
                return d * float4(0.3137, 0.66667, 0.84706, 1);
            }
            ENDCG
        }
    }
}
