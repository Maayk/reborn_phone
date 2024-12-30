RebornCore = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if RebornCore == nil then
            TriggerEvent('RebornCore:GetObject', function(obj) RebornCore = obj end)
            Citizen.Wait(200)
        end
    end
end)


-- Code

local PlayerJob = {}

phoneProp = 0
local phoneModel = `prop_npc_phone_02`

PhoneData = {
    MetaData = {},
    isOpen = false,
    PlayerData = nil,
    Contacts = {},
    Tweets = {},
    MentionedTweets = {},
    Hashtags = {},
    Chats = {},
    Invoices = {},
    Faturas = {},
    CallData = {},
    RecentCalls = {},
    Garage = {},
    Mails = {},
    Adverts = {},
    GarageVehicles = {},
    AnimationData = {
        lib = nil,
        anim = nil,
    },
    SuggestedContacts = {},
    CryptoTransactions = {},
}

RegisterNetEvent('cash-telephone:client:RaceNotify')
AddEventHandler('cash-telephone:client:RaceNotify', function(message)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Racing",
                text = message,
                icon = "fas fa-flag-checkered",
                color = "#353b48",
                timeout = 1500,
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Racing", 
                content = message, 
                icon = "fas fa-flag-checkered", 
                timeout = 3500, 
                color = "#353b48",
            },
        })
    end
end)

RegisterNetEvent('cash-telephone:client:AddRecentCall')
AddEventHandler('cash-telephone:client:AddRecentCall', function(data, time, type)
    table.insert(PhoneData.RecentCalls, {
        name = IsNumberInContacts(data.number),
        time = time,
        type = type,
        number = data.number,
        anonymous = data.anonymous
    })
    TriggerServerEvent('cash-phone:server:SetPhoneAlerts', "phone")
    Config.PhoneApplications["phone"].Alerts = Config.PhoneApplications["phone"].Alerts + 1
    SendNUIMessage({ 
        action = "RefreshAppAlerts",
        AppData = Config.PhoneApplications
    })
end)

RegisterNetEvent('RebornCore:Client:OnJobUpdate')
AddEventHandler('RebornCore:Client:OnJobUpdate', function(JobInfo)
    if JobInfo.name == "police" then
        SendNUIMessage({
            action = "UpdateApplications",
            JobData = JobInfo,
            applications = Config.PhoneApplications
        })
    elseif PlayerJob.name == "police" and JobInfo.name == "unemployed" then
        SendNUIMessage({
            action = "UpdateApplications",
            JobData = JobInfo,
            applications = Config.PhoneApplications
        })
    end

    PlayerJob = JobInfo
end)

RegisterNUICallback('ClearRecentAlerts', function(data, cb)
    TriggerServerEvent('cash-phone:server:SetPhoneAlerts', "phone", 0)
    Config.PhoneApplications["phone"].Alerts = 0
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

RegisterNUICallback('SetBackground', function(data)
    local background = data.background

    PhoneData.MetaData.background = background
    TriggerServerEvent('cash-telephone:server:SaveMetaData', PhoneData.MetaData)
end)

RegisterNUICallback('GetMissedCalls', function(data, cb)
    cb(PhoneData.RecentCalls)
end)

RegisterNUICallback('GetSuggestedContacts', function(data, cb)
    cb(PhoneData.SuggestedContacts)
end)

function IsNumberInContacts(num)
    local retval = num
    for _, v in pairs(PhoneData.Contacts) do
        if num == v.number then
            retval = v.name
        end
    end
    return retval
end

local isLoggedIn = false



RegisterCommand('phone',function(source,args,rawCommand)
	local jogador1 = PlayerPedId()
    TriggerEvent("reborn-hud:naolidas", false)
    if not PhoneData.isOpen then
        local IsHandcuffed = exports['reborn_police']:IsHandcuffed()
        if not IsHandcuffed then
            OpenPhone()
        else
            -- RebornCore.Functions.Notify("A ação atualmente não é possível.", "error")
            TriggerEvent('reborn:notify:send', "Sistema","A ação atualmente não é possível.","info", 3000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(0, Config.OpenPhone) then
            TriggerEvent("reborn-hud:naolidas", false)
            if not PhoneData.isOpen then
                local IsHandcuffed = exports['reborn_police']:IsHandcuffed()
                if not IsHandcuffed then
                    OpenPhone()
                else
                    TriggerEvent('reborn:notify:send', "Sistema","A ação atualmente não é possível.","info", 3000)
                end
            end
        end
        Citizen.Wait(3)
    end
end)

function CalculateTimeToDisplay()
	hour = GetClockHours()
    minute = GetClockMinutes()
    month = GetClockMonth()
    dayOfMonth = GetClockDayOfMonth()
    tmp = exports.reborn_tmp.getCurrentTemperature()
    temperaturaMin = tmp
    temperaturaMax = tmp
    mensagemTempo = nil

    if month == 0 then
        month = "Janeiro"
    elseif month == 1 then
        month = "Janeiro"
    elseif month == 2 then
        month = "Fevereiro"
    elseif month == 3 then
        month = "Março"
    elseif month == 4 then
        month = "Abril"
    elseif month == 5 then
        month = "Maio"
    elseif month == 6 then
        month = "Junho"
    elseif month == 7 then
        month = "Julho"
    elseif month == 8 then
        month = "Agosto"
    elseif month == 9 then
        month = "Setembro"
    elseif month == 10 then
        month = "Outubro"
    elseif month == 11 then
        month = "Novembro"
    elseif month == 12 then
        month = "Dezembro"
    end

    if hour <= 12 then
        mensagemgood = "Bom Dia"
        mensagemTempo = "Hoje a temperatura pode variar entre "..temperaturaMin.." com uma máxima de até "..temperaturaMax 
    elseif hour >= 13 and hour <= 17 then
        mensagemgood = "Boa Tarde"
        mensagemTempo = "Hoje a temperatura pode variar entre "..temperaturaMin.." com uma máxima de até "..temperaturaMax 
    elseif hour > 18 then
        mensagemgood = "Boa Noite"
        mensagemTempo = "Hoje a temperatura pode variar entre "..temperaturaMin.." com uma máxima de até "..temperaturaMax 
    end

    local obj = {}
    
	if minute <= 9 then
		minute = "0" .. minute
    end
    
    obj.hour = hour
    obj.minute = minute
    obj.mes = month
    obj.dia = dayOfMonth
    obj.msgtmp = mensagemTempo
    obj.msggood = mensagemgood
    obj.temp = tmp

    return obj
end

Citizen.CreateThread(function()
    while true do
        if PhoneData.isOpen then
            SendNUIMessage({
                action = "UpdateTime",
                InGameTime = CalculateTimeToDisplay(),
            })
        end
        Citizen.Wait(1000)
    end
end)


RegisterNetEvent( 'reborn:update:faturas' )
AddEventHandler( 'reborn:update:faturas', function()
    AtualizaFaturas()
    -- print('atualizando faturas')
end)

RegisterNetEvent( 'reborn:update:banco:historico' )
AddEventHandler( 'reborn:update:banco:historico', function()
    AtualizaHistoricoBancario()
    -- print('atualizando historico bancário')
end)

function AtualizaHistoricoBancario()
    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetPhoneData', function(pData)
        if pData.Faturas ~= nil and next(pData.Faturas) ~= nil then
            -- for _, fatura in pairs(pData.Invoices) do
            --     invoice.name = IsNumberInContacts(invoice.number)
            -- end
            PhoneData.Faturas = pData.Faturas
        end
    end)
end



function AtualizaFaturas()
    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetPhoneData', function(pData)
        if pData.Invoices ~= nil and next(pData.Invoices) ~= nil then
            for _, invoice in pairs(pData.Invoices) do
                invoice.name = IsNumberInContacts(invoice.number)
            end
            PhoneData.Invoices = pData.Invoices
        end
    end)
end



