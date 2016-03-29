-- Global Variables
DPSMate.Sync.Async = false

-- Local Variables
local player = UnitName("player")
local _, playerclass = UnitClass("player")
local pid = 0
local time, iterator, voteStarter = 0, 1, false
local t = {}
local strgsub = string.gsub
local tinsert = table.insert
local func = function(c) tinsert(t,c) end
local LastMouseover = nil
local DB = DPSMate.DB

-- Beginn Functions

function DPSMate.Sync:OnLoad()
	if (not DPSMateUser[player]) then
		DPSMateUser[player] = {
			[1] = DPSMate:TableLength(DPSMateUser)+1,
			[2] = strlower(playerclass),
		}
	end
	pid = DPSMateUser[player][1]
end

function DPSMate.Sync:OnUpdate(elapsed)
	if DB.loaded and DPSMateSettings["sync"] then
		time=time+elapsed
		if iterator==1 then
			self:DMGDoneAllOut()
			iterator = 2
		elseif time>=1 and iterator==2 then
			self:DMGDoneAbilityOut()
			iterator = 3
		elseif time>=2 and iterator==3 then
			self:DMGDoneStatOut()
			iterator = 4
		elseif time>=5 and iterator==4 then
			self:HealingAllOut(DPSMateEHealing, "E")
			iterator = 5
		elseif time>=6 and iterator==5 then
			self:HealingAbilityOut(DPSMateEHealing, "E")
			iterator = 6
		elseif time>=7 and iterator==6 then
			self:HealingStatOut(DPSMateEHealing, "E")
			iterator = 7
		elseif time>=10 and iterator==7 then
			self:HealingAllOut(DPSMateTHealing, "T")
			iterator = 8
		elseif time>=11 and iterator==8 then
			self:HealingAbilityOut(DPSMateTHealing, "T")
			iterator = 9
		elseif time>=12 and iterator==9 then
			self:HealingStatOut(DPSMateTHealing, "T")
			iterator = 10
		elseif time>=15 and iterator==10 then
			self:HealingAllOut(DPSMateOverhealing, "O")
			iterator = 11
		elseif time>=16 and iterator==11 then
			self:HealingAbilityOut(DPSMateOverhealing, "O")
			iterator = 12
		elseif time>=17 and iterator==12 then
			self:HealingStatOut(DPSMateOverhealing, "O")
			iterator = 13
		elseif time>=20 and iterator==13 then
			self:AbsorbsOut() 
			self:AbsorbsStatOut()
			iterator = 14
		elseif time>=23 and iterator==14 then
			self:DispelsOut()
			iterator = 15
		elseif time>=26 and iterator==15 then
			self:DMGTakenAllOut()
			iterator = 16
		elseif time>=27 and iterator==16 then
			self:DMGTakenAbilityOut()
			iterator = 17
		elseif time>=28 and iterator==17 then
			self:DMGTakenStatOut()
			iterator = 18
		elseif time>=31 and iterator==18 then
			self:EDAllOut(DPSMateEDD, "D")
			iterator = 19
		elseif time>=32 and iterator==19 then
			self:EDAbilityOut(DPSMateEDD, "D")
			iterator = 20
		elseif time>=33 and iterator==20 then
			self:EDStatOut(DPSMateEDD, "D")
			iterator = 21
		elseif time>=36 and iterator==21 then
			self:EDAllOut(DPSMateEDT, "T")
			iterator = 22
		elseif time>=37 and iterator==22 then
			self:EDStatOut(DPSMateEDT, "T")
			iterator = 23
		elseif time>=38 and iterator==23 then
			self:EDAbilityOut(DPSMateEDT, "T")
			iterator = 24
		elseif time>=41 and iterator==24 then
			self:HealingAllOut(DPSMateHealingTaken, "TTaken")
			iterator = 25
		elseif time>=42 and iterator==25 then
			self:HealingTakenAbilityOut(DPSMateHealingTaken, "T")
			iterator = 26
		elseif time>=43 and iterator==26 then
			self:HealingStatOut(DPSMateHealingTaken, "TTaken")
			iterator = 27
		elseif time>=46 and iterator==27 then
			self:HealingAllOut(DPSMateEHealingTaken, "ETaken")
			iterator = 28
		elseif time>=47 and iterator==28 then
			self:HealingTakenAbilityOut(DPSMateEHealingTaken, "E")
			iterator = 29
		elseif time>=48 and iterator==29 then
			self:HealingStatOut(DPSMateEHealingTaken, "ETaken")
			iterator = 30
		elseif time>=51 and iterator==30 then
			self:DeathsAllOut()
			iterator = 31
		elseif time>=52 and iterator==31 then
			self:DeathsOut()
			iterator = 32
		elseif time>=55 and iterator==32 then
			self:InterruptsAllOut()
			iterator = 33
		elseif time>=56 and iterator==33 then
			self:InterruptsAbilityOut()
			iterator = 34
		elseif time>=59 and iterator==34 then
			self:AurasOut()
			self.Async, iterator, time = false, 1, 0
		end
	else
		self.Async, iterator, time = false, 1, 0
	end
end

DPSMate.Sync.minor = DPSMate.localization.g
DPSMate.Sync.major = DPSMate.localization.p

----------------------------------------------------------------------------------
--------------                       GENERAL                        --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:GetSummarizedTable(arr)
	local newArr, i, dmg, time, dis = {}, 1, 0, nil, 1
	local TL = DPSMate:TableLength(arr)
	if TL>100 then dis = floor(TL/100) end
	for cat, val in arr do
		if dis>1 then
			dmg=dmg+val[2]
			if time then
				if i>dis and (val[1]-time)>0 then
					tinsert(newArr, {(val[1]+time)/2, dmg/(val[1]-time)}) -- last time val // subtracting from each other to get the time in which the damage is being done
					time, dmg, i = nil, 0, 1
				end
			else
				time=val[1]
			end
		else
			tinsert(newArr, val)
		end
		i=i+1
	end
	return newArr
