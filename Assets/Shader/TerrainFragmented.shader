Shader "Learning/Environment/TerrainFragmented"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortionRate("Distortion Rate", Range(1, 50)) = 30
        _RotationSpeed("Rotation Speed", Range(0.0, 10.0)) = 3.0
        _DistortionColor("Distortion Color", Color) = (0,0,0,0)
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _DistortionRate;
            float _RotationSpeed;
            fixed4 _DistortionColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv - 0.5;
                float distance = length(uv);
                float interpolation = smoothstep(0.1, 0.04, distance);
                float2 distort = uv * interpolation * _DistortionRate;

                float angle = _Time.y * _RotationSpeed;
                float2x2 rotation = float2x2(cos(angle), -sin(angle), sin(angle), cos(angle));
                distort = mul(rotation, distort);

                uv += distort + 0.5;
                fixed4 col = tex2D(_MainTex, uv);
                col.rgb += _DistortionColor.rgb * interpolation;
                return col;
            }
            ENDCG
        }
    }
}
