#include "normalmap.h"

bool bShaderOverride = false;

TexturePair* pTexturePool = NULL;
RWTexture* pLastTexture;
long dwTexturePoolSize;

float fAmbientMultiply;
float fDiffuseMultiply;
float fShaderSetting[4];
long dwShaderVer;

DWORD* pNormVShaderCode;
DWORD* pNormPShaderCode;

IDirect3DVertexShader9* pNormVShader;
IDirect3DPixelShader9* pNormPShader;


BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved)
{
	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
		DLLInit();
		break;
	case DLL_THREAD_ATTACH:
		break;
	case DLL_THREAD_DETACH:
		break;
	case DLL_PROCESS_DETACH:
		DLLExit();
		break;
	}
	return TRUE;
}


void DLLInit()
{
	char cPath[MAX_PATH];
	char cStr[256];
	FILE* file;

	GetModuleFileName(NULL, cPath, MAX_PATH);
	if (strrchr(cPath, '\\')) *(char*)(strrchr(cPath, '\\') + 1) = '\0';
	strcat_s(cPath, MAX_PATH, "normalmap.ini");
	if (fopen_s(&file, cPath, "rt"))
	{
		MessageBox(0, "File Not Found: normalmap.ini", "Normal Map", MB_OK | MB_ICONERROR);
		ExitProcess(0);
	}
	fclose(file);

	GetPrivateProfileString("LIGHTING", "AmbientMultiply", "1.5", cStr, 256, cPath);
	fAmbientMultiply = (float)atof(cStr);
	GetPrivateProfileString("LIGHTING", "DiffuseMultiply", "3.0", cStr, 256, cPath);
	fDiffuseMultiply = (float)atof(cStr);
	GetPrivateProfileString("SHADER", "SpecularExpMax", "10.0", cStr, 256, cPath);
	fShaderSetting[1] = (float)atof(cStr) - 1.0f;
	GetPrivateProfileString("SHADER", "FresnelRangeMin", "0.25", cStr, 256, cPath);
	fShaderSetting[2] = (float)atof(cStr);
	GetPrivateProfileString("SHADER", "FresnelRangeMax", "2.0", cStr, 256, cPath);
	fShaderSetting[3] = (float)atof(cStr) - fShaderSetting[2];
	dwShaderVer = min(max(GetPrivateProfileInt("VERSION", "ShaderVersion", 1, cPath), 0), 2);

	const unsigned char cCall = 0xE8;
	const unsigned char cJump = 0xE9;
	unsigned long pFunc;

	if (check((void*)0x7F8704, 0x68, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Change3D - 0x7F8709;
		patch(0x7F8704, &cCall, 1);
		patch(0x7F8705, &pFunc, 4);
		nop(0x7F8709, 4);
	} else
	if (check((void*)0x7F86C4, 0x68, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Change3D - 0x7F86C9;
		patch(0x7F86C4, &cCall, 1);
		patch(0x7F86C5, &pFunc, 4);
		nop(0x7F86C9, 4);
	} else
	if (check((void*)0x7F8704, 0xE8, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Change3D - 0x7F8709;
		dwChange3DCall = *(long*)0x7F8705 + 0x7F8709;
		patch(0x7F8704, &cCall, 1);
		patch(0x7F8705, &pFunc, 4);
		nop(0x7F8709, 4);
	} else
	if (check((void*)0x7F86C4, 0xE8, "IDirect3DDevice9::Reset", false))
	{
		pFunc = (unsigned long)&Change3D - 0x7F86C9;
		dwChange3DCall = *(long*)0x7F86C5 + 0x7F86C9;
		patch(0x7F86C4, &cCall, 1);
		patch(0x7F86C5, &pFunc, 4);
		nop(0x7F86C9, 4);
	}

	if (check((void*)0x7F9750, 0x68, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F9755;
		patch(0x7F9750, &cCall, 1);
		patch(0x7F9751, &pFunc, 4);
		nop(0x7F9755, 6);
	} else
	if (check((void*)0x7F9710, 0x68, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F9715;
		patch(0x7F9710, &cCall, 1);
		patch(0x7F9711, &pFunc, 4);
		nop(0x7F9715, 6);
	} else
	if (check((void*)0x7F9750, 0xE8, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F9755;
		dwReset3DCall = *(long*)0x7F9751 + 0x7F9755;
		patch(0x7F9750, &cCall, 1);
		patch(0x7F9751, &pFunc, 4);
		nop(0x7F9755, 6);
	} else
	if (check((void*)0x7F9710, 0xE8, "IDirect3DDevice9::Reset", false))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F9715;
		dwReset3DCall = *(long*)0x7F9711 + 0x7F9715;
		patch(0x7F9710, &cCall, 1);
		patch(0x7F9711, &pFunc, 4);
		nop(0x7F9715, 6);
	}

	if (check((void*)0x7F97C8, 0x68, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F97CD;
		patch(0x7F97C8, &cCall, 1);
		patch(0x7F97C9, &pFunc, 4);
		nop(0x7F97CD, 6);
	} else
	if (check((void*)0x7F9788, 0x68, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F978D;
		patch(0x7F9788, &cCall, 1);
		patch(0x7F9789, &pFunc, 4);
		nop(0x7F978D, 6);
	} else
	if (check((void*)0x7F97C8, 0xE8, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F97CD;
		dwReset3DCall = *(long*)0x7F97C9 + 0x7F97CD;
		patch(0x7F97C8, &cCall, 1);
		patch(0x7F97C9, &pFunc, 4);
		nop(0x7F97CD, 6);
	} else
	if (check((void*)0x7F9788, 0xE8, "IDirect3DDevice9::Reset", false))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F978D;
		dwReset3DCall = *(long*)0x7F9789 + 0x7F978D;
		patch(0x7F9788, &cCall, 1);
		patch(0x7F9789, &pFunc, 4);
		nop(0x7F978D, 6);
	}

	if (check((void*)0x7F9A56, 0x68, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F9A5B;
		patch(0x7F9A56, &cCall, 1);
		patch(0x7F9A57, &pFunc, 4);
		nop(0x7F9A5B, 6);
	} else
	if (check((void*)0x7F9A16, 0x68, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F9A1B;
		patch(0x7F9A16, &cCall, 1);
		patch(0x7F9A17, &pFunc, 4);
		nop(0x7F9A1B, 6);
	} else
	if (check((void*)0x7F9A56, 0xE8, "IDirect3DDevice9::Reset", true))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F9A5B;
		dwReset3DCall = *(long*)0x7F9A57 + 0x7F9A5B;
		patch(0x7F9A56, &cCall, 1);
		patch(0x7F9A57, &pFunc, 4);
		nop(0x7F9A5B, 6);
	} else
	if (check((void*)0x7F9A16, 0xE8, "IDirect3DDevice9::Reset", false))
	{
		pFunc = (unsigned long)&Reset3D - 0x7F9A1B;
		dwReset3DCall = *(long*)0x7F9A17 + 0x7F9A1B;
		patch(0x7F9A16, &cCall, 1);
		patch(0x7F9A17, &pFunc, 4);
		nop(0x7F9A1B, 6);
	}

	if (check((void*)0x7C9C58, 0x8D, "__rpD3D9SkinAtomicCreateVertexBuffer", true))
	{
		pFunc = (unsigned long)&SkinDecl - 0x7C9C5D;
		patch(0x7C9C58, &cJump, 1);
		patch(0x7C9C59, &pFunc, 4);
	} else
	if (check((void*)0x7C9C18, 0x8D, "__rpD3D9SkinAtomicCreateVertexBuffer", false))
	{
		pFunc = (unsigned long)&SkinDecl_Org - 0x7C9C1D;
		patch(0x7C9C18, &cJump, 1);
		patch(0x7C9C19, &pFunc, 4);
	}
	if (check((void*)0x7C9282, 0x8B, "__rpD3D9SkinGeometryReinstance", true))
	{
		pFunc = (unsigned long)&SkinInst - 0x7C9287;
		patch(0x7C9282, &cJump, 1);
		patch(0x7C9283, &pFunc, 4);
	} else
	if (check((void*)0x7C9242, 0x8B, "__rpD3D9SkinGeometryReinstance", false))
	{
		pFunc = (unsigned long)&SkinInst_Org - 0x7C9247;
		patch(0x7C9242, &cJump, 1);
		patch(0x7C9243, &pFunc, 4);
	}

	if (check((void*)0x4CDDA3, 0x5B, "__rwD3D9NativeTextureRead", false))
	{
		pFunc = (unsigned long)&AddTexture - 0x4CDDA8;
		patch(0x4CDDA3, &cJump, 1);
		patch(0x4CDDA4, &pFunc, 4);
	}
	if (check((void*)0x7F3B26, 0x89, "_RwReadTexture", true))
	{
		pFunc = (unsigned long)&RefTexture - 0x7F3B2B;
		patch(0x7F3B26, &cJump, 1);
		patch(0x7F3B27, &pFunc, 4);
	} else
	if (check((void*)0x7F3AE6, 0x89, "_RwReadTexture", false))
	{
		pFunc = (unsigned long)&RefTexture - 0x7F3AEB;
		patch(0x7F3AE6, &cJump, 1);
		patch(0x7F3AE7, &pFunc, 4);
	}
	if (check((void*)0x7F3834, 0x68, "_RwTextureDestroy", true))
	{
		pFunc = (unsigned long)&DestTexture_Org - 0x7F3839;
		patch(0x7F3834, &cJump, 1);
		patch(0x7F3835, &pFunc, 4);
	} else
	if (check((void*)0x7F3874, 0x68, "_RwTextureDestroy", false))
	{
		pFunc = (unsigned long)&DestTexture - 0x7F3879;
		patch(0x7F3874, &cJump, 1);
		patch(0x7F3875, &pFunc, 4);
	}

	if (check((void*)0x761162, 0x8B, "__rxD3D9VertexShaderDefaultMeshRenderCallBack", true))
	{
		pFunc = (unsigned long)&CPed_RW_Draw - 0x761167;
		patch(0x761162, &cJump, 1);
		patch(0x761163, &pFunc, 4);
	} else
	if (check((void*)0x761112, 0x8B, "__rxD3D9VertexShaderDefaultMeshRenderCallBack", false))
	{
		pFunc = (unsigned long)&CPed_RW_Draw_Org - 0x761117;
		patch(0x761112, &cJump, 1);
		patch(0x761113, &pFunc, 4);
	}
	if (check((void*)0x7C8139, 0x68, "__rpD3D9SkinVertexShaderAtomicRender", true))
	{
		pFunc = (unsigned long)&CPed_RW_SetFA - 0x7C813E;
		patch(0x7C8139, &cJump, 1);
		patch(0x7C813A, &pFunc, 4);
	} else
	if (check((void*)0x7C80F9, 0x68, "__rpD3D9SkinVertexShaderAtomicRender", false))
	{
		pFunc = (unsigned long)&CPed_RW_SetFA - 0x7C80FE;
		patch(0x7C80F9, &cJump, 1);
		patch(0x7C80FA, &pFunc, 4);
	}

	if (!pNormVShader)
	{
		char cPath[MAX_PATH];
		ID3DXBuffer* pBuffer = NULL;
		ID3DXBuffer* pError = NULL;
		GetModuleFileName(NULL, cPath, MAX_PATH);
		if (strrchr(cPath, '\\')) *(char*)(strrchr(cPath, '\\') + 1) = '\0';
		strcat_s(cPath, MAX_PATH, "normalmap_vertex.fxc");
		if (FAILED(D3DXCompileShaderFromFile(cPath, NULL, NULL, "main", dwShaderVer == 2 ? "vs_3_0" : "vs_2_0", D3DXSHADER_OPTIMIZATION_LEVEL3, &pBuffer, &pError, NULL)))
		{
			MessageBox(0, (LPCSTR)pError->GetBufferPointer(), "Normal Map", MB_OK);
			ExitProcess(0);
		}
		pNormVShaderCode = (DWORD*)malloc(pBuffer->GetBufferSize());
		memcpy(pNormVShaderCode, pBuffer->GetBufferPointer(), pBuffer->GetBufferSize());
		SAFE_RELEASE(pBuffer);
		SAFE_RELEASE(pError);
	}

	if (!pNormPShader)
	{
		const D3DXMACRO mShaderVer[3][3] =
		{
			{{"HL_HQ", ""}, {"LIGHTS", "2"}, {NULL, NULL}},
			{{"HL_LQ", ""}, {"LIGHTS", "3"}, {NULL, NULL}},
			{{"HL_HQ", ""}, {"LIGHTS", "4"}, {NULL, NULL}}
		};
		char cPath[MAX_PATH];
		ID3DXBuffer* pBuffer = NULL;
		ID3DXBuffer* pError = NULL;
		GetModuleFileName(NULL, cPath, MAX_PATH);
		if (strrchr(cPath, '\\')) *(char*)(strrchr(cPath, '\\') + 1) = '\0';
		strcat_s(cPath, MAX_PATH, "normalmap_pixel.fxc");
		if (FAILED(D3DXCompileShaderFromFile(cPath, mShaderVer[dwShaderVer], NULL, "main", dwShaderVer == 2 ? "ps_3_0" : "ps_2_0", D3DXSHADER_OPTIMIZATION_LEVEL3, &pBuffer, &pError, NULL)))
		{
			MessageBox(0, (LPCSTR)pError->GetBufferPointer(), "Normal Map", MB_OK);
			ExitProcess(0);
		}
		pNormPShaderCode = (DWORD*)malloc(pBuffer->GetBufferSize());
		memcpy(pNormPShaderCode, pBuffer->GetBufferPointer(), pBuffer->GetBufferSize());
		SAFE_RELEASE(pBuffer);
		SAFE_RELEASE(pError);
	}

	return;
}

void DLLExit()
{
	return;
}


void InitResource()
{
	IDirect3DDevice9* pD3DDev = *(IDirect3DDevice9**)0xC97C28;

	if (!pNormVShader)
	{
/*		char cPath[MAX_PATH];
		ID3DXBuffer* pBuffer = NULL;
		ID3DXBuffer* pError = NULL;
		GetModuleFileName(NULL, cPath, MAX_PATH);
		if (strrchr(cPath, '\\')) *(char*)(strrchr(cPath, '\\') + 1) = '\0';
//		strcat_s(cPath, MAX_PATH, "normalmap.vsh");
		strcat_s(cPath, MAX_PATH, "normalmap_vertex.fxc");
//		if (FAILED(D3DXAssembleShaderFromFile(cPath, NULL, NULL, D3DXSHADER_DEBUG, &pBuffer, &pError)))
		if (FAILED(D3DXCompileShaderFromFile(cPath, NULL, NULL, "main", "vs_2_0", D3DXSHADER_DEBUG, &pBuffer, &pError, NULL)))
		{
			MessageBox(0, (LPCSTR)pError->GetBufferPointer(), "Normal Map", MB_OK);
			ExitProcess(0);
		}*/
		HRESULT hr;
		hr = pD3DDev->CreateVertexShader(pNormVShaderCode, &pNormVShader);
		if (FAILED(hr)) switch (hr)
		{
		case D3DERR_INVALIDCALL:
			MessageBox(0, "CreateVertexShader() : D3DERR_INVALIDCALL", "Normal Map", MB_OK);
			ExitProcess(0);
			break;
		case D3DERR_OUTOFVIDEOMEMORY:
			MessageBox(0, "CreateVertexShader() : D3DERR_OUTOFVIDEOMEMORY", "Normal Map", MB_OK);
			ExitProcess(0);
			break;
		case E_OUTOFMEMORY:
			MessageBox(0, "CreateVertexShader() : E_OUTOFMEMORY", "Normal Map", MB_OK);
			ExitProcess(0);
			break;
		default:
			char cMessage[256];
			sprintf_s(cMessage, 256, "CreateVertexShader() : 0x%08X", hr);
			MessageBox(0, cMessage, "Normal Map", MB_OK);
			ExitProcess(0);
			break;
		}
/*		SAFE_RELEASE(pBuffer);
		SAFE_RELEASE(pError);*/
	}

	if (!pNormPShader)
	{
/*		const D3DXMACRO mShaderVer[4][3] =
		{
			{{"HL_HQ", ""}, {"LIGHTS", "2"}, {NULL, NULL}},
			{{"HL_LQ", ""}, {"LIGHTS", "3"}, {NULL, NULL}},
			{{"HL_HQ", ""}, {"LIGHTS", "4"}, {NULL, NULL}}
		};
		const char* pShaderVer[4] =
		{
			"ps_2_0",
			"ps_2_0",
			"ps_3_0"
		};
		char cPath[MAX_PATH];
		ID3DXBuffer* pBuffer = NULL;
		ID3DXBuffer* pError = NULL;
		GetModuleFileName(NULL, cPath, MAX_PATH);
		if (strrchr(cPath, '\\')) *(char*)(strrchr(cPath, '\\') + 1) = '\0';
//		strcat_s(cPath, MAX_PATH, "normalmap.psh");
		strcat_s(cPath, MAX_PATH, "normalmap_pixel.fxc");
//		if (FAILED(D3DXAssembleShaderFromFile(cPath, NULL, NULL, D3DXSHADER_DEBUG, &pBuffer, &pError)))
		if (FAILED(D3DXCompileShaderFromFile(cPath, mShaderVer[dwShaderVer], NULL, "main", pShaderVer[dwShaderVer], D3DXSHADER_DEBUG, &pBuffer, &pError, NULL)))
		{
			MessageBox(0, (LPCSTR)pError->GetBufferPointer(), "Normal Map", MB_OK);
			ExitProcess(0);
		}*/
		HRESULT hr;
		hr = pD3DDev->CreatePixelShader(pNormPShaderCode, &pNormPShader);
		if (FAILED(hr)) switch (hr)
		{
		case D3DERR_INVALIDCALL:
			MessageBox(0, "CreatePixelShader() : D3DERR_INVALIDCALL", "Normal Map", MB_OK);
			ExitProcess(0);
			break;
		case D3DERR_OUTOFVIDEOMEMORY:
			MessageBox(0, "CreatePixelShader() : D3DERR_OUTOFVIDEOMEMORY", "Normal Map", MB_OK);
			ExitProcess(0);
			break;
		case E_OUTOFMEMORY:
			MessageBox(0, "CreatePixelShader() : E_OUTOFMEMORY", "Normal Map", MB_OK);
			ExitProcess(0);
			break;
		default:
			char cMessage[256];
			sprintf_s(cMessage, 256, "CreatePixelShader() : 0x%08X", hr);
			MessageBox(0, cMessage, "Normal Map", MB_OK);
			ExitProcess(0);
			break;
		}
/*		SAFE_RELEASE(pBuffer);
		SAFE_RELEASE(pError);*/
	}

	return;
}

void DestResource()
{
	SAFE_RELEASE(pNormVShader);
	SAFE_RELEASE(pNormPShader);

	return;
}


void D3DLost()
{
	return;
}

void D3DReset()
{
//	SAFE_RELEASE(pNormVShader);
//	SAFE_RELEASE(pNormPShader);

	return;
}

void __declspec(naked) Change3D()
{
	__asm
	{
		pushad;
		call D3DLost;
		popad;
		test dwChange3DCall, 0xFFFFFFFF;
		jz CALL_REAL;
		mov edi, dwChange3DCall
		call edi;
		jmp CALL_END;

CALL_REAL:
		push 0xC9C040;
		push eax;
		call [ecx+0x40];

CALL_END:
		pushad;
		call D3DReset;
		popad;
		ret;
	}
}

void __declspec(naked) Reset3D()
{
	__asm
	{
		pushad;
		call D3DLost;
		popad;
		test dwReset3DCall, 0xFFFFFFFF;
		jz CALL_REAL;
		mov edi, dwReset3DCall
		call edi;
		jmp CALL_END;

CALL_REAL:
		push 0xC9C040;
		push eax;
		mov edx, [eax];
		call [edx+0x40];

CALL_END:
		pushad;
		call D3DReset;
		popad;
		ret;
	}
}


void __declspec(naked) AddTexture()
{
	__asm
	{
		pushad;
		push dword ptr [edx];
		call ListAdd;
		add esp, 4;
		popad;
		mov edx, [edx];
		mov pLastTexture, edx;
		pop ebx;
		add esp, 0x70;
		ret;
	}
}

void __declspec(naked) RefTexture()
{
	__asm
	{
		pushad;
		push eax;
		call ListRef;
		add esp, 4;
		popad;
		mov [eax+0x54], ecx;
		add esp, 8;
		ret;
	}
}

void __declspec(naked) DestTexture()
{
	__asm
	{
		pushad;
		push esi;
		call ListDel;
		add esp, 4;
		popad;
		push 0x8E23CC;
		push 0x7F3879;
		ret;
	}
}

void __declspec(naked) DestTexture_Org()
{
	__asm
	{
		pushad;
		push esi;
		call ListDel;
		add esp, 4;
		popad;
		push 0x8E23CC;
		push 0x7F3839;
		ret;
	}
}

void ListAdd(RWTexture* pTexture)
{
	if (!pLastTexture) return;
	if (_strnicmp(pTexture->cName + strlen(pLastTexture->cName), "_nrm", 4)) return;
	if (_strnicmp(pTexture->cName, pLastTexture->cName, strlen(pLastTexture->cName))) return;
	for (long i = 0; i < dwTexturePoolSize; i++) if (!pTexturePool[i].pTexture)
	{
		pTexturePool[i].pTexture = pLastTexture;
		pTexturePool[i].pNormal = pTexture;
		pTexturePool[i].fBoost = pTexture->cName + strlen(pLastTexture->cName) + 4 ? (float)atof(pTexture->cName + strlen(pLastTexture->cName) + 4) : 1.0f;
		return;
	}
	pTexturePool = (TexturePair*)realloc(pTexturePool, (dwTexturePoolSize + 16) * sizeof(TexturePair));
	memset(&pTexturePool[dwTexturePoolSize], NULL, 16 * sizeof(TexturePair));
	pTexturePool[dwTexturePoolSize].pTexture = pLastTexture;
	pTexturePool[dwTexturePoolSize].pNormal = pTexture;
	pTexturePool[dwTexturePoolSize].fBoost = pTexture->cName + strlen(pLastTexture->cName) + 4 ? (float)atof(pTexture->cName + strlen(pLastTexture->cName) + 4) : 1.0f;
	dwTexturePoolSize += 16;
	return;
}

void ListRef(RWTexture* pTexture)
{
	for (long i = 0; i < dwTexturePoolSize; i++)
	{
		if (pTexturePool[i].pTexture == pTexture)
		{
			pTexturePool[i].pNormal->dwReference++;
			return;
		}
		if (pTexturePool[i].pNormal == pTexture)
		{
			pTexturePool[i].pTexture->dwReference++;
			return;
		}
	}
}

void ListDel(RWTexture* pTexture)
{
	for (long i = 0; i < dwTexturePoolSize; i++) if (pTexturePool[i].pTexture == pTexture || pTexturePool[i].pNormal == pTexture)
	{
		pTexturePool[i].pTexture->dwReference = 0;
		pTexturePool[i].pNormal->dwReference = 0;
		pTexturePool[i].pTexture = NULL;
		pTexturePool[i].pNormal = NULL;
		return;
	}
}

void __declspec(naked) SkinDecl()
{
	__asm
	{
		mov dx, [ebp+8];
		mov word ptr [esp+esi*8+0x28], 0;
		mov word ptr [esp+esi*8+0x2A], dx;
		mov byte ptr [esp+esi*8+0x2C], 2;
		mov byte ptr [esp+esi*8+0x2D], 0;
		mov byte ptr [esp+esi*8+0x2E], 6;
		mov byte ptr [esp+esi*8+0x2F], 0;
		inc esi;
		add dx, 12;
		mov word ptr [esp+esi*8+0x28], 0;
		mov word ptr [esp+esi*8+0x2A], dx;
		mov byte ptr [esp+esi*8+0x2C], 2;
		mov byte ptr [esp+esi*8+0x2D], 0;
		mov byte ptr [esp+esi*8+0x2E], 7;
		mov byte ptr [esp+esi*8+0x2F], 0;
		inc esi;
		add [ebp+8], 24;
		lea ecx, [esp+0x28];
		push eax;
		push ecx;
		push 0x7C9C5E;
		ret;
	}
}

void __declspec(naked) SkinDecl_Org()
{
	__asm
	{
		mov dx, [ebp+8];
		mov word ptr [esp+esi*8+0x28], 0;
		mov word ptr [esp+esi*8+0x2A], dx;
		mov byte ptr [esp+esi*8+0x2C], 2;
		mov byte ptr [esp+esi*8+0x2D], 0;
		mov byte ptr [esp+esi*8+0x2E], 6;
		mov byte ptr [esp+esi*8+0x2F], 0;
		inc esi;
		add dx, 12;
		mov word ptr [esp+esi*8+0x28], 0;
		mov word ptr [esp+esi*8+0x2A], dx;
		mov byte ptr [esp+esi*8+0x2C], 2;
		mov byte ptr [esp+esi*8+0x2D], 0;
		mov byte ptr [esp+esi*8+0x2E], 7;
		mov byte ptr [esp+esi*8+0x2F], 0;
		inc esi;
		add [ebp+8], 24;
		lea ecx, [esp+0x28];
		push eax;
		push ecx;
		push 0x7C9C1E;
		ret;
	}
}

void __declspec(naked) SkinInst()
{
	__asm
	{
		push [esp+0x10];
		push esi;
		push edi;
		call Tangent;
		add esp, 0x0C;
		mov edx, [ebp+0x14];
		add esp, 0x14;
		push 0x7C9288;
		ret;
	}
}

void __declspec(naked) SkinInst_Org()
{
	__asm
	{
		push [esp+0x10];
		push esi;
		push edi;
		call Tangent;
		add esp, 0x0C;
		mov edx, [ebp+0x14];
		add esp, 0x14;
		push 0x7C9248;
		ret;
	}
}

void Tangent(float* pBuffer, RWGeometry* pGeometry, long dwStride)
{
	short* pIndex = pGeometry->pIndex;
	D3DXVECTOR3* pVertex = pGeometry->pVertex->pVertex;
	D3DXVECTOR2* pUV = pGeometry->pTextureUV;

	float vTangent[3];
	float vBinormal[3];
	float fDet;
	D3DXVECTOR3 vPos[2];
	D3DXVECTOR2 vUV[2];

	for (long i = 0; i < pGeometry->dwFace; i++)
	{
		vPos[0] = pVertex[pIndex[i * 4 + 1]] - pVertex[pIndex[i * 4 + 0]];
		vPos[1] = pVertex[pIndex[i * 4 + 2]] - pVertex[pIndex[i * 4 + 1]];
		vUV[0] = pUV[pIndex[i * 4 + 1]] - pUV[pIndex[i * 4 + 0]];
		vUV[1] = pUV[pIndex[i * 4 + 2]] - pUV[pIndex[i * 4 + 1]];

		for (long j = 0; j < 3; j++)
		{
			fDet = vUV[0].x * vUV[1].y - vUV[0].y *vUV[1].x;
			vTangent[j] = fDet ? -(vUV[0].y * ((float*)&vPos[1])[j] - ((float*)&vPos[0])[j] * vUV[1].y) / fDet : 0.0f;
			vBinormal[j] = fDet ? -(((float*)&vPos[0])[j] * vUV[1].x - vUV[0].x * ((float*)&vPos[1])[j]) / fDet : 0.0f;
		}

		for (long j = 0; j < 3; j++)
		{
			*(D3DXVECTOR3*)&pBuffer[(pIndex[i * 4 + j] + 1) * dwStride / 4 - 6] += *(D3DXVECTOR3*)&vTangent;
			*(D3DXVECTOR3*)&pBuffer[(pIndex[i * 4 + j] + 1) * dwStride / 4 - 3] += *(D3DXVECTOR3*)&vBinormal;
		}
	}

	for (long i = 0; i < pGeometry->dwVertex; i++)
	{
		D3DXVec3Normalize((D3DXVECTOR3*)(pBuffer + (i + 1) * dwStride / 4 - 6), (D3DXVECTOR3*)(pBuffer + (i + 1) * dwStride / 4 - 6));
		D3DXVec3Normalize((D3DXVECTOR3*)(pBuffer + (i + 1) * dwStride / 4 - 3), (D3DXVECTOR3*)(pBuffer + (i + 1) * dwStride / 4 - 3));
	}

	return;
}

void __declspec(naked) CPed_RW_Draw()
{
	__asm
	{
		pushad;
		push esi;
		call Camo_CopySetting;
		add esp, 4;
		popad;
		mov eax, [edi+8];
		test eax, eax;
		push 0x761167;
		ret;
	}
}

void __declspec(naked) CPed_RW_Draw_Org()
{
	__asm
	{
		pushad;
		push esi;
		call Camo_CopySetting;
		add esp, 4;
		popad;
		mov eax, [edi+8];
		test eax, eax;
		push 0x761117;
		ret;
	}
}

void CPed_RW_SetFA_(long dwSlot)
{
	IDirect3DDevice9* pD3DDev = *(IDirect3DDevice9**)0xC97C28;

	D3DXMATRIX mWorld;
	float fShaderData[4];

	((void (*)(D3DXMATRIX*))0x764800)(&mWorld);

	*(D3DXVECTOR3*)(0xC97060 + dwSlot * 0x10) = ((D3DXVECTOR3*)0xB7CA50)[*(long*)0xB79FD0];
	*(float*)(0xC97068 + dwSlot * 0x10) = abs(*(float*)(0xC97068 + dwSlot * 0x10));
	*(D3DXVECTOR3*)(0xC97060 + dwSlot * 0x10) *= -1.0f;
	D3DXVec3TransformNormal((D3DXVECTOR3*)(0xC97060 + dwSlot * 0x10), (D3DXVECTOR3*)(0xC97060 + dwSlot * 0x10), &mWorld);
	*(float*)(0xC97070 + dwSlot * 0x10) = *(float*)0xB7C4AC * *(float*)0xC970E0 * fDiffuseMultiply;
	*(float*)(0xC97074 + dwSlot * 0x10) = *(float*)0xB7C4B0 * *(float*)0xC970E4 * fDiffuseMultiply;
	*(float*)(0xC97078 + dwSlot * 0x10) = *(float*)0xB7C4B4 * *(float*)0xC970E8 * fDiffuseMultiply;
	*(float*)0xC970E0 *= fAmbientMultiply;
	*(float*)0xC970E4 *= fAmbientMultiply;
	*(float*)0xC970E8 *= fAmbientMultiply;

	D3DXVec3TransformCoord((D3DXVECTOR3*)fShaderData, (D3DXVECTOR3*)0xB6F9CC, &mWorld);
	fShaderData[3] = (float)(dwSlot + 1);

	pD3DDev->SetVertexShaderConstantF(255, fShaderData, 1);

	memset(fShaderData, 0, 16);
	for (int i = 0; i < (dwSlot - 5) / 2; i++) pD3DDev->SetPixelShaderConstantF(i, (float*)(0xC97100 + i * 0x20), 1);
	for (int i = (dwSlot - 5) / 2; i < 6; i++) pD3DDev->SetPixelShaderConstantF(i, fShaderData, 1);
	pD3DDev->SetPixelShaderConstantF(14, fShaderSetting, 1);

	return;
}

void __declspec(naked) CPed_RW_SetFA()
{
	__asm
	{
		inc byte ptr [esp+0x18];
		add eax, 2;
		mov [esp], eax;
		pushad;
		push eax;
		call CPed_RW_SetFA_;
		add esp, 4;
		popad;
		push 0xC970A0;
		push 0x7C813E;
		ret;
	}
}

void __declspec(naked) CPed_RW_SetFA_Org()
{
	__asm
	{
		inc byte ptr [esp+0x18];
		add eax, 2;
		mov [esp], eax;
		pushad;
		push eax;
		call CPed_RW_SetFA_;
		add esp, 4;
		popad;
		push 0xC970A0;
		push 0x7C80FE;
		ret;
	}
}


/*
00553260
005E7680
00534310	CEntity__render
00749b70	_RpClumpForAllAtomics
007335b0	_pedRenderCB
007491c0	_AtomicDefaultRenderCallBack
00805710	_RxPipelineExecute
007c7b90	__rwSkinD3D9AtomicAllInOneNode
007c8060	__rpD3D9SkinVertexShaderAtomicRender
00761030	__rxD3D9VertexShaderDefaultMeshRenderCallBack
*/

void Camo_CopySetting(RWMesh* pMesh)
{
	long i;
	for (i = 0; i < dwTexturePoolSize; i++) if (pTexturePool[i].pTexture) if (pTexturePool[i].pTexture == *pMesh->ppTexture)
	{
		((void (*)(RWTexture*, long))0x7FDEB0)(pTexturePool[i].pNormal, 2);
		((void (*)(long, long, long))0x7FC380)(2, 1, 4);
		((void (*)(long, long, long))0x7FC380)(2, 2, 2);
		((void (*)(long, long, long))0x7FC380)(2, 3, 0);
		((void (*)(long, long, long))0x7FC380)(2, 4, 4);
		((void (*)(long, long, long))0x7FC380)(2, 5, 2);
		((void (*)(long, long, long))0x7FC380)(2, 6, 0);
		fShaderSetting[0] = pTexturePool[i].fBoost;
		break;
	}
	if (i == dwTexturePoolSize) return;

	IDirect3DDevice9* pD3DDev = *(IDirect3DDevice9**)0xC97C28;

	InitResource();

	pD3DDev->SetVertexShader(pNormVShader);
	*(IDirect3DVertexShader9**)0x8E2448 = pNormVShader;

	pD3DDev->SetPixelShader(pNormPShader);
	*(IDirect3DPixelShader9**)0x8E244C = pNormPShader;

	return;
}