function LoadPhone()
    Citizen.Wait(100)
    isLoggedIn = true
    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetPhoneData', function(pData)
        PlayerJob = RebornCore.Functions.GetPlayerData().job
        PhoneData.PlayerData = RebornCore.Functions.GetPlayerData()
        local PhoneMeta = PhoneData.PlayerData.metadata["phone"]
        PhoneData.MetaData = PhoneMeta

        if PhoneMeta.profilepicture == nil then
            PhoneData.MetaData.profilepicture = "default"
        else
            PhoneData.MetaData.profilepicture = PhoneMeta.profilepicture
        end

        if pData.Applications ~= nil and next(pData.Applications) ~= nil then
            for k, v in pairs(pData.Applications) do 
                Config.PhoneApplications[k].Alerts = v 
            end
        end

        if pData.MentionedTweets ~= nil and next(pData.MentionedTweets) ~= nil then 
            PhoneData.MentionedTweets = pData.MentionedTweets 
        end

        if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then 
            PhoneData.Contacts = pData.PlayerContacts
        end

        if pData.Chats ~= nil and next(pData.Chats) ~= nil then
            local Chats = {}
            for k, v in pairs(pData.Chats) do
                Chats[v.number] = {
                    name = IsNumberInContacts(v.number),
                    number = v.number,
                    messages = json.decode(v.messages)
                }
            end

            PhoneData.Chats = Chats
        end

        if pData.Invoices ~= nil and next(pData.Invoices) ~= nil then
            for _, invoice in pairs(pData.Invoices) do
                invoice.name = IsNumberInContacts(invoice.number)
            end
            PhoneData.Invoices = pData.Invoices
        end

        if pData.Faturas ~= nil and next(pData.Faturas) ~= nil then
            -- for _, invoice in pairs(pData.Invoices) do
            --     invoice.name = IsNumberInContacts(invoice.number)
            -- end
            PhoneData.Faturas = pData.Faturas
            -- print(dump(pData.Faturas))
        end

        if pData.Hashtags ~= nil and next(pData.Hashtags) ~= nil then
            PhoneData.Hashtags = pData.Hashtags
        end

        if pData.Tweets ~= nil and next(pData.Tweets) ~= nil then
            PhoneData.Tweets = pData.Tweets
        end

        if pData.Mails ~= nil and next(pData.Mails) ~= nil then
            PhoneData.Mails = pData.Mails
        end

        if pData.Adverts ~= nil and next(pData.Adverts) ~= nil then
            PhoneData.Adverts = pData.Adverts
        end

        if pData.CryptoTransactions ~= nil and next(pData.CryptoTransactions) ~= nil then
            PhoneData.CryptoTransactions = pData.CryptoTransactions
        end

        Citizen.Wait(300)
    
        SendNUIMessage({ 
            action = "LoadPhoneData", 
            PhoneData = PhoneData, 
            PlayerData = PhoneData.PlayerData,
            PlayerJob = PhoneData.PlayerData.job,
            applications = Config.PhoneApplications 
        })
    end)
end


function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

Citizen.CreateThread(function()
    Wait(500)
    LoadPhone()
end)

RegisterNetEvent('RebornCore:Client:OnPlayerUnload')
AddEventHandler('RebornCore:Client:OnPlayerUnload', function()
    PhoneData = {
        MetaData = {},
        isOpen = false,
        PlayerData = nil,
        Contacts = {},
        Tweets = {},
        MentionedTweets = {},
        Hashtags = {},
        Chats = {},
        Invoices = {},
        Faturas = {},
        CallData = {},
        RecentCalls = {},
        Garage = {},
        Mails = {},
        Adverts = {},
        GarageVehicles = {},
        AnimationData = {
            lib = nil,
            anim = nil,
        },
        SuggestedContacts = {},
        CryptoTransactions = {},
    }

    isLoggedIn = false
end)

RegisterNetEvent('RebornCore:Client:OnPlayerLoaded')
AddEventHandler('RebornCore:Client:OnPlayerLoaded', function()
    LoadPhone()
end)

RegisterNUICallback('HasPhone', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-telephone:server:HasPhone', function(HasPhone)
        cb(HasPhone)
    end)
end)

function OpenPhone()
    RebornCore.Functions.TriggerCallback('cash-telephone:server:HasPhone', function(HasPhone)
        if HasPhone then
            PhoneData.PlayerData = RebornCore.Functions.GetPlayerData()
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "open",
                Tweets = PhoneData.Tweets,
                AppData = Config.PhoneApplications,
                CallData = PhoneData.CallData,
                PlayerData = PhoneData.PlayerData,
            })
            PhoneData.isOpen = true

            if not PhoneData.CallData.InCall then
                DoPhoneAnimation('cellphone_text_in')
            else
                DoPhoneAnimation('cellphone_call_to_text')
            end

            SetTimeout(250, function()
                newPhoneProp()
            end)
    
            RebornCore.Functions.TriggerCallback('cash-telephone:server:GetGarageVehicles', function(vehicles)
                PhoneData.GarageVehicles = vehicles
            end)
        else
            -- RebornCore.Functions.Notify("You don't have a phone", "error")
            TriggerEvent('reborn:notify:send', "Sistema","Você não tem um celular","error", 3000)
        end
    end)
end

RegisterNUICallback('SetupGarageVehicles', function(data, cb)
    cb(PhoneData.GarageVehicles)
end)

RegisterNUICallback('Close', function()
    if not PhoneData.CallData.InCall then
        DoPhoneAnimation('cellphone_text_out')
        SetTimeout(400, function()
            StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
            deletePhone()
            PhoneData.AnimationData.lib = nil
            PhoneData.AnimationData.anim = nil
        end)
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
        DoPhoneAnimation('cellphone_text_to_call')
    end
    SetNuiFocus(false, false)
    -- SetNuiFocusKeepInput(false)
    SetTimeout(1000, function()
        PhoneData.isOpen = false
    end)
end)

RegisterNUICallback('CloseWithNotification', function()
    -- SetNuiFocus(false, false)
    PhoneData.isOpen = false
end)

RegisterNUICallback('RemoveMail', function(data, cb)
    local MailId = data.mailId

    TriggerServerEvent('cash-telephone:server:RemoveMail', MailId)
    cb('ok')
end)

RegisterNetEvent('cash-telephone:client:UpdateMails')
AddEventHandler('cash-telephone:client:UpdateMails', function(NewMails)
    SendNUIMessage({
        action = "UpdateMails",
        Mails = NewMails
    })
    PhoneData.Mails = NewMails
end)

RegisterNUICallback('AcceptMailButton', function(data)
    TriggerEvent(data.buttonEvent, data.buttonData)
    TriggerServerEvent('cash-telephone:server:ClearButtonData', data.mailId)
end)

RegisterNUICallback('AddNewContact', function(data, cb)
    table.insert(PhoneData.Contacts, {
        name = data.ContactName,
        number = data.ContactNumber,
        iban = data.ContactIban
    })
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[data.ContactNumber] ~= nil and next(PhoneData.Chats[data.ContactNumber]) ~= nil then
        PhoneData.Chats[data.ContactNumber].name = data.ContactName
    end
    TriggerServerEvent('cash-telephone:server:AddNewContact', data.ContactName, data.ContactNumber, data.ContactIban)
end)

RegisterNUICallback('GetMails', function(data, cb)
    cb(PhoneData.Mails)
end)

RegisterNUICallback('GetWhatsappChat', function(data, cb)
    if PhoneData.Chats[data.phone] ~= nil then
        cb(PhoneData.Chats[data.phone])
    else
        cb(false)
    end
end)

RegisterNUICallback('GetProfilePicture', function(data, cb)
    local number = data.number

    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetPicture', function(picture)
        cb(picture)
    end, number)
end)

RegisterNUICallback('GetBankContacts', function(data, cb)
    cb(PhoneData.Contacts)
end)

RegisterNUICallback('GetInvoices', function(data, cb)
    if PhoneData.Invoices ~= nil and next(PhoneData.Invoices) ~= nil then
        cb(PhoneData.Invoices)
    else
        cb(nil)
    end
end)

RegisterNUICallback('LoadandoFaturas', function(data, cb)
    if PhoneData.Faturas ~= nil and next(PhoneData.Faturas) ~= nil then
        cb(PhoneData.Faturas)
    else
        cb(nil)
    end
end)

function GetKeyByDate(Number, Date)
    local retval = nil
    if PhoneData.Chats[Number] ~= nil then
        if PhoneData.Chats[Number].messages ~= nil then
            for key, chat in pairs(PhoneData.Chats[Number].messages) do
                if chat.date == Date then
                    retval = key
                    break
                end
            end
        end
    end
    return retval
end

function GetKeyByNumber(Number)
    local retval = nil
    if PhoneData.Chats then
        for k, v in pairs(PhoneData.Chats) do
            if v.number == Number then
                retval = k
            end
        end
    end
    return retval
end

function ReorganizeChats(key)
    local ReorganizedChats = {}
    ReorganizedChats[1] = PhoneData.Chats[key]
    for k, chat in pairs(PhoneData.Chats) do
        if k ~= key then
            table.insert(ReorganizedChats, chat)
        end
    end
    PhoneData.Chats = ReorganizedChats
