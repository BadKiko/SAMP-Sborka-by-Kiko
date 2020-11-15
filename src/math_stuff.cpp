#include "main.h"

#define FLOAT_EPSILON 0.0001f

/*

a lot of these are only for float[] so it would be nice to consolidate
some more functions for actual VECTOR/D3DVECTOR types, or better yet,
to just finally move to the CVector and CMatrix classes.

*/
int near_zero ( float v )
{
	if ( !isfinite(v) )
		return 1;
	return fabs( v ) < FLOAT_EPSILON;
}

void vect2_normalize ( const float in[2], float out[2] )
{
	float	m;
	int		i;

	m = sqrtf( in[0] * in[0] + in[1] * in[1] );

	for ( i = 0; i < 2; i++ )
		out[i] = in[i] / m;
}

float vect2_length ( const float in[2] )
{
	return sqrtf( in[0] * in[0] + in[1] * in[1] );
}

int vect2_near_zero ( const float in[2] )
{
	//if ( !isfinite(in[0]) || !isfinite(in[1]) )
	//	return 1;
	return near_zero( in[0] ) && near_zero( in[1] );
}

void vect3_zero ( float out[3] )
{
	int i;

	for ( i = 0; i < 3; i++ )
		out[i] = 0.0f;
}

void vect2_copy ( const uint8_t in[2], uint8_t out[2] )
{
	memcpy( out, in, sizeof(uint8_t) * 2 );
}

void vect3_normalize ( const float in[3], float out[3] )
{
	float	m;
	int		i;

	m = sqrtf( in[0] * in[0] + in[1] * in[1] + in[2] * in[2] );

	for ( i = 0; i < 3; i++ )
		out[i] = in[i] / m;
}

float vect3_length ( const float in[3] )
{
	return sqrtf( in[0] * in[0] + in[1] * in[1] + in[2] * in[2] );
}

void vect3_div ( const float in[3], float m, float out[3] )
{
	int i;

	for ( i = 0; i < 3; i++ )
		out[i] = in[i] / m;
}

void vect3_mult ( const float in[3], float m, float out[3] )
{
	int i;

	for ( i = 0; i < 3; i++ )
		out[i] = in[i] * m;
}

void vect3_vect3_mult ( const float in1[3], const float in2[3], float out[3] )
{
	int i;

	for ( i = 0; i < 3; i++ )
		out[i] = in1[i] * in2[i];
}

void vect3_vect3_add ( const float in1[3], const float in2[3], float out[3] )
{
	int i;

	for ( i = 0; i < 3; i++ )
		out[i] = in1[i] + in2[i];
}

void vect3_vect3_sub ( const float in1[3], const float in2[3], float out[3] )
{
	int i;

	for ( i = 0; i < 3; i++ )
		out[i] = in1[i] - in2[i];
}

void vect3_invert ( const float in[3], float out[3] )
{
	int i;

	for ( i = 0; i < 3; i++ )
		out[i] = -in[i];
}

int vect3_near_zero ( const float in[3] )
{
	//if ( !isfinite(in[0]) || !isfinite(in[1]) || !isfinite(in[2]) )
	//	return 1;
	return near_zero( in[0] ) && near_zero( in[1] ) && near_zero( in[2] );
}

void vect3_copy ( const float in[3], float out[3] )
{
	memcpy( out, in, sizeof(float) * 3 );
}

float vect3_dist ( const float in1[3], const float in2[3] )
{
	float	dist[3];

	vect3_vect3_sub( in1, in2, dist );
	return vect3_length( dist );
}

int vect4_near_zero ( const float in[4] )
{
	//if ( !isfinite(in[0]) || !isfinite(in[1]) || !isfinite(in[2]) || !isfinite(in[3]) )
	//	return 1;
	return near_zero( in[0] ) && near_zero( in[1] ) && near_zero( in[2] ) && near_zero( in[3] );
}

void vect4_copy ( const uint8_t in[4], uint8_t out[4] )
{
	memcpy( out, in, sizeof(uint8_t) * 4 );
}

void vect4_copy ( const float in[4], float out[4] )
{
	memcpy( out, in, sizeof(float) * 4 );
}

void vect4_zero ( float out[4] )
{
	int i;

	for ( i = 0; i < 4; i++ )
		out[i] = 0.0f;
}