end

function DPSMate.Sync:Vote()
	DPSMate_Vote:Hide()
	SendAddonMessage("DPSMate_Vote", nil, "RAID")
end

function DPSMate.Sync:StartVote()
	if not voteStarter then
		SendAddonMessage("DPSMate_StartVote", nil, "RAID")
		voteStarter = true
	else
		DPSMate:SendMessage("Vote has already been started!")
	end
end

local voteCount = 1
local participants = 1
function DPSMate.Sync:CountVote()
	if voteStarter then
		voteCount=voteCount+1
		if voteCount >= (participants/2) then
			SendAddonMessage("DPSMate_VoteSuccess", nil, "RAID")
			voteStarter = false
			voteCount = 1
			participants = 1
			self:VoteSuccess()
		end
	end
end

local voteTime = 0
function DPSMate.Sync:DismissVote(elapsed)
	if voteStarter then
		voteTime=voteTime+elapsed
		if voteTime>=30 then
			SendAddonMessage("DPSMate_VoteFail", nil, "RAID")
			voteStarter = false
			voteCount = 1
			voteTime = 0
			participants = 1
			DPSMate:SendMessage("Reset vote failed!")
		elseif voteTime>=3 and participants==1 then
			voteStarter = false
			voteCount = 1
			voteTime = 0
			self:VoteSuccess()
		end
	end
end

function DPSMate.Sync:VoteSuccess()
	DPSMate:SendMessage("Reset vote was successful! DPSMate has been resetted!")
	DPSMate.Options:PopUpAccept(true, true)
end

function DPSMate.Sync:CountParticipants()
	if voteStarter then
		participants=participants+1
	end
end

function DPSMate.Sync:Participate()
	SendAddonMessage("DPSMate_Participate", nil, "RAID")
end

function DPSMate.Sync:ReceiveStartVote() 
	self:Participate()
	if DPSMateSettings["dataresetssync"] == 3 then
		DPSMate_Vote:Show()
	elseif DPSMateSettings["dataresetssync"] == 1 then
		self:Vote()
	end
end

function DPSMate.Sync:Validate(s)
	local v = ""
	for i=1, string.len(s or "") do
		v = v..string.byte(s,i,i)
	end
	return tonumber(v)
end

function DPSMate.Sync:CorrectVersion(a,b)
	if DPSMate:TContains(self.minor, self:Validate(b)) or DPSMate:TContains(self.major, self:Validate(a)) then
		return true
	end
	return false
end

