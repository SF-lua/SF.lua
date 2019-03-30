--[[
	Authors: FYP, imring, DonHomka.
	Thanks BH Team for development.
	Structuers/addresses/other were taken in s0beit 0.3.7: https://github.com/BlastHackNet/mod_s0beit_sa
	http://blast.hk/ (ñ) 2018.
]]
local ffi = require 'ffi'

ffi.cdef[[
/*typedef struct stSAMPPools stSAMPPools;
typedef struct stSAMP stSAMP;
typedef struct stServerInfo stServerInfo;
typedef struct stServerPresets stServerPresets;
typedef struct stDialogInfo stDialogInfo;
typedef struct stTextDrawTransmit stTextDrawTransmit;
typedef struct stTextdraw stTextdraw;
typedef struct stTextdrawPool stTextdrawPool;
typedef struct stPickup stPickup;
typedef struct stPickupPool stPickupPool;
typedef struct stPlayerPool stPlayerPool;
typedef struct stSAMPKeys stSAMPKeys;
typedef struct stOnFootData stOnFootData;
typedef struct stInCarData stInCarData;
typedef struct stAimData stAimData;
typedef struct stTrailerData stTrailerData;
typedef struct stPassengerData stPassengerData;
typedef struct stDamageData stDamageData;
typedef struct stSurfData stSurfData;
typedef struct stUnoccupiedData stUnoccupiedData;
typedef struct stBulletData stBulletData;
typedef struct stSpectatorData stSpectatorData;
typedef struct stStatsData stStatsData;
typedef struct stHeadSync stHeadSync;
typedef struct stLocalPlayer stLocalPlayer;*/
typedef struct stRemotePlayerData stRemotePlayerData;
/*typedef struct stRemotePlayer stRemotePlayer;*/
typedef struct stSAMPEntity stSAMPEntity;
typedef struct stSAMPPed stSAMPPed;
/*typedef struct stVehiclePool stVehiclePool;
typedef struct stSAMPVehicle stSAMPVehicle;
typedef struct stObject stObject;
typedef struct stObjectPool stObjectPool;
typedef struct stGangzone stGangzone;
typedef struct stGangzonePool stGangzonePool;
typedef struct stTextLabel stTextLabel;
typedef struct stTextLabelPool stTextLabelPool;
typedef struct stChatEntry stChatEntry;*/
typedef struct stFontRenderer stFontRenderer;
/*typedef struct stChatInfo stChatInfo;*/
typedef struct stInputBox stInputBox;
/*typedef struct stInputInfo stInputInfo;
typedef struct stKillEntry stKillEntry;
typedef struct stKillInfo stKillInfo;
typedef struct stChatPlayer stChatPlayer;*/
typedef struct stAudio stAudio;
/*typedef struct stGameInfo stGameInfo;
typedef struct stScoreboardInfo stScoreboardInfo;
typedef struct stActorPool stActorPool;
typedef struct stChatBubbleInfo stChatBubbleInfo;
typedef struct stStreamedOutPlayerInfo stStreamedOutPlayerInfo;*/
typedef struct stCamera stCamera;
typedef struct BitStream BitStream;

enum Limits
{
	SAMP_MAX_ACTORS = 1000,
	SAMP_MAX_PLAYERS = 1004,
	SAMP_MAX_VEHICLES = 2000,
	SAMP_MAX_PICKUPS = 4096,
	SAMP_MAX_OBJECTS = 1000,
	SAMP_MAX_GANGZONES = 1024,
	SAMP_MAX_3DTEXTS = 2048,
	SAMP_MAX_TEXTDRAWS = 2048,
	SAMP_MAX_PLAYERTEXTDRAWS = 256,
	SAMP_MAX_CLIENTCMDS = 144,
	SAMP_MAX_MENUS = 128,
	SAMP_MAX_PLAYER_NAME = 24,
	SAMP_ALLOWED_PLAYER_NAME_LENGTH = 20,
};

struct stSAMPPools
{
	struct stActorPool		*pActor;
	struct stObjectPool		*pObject;
	struct stGangzonePool	*pGangzone;
	struct stTextLabelPool	*pText3D;
	struct stTextdrawPool	*pTextdraw;
	void					*pPlayerLabels;
	struct stPlayerPool		*pPlayer;
	struct stVehiclePool	*pVehicle;
	struct stPickupPool		*pPickup;
} __attribute__ ((packed));

struct stSAMP
{
	void					*pUnk0;
	struct stServerInfo		*pServerInfo;
	BYTE					byteSpace[24];
	char					szIP[257];
	char					szHostname[259];
	bool					bNametagStatus; // changes by /nametagstatus
	DWORD					ulPort;
	DWORD					ulMapIcons[100];
	int						iLanMode;
	int						iGameState;
	DWORD					ulConnectTick;
	struct stServerPresets	*pSettings;
	void					*pRakClientInterface;
	struct stSAMPPools		*pPools;
} __attribute__ ((packed));

struct stServerInfo
{
	DWORD 					uiIP;
	WORD 					usPort;
} __attribute__ ((packed));

struct stServerPresets
{
	BYTE					byteCJWalk;
	int						m_iDeathDropMoney;
	float					fWorldBoundaries[4];
	bool					m_bAllowWeapons;
	float					fGravity;
	BYTE					byteDisableInteriorEnterExits;
	DWORD					ulVehicleFriendlyFire;
	bool					m_byteHoldTime;
	bool					m_bInstagib;
	bool					m_bZoneNames;
	bool					m_byteFriendlyFire;
	int						iClassesAvailable;
	float					fNameTagsDistance;
	bool					m_bManualVehicleEngineAndLight;
	BYTE					byteWorldTime_Hour;
	BYTE					byteWorldTime_Minute;
	BYTE					byteWeather;
	BYTE					byteNoNametagsBehindWalls;
	int						iPlayerMarkersMode;
	float					fGlobalChatRadiusLimit;
	BYTE					byteShowNameTags;
	bool					m_bLimitGlobalChatRadius;
} __attribute__ ((packed));

struct stDialogInfo
{
	void					*m_pD3DDevice;
	int						iTextPoxX;
	int						iTextPoxY;
	DWORD					uiDialogSizeX;
	DWORD					uiDialogSizeY;
	int						iBtnOffsetX;
	int						iBtnOffsetY;
	void					*pDialog;
	void					*pList;
	void					*pEditBox;
	int						iIsActive;
	int						iType;
	DWORD					DialogID;
	PCHAR					pText;
	DWORD					uiTextWidth;
	DWORD					uiTextHeight;
	char					szCaption[65];
	int						bServerside;
} __attribute__ ((packed));

struct stTextDrawTransmit
{
	union
	{
		BYTE byteFlags;
		struct
		{
			BYTE byteBox : 1;
			BYTE byteLeft : 1;
			BYTE byteRight : 1;
			BYTE byteCenter : 1;
			BYTE byteProportional : 1;
			BYTE bytePadding : 3;
		};
	};
	float					fLetterWidth;
	float					fLetterHeight;
	DWORD					dwLetterColor;
	float					fBoxWidth;
	float					fBoxHeight;
	DWORD					dwBoxColor;
	BYTE					byteShadow;
	BYTE					byteOutline;
	DWORD					dwBackgroundColor;
	BYTE					byteStyle;
	BYTE					byteUNK;
	float					fX;
	float					fY;
	WORD					sModel;
	float					fRot[3];
	float					fZoom;
	WORD					sColor[2];
} __attribute__ ((packed));

struct stTextdraw
{
	char					szText[800 + 1];
	char					szString[1600 + 2];
	float					fLetterWidth;
	float					fLetterHeight;
	DWORD					dwLetterColor;
	BYTE					byte_unk;	// always = 01 (?)
	BYTE					byteCenter;
	BYTE					byteBox;
	float					fBoxSizeX;
	float					fBoxSizeY;
	DWORD					dwBoxColor;
	BYTE					byteProportional;
	DWORD					dwShadowColor;
	BYTE					byteShadowSize;
	BYTE					byteOutline;
	BYTE					byteLeft;
	BYTE					byteRight;
	int						iStyle;		// font style/texture/model
	float					fX;
	float					fY;
	BYTE					unk[8];
	DWORD					dword99B;	// -1 by default
	DWORD					dword99F;	// -1 by default
	DWORD					index;		// -1 if bad
	BYTE					byte9A7;	// = 1; 0 by default
	WORD					sModel;
	float					fRot[3];
	float					fZoom;
	WORD					sColor[2];
	BYTE					f9BE;
	BYTE					byte9BF;
	BYTE					byte9C0;
	DWORD					dword9C1;
	DWORD					dword9C5;
	DWORD					dword9C9;
	DWORD					dword9CD;
	BYTE					byte9D1;
	DWORD					dword9D2;
} __attribute__ ((packed));

struct stTextdrawPool
{
	int						iIsListed[SAMP_MAX_TEXTDRAWS];
	int						iPlayerTextDraw[SAMP_MAX_PLAYERTEXTDRAWS];
	struct stTextdraw		*textdraw[SAMP_MAX_TEXTDRAWS];
	struct stTextdraw		*playerTextdraw[SAMP_MAX_PLAYERTEXTDRAWS];
} __attribute__ ((packed));

struct stPickup
{
	int						iModelID;
	int						iType;
	float					fPosition[3];
} __attribute__ ((packed));

struct stPickupPool
{
	int						iPickupsCount;
	DWORD					ul_GTA_PickupID[SAMP_MAX_PICKUPS];
	int						iPickupID[SAMP_MAX_PICKUPS];
	int						iTimePickup[SAMP_MAX_PICKUPS];
	BYTE					unk[SAMP_MAX_PICKUPS * 3];
	struct stPickup			pickup[SAMP_MAX_PICKUPS];
} __attribute__ ((packed));

struct stPlayerPool
{
	DWORD					ulMaxPlayerID;
	WORD					sLocalPlayerID;
	void					*pVTBL_txtHandler;
	stdstring				strLocalPlayerName;
	struct stLocalPlayer	*pLocalPlayer;
	int						iLocalPlayerPing;
	int						iLocalPlayerScore;
	struct stRemotePlayer	*pRemotePlayer[SAMP_MAX_PLAYERS];
	int						iIsListed[SAMP_MAX_PLAYERS];
	DWORD					dwPlayerIP[SAMP_MAX_PLAYERS]; // always 0
} __attribute__ ((packed));

struct stSAMPKeys
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
} __attribute__ ((packed));

struct stOnFootData
{
	WORD					sLeftRightKeys;
	WORD					sUpDownKeys;
	union
	{
		WORD				sKeys;
		struct stSAMPKeys	stSampKeys;
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
} __attribute__ ((packed));

struct stInCarData
{
	WORD					sVehicleID;
	WORD					sLeftRightKeys;
	WORD					sUpDownKeys;
	union
	{
		WORD				sKeys;
		struct stSAMPKeys	stSampKeys;
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
} __attribute__ ((packed));

struct stAimData
{
	BYTE					byteCamMode;
	float					vecAimf1[3];
	float					vecAimPos[3];
	float					fAimZ;
	BYTE					byteCamExtZoom : 6;		// 0-63 normalized
	BYTE					byteWeaponState : 2;	// see eWeaponState
	BYTE					bUnk;
} __attribute__ ((packed));

struct stTrailerData
{
	WORD					sTrailerID;
	float					fPosition[3];
	float					fQuaternion[4];
	float					fSpeed[3];
	float					fSpin[3];
} __attribute__ ((packed));

struct stPassengerData
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
		struct stSAMPKeys	stSampKeys;
	};
	float					fPosition[3];
} __attribute__ ((packed));

struct stDamageData
{
	WORD					sVehicleID_lastDamageProcessed;
	int						iBumperDamage;
	int						iDoorDamage;
	BYTE					byteLightDamage;
	BYTE					byteWheelDamage;
} __attribute__ ((packed));

struct stSurfData
{
	int						iIsSurfing;
	float					fSurfPosition[3];
	int						iUnk0;
	WORD					sSurfingVehicleID;
	DWORD					ulSurfTick;
	struct stSAMPVehicle	*pSurfingVehicle;
	int						iUnk1;
	int						iSurfMode;	//0 = not surfing, 1 = moving (unstable surf), 2 = fixed on vehicle
} __attribute__ ((packed));

struct stUnoccupiedData
{
	int16_t					sVehicleID;
	BYTE					byteSeatID;
	float					fRoll[3];
	float					fDirection[3];
	float					fPosition[3];
	float					fMoveSpeed[3];
	float					fTurnSpeed[3];
	float					fHealth;
} __attribute__ ((packed));

struct stBulletData
{
	BYTE					byteType;
	WORD					sTargetID;
	float					fOrigin[3];
	float					fTarget[3];
	float					fCenter[3];
	BYTE					byteWeaponID;
} __attribute__ ((packed));

struct stSpectatorData
{
	WORD					sLeftRightKeys;
	WORD					sUpDownKeys;
	union
	{
		WORD				sKeys;
		struct stSAMPKeys	stSampKeys;
	};
	float					fPosition[3];
} __attribute__ ((packed));

struct stStatsData
{
	int						iMoney;
	int						iAmmo;
} __attribute__ ((packed));

struct stHeadSync
{
	float					fHeadSync[3];
	int						iHeadSyncUpdateTick;
	int						iHeadSyncLookTick;
} __attribute__ ((packed));

struct stLocalPlayer
{
	struct stSAMPPed		*pSAMP_Actor;
	WORD					sCurrentAnimID;
	WORD					sAnimFlags;
	DWORD					ulUnk0;
	int						iIsActive;
	int						iIsWasted;
	WORD					sCurrentVehicleID;
	WORD					sLastVehicleID;
	struct stOnFootData		onFootData;
	struct stPassengerData	passengerData;
	struct stTrailerData	trailerData;
	struct stInCarData		inCarData;
	struct stAimData		aimData;
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
	struct stHeadSync		headSyncData;
	DWORD					ulHeadSyncTick;
	BYTE					byteSpace3[260];
	struct stSurfData		surfData;
	int						iClassSelectionOnDeath;
	int						iSpawnClassID;
	int						iRequestToSpawn;
	int						iIsInSpawnScreen;
	DWORD					ulUnk4;
	BYTE					byteSpectateMode;		// 3 = vehicle, 4 = player, side = 14, fixed = 15
	BYTE					byteSpectateType;		// 0 = none, 1 = player, 2 = vehicle
	int						iSpectateID;
	int						iInitiatedSpectating;
	struct stDamageData		vehicleDamageData;
} __attribute__ ((packed));

struct stRemotePlayerData
{
	struct stSAMPPed		*pSAMP_Actor;
	struct stSAMPVehicle	*pSAMP_Vehicle;
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
	struct stOnFootData		onFootData;
	struct stInCarData		inCarData;
	struct stTrailerData	trailerData;
	struct stPassengerData	passengerData;
	struct stAimData		aimData;
	float					fActorArmor;
	float					fActorHealth;
	DWORD					ulUnk10;
	BYTE					byteUnk9;
	DWORD					dwTick;
	DWORD					dwLastStreamedInTick;	// is 0 when currently streamed in
	DWORD					ulUnk7;
	int						iAFKState;
	struct stHeadSync		headSyncData;
	int						iGlobalMarkerLoaded;
	int						iGlobalMarkerLocation[3];
	DWORD					ulGlobalMarker_GTAID;
} __attribute__ ((packed));

struct stRemotePlayer
{
	stRemotePlayerData		*pPlayerData;
	int						iIsNPC;
	void					*pVTBL_txtHandler;
	stdstring				strPlayerName;
	int						iScore;
	int						iPing;
} __attribute__ ((packed));

struct stSAMPEntity
{
	void					*pVTBL;
	BYTE					byteUnk0[60]; // game CEntity object maybe. always empty.
	void					*pGTAEntity;
	DWORD					ulGTAEntityHandle;
} __attribute__ ((packed));

struct stSAMPPed
{
	stSAMPEntity			actor_info;
	int						usingCellPhone;
	BYTE					byteUnk0[600];
	struct actor_info		*pGTA_Ped;
	BYTE					byteUnk1[22];
	BYTE					byteKeysId;
	WORD					ulGTA_UrinateParticle_ID;
	int						DrinkingOrSmoking;
	int						object_in_hand;
	int						drunkLevel;
	BYTE					byteUnk2[5];
	int						isDancing;
	int						danceStyle;
	int						danceMove;
	BYTE					byteUnk3[20];
	int						isUrinating;
} __attribute__ ((packed));

struct stVehiclePool
{
	int						iVehicleCount;
	void					*pUnk0;
	BYTE					byteSpace1[0x112C];
	struct stSAMPVehicle	*pSAMP_Vehicle[SAMP_MAX_VEHICLES];
	int						iIsListed[SAMP_MAX_VEHICLES];
	struct stSAMPVehicle	*pGTA_Vehicle[SAMP_MAX_VEHICLES];
	BYTE					byteSpace2[SAMP_MAX_VEHICLES * 6];
	DWORD					ulShit[SAMP_MAX_VEHICLES];
	int						iIsListed2[SAMP_MAX_VEHICLES];
	DWORD					byteSpace3[SAMP_MAX_VEHICLES * 2];
	float					fSpawnPos[SAMP_MAX_VEHICLES][3];
	int						iInitiated;
} __attribute__ ((packed));

struct stSAMPVehicle
{
	stSAMPEntity			vehicle_info;
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
} __attribute__ ((packed));

struct stObject
{
	stSAMPEntity			object_info;
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
} __attribute__ ((packed));

struct stObjectPool
{
	int						iObjectCount;
	int						iIsListed[SAMP_MAX_OBJECTS];
	struct stObject			*object[SAMP_MAX_OBJECTS];
} __attribute__ ((packed));

struct stGangzone
{
	float					fPosition[4];
	DWORD					dwColor;
	DWORD					dwAltColor;
} __attribute__ ((packed));

struct stGangzonePool
{
	struct stGangzone		*pGangzone[SAMP_MAX_GANGZONES];
	int						iIsListed[SAMP_MAX_GANGZONES];
} __attribute__ ((packed));

struct stTextLabel
{
	PCHAR					pText;
	DWORD					color;
	float					fPosition[3];
	float					fMaxViewDistance;
	BYTE					byteShowBehindWalls;
	WORD					sAttachedToPlayerID;
	WORD					sAttachedToVehicleID;
} __attribute__ ((packed));

struct stTextLabelPool
{
	struct stTextLabel		textLabel[SAMP_MAX_3DTEXTS];
	int						iIsListed[SAMP_MAX_3DTEXTS];
} __attribute__ ((packed));

struct stChatEntry
{
	DWORD					SystemTime;
	char					szPrefix[28];
	char					szText[144];
	BYTE					unknown[64];
	int						iType;			// 2 - text + prefix, 4 - text (server msg), 8 - text (debug)
	DWORD					clTextColor;
	DWORD					clPrefixColor;	// or textOnly colour
} __attribute__ ((packed));

struct stFontRenderer
{
	ID3DXFont				*m_pChatFont;
	ID3DXFont				*m_pLittleFont;
	ID3DXFont				*m_pChatShadowFont;
	ID3DXFont				*m_pLittleShadowFont;
	ID3DXFont				*m_pCarNumberFont;
	void 					*m_pTempSprite;
	void					*m_pD3DDevice;
	PCHAR					m_pszTextBuffer;
} __attribute__ ((packed));

struct stChatInfo
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
	struct stChatEntry		chatEntry[100];
	stFontRenderer			*m_pFontRenderer;
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
} __attribute__ ((packed));

