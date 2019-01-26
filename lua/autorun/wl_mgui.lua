if SERVER then  else
print("Loaded Team Manager")
	local TeamButtons = {}
		local GL = {}
		local SelClicked = ""
	local SelClickedUnit = {}
	local Frame
	local W , H = ScrW() , ScrH()
	local FrameX , FrameY = ScrW()*0.8 , ScrH()*0.8
local function SetData(Team,ID,Value,...)
	net.Start("SWL_GUI_Return")
	net.WriteTable({Team,ID,Value,...})
	net.SendToServer() 
end
local function permCheck(Team,SteamID)
		local r = ((SWhitelist[Team]or{})[SteamID]or{})["rank"]
		local perm = (((((SWhitelist[Team]or{})["##Settings##"]or{})["ranks"]or{})[r]or{})["Priv"]or{})["EditWL"]
		return tobool(perm) or GL.PrivOverride
	end

local NotesToSelf = {




}
local TeamLayout = {
	["##Settings##"] = {
		name = "%r %c",
		ranks = {
			Rank = {
				Key = 1, -- Higher Number == higher position
				Commander = true,
				Priv = {
					EditWL = true
				}


			}

		}
	}
}

local PlayerLayout = {
	Type = "Unit",
rank = "PVT",
RPName = "", -- internal
Log = {
"Unit A got warned ....",
"Unit A was promoted ..."
},
Codename = "",
CustomName = "" -- optional
}


local function temOptPnl()
local Pnl = GL.PTOpt
local SW = SWhitelist[SelClicked]or{}
if not SW["##Settings##"] then
 SW["##Settings##"] = {}
end
local RanksT = (SW["##Settings##"] or {})["ranks"]or{}
local Ranks = vgui.Create("DListView",Pnl)
Ranks:Clear()
Ranks:Dock(FILL)
Ranks:SetSize(400,1)
Ranks:DockMargin(200,15,15,15)
Ranks:AddColumn("Rank")
Ranks:AddColumn("Privilliges")
Ranks:AddLine("[New]")
Ranks:SetSortable(false)
Ranks:SetMultiSelect(false)
local R = table.ClearKeys(RanksT,true)
table.SortByMember(R,"Key",true)
for ki,v in pairs(R) do
	local Privs = v["Priv"]or{}
	local k = v["__key"]
	local S = "Key = "..tostring(v["Key"] or 0) .. " ,"
	for k2 , v2 in pairs(Privs) do
		S = S .. k2 .. "=" ..tostring(v2).. " ,"
	end
	S = string.sub(S,1,string.len(S)-1)
	Ranks:AddLine(k,S)

end
local RemoveRankBut = vgui.Create("DButton",Pnl)
RemoveRankBut:SetSize(70,40)
RemoveRankBut:SetPos(100,25)
RemoveRankBut:SetText("Remove\n    Rank")
RemoveRankBut.DoClick = function() 
		local T = ""
		local P = {}
	if Ranks:GetSelectedLine() then
	 P = RanksT[Ranks:GetLine(Ranks:GetSelectedLine()):GetColumnText(1)] or {}
	 T = Ranks:GetLine(Ranks:GetSelectedLine()):GetColumnText(1)
end

if P["Priv"] and T != "" then

	 local set = SW["##Settings##"]["ranks"]
	set[T] = nil
	SetData(SelClicked,nil,SW)
end
end



local AddEBut = vgui.Create("DButton",Pnl)
AddEBut:SetSize(70,40)
AddEBut:SetPos(25,25)
AddEBut:SetText("Add/Edit\n   Rank")
AddEBut.DoClick = function() 
	local P = {}
	local T = "[New]"
	if Ranks:GetSelectedLine() then
	 P = RanksT[Ranks:GetLine(Ranks:GetSelectedLine()):GetColumnText(1)] or {}
	 T = Ranks:GetLine(Ranks:GetSelectedLine()):GetColumnText(1)

