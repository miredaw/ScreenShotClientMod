#include <sourcemod>
#include <filenetmessages>
#include <clientmod>
#include <clientmod/multicolors>
#include <tEasyFTP>

#pragma semicolon 1
#pragma tabsize 0

Handle db;

char screenshotname[256];

char target_name[120];
char target_steamid[60];
char target_ip[20];

char admin_name[120];
char admin_steamid[60];
char admin_ip[20];

char sTime1[50];
int time_in_unix;

bool ongoing;

public Plugin myinfo =
{
	name = "Mireda ScreenShot Capture CM ONLY",
	author = "Mireda",
	description = "",
	version = "1",
	url = "Mireda.ir"
};		

public void OnPluginStart(){


	RegAdminCmd("sm_sc" , screen_menu_admin , ADMFLAG_BAN);

	InitDB(db);
}

public void OnMapStart(){


 ongoing = false;
}

public void InitDB(&Handle:DbHNDL)
{


	char Error[255];
	

	DbHNDL = SQL_Connect("MiredaScreenShots", true, Error, sizeof(Error));
	
	

	if(DbHNDL == INVALID_HANDLE)
	{

	///
	PrintToServer("\n\n Mireda ScreenShots MYSQL Did not Respond\n\n");
	
	}
	
	else if (DbHNDL != INVALID_HANDLE){
	

	
	char Query_MakeSCtable[450];
	Format(Query_MakeSCtable, sizeof(Query_MakeSCtable), "CREATE TABLE IF NOT EXISTS `screenshots` (idnum int NOT NULL AUTO_INCREMENT , pl_name TEXT NOT NULL , pl_steamid TEXT NOT NULL  , pl_ip TEXT NOT NULL , pl_screen TEXT NOT NULL , sc_date int NOT NULL , sv_name TEXT NOT NULL , sv_ip TEXT NOT NULL , admin_name TEXT NOT NULL , admin_steamid TEXT NOT NULL , admin_ip TEXT NOT NULL , PRIMARY KEY (idnum));");


	SQL_LockDatabase(DbHNDL);
	

	SQL_FastQuery(DbHNDL, Query_MakeSCtable);


	SQL_UnlockDatabase(DbHNDL);
	SQL_SetCharset(DbHNDL,"utf8");

	}
}

public void ScreenCaptureFunc(int client){


	char playersteamid[60];
	


	GetClientAuthId(client, AuthId_Engine, playersteamid, sizeof(playersteamid));

	ReplaceString(playersteamid, sizeof(playersteamid), ":", "-", false);
	
	time_in_unix = GetTime();
	FormatTime(sTime1, sizeof(sTime1), "%Y_%m_%d_%H_%M_%S", time_in_unix);



	Format(screenshotname , sizeof(screenshotname) , "%s_%s", playersteamid , sTime1);


	char ScreenCMD[300];
	Format(ScreenCMD , sizeof(ScreenCMD) , "jpeg %s 50" , screenshotname);

	ClientCommand(client , ScreenCMD);

	CreateTimer(3.0 , reqscreen , client);

	
}


public Action reqscreen(Handle timer , any client){

	if(!IsClientInGame(client)){

		return Plugin_Continue;
	}

	if(ongoing == true){

		PrintToChat(client, "[SM] \x02One ScreenShot is being uploaded , so wait till its finished.");
		return Plugin_Continue;
	}

	ongoing = true;

	char filetoget[140];
	Format(filetoget , sizeof(filetoget) , "screenshots/%s.jpg" , screenshotname );

    FNM_RequestFile(client,filetoget);

	//PrintToChatAll("%d" , id);

	//if(){


	//	PrintToChatAll("file ( %s ) recieved %d" , screenshotname , id);

	//}//FileExists(const char[] path, bool use_valve_fs, const char[] valve_path_id)


	//ravesh 2vom
	//CreateTimer(60.0 , searchForFileTimer , client);
	


	return Plugin_Continue;
}

