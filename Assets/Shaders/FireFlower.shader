Shader "Unlit/FireFlower"
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

            fixed4 hsl_to_rgb(float3 hsl)
            {
                float H = hsl.x;
                float S = hsl.y;
                float L = hsl.z;

                float C = (1 - abs(2 * L - 1)) * S;
                float X = C * (1 - abs(fmod(H * 6, 2) - 1));
                float m = L - C / 2;

                float3 rgb;

                if (H < 1.0 / 6.0)
                    rgb = float3(C, X, 0);
                else if (H < 2.0 / 6.0)
                    rgb = float3(X, C, 0);
                else if (H < 3.0 / 6.0)
                    rgb = float3(0, C, X);
                else if (H < 4.0 / 6.0)
                    rgb = float3(0, X, C);
                else if (H < 5.0 / 6.0)
                    rgb = float3(X, 0, C);
                else
                    rgb = float3(C, 0, X);

                return float4(rgb + m, 1.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                    i.uv.x *= 1;
                    i.uv.y *= 1;

                    i.uv = 2 * i.uv - 1;


                    float u = abs(sin((atan2(i.uv.y, i.uv.x) - length(i.uv) + _Time.y * 3) * 10.) * .5) + .2 + 0.15 * sin(_Time.y * 3);
                    float t = (0.2 + 0.1 * sin(_Time.y * 2)) / abs(u - length(i.uv));
     
                    //float theta = atan2(i.uv.y, i.uv.x);
                    //float d = 0.5 * length(i.uv) -  + sin(theta * 6. + _Time.y * 5.) * 1;
                    //float b = 0.5 / abs(d - sin(_Time.y));
                    //float4 col = float4(.1, .01, 1., 1.);
                    
                    float h = _Time.y * .5;
                    float s = 0.5 + 0.5 *sin(_Time.y * 5);
                    h = frac(h);
                    s = frac(s);
                    float3 hsl = float3(h, s, 0.5);
                    float4 col = float4(hsl_to_rgb(hsl).xyz, 1);
                    
                    //float4 col = float4(.05, .3, 0.9, 1.);
                    //col = b * col;
                    col = t * col;
                    return col;
            }
            ENDCG
        }
    }
}