end

				local PopUp = vgui.Create("DFrame")
				PopUp:SetSize(150,170)
				PopUp:Center()
				PopUp:MakePopup()
				PopUp:SetBackgroundBlur(true)
					local Namey = vgui.Create("DTextEntry",PopUp)
					Namey:SetPos(40,40)
					Namey:SetSize(100,20)

					local NameyL = vgui.Create("DLabel",PopUp)
					NameyL:SetPos(10,40)
					NameyL:SetText("Name:")
					Namey:SetText(P["__key"] or "New Rank")
					local Cmd = vgui.Create("DCheckBoxLabel",PopUp)
					Cmd:SetText("Is Commander")
					Cmd:SetPos(10,70)
					Cmd:SetValue(P["Commander"]or false)
					local EDITWL = vgui.Create("DCheckBoxLabel",PopUp)
					EDITWL:SetText("Can Edit WL")
					EDITWL:SetPos(10,90)
					EDITWL:SetValue((P["Priv"]or{})["EditWL"]or false)
					local	Key = vgui.Create("DNumberWang",PopUp)
					Key:SetPos(70,110)
					Key:SetSize(40,20)
					local KeyL = vgui.Create("DLabel",PopUp)
					KeyL:SetPos(10,110)
					KeyL:SetText("Key(Order):")
					Key:SetText(P["Key"] or 1)
					local ButtonA = vgui.Create("DButton",PopUp)
					ButtonA:SetSize(1,20)
					ButtonA:Dock(BOTTOM)
					ButtonA:SetText("Save")
					ButtonA.DoClick = function()
					local Mrg = {Priv={EditWL=tobool(EDITWL:GetChecked())},Commander=tobool(Cmd:GetChecked()	),Key = Key:GetValue()}
					if not SW["##Settings##"] then SW["##Settings##"] = {ranks={}} end
					if not SW["##Settings##"]["ranks"] then SW["##Settings##"]["ranks"] = {} end
					local set = SW["##Settings##"]["ranks"]

					set[T] = nil
					set[Namey:GetValue()] = Mrg
					SetData(SelClicked,nil,SW)
					PopUp:Close()
					end
end
local CNameCheckBox = vgui.Create("DCheckBoxLabel",Pnl)
CNameCheckBox:SetText("Enable Custom Name")
CNameCheckBox:SetPos(25,80)
CNameCheckBox:SetDark(1)
local CNameEntry = vgui.Create("DTextEntry",Pnl)
CNameEntry:SetPos(25,80+25)
CNameEntry:SetSize(140,20)
CNameCheckBox:SetValue(tobool(SW["##Settings##"]["name"]))
CNameEntry:SetValue(SW["##Settings##"]["name"]or"")
function CNameEntry:OnEnter()
	if CNameCheckBox:GetValue() then 
	SW["##Settings##"]["name"] = CNameEntry:GetValue()
	else
	SW["##Settings##"]["name"] = nil
	end

	end
function CNameCheckBox:OnChange(val) 
if val then 
SW["##Settings##"]["name"]= CNameEntry:GetValue()
else
SW["##Settings##"]["name"] = nil
end
end
local SaveB = vgui.Create("DButton",Pnl)
SaveB:SetPos(25,80+50)
SaveB:SetSize(140,20)
SaveB:SetText("Save")
SaveB.DoClick = function()
					SetData(SelClicked,nil,SW)
end














end

local function TmPanel2()
local SelClickedUnit2 = SelClickedUnit

