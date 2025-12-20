-- XianZhouFuctions
-- Author: Pen
-- DateCreated: 2024/11/12 19:25:45
--------------------------------------------------------------
DIVINATION_TO_PRODUCTION 	= math.floor(GlobalParameters.XIANZHOU_DIVINATION_TO_PRODUCTION)
DIVINATION_FIX_PRODUCTION = math.floor(GlobalParameters.XIANZHOU_DIVINATION_FIX_PRODUCTION)

DivinationYieldType = {
    YIELD_PRODUCTION = GameInfo.Yields["YIELD_PRODUCTION"].Index
}
--------------------------------------------------------------
function FormatValuePerTurn( value:number )
	if(value == 0) then
		return Locale.ToNumber(value);
	else
		return Locale.Lookup("{1: number +#,###.#;-#,###.#}", value);
	end
end

function DivinationCityGetImproCost(playerID, cityID)
	local pCity = CityManager.GetCity(playerID, cityID)
	if	pCity then
		local ImproveCost = math.min(math.max((pCity:GetProperty('DEBUFF_MATRIX_OF_PRESCIENCE') or 0)-5,0),30)
		return ImproveCost
	end
end

function UpdateCityYieldToDivinationPoint(playerID, cityID, tooltip, yieldType)
    local CityBaseYield = 0;--计算基础产出
	local CityDivinationPoint = 0;--计算卜算点
    local modifierPattern = "(%+*%-*%d*%.?%d+)";--数字小数格式匹配(*匹配0或多次，？匹配0或1次，+匹配1或多次)
    local modifierPattern2 = "(%+*%-*%d*)%%";--百分比格式匹配
	local modifierPattern3 = "(%+*%-*%d*)%%%s*%p?(%+*%-*%d*%.?%d+)%p?";--半角百分比格式匹配
	local modifierPattern4 = "(%+*%-*%d*)%%（(%+*%-*%d*%.?%d+)）";--全角百分比格式匹配
    local pCity = CityManager.GetCity(playerID, cityID);
    local newTooltip = string.gsub(tooltip, "%[NEWLINE%]", ";");
	for line in string.gmatch(newTooltip, "([^;]+)") do--将各加成分段
		local IconBullet = "%[ICON_Bullet]"
		local fromModifierAmountStr = line:match(modifierPattern);
		local _, _, d0  = line:find(modifierPattern2);--匹配百分数(由于基尔瓦基斯瓦尼等效果只有百分比，因此需要单列)
        local _, _, d1,  d2  = line:find(modifierPattern3);--d1为百分比,d2为数值加成
		local _, _, d11, d22 = line:find(modifierPattern4);--d11为百分比,d22为数值加成
		if	string.match(line,IconBullet) == nil then --去除产出文本中的细分项避免重复计算
			--print(yieldType,line,fromModifierAmountStr,d0, d1, d2, d11, d22)
			if	d0 and d0 ~= 0 then--如果为百分比
				local pCityGrowth = pCity:GetGrowth();
				local iAmenity = pCityGrowth:GetAmenities() - pCityGrowth:GetAmenitiesNeeded();
				local iHappiness = pCityGrowth:GetHappiness();
				
				local amount1 = tonumber(d1) or tonumber(d11) or tonumber(d0) or 0;
				local amount2 = tonumber(d2) or tonumber(d22) or 0;
				local pCulturalIdentity = pCity:GetCulturalIdentity();
				local loyaltyLevel = pCulturalIdentity:GetLoyaltyLevel();
				if	amount1 ~= 0 then--如果为百分数
					if	amount2 ~= 0 then--如果有显示值
						if	amount1 == tonumber(GameInfo.Happinesses[iHappiness].NonFoodYieldModifier) then--宜居加成(理论上可以匹配loc，但之前原版bug...后面再研究吧)
							--print('CityModifierDivinationPoint(Happinesses)',amount1,amount2)
							CityDivinationPoint = CityDivinationPoint + amount2
					elseif	amount1 > 0 then--其他独立加成（如花郎或苏格兰）
							local TrueCityModifier = amount1
							--print('CityModifierDivinationPoint',amount1,amount2)
							CityDivinationPoint = CityDivinationPoint + amount2
					elseif	amount1 < 0 then--修正值负值加成（-1000不可能给扭到正值吧,应该不可能吧）
							if	amount1 == (GameInfo.LoyaltyLevels[loyaltyLevel].YieldChange)*100 then--如果来源于忠诚度
								--print('CityModifierDivinationPoint(Loyalty)',amount1,amount2)
								CityDivinationPoint = CityDivinationPoint + amount2
							else
								TrueCityModifier = amount1 + DIVINATION_FIX_PRODUCTION--移除减去的1000%产出数值
								--print('CityModifierDivinationPoint',amount1,math.floor(((TrueCityModifier * CityBaseYield)*10+0.5)/10)/100)
								CityDivinationPoint = CityDivinationPoint + math.floor(((TrueCityModifier * CityBaseYield)*10+0.5)/10)/100
							end
						end
					else
						local TrueCityModifier = amount1
						--print('CityModifierDivinationPoint',amount1,TrueCityModifier,CityBaseYield,math.floor(((TrueCityModifier * CityBaseYield)*100+0.5)/10)/100)
						CityDivinationPoint = CityDivinationPoint + math.floor(((TrueCityModifier * CityBaseYield)*10+0.5)/10)/100
					end
				end	
		elseif	fromModifierAmountStr and d0 == nil and ((d1 == nil and d2 == nil) or (d11 == nil and d22 == nil)) then--如果为固定数值(百分比下同样会被识别一次%前的数值，需要额外判断nil)
				-- It's the "from modifier" line, edit it and add new lines.
				fromModifierAmount = tonumber(fromModifierAmountStr);
				if	fromModifierAmount ~= 0 then
					local fromModifierLine = Locale.Lookup("LOC_CITY_YIELD_FROM_GAMEEFFECTS_TOOLTIP", fromModifierAmount);
					--print('CityDivinationPoint',fromModifierAmount)
					CityBaseYield = CityBaseYield + fromModifierAmount--由于固定数值显示在产出面板最上方,会优先累加,因此CityBaseYield可用于乘算加成
					CityDivinationPoint = CityDivinationPoint + fromModifierAmount
				end
			end
		end
	end
	return CityDivinationPoint;
