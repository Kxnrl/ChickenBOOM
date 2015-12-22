/* <Store - ChickenBOOM> (c) by <maoling ( shAna.xQy ) - (http://kxnrl.com)> */
/*                                                                           */
/*                 <Store - ChickenBOOM> is licensed under a                 */
/*                        GNU General Public License                         */
/*																			 */
/*      You should have received a copy of the license along with this       */
/*            work.  If not, see <http://www.gnu.org/licenses/>.             */
//***************************************************************************//
//***************************************************************************//
//****************************Store - ChickenBOOM****************************//
//***************************************************************************//
//***************************************************************************//


#pragma semicolon 1

//////////////////////////////
//			INCLUDES		//
//////////////////////////////
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <store>
#include <zephstocks>
#include <morecolors>

//////////////////////////////
//		DEFINITIONS			//
//////////////////////////////
#define PLUGIN_PREFIX_CREDITS "\x01 \x04[Store]  "
#define PLUGIN_PREFIX_CHICKEN "\x01 \x04[杀鸡彩蛋]  "
#define PLUGIN_VERSION " 1.0 - [CG] Community Version "

//////////////////////////////////
//		GLOBAL VARIABLES		//
//////////////////////////////////
new Handle: CVAR_EXPLODE_DAMAGE = INVALID_HANDLE,
	Handle: CVAR_EXPLODE_RADIUS = INVALID_HANDLE,
	Handle: CVAR_EXPLODE_SOUND = INVALID_HANDLE;
new EXPLODE_DAMAGE,
	EXPLODE_RADIUS;
new String: EXPLODE_SOUND[PLATFORM_MAX_PATH];
new g_cvarMin = -1;
new g_cvarMax = -1;
new g_cvarMin2 = -1;
new g_cvarMax2 = -1;

//////////////////////////////////
//		PLUGIN DEFINITION		//
//////////////////////////////////
public Plugin: myinfo =
{
	name = "Store - ChickenBOOM",
	author = "maoling ( shAna.xQy )",
	description = " ",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/shAna_xQy/"
};

//////////////////////////////
//		PLUGIN FORWARDS		//
//////////////////////////////
public OnPluginStart()
{
	CVAR_EXPLODE_DAMAGE = CreateConVar("sm_chicken_explode_damage", "100.0", "Chicken Explode Damage. Set 0 to disable explosion.", _, true, 0.0, true, 10000.0);
	CVAR_EXPLODE_RADIUS = CreateConVar("sm_chicken_explode_radius", "1000.0", "Chicken Explode Radius. Set 0 to auto radius.", _, true, 0.0, true, 10000.0);
	CVAR_EXPLODE_SOUND = CreateConVar("sm_chicken_explode_sound", "weapons/hegrenade/explode3.wav", "Chicken Explode Sound. Set blank for disable."); //weapons/flashbang/flashbang_explode1.wav
	
	HookConVarChange(CVAR_EXPLODE_DAMAGE, OnDamageVarChange);
	HookConVarChange(CVAR_EXPLODE_RADIUS, OnRadiusVarChange);
	HookConVarChange(CVAR_EXPLODE_SOUND, OnSoundVarChange);
	
	EXPLODE_DAMAGE = GetConVarInt(CVAR_EXPLODE_DAMAGE);
	EXPLODE_RADIUS = GetConVarInt(CVAR_EXPLODE_RADIUS);

	g_cvarMin = RegisterConVar("sm_store_chicken_raffle_min_credits", "5", "最少给多少钱", TYPE_INT);
	g_cvarMin2 = RegisterConVar("sm_store_chicken_raffle_min_credits", "1", "最少扣多少钱", TYPE_INT);
	g_cvarMax = RegisterConVar("sm_store_chicken_raffle_max_credits", "20", "最多给多少钱", TYPE_INT);
	g_cvarMax2 = RegisterConVar("sm_store_chicken_raffle_max_credits", "10", "最多扣多少钱", TYPE_INT);
	
	AutoExecConfig(true, "StoreChickenBOOMCredits");	
	
	GetConVarString(CVAR_EXPLODE_SOUND, EXPLODE_SOUND, sizeof(EXPLODE_SOUND));
}

public OnMapStart()
{
	if(!StrEqual(EXPLODE_SOUND, ""))
	{
		PrecacheSound(EXPLODE_SOUND, true);
	}
}

//////////////////////////////
//		  SDK HOOKS	    	//
//////////////////////////////
public OnEntityCreated(entity)
{
	if(IsValidEntity(entity) && (EXPLODE_DAMAGE > 0))
	{
		new String: classname[32];
		GetEntityClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "chicken"))
		{
			SetEntPropFloat(entity, Prop_Data, "m_explodeDamage", float(EXPLODE_DAMAGE));
			SetEntPropFloat(entity, Prop_Data, "m_explodeRadius", float(EXPLODE_RADIUS));
			
			if(!StrEqual(EXPLODE_SOUND, ""))
			{
				HookSingleEntityOutput(entity, "OnBreak", OnBreak);
			}
		}
	}
}