local SW = SWhitelist[SelClicked]or{}
local RanksT = (SW["##Settings##"] or {})["ranks"]or{}
local  divw , divh  = Frame:GetSize()
local RankU = RanksT[SelClickedUnit[rank]or""]or{}
local Unit = table.Merge(SelClickedUnit,RankU)
POpt = GL.Opt
local div3 = vgui.Create("DVerticalDivider",POpt)
div3:Dock(FILL)
div3:SetTopHeight(divh/2)
local PPOpt = vgui.Create("DPanel",POpt)
local PTOpt = vgui.Create("DPanel",POpt)
div3:SetTop(PPOpt)
div3:SetBottom(PTOpt)
GL.PTOpt = PTOpt
local HeadLabel2 = vgui.Create("DLabel",POpt)
HeadLabel2:SetPos(0,0)
HeadLabel2:SetSize( divw/2, 20 )
HeadLabel2:SetTextColor( Color(0,0,0))
HeadLabel2:SetContentAlignment(8)
HeadLabel2:SetFont("Trebuchet24")
if SelClickedUnit["__key"] then
HeadLabel2:SetText("Unit:"..SelClickedUnit["__key"])
else
HeadLabel2:SetText("")
end

local Ranks = vgui.Create("DComboBox",PPOpt)
local RanksL = vgui.Create("DLabel",PPOpt)
RanksL:SetPos(10,25) 
RanksL:SetSize( 150, 20 )
RanksL:SetTextColor( Color(0,0,0))
RanksL:SetContentAlignment(8)
RanksL:SetText("Units Rank")
Ranks:SetPos(10,40) 
Ranks:SetSize( 150, 20 )
local RanksTS = table.ClearKeys(RanksT,true)
table.SortByMember(RanksTS,"Key",false)
Ranks:SetSortItems(false)
local i = 0
for k , v in pairs(RanksTS) do
	i = i+1
local v = RanksT[v["__key"]]["__key"]
if !(v == "[LegacyWL]") then
Ranks:AddChoice( v )
if SelClickedUnit2["rank"] == v then
Ranks:ChooseOptionID(i)
end
end
end

local promButton = vgui.Create("DButton",PPOpt)
promButton:SetSize(70,20)
promButton:SetPos((150/2+10)+150/4-70/2,65)
promButton:SetText("Promote")
promButton.DoClick = function()
if (Ranks:GetSelectedID() or 0) > 1 then
print(Ranks:GetSelected())
Ranks:ChooseOptionID(Ranks:GetSelectedID()-1)
end
end
local demButton = vgui.Create("DButton",PPOpt)
demButton:SetSize(70,20)
demButton:SetPos((150/2+10)-150/4-70/2,65)
demButton:SetText("Demote")
demButton.DoClick = function()
if (Ranks:GetSelectedID() or 999) < table.Count(RanksTS)-1 then
Ranks:ChooseOptionID(Ranks:GetSelectedID()+1)
end
end
Ranks.OnSelect = function(i,v,d)
	print(i,v,d)
SelClickedUnit["rank"] = d
SelClickedUnit["rankInv"] = nil
SetData(SelClicked,SelClickedUnit["__key"],SelClickedUnit)

end
AddUnitButton = vgui.Create("DButton",PPOpt)
local X , Y = (150/2+10)-145/2,90 
AddUnitButton:SetSize(145,20)
AddUnitButton:SetPos(X,Y)
AddUnitButton:SetText("Remove Unit")
AddUnitButton.DoClick = function(i,v,d)
SetData(SelClicked,SelClickedUnit["__key"],nil)
end
local Log = vgui.Create("DListView",PPOpt)
Log:Dock(FILL)
Log:DockMargin(170,25,10,10)
Log:AddColumn("Log")
for k,v in pairs(SelClickedUnit["Log"]or{})do
	Log:AddLine(v)