end

RegisterNUICallback('SendMessage', function(data, cb)
    local ChatMessage = data.ChatMessage
    local ChatDate = data.ChatDate
    local ChatNumber = data.ChatNumber
    local ChatTime = data.ChatTime
    local ChatType = data.ChatType
    local ChatImagem = data.Imagem

    local Ped = GetPlayerPed(-1)
    local Pos = GetEntityCoords(Ped)
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(table.unpack(GetEntityCoords(PlayerPedId(),false))))
    local NumberKey = GetKeyByNumber(ChatNumber)
    local ChatKey = GetKeyByDate(NumberKey, ChatDate)
    -- checkpoint
    if PhoneData.Chats[NumberKey] ~= nil then
        if PhoneData.Chats[NumberKey].messages[ChatKey] ~= nil then
            if ChatType == "message" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                })
            elseif ChatType == "location" then
                -- print(ChatImagem)
                if ChatImagem == nil then
                    table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                        message = "Localização Compartilhada",
                        time = ChatTime,
                        sender = PhoneData.PlayerData.citizenid,
                        type = ChatType,
                        data = {
                            x = Pos.x,
                            y = Pos.y,
                            localizacao = street,
                            Imagem = ChatImagem
                        },
                    })
                else
                    table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                        message = "Imagem Recebida",
                        time = ChatTime,
                        sender = PhoneData.PlayerData.citizenid,
                        type = ChatType,
                        data = {
                            x = Pos.x,
                            y = Pos.y,
                            localizacao = street,
                            Imagem = ChatImagem
                        },
                    })
                end
            end
            TriggerServerEvent('cash-telephone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, false)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        else
            table.insert(PhoneData.Chats[NumberKey].messages, {
                date = ChatDate,
                messages = {},
            })
            ChatKey = GetKeyByDate(NumberKey, ChatDate)
            if ChatType == "message" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                    message = ChatMessage,
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {},
                })
            elseif ChatType == "location" then
                table.insert(PhoneData.Chats[NumberKey].messages[ChatDate].messages, {
                    message = "Shared location",
                    time = ChatTime,
                    sender = PhoneData.PlayerData.citizenid,
                    type = ChatType,
                    data = {
                        x = Pos.x,
                        y = Pos.y,
                    },
                })
            end
            TriggerServerEvent('cash-telephone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, true)
            NumberKey = GetKeyByNumber(ChatNumber)
            ReorganizeChats(NumberKey)
        end
    else
        table.insert(PhoneData.Chats, {
            name = IsNumberInContacts(ChatNumber),
            number = ChatNumber,
            messages = {},
        })
        NumberKey = GetKeyByNumber(ChatNumber)
        table.insert(PhoneData.Chats[NumberKey].messages, {
            date = ChatDate,
            messages = {},
        })
        ChatKey = GetKeyByDate(NumberKey, ChatDate)
        if ChatType == "message" then
            table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                message = ChatMessage,
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {},
            })
        elseif ChatType == "location" then
            table.insert(PhoneData.Chats[NumberKey].messages[ChatKey].messages, {
                message = "Shared Location",
                time = ChatTime,
                sender = PhoneData.PlayerData.citizenid,
                type = ChatType,
                data = {
                    x = Pos.x,
                    y = Pos.y,
                },
            })
        end
        TriggerServerEvent('cash-telephone:server:UpdateMessages', PhoneData.Chats[NumberKey].messages, ChatNumber, true)
        NumberKey = GetKeyByNumber(ChatNumber)
        ReorganizeChats(NumberKey)
    end

    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetContactPicture', function(Chat)
        SendNUIMessage({
            action = "UpdateChat",
            chatData = Chat,
            chatNumber = ChatNumber,
        })
    end,  PhoneData.Chats[GetKeyByNumber(ChatNumber)])
end)

RegisterNUICallback('SharedLocation', function(data)
    local x = data.coords.x
    local y = data.coords.y

    SetNewWaypoint(x, y)
    --NOTIFICACAODENTRODOCELULAR
    SendNUIMessage({
        action = "InsidePhoneNotify",
        PhoneNotify = {
            title = "Mensagem",
            text = "Localização marcada!",
            app = "sms",
            mtitulo = "Localização",
        },
    })
end)

RegisterNetEvent('cash-telephone:client:UpdateMessages')
AddEventHandler('cash-telephone:client:UpdateMessages', function(ChatMessages, SenderNumber, New)
    local Sender = IsNumberInContacts(SenderNumber)

    local NumberKey = GetKeyByNumber(SenderNumber)

    if New then
        PhoneData.Chats[NumberKey] = {
            name = IsNumberInContacts(SenderNumber),
            number = SenderNumber,
            messages = ChatMessages
        }

        if PhoneData.Chats[NumberKey].Unread ~= nil then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "SMS",
                        text = "Nova mensagem de <strong>"..IsNumberInContacts(SenderNumber).."</strong>!",
                        app = "sms",
                        mtitulo = "Nova Mensagem",
                    },
                })
            else
                
                --NOTIFICACAODENTRODOCELULAR
                SendNUIMessage({
                    action = "InsidePhoneNotify",
                    PhoneNotify = {
                        title = "SMS",
                        text = "Você não pode mandar mensagem para você mesmo.",
                        app = "sms",
                        mtitulo = "Messenger",
                    },
                })
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Wait(100)
            RebornCore.Functions.TriggerCallback('cash-telephone:server:GetContactPictures', function(Chats)
                SendNUIMessage({
                    action = "UpdateChat",
                    chatData = Chats[GetKeyByNumber(SenderNumber)],
                    chatNumber = SenderNumber,
                    Chats = Chats,
                })
            end,  PhoneData.Chats)
            --xD
        else
            SendNUIMessage({
                action = "Notification",
                PhoneNotify = {
                    title = "SMS",
                    text = "Nova mensagem de <strong>"..IsNumberInContacts(SenderNumber).."</strong>!",
                    app = "sms",
                    mtitulo = "Nova Mensagem",
                    timeout = 1500,
                },
            })
            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
            TriggerServerEvent('cash-phone:server:SetPhoneAlerts', "whatsapp")
        end
    else
        PhoneData.Chats[NumberKey].messages = ChatMessages

        if PhoneData.Chats[NumberKey].Unread ~= nil then
            PhoneData.Chats[NumberKey].Unread = PhoneData.Chats[NumberKey].Unread + 1
        else
            PhoneData.Chats[NumberKey].Unread = 1
        end

        if PhoneData.isOpen then
            if SenderNumber ~= PhoneData.PlayerData.charinfo.phone then
                SendNUIMessage({
                    action = "PhoneNotification",
                    PhoneNotify = {
                        title = "SMS",
                        text = "Nova mensagem de <strong>"..IsNumberInContacts(SenderNumber).."</strong>!",
                        app = "sms",
                        mtitulo = "Nova Mensagem",
                    },
                })
            else
                
                --NOTIFICACAODENTRODOCELULAR
                SendNUIMessage({
                    action = "InsidePhoneNotify",
                    PhoneNotify = {
                        title = "SMS",
                        text = "Você não pode mandar mensagem para você mesmo.",
                        app = "sms",
                        mtitulo = "Messenger",
                    },
                })
            end

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)
            
            Wait(100)
            RebornCore.Functions.TriggerCallback('cash-telephone:server:GetContactPictures', function(Chats)
                SendNUIMessage({
                    action = "UpdateChat",
                    chatData = Chats[GetKeyByNumber(SenderNumber)],
                    chatNumber = SenderNumber,
                    Chats = Chats,
                })
            end,  PhoneData.Chats)
        else
            SendNUIMessage({
                action = "Notification",
                NotifyData = {
                    title = "SMS", 
                    text = "Você recebeu uma nova mensagem de <strong>"..IsNumberInContacts(SenderNumber).."</strong>!", 
                    app = "sms",
                    mtitulo = "Nova Mensagem",
                    color = "#3bd325",
                },
            })

            NumberKey = GetKeyByNumber(SenderNumber)
            ReorganizeChats(NumberKey)

            Config.PhoneApplications['whatsapp'].Alerts = Config.PhoneApplications['whatsapp'].Alerts + 1
            TriggerServerEvent('cash-phone:server:SetPhoneAlerts', "whatsapp")
        end
    end
end)