void matrix_copy ( const float in[16], float out[16] )
{
	memcpy( out, in, sizeof(float) * 16 );
}

float vect3_dot_product ( const float in1[3], const float in2[3] )
{
	return in1[0] * in2[0] + in1[1] * in2[1] + in1[2] * in2[2];
}

void vect3_cross_product ( const float in1[3], const float in2[3], float out[3] )
{
	out[0] = ( in1[1] * in2[2] ) - ( in2[1] * in1[2] );
	out[1] = ( in1[2] * in2[0] ) - ( in2[2] * in1[0] );
	out[2] = ( in1[0] * in2[1] ) - ( in2[0] * in1[1] );
}

void matrix_vect3_mult ( const float matrix[16], const float in[3], float out[3] )
{
	const float in4[4] = { in[0], in[1], in[2], 1.0f };
	float		out4[4];

	matrix_vect4_mult( matrix, in4, out4 );
	vect3_copy( out4, out );
}

void matrix_vect4_mult ( const float matrix[16], const float in[4], float out[4] )
{
	float	res[4];
	int		i;

	for ( i = 0; i < 4; i++ )
	{
		res[i] = in[0] * matrix[0 + i] + in[1] * matrix[4 + i] + in[2] * matrix[8 + i] + in[3] * matrix[12 + i];
	}

	vect4_copy( res, out );
}

void matrix_matrix_mult ( const float in1[16], const float in2[16], float out[16] )
{
	float	res[16];
	int		i, j;

	for ( i = 0; i < 4; i++ )
	{
		for ( j = 0; j < 4; j++ )
		{
			res[i * 4 + j] = in1[i * 4 + 0] *
				in2[0 + j] +
				in1[i * 4 + 1] *
				in2[4 + j] +
				in1[i * 4 + 2] *
				in2[8 + j] +
				in1[i * 4 + 3] *
				in2[12 + j];
		}
	}

	matrix_copy( res, out );
}

void matrix_vect3_rotate ( const float in[16], const float vect[3], float t, float out[16] )
{
	const float x = vect[0], y = vect[1], z = vect[2];
	const float sin_t = sinf( t ), cos_t = cosf( t );
	float		res[16];
	const float matrix[16] =
	{
		cos_t + ( 1.0f - cos_t ) * x * x,
		( 1.0f - cos_t ) * x * y - sin_t * z,
		( 1.0f - cos_t ) * x * z + sin_t * y,
		0.0f,
		( 1.0f - cos_t ) * y * x + sin_t * z,
		cos_t + ( 1.0f - cos_t ) * y * y,
		( 1.0f - cos_t ) * y * z - sin_t * x,
		0.0f,
		( 1.0f - cos_t ) * z * x - sin_t * y,
		( 1.0f - cos_t ) * z * y + sin_t * x,
		cos_t + ( 1.0f - cos_t ) * z * z,
		0.0f,
		0.0f,
		0.0f,
		0.0f,
		1.0f
	};

	matrix_matrix_mult( in, matrix, res );
	vect4_copy( &in[4 * 3], &res[4 * 3] );
	matrix_copy( res, out );
}

void matrix_vect3_switchXY ( const float in[16], float out[16] )
{
	float	res[16];
	vect4_copy( &in[4 * 0], &res[4 * 0] );
	vect4_copy( &in[4 * 1], &res[4 * 1] );
	vect4_copy( &in[4 * 2], &res[4 * 2] );

	vect4_copy( &in[4 * 3], &res[4 * 3] );
	matrix_copy( res, out );
}

void matrix_identity ( float out[16] )
{
	static const float	id[16] =
	{
		1.0f,
		0.0f,
		0.0f,
		0.0f,
		0.0f,
		1.0f,
		0.0f,
		0.0f,
		0.0f,
		0.0f,
		1.0f,
		0.0f,
		0.0f,
		0.0f,
		0.0f,
		1.0f
	};

	matrix_copy( id, out );
}

float roundf ( float v )
{
	return floorf( v + 0.5f );
}