end
local LogAdd = vgui.Create("DButton",PPOpt)
local X , Y = (150/2+10)-145/2,90+25
LogAdd:SetSize(145,20)
LogAdd:SetPos(X,Y)
LogAdd:SetText("Add Log Entry")
LogAdd.DoClick = function(i,v,d)
					local PopUp = vgui.Create("DFrame")
			PopUp:SetSize(300,100)
			PopUp:Center()
			PopUp:SetTitle("Log Entry")
			PopUp:MakePopup()
			PopUp:SetBackgroundBlur(true)
			local PPLabel = vgui.Create("DLabel",PopUp)
			PPLabel:SetText("Enter a log entry to add it too log")
			PPLabel:Dock(TOP)
			PPLabel:SetContentAlignment(8)
			local PPEntry = vgui.Create("DTextEntry",PopUp)
			PPEntry:SetSize(250,20)
			PPEntry:SetPos(150-250/2,47)
			local PPButton = vgui.Create("DButton",PopUp)
			PPButton:Dock(BOTTOM)
			PPButton:SetText("Add Entry")
			PPButton.DoClick = function()
				if  PPEntry:GetValue() ~= "" then
					SelClickedUnit["Log"] = table.Add(SelClickedUnit["Log"],{PPEntry:GetValue()})
					SetData(SelClicked,SelClickedUnit["__key"]or"Broken",SelClickedUnit)
					PopUp:Close()
					end
				end




end

local CNameCheckBox = vgui.Create("DCheckBoxLabel",PPOpt)
CNameCheckBox:SetText("Enable Custom Name")
CNameCheckBox:SetPos(X,Y+25)
CNameCheckBox:SetDark(1)
local CNameEntry = vgui.Create("DTextEntry",PPOpt)
CNameEntry:SetPos(X,Y+25+25)
CNameEntry:SetSize(145,20)
CNameCheckBox:SetValue(tobool(SelClickedUnit["CustomName"]))
CNameEntry:SetValue(SelClickedUnit["CustomName"]or"")
function CNameEntry:OnChange()
	if CNameCheckBox:GetValue() then 
	SelClickedUnit["CustomName"] = CNameEntry:GetValue()
	else
	SelClickedUnit["CustomName"] = nil
	end

	end
function CNameCheckBox:OnChange(val) 
if val then 
SelClickedUnit["CustomName"] = CNameEntry:GetValue()
else
SelClickedUnit["CustomName"] = nil
end
end
local SaveB = vgui.Create("DButton",PPOpt)
SaveB:SetPos(X,Y+125)
SaveB:SetSize(145,20)
SaveB:SetText("Save")
SaveB.DoClick = function()
					SetData(SelClicked,SelClickedUnit["__key"]or"´Sth Wrong",SelClickedUnit)
end
local CoName = vgui.Create("DLabel",PPOpt)
CoName:SetPos(X,Y+75)
CoName:SetSize(145,20)
CoName:SetText("Code Name")
CoName:SetContentAlignment(8) 
CoName:SetTextColor(Color(0,0,0))
local COEntry = vgui.Create("DTextEntry",PPOpt)
COEntry:SetPos(X,Y+100)
COEntry:SetSize(145,20)
COEntry:SetValue(SelClickedUnit["Codename"]or"")
function COEntry:OnChange()
	SelClickedUnit["Codename"] = COEntry:GetValue()
	end


temOptPnl()
end

local function TmPanel()
local Panel = vgui.Create("DPanel",Frame)
Panel:Dock(FILL)
Panel:DockMargin(5,5,5,5)
Panel:DockPadding(5,5,5,5)
function Panel:Paint(w,h)
draw.RoundedBox(5, 0, 0, w, h, Color(128,128,128))
end 	
local HeadLabel = vgui.Create("DLabel",Panel)
HeadLabel:Dock(TOP)
HeadLabel:SetAutoStretchVertical(true)
HeadLabel:SetText(SelClicked or "")

HeadLabel:SetFont("DermaLarge")
HeadLabel:SetContentAlignment(8) 
HeadLabel:SetTextColor(Color(0,0,0))
local div = vgui.Create("DHorizontalDivider",Panel)
div:Dock(FILL)
local  divw , divh  = Frame:GetSize()
div:SetLeftWidth(divw/3)
local bdiv2 = vgui.Create("DPanel",Panel)
div:SetLeft(bdiv2)
local div2 = vgui.Create("DVerticalDivider",bdiv2)
div2:Dock(FILL)
div2:SetTopHeight(divh/2)

