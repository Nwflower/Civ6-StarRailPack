-- LuoFu_XianZhou_Gameplay
-- Author: Pen
-- DateCreated: 2024/2/12 14:58:04
--------------------------------------------------------------
local e = 2.71828
local DIVINATION_TO_PRODUCTION = math.floor(GlobalParameters.XIANZHOU_DIVINATION_TO_PRODUCTION) or 0
--------------------------------------------------------------
function XianZhouInitilize ()

	GameEvents.XianZhouSetDivinationPoint.Add(XianZhouSetDivinationPoint)
	GameEvents.DivinationPointToProduction.Add(DivinationPointToProduction)
	GameEvents.DivinationPointToProductionLater.Add(DivinationPointToProductionLater)

	Events.GameEraChanged.Add(XianZhouGameEraChanged)
	GameEvents.OnCityPopulationChanged.Add(XianZhouCityPopulationChanged)
end

--FuXuan
function XianZhouSetDivinationPoint(playerID, params)
	--print(playerID)
	local pPlayer = Players[playerID]
	local key = params.Propertykey
	local PointNum = math.floor((params.PointNum)*10+0.5)/10
    --print("Previous has DivinationPoint:",pPlayer:GetProperty(key))
	if	pPlayer:GetProperty(key) then
		pPlayer:SetProperty(key, math.floor((pPlayer:GetProperty(key) + PointNum)*10+0.5)/10)
	else
		pPlayer:SetProperty(key, math.floor(PointNum*10+0.5)/10)
	end
end

function DivinationPointToProduction(playerID, params)
	local pPlayer = Players[playerID]
	local CityID = params.CityID
	local pCity = CityManager.GetCity(playerID, CityID)
	--print(pCity:GetProperty("DivinationProduction"))
	if	pCity:GetProperty("DivinationProduction") == nil then
		local pCityBuildQueue = pCity:GetBuildQueue()
		local key = params.Propertykey
		local Hash = params.Hash
		local PercentComplete = params.PercentComplete
		local Cost = params.Cost
		local Progress = params.Progress--(Cost-Progress) = DivinationPoint*(100-DIVINATION_TO_PRODUCTION)/100
		local DivinationPoint = math.floor(pPlayer:GetProperty(key)) or 0	
		--print((Cost-Progress))
		
		if (Cost-Progress) > 0 then
			local AddDivination = math.max(math.floor((Cost-Progress)/3),10)--最大处理200%的加速锤
			local EffectivePoints = math.floor(DivinationPoint*(100-DIVINATION_TO_PRODUCTION)/100)
			print("DivinationPointToProduction",(Cost-Progress),"Has Point:",math.floor(DivinationPoint*100)/100)
			
			if	AddDivination >= EffectivePoints then--点数不足1/3
				pCityBuildQueue:AddProgress(math.floor(EffectivePoints))
				pPlayer:SetProperty(key, (pPlayer:GetProperty(key) - DivinationPoint))--清空
				print("AddProduction:",EffectivePoints,"AddDivination",DivinationPoint)
		elseif	10 >= (Cost-Progress) then--剩余进度小于10锤但点数大于10
				pCityBuildQueue:AddProgress(math.floor(Cost-Progress+0.5))
				pPlayer:SetProperty(key, (pPlayer:GetProperty(key) - math.floor((Cost-Progress)*100/(100-DIVINATION_TO_PRODUCTION))))
				print("AddProduction:",math.floor(Cost-Progress+0.5))
			else--点数大于所需的1/3且剩余进度大于10锤
				local	DivinationPreviousData = {
							Hash					= Hash,
							PercentComplete			= PercentComplete,
							Progress				= Progress,
							Cost					= Cost,
							AddDivination			= AddDivination;	
						}
				
				pCityBuildQueue:AddProgress(AddDivination)
				pPlayer:SetProperty(key, (pPlayer:GetProperty(key) - math.floor(AddDivination*100/(100-DIVINATION_TO_PRODUCTION))))
				print("AddProduction:",AddDivination,"AddDivination",math.floor(AddDivination*100/(100-DIVINATION_TO_PRODUCTION)))
				pCity:SetProperty("DivinationProduction",DivinationPreviousData)--必须位于PlayerSet下面
			end
	elseif	Cost == 0 then
			print("DivinationPointToProduction",(Cost-Progress),"Has Point:",math.floor(DivinationPoint*100)/100)
			pCityBuildQueue:AddProgress(1)--不能为0，不能为小数，
		end

	end
end