end

function DivinationCityBuildQueue(PlayerID,CityID)
	local pCity = CityManager.GetCity(PlayerID, CityID)
	if	pCity then
		local pCityBuildQueue = pCity:GetBuildQueue()
		if	pCityBuildQueue then
			local hash	:number = pCityBuildQueue:GetCurrentProductionTypeHash()--获得生产队列的Hash值
			local index						:number = 0;
			local progress					:number = 0;
			local cost						:number = 0;
			local percentComplete			:number = 0;
			local type						:string = "";
			
			-- Nothing being produced.
			if hash == 0 then
				return {
					Name					= Locale.Lookup("LOC_HUD_CITY_NOTHING_PRODUCED"),
					index					= 0,
					Hash					= 0, 
					PercentComplete			= 0, 
					Progress				= 0,
					Cost					= 0,
					type					= "Nothing";
				};
			end
			
			local buildingDef	:table = GameInfo.Buildings[hash];
			local districtDef	:table = GameInfo.Districts[hash];
			local unitDef		:table = GameInfo.Units[hash];
			local projectDef	:table = GameInfo.Projects[hash];
			--print(hash,buildingDef,districtDef,unitDef,projectDef)
			if( buildingDef ~= nil ) then
				productionName	= Locale.Lookup(buildingDef.Name);
				index			= buildingDef.Index
				progress		= pCityBuildQueue:GetBuildingProgress(buildingDef.Index);
				percentComplete	= progress / pCityBuildQueue:GetBuildingCost(buildingDef.Index);
				cost			= pCityBuildQueue:GetBuildingCost(buildingDef.Index);
				type			= "Building"
				--print("DivinationComplete:",Locale.Lookup(GameInfo.Buildings[hash].Name),'Playerid and Cityid:',PlayerID,CityID,'Cost and hasProgress:',cost,progress)
			elseif( districtDef ~= nil ) then
				productionName	= Locale.Lookup(districtDef.Name);
				index			= districtDef.Index
				progress		= pCityBuildQueue:GetDistrictProgress(districtDef.Index);
				percentComplete	= progress / pCityBuildQueue:GetDistrictCost(districtDef.Index);
				cost			= pCityBuildQueue:GetDistrictCost(districtDef.Index);
				type			= "District"
				--print("DivinationComplete:",Locale.Lookup(GameInfo.Districts[hash].Name),'Playerid and Cityid:',PlayerID,CityID,'Cost and hasProgress:',cost,progress)
			elseif( unitDef ~= nil ) then
				local eMilitaryFormationType :number = pCityBuildQueue:GetCurrentProductionTypeModifier();
				--local prodTurnsLeft	= pCityBuildQueue:GetTurnsLeft(unitDef.UnitType, eMilitaryFormationType);		
				productionName	= Locale.Lookup(unitDef.Name);
				index			= unitDef.Index
				progress		= pCityBuildQueue:GetUnitProgress(unitDef.Index);
				--Units need some additional information to represent the Standard, Corps, and Army versions. This is determined by the MilitaryFormationType
				if	(eMilitaryFormationType == MilitaryFormationTypes.STANDARD_FORMATION) then
					percentComplete = progress / pCityBuildQueue:GetUnitCost(unitDef.Index);	
					cost			= pCityBuildQueue:GetUnitCost(unitDef.Index);
				elseif	(eMilitaryFormationType == MilitaryFormationTypes.CORPS_FORMATION) then
					percentComplete = progress / pCityBuildQueue:GetUnitCorpsCost(unitDef.Index);
					cost			= pCityBuildQueue:GetUnitCorpsCost(unitDef.Index);
					if (unitDef.Domain == "DOMAIN_SEA") then
						productionName = productionName .. " " .. Locale.Lookup("LOC_UNITFLAG_FLEET_SUFFIX");
					else
						productionName = productionName .. " " .. Locale.Lookup("LOC_UNITFLAG_CORPS_SUFFIX");
					end
				elseif	(eMilitaryFormationType == MilitaryFormationTypes.ARMY_FORMATION) then
					percentComplete = progress / pCityBuildQueue:GetUnitArmyCost(unitDef.Index);
					cost			= pCityBuildQueue:GetUnitArmyCost(unitDef.Index);
					if (unitDef.Domain == "DOMAIN_SEA") then
						productionName = productionName .. " " .. Locale.Lookup("LOC_UNITFLAG_FLEET_SUFFIX");
					else
						productionName = productionName .. " " .. Locale.Lookup("LOC_UNITFLAG_CORPS_SUFFIX");
					end
				end
				type			= "Unit"
				--print("DivinationComplete:",Locale.Lookup(GameInfo.Units[hash].Name),'Playerid and Cityid:',PlayerID,CityID,'Cost and hasProgress:',cost,progress)
			elseif	(projectDef ~= nil) then
				productionName	= Locale.Lookup(projectDef.Name);
				index			= projectDef.Index
				progress		= pCityBuildQueue:GetProjectProgress(projectDef.Index);
				cost			= pCityBuildQueue:GetProjectCost(projectDef.Index);
				percentComplete	= progress / pCityBuildQueue:GetProjectCost(projectDef.Index);
				type			= "Project"
				--print("DivinationComplete:",Locale.Lookup(GameInfo.Projects[hash].Name),'Playerid and Cityid:',PlayerID,CityID,'Cost and hasProgress:',cost,progress)
			end
			local pProductionComplete = (cost - progress)
			--print(cost,progress)
			if	cost >= 0 and pProductionComplete >= 0 then
				return {
					Name					= productionName,
					Index					= index,
					Hash					= hash,
					PercentComplete			= percentComplete,
					Progress				= progress,
					Cost					= cost,
					Type					= type;
				};
			end
		end
	end
end