void QuaternionToMatrix( float &quaterW, float &quaterX, float &quaterY, float &quaterZ, tVector* right, tVector* up, tVector* at )
{
	float SquarredQuaterW = 0.0f, SquarredQuaterX = 0.0f, SquarredQuaterY = 0.0f, SquarredQuaterZ = 0.0f;

	SquarredQuaterW = quaterW * quaterW;
	SquarredQuaterX = quaterX * quaterX;
	SquarredQuaterY = quaterY * quaterY;
	SquarredQuaterZ = quaterZ * quaterZ;
	right->X	= SquarredQuaterX - SquarredQuaterY - SquarredQuaterZ + SquarredQuaterW;
	up->Y		= SquarredQuaterY - SquarredQuaterX - SquarredQuaterZ + SquarredQuaterW;
	at->Z		= SquarredQuaterZ - (SquarredQuaterY + SquarredQuaterX) + SquarredQuaterW;

	float multXY = quaterX * quaterY;
	float multWZ = quaterW * quaterZ;
	up->X		= multWZ + multXY + multWZ + multXY;
	right->Y	= multXY - multWZ + multXY - multWZ;

	float multXZ = quaterX * quaterZ;
	float multWY = quaterW * quaterY;
	at->X		= multXZ - multWY + multXZ - multWY;
	right->Z	= multWY + multXZ + multWY + multXZ;

	float multYZ = quaterY * quaterZ;
	float multWX = quaterW * quaterX;
	at->Y = multWX + multYZ + multWX + multYZ;
	up->Z = multYZ - multWX + multYZ - multWX;
}

void MatrixToQuaternion( tVector* right, tVector* up, tVector* at, float &quaterW, float &quaterX, float &quaterY, float &quaterZ ) // IDA POWA !
{
  long double v13; // st7@1
  long double v14; // st7@3
  long double v15; // st5@5
  float v16; // st6@5
  float v17; // st7@5
  long double v18; // st6@7
  int result = 0; // eax@17
  float v20; // ST28_8@17
  float v21; // ST10_8@17
  float v22; // st7@17
  float v23; // [sp+10h] [bp-20h]@7
  float v24; // [sp+18h] [bp-18h]@9
  float v25; // [sp+20h] [bp-10h]@3

  v13 = right->X + up->Y + at->Z + 1.0f;
  if ( v13 < 0.0f )
    v13 = 0.0f;
  v25 = (float)sqrt(v13) * 0.5f;
  v14 = right->X + 1.0 - up->Y - at->Z;
  if ( v14 < 0.0f)
    v14 = 0.0f;
  v17 = (float)sqrt(v14) * 0.5f;
  v16 = 1.0f - right->X;
  v15 = up->Y + v16 - at->Z;
  if ( v15 < 0.0f )
    v15 = 0.0f;
  v23 = (float)sqrt(v15) * 0.5f;
  v18 = v16 - up->Y + at->Z;
  if ( v18 < 0.0f )
    v18 = 0.0f;
  v24 = (float)sqrt(v18) * 0.5f;
  if ( v25 < 0.0f )
    v25 = 0.0f;
  if ( v17 < 0.0f )
    v17 = 0.0f;
  if ( v23 < 0.0f )
    v23 = 0.0f;
  if ( v24 < 0.0f )
    v24 = 0.0f;
  v20 = (float)_copysign(v17, at->Y - up->Z);
  v21 = (float)_copysign(v23, right->Z - at->X);
  v22 = (float)_copysign(v24, up->X - right->Y);
  quaterW = v25;
  quaterX = v20;
  quaterY = v21;
  quaterZ = v22;
}

int random(int min, int max)
{
   return (rand() % (max - min+1) + min);
}

float random_float(float a, float b)
{
    float random = ((float) rand()) / (float) RAND_MAX;
    float diff = b - a;
    float r = random * diff;
    return a + r;
}

uint32_t encode_panels(unsigned char flp, unsigned char frp, unsigned char rlp, unsigned char rrp, unsigned char windshield, unsigned char front_bumper, unsigned char rear_bumper)
{
    return flp | (frp << 4) | (rlp << 8) | (rrp << 12) | (windshield << 16) | (front_bumper << 20) | (rear_bumper << 24);
}

uint32_t encode_doors(unsigned char bonnet, unsigned char boot, unsigned char driver_door, unsigned char passenger_door)
{
    return bonnet | (boot << 8) | (driver_door << 16) | (passenger_door << 24);
}