RegisterNetEvent("cash-phone-new:client:BankNotify")
AddEventHandler("cash-phone-new:client:BankNotify", function(text)
    SendNUIMessage({
        action = "Notification",
        NotifyData = {
            title = "Bank", 
            content = text, 
            icon = "fas fa-university", 
            timeout = 3500, 
            color = "#ff0000",
        },
    })
end)

RegisterNetEvent('cash-telephone:client:NewMailNotify')
AddEventHandler('cash-telephone:client:NewMailNotify', function(MailData)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Mail",
                text = "Você recebeu um novo Mail de <strong>"..MailData.sender.."</strong>",
                app = "mail",
                mtitulo = "Novo Mail",
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Mail",
                text = "Você recebeu um novo Mail de <strong>"..MailData.sender.."</strong>",
                app = "mail",
                mtitulo = "Novo Mail",
            },
        })
    end
    Config.PhoneApplications['mail'].Alerts = Config.PhoneApplications['mail'].Alerts + 1
    TriggerServerEvent('cash-phone:server:SetPhoneAlerts', "mail")
end)

RegisterNUICallback('NovoAnuncio', function(data)
    TriggerServerEvent('reborn-phone:server:novoanuncio', data.message)
end)

RegisterNetEvent('reborn-phone:client:updateanuncio')
AddEventHandler('reborn-phone:client:updateanuncio', function(Adverts, LastAd)
    PhoneData.Adverts = Adverts

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Rebay",
                text = "Novo anuncio de <strong>"..LastAd.."</strong>",
                app = "anunciar",
                mtitulo = "Novo Anuncio",
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Rebay",
                text = "Novo anuncio de <strong>"..LastAd.."</strong>",
                app = "anunciar",
                mtitulo = "Novo Anuncio",
            },
        })
    end

    SendNUIMessage({
        action = "RefreshAdverts",
        Adverts = PhoneData.Adverts
    })
end)

RegisterNUICallback('LoadAdverts', function()
    SendNUIMessage({
        action = "RefreshAdverts",
        Adverts = PhoneData.Adverts
    })
end)

RegisterNUICallback('ClearAlerts', function(data, cb)
    local chat = data.number
    local ChatKey = GetKeyByNumber(chat)

    if PhoneData.Chats[ChatKey].Unread ~= nil then
        local newAlerts = (Config.PhoneApplications['whatsapp'].Alerts - PhoneData.Chats[ChatKey].Unread)
        Config.PhoneApplications['whatsapp'].Alerts = newAlerts
        TriggerServerEvent('cash-phone:server:SetPhoneAlerts', "whatsapp", newAlerts)

        PhoneData.Chats[ChatKey].Unread = 0

        SendNUIMessage({
            action = "RefreshWhatsappAlerts",
            Chats = PhoneData.Chats,
        })
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    end
end)

RegisterNUICallback('PayInvoice', function(data, cb)
    local sender = data.sender
    local amount = data.amount
    local invoiceId = data.invoiceId

    RebornCore.Functions.TriggerCallback('cash-telephone:server:PayInvoice', function(CanPay, Invoices)
        if CanPay then PhoneData.Invoices = Invoices end
        cb(CanPay)
    end, sender, amount, invoiceId)

    TriggerServerEvent('reborn:historico:add',sender,amount,'Fatura','Pagamento de Fatura #'..invoiceId,'1')

    RebornCore.Functions.GetPlayerData(function(PlayerData)
        local rg = PlayerData.citizenid
        TriggerServerEvent('reborn:historico:add',rg,amount,'Fatura','Sua Fatura #'..invoiceId.." foi paga",'2')
    end)
    -- TriggerServerEvent('reborn_banking:update:balance',src)
end)

RegisterNUICallback('DeclineInvoice', function(data, cb)
    local sender = data.sender
    -- print(sender)
    local amount = data.amount
    local invoiceId = data.invoiceId

    RebornCore.Functions.TriggerCallback('cash-telephone:server:DeclineInvoice', function(CanPay, Invoices)
        PhoneData.Invoices = Invoices
        cb('ok')
    end, sender, amount, invoiceId)
end)

RegisterNUICallback('EditContact', function(data, cb)
    local NewName = data.CurrentContactName
    local NewNumber = data.CurrentContactNumber
    local NewIban = data.CurrentContactIban
    local OldName = data.OldContactName
    local OldNumber = data.OldContactNumber
    local OldIban = data.OldContactIban

    for k, v in pairs(PhoneData.Contacts) do
        if v.name == OldName and v.number == OldNumber then
            v.name = NewName
            v.number = NewNumber
            v.iban = NewIban
        end
    end
    if PhoneData.Chats[NewNumber] ~= nil and next(PhoneData.Chats[NewNumber]) ~= nil then
        PhoneData.Chats[NewNumber].name = NewName
    end
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    TriggerServerEvent('cash-telephone:server:EditContact', NewName, NewNumber, NewIban, OldName, OldNumber, OldIban)
end)

local function escape_str(s)
	-- local in_char  = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
	-- local out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}
	-- for i, c in ipairs(in_char) do
	--   s = s:gsub(c, '\\' .. out_char[i])
	-- end
	return s
end

function GenerateTweetId()
    local tweetId = "TWEET-"..math.random(11111111, 99999999)
    return tweetId
end

RegisterNetEvent('cash-telephone:client:UpdateHashtags')
AddEventHandler('cash-telephone:client:UpdateHashtags', function(Handle, msgData)
    if PhoneData.Hashtags[Handle] ~= nil then
        table.insert(PhoneData.Hashtags[Handle].messages, msgData)
    else
        PhoneData.Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        table.insert(PhoneData.Hashtags[Handle].messages, msgData)
    end

    SendNUIMessage({
        action = "UpdateHashtags",
        Hashtags = PhoneData.Hashtags,
    })
end)

RegisterNUICallback('GetHashtagMessages', function(data, cb)
    if PhoneData.Hashtags[data.hashtag] ~= nil and next(PhoneData.Hashtags[data.hashtag]) ~= nil then
        cb(PhoneData.Hashtags[data.hashtag])
    else
        cb(nil)
    end
end)

RegisterNUICallback('GetTweets', function(data, cb)
    cb(PhoneData.Tweets)
end)

RegisterNUICallback('UpdateProfilePicture', function(data)
    local pf = data.profilepicture

    PhoneData.MetaData.profilepicture = pf
    
    TriggerServerEvent('cash-telephone:server:SaveMetaData', PhoneData.MetaData)
end)

local patt = "[?!@#]"

RegisterNUICallback('PostNewTweet', function(data, cb)
    local TweetMessage = {
        firstName = PhoneData.PlayerData.charinfo.firstname,
        lastName = PhoneData.PlayerData.charinfo.lastname,
        message = escape_str(data.Message),
        time = data.Date,
        tweetId = GenerateTweetId(),
        picture = data.Picture
    }

    local TwitterMessage = data.Message
    local MentionTag = TwitterMessage:split("@")
    local Hashtag = TwitterMessage:split("#")

    for i = 2, #Hashtag, 1 do
        local Handle = Hashtag[i]:split(" ")[1]
        if Handle ~= nil or Handle ~= "" then
            local InvalidSymbol = string.match(Handle, patt)
            if InvalidSymbol then
                Handle = Handle:gsub("%"..InvalidSymbol, "")
            end
            TriggerServerEvent('cash-telephone:server:UpdateHashtags', Handle, TweetMessage)
        end
    end

    for i = 2, #MentionTag, 1 do
        local Handle = MentionTag[i]:split(" ")[1]
        if Handle ~= nil or Handle ~= "" then
            local Fullname = Handle:split("_")
            local Firstname = Fullname[1]
            table.remove(Fullname, 1)
            local Lastname = table.concat(Fullname, " ")

            if (Firstname ~= nil and Firstname ~= "") and (Lastname ~= nil and Lastname ~= "") then
                if Firstname ~= PhoneData.PlayerData.charinfo.firstname and Lastname ~= PhoneData.PlayerData.charinfo.lastname then
                    TriggerServerEvent('cash-telephone:server:MentionedPlayer', Firstname, Lastname, TweetMessage)
                else
                    --NOTIFICACAODENTRODOCELULAR
                    SendNUIMessage({
                        action = "InsidePhoneNotify",
                        PhoneNotify = {
                            title = "Twitter",
                            text = "Você não pode mencionar você mesmo!",
                            app = "twitter",
                            mtitulo = "Twitter",
                        },
                    })
                    
                end
            end
        end
    end

    table.insert(PhoneData.Tweets, TweetMessage)
    Citizen.Wait(100)
    cb(PhoneData.Tweets)

    TriggerServerEvent('cash-telephone:server:UpdateTweets', PhoneData.Tweets, TweetMessage)
end)