local POpt = vgui.Create("DPanel",Panel)
div:SetRight(POpt)
GL.Opt = POpt
GL.div = div
GL.Pnl = Panel
local PLUnit = vgui.Create("DListView",Panel)
div2:SetTop(PLUnit)
PLUnit:AddColumn("Rank")
PLUnit:AddColumn("Units")
local PLCmd = vgui.Create("DListView",Panel)
div2:SetBottom(PLCmd)
PLCmd:AddColumn("Rank")
PLCmd:AddColumn("Commanders") 
function RefreshPlys()

-- Units --
PLUnit:Clear()
local II = true
local Rank =""
local Rank2 =""
local SW = SWhitelist[SelClicked]or{}
local Ranks = (SW["##Settings##"] or {})["ranks"]or{}
SW = table.ClearKeys(SW,true)
table.SortByMember(SW,"Key",false)
GL.SWS = SW
local l = PLUnit:AddLine("New Unit")



for k , v in pairs(SW) do
k = v["__key"]
Rank = v["rank"]
II = not II
	if !(v==true) then Rank = v["rank"] else Rank = "N/A" end
	if (v == true)or(v["Type"] == "Unit")and !((Ranks[Rank]or{})["Commander"]) then
			if v["rankInv"] then
						  p = PLUnit:AddLine("[Invalid]"..Rank,k)
			else
			  p = PLUnit:AddLine(Rank,k)
			 end
			  
	elseif v["Type"] == "Commander" or (Ranks[Rank]or{})["Commander"] then
			 p = PLCmd:AddLine(Rank,k)
	end
			--if II then function p:Paint(w , h) draw.RoundedBox(3, 2, 2, w-4, h-4,TG) end else function p:Paint(w , h) draw.RoundedBox(3, 2, 2, w-4, h-4,TG2) end
			--end		
end
end

PLUnit:SetMultiSelect(false)
PLUnit.OnRowSelected = function(st,index,pnl)
PLCmd:ClearSelection()
if pnl:GetColumnText(1) ~= "New Unit" then
SelClickedUnit = (SWhitelist[SelClicked]or{})[pnl:GetColumnText(2)]
TmPanel2()
else
	local PopUp = vgui.Create("DFrame")
	PopUp:SetSize(300,100)
	PopUp:Center()
	PopUp:MakePopup()
	PopUp:SetBackgroundBlur(true)
	local PPLabel = vgui.Create("DLabel",PopUp)
	PPLabel:SetText("Enter SteamID to Add to Whitelist")
	PPLabel:Dock(TOP)
	PPLabel:SetContentAlignment(8)
	local PPEntry = vgui.Create("DTextEntry",PopUp)
	PPEntry:SetSize(150,20)
	PPEntry:SetPos(150-150/2,47)
	local PPButton = vgui.Create("DButton",PopUp)
	PPButton:Dock(BOTTOM)
	PPButton:SetText("Add User")
	PPButton.DoClick = function()
		if  PPEntry:GetValue() ~= "" then

			(SWhitelist[SelClicked]or{})[tostring(PPEntry:GetValue())] = true
			PopUp:Close()
			SetData(SelClicked,PPEntry:GetValue(),true)
			end
		end
	end
end
PLCmd:SetMultiSelect(false)
PLCmd.OnRowSelected = function(st,index,pnl)
PLUnit:ClearSelection()
SelClickedUnit = (SWhitelist[SelClicked]or{})[pnl:GetColumnText(2)]
TmPanel2()
end


RefreshPlys()
TmPanel2()
end




local function TeamBar() 
local A = true
local Selec = vgui.Create("DScrollPanel",Frame)
Selec:Dock(LEFT)
Selec:SetSize(75+15,50)
Selec:GetVBar():SetHideButtons(true)
Vbar = Selec:GetVBar()

function Vbar.btnGrip:Paint( w, h ) end
function Vbar:Paint( w, h ) end