----------------------------------------------------------------------------------
--------------                       SYNC IN                        --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:OnEvent(event)
	if event == "CHAT_MSG_ADDON" then
		if DPSMateSettings["sync"] and DB.loaded and self:CorrectVersion(self.v1(self.v3),self.v2(self.v3)) then
			if arg4 == player then return end 
			if arg1 == "DPSMate" then
				t = {}
				strgsub(arg2, "(.-),", func) -- name, aura, target, time
				t[3] = GetTime()
				if DPSMate:TContains(DPSMate.Parser.Kicks, ability) then DB:AwaitAfflictedStun(arg4, t[1], t[2], t[3]) end
				if DPSMate:TContains(DPSMate.Parser.HotDispels, ability) then DB:AwaitHotDispel(t[1], t[2], arg4, t[3]) end
				DB:AwaitingBuff(arg4, t[1], t[2], t[3])
				DB:AwaitingAbsorbConfirmation(arg4, t[1], t[2], t[3])
			elseif arg1 == "DPSMate_DMGDoneAll" then
				self:DMGDoneAllIn(arg2, arg4)
			elseif arg1 == "DPSMate_DMGDoneStat" then
				self:DMGDoneStatIn(arg2, arg4)
			elseif arg1 == "DPSMate_DMGDoneAbility" then
				self:DMGDoneAbilityIn(arg2, arg4)
			elseif arg1 == "DPSMate_EHealingAll" then
				self:HealingAllIn(arg2, arg4, DPSMateEHealing)
			elseif arg1 == "DPSMate_EHealingStat" then
				self:HealingStatIn(arg2, arg4, DPSMateEHealing)
			elseif arg1 == "DPSMate_EHealingAbility" then
				self:HealingAbilityIn(arg2, arg4, DPSMateEHealing)
			elseif arg1 == "DPSMate_THealingAll" then
				self:HealingAllIn(arg2, arg4, DPSMateTHealing)
			elseif arg1 == "DPSMate_THealingStat" then
				self:HealingStatIn(arg2, arg4, DPSMateTHealing)
			elseif arg1 == "DPSMate_THealingAbility" then
				self:HealingAbilityIn(arg2, arg4, DPSMateTHealing)
			elseif arg1 == "DPSMate_OHealingAll" then
				self:HealingAllIn(arg2, arg4, DPSMateOverhealing)
			elseif arg1 == "DPSMate_OHealingStat" then
				self:HealingStatIn(arg2, arg4, DPSMateOverhealing)
			elseif arg1 == "DPSMate_OHealingAbility" then
				self:HealingAbilityIn(arg2, arg4, DPSMateOverhealing)
			elseif arg1 == "DPSMate_TTakenHealingAll" then
				self:HealingAllIn(arg2, arg4, DPSMateHealingTaken)
			elseif arg1 == "DPSMate_TTakenHealingStat" then
				self:HealingStatIn(arg2, arg4, DPSMateHealingTaken)
			elseif arg1 == "DPSMate_THealingTakenAbility" then
				self:HealingTakenAbilityIn(arg2, arg4, DPSMateHealingTaken)
			elseif arg1 == "DPSMate_ETakenHealingAll" then
				self:HealingAllIn(arg2, arg4, DPSMateEHealingTaken)
			elseif arg1 == "DPSMate_ETakenHealingStat" then
				self:HealingStatIn(arg2, arg4, DPSMateEHealingTaken)
			elseif arg1 == "DPSMate_EHealingTakenAbility" then
				self:HealingTakenAbilityIn(arg2, arg4, DPSMateEHealingTaken)
			elseif arg1 == "DPSMate_Absorbs" then
				self:AbsorbsIn(arg2, arg4) 
			elseif arg1 == "DPSMate_iAbsorbs" then
				self:iAbsorbsIn(arg2, arg4) 
			elseif arg1 == "DPSMate_Dispels" then
				self:DispelsIn(arg2, arg4) 
			elseif arg1 == "DPSMate_iDispels" then
				self:iDispelsIn(arg2, arg4) 
			elseif arg1 == "DPSMate_DMGTakenAll" then
				self:DMGTakenAllIn(arg2, arg4)
			elseif arg1 == "DPSMate_DMGTakenStat" then
				self:DMGTakenStatIn(arg2, arg4)
			elseif arg1 == "DPSMate_DMGTakenAbility" then
				self:DMGTakenAbilityIn(arg2, arg4)
			elseif arg1 == "DPSMate_EDTAll" then
				self:EDAllIn(DPSMateEDT, arg2, arg4)
			elseif arg1 == "DPSMate_EDTAbility" then
				self:EDAbilityIn(DPSMateEDT, arg2, arg4)
			elseif arg1 == "DPSMate_EDTStat" then
				self:EDStatIn(DPSMateEDT, arg2, arg4)
			elseif arg1 == "DPSMate_EDDAll" then
				self:EDAllIn(DPSMateEDD, arg2, arg4)
			elseif arg1 == "DPSMate_EDDAbility" then
				self:EDAbilityIn(DPSMateEDD, arg2, arg4)
			elseif arg1 == "DPSMate_EDDStat" then
				self:EDStatIn(DPSMateEDD, arg2, arg4)
			elseif arg1 == "DPSMate_DeathsAll" then
				self:DeathsAllIn(arg2, arg4) 
			elseif arg1 == "DPSMate_Deaths" then
				self:DeathsIn(arg2, arg4)
			elseif arg1 == "DPSMate_InterruptsAll" then
				self:InterruptsAllIn(arg2, arg4)
			elseif arg1 == "DPSMate_InterruptsAbility" then
				self:InterruptsAbilityIn(arg2, arg4)
			elseif arg1 == "DPSMate_AurasAll" then
				self:AurasAllIn(arg2, arg4)
			elseif arg1 == "DPSMate_AurasStart" then
				self:AurasStartEndIn(arg2, arg4, 1)
			elseif arg1 == "DPSMate_AurasEnd" then
				self:AurasStartEndIn(arg2, arg4, 2)
			elseif arg1 == "DPSMate_AurasCause" then
				self:AurasCauseIn(arg2, arg4)
			elseif arg1 == "DPSMate_Vote" then
				self:CountVote()
			elseif arg1 == "DPSMate_StartVote" then
				self:ReceiveStartVote() 
			elseif arg1 == "DPSMate_VoteSuccess" then
				self:VoteSuccess()
			elseif arg1 == "DPSMate_VoteFail" then
				DPSMate:SendMessage("Reset voting has failed!")
			elseif arg1 == "DPSMate_Participate" then
				self:CountParticipants()
			end
		end
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		LastMouseover = UnitName("mouseover")
	end
end

----------------------------------------------------------------------------------
--------------                    DAMAGE DONE                       --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:DMGDoneAllIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, t[1])
	DPSMateDamageDone[1][DPSMateUser[arg4][1]] = {
		i = {
			[1] = {},
			[2] = 0,
		},
	}
	DPSMateDamageDone[1][DPSMateUser[arg4][1]]["i"][2] = tonumber(t[2])
	DB.NeedUpdate = true
end

DPSMate.Sync.v1 = UnitName

function DPSMate.Sync:DMGDoneStatIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	t[1] = tonumber(t[1])
	if not DPSMateDamageDone[1][DPSMateUser[arg4][1]] then return end
	tinsert(DPSMateDamageDone[1][DPSMateUser[arg4][1]]["i"][1], {t[1], tonumber(t[2])})
	if t[1]>DPSMateCombatTime["total"] then DPSMateCombatTime["total"]=t[1] end
end

function DPSMate.Sync:DMGDoneAbilityIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildAbility(t[1], nil)
	if not DPSMateDamageDone[1][DPSMateUser[arg4][1]] then
		DPSMateDamageDone[1][DPSMateUser[arg4][1]] = {
			i = {
				[1] = {},
				[2] = 0,
			},
		}
	end
	DPSMateDamageDone[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]] = {
		[1] = tonumber(t[2]),
		[2] = tonumber(t[3]),
		[3] = tonumber(t[4]),
		[4] = tonumber(t[5]),
		[5] = tonumber(t[6]),
		[6] = tonumber(t[7]),
		[7] = tonumber(t[8]),
		[8] = tonumber(t[9]),
		[9] = tonumber(t[10]),
		[10] = tonumber(t[11]),
		[11] = tonumber(t[12]),
		[12] = tonumber(t[13]),
		[13] = tonumber(t[14]),
		[14] = tonumber(t[15]),
		[15] = tonumber(t[16]),
		[16] = tonumber(t[17]),
		[17] = tonumber(t[18]),
		[18] = tonumber(t[19]),
		[19] = tonumber(t[20]),
		[20] = tonumber(t[21]),
		[21] = tonumber(t[22]),
	}
