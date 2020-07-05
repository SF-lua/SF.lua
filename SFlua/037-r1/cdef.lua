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
    typedef struct SFL_ControllerState    SFL_ControllerState;
    typedef struct SFL_IncarData          SFL_IncarData;
    typedef struct SFL_OnfootData         SFL_OnfootData;
    typedef struct SFL_AimData            SFL_AimData;
    typedef struct SFL_TrailerData        SFL_TrailerData;
    typedef struct SFL_PassengerData      SFL_PassengerData;
    typedef struct SFL_UnoccupiedData     SFL_UnoccupiedData;
    typedef struct SFL_BulletData         SFL_BulletData;
    typedef struct SFL_SpectatorData      SFL_SpectatorData;
    typedef struct SFL_StatsData          SFL_StatsData;
    typedef struct SFL_RemotePlayer       SFL_RemotePlayer;
    typedef struct SFL_VehicleInfo        SFL_VehicleInfo;
    typedef struct SFL_Vehicle            SFL_Vehicle;
    typedef struct SFL_ObjectPool         SFL_ObjectPool;
    typedef struct SFL_GangzonePool       SFL_GangzonePool;
    typedef struct SFL_LabelPool          SFL_LabelPool;
    typedef struct SFL_VehiclePool        SFL_VehiclePool;
    typedef struct SFL_MaterialText       SFL_MaterialText;
    typedef struct SFL_ObjectMaterial     SFL_ObjectMaterial;
    typedef struct SFL_Object             SFL_Object;
    typedef struct SFL_Gangzone           SFL_Gangzone;
    typedef struct SFL_TextLabel          SFL_TextLabel;
    typedef struct SFL_ChatEntry          SFL_ChatEntry;
    typedef struct SFL_Chat               SFL_Chat;
    typedef struct SFL_Input              SFL_Input;
    typedef struct SFL_KillEntry          SFL_KillEntry;
    typedef struct SFL_DeathWindow        SFL_DeathWindow;
    typedef struct SFL_Camera             SFL_Camera;
    
    enum Limits
    {
        SAMP_MAX_ACTORS      = 1000,
        MAX_PLAYERS          = 1004,
        MAX_VEHICLES         = 2000,
        MAX_PICKUPS          = 4096,
        MAX_OBJECTS          = 1000,
        MAX_GANGZONES        = 1024,
        MAX_TEXT_LABELS      = 2048,
        MAX_TEXTDRAWS        = 2048,
        MAX_LOCAL_TEXTDRAWS  = 256,
        MAX_CLIENT_CMDS      = 144,
        SAMP_MAX_MENUS       = 128,
        SAMP_MAX_PLAYER_NAME = 24,

        MAX_ACCESSORIES        = 10,
        WAITING_LIST_SIZE      = 100,
        LICENSE_PLATE_TEXT_LEN = 32,
        MAX_MATERIALS          = 16,
        MAX_MESSAGES           = 100,
        MAX_CMD_LENGTH         = 32,
        MAX_DEATHMESSAGES      = 5
    };
    
    #pragma pack(push, 1)
    
    // CNetGame
    struct SFL_Pools
    {
        void              *m_pActor;
        SFL_ObjectPool    *m_pObject;
        SFL_GangzonePool  *m_pGangzone;
        SFL_LabelPool     *m_pLabel;
        SFL_TextDrawPool  *m_pTextdraw;
        void              *m_pMenu;
        SFL_PlayerPool    *m_pPlayer;
        SFL_VehiclePool   *m_pVehicle;
        SFL_PickupPool    *m_pPickup;
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

    // ControllerState
    struct SFL_ControllerState {
        short m_sLeftStickX; // move/steer left = -128, right = 128
        short m_sLeftStickY; // move back = 128, forwards = -128
        union {
            struct {
                unsigned char m_bLeftShoulder1 : 1;  // fire weapon alt
                unsigned char m_bShockButtonL : 1;   // crouch
                unsigned char m_bButtonCircle : 1;   // fire weapon
                unsigned char m_bButtonCross : 1;    // sprint, accelerate
                unsigned char m_bButtonTriangle : 1; // enter/exit vehicle
                unsigned char m_bButtonSquare : 1;   // jump, reverse
                unsigned char m_bRightShoulder2 : 1; // look right (incar)
                unsigned char m_bRightShoulder1 : 1; // hand brake, target
    
                unsigned char m_bLeftShoulder2 : 1; // look left
                unsigned char m_bShockButtonR : 1;  // look behind
                unsigned char m_bPedWalk : 1;       // walking
                unsigned char m_bRightStickDown : 1;
                unsigned char m_bRightStickUp : 1;
                unsigned char m_bRightStickRight : 1; // num 4
                unsigned char m_bRightStickLeft : 1;  // num 6
                                                      // 16th bit is unused
            };
            short m_value;
        };
    };

    // Animation
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
    
    // Synchronization
    struct SFL_OnfootData
    {
        SFL_ControllerState m_controllerState;
        CVector             m_position;
        float               m_fQuaternion[4];
        unsigned char       m_nHealth;
        unsigned char       m_nArmor;
        unsigned char       m_nCurrentWeapon;
        unsigned char       m_nSpecialAction;
        CVector             m_speed;
        CVector             m_surfingOffset;
        ID                  m_nSurfingVehicleId;
        SFL_Animation       m_animation;
    };
    
    struct SFL_IncarData
    {
        ID                  m_nVehicle;
        SFL_ControllerState m_controllerState;
        float               m_fQuaternion[4];
        CVector             m_position;
        CVector             m_speed;
        float               m_fHealth;
        unsigned char       m_nDriverHealth;
        unsigned char       m_nDriverArmor;
        unsigned char       m_nCurrentWeapon;
        bool                m_bSirenEnabled;
        bool                m_bLandingGear;
        ID                  m_nTrailerId;
        union {
            unsigned short m_aHydraThrustAngle[2];
            float          m_fTrainSpeed;
        };
    };
    
    struct SFL_AimData
    {
        unsigned char m_nCameraMode;
        CVector       m_aimf1;
        CVector       m_aimPos;
        float         m_fAimZ;
        unsigned char m_nCameraExtZoom : 6;
        unsigned char m_nWeaponState : 2;
        char          m_nAspectRatio;
    };
    
    struct SFL_TrailerData
    {
        ID      m_nId;
        CVector m_position;
        float   m_fQuaternion[4];
        CVector m_speed;
        CVector m_turnSpeed;
    };
    
    struct SFL_PassengerData
    {
        ID                  m_nVehicleId;
        unsigned char       m_nSeatId; // flags
        unsigned char       m_nCurrentWeapon;
        unsigned char       m_nHealth;
        unsigned char       m_nArmor;
        SFL_ControllerState m_controllerState;
        CVector             m_position;
    };
    
    struct SFL_UnoccupiedData
    {
        ID            m_nVehicleId;
        unsigned char m_nSeatId;
        CVector       m_roll;
        CVector       m_direction;
        CVector       m_position;
        CVector       m_speed;
        CVector       m_turnSpeed;
        float         m_fHealth;
    };
    
    struct SFL_BulletData
    {
        unsigned char m_nTargetType;
        ID            m_nTargetId;
        CVector       m_origin;
        CVector       m_target;
        CVector       m_center;
        unsigned char m_nWeapon;
    };
    
    struct SFL_SpectatorData
    {
        SFL_ControllerState m_controllerState;
        CVector             m_position;
    };
    
    struct SFL_StatsData
    {
        int m_nMoney;
        int m_nDrunkLevel;
    };

    // CLocalPlayer
    struct SFL_LocalPlayer
    {
        SFL_Ped      *m_pPed;
        SFL_Animation m_animation;
        int           field_8;
        BOOL          m_bIsActive;
        BOOL          m_bIsWasted;
        ID            m_nCurrentVehicle;
        ID            m_nLastVehicle;

        SFL_OnfootData    m_onfootData;
        SFL_PassengerData m_passengerData;
        SFL_TrailerData   m_trailerData;
        SFL_IncarData     m_incarData;
        SFL_AimData       m_aimData;

        // used by RPC_SetSpawnInfo
        struct {
            NUMBER  m_nTeam;
            int     m_nSkin;
            char    field_c;
            CVector m_position;
            float   m_fRotation;
            int     m_aWeapon[3];
            int     m_aAmmo[3];
        } m_spawnInfo;

        BOOL   m_bHasSpawnInfo;
        BOOL   m_bClearedToSpawn;
        TICK   m_lastSelectionTick;
        TICK   m_initialSelectionTick;
        BOOL   m_bDoesSpectating;
        NUMBER m_nTeam;
        short  field_14b;
        TICK   m_lastUpdate;
        TICK   m_lastSpecUpdate;
        TICK   m_lastAimUpdate;
        TICK   m_lastStatsUpdate;
        TICK   m_lastWeaponsUpdate;

        struct {
            ID     m_nAimedPlayer;
            ID     m_nAimedActor;
            NUMBER m_nCurrentWeapon;
            NUMBER m_aLastWeapon[13];
            int    m_aLastWeaponAmmo[13];
        } m_weaponsData;

        BOOL m_bPassengerDriveBy;
        char m_nCurrentInterior;
        BOOL m_bInRCMode;

        struct {
            ID m_nObject;
            ID m_nVehicle;
            ID m_nPlayer;
            ID m_nActor;
        } m_cameraTarget;

        struct {
            CVector m_direction;
            TICK    m_lastUpdate;
            TICK    m_lastLook;
        } m_head;

        TICK m_lastHeadUpdate;
        TICK m_lastAnyUpdate;
        char m_szName[256];

        struct {
            BOOL    m_bIsActive;
            CVector m_position;
            int     field_10;
            ID      m_nEntityId;
            TICK    m_lastUpdate;
    
            union {
                SFL_Vehicle *m_pVehicle;
                SFL_Object  *m_pObject;
            };
    
            BOOL m_bStuck;
            int  m_nMode;
        } m_surfing;   
        
        struct {
            BOOL m_bEnableAfterDeath;
            int  m_nSelected;
            BOOL m_bWaitingForSpawnRequestReply;
            BOOL m_bIsActive;
        } m_classSelection;
    
        TICK m_zoneDisplayingEnd;
    
        struct {
            char m_nMode;
            char m_nType;
            int  m_nObject; // id
            BOOL m_bProcessed;
        } m_spectating;
    
        struct {
            ID   m_nVehicleUpdating;
            int  m_nBumper;
            int  m_nDoor;
            char m_bLight;
            char m_bWheel;
        } m_damage;
    };
    
    // CRemotePlayer
    struct SFL_RemotePlayer
    {
        SFL_Ped     *m_pPed;
        SFL_Vehicle *m_pVehicle;
        NUMBER       m_nTeam;
        NUMBER       m_nState;
        NUMBER       m_nSeatId;
        int          field_b;
        BOOL         m_bPassengerDriveBy;
        char         pad_13[64];
        CVector      m_positionDifference; // target pos - current pos
    
        struct {
            float   real;
            CVector imag;
        } m_incarTargetRotation;
    
        int     pad_6f[3];
        CVector m_onfootTargetPosition;
        CVector m_onfootTargetSpeed;
        CVector m_incarTargetPosition;
        CVector m_incarTargetSpeed;
        ID      m_nId;
        ID      m_nVehicleId;
        int     field_af;
        BOOL    m_bDrawLabels;
        BOOL    m_bHasJetPack;
        NUMBER  m_nSpecialAction;
        int     pad_bc[3];
    
        SFL_OnfootData    m_onfootData;
        SFL_IncarData     m_incarData;
        SFL_TrailerData   m_trailerData;
        SFL_PassengerData m_passengerData;
        SFL_AimData       m_aimData;
    
        float         m_fReportedArmour;
        float         m_fReportedHealth;
        SFL_Animation m_animation;
        NUMBER        m_nUpdateType;
        TICK          m_lastUpdate;
        TICK          m_lastTimestamp;
        BOOL          m_bPerformingCustomAnimation;
        int           m_nStatus;
    
        struct {
            CVector m_direction;
            TICK    m_lastUpdate;
            TICK    m_lastLook;
        } m_head;
    
        BOOL m_bMarkerState;
    
        struct {
            int x, y, z;
        } m_markerPosition;
    
        GTAREF m_marker;
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

    // CVehiclePool
    struct SFL_VehicleInfo {
        ID      m_nId;
        int     m_nType;
        CVector m_position;
        float   m_fRotation;
        NUMBER  m_nPrimaryColor;
        NUMBER  m_nSecondaryColor;
        float   m_fHealth;
        char    m_nInterior;
        int     m_nDoorDamageStatus;
        int     m_nPanelDamageStatus;
        char    m_nLightDamageStatus;
        bool    m_bDoorsLocked;
        bool    m_bHasSiren;
    };
    
    struct SFL_VehiclePool
    {
        int m_nCount;

        // vehicles that will be created after loading the model
        struct {
            SFL_VehicleInfo m_entry[WAITING_LIST_SIZE];
            BOOL            m_bNotEmpty[WAITING_LIST_SIZE];
        } m_waiting;

        SFL_Vehicle     *m_pObject[MAX_VEHICLES];
        BOOL             m_bNotEmpty[MAX_VEHICLES];
        struct CVehicle *m_pGameObject[MAX_VEHICLES];
        int              pad_6ef4[MAX_VEHICLES];
        ID               m_nLastUndrivenId[MAX_VEHICLES]; // a player who send unoccupied sync data
        TICK             m_lastUndrivenProcessTick[MAX_VEHICLES];
        BOOL             m_bIsActive[MAX_VEHICLES];
        BOOL             m_bIsDestroyed[MAX_VEHICLES];
        TICK             m_tickWhenDestroyed[MAX_VEHICLES];
        CVector          m_spawnedAt[MAX_VEHICLES];
        BOOL             m_bNeedsToInitializeLicensePlates;
    };
    
    // CVehicle
    struct SFL_Vehicle
    {
        SFL_Entity       entity;
        SFL_Vehicle     *m_pTrailer;
        struct CVehicle *m_pGameVehicle;
        char             pad_50[8];
        BOOL             m_bIsInvulnerable;
        BOOL             m_bIsLightsOn;
        BOOL             m_bIsLocked;
        bool             m_bIsObjective;
        BOOL             m_bObjectiveBlipCreated;
        TICK             m_timeSinceLastDriven;
        BOOL             m_bHasBeenDriven;
        char             pad_71[4];
        BOOL             m_bEngineState;
        NUMBER           m_nPrimaryColor;
        NUMBER           m_nSecondaryColor;
        BOOL             m_bNeedsToUpdateColor;
        BOOL             m_bUnoccupiedSync;
        BOOL             m_bRemoteUnocSync;
        BOOL             m_bKeepModelLoaded;
        int              m_bHasSiren;
        void            *m_pLicensePlate;
        char             m_szLicensePlateText[LICENSE_PLATE_TEXT_LEN + 1];
        GTAREF           m_marker;
    };
    
    // CObject
    struct SFL_MaterialText {
        char     m_nMaterialIndex;
        char     pad_0[137];
        char     m_nMaterialSize;
        char     m_szFont[65];
        char     m_nFontSize;
        bool     m_bBold;
        D3DCOLOR m_fontColor;
        D3DCOLOR m_backgroundColor;
        char     m_align;
    };

    struct SFL_ObjectMaterial {
        union {
            struct CSprite2d *m_pSprite[MAX_MATERIALS];
            struct RwTexture *m_pTextBackground[MAX_MATERIALS];
        };

        D3DCOLOR m_color[MAX_MATERIALS];
        char     pad_6[68];
        int      m_nType[MAX_MATERIALS];
        BOOL     m_bTextureWasCreated[MAX_MATERIALS];

        SFL_MaterialText m_textInfo[MAX_MATERIALS];
        char            *m_szText[MAX_MATERIALS];
        void            *m_pBackgroundTexture[MAX_MATERIALS];
        void            *m_pTexture[MAX_MATERIALS];
    };

    struct SFL_Object
    {
        SFL_Entity entity;
        char       pad_0[6];
        int        m_nModel;
        char       pad_1;
        bool       m_bDontCollideWithCamera;
        float      m_fDrawDistance;
        float      field_0;
        CVector    m_position;
        float      m_fDistanceToCamera;
        bool       m_bDrawLast;
        char       pad_2[64];
        CVector    m_rotation;
        char       pad_3[5];
        ID         m_nAttachedToVehicle;
        ID         m_nAttachedToObject;
        CVector    m_attachOffset;
        CVector    m_attachRotation;
        char       field_1;
        CMatrix    m_targetMatrix;
        char       pad_4[148];
        char       m_bMoving;
        float      m_fSpeed;
        char       pad_5[99];

        SFL_ObjectMaterial m_material;

        BOOL m_bHasCustomMaterial;
        char pad_9[10];
    };
    
    // CObjectPool
    struct SFL_ObjectPool
    {
        int         m_nLargestId;
        BOOL        m_bNotEmpty[MAX_OBJECTS];
        SFL_Object *m_pObject[MAX_OBJECTS];
    };
    
    // CGangZonePool
    struct SFL_Gangzone
    {
        struct {
            float left;
            float bottom;
            float right;
            float top;
        } m_rect;

        D3DCOLOR m_color;
        D3DCOLOR m_altColor;
    };
    
    struct SFL_GangzonePool
    {
        SFL_Gangzone *m_pObject[MAX_GANGZONES];
        BOOL          m_bNotEmpty[MAX_GANGZONES];
    };
    
    // CLabelPool
    struct SFL_TextLabel {
        char    *m_pText;
        D3DCOLOR m_color;
        CVector  m_position;
        float    m_fDrawDistance;
        bool     m_bBehindWalls;
        ID       m_nAttachedToPlayer;
        ID       m_nAttachedToVehicle;
    };
    
    struct SFL_LabelPool
    {
        SFL_TextLabel m_object[MAX_TEXT_LABELS];
        BOOL          m_bNotEmpty[MAX_TEXT_LABELS];
    };
    
    // CChat
    struct SFL_ChatEntry {
        __int32  m_timestamp;
        char     m_szPrefix[28];
        char     m_szText[144];
        char     unused[64];
        int      m_nType;
        D3DCOLOR m_textColor;
        D3DCOLOR m_prefixColor;
    };
    
    struct SFL_Chat
    {
        unsigned int m_nPageSize;
        char        *m_szLastMessage;
        int          m_nMode;
        bool         m_bTimestamps;
        BOOL         m_bDoesLogExist;
        char         m_szLogPath[261]; // MAX_PATH(+1)
        void        *m_pGameUi; // CDXUTDialog
        void        *m_pEditbox; // CDXUTEditBox
        void        *m_pScrollbar; // CDXUTScrollBar
        D3DCOLOR     m_textColor;  // 0xFFFFFFFF
        D3DCOLOR     m_infoColor;  // 0xFF88AA62
        D3DCOLOR     m_debugColor; // 0xFFA9C4E4
        long         m_nWindowBottom;

        SFL_ChatEntry m_entry[MAX_MESSAGES];
        void         *m_pFontRenderer;
        void         *m_pTextSprite;
        void         *m_pSprite;
        void         *m_pDevice;
        BOOL          m_bRenderToSurface;
        void         *m_pRenderToSurface;
        void         *m_pTexture;
        void         *m_pSurface;
        unsigned int  m_displayMode[4];
        int           pad_[2];
        BOOL          m_bRedraw;
        long          m_nScrollbarPos;
        long          m_nCharHeight; // this is the height of the "Y"
        long          m_nTimestampWidth;
    };
    
    // CInput
    struct SFL_InputInfo
    {
        void   *m_pDevice;
        void   *m_pGameUi;
        void   *m_pEditbox;
        CMDPROC m_pCommandProc[MAX_CLIENT_CMDS];
        char    m_szCommandName[MAX_CLIENT_CMDS][MAX_CMD_LENGTH + 1];
        int     m_nCommandCount;
        BOOL    m_bEnabled;
        char    m_szInput[129];
        char    m_szRecallBufffer[10][129];
        char    m_szCurrentBuffer[129];
        int     m_nCurrentRecall;
        int     m_nTotalRecall;
        CMDPROC m_pDefaultCommand;
    };
    
    struct SFL_DeathWindow
    {
        BOOL          m_bEnabled;
        struct
        {
            char     m_szKiller[25];
            char     m_szVictim[25];
            D3DCOLOR m_killerColor;
            D3DCOLOR m_victimColor;
            char     m_nWeapon;
        } m_entry[MAX_DEATHMESSAGES];
        int           m_nLongestNickWidth;
        int           m_position[2];
        void         *m_pFont;
        void         *m_pWeaponFont1;
        void         *m_pWeaponFont2;
        void         *m_pSprite;
        void         *m_pDevice;
        BOOL          m_bAuxFontInited;
        void         *m_pAuxFont1;
        void         *m_pAuxFont2;
    };
    
    struct SFL_Audio
    {
        BOOL m_bSoundLoaded;
    };
    
    struct SFL_Camera
    {
        SFL_Entity *m_pAttachedTo;
        CMatrix    *m_pMatrix;
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
    
    // CScoreboard
    struct SFL_Scoreboard
    {
        BOOL  m_bIsEnabled;
        int   m_nPlayerCount;
        float m_position[2];
        float _fScalar;
        float m_size[2];
        float pad[5];
        void *m_pDevice;
        void *m_pDialog;
        void *m_pListBox;
        int   m_nCurrentOffset;
        BOOL  m_bIsSorted;
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