for k , v in pairs(SWhitelist) do
	if permCheck(k,LocalPlayer():SteamID()) then
	A = false
	local DLabel = Selec:Add( "DButton" )
	DLabel:SetText( k )
	DLabel:SetSize(75,75)
	DLabel:Dock( TOP )
	DLabel.CID = k
	function DLabel:Paint( w, h )
	draw.RoundedBox( 8, 0, 0, w, h, Color(170,170,170) )
		end
	DLabel.DoClick = function(s)
		SelClicked = s.CID
		s:SetEnabled(true)
		TmPanel()

		end
	function DLabel:DoRightClick(a,b,c)
		if GL.ManOverride then
		local Team = self:GetText()
		local Menu = DermaMenu()
	local RmWL = Menu:AddOption( "Disable Whitelist" )
		RmWL:SetIcon( "icon16/cancel.png" )
		RmWL.DoClick = function(...)
		SetData(Team,nil,nil)
		end
		Menu:Open()
	end
	end


	TeamButtons[k] = DLabel
	if SelClicked == k then
		TmPanel()
	end
end
end
	
	
	GL.Selec = Selec
	if GL.ManOverride then
	A = false
	local DAddButton = Selec:Add( "DButton" )
	DAddButton:SetText( "   [Add Job]\n[Clear JobWL]" )
	DAddButton:SetSize(75,75)
	DAddButton:Dock( TOP )
	TeamButtons["Add"] = DAddButton

	DAddButton.DoClick = function()

					local PopUp = vgui.Create("DFrame")
					PopUp:SetSize(150,170)
					PopUp:Center()
					PopUp:MakePopup()
					PopUp:SetBackgroundBlur(true)
					PopUp:SetTitle("Add a New Job")
					local Button = vgui.Create("DButton",PopUp)
					Button:Dock(BOTTOM)
					Button:SetText("Add Job to WL")
					local List = vgui.Create("DListView",PopUp)
					List:Dock(FILL)
					List:AddColumn("Jobs")
						local Jobs = team.GetAllTeams() or {}
						for k ,v in pairs(Jobs) do
							print(team.GetName(k))
							List:AddLine(team.GetName(k))


						end
					Button.DoClick = function()
						local Sel = List:GetSelectedLine()
						local Line = List:GetLine(Sel)
						local L = Line:GetColumnText(1)
						print(Sel,Line,L)
				SetData(L,nil,{})
				PopUp:Close()

					end



	end
end

if A then
	Frame:Close()
end
end






net.Receive("SWL_GUI_Data" , function()

	Frame:SetSize(FrameX,FrameY)
	Frame:MakePopup()
	Frame:Center()
	Frame:SetTitle("SW Team Manager")
	Frame:DockPadding(5,25,5,0)







	CAMI.PlayerHasAccess(LocalPlayer(),"Whitelist_ManageJobs",function(b2,s)
	CAMI.PlayerHasAccess(LocalPlayer(),"Whitelist_Edit",function(b,s)
	GL.PrivOverride = b or b2 or  false
		GL.ManOverride = b2 or false
	SWhitelist = net.ReadTable() or {}
	SWhitelist["##Admins##"] = nil
	for k ,v in pairs(SWhitelist) do
		local SW = v
			local Ranks = (SW["##Settings##"] or {})["ranks"]or{}
			Ranks["[LegacyWL]"] = {Key = 0}
			for k , v in pairs(SW) do
			if !(v==true) then Rank = v["rank"] else Rank = "" end
			if SW[k] == true then
			SW[k] = {Type = "Unit" , rank = "[LegacyWL]" , Key=0}
			else
			Rank = Rank or "[Broken]"
			table.Merge(SW[k] , Ranks[Rank]or{Key = 0,rankInv = true })
			end

end


	
	
	
	
	
	
	end
	if GL.Selec then  GL.Selec:Remove() end


	TeamBar()
end)
end)
end)
concommand.Add("wl" , function()	Frame = vgui.Create("DFrame")  print("Getting Data") net.Start("SWL_GUI") net.SendToServer() end )
concommand.Add("whitelist" , function()  	Frame = vgui.Create("DFrame") print("Getting Data") net.Start("SWL_GUI") net.SendToServer() end )
end