end

----------------------------------------------------------------------------------
--------------                    DAMAGE TAKEN                      --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:DMGTakenAllIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, t[1])
	DPSMateDamageTaken[1][DPSMateUser[arg4][1]] = {
		i = {
			[1] = {},
			[2] = tonumber(t[2]),
		},
	}
	DB.NeedUpdate = true
end

function DPSMate.Sync:DMGTakenStatIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	if not DPSMateDamageTaken[1][DPSMateUser[arg4][1]] then return end
	t[1] = tonumber(t[1])
	tinsert(DPSMateDamageTaken[1][DPSMateUser[arg4][1]]["i"][1], {t[1], tonumber(t[2])})
	if t[1]>DPSMateCombatTime["total"] then DPSMateCombatTime["total"]=t[1] end
end

DPSMate.Sync.v2 = GetGuildInfo

function DPSMate.Sync:DMGTakenAbilityIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[1], nil)
	DB:BuildAbility(t[2], nil)
	if not DPSMateDamageTaken[1][DPSMateUser[arg4][1]] then return end
	
	if not DPSMateDamageTaken[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]] then
		DPSMateDamageTaken[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]] = {}
	end
	DPSMateDamageTaken[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]][DPSMateAbility[t[2]][1]] = {
		[1] = tonumber(t[3]),
		[2] = tonumber(t[4]),
		[3] = tonumber(t[5]),
		[4] = tonumber(t[6]),
		[5] = tonumber(t[7]),
		[6] = tonumber(t[8]),
		[7] = tonumber(t[9]),
		[8] = tonumber(t[10]),
		[9] = tonumber(t[11]),
		[10] = tonumber(t[12]),
		[11] = tonumber(t[13]),
		[12] = tonumber(t[14]),
		[13] = tonumber(t[15]),
		[14] = tonumber(t[16]),
		[15] = tonumber(t[17]),
		[16] = tonumber(t[18]),
		[17] = tonumber(t[19]),
		[18] = tonumber(t[20]),
	}
end

----------------------------------------------------------------------------------
--------------                 ENEMY DAMAGE TAKEN                   --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:EDAllIn(arr, arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, t[1])
	DB:BuildUser(t[2], nil)
	if not arr[1][DPSMateUser[t[2]][1]] then
		arr[1][DPSMateUser[t[2]][1]] = {}
	end
	arr[1][DPSMateUser[t[2]][1]][DPSMateUser[arg4][1]] = {
		i = {
			[1] = {},
			[2] = tonumber(t[3]),
		},
	}
	DB.NeedUpdate = true
end

function DPSMate.Sync:EDStatIn(arr, arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[1], nil)
	if not arr[1][DPSMateUser[t[1]][1]] then return end
	t[2] = tonumber(t[2])
	if not t[1] then DPSMate:SendMessage(arg4) end
	if not arg4 then DPSMate:SendMessage(t[1]) end
	tinsert(arr[1][DPSMateUser[t[1]][1]][DPSMateUser[arg4][1]]["i"][1], {t[2], tonumber(t[3])})
	if t[2]>DPSMateCombatTime["total"] then DPSMateCombatTime["total"]=t[2] end
end

function DPSMate.Sync:EDAbilityIn(arr, arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[1], nil)
	DB:BuildAbility(t[2], nil)
	if not arr[1][DPSMateUser[t[1]][1]] then
		arr[1][DPSMateUser[t[1]][1]] = {}
	end
	if not arr[1][DPSMateUser[t[1]][1]][DPSMateUser[arg4][1]] then return end
	arr[1][DPSMateUser[t[1]][1]][DPSMateUser[arg4][1]][DPSMateAbility[t[2]][1]] = {
		[1] = tonumber(t[3]),
		[2] = tonumber(t[4]),
		[3] = tonumber(t[5]),
		[4] = tonumber(t[6]),
		[5] = tonumber(t[7]),
		[6] = tonumber(t[8]),
		[7] = tonumber(t[9]),
		[8] = tonumber(t[10]),
		[9] = tonumber(t[11]),
		[10] = tonumber(t[12]),
		[11] = tonumber(t[13]),
		[12] = tonumber(t[14]),
		[13] = tonumber(t[15]),
		[14] = tonumber(t[16]),
		[15] = tonumber(t[17]),
		[16] = tonumber(t[18]),
		[17] = tonumber(t[19]),
		[18] = tonumber(t[20]),
		[19] = tonumber(t[21]),
		[20] = tonumber(t[22]),
		[21] = tonumber(t[23]),
	}
end

DPSMate.Sync.v3 = "player"

----------------------------------------------------------------------------------
--------------                        Healing                       --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:HealingAllIn(arg2, arg4, arr)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, t[1])
	arr[1][DPSMateUser[arg4][1]] = {
		i = {
			[1] = tonumber(t[2]),
			[2] = {},
		},
	}
	DB.NeedUpdate = true
end

function DPSMate.Sync:HealingStatIn(arg2, arg4, arr)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	t[1] = tonumber(t[1])
	if not arr[1][DPSMateUser[arg4][1]] then return end
	tinsert(arr[1][DPSMateUser[arg4][1]]["i"][2], {t[1], tonumber(t[2])})
	if t[1]>DPSMateCombatTime["total"] then DPSMateCombatTime["total"]=t[1] end
