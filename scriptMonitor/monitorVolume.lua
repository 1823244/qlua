function initVolume()
    lastVolume = {}
    volumeEMA = {}
end

function Volume(i)

    local seccode = SEC_CODES['sec_codes'][i]
    local classcode = SEC_CODES['class_codes'][i]
    local period = 10                             -- ������ ���������� ������        
    local volumeFactor = 4                        -- ���������� ���, ����� ������� ����� ����������        
    local k = 2/(period+1)
    
    if volumeEMA[seccode] == nil then
        volumeEMA[seccode] = {}
    end
    
    local lastSECVolume = tonumber(getParamEx(classcode,seccode,"valtoday").param_value)
    --myLog(SEC_CODES['names'][i].." lastSECVolume: "..tostring(lastSECVolume))
    
    if lastVolume[seccode] == nil then
        lastVolume[seccode] = lastSECVolume
    end
    local intervalVolume = lastSECVolume - lastVolume[seccode]
    volumeEMA[seccode][#volumeEMA[seccode] + 1] = intervalVolume
    lastVolume[seccode] = lastSECVolume

 
    local ind = #volumeEMA[seccode]
    if ind==period then
        local sum = 0
        for n=2, ind do
            sum = sum + volumeEMA[seccode][n]
        end
        volumeEMA[seccode][ind] = sum/(ind-1)
    elseif ind>period then
        volumeEMA[seccode][ind]=round(k*volumeEMA[seccode][ind]+(1-k)*volumeEMA[seccode][ind-1], 5)
        
        local isMessage = SEC_CODES['isMessage'][i]
        local isPlaySound = SEC_CODES['isPlaySound'][i]
        local mes0 = tostring(SEC_CODES['names'][i])
        if intervalVolume > volumeEMA[seccode][ind]*volumeFactor then
            local mes = mes0..": ������ ��������� �����"
            myLog(mes)
            myLog("interval vol: "..tostring(intervalVolume))
            myLog(SEC_CODES['names'][i].." volEMA: "..tostring(volumeEMA[seccode][ind]))
            if isMessage == 1 then message(mes) end
            if isPlaySound == 1 then PaySoundFile(soundFileName) end
        end
    end  
end