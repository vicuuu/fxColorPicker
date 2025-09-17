// Variables //
float mode = 0.0; // 0 = SV, 1 = Hue
float hue = 0.0;

// Inputs //
struct PSInput {
    float4 Position : POSITION0;
    float2 TexCoord : TEXCOORD0;
};

// Utils //
float3 hsv2rgb(float3 c) {
    float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

// Handlers //
float4 PSHandler(PSInput IN) : COLOR0 {
    float2 uv = IN.TexCoord;
    float3 col;
    if (mode < 0.5) {
        float s = saturate(uv.x);
        float v = saturate(1.0 - uv.y);
        col = hsv2rgb(float3(hue, s, v));
    } else {
        float h = saturate(1.0 - uv.y);
        col = hsv2rgb(float3(h, 1.0, 1.0));
    }
    return float4(col, 1.0);
}

// Techniques //
technique Shader_HSV {
    pass P0 {
        ZEnable = FALSE;
        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = INVSRCALPHA;
        PixelShader = compile ps_2_0 PSHandler();
    }
}
technique fallback {
    pass P0 {}
}