end

function DPSMate.Sync:HealingAbilityIn(arg2, arg4, arr)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildAbility(t[1], nil)
	if not arr[1][DPSMateUser[arg4][1]] then return end
	arr[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]] = {
		[1] = tonumber(t[2]),
		[2] = tonumber(t[3]),
		[3] = tonumber(t[4]),
		[4] = tonumber(t[5]),
		[5] = tonumber(t[6]),
		[6] = tonumber(t[7]),
		[7] = tonumber(t[8]),
		[8] = tonumber(t[9]),
		[9] = tonumber(t[10]),
	}
end

----------------------------------------------------------------------------------
--------------                    Healing taken                     --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:HealingTakenAbilityIn(arg2, arg4, arr)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[1], nil)
	DB:BuildAbility(t[2], nil)
	if not arr[1][DPSMateUser[arg4][1]] then return end
	if not arr[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]] then
		arr[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]] = {}
	end
	arr[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]][DPSMateAbility[t[2]][1]] = {
		[1] = tonumber(t[3]),
		[2] = tonumber(t[4]),
		[3] = tonumber(t[5]),
		[4] = tonumber(t[6]),
		[5] = tonumber(t[7]),
		[6] = tonumber(t[8]),
		[7] = tonumber(t[9]),
		[8] = tonumber(t[10]),
		[9] = tonumber(t[11]),
	}
end

----------------------------------------------------------------------------------
--------------                        Absorbs                       --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:iAbsorbsIn(arg2, arg4) 
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[1], nil)
	DB:BuildAbility(t[2], nil)
	if not DPSMateAbsorbs[1][DPSMateUser[arg4][1]] then
		DPSMateAbsorbs[1][DPSMateUser[arg4][1]] = {}
	end
	if not DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]] then
		DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]] = {
			i = {},
		}
	end
	if not DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]][DPSMateAbility[t[2]][1]] then
		DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]][DPSMateAbility[t[2]][1]] = {}
	end
	DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]][DPSMateAbility[t[2]][1]][tonumber(t[3])] = {
		i = {
			[1] = tonumber(t[4]),
			[2] = tonumber(t[5]),
			[3] = tonumber(t[6]),
			[4] = tonumber(t[7]),
		},
	}
end

function DPSMate.Sync:AbsorbsStatIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[1], nil)
	if not DPSMateAbsorbs[1][DPSMateUser[arg4][1]] then return end
	if not DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]] then return end
	t[2] = tonumber(t[2])
	if t[4] then
		tinsert(DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]]["i"], {t[2], tonumber(t[3]), tonumber(t[4]), tonumber(t[5])})
	else
		tinsert(DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]]["i"], {t[2], tonumber(t[3]), tonumber(t[4])})
	end
	if t[1]>DPSMateCombatTime["total"] then DPSMateCombatTime["total"]=t[1] end
end

function DPSMate.Sync:AbsorbsIn(arg2, arg4) 
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[1], nil)
	DB:BuildUser(t[4], nil)
	DB:BuildAbility(t[2], nil)
	if not DPSMateAbsorbs[1][DPSMateUser[arg4][1]] then return end
	if not DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]] then return end
	DPSMateAbsorbs[1][DPSMateUser[arg4][1]][DPSMateUser[t[1]][1]][DPSMateAbility[t[2]][1]][tonumber(t[3])][DPSMateUser[t[4]][1]] = {
		[1] = tonumber(t[5]),
		[2] = tonumber(t[6]),
	}
	DB.NeedUpdate = true
end

----------------------------------------------------------------------------------
--------------                        Deaths                        --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:DeathsAllIn(arg2, arg4) 
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, t[1])
	t[2] = tonumber(t[2])
	if not DPSMateDeaths[1][DPSMateUser[arg4][1]] then
		DPSMateDeaths[1][DPSMateUser[arg4][1]] = {}
	end
	DPSMateDeaths[1][DPSMateUser[arg4][1]][t[2]] = {
		i = {
			[1] = tonumber(t[3]),
			[2] = t[4],
		},
	}
	DB.NeedUpdate = true
end

function DPSMate.Sync:DeathsIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[3], nil)
	DB:BuildAbility(t[4], nil)
	t[1] = tonumber(t[1])
	t[2] = tonumber(t[2])
	if not DPSMateDeaths[1][DPSMateUser[arg4][1]] then return end
	if not DPSMateDeaths[1][DPSMateUser[arg4][1]][t[1]] then return end
	DPSMateDeaths[1][DPSMateUser[arg4][1]][t[1]][t[2]] = {
		[1] = DPSMateUser[t[3]][1],
		[2] = DPSMateAbility[t[4]][1],
		[3] = tonumber(t[5]),
		[4] = tonumber(t[6]),
		[5] = tonumber(t[7]),
		[6] = tonumber(t[8]),
		[7] = t[9],
	}
end

----------------------------------------------------------------------------------
--------------                     Interrupts                       --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:InterruptsAllIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, t[1])
	DPSMateInterrupts[1][DPSMateUser[arg4][1]] = {
		i = tonumber(t[2]),
	}
	DB.NeedUpdate = true
end

function DPSMate.Sync:InterruptsAbilityIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[2], nil)
	DB:BuildAbility(t[1], nil)
	DB:BuildAbility(t[3], nil)
	if not DPSMateInterrupts[1][DPSMateUser[arg4][1]] then return end
	if not DPSMateInterrupts[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]] then
		DPSMateInterrupts[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]] = {}
	end
	if not DPSMateInterrupts[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][DPSMateUser[t[2]][1]] then
		DPSMateInterrupts[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][DPSMateUser[t[2]][1]] = {}
	end
	DPSMateInterrupts[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][DPSMateUser[t[2]][1]][DPSMateAbility[t[3]][1]] = tonumber(t[4])
