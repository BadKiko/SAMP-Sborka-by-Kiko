#define WIN32_LEAN_AND_MEAN
#include <windows.h>

#include <stdio.h>
#include <stdlib.h>

#include <d3dx9.h>
#pragma comment(lib, "d3d9.lib")
#ifdef _DEBUG
#pragma comment(lib, "d3dx9d.lib")
#else
#pragma comment(lib, "d3dx9.lib")
#endif


struct RWTexture
{
	void* pTexture;
	long dwUnknown04;
	long pPrevious;
	void* pTXDPool;
	char cName[32];
	char cAlpha[32];
	long dwUnknown50;
	long dwReference;
	long dwUnknown58;
};


struct RWMesh
{
	long dwUnknown00;
	long dwUnknown04;
	RWTexture** ppTexture;
	long dwUnknown0C;
	IDirect3DVertexShader9* pVShader;
	long dwBaseIndex;
	long dwNumVertex;
	long dwStartIndex;
	long dwPrimitiveCount;
};

struct RWVertex
{
	void* pGeometry;
	D3DXVECTOR4 fBoudingSphere;
	D3DXVECTOR3* pVertex;
	D3DXVECTOR2* pNormal;
};

struct RWGeometry
{
	long dwUnknown00;
	long dwUnknown04;
	long dwFlag;
	long dwUnknown0C;
	long dwFace;
	long dwVertex;
	long dwUnknown18;
	long dwUnknown1C;
	RWTexture*** pMaterial;
	long dwUnknown24;
	long dwUnknown28;
	short* pIndex;
	long dwUnknown30;
	D3DXVECTOR2* pTextureUV;
	long dwUnknown38;
	long dwUnknown3C;
	long dwUnknown40;
	long dwUnknown44;
	long dwUnknown48;
	long dwUnknown4C;
	long dwUnknown50;
	void* pBinMeshPLG;
	void* pUnknown58;
	RWVertex* pVertex;
	long dwUnknown60;
	void* pUnknown64;
};

struct TexturePair
{
	RWTexture* pTexture;
	RWTexture* pNormal;
	float fBoost;
};


BOOL APIENTRY DllMain(HMODULE, DWORD, LPVOID);

void DLLInit();
void DLLExit();

void InitResource();
void DestResource();

void D3DLost();
void D3DReset();

void Change3D();
long dwChange3DCall = NULL;

void Reset3D();
long dwReset3DCall = NULL;

void AddTexture();
void RefTexture();
void RefTexture();
void DestTexture();
void DestTexture_Org();

void ListAdd(RWTexture* pTexture);
void ListRef(RWTexture* pTexture);
void ListDel(RWTexture* pTexture);

void SkinDecl();
void SkinDecl_Org();
void SkinInst();
void SkinInst_Org();
void Tangent(float* pBuffer, RWGeometry* pGeometry, long dwStride);

void CPed_RW_Draw();
void CPed_RW_Draw_Org();
void CPed_RW_SetFA();
void CPed_RW_SetFA_Org();

void Camo_CopySetting(RWMesh* pMesh);


#define SAFE_RELEASE(p) {if(p){(p)->Release();(p)=NULL;}}
#define SAFE_DELETE(p) {if(p){delete (p);(p)=NULL;}}
#define SAFE_FREE(p) {if(p){free(p);(p)=NULL;}}

#define patch(a, v, s) _patch((void*)(a), (void*)(v), (s))
void _patch(void*, void*, int);
#define nop(a, s) _nop((void*)(a), (s))
void _nop(void*, int);
bool check(void*, unsigned char, const char*, bool);
bool _check(void*, unsigned char);

void _patch(void* pAddress, void* pData, int iSize)
{
	unsigned long dwProtect[2];
	VirtualProtect(pAddress, iSize, PAGE_EXECUTE_READWRITE, &dwProtect[0]);
	memcpy(pAddress, pData, iSize);
	VirtualProtect(pAddress, iSize, dwProtect[0], &dwProtect[1]);
}

void _nop(void* pAddress, int iSize)
{
	unsigned long dwProtect[2];
	VirtualProtect(pAddress, iSize, PAGE_EXECUTE_READWRITE, &dwProtect[0]);
	memset(pAddress, 0x90, iSize);
	VirtualProtect(pAddress, iSize, dwProtect[0], &dwProtect[1]);
}

bool check(void* pAddress, unsigned char cByte, const char* sExp, bool bContinue)
{
	if (_check(pAddress, cByte)) return true;
	if (bContinue) return false;
	char buf[1024];
	sprintf_s(buf, 1024, "An unknown code found at 0x%08X (%s).\nDo you want to continue without this Function?", pAddress, sExp);
	if (MessageBox(0, buf, "Normal Map", MB_YESNO | MB_ICONERROR | MB_DEFBUTTON2) == IDNO) ExitProcess(0);
	return false;
}

bool _check(void* pAddress, unsigned char cByte)
{
	unsigned long dwProtect[2];
	unsigned char cValue = cByte;
	VirtualProtect(pAddress, 1, PAGE_EXECUTE_READ, &dwProtect[0]);
	memcpy(&cValue, pAddress, 1);
	VirtualProtect(pAddress, 1, dwProtect[0], &dwProtect[1]);
	return (cValue == cByte);
}
