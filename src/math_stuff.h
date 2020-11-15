#ifndef M_PI
#define M_PI	3.14159265358979323844f
#endif
#define DEGTORAD( Deg ) ( (Deg * M_PI) / 180.0f )

int		near_zero ( float v );
void	vect2_normalize ( const float in[2], float out[2] );
float	vect2_length ( const float in[2] );
int		vect2_near_zero ( const float in[2] );
void	vect2_copy ( const uint8_t in[2], uint8_t out[2] );
void	vect3_zero ( float out[3] );
void	vect3_normalize ( const float in[3], float out[3] );
void	vect3_mult ( const float in[3], float m, float out[3] );
float	vect3_length ( const float in[3] );
void	vect3_div ( const float in[3], float m, float out[3] );
void	vect3_mult ( const float in[3], float m, float out[3] );
void	vect3_invert ( const float in[3], float out[3] );
void	vect3_vect3_mult ( const float in1[3], const float in2[3], float out[3] );
void	vect3_vect3_add ( const float in1[3], const float in2[3], float out[3] );
void	vect3_vect3_sub ( const float in1[3], const float in2[3], float out[3] );
int		vect3_near_zero ( const float in[3] );
void	vect3_copy ( const float in[3], float out[3] );
float	vect3_dist ( const float in1[3], const float in2[3] );
int		vect4_near_zero ( const float in[4] );
void	vect4_copy ( const uint8_t in[4], uint8_t out[4] );
void	vect4_copy ( const float in[4], float out[4] );
void	vect4_zero ( float out[4] );
void	matrix_copy ( const float in[16], float out[16] );
float	vect3_dot_product ( const float in1[3], const float in2[3] );
void	vect3_cross_product ( const float in1[3], const float in2[3], float out[3] );
void	matrix_vect3_mult ( const float matrix[16], const float in[3], float out[3] );
void	matrix_vect4_mult ( const float matrix[16], const float in[4], float out[4] );
void	matrix_matrix_mult ( const float in1[16], const float in2[16], float out[16] );
void	matrix_vect3_rotate ( const float in[16], const float vect[3], float t, float out[16] );
void	matrix_vect3_switchXY ( const float in[16], float out[16] );
void	matrix_identity ( float out[16] );
float	roundf ( float v );

int		project ( const float in[3], const float model[16], const float proj[16], float out[3] );

class tVector
{
public:

	float X, Y, Z;

	tVector()	{ this->X = 0.0f; this->Y = 0.0f; this->Z = 0.0f; };
	tVector ( float a_float_X, float a_float_Y, float a_float_Z )	{ this->X = a_float_X; this->Y = a_float_Y; this->Z = a_float_Z; };

	tVector& operator= ( const tVector& a_Vector ) { this->X = a_Vector.X; this->Y = a_Vector.Y; this->Z = a_Vector.Z; return *this; }

	tVector operator+ ( const tVector& a_Vector ) const { return tVector ( this->X + a_Vector.X, this->Y + a_Vector.Y, this->Z + a_Vector.Z ); }
	tVector& operator+= ( const tVector& a_Vector ) { this->X += a_Vector.X; this->Y += a_Vector.Y; this->Z+= a_Vector.Z; return *this; };

	tVector operator- ( const tVector& a_Vector ) const { return tVector ( this->X - a_Vector.X, this->Y - a_Vector.Y, this->Z - a_Vector.Z ); }
	tVector& operator-= ( const tVector& a_Vector ) { this->X -= a_Vector.X; this->Y -= a_Vector.Y; this->Z -= a_Vector.Z; return *this; };

	tVector operator* ( const tVector& a_Vector ) const { return tVector ( this->X * a_Vector.X, this->Y * a_Vector.Y, this->Z * a_Vector.Z ); }
	tVector& operator*= ( const tVector& a_Vector ) { this->X *= a_Vector.X; this->Y *= a_Vector.Y; this->Z *= a_Vector.Z; return *this; };

	tVector operator/ ( const tVector& a_Vector ) const { return tVector ( this->X / a_Vector.X, this->Y / a_Vector.Y, this->Z / a_Vector.Z ); }
	tVector& operator/= ( const tVector& a_Vector ) { this->X /= a_Vector.X; this->Y /= a_Vector.Y; this->Z /= a_Vector.Z; return *this; };

	tVector operator/ ( const float a_Value ) const { return tVector ( this->X / a_Value, this->Y / a_Value, this->Z / a_Value ); }
	tVector& operator/= ( const float a_Value ) { this->X /= a_Value; this->Y /= a_Value; this->Z /= a_Value; return *this; };

	float GetLength ( void )
	{
		return sqrt ( X * X + Y * Y + Z * Z );
	};
		
	float GetDistanceFrom ( tVector* a_Vector )
	{
		return tVector ( X - a_Vector->X, Y - a_Vector->Y, Z - a_Vector->Z ).GetLength();
	}
};

typedef struct QuaternionVector_t
{
	float W, X, Y, Z;
} tQuaternionVector;

void QuaternionToMatrix( float &quaterW, float &quaterX, float &quaterY, float &quaterZ, tVector* right, tVector* up, tVector* at );
void MatrixToQuaternion( tVector* right, tVector* up, tVector* at, float &quaterW, float &quaterX, float &quaterY, float &quaterZ );

int random(int min, int max);
float random_float(float a, float b);

uint32_t encode_panels(unsigned char flp, unsigned char frp, unsigned char rlp, unsigned char rrp, unsigned char windshield, unsigned char front_bumper, unsigned char rear_bumper);
uint32_t encode_doors(unsigned char bonnet, unsigned char boot, unsigned char driver_door, unsigned char passenger_door);