RegisterNetEvent('cash-telephone:client:TransferMoney')
AddEventHandler('cash-telephone:client:TransferMoney', function(amount, newmoney)
    PhoneData.PlayerData.money.bank = newmoney
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Banco",
                text = "$<strong>"..amount.."</strong> Creditado!",
                app = "banco",
                mtitulo = "Banco",
            },
        })
        SendNUIMessage({ action = "UpdateBank", NewBalance = PhoneData.PlayerData.money.bank })
    else
        SendNUIMessage({ action = "Notification", NotifyData = { title = "Banco", text = "$<strong>"..amount.."</strong> Creditado!", app = "banco", mtitulo = "Banco", }, })
    end
end)

RegisterNetEvent('cash-telephone:client:UpdateTweets')
AddEventHandler('cash-telephone:client:UpdateTweets', function(src, Tweets, NewTweetData)
    PhoneData.Tweets = Tweets
    local MyPlayerId = PhoneData.PlayerData.source

    if src ~= MyPlayerId then
        if not PhoneData.isOpen then
            SendNUIMessage({
                action = "Notification",
                NotifyData = {
                    title = "Twitter", 
                    text = "@"..NewTweetData.firstName.." "..NewTweetData.lastName.." Tweetou ", 
                    app = "twitter", 
                    mtitulo = "Novo Tweet", 
                },
            })
        else
            SendNUIMessage({
                action = "PhoneNotification",
                PhoneNotify = {
                    title = "Twitter", 
                    text = "@"..NewTweetData.firstName.." "..NewTweetData.lastName.." Tweetou ", 
                    app = "twitter",
                    mtitulo = "Novo Tweet",
                },
            })
        end
    end
    SendNUIMessage({
        action = "InsidePhoneNotify",
        PhoneNotify = {
            title = "Twitter",
            text = "Você postou um novo Tweet.",
            app = "twitter",
            mtitulo = "Novo Tweet",
        },
    })
end)

RegisterNUICallback('GetMentionedTweets', function(data, cb)
    cb(PhoneData.MentionedTweets)
end)

RegisterNUICallback('GetHashtags', function(data, cb)
    if PhoneData.Hashtags ~= nil and next(PhoneData.Hashtags) ~= nil then
        cb(PhoneData.Hashtags)
    else
        cb(nil)
    end
end)

RegisterNetEvent('cash-telephone:client:GetMentioned')
AddEventHandler('cash-telephone:client:GetMentioned', function(TweetMessage, AppAlerts)
    Config.PhoneApplications["twitter"].Alerts = AppAlerts
    if not PhoneData.isOpen then
        SendNUIMessage({ action = "Notification", NotifyData = { title = "Twitter", content = TweetMessage.message, app = "twitter", mtitulo = "Twitter", }, })
    else
        SendNUIMessage({ action = "PhoneNotification", PhoneNotify = { title = "Twitter", text = TweetMessage.message, app = "twitter", mtitulo = "Twitter", }, })
    end
    local TweetMessage = {firstName = TweetMessage.firstName, lastName = TweetMessage.lastName, message = escape_str(TweetMessage.message), time = TweetMessage.time, picture = TweetMessage.picture}
    table.insert(PhoneData.MentionedTweets, TweetMessage)
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    SendNUIMessage({ action = "UpdateMentionedTweets", Tweets = PhoneData.MentionedTweets })
end)

RegisterNUICallback('ClearMentions', function()
    Config.PhoneApplications["twitter"].Alerts = 0
    SendNUIMessage({
        action = "RefreshAppAlerts",
        AppData = Config.PhoneApplications
    })
    TriggerServerEvent('cash-phone:server:SetPhoneAlerts', "twitter", 0)
    SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

RegisterNUICallback('ClearGeneralAlerts', function(data)
    SetTimeout(400, function()
        Config.PhoneApplications[data.app].Alerts = 0
        SendNUIMessage({
            action = "RefreshAppAlerts",
            AppData = Config.PhoneApplications
        })
        TriggerServerEvent('cash-phone:server:SetPhoneAlerts', data.app, 0)
        SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
    end)
end)

function string:split(delimiter)
    local result = { }
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
    return result
end

RegisterNUICallback('TransferMoney', function(data, cb)
    data.amount = tonumber(data.amount)
    if tonumber(PhoneData.PlayerData.money.bank) >= data.amount then
        local amaountata = PhoneData.PlayerData.money.bank - data.amount
        TriggerServerEvent('cash-telephone:server:TransferMoney', data.iban, data.amount)
        local cbdata = {
            CanTransfer = true,
            NewAmount = amaountata 
        }
        cb(cbdata)
    else
        local cbdata = {
            CanTransfer = false,
            NewAmount = nil,
        }
        cb(cbdata)
    end
end)

RegisterNUICallback('GetWhatsappChats', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetContactPictures', function(Chats)
        cb(Chats)
    end, PhoneData.Chats)
end)

function dump(t, indent, done)
    done = done or {}
    indent = indent or 0

    done[t] = true

    for key, value in pairs(t) do
        print(string.rep("\t", indent))

        if (type(value) == "table" and not done[value]) then
            done[value] = true
            print(key, ":\n")

            dump(value, indent + 2, done)
            done[value] = nil
        else
            print(key, "\t=\t", value, "\n")
        end
    end
end

RegisterNUICallback('CallContact', function(data, cb)
    --print(dump(data.ContactData))
    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetCallState', function(CanCall, IsOnline)
        local status = { 
            CanCall = CanCall, 
            IsOnline = IsOnline,
            InCall = PhoneData.CallData.InCall,
        }
        -- print(dump(status))
        cb(status)
        if CanCall and not status.InCall and (data.ContactData.number ~= PhoneData.PlayerData.charinfo.phone) then
            CallContact(data.ContactData, data.Anonymous)
        end
    end, data.ContactData)
end)

function GenerateCallId(caller, target)
    local CallId = math.ceil(((tonumber(caller) + tonumber(target)) / 100 * 1))
    return CallId
end

CallContact = function(CallData, AnonymousCall)
    local RepeatCount = 0
    PhoneData.CallData.CallType = "outgoing"
    PhoneData.CallData.InCall = true
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.CallId = GenerateCallId(PhoneData.PlayerData.charinfo.phone, CallData.number)

    -- print(AnonymousCall)

    TriggerServerEvent('cash-telephone:server:CallContact', PhoneData.CallData.TargetData, PhoneData.CallData.CallId, AnonymousCall)
    TriggerServerEvent('cash-telephone:server:SetCallState', true)
    
    for i = 1, Config.CallRepeats + 1, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                if PhoneData.CallData.InCall then
                    RepeatCount = RepeatCount + 1
                    TriggerEvent('InteractSound_CL:PlayOnOne', "ligando", 0.1)
                else
                    break
                end
                Citizen.Wait(Config.RepeatTimeout)
            else
                CancelCall()
                break
            end
        else
            break
        end
    end
end

CancelCall = function()
    TriggerServerEvent('cash-telephone:server:CancelCall', PhoneData.CallData)
    if PhoneData.CallData.CallType == "ongoing" then
        --exports.tokovoip_script:removePlayerFromRadio(PhoneData.CallData.CallId)
        exports["mumble-voip"]:SetCallChannel(0)
    end
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}
    PhoneData.CallData.CallId = nil

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    end

    TriggerServerEvent('cash-telephone:server:SetCallState', false)

    if not PhoneData.isOpen then
        SendNUIMessage({ 
            action = "Notification", 
            NotifyData = { 
                title = "Phone",
                text = "Ligação finalizada", 
                app = "telefone", 
                mtitulo = "Ligação", 
            }, 
        })            
    else
        --NOTIFICACAODENTRODOCELULAR
        SendNUIMessage({ 
            action = "InsidePhoneNotify", 
            PhoneNotify = { 
                title = "Phone",
                text = "Ligação encerrada",
                app = "telefone",
                mtitulo = "Ligação",
            }, 
        })

        SendNUIMessage({
            action = "SetupHomeCall",
            CallData = PhoneData.CallData,
        })

        SendNUIMessage({
            action = "CancelOutgoingCall",
        })
    end
end