public int FNM_OnFileReceived(int client, const char[] file, int transferID){

	char filetoget[140];
	Format(filetoget , sizeof(filetoget) , "screenshots/%s.jpg" , screenshotname );



	if(StrEqual(filetoget , file , false))
	{



	char sv_name[50] ;
	GetConVarString(FindConVar("hostname") ,sv_name , sizeof(sv_name));
	

///ip address
	int ip_value = GetConVarInt(FindConVar("hostip"));
	
	char ip_address[20];
	
	Inet_NtoA(ip_value, ip_address, sizeof(ip_address));
	
	int sv_port = GetConVarInt(FindConVar("hostport"));
	
	char sv_fullip[30];
	
	Format(sv_fullip,sizeof(sv_fullip),"%s:%d",ip_address,sv_port);

	//	Format(Query_MakeSCtable, sizeof(Query_MakeSCtable), "CREATE TABLE IF NOT EXISTS `screenshots` (idnum int NOT NULL AUTO_INCREMENT , pl_steamid TEXT NOT NULL , pl_name TEXT NOT NULL , pl_ip TEXT NOT NULL , pl_screen TEXT NOT NULL , pl_date int NOT NULL , sv_name TEXT NOT NULL 
	//, sv_ip TEXT NOT NULL , admin_name TEXT NOT NULL , admin_steamid TEXT NOT NULL , admin_ip TEXT NOT NULL , PRIMARY KEY (idnum));");
	char sendInfoToDB[750];
	Format(sendInfoToDB, sizeof(sendInfoToDB), "INSERT INTO `screenshots` (`pl_name` , `pl_steamid`, `pl_ip` , `pl_screen`  , `sc_date` , `sv_name` , `sv_ip` , `admin_name` , `admin_steamid` , `admin_ip`) VALUES ('%s' , '%s' , '%s' , '%s' , '%d' , '%s' , '%s' , '%s' , '%s' , '%s');" , target_name , target_steamid , target_ip  , screenshotname , time_in_unix , sv_name , sv_fullip , admin_name , admin_steamid , admin_ip);


			for(int i = 1; i <= MaxClients; i++)
			{
		       if (IsClientInGame(i) && !IsFakeClient(i))
				if ( !IsClientSourceTV(i)){


                        char stttm[50];

                        GetClientAuthId(i, AuthId_Engine, stttm, sizeof(stttm));

                        if(StrEqual(stttm , admin_steamid , false )){

							SQL_TQuery(db, SQL_checker , sendInfoToDB , i);



						}


				}
			}

	






	//	PrintToChatAll("[SM] Kir Umad file %s hooooooooo ID = %d" , file , transferID);
	}
	


}

public Action searchForFileTimer(Handle timer , any data){

	char filetoget[140];
	Format(filetoget , sizeof(filetoget) , "screenshots/%s.jpg" , screenshotname );

	if(FileExists(filetoget)){


		//PrintToChatAll("File Exist.");

		//CREATE TABLE IF NOT EXISTS `screenshots` (idnum int NOT NULL AUTO_INCREMENT ,
		// pl_steamid TEXT NOT NULL , pl_name TEXT NOT NULL , pl_screen TEXT NOT NULL , pl_date int NOT NULL , PRIMARY KEY (idnum));
	///hostname
	char sv_name[50] ;
	GetConVarString(FindConVar("hostname") ,sv_name , sizeof(sv_name));
	

///ip address
	int ip_value = GetConVarInt(FindConVar("hostip"));
	
	char ip_address[20];
	
	Inet_NtoA(ip_value, ip_address, sizeof(ip_address));
	
	int sv_port = GetConVarInt(FindConVar("hostport"));
	
	char sv_fullip[30];
	
	Format(sv_fullip,sizeof(sv_fullip),"%s:%d",ip_address,sv_port);

	//	Format(Query_MakeSCtable, sizeof(Query_MakeSCtable), "CREATE TABLE IF NOT EXISTS `screenshots` (idnum int NOT NULL AUTO_INCREMENT , pl_steamid TEXT NOT NULL , pl_name TEXT NOT NULL , pl_ip TEXT NOT NULL , pl_screen TEXT NOT NULL , pl_date int NOT NULL , sv_name TEXT NOT NULL 
	//, sv_ip TEXT NOT NULL , admin_name TEXT NOT NULL , admin_steamid TEXT NOT NULL , admin_ip TEXT NOT NULL , PRIMARY KEY (idnum));");
	char sendInfoToDB[750];
	Format(sendInfoToDB, sizeof(sendInfoToDB), "INSERT INTO `screenshots` (`pl_name` , `pl_steamid`, `pl_ip` , `pl_screen`  , `sc_date` , `sv_name` , `sv_ip` , `admin_name` , `admin_steamid` , `admin_ip`) VALUES ('%s' , '%s' , '%s' , '%s' , '%d' , '%s' , '%s' , '%s' , '%s' , '%s');" , target_name , target_steamid , target_ip  , screenshotname , sTime1 , sv_name , sv_fullip , admin_name , admin_steamid , admin_ip);

	SQL_TQuery(db, SQL_checker , sendInfoToDB , data);

	}
	else if(!FileExists(filetoget)){

		//PrintToChatAll("File Not Exist.");

		CreateTimer(5.0 , searchForFileTimer);

	}

	return Plugin_Continue;
}

