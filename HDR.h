/*------------------------------------------------------------------------------
						HDR
------------------------------------------------------------------------------*/

float4 HDRPass( float4 colorInput, float2 Tex )
{
	float4 HDR = colorInput;
	float HDRPower = 0.05;
	float4 c_center = tex2D(s0, Tex.xy).rgba;
	float4 bloom_sum = float4(0.0, 0.0, 0.0, 0.0);
	Tex += float2(0.3, 0.3);
	float radius1 = 2.5;
	bloom_sum += tex2D(s0, Tex + float2(-1.5, -1.5) * radius1);
	bloom_sum += tex2D(s0, Tex + float2(-2.5, 0) * radius1);
	bloom_sum += tex2D(s0, Tex + float2(-1.5, 1.5) * radius1);
	bloom_sum += tex2D(s0, Tex + float2(0, 2.5) * radius1);
	bloom_sum += tex2D(s0, Tex + float2(1.5, 1.5) * radius1);
	bloom_sum += tex2D(s0, Tex + float2(2.5, 0) * radius1);
	bloom_sum += tex2D(s0, Tex + float2(1.5, -1.5) * radius1);
	bloom_sum += tex2D(s0, Tex + float2(0, -2.5) * radius1);
	float radius2 = 2.5;
	bloom_sum += tex2D(s0, Tex + float2(-1.5, -1.5) * radius2);
	bloom_sum += tex2D(s0, Tex + float2(-2.5, 0) * radius2);
	bloom_sum += tex2D(s0, Tex + float2(-1.5, 1.5) * radius2);
	bloom_sum += tex2D(s0, Tex + float2(0, 2.5) * radius2);
	bloom_sum += tex2D(s0, Tex + float2(1.5, 1.5) * radius2);
	bloom_sum += tex2D(s0, Tex + float2(2.5, 0) * radius2);
	bloom_sum += tex2D(s0, Tex + float2(1.5, -1.5) * radius2);
	bloom_sum += tex2D(s0, Tex + float2(0, -2.5) * radius2);
	bloom_sum *= 0.025;
	bloom_sum -= float4(0.1, 0.1, 0.1, 0.1);
	bloom_sum = max(bloom_sum, float4(0,0,0,0));
	float2 vpos = (Tex - float2(0.5, 0.5)) * 2;
	float dist = (dot(vpos, vpos));
	dist = 1 - 0.1*dist;
	HDR = (c_center * 0.4 + bloom_sum) * dist;
	float4 blend = HDR + colorInput;
	HDR += pow(blend, 4) * HDRPower;
	return HDR;
}