RegisterNetEvent('cash-telephone:client:CancelCall')
AddEventHandler('cash-telephone:client:CancelCall', function()
    if PhoneData.CallData.CallType == "ongoing" then
        SendNUIMessage({
            action = "CancelOngoingCall"
        })
        --exports.tokovoip_script:removePlayerFromRadio(PhoneData.CallData.CallId)
        exports["mumble-voip"]:SetCallChannel(0)
    end
    PhoneData.CallData.CallType = nil
    PhoneData.CallData.InCall = false
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = {}

    if not PhoneData.isOpen then
        StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
        deletePhone()
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    else
        PhoneData.AnimationData.lib = nil
        PhoneData.AnimationData.anim = nil
    end

    TriggerServerEvent('cash-telephone:server:SetCallState', false)

    if not PhoneData.isOpen then
        SendNUIMessage({ 
            action = "Notification", 
            NotifyData = { 
                title = "Phone",
                text = "Chamada finalizada", 
                app = "telefone", 
                mtitulo = "Ligação",
            }, 
        })            
    else
        --NOTIFICACAODENTRODOCELULAR
        SendNUIMessage({ 
            action = "InsidePhoneNotify", 
            PhoneNotify = { 
                title = "Phone",
                text = "Ligação encerrada",
                app = "telefone",
                mtitulo = "Ligação",
            }, 
        })

        SendNUIMessage({
            action = "SetupHomeCall",
            CallData = PhoneData.CallData,
        })

        SendNUIMessage({
            action = "CancelOutgoingCall",
        })
    end
end)

RegisterNetEvent('cash-telephone:client:GetCalled')
AddEventHandler('cash-telephone:client:GetCalled', function(CallerNumber, CallId, AnonymousCall, fotinha)
    -- print(fotinha)
    local RepeatCount = 0
    local CallData = {
        number = CallerNumber,
        name = IsNumberInContacts(CallerNumber),
        anonymous = AnonymousCall,
        fotinha = "url('"..fotinha.."')"
    }
    -- print(CallData.fotinha)
    -- print(AnonymousCall)

    if AnonymousCall then
        CallData.name = "Desconhecido"
        CallData.number = "Desconhecido"
        CallData.fotinha = "url('https://cdn.falauniversidades.com.br/wp-content/uploads/2020/06/17122042/Anonymous.jpg')"
    end

    PhoneData.CallData.CallType = "incoming"
    PhoneData.CallData.InCall = true
    PhoneData.CallData.AnsweredCall = false
    PhoneData.CallData.TargetData = CallData
    PhoneData.CallData.CallId = CallId

    TriggerServerEvent('cash-telephone:server:SetCallState', true)

    SendNUIMessage({
        action = "SetupHomeCall",
        CallData = PhoneData.CallData,
    })

    for i = 1, Config.CallRepeats + 1, 1 do
        if not PhoneData.CallData.AnsweredCall then
            if RepeatCount + 1 ~= Config.CallRepeats + 1 then
                if PhoneData.CallData.InCall then
                    RepeatCount = RepeatCount + 1
                    TriggerEvent('InteractSound_CL:PlayOnOne', "ringing", 0.2)
                    
                    if not PhoneData.isOpen then
                        SendNUIMessage({
                            action = "IncomingCallAlert",
                            CallData = PhoneData.CallData.TargetData,
                            Canceled = false,
                            AnonymousCall = AnonymousCall,
                        })
                    end
                else
                    SendNUIMessage({
                        action = "IncomingCallAlert",
                        CallData = PhoneData.CallData.TargetData,
                        Canceled = true,
                        AnonymousCall = AnonymousCall,
                    })
                    TriggerServerEvent('cash-telephone:server:AddRecentCall', "missed", CallData)
                    break
                end
                Citizen.Wait(Config.LigandoTimeout)
            else
                SendNUIMessage({
                    action = "IncomingCallAlert",
                    CallData = PhoneData.CallData.TargetData,
                    Canceled = true,
                    AnonymousCall = AnonymousCall,
                })
                TriggerServerEvent('cash-telephone:server:AddRecentCall', "missed", CallData)
                break
            end
        else
            TriggerServerEvent('cash-telephone:server:AddRecentCall', "missed", CallData)
            break
        end
    end
end)

RegisterNUICallback('CancelOutgoingCall', function()
    CancelCall()
end)

RegisterNUICallback('DenyIncomingCall', function()
    CancelCall()
end)

RegisterNUICallback('CancelOngoingCall', function()
    CancelCall()
end)

RegisterNUICallback('AnswerCall', function()
    AnswerCall()
end)

function AnswerCall()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = "ongoing"
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

        TriggerServerEvent('cash-telephone:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        Citizen.CreateThread(function()
            while true do
                if PhoneData.CallData.AnsweredCall then
                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                    SendNUIMessage({
                        action = "UpdateCallTime",
                        Time = PhoneData.CallData.CallTime,
                        Name = PhoneData.CallData.TargetData.name,
                    })
                else
                    break
                end

                Citizen.Wait(1000)
            end
        end)

        TriggerServerEvent('cash-telephone:server:AnswerCall', PhoneData.CallData)

        --exports.tokovoip_script:addPlayerToRadio(PhoneData.CallData.CallId, 'Telephone')
        exports["mumble-voip"]:SetCallChannel(PhoneData.CallData.CallId, 'Phone')
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        --NOTIFICACAODENTRODOCELULAR
        SendNUIMessage({ 
            action = "InsidePhoneNotify", 
            PhoneNotify = { 
                title = "Phone",
                text = "Você não tem nenhuma chamada.",
                app = "telefone",
                mtitulo = "Ligação",
            }, 
        })
    end
end

RegisterNetEvent('cash-telephone:client:AnswerCall')
AddEventHandler('cash-telephone:client:AnswerCall', function()
    if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
        PhoneData.CallData.CallType = "ongoing"
        PhoneData.CallData.AnsweredCall = true
        PhoneData.CallData.CallTime = 0

        SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
        SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

        TriggerServerEvent('cash-telephone:server:SetCallState', true)

        if PhoneData.isOpen then
            DoPhoneAnimation('cellphone_text_to_call')
        else
            DoPhoneAnimation('cellphone_call_listen_base')
        end

        Citizen.CreateThread(function()
            while true do
                if PhoneData.CallData.AnsweredCall then
                    PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
                    SendNUIMessage({
                        action = "UpdateCallTime",
                        Time = PhoneData.CallData.CallTime,
                        Name = PhoneData.CallData.TargetData.name,
                    })
                else
                    break
                end

                Citizen.Wait(1000)
            end
        end)

        --exports.tokovoip_script:addPlayerToRadio(PhoneData.CallData.CallId, 'Telephone')
        exports["mumble-voip"]:SetCallChannel(PhoneData.CallData.CallId, 'Phone')
    else
        PhoneData.CallData.InCall = false
        PhoneData.CallData.CallType = nil
        PhoneData.CallData.AnsweredCall = false

        --NOTIFICACAODENTRODOCELULAR
        SendNUIMessage({ 
            action = "InsidePhoneNotify", 
            PhoneNotify = { 
                title = "Phone",
                text = "Você não tem nenhuma chamada.",
                app = "telefone",
                mtitulo = "Ligação",
            }, 
        })
    end
end)

-- AddEventHandler('onResourceStop', function(resource)
--     if resource == GetCurrentResourceName() then
--         -- SetNuiFocus(false, false)
--     end
-- end)

RegisterNUICallback('FetchSearchResults', function(data, cb)
    RebornCore.Functions.TriggerCallback('RebornPhone:FetchResult', function(result)
        cb(result)
    end, data.input)
end)

RegisterNUICallback('FetchVehicleResults', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetVehicleSearchResults', function(result)
        if result ~= nil then 
            for k, v in pairs(result) do
                RebornCore.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
                    result[k].isFlagged = flagged
                end, result[k].plate)
                Citizen.Wait(50)
            end
        end
        cb(result)
    end, data.input)
end)

RegisterNUICallback('FetchVehicleScan', function(data, cb)
    local vehicle = RebornCore.Functions.GetClosestVehicle()
    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetEntityModel(vehicle)

    RebornCore.Functions.TriggerCallback('cash-telephone:server:ScanPlate', function(result)
        RebornCore.Functions.TriggerCallback('police:IsPlateFlagged', function(flagged)
            result.isFlagged = flagged
            local vehicleInfo = RebornCore.Shared.Vehicles[RebornCore.Shared.VehicleModels[model]["model"]] ~= nil and RebornCore.Shared.Vehicles[RebornCore.Shared.VehicleModels[model]["model"]] or {["brand"] = "Brand..", ["name"] = ""}
            result.label = vehicleInfo["name"]
            cb(result)
        end, plate)
    end, plate)
end)