end

----------------------------------------------------------------------------------
--------------                        Dispels                       --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:iDispelsIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DPSMateDispels[1][DPSMateUser[arg4][1]] = {
		i = tonumber(arg2),
	}
	DB.NeedUpdate = true
end

function DPSMate.Sync:DispelsIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[2], nil)
	DB:BuildAbility(t[1], nil)
	DB:BuildAbility(t[3], nil)
	if not DPSMateDispels[1][DPSMateUser[arg4][1]] then return end
	if not DPSMateDispels[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]] then
		DPSMateDispels[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]] = {}
	end
	if not DPSMateDispels[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][DPSMateUser[t[2]][1]] then
		DPSMateDispels[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][DPSMateUser[t[2]][1]] = {}
	end
	DPSMateDispels[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][DPSMateUser[t[2]][1]][DPSMateAbility[t[3]][1]] = tonumber(v1)
end

----------------------------------------------------------------------------------
--------------                        Auras                         --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:AurasAllIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildAbility(t[1], nil)
	if not DPSMateAurasGained[1][DPSMateUser[arg4][1]] then
		DPSMateAurasGained[1][DPSMateUser[arg4][1]] = {}
	end
	DPSMateAurasGained[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]] = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = false,
	}
	if t[2]=="1" then
		DPSMateAurasGained[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][4] = true
	end
end

function DPSMate.Sync:AurasStartEndIn(arg2, arg4, prefix)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildAbility(t[1], nil)
	DPSMateAurasGained[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][prefix][tonumber(t[2])] = tonumber(t[3])
end

function DPSMate.Sync:AurasCauseIn(arg2, arg4)
	t = {}
	strgsub(arg2, "(.-),", func)
	DB:BuildUser(arg4, nil)
	DB:BuildUser(t[2], nil)
	DB:BuildAbility(t[1], nil)
	DPSMateAurasGained[1][DPSMateUser[arg4][1]][DPSMateAbility[t[1]][1]][3][DPSMateUser[t[2]][1]] = tonumber(t[3])
end

----------------------------------------------------------------------------------
--------------                       SYNC OUT                       --------------                                  
----------------------------------------------------------------------------------

-- Hooking useaction function in order to get the owner of the spell.
local oldUseAction = UseAction
DPSMate.Parser.UseAction = function(slot, checkCursor, onSelf)
	oldUseAction(slot, checkCursor, onSelf)
	DPSMate_Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	DPSMate_Tooltip:ClearLines()
	DPSMate_Tooltip:SetAction(slot)
	local aura = DPSMate_TooltipTextLeft1:GetText()
	DPSMate_Tooltip:Hide()
	if aura then
		local target, time = UnitName("target"), GetTime()
		if not target then target = LastMouseover end
		if target and DPSMateSettings["sync"] then SendAddonMessage("DPSMate", aura..","..target..",", "RAID") end
		if DPSMate:TContains(DPSMate.Parser.Kicks, ability) then DB:AwaitAfflictedStun(player, aura, target, time) end
		DB:AwaitingBuff(player, aura, target, time)
		DB:AwaitingAbsorbConfirmation(player, aura, target, time)
	end
end
UseAction = DPSMate.Parser.UseAction

-- Hooking CastSpellByName function in order to get the owner of the spell.
local oldCastSpellByName = CastSpellByName
DPSMate.Parser.CastSpellByName = function(spellName, onSelf)
	oldCastSpellByName(spellName, onSelf)
	local target, time = UnitName("target"), GetTime()
	if not target then target = LastMouseover end
	if target and DPSMateSettings["sync"] then SendAddonMessage("DPSMate", spellName..","..target..",", "RAID") end
	if DPSMate:TContains(DPSMate.Parser.Kicks, ability) then DB:AwaitAfflictedStun(player, spellName, target, time) end
	DB:AwaitingBuff(player, spellName, target, time)
	DB:AwaitingAbsorbConfirmation(player, spellName, target, time)
end
CastSpellByName = DPSMate.Parser.CastSpellByName

-- Hooking CastSpell function in order to get the owner of the spell.
local oldCastSpell = CastSpell
DPSMate.Parser.CastSpell = function(spellID, spellbookType)
	oldCastSpell(spellID, spellbookType)
	local spellName, spellRank = GetSpellName(spellID, spellbookType)
	local target, time = UnitName("target"), GetTime()
	if not target then target = LastMouseover end
	if target and DPSMateSettings["sync"] then SendAddonMessage("DPSMate", spellName..","..target..",", "RAID") end
	if DPSMate:TContains(DPSMate.Parser.Kicks, ability) then DB:AwaitAfflictedStun(player, spellName, target, time) end
	DB:AwaitingBuff(player, spellName, target, time)
	DB:AwaitingAbsorbConfirmation(player, spellName, target, time)
end
CastSpell = DPSMate.Parser.CastSpell

----------------------------------------------------------------------------------
--------------                     DAMAGE DONE                      --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:DMGDoneAllOut()
	if DPSMateDamageDone[1][pid] then
		SendAddonMessage("DPSMate_DMGDoneAll", playerclass..","..DPSMateDamageDone[1][pid]["i"][2]..",", "RAID")
	end
end