function DivinationPointToProductionLater(playerID, params)
	local pPlayer = Players[playerID]
	local CityID = params.CityID
	local pCity = CityManager.GetCity(playerID, CityID)
	local DivinationPreviousData = pCity:GetProperty("DivinationProduction")
	--print(pCity:GetProperty("DivinationProduction"))
	if	DivinationPreviousData ~= nil then
		local pCityBuildQueue = pCity:GetBuildQueue()
		local key = params.Propertykey
		local Hash = params.Hash
		local PercentComplete = params.PercentComplete
		local Cost = params.Cost
		local Progress = params.Progress
		local DivinationPoint = pPlayer:GetProperty(key) or 0
		
		local PreHash = DivinationPreviousData.Hash
		local PrePercentComplete = DivinationPreviousData.PercentComplete
		local PreProgress = DivinationPreviousData.Progress
		local PreAddDivination = DivinationPreviousData.AddDivination
		--print(Progress,PreProgress,PreAddDivination)
		if	Hash == PreHash then
			--print("DivinationPointToProduction",(Cost-Progress),DivinationPoint)
			local PreMultiplier = 1
			PreMultiplier = math.floor((Progress-PreProgress)/PreAddDivination*1000+0.5)/1000--保留三位小数**.*%(实际由于引擎内有损耗会无法避免偏小)
			local ShouldAddProduction = math.floor((Cost-Progress) / PreMultiplier + 0.5)--所需花费生产力
			local ShouldAddDivination = math.floor(ShouldAddProduction*100/(100-DIVINATION_TO_PRODUCTION))--所需花费玉兆，若为0会爆炸吧
			--local ShouldAddDivination = math.floor((Cost-Progress)/(1+PreMultiplier)*100)/100
			local EffectivePoints = math.floor(DivinationPoint*(100-DIVINATION_TO_PRODUCTION)/100+0.5)
			print("ProductionMultiplier :",PreMultiplier*100,"%%","ShouldAddProduction:",ShouldAddProduction,"ShouldAddDivination:",ShouldAddDivination,"EffectivePoints:",EffectivePoints)
			if	PreMultiplier >= 1 and EffectivePoints >= ShouldAddDivination then--为正加成且点数足够
				pCityBuildQueue:FinishProgress()
				pPlayer:SetProperty(key, (pPlayer:GetProperty(key) - ShouldAddDivination))
		elseif	EffectivePoints <= ShouldAddDivination then--点数不足
				pCityBuildQueue:AddProgress(math.floor(EffectivePoints+0.5))
				pPlayer:SetProperty(key, (pPlayer:GetProperty(key) - math.floor(DivinationPoint)))
		elseif	PreMultiplier < 1 and PreMultiplier > 0 and EffectivePoints >= ShouldAddDivination then--负加成且点数足够
				pCityBuildQueue:AddProgress(1)--部分情况下会出现无法完成的情况，因此手动加
				pCityBuildQueue:FinishProgress()
				pPlayer:SetProperty(key, (pPlayer:GetProperty(key) - ShouldAddDivination))
			end
		end
		pCity:SetProperty("DivinationProduction",nil)
	end
end

--JingLiu
function XianZhouGameEraChanged(previousEraIndex, newEraIndex)
	local pAllPlayerIDs : table = PlayerManager.GetAliveIDs()
	for	k, iPlayerID in ipairs(pAllPlayerIDs) do
		local pPlayer = Players[iPlayerID]
		if pPlayer:GetProperty('XIANZHOU_CAN_SLOT_GOLDEN_POLICIES') == nil or pPlayer:GetProperty('XIANZHOU_CAN_SLOT_GOLDEN_POLICIES') == 0 then
			return;
		end
		if	pPlayer:GetProperty('XianZhouHasUnlockPolicies') == nil then
				for row in GameInfo.CommemorationTypes() do 
					local pPlayerCulture = pPlayer:GetCulture()
					pPlayerCulture:UnlockPolicy(GameInfo.Policies['POLICY_XIANZHOU_'..row.CommemorationType].Index); --解锁政策卡
				end
			pPlayer:SetProperty('XianZhouHasUnlockPolicies',1)
		end
	end
end


function XianZhouCityPopulationChanged(playerID, cityID, ChangeAmount)
	local pPlayer = Players[playerID];
	--判断是镜流
	if pPlayer:GetProperty('XIANZHOU_LEADER_QUEST_PER_POPULATION_GROW') == nil or pPlayer:GetProperty('XIANZHOU_LEADER_QUEST_PER_POPULATION_GROW') == 0 then
		return;
	end
	local pCity = CityManager.GetCity(playerID, cityID);
	if pCity then
		local CityPlot = Map.GetPlot(pCity:GetX(), pCity:GetY());
		if ChangeAmount > 0 then
			local pGameEra = Game.GetEras()
			local ReduceEraScore = pPlayer:GetProperty('XIANZHOU_LEADER_QUEST_PER_POPULATION_GROW')
			pGameEra:ChangePlayerEraScore(playerID, ReduceEraScore)--减少时代分
		end
	end
end

Events.LoadGameViewStateDone.Add(XianZhouInitilize);