RegisterNetEvent('cash-phone:client:addPoliceAlert')
AddEventHandler('cash-phone:client:addPoliceAlert', function(alertData)
    if PlayerJob.name == 'police' and PlayerJob.onduty then
        SendNUIMessage({
            action = "AddPoliceAlert",
            alert = alertData,
        })
    end
end)

RegisterNetEvent('Reborn:Dispatch:SetWaypoint')
AddEventHandler('Reborn:Dispatch:SetWaypoint', function(data)
    local coords = data.alert.coords
    TriggerEvent('reborn:notify:send', "Localização","Local marcado","gps", 4000)
    SetNewWaypoint(coords.x, coords.y)
end)


RegisterNUICallback('SetAlertWaypoint', function(data)
    local coords = data.alert.coords
    TriggerEvent('reborn:notify:send', "Localização","Local marcado","gps", 4000)
    SetNewWaypoint(coords.x, coords.y)
end)


RegisterNUICallback('RemoveSuggestion', function(data, cb)
    local data = data.data

    if PhoneData.SuggestedContacts ~= nil and next(PhoneData.SuggestedContacts) ~= nil then
        for k, v in pairs(PhoneData.SuggestedContacts) do
            if (data.name[1] == v.name[1] and data.name[2] == v.name[2]) and data.number == v.number and data.bank == v.bank then
                table.remove(PhoneData.SuggestedContacts, k)
            end
        end
    end
end)

RegisterNUICallback('ClearContatosSugeridos', function(data, cb)
    local data = data.data

    if PhoneData.SuggestedContacts then
        PhoneData.SuggestedContacts = {}
    end
end)

function GetClosestPlayer()
    local closestPlayers = RebornCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(GetPlayerPed(-1))

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end

	return closestPlayer, closestDistance
end

RegisterNetEvent('cash-telephone:client:GiveContactDetails')
AddEventHandler('cash-telephone:client:GiveContactDetails', function()
    local ped = GetPlayerPed(-1)

    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local PlayerId = GetPlayerServerId(player)
        TriggerServerEvent('cash-telephone:server:GiveContactDetails', PlayerId)
    else
        -- RebornCore.Functions.Notify("No one around!", "error")
        TriggerEvent('reborn:notify:send', "Sistema","Ninguém próximo a você","error", 3000)
    end
end)

-- Citizen.CreateThread(function()
--     Wait(1000)
--     TriggerServerEvent('cash-telephone:server:GiveContactDetails', 1)
-- end)

RegisterNUICallback('DeleteContact', function(data, cb)
    local Name = data.CurrentContactName
    local Number = data.CurrentContactNumber
    local Account = data.CurrentContactIban

    for k, v in pairs(PhoneData.Contacts) do
        if v.name == Name and v.number == Number then
            table.remove(PhoneData.Contacts, k)
            if PhoneData.isOpen then
                
                --NOTIFICACAODENTRODOCELULAR
                SendNUIMessage({
                    action = "InsidePhoneNotify",
                    PhoneNotify = {
                        title = "Phone",
                        text = "Contato deletado",
                        app = "telefone",
                        mtitulo = "Contato",
                    },
                })
            else
                
                --NOTIFICACAODENTRODOCELULAR
                SendNUIMessage({
                    action = "InsidePhoneNotify",
                    NotifyData = {
                        title = "Phone",
                        text = "Contato deletado",
                        app = "telefone",
                        mtitulo = "Contato",
                    },
                })
            end
            break
        end
    end
    Citizen.Wait(100)
    cb(PhoneData.Contacts)
    if PhoneData.Chats[Number] ~= nil and next(PhoneData.Chats[Number]) ~= nil then
        PhoneData.Chats[Number].name = Number
    end
    TriggerServerEvent('cash-telephone:server:RemoveContact', Name, Number)
end)

RegisterNetEvent('cash-telephone:client:AddNewSuggestion')
AddEventHandler('cash-telephone:client:AddNewSuggestion', function(SuggestionData)
    table.insert(PhoneData.SuggestedContacts, SuggestionData)

    if PhoneData.isOpen then
        
        --NOTIFICACAODENTRODOCELULAR
        SendNUIMessage({
            action = "InsidePhoneNotify",
            PhoneNotify = {
                title = "Phone",
                text = "Você tem uma sugestão de Contato",
                app = "telefone",
                mtitulo = "Sugestão",
            },
        })
    else
        
        --NOTIFICACAODENTRODOCELULAR
        -- SendNUIMessage({
        --     action = "Notification",
        --     NotifyData = {
        --         title = "Phone",
        --         text = "Você tem uma sugestão de Contato",
        --         app = "telefone",
        --         mtitulo = "Sugestão",
        --     },
        -- })
    end

    Config.PhoneApplications["phone"].Alerts = Config.PhoneApplications["phone"].Alerts + 1
    TriggerServerEvent('cash-phone:server:SetPhoneAlerts', "phone", Config.PhoneApplications["phone"].Alerts)
end)

RegisterNUICallback('GetCryptoData', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-bitcoins:server:GetCryptoData', function(CryptoData)
        cb(CryptoData)
    end, data.crypto)
end)

RegisterNUICallback('BuyCrypto', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-bitcoins:server:BuyCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('SellCrypto', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-bitcoins:server:SellCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNUICallback('TransferCrypto', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-bitcoins:server:TransferCrypto', function(CryptoData)
        cb(CryptoData)
    end, data)
end)

RegisterNetEvent('cash-telephone:client:RemoveBankMoney')
AddEventHandler('cash-telephone:client:RemoveBankMoney', function(amount)
    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Bank",
                text = "$<strong>"..amount.."</strong> debitado do seu banco.", 
                app = "banco", 
                mtitulo = "Banco",
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Bank",
                text = "$<strong>"..amount.."</strong> debitado do seu banco.", 
                app = "banco",
                mtitulo = "Banco",
            },
        })
    end
end)

RegisterNetEvent('cash-telephone:client:AddTransaction')
AddEventHandler('cash-telephone:client:AddTransaction', function(SenderData, TransactionData, Message, Title)
    local Data = {
        TransactionTitle = Title,
        TransactionMessage = Message,
    }
    
    table.insert(PhoneData.CryptoTransactions, Data)

    if PhoneData.isOpen then
        SendNUIMessage({
            action = "PhoneNotification",
            PhoneNotify = {
                title = "Crypto",
                text = Message, 
                icon = "fas fa-chart-pie",
                color = "#04b543",
                timeout = 1500,
            },
        })
    else
        SendNUIMessage({
            action = "Notification",
            NotifyData = {
                title = "Crypto",
                content = Message, 
                icon = "fas fa-chart-pie",
                timeout = 3500, 
                color = "#04b543",
            },
        })
    end

    SendNUIMessage({
        action = "UpdateTransactions",
        CryptoTransactions = PhoneData.CryptoTransactions
    })

    TriggerServerEvent('cash-telephone:server:AddTransaction', Data)
end)

RegisterNUICallback('GetCryptoTransactions', function(data, cb)
    local Data = {
        CryptoTransactions = PhoneData.CryptoTransactions
    }
    cb(Data)
end)

RegisterNUICallback('GetAvailableRaces', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-racingsystem:server:GetRaces', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('JoinRace', function(data)
    TriggerServerEvent('cash-racingsystem:server:JoinRace', data.RaceData)
end)

RegisterNUICallback('LeaveRace', function(data)
    TriggerServerEvent('cash-racingsystem:server:LeaveRace', data.RaceData)
end)

RegisterNUICallback('StartRace', function(data)
    TriggerServerEvent('cash-racingsystem:server:StartRace', data.RaceData.RaceId)
end)

RegisterNetEvent('cash-telephone:client:UpdateLapraces')
AddEventHandler('cash-telephone:client:UpdateLapraces', function()
    SendNUIMessage({
        action = "UpdateRacingApp",
    })
end)

RegisterNUICallback('GetRaces', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-racingsystem:server:GetListedRaces', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('GetTrackData', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-racingsystem:server:GetTrackData', function(TrackData, CreatorData)
        TrackData.CreatorData = CreatorData
        cb(TrackData)
    end, data.RaceId)
end)

RegisterNUICallback('SetupRace', function(data, cb)
    TriggerServerEvent('cash-racingsystem:server:SetupRace', data.RaceId, tonumber(data.AmountOfLaps))
end)

RegisterNUICallback('HasCreatedRace', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-racingsystem:server:HasCreatedRace', function(HasCreated)
        cb(HasCreated)
    end)
end)