public SQL_checker(Handle owner, Handle hndl, char[] error, any data)
{

	ongoing = false;
	
	if(hndl == INVALID_HANDLE)
	{
	
	//

    PrintToChat(data , "Failed to add player ScreenShot Data to DB");



	}

    else {

	uploadIMGFunc();

    }
}

public Action screen_menu_admin(int client , int args){



	load_menu(client);

    return Plugin_Continue;
}

public void load_menu(int client){




	Menu menuu = new Menu(MenuHandlerChoosePlayer);
    menuu.SetTitle("RoyalCS - Who To Capture ScreenShot?");			

    

	for(int i = 1; i <= MaxClients; i++)
	{
    	if (IsClientInGame(i) && !IsFakeClient(i))
			if ( !IsClientSourceTV(i)){

				if(CM_IsClientModUser(i,true))
				{
					char playersteamid[60];
					char playername[120];
					GetClientAuthId(i, AuthId_Engine, playersteamid, sizeof(playersteamid));
					GetClientName(i , playername , sizeof(playername));


					menuu.AddItem(playersteamid, playername);
				}


			}
		
	}
	
    menuu.ExitButton = true;
    menuu.Display(client, 90);
}


public int MenuHandlerChoosePlayer(Menu menu, MenuAction action, int client, int param2)
{

	switch (action) {
	
	
		case MenuAction_Select:
		{
		
			char item[50];
            char display_item_string[120];
			menu.GetItem(param2,item,sizeof(item),_,display_item_string,sizeof(display_item_string));

			Format(target_steamid , sizeof(target_steamid) , "%s" , item);


				Menu menu2 = new Menu(MenuHandlerPrompt);

				char titlee[160];
				Format(titlee , sizeof(titlee) , "Capture From %s" , display_item_string);
    			menu2.SetTitle(titlee);

				menu2.AddItem("yes", "Yes , Im Sure!");
				menu2.AddItem("no", "No!");

					
    			SetMenuExitBackButton(menu2,true);
    			menu2.Display(client, 90);           

            


		}
		
	}


}


public int MenuHandlerPrompt(Menu menu, MenuAction action, int client, int param2)
{

	switch (action) {
	
	
		case MenuAction_Select:
		{
		
			char item[10];
            char display_item_string[20];
			menu.GetItem(param2,item,sizeof(item),_,display_item_string,sizeof(display_item_string));
//
			if(StrEqual(item , "yes" , false)){


			for(int i = 1; i <= MaxClients; i++)
            {
               if (IsClientInGame(i) && !IsFakeClient(i))
				if ( !IsClientSourceTV(i)){


                        char stttm[50];

                        GetClientAuthId(i, AuthId_Engine, stttm, sizeof(stttm));

                        if(StrEqual(stttm , target_steamid , false )){

							
							GetClientName(i , target_name , sizeof(target_name));
							GetClientIP(i , target_ip , sizeof(target_ip));

							GetClientName(client , admin_name , sizeof(admin_name));
							GetClientAuthId(client, AuthId_Engine, admin_steamid, sizeof(admin_steamid));
							GetClientIP(client , admin_ip , sizeof(admin_ip));

							ScreenCaptureFunc(i);

							
							if(CM_IsClientModUser(client , true)){

										CPrintToChat(client,"{lime}[{hotpink}RoyalCS{lime}] {lightgreen}Wait {cyan}60 {gold}Seconds {lightgreen}to Get {cyan}Image {gold}From {hotpink}%N" , i);
										

							}
							else if (!CM_IsClientModUser(client,true))
									PrintToChat(client, "[SM] Wait 60 Seconds to Get Image From %N !" , i);

                        }

                }
            }



			}

			else if (StrEqual(item , "no" , false)){


				PrintToChat(client , "ok bye :D");
			}


			

		}

		case MenuAction_Cancel:
        {
            switch (param2)
            {
                case MenuCancel_ExitBack:
                {
						load_menu(client);	
						return 0;
                }
            }
        }
		
	}

	return 0;
}

