/*****************************************************************************
*
*  PROJECT:     Multi Theft Auto v1.0
*  LICENSE:     See LICENSE in the top level directory
*  FILE:        game_sa/CWeaponSA.h
*  PURPOSE:     Header file for weapon class
*  DEVELOPERS:  Ed Lyons <eai@opencoding.net>
*               Cecill Etheredge <ijsf@gmx.net>
*               Jax <>
*
*  Multi Theft Auto is available from http://www.multitheftauto.com/
*
*****************************************************************************/

#ifndef __CGAMESA_WEAPON
#define __CGAMESA_WEAPON


#include "CGameSA.h"
#include <game/CWeapon.h>
#include <game/CPed.h>

#define FUNC_Shutdown                                   0x73A380
#define FUNC_CWeapon_CheckForShootingVehicleOccupant    0x73f480
#define FUNC_CWeapon_Initialize                         0x73b4a0
#define FUNC_CWeapon_Update                             0x73db40
#define FUNC_CWeapon_Fire                               0x742300
#define FUNC_CWeapon_AddGunshell                        0x73a3e0
#define FUNC_CWeapon_DoBulletImpact                     0x73b550
#define FUNC_CWeapon_GenerateDamageEvent                0x73a530
#define FUNC_CWeapon_FireInstantHit                     0x73FB10

#define FUNC_CWeaponInfo_GetWeaponReloadTime            0x743D70

extern CGameSA * pGame;

class CWeaponSAInterface
{
public:
	eWeaponType		m_eWeaponType;
	eWeaponState	m_eState;
	DWORD			m_nAmmoInClip;
	DWORD			m_nAmmoTotal;
	DWORD			m_nTimer;
	DWORD			m_GoggleMode;
    DWORD           m_IsFiring;
};

class CWeaponSA : public CWeapon
{
private:
	CWeaponSAInterface		* internalInterface;
	CPed					* owner;
	eWeaponSlot 			m_weaponSlot;
public:
	CWeaponSA(CWeaponSAInterface * weaponInterface, CPed * ped, eWeaponSlot weaponSlot);
	eWeaponType		GetType(  );
	VOID			SetType( eWeaponType type );
	eWeaponState	GetState(  );
    void            SetState ( eWeaponState state );
	DWORD			GetAmmoInClip(  );
	VOID			SetAmmoInClip( DWORD dwAmmoInClip );
	DWORD			GetAmmoTotal(  );
	VOID			SetAmmoTotal( DWORD dwAmmoTotal );
	
	CPed			* GetPed();
	eWeaponSlot		GetSlot();

	VOID			SetAsCurrentWeapon();
	CWeaponInfo		* GetInfo() { return pGame->GetWeaponInfo(internalInterface->m_eWeaponType); };

    void            Remove ();

	void			AddGunshell ( CEntity * pFiringEntity, CVector * pvecOrigin, CVector2D * pvecDirection, float fSize );
	void			DoBulletImpact ( CEntity * pFiringEntity, CEntitySAInterface * pEntityInterface, CVector * pvecOrigin, CVector * pvecTarget, CColPoint * pColPoint, int i_1 );
};

#endif