RegisterNUICallback('IsInRace', function(data, cb)
    local InRace = exports['reborn_racing']:IsInRace()
    cb(InRace)
end)

RegisterNUICallback('IsAuthorizedToCreateRaces', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-racingsystem:server:IsAuthorizedToCreateRaces', function(IsAuthorized, NameAvailable)
        local data = {
            IsAuthorized = IsAuthorized,
            IsBusy = exports['reborn_racing']:IsInEditor(),
            IsNameAvailable = NameAvailable,
        }
        cb(data)
    end, data.TrackName)
end)

RegisterNUICallback('StartTrackEditor', function(data, cb)
    TriggerServerEvent('cash-racingsystem:server:CreateLapRace', data.TrackName)
end)

RegisterNUICallback('GetRacingLeaderboards', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-racingsystem:server:GetRacingLeaderboards', function(Races)
        cb(Races)
    end)
end)

RegisterNUICallback('RaceDistanceCheck', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-racingsystem:server:GetRacingData', function(RaceData)
        local ped = GetPlayerPed(-1)
        local coords = GetEntityCoords(ped)
        local checkpointcoords = RaceData.Checkpoints[1].coords
        local dist = GetDistanceBetweenCoords(coords, checkpointcoords.x, checkpointcoords.y, checkpointcoords.z, true)
        if dist <= 115.0 then
            if data.Joined then
                TriggerEvent('cash-racingsystem:client:WaitingDistanceCheck')
            end
            cb(true)
        else
            -- RebornCore.Functions.Notify('You are too far from the race. Your navigation is set to the race.', 'error', 5000)
            TriggerEvent('reborn:notify:send', "Sistema","Você está muito longe da corrida. Sua navegação está configurada para a corrida. ","error", 3000)
            SetNewWaypoint(checkpointcoords.x, checkpointcoords.y)
            cb(false)
        end
    end, data.RaceId)
end)

RegisterNUICallback('IsBusyCheck', function(data, cb)
    if data.check == "editor" then
        cb(exports['reborn_racing']:IsInEditor())
    else
        cb(exports['reborn_racing']:IsInRace())
    end
end)

RegisterNUICallback('CanRaceSetup', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-racingsystem:server:CanRaceSetup', function(CanSetup)
        cb(CanSetup)
    end)
end)

RegisterNUICallback('GetPlayerHouses', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetPlayerHouses', function(Houses)
        cb(Houses)
    end)
end)

RegisterNUICallback('RemoveKeyholder', function(data)
    TriggerServerEvent('cash-playerhousing:server:removeHouseKey', data.HouseData.name, {
        citizenid = data.HolderData.citizenid,
        firstname = data.HolderData.charinfo.firstname,
        lastname = data.HolderData.charinfo.lastname,
    })
end)

RegisterNUICallback('FetchPlayerHouses', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-telephone:server:MeosGetPlayerHouses', function(result)
        cb(result)
    end, data.input)
end)

RegisterNUICallback('SetGPSLocation', function(data, cb)
    local ped = GetPlayerPed(-1)

    SetNewWaypoint(data.coords.x, data.coords.y)
    -- RebornCore.Functions.Notify('GPS is set!', 'success')
    TriggerEvent('reborn:notify:send', "Sistema","GPS Marcado","sucesso", 3000)

end)

RegisterNUICallback('SetApartmentLocation', function(data, cb)
    local ApartmentData = data.data.appartmentdata
    local TypeData = Apartments.Locations[ApartmentData.type]

    SetNewWaypoint(TypeData.coords.enter.x, TypeData.coords.enter.y)
    -- RebornCore.Functions.Notify('GPS is set!', 'success')
    TriggerEvent('reborn:notify:send', "Sistema","GPS Marcado","sucesso", 3000)
end)

RegisterNUICallback('GetCurrentLawyers', function(data, cb)
    RebornCore.Functions.TriggerCallback('cash-telephone:server:GetCurrentLawyers', function(lawyers)
        cb(lawyers)
    end)
end)

RegisterNUICallback('GruposTrabalhosAtuais', function(data, cb)
    local grupoatual = "trabalho aleatório"
    -- cb(grupoatual)
end)

RegisterNUICallback('AbrirCamera', function(data, cb)
    -- print('cheguei aqui no client abrircamera')
    TriggerEvent('reborn:camera:phone')
end)


RegisterNUICallback('reborn:CriarGrupo', function()
    print('client: client enviando solicitação para o servidor')
    TriggerServerEvent('reborn:create:grupo:trabalho')
end)

-- RegisterCommand('addgrupo',function(source,args,rawCommand)
--     local jogador = PlayerPedId()
--     TriggerServerEvent("reborn:add:membro:trabalho",args[1],args[2])
-- end)

-- RegisterCommand('delgrupo',function(source,args,rawCommand)
--     local jogador = PlayerPedId()
--     TriggerServerEvent("reborn:delete:grupo:trabalho")
-- end)

-- RegisterCommand('entrarqueue',function(source,args,rawCommand)
--     local jogador = PlayerPedId()
--     TriggerServerEvent("reborn:create:grupo:recebendotrabalho")
-- end)


RegisterNetEvent('reborn:create:grupo:client')
AddEventHandler('reborn:create:grupo:client', function(condicao,nome,cargo,idgrupo)
    print('client: criando grupo e buildando a tela')
    SendNUIMessage({
        condicao = condicao,
        nome = nome,
        cargo = cargo,
        idgrupo = idgrupo
    })
end)

RegisterNetEvent('reborn:add:grupo:membro:client')
AddEventHandler('reborn:add:grupo:membro:client', function(slot,nome,cargo)
    SendNUIMessage({
        adicionando = true,
        slot = slot,
        mnome = nome,
        mcargo = cargo
    })
    print('client: adicionando membro')
end)


------- CAMERA PHONE


phone = false
phoneId = 0

local function chatMessage(msg)
	TriggerEvent('chatMessage', '', {0, 0, 0}, msg)
end

phones = {
	[0] = "Michael's",
	[1] = "Trevor's",
	[2] = "Franklin's",
	[4] = "Prologue"
}

RegisterNetEvent('camera:phone')
AddEventHandler('camera:phone', function(message)		
	print(' ')
end)

function ChangePhone(flag)
	if flag == 0 or flag == 1 or flag == 2 or flag == 4 then
		phoneId = flag
		--chatMessage("^2Changed phone to "..phones[flag].." phone")
	end
end

frontCam = false

function CellFrontCamActivate(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

-- RemoveLoadingPrompt()

TakePhoto = N_0xa67c35c56eb1bd9d
WasPhotoTaken = N_0x0d6ca79eeebd8ca3
SavePhoto = N_0x3dec726c25a11bac
ClearPhoto = N_0xd801cc02177fa3f1


RegisterNetEvent('reborn:camera:phone')
AddEventHandler('reborn:camera:phone', function()		
	CreateMobilePhone(phoneId)
	CellCamActivate(true, true)
	phone = true
end)


Citizen.CreateThread(function()
DestroyMobilePhone()
	while true do
		Citizen.Wait(0)
		
		if IsControlJustPressed(0, 27) and phone == true then -- SELFIE MODE
			frontCam = not frontCam
			CellFrontCamActivate(frontCam)
		end
		
		if IsControlJustPressed(0, 27) then -- OPEN PHONE
			CreateMobilePhone(phoneId)
			CellCamActivate(true, true)
			phone = true
		end
		
		if IsControlJustPressed(0, 177) and phone == true then -- CLOSE PHONE
			DestroyMobilePhone()
			phone = false
			CellCamActivate(false, false)
			if firstTime == true then 
				firstTime = false 
				Citizen.Wait(2500)
				displayDoneMission = true
			end
		end
		
		if IsControlJustPressed(0, 176) and phone == true then -- TAKE.. PIC
			TakePhoto()
			if (WasPhotoTaken() and SavePhoto(-1)) then
				-- SetLoadingPromptTextEntry("CELL_278")
				-- ShowLoadingPrompt(1)
				ClearPhoto()
			end
		end
			
		if phone == true then
			HideHudComponentThisFrame(7)
			HideHudComponentThisFrame(8)
			HideHudComponentThisFrame(9)
			HideHudComponentThisFrame(6)
			HideHudComponentThisFrame(19)
			HideHudAndRadarThisFrame()
		end
			
		-- ren = GetMobilePhoneRenderId()
		-- SetTextRenderId(ren)
		
		-- Everything rendered inside here will appear on your phone.
		
		-- SetTextRenderId(1) -- NOTE: 1 is default
	end
end)