function DPSMate.Sync:DMGDoneStatOut()
	if not DPSMateDamageDone[1][pid] then return end
	for cat, val in self:GetSummarizedTable(DPSMateDamageDone[1][pid]["i"][1]) do
		SendAddonMessage("DPSMate_DMGDoneStat", val[1]..","..val[2]..",", "RAID")
	end
end

function DPSMate.Sync:DMGDoneAbilityOut()
	if not DPSMateDamageDone[1][pid] then return end
	for cat, val in (DPSMateDamageDone[1][pid]) do
		if cat~="i" then
			SendAddonMessage("DPSMate_DMGDoneAbility", DPSMate:GetAbilityById(cat)..","..val[1]..","..val[2]..","..val[3]..","..ceil(val[4])..","..val[5]..","..val[6]..","..val[7]..","..ceil(val[8])..","..val[9]..","..val[10]..","..val[11]..","..val[12]..","..val[13]..","..val[14]..","..val[15]..","..val[16]..","..ceil(val[17])..","..val[18]..","..val[19]..","..val[20]..","..ceil(val[21])..",", "RAID")
		end
	end
end

----------------------------------------------------------------------------------
--------------                    DAMAGE TAKEN                      --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:DMGTakenAllOut()
	if DPSMateDamageTaken[1][pid] then
		SendAddonMessage("DPSMate_DMGTakenAll", playerclass..","..DPSMateDamageTaken[1][pid]["i"][2]..",", "RAID")
	end
end

function DPSMate.Sync:DMGTakenStatOut()
	if not DPSMateDamageTaken[1][pid] then return end
	for cat, val in self:GetSummarizedTable(DPSMateDamageTaken[1][pid]["i"][1]) do
		SendAddonMessage("DPSMate_DMGTakenStat", val[1]..","..val[2]..",", "RAID")
	end
end

function DPSMate.Sync:DMGTakenAbilityOut()
	if not DPSMateDamageTaken[1][pid] then return end
	for cat, val in (DPSMateDamageTaken[1][pid]) do
		if cat~="i" then
			for ca, va in pairs(val) do
				SendAddonMessage("DPSMate_DMGTakenAbility", DPSMate:GetUserById(cat)..","..DPSMate:GetAbilityById(ca)..","..va[1]..","..va[2]..","..va[3]..","..ceil(va[4])..","..va[5]..","..va[6]..","..va[7]..","..ceil(va[8])..","..va[9]..","..va[10]..","..va[11]..","..va[12]..","..va[13]..","..ceil(va[14])..","..va[15]..","..va[16]..","..va[17]..","..ceil(va[18])..",", "RAID")
			end
		end
	end
end

----------------------------------------------------------------------------------
--------------                 ENEMY DAMAGE TAKEN                   --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:EDAllOut(arr, prefix)
	for cat, val in pairs(arr[1]) do
		if val[pid] then
			SendAddonMessage("DPSMate_ED"..prefix.."All", playerclass..","..DPSMate:GetUserById(cat)..","..val[pid]["i"][2]..",", "RAID")
		end
	end
end

function DPSMate.Sync:EDStatOut(arr, prefix)
	for cat, val in arr[1] do
		if val[pid] then
			for ca, va in self:GetSummarizedTable(val[pid]["i"][1]) do
				SendAddonMessage("DPSMate_ED"..prefix.."Stat", DPSMate:GetUserById(cat)..","..va[1]..","..va[2]..",", "RAID")
			end
		end
	end
end

function DPSMate.Sync:EDAbilityOut(arr, prefix)
	for cat, val in (arr[1]) do
		if val[pid] then
			for ca, va in pairs(val[pid]) do
				if ca~="i" then
					SendAddonMessage("DPSMate_ED"..prefix.."Ability", DPSMate:GetUserById(cat)..","..DPSMate:GetAbilityById(ca)..","..va[1]..","..va[2]..","..va[3]..","..ceil(va[4])..","..va[5]..","..va[6]..","..va[7]..","..ceil(va[8])..","..va[9]..","..va[10]..","..va[11]..","..va[12]..","..va[13]..","..va[14]..","..va[15]..","..va[16]..","..ceil(va[17])..","..va[18]..","..va[19]..","..va[20]..","..ceil(va[21])..",", "RAID")
				end
			end
		end
	end
end

----------------------------------------------------------------------------------
--------------                       Healing                        --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:HealingAllOut(arr, prefix)
	if arr[1][pid] then
		SendAddonMessage("DPSMate_"..prefix.."HealingAll", playerclass..","..arr[1][pid]["i"][1]..",", "RAID")
	end
end

function DPSMate.Sync:HealingStatOut(arr, prefix)
	if not arr[1][pid] then return end
	for cat, val in self:GetSummarizedTable(arr[1][pid]["i"][2]) do
		SendAddonMessage("DPSMate_"..prefix.."HealingStat", val[1]..","..val[2]..",", "RAID")
	end
end

function DPSMate.Sync:HealingAbilityOut(arr, prefix)
	if not arr[1][pid] then return end
	for cat, val in (arr[1][pid]) do
		if cat~="i" then
			SendAddonMessage("DPSMate_"..prefix.."HealingAbility", DPSMate:GetAbilityById(cat)..","..val[1]..","..val[2]..","..val[3]..","..ceil(val[4])..","..ceil(val[5])..","..val[6]..","..val[7]..","..val[8]..","..val[9]..",", "RAID")
		end
	end
end

----------------------------------------------------------------------------------
--------------                    Healing taken                     --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:HealingTakenAbilityOut(arr, prefix)
	if not arr[1][pid] then return end
	for cat, val in arr[1][pid] do
		if cat~="i" then
			for ca, va in val do
				SendAddonMessage("DPSMate_"..prefix.."HealingTakenAbility", DPSMate:GetUserById(cat)..","..DPSMate:GetAbilityById(ca)..","..va[1]..","..va[2]..","..va[3]..","..ceil(va[4])..","..ceil(va[5])..","..va[6]..","..va[7]..","..va[8]..","..va[9]..",", "RAID")
			end
		end
	end