struct stInputBox
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
} __attribute__ ((packed));

struct stInputInfo
{
	void					*pD3DDevice;
	void					*pDXUTDialog;
	stInputBox				*pDXUTEditBox;
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
} __attribute__ ((packed));

struct stKillEntry
{
	char					szKiller[25];
	char					szVictim[25];
	D3DCOLOR				clKillerColor;
	D3DCOLOR				clVictimColor;
	BYTE					byteType;
} __attribute__ ((packed));

struct stKillInfo
{
	int						iEnabled;
	struct stKillEntry		killEntry[5];
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
} __attribute__ ((packed));

struct stChatPlayer
{
	int						iCreated;
	char					probablyTheText[256];
	DWORD					dwTickCreated;
	DWORD					dwLiveLength;
	DWORD					dwColor;
	float					fDrawDistance;
	DWORD					dwUnknown;
} __attribute__ ((packed));

struct stAudio
{
	int						iSoundState; // 0 - Finished, 1 - Loaded, 2 - Playing
} __attribute__ ((packed));

struct stCamera
{
	void*				pEntity; // attached entity
	void*				matrix;
} __attribute__ ((packed));

struct stGameInfo
{
	stAudio*				pAudio;
	stCamera*				pCamera;
	stSAMPPed*				pLocalPlayerPed;
	float					fCheckpointPos[3];
	float					fCheckpointExtent[3];
	int						bCheckpointsEnabled;

