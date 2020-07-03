--[[
    Project: SF.lua <https://github.com/imring/SF.lua>
    License: GNU General Public License v3.0
    Authors: look in file <AUTHORS>.

    ------------------------------------------------------------------------------

	MIT License

    Copyright (c) 2018 LUCHARE<luchare.dev@gmail.com>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.

    https://github.com/BlastHackNet/SAMP-API
]]

local ffi = require 'ffi'

require 'SFlua.cdef'
require 'SFlua.bitstream'

ffi.cdef[[
    /*typedef struct SFL_SAMPPools SFL_SAMPPools;
    typedef struct SFL_NetGame SFL_NetGame;
    typedef struct SFL_ServerInfo SFL_ServerInfo;
    typedef struct SFL_ServerPresets SFL_ServerPresets;
    typedef struct SFL_Dialog SFL_Dialog;
    typedef struct SFL_TextDrawTransmit SFL_TextDrawTransmit;
    typedef struct SFL_Textdraw SFL_Textdraw;
    typedef struct SFL_TextdrawPool SFL_TextdrawPool;
    typedef struct SFL_Pickup SFL_Pickup;
    typedef struct SFL_PickupPool SFL_PickupPool;
    typedef struct SFL_PlayerPool SFL_PlayerPool;
    typedef struct SFL_SAMPKeys SFL_SAMPKeys;
    typedef struct SFL_OnFootData SFL_OnFootData;
    typedef struct SFL_InCarData SFL_InCarData;
    typedef struct SFL_AimData SFL_AimData;
    typedef struct SFL_TrailerData SFL_TrailerData;
    typedef struct SFL_PassengerData SFL_PassengerData;
    typedef struct SFL_DamageData SFL_DamageData;
    typedef struct SFL_SurfData SFL_SurfData;
    typedef struct SFL_UnoccupiedData SFL_UnoccupiedData;
    typedef struct SFL_BulletData SFL_BulletData;
    typedef struct SFL_SpectatorData SFL_SpectatorData;
    typedef struct SFL_StatsData SFL_StatsData;
    typedef struct SFL_HeadSync SFL_HeadSync;
    typedef struct SFL_LocalPlayer SFL_LocalPlayer;*/
    typedef struct SFL_RemotePlayer SFL_RemotePlayer;
    /*typedef struct SFL_PlayerInfo SFL_PlayerInfo;*/
    typedef struct SFL_Entity SFL_Entity;
    typedef struct SFL_Ped SFL_Ped;
    /*typedef struct SFL_VehiclePool SFL_VehiclePool;
    typedef struct SFL_SAMPVehicle SFL_SAMPVehicle;
    typedef struct SFL_Object SFL_Object;
    typedef struct SFL_ObjectPool SFL_ObjectPool;
    typedef struct SFL_Gangzone SFL_Gangzone;
    typedef struct SFL_GangzonePool SFL_GangzonePool;
    typedef struct SFL_TextLabel SFL_TextLabel;
    typedef struct SFL_TextLabelPool SFL_TextLabelPool;
    typedef struct SFL_ChatEntry SFL_ChatEntry;*/
    typedef struct SFL_FontRenderer SFL_FontRenderer;
    /*typedef struct SFL_ChatInfo SFL_ChatInfo;*/
    typedef struct SFL_InputBox SFL_InputBox;
    /*typedef struct SFL_InputInfo SFL_InputInfo;
    typedef struct SFL_KillEntry SFL_KillEntry;
    typedef struct SFL_KillInfo SFL_KillInfo;
    typedef struct SFL_ChatPlayer SFL_ChatPlayer;*/
    typedef struct SFL_Audio SFL_Audio;
    /*typedef struct SFL_GameInfo SFL_GameInfo;
    typedef struct SFL_ScoreboardInfo SFL_ScoreboardInfo;
    typedef struct SFL_ActorPool SFL_ActorPool;
    typedef struct SFL_ChatBubbleInfo SFL_ChatBubbleInfo;
    typedef struct SFL_StreamedOutPlayerInfo SFL_StreamedOutPlayerInfo;*/
    typedef struct SFL_Camera SFL_Camera;

    typedef struct SFL_NetGame            SFL_NetGame;
    typedef struct SFL_Settings           SFL_Settings;
    typedef struct SFL_Pools              SFL_Pools;
    typedef struct SFL_Dialog             SFL_Dialog;
    typedef struct SFL_RakClientInterface SFL_RakClientInterface;
    typedef struct SFL_TextDraw           SFL_TextDraw;
    typedef struct SFL_TextDrawPool       SFL_TextDrawPool;
    typedef struct SFL_TextDrawTransmit   SFL_TextDrawTransmit;
    typedef struct SFL_Pickup             SFL_Pickup;
    typedef struct SFL_WeaponPickup       SFL_WeaponPickup;
    typedef struct SFL_PickupPool         SFL_PickupPool;
    typedef struct SFL_PlayerPool         SFL_PlayerPool;
    typedef struct SFL_LocalPlayer        SFL_LocalPlayer;
    typedef struct SFL_PlayerInfo         SFL_PlayerInfo;
    typedef struct SFL_Audio              SFL_Audio;
    typedef struct SFL_Game               SFL_Game;
    typedef struct SFL_Entity             SFL_Entity;
    typedef struct SFL_Ped_Accessory      SFL_Ped_Accessory;
    typedef struct SFL_Ped                SFL_Ped;
    typedef struct SFL_Animation          SFL_Animation;
    
    enum Limits
    {
        SAMP_MAX_ACTORS      = 1000,
        MAX_PLAYERS          = 1004,
        SAMP_MAX_VEHICLES    = 2000,
        MAX_PICKUPS          = 4096,
        SAMP_MAX_OBJECTS     = 1000,
        SAMP_MAX_GANGZONES   = 1024,
        SAMP_MAX_3DTEXTS     = 2048,
        MAX_TEXTDRAWS        = 2048,
        MAX_LOCAL_TEXTDRAWS  = 256,
        SAMP_MAX_CLIENTCMDS  = 144,
        SAMP_MAX_MENUS       = 128,
        SAMP_MAX_PLAYER_NAME = 24,

        MAX_ACCESSORIES = 10
    };
    
    #pragma pack(push, 1)
    
    // CNetGame
    struct SFL_Pools
    {
        struct SFL_ActorPool     *m_pActor;
        struct SFL_ObjectPool    *m_pObject;
        struct SFL_GangzonePool  *m_pGangzone;
        struct SFL_TextLabelPool *m_pLabel;
        struct SFL_TextDrawPool  *m_pTextdraw;
        void                     *m_pMenu;
        struct SFL_PlayerPool    *m_pPlayer;
        struct SFL_VehiclePool   *m_pVehicle;
        struct SFL_PickupPool    *m_pPickup;
    };

    struct SFL_Settings
    {
        bool          m_bUseCJWalk;
        unsigned int  m_nDeadDropsMoney;
        float         m_fWorldBoundaries[4];
        bool          m_bAllowWeapons;
        float         m_fGravity;
        bool          m_bEnterExit;
        BOOL          m_bVehicleFriendlyFire;
        bool          m_bHoldTime;
        bool          m_bInstagib;
        bool          m_bZoneNames;
        bool          m_bFriendlyFire;
        BOOL          m_bClassesAvailable;
        float         m_fNameTagsDrawDist;
        bool          m_bManualVehicleEngineAndLight;
        unsigned char m_nWorldTimeHour;
        unsigned char m_nWorldTimeMinute;
        unsigned char m_nWeather;
        bool          m_bNoNametagsBehindWalls;
        int           m_nPlayerMarkersMode;
        float         m_fChatRadius;
        bool          m_bNameTags;
        bool          m_bLtdChatRadius;
    };
    
    struct SFL_NetGame
    {
        char                    pad_0[32];
        char                    m_szHostAddress[257];
        char                    m_szHostname[257];
        bool                    m_bDisableCollision;
        bool                    m_bUpdateCameraTarget;
        bool                    m_bNametagStatus;
        int                     m_nPort;
        BOOL                    m_bLanMode;
        GTAREF                  m_aMapIcons[100];
        int                     m_nGameState;
        TICK                    m_lastConnectAttempt;
        SFL_Settings           *m_pSettings;
        SFL_RakClientInterface *m_pRakClient;
        SFL_Pools              *m_pPools;
    };
    
    // CDialog
    struct SFL_Dialog
    {
        struct IDirect3DDevice9 *m_pDevice;
        unsigned long            m_position[2];
        unsigned long            m_size[2];
        unsigned long            m_buttonOffset[2];
        struct CDXUTDialog      *m_pDialog;
        struct CDXUTListBox     *m_pListbox;
        struct CDXUTIMEEditBox  *m_pEditbox;
        BOOL                     m_bIsActive;
        int                      m_nType;
        int                      m_nId;
        char                    *m_szText;
        int                      m_textSize[2];
        char                     m_szCaption[65];
        BOOL                     m_bServerside;
    };
    
    // CTextDraw
    struct SFL_TextDrawTransmit
    {
        union
        {
            struct {
                unsigned char m_bBox : 1;
                unsigned char m_bLeft : 1;
                unsigned char m_bRight : 1;
                unsigned char m_bCenter : 1;
                unsigned char m_bProportional : 1;
            };
            unsigned char m_nFlags;
        };
        float          m_fLetterWidth;
        float          m_fLetterHeight;
        D3DCOLOR       m_letterColor;
        float          m_fBoxWidth;
        float          m_fBoxHeight;
        D3DCOLOR       m_boxColor;
        unsigned char  m_nShadow;
        bool           m_bOutline;
        D3DCOLOR       m_backgroundColor;
        unsigned char  m_nStyle;
        unsigned char  unknown;
        float          m_fX;
        float          m_fY;
        unsigned short m_nModel;
        CVector        m_rotation;
        float          m_fZoom;
        unsigned short m_aColor[2];
    };
    
    struct SFL_TextDraw
    {
        char           m_szText[801];
        char           m_szString[1602];
        float          m_fLetterWidth;
        float          m_fLetterHeight;
        D3DCOLOR       m_letterColor;
        unsigned char  unknown;
        unsigned char  m_bCenter;
        unsigned char  m_bBox;
        float          m_fBoxSizeX;
        float          m_fBoxSizeY;
        D3DCOLOR       m_boxColor;
        unsigned char  m_nProportional;
        D3DCOLOR       m_backgroundColor;
        unsigned char  m_nShadow;
        unsigned char  m_nOutline;
        unsigned char  m_bLeft;
        unsigned char  m_bRight;
        int            m_nStyle;
        float          m_fX;
        float          m_fY;
        unsigned char  pad_[8];
        unsigned long  field_99B;
        unsigned long  field_99F;
        unsigned long  m_nIndex;
        unsigned char  field_9A7;
        unsigned short m_nModel;
        CVector        m_rotation;
        float          m_fZoom;
        unsigned short m_aColor[2];
        unsigned char  field_9BE;
        unsigned char  field_9BF;
        unsigned char  field_9C0;
        unsigned long  field_9C1;
        unsigned long  field_9C5;
        unsigned long  field_9C9;
        unsigned long  field_9CD;
        unsigned char  field_9D1;
        unsigned long  field_9D2;
    };
    
    // CTextDrawPool
    struct SFL_TextDrawPool
    {
        BOOL          m_bNotEmpty[MAX_TEXTDRAWS + MAX_LOCAL_TEXTDRAWS];
        SFL_TextDraw *m_pObject[MAX_TEXTDRAWS + MAX_LOCAL_TEXTDRAWS];
    };
    
    // CPickupPool
    struct SFL_Pickup
    {
        int     m_nModel;
        int     m_nType;
        CVector m_position;
    };

    struct SFL_WeaponPickup {
        bool m_bExists;
        ID   m_nExOwner;
    };
    
    struct SFL_PickupPool
    {
        int              m_nCount;
        GTAREF           m_handle[MAX_PICKUPS];
        int              m_nId[MAX_PICKUPS];
        unsigned long    m_nTimer[MAX_PICKUPS];
        SFL_WeaponPickup m_weapon[MAX_PICKUPS];
        SFL_Pickup       m_object[MAX_PICKUPS];
    };
    
    // CPlayerPool
    struct SFL_PlayerPool
    {
        int m_nLargestId;
        struct {
            ID               m_nId;
            int              __align;
            stdstring        m_szName;
            SFL_LocalPlayer *m_pObject;
            int              m_nPing;
            int              m_nScore;
        } m_localInfo;

        SFL_PlayerInfo *m_pObject[MAX_PLAYERS];
        BOOL            m_bNotEmpty[MAX_PLAYERS];
        BOOL            m_bPrevCollisionFlag[MAX_PLAYERS];
    };
    
    struct SFL_SAMPKeys
    {
        BYTE keys_primaryFire : 1;
        BYTE keys_horn__crouch : 1;
        BYTE keys_secondaryFire__shoot : 1;
        BYTE keys_accel__zoomOut : 1;
        BYTE keys_enterExitCar : 1;
        BYTE keys_decel__jump : 1;			// on foot: jump or zoom in
        BYTE keys_circleRight : 1;
        BYTE keys_aim : 1;					// hydra auto aim or on foot aim
        BYTE keys_circleLeft : 1;
        BYTE keys_landingGear__lookback : 1;
        BYTE keys_unknown__walkSlow : 1;
        BYTE keys_specialCtrlUp : 1;
        BYTE keys_specialCtrlDown : 1;
        BYTE keys_specialCtrlLeft : 1;
        BYTE keys_specialCtrlRight : 1;
        BYTE keys__unused : 1;
    };
    
    struct SFL_OnFootData
    {
        WORD					sLeftRightKeys;
        WORD					sUpDownKeys;
        union
        {
            WORD				sKeys;
            struct SFL_SAMPKeys	stSampKeys;
        };
        float					fPosition[3];
        float					fQuaternion[4];
        BYTE					byteHealth;
        BYTE					byteArmor;
        BYTE					byteCurrentWeapon;
        BYTE					byteSpecialAction;
        float					fMoveSpeed[3];
        float					fSurfingOffsets[3];
        WORD					sSurfingVehicleID;
        short					sCurrentAnimationID;
        short					sAnimFlags;
    };
    
    struct SFL_InCarData
    {
        WORD					sVehicleID;
        WORD					sLeftRightKeys;
        WORD					sUpDownKeys;
        union
        {
            WORD				sKeys;
            struct SFL_SAMPKeys	stSampKeys;
        };
        float					fQuaternion[4];
        float					fPosition[3];
        float					fMoveSpeed[3];
        float					fVehicleHealth;
        BYTE					bytePlayerHealth;
        BYTE					byteArmor;
        BYTE					byteCurrentWeapon;
        BYTE					byteSiren;
        BYTE					byteLandingGearState;
        WORD					sTrailerID;
        union
        {
            WORD				HydraThrustAngle[2];	//nearly same value
            float				fTrainSpeed;
        };
    };
    
    struct SFL_AimData
    {
        BYTE					byteCamMode;
        float					vecAimf1[3];
        float					vecAimPos[3];
        float					fAimZ;
        BYTE					byteCamExtZoom : 6;		// 0-63 normalized
        BYTE					byteWeaponState : 2;	// see eWeaponState
        BYTE					bUnk;
    };
    
    struct SFL_TrailerData
    {
        WORD					sTrailerID;
        float					fPosition[3];
        float					fQuaternion[4];
        float					fSpeed[3];
        float					fSpin[3];
    };
    
    struct SFL_PassengerData
    {
        WORD					sVehicleID;
        BYTE					byteSeatID;
        BYTE					byteCurrentWeapon;
        BYTE					byteHealth;
        BYTE					byteArmor;
        WORD					sLeftRightKeys;
        WORD					sUpDownKeys;
        union
        {
            WORD				sKeys;
            struct SFL_SAMPKeys	stSampKeys;
        };
        float					fPosition[3];
    };
    
    struct SFL_DamageData
    {
        WORD					sVehicleID_lastDamageProcessed;
        int						iBumperDamage;
        int						iDoorDamage;
        BYTE					byteLightDamage;
        BYTE					byteWheelDamage;
    };
    
    struct SFL_SurfData
    {
        int						iIsSurfing;
        float					fSurfPosition[3];
        int						iUnk0;
        WORD					sSurfingVehicleID;
        DWORD					ulSurfTick;
        struct SFL_SAMPVehicle	*pSurfingVehicle;
        int						iUnk1;
        int						iSurfMode;	//0 = not surfing, 1 = moving (unstable surf), 2 = fixed on vehicle
    };
    
    struct SFL_UnoccupiedData
    {
        int16_t					sVehicleID;
        BYTE					byteSeatID;
        float					fRoll[3];
        float					fDirection[3];
        float					fPosition[3];
        float					fMoveSpeed[3];
        float					fTurnSpeed[3];
        float					fHealth;
    };
    
    struct SFL_BulletData
    {
        BYTE					byteType;
        WORD					sTargetID;
        float					fOrigin[3];
        float					fTarget[3];
        float					fCenter[3];
        BYTE					byteWeaponID;
    };
    
    struct SFL_SpectatorData
    {
        WORD					sLeftRightKeys;
        WORD					sUpDownKeys;
        union
        {
            WORD				sKeys;
            struct SFL_SAMPKeys	stSampKeys;
        };
        float					fPosition[3];
    };
    
    struct SFL_StatsData
    {
        int						iMoney;
        int						iAmmo;
    };
    
    struct SFL_HeadSync
    {
        float					fHeadSync[3];
        int						iHeadSyncUpdateTick;
        int						iHeadSyncLookTick;
    };
    
    // Animation.h
    struct SFL_Animation {
        union {
            struct {
                unsigned short m_nId : 16;
                unsigned char  m_nFramedelta : 8;
                unsigned char  m_nLoopA : 1;
                unsigned char  m_nLockX : 1;
                unsigned char  m_nLockY : 1;
                unsigned char  m_nLockF : 1;
                unsigned char  m_nTime : 2;
            };
            int m_value;
        };
    };
    

    struct SFL_LocalPlayer
    {
        SFL_Ped *m_pPed;
        WORD					sCurrentAnimID;
        WORD					sAnimFlags;
        DWORD					ulUnk0;
        int						iIsActive;
        int						iIsWasted;
        WORD					sCurrentVehicleID;
        WORD					sLastVehicleID;
        struct SFL_OnFootData		onFootData;
        struct SFL_PassengerData	passengerData;
        struct SFL_TrailerData	trailerData;
        struct SFL_InCarData		inCarData;
        struct SFL_AimData		aimData;
        BYTE					byteTeamID;
        int						iSpawnSkin;
        BYTE					byteUnk1;
        float					fSpawnPos[3];
        float					fSpawnRot;
        int						iSpawnWeapon[3];
        int						iSpawnAmmo[3];
        int						iIsActorAlive;
        int						iSpawnClassLoaded;
        DWORD					ulSpawnSelectionTick;
        DWORD					ulSpawnSelectionStart;
        int						iIsSpectating;
        BYTE					byteTeamID2;
        WORD					usUnk2;
        DWORD					ulSendTick;
        DWORD					ulSpectateTick;
        DWORD					ulAimTick;
        DWORD					ulStatsUpdateTick;
        DWORD					ulWeapUpdateTick;
        WORD					sAimingAtPid;
        WORD					usUnk3;
        BYTE					byteCurrentWeapon;
        BYTE					byteWeaponInventory[13];
        int						iWeaponAmmo[13];
        int						iPassengerDriveBy;
        BYTE					byteCurrentInterior;
        int						iIsInRCVehicle;
        WORD					sTargetObjectID;
        WORD					sTargetVehicleID;
        WORD					sTargetPlayerID;
        struct SFL_HeadSync		headSyncData;
        DWORD					ulHeadSyncTick;
        BYTE					byteSpace3[260];
        struct SFL_SurfData		surfData;
        int						iClassSelectionOnDeath;
        int						iSpawnClassID;
        int						iRequestToSpawn;
        int						iIsInSpawnScreen;
        DWORD					ulUnk4;
        BYTE					byteSpectateMode;		// 3 = vehicle, 4 = player, side = 14, fixed = 15
        BYTE					byteSpectateType;		// 0 = none, 1 = player, 2 = vehicle
        int						iSpectateID;
        int						iInitiatedSpectating;
        struct SFL_DamageData		vehicleDamageData;
    };
    
    struct SFL_RemotePlayer
    {
        struct SFL_Ped		*pSAMP_Actor;
        struct SFL_SAMPVehicle	*pSAMP_Vehicle;
        BYTE					byteTeamID;
        BYTE					bytePlayerState;
        BYTE					byteSeatID;
        DWORD					ulUnk3;
        int						iPassengerDriveBy;
        void					*pUnk0;
        BYTE					byteUnk1[60];
        float					fSomething[3];
        float					fVehicleRoll[4];
        DWORD					ulUnk2[3];
        float					fOnFootPos[3];
        float					fOnFootMoveSpeed[3];
        float					fVehiclePosition[3];
        float					fVehicleMoveSpeed[3];
        WORD					sPlayerID;
        WORD					sVehicleID;
        DWORD					ulUnk5;
        int						iShowNameTag;
        int						iHasJetPack;
        BYTE					byteSpecialAction;
        DWORD					ulUnk4[3];
        struct SFL_OnFootData	onFootData;
        struct SFL_InCarData	inCarData;
        struct SFL_TrailerData	trailerData;
        struct SFL_PassengerData	passengerData;
        struct SFL_AimData		aimData;
        float					fActorArmor;
        float					fActorHealth;
        DWORD					ulUnk10;
        BYTE					byteUnk9;
        DWORD					dwTick;
        DWORD					dwLastStreamedInTick;	// is 0 when currently streamed in
        DWORD					ulUnk7;
        int						iAFKState;
        struct SFL_HeadSync		headSyncData;
        int						iGlobalMarkerLoaded;
        int						iGlobalMarkerLocation[3];
        DWORD					ulGlobalMarker_GTAID;
    };
    
    // CPlayerInfo
    struct SFL_PlayerInfo
    {
        SFL_RemotePlayer *m_pPlayer;
        BOOL              m_bIsNPC;
        unsigned int      __align;
        stdstring         m_szNick;
        int               m_nScore;
        unsigned int      m_nPing;
    };
    
    // CEntity
    struct SFL_Entity
    {
        void          **m_lpVtbl;
        char            pad_4[60];
        struct CEntity *m_pGameEntity;
        GTAREF          m_handle;
    };
    
    // CPed
    struct SFL_Ped_Accessory {
        int      m_nModel;
        int      m_nBone;
        CVector  m_offset;
        CVector  m_rotation;
        CVector  m_scale;
        D3DCOLOR m_firstMaterialColor;
        D3DCOLOR m_secondMaterialColor;
    };

    struct SFL_Ped
    {
        SFL_Entity entity;
        BOOL       m_bUsingCellphone;

        struct {
            BOOL              m_bNotEmpty[MAX_ACCESSORIES];
            SFL_Ped_Accessory m_info[MAX_ACCESSORIES];
            struct CObject   *m_pObject[MAX_ACCESSORIES];
        } m_accessories;

        struct CPed *m_pGamePed;
        int          pad_2a8[2];
        NUMBER       m_nPlayerNumber;
        int          pad_2b1[2];
        GTAREF       m_parachuteObject;
        GTAREF       m_urinatingParticle;

        struct {
            int    m_nType;
            GTAREF m_object;
            int    m_nDrunkLevel;
        } m_stuff;

        GTAREF m_arrow;
        char   field_2de;
        BOOL   m_bIsDancing;
        int    m_nDanceStyle;
        int    m_nLastDanceMove;
        char   pad_2de[20];
        BOOL   m_bIsUrinating;
        char   pad[55];
    };
    
    struct SFL_VehiclePool
    {
        int						iVehicleCount;
        void					*pUnk0;
        BYTE					byteSpace1[0x112C];
        struct SFL_SAMPVehicle	*pSAMP_Vehicle[SAMP_MAX_VEHICLES];
        int						iIsListed[SAMP_MAX_VEHICLES];
        struct SFL_SAMPVehicle	*pGTA_Vehicle[SAMP_MAX_VEHICLES];
        BYTE					byteSpace2[SAMP_MAX_VEHICLES * 6];
        DWORD					ulShit[SAMP_MAX_VEHICLES];
        int						iIsListed2[SAMP_MAX_VEHICLES];
        DWORD					byteSpace3[SAMP_MAX_VEHICLES * 2];
        float					fSpawnPos[SAMP_MAX_VEHICLES][3];
        int						iInitiated;
    };
    
    struct SFL_SAMPVehicle
    {
        SFL_Entity			vehicle_info;
        DWORD					bUnk0;
        struct vehicle_info		*pGTA_Vehicle;
        BYTE					byteUnk1[8];
        int						bIsMotorOn;
        int						iIsLightsOn;
        int						iIsLocked;
        BYTE					byteIsObjective;
        int						iObjectiveBlipCreated;
        BYTE					byteUnk2[16];
        BYTE					byteColor[2];
        int						iColorSync;
        int						iColor_something;
    };
    
    struct SFL_Object
    {
        SFL_Entity			object_info;
        BYTE					byteUnk0[2];
        DWORD					ulUnk1;
        int						iModel;
        WORD					byteUnk2;
        float					fDrawDistance;
        float					fUnk;
        float					fPos[3];
        BYTE					byteUnk3[68];
        BYTE					byteUnk4;
        float					fRot[3];
    };
    
    struct SFL_ObjectPool
    {
        int						iObjectCount;
        int						iIsListed[SAMP_MAX_OBJECTS];
        struct SFL_Object			*object[SAMP_MAX_OBJECTS];
    };
    
    struct SFL_Gangzone
    {
        float					fPosition[4];
        DWORD					dwColor;
        DWORD					dwAltColor;
    };
    
    struct SFL_GangzonePool
    {
        struct SFL_Gangzone		*pGangzone[SAMP_MAX_GANGZONES];
        int						iIsListed[SAMP_MAX_GANGZONES];
    };
    
    struct SFL_TextLabel
    {
        PCHAR					pText;
        DWORD					color;
        float					fPosition[3];
        float					fMaxViewDistance;
        BYTE					byteShowBehindWalls;
        WORD					sAttachedToPlayerID;
        WORD					sAttachedToVehicleID;
    };
    
    struct SFL_TextLabelPool
    {
        struct SFL_TextLabel		textLabel[SAMP_MAX_3DTEXTS];
        int						iIsListed[SAMP_MAX_3DTEXTS];
    };
    
    struct SFL_ChatEntry
    {
        DWORD					SystemTime;
        char					szPrefix[28];
        char					szText[144];
        BYTE					unknown[64];
        int						iType;			// 2 - text + prefix, 4 - text (server msg), 8 - text (debug)
        DWORD					clTextColor;
        DWORD					clPrefixColor;	// or textOnly colour
    };
    
    struct SFL_FontRenderer
    {
        ID3DXFont				*m_pChatFont;
        ID3DXFont				*m_pLittleFont;
        ID3DXFont				*m_pChatShadowFont;
        ID3DXFont				*m_pLittleShadowFont;
        ID3DXFont				*m_pCarNumberFont;
        void 					*m_pTempSprite;
        void					*m_pD3DDevice;
        PCHAR					m_pszTextBuffer;
    };
    
    struct SFL_ChatInfo
    {
        int						pagesize;
        PCHAR					pLastMsgText;
        int						iChatWindowMode;
        BYTE					bTimestamps;
        DWORD					m_iLogFileExist;
        char					logFilePathChatLog[260 + 1];
        void					*pGameUI; // CDXUTDialog
        void					*pEditBackground; // CDXUTEditBox
        void					*pDXUTScrollBar;
        D3DCOLOR				clTextColor;
        D3DCOLOR				clInfoColor;
        D3DCOLOR				clDebugColor;
        DWORD					m_lChatWindowBottom;
        struct SFL_ChatEntry	chatEntry[100];
        SFL_FontRenderer		*m_pFontRenderer;
        void					*m_pChatTextSprite;
        void					*m_pSprite;
        void					*m_pD3DDevice;
        int						m_iRenderMode; // 0 - Direct Mode (slow), 1 - Normal mode
        void					*pID3DXRenderToSurface;
        void					*m_pTexture;
        void					*pSurface;
        void					*pD3DDisplayMode;
        int						iUnk1[3];
        int						iUnk2; // smth related to drawing in direct mode
        int						m_iRedraw;
        int						m_nPrevScrollBarPosition;
        int						m_iFontSizeY;
        int						m_iTimestampWidth;
    };
    
    struct SFL_InputBox
    {
        void					*pUnknown;
        BYTE					bIsChatboxOpen;
        BYTE					bIsMouseInChatbox;
        BYTE					bMouseClick_related;
        BYTE					unk;
        DWORD					dwPosChatInput[2];
        BYTE					unk2[263];
        int						iCursorPosition;
        BYTE					unk3;
        int						iMarkedText_startPos; // Highlighted text between this and iCursorPosition
        BYTE					unk4[20];
        int						iMouseLeftButton;
    };
    
    struct SFL_InputInfo
    {
        void					*pD3DDevice;
        void					*pDXUTDialog;
        SFL_InputBox				*pDXUTEditBox;
        CMDPROC					pCMDs[SAMP_MAX_CLIENTCMDS];
        char					szCMDNames[SAMP_MAX_CLIENTCMDS][33];
        int						iCMDCount;
        int						iInputEnabled;
        char					szInputBuffer[129];
        char					szRecallBufffer[10][129];
        char					szCurrentBuffer[129];
        int						iCurrentRecall;
        int						iTotalRecalls;
        CMDPROC					pszDefaultCMD;
    };
    
    struct SFL_KillEntry
    {
        char					szKiller[25];
        char					szVictim[25];
        D3DCOLOR				clKillerColor;
        D3DCOLOR				clVictimColor;
        BYTE					byteType;
    };
    
    struct SFL_KillInfo
    {
        int						iEnabled;
        struct SFL_KillEntry	killEntry[5];
        int 					iLongestNickLength;
          int 					iOffsetX;
          int 					iOffsetY;
        ID3DXFont				*pD3DFont;
        ID3DXFont				*pWeaponFont1;
        ID3DXFont				*pWeaponFont2;
        void					*pSprite;
        void					*pD3DDevice;
        int 					iAuxFontInited;
          ID3DXFont 				*pAuxFont1;
          ID3DXFont 				*pAuxFont2;
    };
    
    struct SFL_ChatPlayer
    {
        int						iCreated;
        char					probablyTheText[256];
        DWORD					dwTickCreated;
        DWORD					dwLiveLength;
        DWORD					dwColor;
        float					fDrawDistance;
        DWORD					dwUnknown;
    };
    
    struct SFL_Audio
    {
        BOOL m_bSoundLoaded;
    };
    
    struct SFL_Camera
    {
        SFL_Entity* m_pAttachedTo;
        CMatrix* m_pMatrix;
    };
    
    // CGame
    struct SFL_Game
    {
        SFL_Audio  *m_pAudio;
        SFL_Camera *m_pCamera;
        SFL_Ped    *m_pPlayerPed;

        struct {
            CVector m_position;
            CVector m_size;
            BOOL    m_bEnabled;
            GTAREF  m_handle;
        } m_checkpoint;    

        struct {
            CVector m_currentPosition;
            CVector m_nextPosition;
            float   m_fSize;
            char    m_nType;
            BOOL    m_bEnabled;
            GTAREF  m_marker;
            GTAREF  m_handle;
        } m_racingCheckpoint;

        int          m_nCursorMode;
        unsigned int m_nInputEnableWaitFrames;
        BOOL         m_bClockEnabled;
        int          field_61;
        BOOL         m_bHeadMove;
        int          m_nFrameLimiter;
        char         field_6d;
        bool         m_aKeepLoadedVehicleModels[212];
    };
    
    struct SFL_ScoreboardInfo
    {
        int						iIsEnabled;
        int						iPlayersCount;
        float					fTextOffset[2];
        float					fScalar;
        float					fSize[2];
        float					fUnk0[5];
        void					*pDirectDevice;
        void					*pDialog;
        void 					*pList;
        int						iOffset;		// ?
        int						iIsSorted;		// ?
    };
    
    struct SFL_ActorPool
    {
        int     m_nLargestId;
        SFL_Entity			*pActor[SAMP_MAX_ACTORS]; // ?
        int						iIsListed[SAMP_MAX_ACTORS];
        struct SFL_Ped		*pGTAPed[SAMP_MAX_ACTORS];
        DWORD					ulUnk0[SAMP_MAX_ACTORS];
        DWORD					ulUnk1[SAMP_MAX_ACTORS];
    };
    
    struct SFL_ChatBubbleInfo
    {
        struct SFL_ChatPlayer	chatBubble[MAX_PLAYERS];
    };
    
    struct SFL_StreamedOutPlayerInfo
    {
        bool					iIsListed[MAX_PLAYERS];
        float					fPlayerPos[MAX_PLAYERS][3];
    };

    struct SFL_RakClientInterface_vtbl {
        void *destructor, *Connect, *Disconnect, *InitializeSecurity, *SetPassword,
             *HasPassword, *Send1;

        bool(__thiscall *Send2)(SFL_RakClientInterface *this, SFL_BitStream *bitStream, int priority, int reliability, char orderingChannel);

        void *Receive, *DeallocatePacket, *PingServer1, *PingServer2, *GetAveragePing,
             *GetLastPing, *GetLowestPing, *GetPlayerPing, *StartOccasionalPing,
             *StopOccasionalPing, *IsConnected, *GetSynchronizedRandomInteger,
             *GenerateCompressionLayer, *DeleteCompressionLayer, *RegisterAsRemoteProcedureCall,
             *RegisterClassMemberRPC, *UnregisterAsRemoteProcedureCall, *RPC1;

        bool(__thiscall *RPC2)(SFL_RakClientInterface *this, int *uniqueID, SFL_BitStream *bitStream, int priority, int reliability, char orderingChannel, bool shiftTimestamp);

        void *RPC3, *SetTrackFrequencyTable, *GetSendFrequencyTable, *GetCompressionRatio,
             *GetDecompressionRatio, *AttachPlugin, *DetachPlugin, *GetStaticServerData,
             *SetStaticServerData, *GetStaticClientData, *SetStaticClientData,
             *SendStaticClientDataToServer, *GetServerID, *GetPlayerID, *GetInternalID,
             *PlayerIDToDottedIP, *PushBackPacket, *SetRouterInterface, *RemoveRouterInterface,
             *SetTimeoutTime, *SetMTUSize, *GetMTUSize, *AllowConnectionResponseIPMigration,
             *AdvertiseSystem, *GetStatistics, *ApplyNetworkSimulator, *IsNetworkSimulatorActive,
             *GetPlayerIndex;
    };

    struct SFL_RakClientInterface {
        struct SFL_RakClientInterface_vtbl *vtbl;
    };
]]