/*



 */

stock Inet_NtoA(int binary, char[] ip_address, int maxlength)
{
    int quads[4];
    quads[0] = binary >> 24 & 0x000000FF; // mask isn't necessary for this one, but do it anyway
    quads[1] = binary >> 16 & 0x000000FF;
    quads[2] = binary >> 8 & 0x000000FF;
    quads[3] = binary & 0x000000FF;
	
    Format(ip_address, maxlength, "%d.%d.%d.%d", quads[0], quads[1], quads[2], quads[3]);
}

public void uploadIMGFunc(){




	char filetoget[140];
	Format(filetoget , sizeof(filetoget) , "screenshots/%s.jpg" , screenshotname );
	
	
	EasyFTP_UploadFile("demostorage", filetoget, "/", IMGUploadCallBack); 


}

public IMGUploadCallBack(char[] sTarget, char[] sLocalFile, char[] sRemoteFile, int iErrorCode, any data)
{



	


    if(iErrorCode == 0)       
    {

	for(int i = 1; i <= MaxClients; i++)
	{
		       if (IsClientInGame(i) && !IsFakeClient(i))
				if ( !IsClientSourceTV(i)){


                        char stttm[50];

                        GetClientAuthId(i, AuthId_Engine, stttm, sizeof(stttm));

                        if(StrEqual(stttm , admin_steamid , false )){

								char title[120];
								char urlcm[400];

										Format(urlcm,sizeof(urlcm),"http://panel.royalcs.ir/screenshots/index.php?imageid=%s",screenshotname);
	
	
										Format(title,sizeof(title),"ScreenShot Page : ID %s",screenshotname);
	
	
											Handle setup = CreateKeyValues("data");
									
											KvSetString(setup, "title", title);
											KvSetNum(setup, "type", MOTDPANEL_TYPE_URL);
											KvSetString(setup, "msg", urlcm);	
											ShowVGUIPanel(i, "info", setup, true);	
											CloseHandle(setup);
									
									if(CM_IsClientModUser(i , true)){

										//CPrintToChat(i,"{lime}[{hotpink}RoyalCS{lime}] {lightgreen}Success uploading Img File {cyan}%s .\n", sLocalFile);
										CPrintToChat(i,"{lime}[{hotpink}RoyalCS{lime}] {lightgreen}Watch {cyan}%s {gold}ScreenShot {lightgreen}in Here :{cyan}\npanel.royalcs.ir/screenshots?imageid=%s" ,  target_name , screenshotname);

									}

									else if(!CM_IsClientModUser(i , true)){

										//PrintToChat(i,"Success uploading Img File %s .", sLocalFile);
										PrintToChat(i,"[SM] Watch %s ScreenShot in Here :\npanel.royalcs.ir/screenshots?imageid=%s" ,  target_name , screenshotname);

									}



						}


				}
	}


    } else {
       // PrintToServer("Failed uploading Demo File %s to %s.", sLocalFile, sTarget);    

	for(int i = 1; i <= MaxClients; i++)
	{
		       if (IsClientInGame(i) && !IsFakeClient(i))
				if ( !IsClientSourceTV(i)){


                        char stttm[50];

                        GetClientAuthId(i, AuthId_Engine, stttm, sizeof(stttm));

                        if(StrEqual(stttm , admin_steamid , false )){

							PrintToChat(i,"Failed uploading Demo File %s to %s.", sLocalFile, sTarget);



						}


				}
	}
	//	char statsup[200];
		//Format(statsup , sizeof(statsup) , "Failed uploading Demo File %s to %s. Err : " ,  sLocalFile, sTarget , iErrorCode);
		
		//LogMe(statsup);

    }
}