end

----------------------------------------------------------------------------------
--------------                        Absorbs                       --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:AbsorbsOut() 
	if not DPSMateAbsorbs[1][pid] then return end
	for cat, val in pairs(DPSMateAbsorbs[1][pid]) do -- owner
		for ca, va in pairs(val) do -- ability
			if ca~="i" then
				for c, v in pairs(va) do -- each one
					for ce, ve in pairs(v) do -- enemy
						if ce=="i" then
							SendAddonMessage("DPSMate_iAbsorbs", DPSMate:GetUserById(cat)..","..DPSMate:GetAbilityById(ca)..","..c..","..ve[1]..","..ve[2]..","..ve[3]..","..ve[4]..",", "RAID")
						else
							SendAddonMessage("DPSMate_Absorbs", DPSMate:GetUserById(cat)..","..DPSMate:GetAbilityById(ca)..","..c..","..DPSMate:GetUserById(ce)..","..ve[1]..","..ve[2]..",", "RAID")
						end
					end
				end
			end
		end
	end
end

function DPSMate.Sync:AbsorbsStatOut()
	if not DPSMateAbsorbs[1][pid] then return end
	for cat, val in DPSMateAbsorbs[1][pid] do -- owner
		for ca, va in val["i"] do
			if va[4] then
				SendAddonMessage("DPSMate_AbsorbsStat", DPSMate:GetUserById(cat)..","..va[1]..","..va[2]..","..va[3]..","..va[4]..",", "RAID")
			else
				SendAddonMessage("DPSMate_AbsorbsStat", DPSMate:GetUserById(cat)..","..va[1]..","..va[2]..","..va[3]..",", "RAID")
			end
		end
	end
end

----------------------------------------------------------------------------------
--------------                        Deaths                        --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:DeathsAllOut()
	if not DPSMateDeaths[1][pid] then return end
	for cat, val in pairs(DPSMateDeaths[1][pid]) do -- death count
		SendAddonMessage("DPSMate_DeathsAll", playerclass..","..cat..","..val["i"][1]..","..val["i"][2]..",", "RAID")
	end
end

function DPSMate.Sync:DeathsOut()
	if not DPSMateDeaths[1][pid] then return end
	for cat, val in pairs(DPSMateDeaths[1][pid]) do -- death count
		for ca, va in pairs(val) do -- each part
			if ca~="i" then -- Testing if this prevents the error
				SendAddonMessage("DPSMate_Deaths", cat..","..ca..","..DPSMate:GetUserById(va[1])..","..DPSMate:GetAbilityById(va[2])..","..va[3]..","..va[4]..","..va[5]..","..va[6]..","..va[7]..",", "RAID")
			end
		end
	end
end

----------------------------------------------------------------------------------
--------------                     Interrupts                       --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:InterruptsAllOut()
	if DPSMateInterrupts[1][pid] then
		SendAddonMessage("DPSMate_InterruptsAll", playerclass..","..DPSMateInterrupts[1][pid]["i"]..",", "RAID")
	end
end

function DPSMate.Sync:InterruptsAbilityOut()
	if not DPSMateInterrupts[1][pid] then return end
	for cat, val in pairs(DPSMateInterrupts[1][pid]) do
		if cat~="i" then
			for ca, va in pairs(val) do
				for c, v in pairs(va) do
					SendAddonMessage("DPSMate_InterruptsAbility", DPSMate:GetAbilityById(cat)..","..DPSMate:GetUserById(ca)..","..DPSMate:GetAbilityById(c)..","..v..",", "RAID")
				end
			end
		end
	end
end

----------------------------------------------------------------------------------
--------------                        Dispels                       --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:DispelsOut()
	if not DPSMateDispels[1][pid] then return end
	for cat, val in pairs(DPSMateDispels[1][pid]) do -- Ability
		if cat=="i" then
			SendAddonMessage("DPSMate_iDispels", DPSMate:GetAbilityById(cat)..","..val..",", "RAID")
		else
			for ca, va in pairs(val) do -- Target
				for c, v in pairs(v) do -- Ability
					SendAddonMessage("DPSMate_Dispels", DPSMate:GetAbilityById(cat)..","..DPSMate:GetUserById(ca)..","..DPSMate:GetAbilityById(c)..","..v..",", "RAID")
				end
			end
		end
	end
end

----------------------------------------------------------------------------------
--------------                        Auras                         --------------                                  
----------------------------------------------------------------------------------

function DPSMate.Sync:AurasOut()
	if not DPSMateAurasGained[1][pid] then return end
	local p = 0
	for cat, val in pairs(DPSMateAurasGained[1][pid]) do -- ability
		if val[4] then p = 1 end
		local ability = DPSMate:GetAbilityById(cat)
		SendAddonMessage("DPSMate_AurasAll", ability..","..p..",", "RAID")
		for ca, va in pairs(val[1]) do
			SendAddonMessage("DPSMate_AurasStart", ability..","..ca..","..va..",", "RAID")
		end
		for ca, va in pairs(val[2]) do
			SendAddonMessage("DPSMate_AurasEnd", ability..","..ca..","..va..",", "RAID")
		end
		for ca, va in pairs(val[3]) do
			SendAddonMessage("DPSMate_AurasCause", ability..","..DPSMate:GetUserById(ca)..","..va..",", "RAID")
		end
	end
end