	// not tested
	DWORD					dwCheckpointMarker;
	float					fRaceCheckpointPos[3];
	float					fRaceCheckpointNext[3];
	float					m_fRaceCheckpointSize;
	BYTE					byteRaceType;

	int						bRaceCheckpointsEnabled;

	DWORD					dwRaceCheckpointMarker;
	DWORD					dwRaceCheckpointHandle;

	int						iCursorMode;
	DWORD					ulUnk1;
	int						bClockEnabled;
	DWORD					ulUnk2;
	int						bHeadMove;
	DWORD					ulFpsLimit;
	BYTE					byteUnk3;
	BYTE					byteVehicleModels[212];
} __attribute__ ((packed));

struct stScoreboardInfo
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
} __attribute__ ((packed));

struct stActorPool
{
	int						iLastActorID;
	stSAMPEntity			*pActor[SAMP_MAX_ACTORS]; // ?
	int						iIsListed[SAMP_MAX_ACTORS];
	struct stSAMPPed		*pGTAPed[SAMP_MAX_ACTORS];
	DWORD					ulUnk0[SAMP_MAX_ACTORS];
	DWORD					ulUnk1[SAMP_MAX_ACTORS];
} __attribute__ ((packed));

struct stChatBubbleInfo
{
	struct stChatPlayer		chatBubble[SAMP_MAX_PLAYERS];
} __attribute__ ((packed));

struct stStreamedOutPlayerInfo
{
	int						iPlayerID[SAMP_MAX_PLAYERS];
	float					fPlayerPos[SAMP_MAX_PLAYERS][3];
} __attribute__ ((packed));
]]