public OnBreak(const String: output[], caller, activator, Float: delay)
{
	if(!StrEqual(EXPLODE_SOUND, ""))
	{
		EmitSoundToAll(EXPLODE_SOUND, caller);
	}
	new String:sClientName[MAX_NAME_LENGTH];
	GetClientName(activator,sClientName,sizeof(sClientName));

	new probability = GetRandomInt(1, 100);
	new credits = GetRandomInt(g_eCvars[g_cvarMin][aCache], g_eCvars[g_cvarMax][aCache]);
	new credits2 = GetRandomInt(g_eCvars[g_cvarMin2][aCache], g_eCvars[g_cvarMax2][aCache]);

	if(probability > 40)
	{
		Store_SetClientCredits(activator, Store_GetClientCredits(activator)+credits);
		CPrintToChat(activator,"%s \x10你获得了\x04 %d Credits \x10来自\x04[杀鸡彩蛋].", PLUGIN_PREFIX_CREDITS, credits);
		new RandomEvent = GetRandomInt(1, 20);
		switch (RandomEvent)
		{
			case 1 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C踩到了一坨屎，在里面找到了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>踩到了一坨屎\n　　　在里面找到了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 2 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C去大宝剑，老鸨倒贴了他\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>去体验大宝剑\n　　　老鸨倒贴了他 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 3 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C在网吧通宵，上H网发现了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>在网吧通宵\n　　　上H网发现了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 4 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C吃了一只苍蝇，恶心之后吐出来\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>吃了一只苍蝇\n　　恶心之后吐出来 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 5 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C扶老奶奶过马路，老奶奶给了他\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>扶老奶奶过马路\n　　老奶奶给了他 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 6 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C听电音抖腿，抖出来\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>听电音抖腿\n　　　　抖出来 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 7 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C一脚踢到主机电源，意外收获\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>一脚踢到主机电源\n　　　　意外收获 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 8 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C放屁蹦出屎，擦屁股时发现了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>放屁蹦出屎\n　　擦屁股时发现了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 9 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C蹲公厕没带纸，意外发现\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>蹲公厕没带纸\n　　　　意外发现 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 10 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C坟头蹦迪，突然天上飘落\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>坟头蹦迪\n　　突然天上飘落 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 11 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C加入传销组织，非法牟利\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>加入传销组织\n　　　　非法牟利 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 12 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C不拿群众一针一线，坑蒙拐骗了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>不拿群众一针一线\n　　坑蒙拐骗了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 13 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C捡到一分钱交给警察叔叔，警察叔叔奖励他\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>捡到一分钱交给警察叔叔\n　　警察叔叔奖励他 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 14 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C杀了一只鸡，在鸡骨头里发现了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>杀了一只鸡\n　　在鸡骨头里发现了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 15 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C打麻将输了掀桌，在桌底找到\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>打麻将输了掀桌\n　　　在桌底找到 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 16 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C炮轰陈抄封，僵尸乐园给他\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>炮轰陈抄封\n　　　僵尸乐园给他 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 17 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C插屁股抠破纸，意外发现\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>插屁股抠破纸\n　　　　意外发现 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 18 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C卖屁股不要钱，顾客强塞给他\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>卖屁股不要钱\n　　　顾客强塞给他 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 19 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C强X了曼妥思，猫灵奖励他\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>强X了曼妥思\n　　　猫灵奖励他 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 20 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C日了狗，狗狗给了他\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>日了狗\n　　　狗狗给了他 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
		}
	}
	else
	{
		Store_SetClientCredits(activator, Store_GetClientCredits(activator)+credits2);
		CPrintToChat(activator,"%s \x10你失去了\x04 %d Credits \x10因为\x04[杀鸡彩蛋].", PLUGIN_PREFIX_CREDITS, credits);
		new RandomEvent2 = GetRandomInt(1, 5);
		switch (RandomEvent2)
		{
			case 1 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C嫖娼被抓，被罚款\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>嫖娼被抓\n　　　　被罚款 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 2 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C扶老奶奶过马路，被讹了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>扶老奶奶过马路\n　　　　被讹了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 3 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C装逼失败，钱包少了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>装逼失败\n　　　　钱包少了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 4 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0CX曼妥思被反草，丢失了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>X曼妥思被反草\n　　　　丢失了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
			case 5 :
			{
				CPrintToChatAll("%s \x0C玩家 \x0E%s \x0C灵车飘逸出车祸，赔偿了\x04 %d \x0FCredits", PLUGIN_PREFIX_CHICKEN, sClientName, credits);
				PrintCenterTextAll("    <font color='#FF00FF'> %s </font><font color='#0066CC'>灵车飘逸出车祸\n　　　　赔偿了 </font><font color='#FFA500'>%d Credits</font>", sClientName, credits);
			}
		}
	}
}

//////////////////////////////////////
//		REST OF PLUGIN FORWARDS		//
//////////////////////////////////////
public OnDamageVarChange(Handle: convar, const String: oldValue[], const String: newValue[])
{
	if(!StrEqual(oldValue, newValue))
	{
		EXPLODE_DAMAGE = GetConVarInt(CVAR_EXPLODE_DAMAGE);
	}
}
public OnRadiusVarChange(Handle: convar, const String: oldValue[], const String: newValue[])
{
	if(!StrEqual(oldValue, newValue))
	{
		EXPLODE_RADIUS = GetConVarInt(CVAR_EXPLODE_RADIUS);
	}
}
public OnSoundVarChange(Handle: convar, const String: oldValue[], const String: newValue[])
{
	if(!StrEqual(oldValue, newValue))
	{
		GetConVarString(CVAR_EXPLODE_SOUND, EXPLODE_SOUND, sizeof(EXPLODE_SOUND));
		if(!StrEqual(EXPLODE_SOUND, ""))
		{
			PrecacheSound(EXPLODE_SOUND, true);
		}
	}
}