RebornCore = nil
TriggerEvent('RebornCore:GetObject', function(obj) RebornCore = obj end)

-- Code

local RebornPhone = {}
local Tweets = {}
local AppAlerts = {}
local MentionedTweets = {}
local Hashtags = {}
local Calls = {}
local Adverts = {}
local GeneratedPlates = {}
local TrabalhoGrupos = {}
local idStartAdvert = 2500000

RegisterServerEvent('reborn-phone:server:novoanuncio')
AddEventHandler('reborn-phone:server:novoanuncio', function(msg)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    local CitizenId = Player.PlayerData.citizenid

    if idStartAdvert then
        idStartAdvert = idStartAdvert-1
        Adverts[idStartAdvert] = {
            message = msg,
            name = "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname,
            number = Player.PlayerData.charinfo.phone,
        }
        TriggerClientEvent('reborn-phone:client:updateanuncio', -1, Adverts, "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname)
    end
end)

-- CODIGO SUCATA
    -- local GenerateAdID = #Adverts
    -- local NewId = GenerateAdID+1

    -- if Adverts[CitizenId] ~= nil then
    --     Adverts[CitizenId].message = msg
    --     Adverts[CitizenId].name = "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname
    --     Adverts[CitizenId].number = Player.PlayerData.charinfo.phone
    -- else
    --     Adverts[CitizenId] = {
    --         message = msg,
    --         name = "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname,
    --         number = Player.PlayerData.charinfo.phone,
    --     }
    -- end
    -- print('colocando anuncio na tela')
    -- Adverts[#Adverts+1] = {
    --     message = msg,
    --     name = "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname,
    --     number = Player.PlayerData.charinfo.phone,
    -- }

    -- TriggerClientEvent('cash-telephone:client:UpdateAdverts', -1, Adverts, "@"..Player.PlayerData.charinfo.firstname..""..Player.PlayerData.charinfo.lastname)
--
function GetOnlineStatus(number)
    local Target = RebornCore.Functions.GetPlayerByPhone(number)
    local retval = false
    if Target ~= nil then retval = true end
    return retval
end

RebornCore.Functions.CreateCallback('cash-telephone:server:GetPhoneData', function(source, cb)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    if Player ~= nil then
        local PhoneData = {
            Applications = {},
            PlayerContacts = {},
            MentionedTweets = {},
            Chats = {},
            Hashtags = {},
            Invoices = {},
            Garage = {},
            Mails = {},
            Adverts = {},
            CryptoTransactions = {},
            Tweets = {},
            Faturas = {}
        }

        PhoneData.Adverts = Adverts

        -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM player_contacts WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' ORDER BY `name` ASC", function(result)
        local result = exports.ghmattimysql:executeSync('SELECT * FROM player_contacts WHERE citizenid=@citizenid ORDER BY name ASC', {['@citizenid'] = Player.PlayerData.citizenid})
        local Contacts = {}
        if result[1] ~= nil then
            for k, v in pairs(result) do
                v.status = GetOnlineStatus(v.number)
            end
            
            PhoneData.PlayerContacts = result
        end

        -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM phone_invoices WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' ORDER BY `id` DESC", function(invoices)
        local invoices = exports.ghmattimysql:executeSync('SELECT * FROM phone_invoices WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid})
        if invoices[1] ~= nil then
            for k, v in pairs(invoices) do
                local Ply = RebornCore.Functions.GetPlayerByCitizenId(v.sender)
                if Ply ~= nil then
                    v.number = Ply.PlayerData.charinfo.phone
                else
                    -- RebornCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.sender.."'", function(res)
                    local res = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE citizenid=@citizenid', {['@citizenid'] = v.sender})
                    if res[1] ~= nil then
                        res[1].charinfo = json.decode(res[1].charinfo)
                        v.number = res[1].charinfo.phone
                    else
                        v.number = nil
                    end
                    -- end)
                end
            end
            PhoneData.Invoices = invoices
        end
            
            -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM player_vehicles WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(garageresult)
            local garageresult = exports.ghmattimysql:executeSync('SELECT * FROM player_vehicles WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid})
            if garageresult[1] ~= nil then
                -- for k, v in pairs(garageresult) do
                --     if (RebornCore.Shared.Vehicles[v.vehicle] ~= nil) and (Garages[v.garage] ~= nil) then
                --         v.garage = Garages[v.garage].label
                --         v.vehicle = RebornCore.Shared.Vehicles[v.vehicle].name
                --         v.brand = RebornCore.Shared.Vehicles[v.vehicle].brand
                --     end
                -- end

                PhoneData.Garage = garageresult
            end
            
            -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM phone_messages WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(messages)
            local messages = exports.ghmattimysql:executeSync('SELECT * FROM phone_messages WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid})
            if messages ~= nil and next(messages) ~= nil then 
                PhoneData.Chats = messages
            end

            if AppAlerts[Player.PlayerData.citizenid] ~= nil then 
                PhoneData.Applications = AppAlerts[Player.PlayerData.citizenid]
            end

            if MentionedTweets[Player.PlayerData.citizenid] ~= nil then 
                PhoneData.MentionedTweets = MentionedTweets[Player.PlayerData.citizenid]
            end

            if Hashtags ~= nil and next(Hashtags) ~= nil then
                PhoneData.Hashtags = Hashtags
            end

            if Tweets ~= nil and next(Tweets) ~= nil then
                PhoneData.Tweets = Tweets
            end

            -- RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC LIMIT 50', function(mails)
            local mails = exports.ghmattimysql:executeSync('SELECT * FROM player_mails WHERE citizenid=@citizenid ORDER BY `date` ASC', {['@citizenid'] = Player.PlayerData.citizenid})
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
                PhoneData.Mails = mails
            end

            -- RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `crypto_transactions` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(transactions)
            local transactions = exports.ghmattimysql:executeSync('SELECT * FROM crypto_transactions WHERE citizenid=@citizenid ORDER BY `date` ASC', {['@citizenid'] = Player.PlayerData.citizenid})
            if transactions[1] ~= nil then
                for _, v in pairs(transactions) do
                    table.insert(PhoneData.CryptoTransactions, {
                        TransactionTitle = v.title,
                        TransactionMessage = v.message,
                    })
                end
            end

            -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM reborn_faturas WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' ORDER BY `idfatura` DESC LIMIT 50" , function(faturas)
            local faturas = exports.ghmattimysql:executeSync('SELECT * FROM reborn_faturas WHERE citizenid=@citizenid ORDER BY `idfatura` DESC LIMIT 50', {['@citizenid'] = Player.PlayerData.citizenid})
            if faturas[1] ~= nil then

                PhoneData.Faturas = faturas
            end
            cb(PhoneData)
            -- end)
            -- end)
            -- end)
            -- end)
            -- end)
        -- end)
        -- end)
    end
end)




RebornCore.Functions.CreateCallback('cash-telephone:server:GetCallState', function(source, cb, ContactData)
    local Target = RebornCore.Functions.GetPlayerByPhone(ContactData.number)
    if Target ~= nil then
        if Calls[Target.PlayerData.citizenid] ~= nil then
            if Calls[Target.PlayerData.citizenid].inCall then
                cb(false, true)
            else
                cb(true, true)
            end
        else
            cb(true, true)
        end
    else
        cb(false, false)
    end
end)

RegisterServerEvent('cash-telephone:server:SetCallState')
AddEventHandler('cash-telephone:server:SetCallState', function(bool)
    local src = source
    local Ply = RebornCore.Functions.GetPlayer(src)

    if Calls[Ply.PlayerData.citizenid] ~= nil then
        Calls[Ply.PlayerData.citizenid].inCall = bool
    else
        Calls[Ply.PlayerData.citizenid] = {}
        Calls[Ply.PlayerData.citizenid].inCall = bool
    end
end)

RegisterServerEvent('cash-telephone:server:RemoveMail')
AddEventHandler('cash-telephone:server:RemoveMail', function(MailId)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    RebornCore.Functions.ExecuteSql(false, 'DELETE FROM `player_mails` WHERE `mailid` = "'..MailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
    SetTimeout(100, function()
        RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` ASC', function(mails)
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('cash-telephone:client:UpdateMails', src, mails)
        end)
    end)
end)

function GenerateMailId()
    return math.random(111111, 999999)
end

RegisterServerEvent('cash-phone:server:sendNewMail')
AddEventHandler('cash-phone:server:sendNewMail', function(mailData)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    if mailData.button == nil then
        exports.ghmattimysql:execute('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (@citizenid, @sender, @subject, @message, @mailid, @read)', {
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@sender'] = mailData.sender,
            ['@subject'] = mailData.subject,
            ['@message'] = mailData.message,
            ['@mailid'] = GenerateMailId(),
            ['@read'] = 0
        })
    else
        exports.ghmattimysql:execute('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (@citizenid, @sender, @subject, @message, @mailid, @read, @button)', {
            ['@citizenid'] = Player.PlayerData.citizenid,
            ['@sender'] = mailData.sender,
            ['@subject'] = mailData.subject,
            ['@message'] = mailData.message,
            ['@mailid'] = GenerateMailId(),
            ['@read'] = 0,
            ['@button'] = json.encode(mailData.button)
        })
    end
    
    TriggerClientEvent('cash-telephone:client:NewMailNotify', src, mailData)
    SetTimeout(200, function()
        -- RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
        local mails = exports.ghmattimysql:executeSync('SELECT * FROM player_mails WHERE citizenid=@citizenid ORDER BY `date` DESC', {['@citizenid'] = Player.PlayerData.citizenid})
        if mails[1] ~= nil then
            for k, v in pairs(mails) do
                if mails[k].button ~= nil then
                    mails[k].button = json.decode(mails[k].button)
                end
            end
        end

        TriggerClientEvent('cash-telephone:client:UpdateMails', src, mails)
        -- end)
    end)
end)

RegisterServerEvent('cash-phone:server:sendNewMailToOffline')
AddEventHandler('cash-phone:server:sendNewMailToOffline', function(citizenid, mailData)
    local Player = RebornCore.Functions.GetPlayerByCitizenId(citizenid)

    if Player ~= nil then
        local src = Player.PlayerData.source

        if mailData.button == nil then
            exports.ghmattimysql:execute('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (@citizenid, @sender, @subject, @message, @mailid, @read)', {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@sender'] = mailData.sender,
                ['@subject'] = mailData.subject,
                ['@message'] = mailData.message,
                ['@mailid'] = GenerateMailId(),
                ['@read'] = 0
            })
            TriggerClientEvent('cash-telephone:client:NewMailNotify', src, mailData)
        else
            exports.ghmattimysql:execute('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (@citizenid, @sender, @subject, @message, @mailid, @read, @button)', {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@sender'] = mailData.sender,
                ['@subject'] = mailData.subject,
                ['@message'] = mailData.message,
                ['@mailid'] = GenerateMailId(),
                ['@read'] = 0,
                ['@button'] = json.encode(mailData.button)
            })
            TriggerClientEvent('cash-telephone:client:NewMailNotify', src, mailData)
        end

        SetTimeout(200, function()
            -- RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
            local mails = exports.ghmattimysql:executeSync('SELECT * FROM player_mails WHERE citizenid=@citizenid ORDER BY `date` ASC', {['@citizenid'] = Player.PlayerData.citizenid})
            if mails[1] ~= nil then
                for k, v in pairs(mails) do
                    if mails[k].button ~= nil then
                        mails[k].button = json.decode(mails[k].button)
                    end
                end
            end
    
            TriggerClientEvent('cash-telephone:client:UpdateMails', src, mails)
            -- end)
        end)
    else
        if mailData.button == nil then
            -- RebornCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0')")
            exports.ghmattimysql:execute('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (@citizenid, @sender, @subject, @message, @mailid, @read)', {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@sender'] = mailData.sender,
                ['@subject'] = mailData.subject,
                ['@message'] = mailData.message,
                ['@mailid'] = GenerateMailId(),
                ['@read'] = 0
            })
        else
            -- RebornCore.Functions.ExecuteSql(false, "INSERT INTO `player_mails` (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES ('"..citizenid.."', '"..mailData.sender.."', '"..mailData.subject.."', '"..mailData.message.."', '"..GenerateMailId().."', '0', '"..json.encode(mailData.button).."')")
            exports.ghmattimysql:execute('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (@citizenid, @sender, @subject, @message, @mailid, @read, @button)', {
                ['@citizenid'] = Player.PlayerData.citizenid,
                ['@sender'] = mailData.sender,
                ['@subject'] = mailData.subject,
                ['@message'] = mailData.message,
                ['@mailid'] = GenerateMailId(),
                ['@read'] = 0,
                ['@button'] = json.encode(mailData.button)
            })
        end
    end
end)

RegisterServerEvent('cash-phone:server:sendNewEventMail')
AddEventHandler('cash-phone:server:sendNewEventMail', function(citizenid, mailData)
    if mailData.button == nil then
        exports.ghmattimysql:execute('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`) VALUES (@citizenid, @sender, @subject, @message, @mailid, @read)', {
            ['@citizenid'] = citizenid,
            ['@sender'] = mailData.sender,
            ['@subject'] = mailData.subject,
            ['@message'] = mailData.message,
            ['@mailid'] = GenerateMailId(),
            ['@read'] = 0
        })
    else
        exports.ghmattimysql:execute('INSERT INTO player_mails (`citizenid`, `sender`, `subject`, `message`, `mailid`, `read`, `button`) VALUES (@citizenid, @sender, @subject, @message, @mailid, @read, @button)', {
            ['@citizenid'] = citizenid,
            ['@sender'] = mailData.sender,
            ['@subject'] = mailData.subject,
            ['@message'] = mailData.message,
            ['@mailid'] = GenerateMailId(),
            ['@read'] = 0,
            ['@button'] = json.encode(mailData.button)
        })
    end
    SetTimeout(200, function()
        -- RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
        local mails = exports.ghmattimysql:executeSync('SELECT * FROM player_mails WHERE citizenid=@citizenid ORDER BY `date` ASC', {['@citizenid'] = citizenid})
        if mails[1] ~= nil then
            for k, v in pairs(mails) do
                if mails[k].button ~= nil then
                    mails[k].button = json.decode(mails[k].button)
                end
            end
        end

        TriggerClientEvent('cash-telephone:client:UpdateMails', src, mails)
        -- end)
    end)
end)

RegisterServerEvent('cash-telephone:server:ClearButtonData')
AddEventHandler('cash-telephone:server:ClearButtonData', function(mailId)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    -- RebornCore.Functions.ExecuteSql(false, 'UPDATE `player_mails` SET `button` = "" WHERE `mailid` = "'..mailId..'" AND `citizenid` = "'..Player.PlayerData.citizenid..'"')
    exports.ghmattimysql:execute('UPDATE player_mails SET button=@button WHERE mailid=@mailid AND citizenid=@citizenid', {['@button'] = '', ['@mailid'] = mailId, ['@citizenid'] = Player.PlayerData.citizenid})

    SetTimeout(200, function()
        -- RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_mails` WHERE `citizenid` = "'..Player.PlayerData.citizenid..'" ORDER BY `date` DESC', function(mails)
        local mails = exports.ghmattimysql:executeSync('SELECT * FROM player_mails WHERE citizenid=@citizenid ORDER BY `date` ASC', {['@citizenid'] = Player.PlayerData.citizenid})
        if mails[1] ~= nil then
            for k, v in pairs(mails) do
                if mails[k].button ~= nil then
                    mails[k].button = json.decode(mails[k].button)
                end
            end
        end

        TriggerClientEvent('cash-telephone:client:UpdateMails', src, mails)
        -- end)
    end)
end)

RegisterServerEvent('cash-telephone:server:MentionedPlayer')
AddEventHandler('cash-telephone:server:MentionedPlayer', function(firstName, lastName, TweetMessage)
    for k, v in pairs(RebornCore.Functions.GetPlayers()) do
        local Player = RebornCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.charinfo.firstname == firstName and Player.PlayerData.charinfo.lastname == lastName) then
                RebornPhone.SetPhoneAlerts(Player.PlayerData.citizenid, "twitter")
                RebornPhone.AddMentionedTweet(Player.PlayerData.citizenid, TweetMessage)
                TriggerClientEvent('cash-telephone:client:GetMentioned', Player.PlayerData.source, TweetMessage, AppAlerts[Player.PlayerData.citizenid]["twitter"])
            else
                -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..firstName.."%' AND `charinfo` LIKE '%"..lastName.."%'", function(result)
                local query1 = '%'..firstName..'%'
                local query2 = '%'..lastName..'%'
                local result = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE charinfo LIKE @query1 AND charinfo LIKE @query2', {['@query1'] = query1, ['@query2'] = query2})
                if result[1] ~= nil then
                    local MentionedTarget = result[1].citizenid
                    RebornPhone.SetPhoneAlerts(MentionedTarget, "twitter")
                    RebornPhone.AddMentionedTweet(MentionedTarget, TweetMessage)
                end
                -- end)
            end
        end
	end
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


RegisterServerEvent('cash-telephone:server:CallContact')
AddEventHandler('cash-telephone:server:CallContact', function(TargetData, CallId, AnonymousCall)
    local src = source
    local Ply = RebornCore.Functions.GetPlayer(src)
    local Target = RebornCore.Functions.GetPlayerByPhone(TargetData.number)

    if Target ~= nil then
        local contato = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE charinfo=@charinfo', {['@charinfo'] = Ply.PlayerData.charinfo.phone})
        if contato[1] ~= nil then
            local MetaData = json.decode(contato[1].metadata)

            if MetaData.phone.profilepicture ~= nil then
                Fotinha = MetaData.phone.profilepicture
            else
                Fotinha = "default"
            end

        else
            return
        end
        TriggerClientEvent('qb-phone:client:GetCalled', Target.PlayerData.source, Ply.PlayerData.charinfo.phone, CallId, AnonymousCall, Fotinha)
    end
end)


-- RegisterServerEvent('cash-telephone:server:CallContact')
-- AddEventHandler('cash-telephone:server:CallContact', function(TargetData, CallId, AnonymousCall)
--     local src = source
--     local Ply = RebornCore.Functions.GetPlayer(src)
--     local Target = RebornCore.Functions.GetPlayerByPhone(TargetData.number)
--     local Fotinha = nil
--     if Target ~= nil then
--         RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..Ply.PlayerData.charinfo.phone.."%'", function(result)
--             if result[1] ~= nil then
--                 local MetaData = json.decode(result[1].metadata)

--                 if MetaData.phone.profilepicture ~= nil then
--                     Fotinha = MetaData.phone.profilepicture
--                 else
--                     Fotinha = "default"
--                 end
--                 TriggerClientEvent('cash-telephone:client:GetCalled', Target.PlayerData.source, Ply.PlayerData.charinfo.phone, CallId, AnonymousCall, Fotinha)
--             else
--                 return
--             end
--         end)
--     end
-- end)

RebornCore.Functions.CreateCallback('cash-telephone:server:PayInvoice', function(source, cb, sender, amount, invoiceId)
    local src = source
    local Ply = RebornCore.Functions.GetPlayer(src)
    local Trgt = RebornCore.Functions.GetPlayerByCitizenId(sender)
    local Invoices = {}

    if Trgt ~= nil then
        if Ply.PlayerData.money.bank >= amount then
            Ply.Functions.RemoveMoney('bank', amount, "paid-invoice")
            Trgt.Functions.AddMoney('bank', amount, "paid-invoice")

            -- RebornCore.Functions.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `invoiceid` = '"..invoiceId.."'")
            exports.ghmattimysql:execute('DELETE FROM phone_invoices WHERE invoiceid=@invoiceid', {['@invoiceid'] = invoiceId})
            -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `phone_invoices` WHERE `citizenid` = '"..Ply.PlayerData.citizenid.."'", function(invoices)
            local invoices = exports.ghmattimysql:executeSync('SELECT * FROM phone_invoices WHERE citizenid=@citizenid', {['@citizenid'] = Ply.PlayerData.citizenid})
            if invoices[1] ~= nil then
                Invoices = invoices
            end
            cb(true, Invoices)
            -- end)
        else
            cb(false)
        end
    end
end)


-- RebornCore.Functions.CreateCallback('cash-telephone:server:DeclineInvoice', function(source, cb, sender, amount, invoiceId)
--     local src = source
--     local Ply = RebornCore.Functions.GetPlayer(src)
--     local Trgt = RebornCore.Functions.GetPlayerByCitizenId(sender)
--     local Invoices = {}
--     -- checkpoint
--     RebornCore.Functions.ExecuteSql(true, "DELETE FROM `phone_invoices` WHERE `invoiceid` = '"..invoiceId.."'")
--     RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `phone_invoices` WHERE `citizenid` = '"..Ply.PlayerData.citizenid.."'", function(invoices)
--         if invoices[1] ~= nil then
--             for k, v in pairs(invoices) do
--                 local Target = RebornCore.Functions.GetPlayerByCitizenId(v.sender)
--                 if Target ~= nil then
--                     v.number = Target.PlayerData.charinfo.phone
--                 else
--                     RebornCore.Functions.ExecuteSql(true, "SELECT * FROM `players` WHERE `citizenid` = '"..v.sender.."'", function(res)
--                         if res[1] ~= nil then
--                             res[1].charinfo = json.decode(res[1].charinfo)
--                             v.number = res[1].charinfo.phone
--                         else
--                             v.number = nil
--                         end
--                     end)
--                 end
--             end
--             Invoices = invoices
--         end
--         cb(true, invoices)
--     end)
-- end)

RegisterServerEvent('cash-telephone:server:UpdateHashtags')
AddEventHandler('cash-telephone:server:UpdateHashtags', function(Handle, messageData)
    if Hashtags[Handle] ~= nil and next(Hashtags[Handle]) ~= nil then
        table.insert(Hashtags[Handle].messages, messageData)
    else
        Hashtags[Handle] = {
            hashtag = Handle,
            messages = {}
        }
        table.insert(Hashtags[Handle].messages, messageData)
    end
    TriggerClientEvent('cash-telephone:client:UpdateHashtags', -1, Handle, messageData)
end)

RebornPhone.AddMentionedTweet = function(citizenid, TweetData)
    if MentionedTweets[citizenid] == nil then MentionedTweets[citizenid] = {} end
    table.insert(MentionedTweets[citizenid], TweetData)
end

RebornPhone.SetPhoneAlerts = function(citizenid, app, alerts)
    if citizenid ~= nil and app ~= nil then
        if AppAlerts[citizenid] == nil then
            AppAlerts[citizenid] = {}
            if AppAlerts[citizenid][app] == nil then
                if alerts == nil then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = alerts
                end
            end
        else
            if AppAlerts[citizenid][app] == nil then
                if alerts == nil then
                    AppAlerts[citizenid][app] = 1
                else
                    AppAlerts[citizenid][app] = 0
                end
            else
                if alerts == nil then
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 1
                else
                    AppAlerts[citizenid][app] = AppAlerts[citizenid][app] + 0
                end
            end
        end
    end
end

RebornCore.Functions.CreateCallback('cash-telephone:server:GetContactPictures', function(source, cb, Chats)
    for k, v in pairs(Chats) do
        local Player = RebornCore.Functions.GetPlayerByPhone(v.number)
        
        -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..v.number.."%'", function(result)
        local query = '%'..v.number..'%'
        local result = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE charinfo LIKE @query', {['@query'] = query})
        if result[1] ~= nil then
            local MetaData = json.decode(result[1].metadata)

            if MetaData.phone.profilepicture ~= nil then
                v.picture = MetaData.phone.profilepicture
            else
                v.picture = "default"
            end
        end
        -- end)
    end
    SetTimeout(100, function()
        cb(Chats)
    end)
end)

RebornCore.Functions.CreateCallback('cash-telephone:server:GetContactPicture', function(source, cb, Chat)
    local Player = RebornCore.Functions.GetPlayerByPhone(Chat.number)
    -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..Chat.number.."%'", function(result)
    local query = '%'..Chat.number..'%'
    local result = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE charinfo LIKE @query', {['@query'] = query})
    if result[1] ~= nil then
        local MetaData = json.decode(result[1].metadata)
        if MetaData.phone.profilepicture ~= nil then
            Chat.picture = MetaData.phone.profilepicture
        else
            Chat.picture = "default"
        end
    end
    -- end)
    SetTimeout(100, function()
        cb(Chat)
    end)
end)

RebornCore.Functions.CreateCallback('cash-telephone:server:GetPicture', function(source, cb, number)
    local Player = RebornCore.Functions.GetPlayerByPhone(number)
    local Picture = nil

    -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..number.."%'", function(result)
    local query = '%'..number..'%'
    local result = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE charinfo LIKE @query', {['@query'] = query})
    if result[1] ~= nil then
        local MetaData = json.decode(result[1].metadata)

        if MetaData.phone.profilepicture ~= nil then
            Picture = MetaData.phone.profilepicture
        else
            Picture = "default"
        end
        cb(Picture)
    else
        cb(nil)
    end
    -- end)
end)

RegisterServerEvent('cash-phone:server:SetPhoneAlerts')
AddEventHandler('cash-phone:server:SetPhoneAlerts', function(app, alerts)
    local src = source
    local CitizenId = RebornCore.Functions.GetPlayer(src).citizenid
    RebornPhone.SetPhoneAlerts(CitizenId, app, alerts)
end)

RegisterServerEvent('cash-telephone:server:UpdateTweets')
AddEventHandler('cash-telephone:server:UpdateTweets', function(NewTweets, TweetData)
    Tweets = NewTweets
    local TwtData = TweetData
    local src = source
    TriggerClientEvent('cash-telephone:client:UpdateTweets', -1, src, Tweets, TwtData)
end)

RegisterServerEvent('cash-telephone:server:TransferMoney')
AddEventHandler('cash-telephone:server:TransferMoney', function(iban, amount)
    local src = source
    local sender = RebornCore.Functions.GetPlayer(src)

    -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..iban.."%'", function(result)
    local query = '%'..iban..'%'
    local result = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE charinfo LIKE @query', {['@query'] = query})
    if result[1] ~= nil then
        local recieverSteam = RebornCore.Functions.GetPlayerByCitizenId(result[1].citizenid)

        if recieverSteam ~= nil then
            local PhoneItem = recieverSteam.Functions.GetItemByName("phone")
            recieverSteam.Functions.AddMoney('bank', amount, "phone-transfered-from-"..sender.PlayerData.citizenid)
            sender.Functions.RemoveMoney('bank', amount, "phone-transfered-to-"..recieverSteam.PlayerData.citizenid)

            if PhoneItem ~= nil then
                TriggerClientEvent('cash-telephone:client:TransferMoney', recieverSteam.PlayerData.source, amount, recieverSteam.PlayerData.money.bank)
            end
            -- print(recieverSteam.PlayerData.citizenid)
            TriggerEvent('reborn:historico:add',recieverSteam.PlayerData.citizenid,amount,"Transferencia","Transferencia Recebida","1")
            TriggerEvent('reborn:historico:add',sender.PlayerData.citizenid,amount,"Transferencia","Transferencia Enviada","2")
            Wait(500)
            TriggerClientEvent('reborn:update:banco:historico', recieverSteam.PlayerData.source)
            TriggerClientEvent('reborn:update:banco:historico', src)
        else
            local moneyInfo = json.decode(result[1].money)
            moneyInfo.bank = moneyInfo.bank + amount
            -- RebornCore.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(moneyInfo).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
            exports.ghmattimysql:execute('UPDATE players SET money=@money WHERE citizenid=@citizenid', {['@money'] = json.encode(moneyInfo), ['@citizenid'] = result[1].citizenid})
            sender.Functions.RemoveMoney('bank', amount, "phone-transfered")
            TriggerEvent('reborn:historico:add',result[1].citizenid,amount,"Transferencia","Transferencia Recebida","1")
            TriggerEvent('reborn:historico:add',sender.PlayerData.citizenid,amount,"Transferencia","Transferencia Enviada","2")
            Wait(500)
            TriggerClientEvent('reborn:update:banco:historico', src)
        end
    else
        TriggerClientEvent('RebornCore:Notify', src, "This account number does not exist!", "error")
    end
    -- end)
end)

RegisterServerEvent('cash-telephone:server:EditContact')
AddEventHandler('cash-telephone:server:EditContact', function(newName, newNumber, newIban, oldName, oldNumber, oldIban)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    -- RebornCore.Functions.ExecuteSql(false, "UPDATE `player_contacts` SET `name` = '"..newName.."', `number` = '"..newNumber.."', `iban` = '"..newIban.."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `name` = '"..oldName.."' AND `number` = '"..oldNumber.."'")

    exports.ghmattimysql:execute('UPDATE player_contacts SET name=@newname, number=@newnumber, iban=@newiban WHERE citizenid=@citizenid AND name=@oldname AND number=@oldnumber', {
        ['@newname'] = newName,
        ['@newnumber'] = newNumber,
        ['@newiban'] = newIban,
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@oldname'] = oldName,
        ['@oldnumber'] = oldNumber
    })

end)

RegisterServerEvent('cash-telephone:server:RemoveContact')
AddEventHandler('cash-telephone:server:RemoveContact', function(Name, Number)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    
    -- RebornCore.Functions.ExecuteSql(false, "DELETE FROM `player_contacts` WHERE `name` = '"..Name.."' AND `number` = '"..Number.."' AND `citizenid` = '"..Player.PlayerData.citizenid.."'")
    
    exports.ghmattimysql:execute('DELETE FROM player_contacts WHERE name=@name AND number=@number AND citizenid=@citizenid', {
        ['@name'] = Name,
        ['@number'] = Number,
        ['@citizenid'] = Player.PlayerData.citizenid
    })
end)

RegisterServerEvent('cash-telephone:server:AddNewContact')
AddEventHandler('cash-telephone:server:AddNewContact', function(name, number, iban)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    -- RebornCore.Functions.ExecuteSql(false, "INSERT INTO `player_contacts` (`citizenid`, `name`, `number`, `iban`) VALUES ('"..Player.PlayerData.citizenid.."', '"..tostring(name).."', '"..tostring(number).."', '"..tostring(iban).."')")
    exports.ghmattimysql:execute('INSERT INTO player_contacts (citizenid, name, number, iban) VALUES (@citizenid, @name, @number, @iban)', {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@name'] = tostring(name),
        ['@number'] = tostring(number),
        ['@iban'] = tostring(iban)
    })
end)

RegisterServerEvent('cash-telephone:server:UpdateMessages')
AddEventHandler('cash-telephone:server:UpdateMessages', function(ChatMessages, ChatNumber, New)
    local src = source
    local SenderData = RebornCore.Functions.GetPlayer(src)

    -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `charinfo` LIKE '%"..ChatNumber.."%'", function(Player)
    local query = '%'..ChatNumber..'%'
    local Player = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE charinfo LIKE @query', {['@query'] = query})
    if Player[1] ~= nil then
        local TargetData = RebornCore.Functions.GetPlayerByCitizenId(Player[1].citizenid)

        if TargetData ~= nil then
            RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `phone_messages` WHERE `citizenid` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..ChatNumber.."'", function(Chat)
                if Chat[1] ~= nil then
                     -- Update for target
                     exports.ghmattimysql:execute('UPDATE phone_messages SET messages=@messages WHERE citizenid=@citizenid AND number=@number', {
                        ['@messages'] = json.encode(ChatMessages), 
                        ['@citizenid'] = TargetData.PlayerData.citizenid,
                        ['@number'] = SenderData.PlayerData.charinfo.phone
                    })
                            
                    -- Update for sender
                    exports.ghmattimysql:execute('UPDATE phone_messages SET messages=@messages WHERE citizenid=@citizenid AND number=@number', {
                        ['@messages'] = json.encode(ChatMessages), 
                        ['@citizenid'] = SenderData.PlayerData.citizenid,
                        ['@number'] = TargetData.PlayerData.charinfo.phone
                    })
                
                    -- Send notification & Update messages for target
                    TriggerClientEvent('cash-telephone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, false)
                else

                    exports.ghmattimysql:execute('INSERT INTO phone_messages (citizenid, number, messages) VALUES (@citizenid, @number, @messages)', {
                        ['@citizenid'] = TargetData.PlayerData.citizenid, 
                        ['@number'] = SenderData.PlayerData.charinfo.phone,
                        ['@messages'] = json.encode(ChatMessages)
                    })
                                        
                    -- Insert for sender
                    exports.ghmattimysql:execute('INSERT INTO phone_messages (citizenid, number, messages) VALUES (@citizenid, @number, @messages)', {
                        ['@citizenid'] = SenderData.PlayerData.citizenid, 
                        ['@number'] = TargetData.PlayerData.charinfo.phone,
                        ['@messages'] = json.encode(ChatMessages)
                    })
                    
                    -- Send notification & Update messages for target
                    TriggerClientEvent('cash-telephone:client:UpdateMessages', TargetData.PlayerData.source, ChatMessages, SenderData.PlayerData.charinfo.phone, true)
                    TriggerClientEvent("reborn-hud:naolidas", TargetData.PlayerData.source, true)
                end
            end)
        else
            RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `phone_messages` WHERE `citizenid` = '"..SenderData.PlayerData.citizenid.."' AND `number` = '"..ChatNumber.."'", function(Chat)
                if Chat[1] ~= nil then
                    -- Update for target
                    exports.ghmattimysql:execute('UPDATE phone_messages SET messages=@messages WHERE citizenid=@citizenid AND number=@number', {
                        ['@messages'] = json.encode(ChatMessages), 
                        ['@citizenid'] = Player[1].citizenid,
                        ['@number'] = SenderData.PlayerData.charinfo.phone
                    })
                    -- Update for sender
                    Player[1].charinfo = json.decode(Player[1].charinfo)
                    exports.ghmattimysql:execute('UPDATE phone_messages SET messages=@messages WHERE citizenid=@citizenid AND number=@number', {
                        ['@messages'] = json.encode(ChatMessages), 
                        ['@citizenid'] = SenderData.PlayerData.citizenid,
                        ['@number'] = Player[1].charinfo.phone
                    })
                else
                    -- Insert for target
                    exports.ghmattimysql:execute('INSERT INTO phone_messages (citizenid, number, messages) VALUES (@citizenid, @number, @messages)', {
                        ['@citizenid'] = Player[1].citizenid, 
                        ['@number'] = SenderData.PlayerData.charinfo.phone,
                        ['@messages'] = json.encode(ChatMessages)
                    })
                    
                    -- Insert for sender
                    Player[1].charinfo = json.decode(Player[1].charinfo)
                    exports.ghmattimysql:execute('INSERT INTO phone_messages (citizenid, number, messages) VALUES (@citizenid, @number, @messages)', {
                        ['@citizenid'] = SenderData.PlayerData.citizenid, 
                        ['@number'] = Player[1].charinfo.phone,
                        ['@messages'] = json.encode(ChatMessages)
                    })
                end
            end)
        end
    end
    -- end)
end)

RegisterServerEvent('cash-telephone:server:AddRecentCall')
AddEventHandler('cash-telephone:server:AddRecentCall', function(type, data)
    local src = source
    local Ply = RebornCore.Functions.GetPlayer(src)

    local Hour = os.date("%H")
    local Minute = os.date("%M")
    local label = Hour..":"..Minute

    TriggerClientEvent('cash-telephone:client:AddRecentCall', src, data, label, type)

    local Trgt = RebornCore.Functions.GetPlayerByPhone(data.number)
    if Trgt ~= nil then
        TriggerClientEvent('cash-telephone:client:AddRecentCall', Trgt.PlayerData.source, {
            name = Ply.PlayerData.charinfo.firstname .. " " ..Ply.PlayerData.charinfo.lastname,
            number = Ply.PlayerData.charinfo.phone,
            anonymous = anonymous
        }, label, "outgoing")
    end
end)

RegisterServerEvent('cash-telephone:server:CancelCall')
AddEventHandler('cash-telephone:server:CancelCall', function(ContactData)
    local Ply = RebornCore.Functions.GetPlayerByPhone(ContactData.TargetData.number)

    if Ply ~= nil then
        TriggerClientEvent('cash-telephone:client:CancelCall', Ply.PlayerData.source)
    end
end)

RegisterServerEvent('cash-telephone:server:AnswerCall')
AddEventHandler('cash-telephone:server:AnswerCall', function(CallData)
    local Ply = RebornCore.Functions.GetPlayerByPhone(CallData.TargetData.number)

    if Ply ~= nil then
        TriggerClientEvent('cash-telephone:client:AnswerCall', Ply.PlayerData.source)
    end
end)

RegisterServerEvent('cash-telephone:server:SaveMetaData')
AddEventHandler('cash-telephone:server:SaveMetaData', function(MData)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
    local result = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid})
    local MetaData = json.decode(result[1].metadata)
    MetaData.phone = MData
    exports.ghmattimysql:execute('UPDATE players SET metadata=@metadata WHERE citizenid=@citizenid', {['@metadata'] = json.encode(MetaData), ['@citizenid'] = Player.PlayerData.citizenid})
    -- RebornCore.Functions.ExecuteSql(false, "UPDATE `players` SET `metadata` = '"..json.encode(MetaData).."' WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'")
    -- end)

    Player.Functions.SetMetaData("phone", MData)
end)

function escape_sqli(source)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return source:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end

function SplitStringToArray(string)
    local retval = {}
    for i in string.gmatch(string, "%S+") do
        table.insert(retval, i)
    end
    return retval
end

RebornCore.Functions.CreateCallback('RebornPhone:FetchResult', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    local ApaData = {}

    local query = 'SELECT * FROM `players` WHERE `citizenid` = "'..search..'"'
    -- Split on " " and check each var individual
    local searchParameters = SplitStringToArray(search)
    
    -- Construct query dynamicly for individual parm check
    if #searchParameters > 1 then
        query = query .. ' OR `charinfo` LIKE "%'..searchParameters[1]..'%"'
        for i = 2, #searchParameters do
            query = query .. ' AND `charinfo` LIKE  "%' .. searchParameters[i] ..'%"'
        end
    else
        query = query .. ' OR `charinfo` LIKE "%'..search..'%"'
    end
    
    local ApartmentData = exports.ghmattimysql:executeSync('SELECT * FROM apartments')
    for k, v in pairs(ApartmentData) do
        ApaData[v.citizenid] = ApartmentData[k]
    end

    local result = exports.ghmattimysql:executeSync(query)
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local charinfo = json.decode(v.charinfo)
            local metadata = json.decode(v.metadata)
            local appiepappie = {}
            if ApaData[v.citizenid] ~= nil and next(ApaData[v.citizenid]) ~= nil then
                appiepappie = ApaData[v.citizenid]
            end
            table.insert(searchData, {
                citizenid = v.citizenid,
                firstname = charinfo.firstname,
                lastname = charinfo.lastname,
                birthdate = charinfo.birthdate,
                phone = charinfo.phone,
                nationality = charinfo.nationality,
                gender = charinfo.gender,
                warrant = false,
                driverlicense = metadata["licences"]["driver"],
                appartmentdata = appiepappie,
            })
        end
        cb(searchData)
    else
        cb(nil)
    end
end)



-- RebornCore.Functions.CreateCallback('cash-telephone:server:FetchResult', function(source, cb, search)
--     local src = source
--     local search = escape_sqli(search)
--     local searchData = {}
--     local ApaData = {}
--     RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `players` WHERE `citizenid` = "'..search..'" OR `charinfo` LIKE "%'..search..'%"', function(result)
--         RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `apartments`', function(ApartmentData)
--             for k, v in pairs(ApartmentData) do
--                 ApaData[v.citizenid] = ApartmentData[k]
--             end

--             if result[1] ~= nil then
--                 for k, v in pairs(result) do
--                     local charinfo = json.decode(v.charinfo)
--                     local metadata = json.decode(v.metadata)
--                     local appiepappie = {}
--                     if ApaData[v.citizenid] ~= nil and next(ApaData[v.citizenid]) ~= nil then
--                         appiepappie = ApaData[v.citizenid]
--                     end
--                     table.insert(searchData, {
--                         citizenid = v.citizenid,
--                         firstname = charinfo.firstname,
--                         lastname = charinfo.lastname,
--                         birthdate = charinfo.birthdate,
--                         phone = charinfo.phone,
--                         nationality = charinfo.nationality,
--                         gender = charinfo.gender,
--                         warrant = false,
--                         driverlicense = metadata["licences"]["driver"],
--                         appartmentdata = appiepappie,
--                     })
--                 end
--                 cb(searchData)
--             else
--                 cb(nil)
--             end
--         end)
--     end)
-- end)

RebornCore.Functions.CreateCallback('cash-telephone:server:GetVehicleSearchResults', function(source, cb, search)
    local src = source
    local search = escape_sqli(search)
    local searchData = {}
    -- RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_vehicles` WHERE `plate` LIKE "%'..search..'%" OR `citizenid` = "'..search..'"', function(result)
    local query = '%'..search..'%'
    local result = exports.ghmattimysql:executeSync('SELECT * FROM player_vehicles WHERE plate LIKE @query OR citizenid=@citizenid', {['@query'] = query, ['@citizenid'] = search})
    if result[1] ~= nil then
        for k, v in pairs(result) do
            -- RebornCore.Functions.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[k].citizenid..'"', function(player)
            local player = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE citizenid=@citizenid', {['@citizenid'] = result[k].citizenid})
            if player[1] ~= nil then 
                local charinfo = json.decode(player[1].charinfo)
                local vehicleInfo = RebornCore.Shared.Vehicles[result[k].vehicle]
                if vehicleInfo ~= nil then 
                    table.insert(searchData, {
                        plate = result[k].plate,
                        status = true,
                        owner = charinfo.firstname .. " " .. charinfo.lastname,
                        citizenid = result[k].citizenid,
                        label = vehicleInfo["name"]
                    })
                else
                    table.insert(searchData, {
                        plate = result[k].plate,
                        status = true,
                        owner = charinfo.firstname .. " " .. charinfo.lastname,
                        citizenid = result[k].citizenid,
                        label = "Name not found.."
                    })
                end
            end
            -- end)
        end
    else
        if GeneratedPlates[search] ~= nil then
            table.insert(searchData, {
                plate = GeneratedPlates[search].plate,
                status = GeneratedPlates[search].status,
                owner = GeneratedPlates[search].owner,
                citizenid = GeneratedPlates[search].citizenid,
                label = "Brand unknown.."
            })
        else
            local ownerInfo = GenerateOwnerName()
            GeneratedPlates[search] = {
                plate = search,
                status = true,
                owner = ownerInfo.name,
                citizenid = ownerInfo.citizenid,
            }
            table.insert(searchData, {
                plate = search,
                status = true,
                owner = ownerInfo.name,
                citizenid = ownerInfo.citizenid,
                label = "Brand unknown.."
            })
        end
    end
    cb(searchData)
    -- end)
end)

RebornCore.Functions.CreateCallback('cash-telephone:server:ScanPlate', function(source, cb, plate)
    local src = source
    local vehicleData = {}
    if plate ~= nil then 
        -- RebornCore.Functions.ExecuteSql(false, 'SELECT * FROM `player_vehicles` WHERE `plate` = "'..plate..'"', function(result)
        local result = exports.ghmattimysql:executeSync('SELECT * FROM player_vehicles WHERE plate=@plate', {['@plate'] = plate})
        if result[1] ~= nil then
            -- RebornCore.Functions.ExecuteSql(true, 'SELECT * FROM `players` WHERE `citizenid` = "'..result[1].citizenid..'"', function(player)
            local player = exports.ghmattimysql:executeSync('SELECT * FROM players WHERE citizenid=@citizenid', {['@citizenid'] = result[1].citizenid})
            local charinfo = json.decode(player[1].charinfo)
            vehicleData = {
                plate = plate,
                status = true,
                owner = charinfo.firstname .. " " .. charinfo.lastname,
                citizenid = result[1].citizenid,
            }
            -- end)
        elseif GeneratedPlates ~= nil and GeneratedPlates[plate] ~= nil then 
            vehicleData = GeneratedPlates[plate]
        else
            local ownerInfo = GenerateOwnerName()
            GeneratedPlates[plate] = {
                plate = plate,
                status = true,
                owner = ownerInfo.name,
                citizenid = ownerInfo.citizenid,
            }
            vehicleData = {
                plate = plate,
                status = true,
                owner = ownerInfo.name,
                citizenid = ownerInfo.citizenid,
            }
        end
        cb(vehicleData)
        -- end)
    else
        TriggerClientEvent('RebornCore:Notify', src, "No vehicle around..", "error")
        cb(nil)
    end
end)

function GenerateOwnerName()
    local names = {
        [1] = { name = "Jan Bloksteen", citizenid = "DSH091G93" },
        [2] = { name = "Jay Dendam", citizenid = "AVH09M193" },
        [3] = { name = "Ben Klaariskees", citizenid = "DVH091T93" },
        [4] = { name = "Karel Bakker", citizenid = "GZP091G93" },
        [5] = { name = "Klaas Adriaan", citizenid = "DRH09Z193" },
        [6] = { name = "Nico Wolters", citizenid = "KGV091J93" },
        [7] = { name = "Mark Hendrickx", citizenid = "ODF09S193" },
        [8] = { name = "Bert Johannes", citizenid = "KSD0919H3" },
        [9] = { name = "Karel de Grote", citizenid = "NDX091D93" },
        [10] = { name = "Jan Pieter", citizenid = "ZAL0919X3" },
        [11] = { name = "Huig Roelink", citizenid = "ZAK09D193" },
        [12] = { name = "Corneel Boerselman", citizenid = "POL09F193" },
        [13] = { name = "Hermen Klein Overmeen", citizenid = "TEW0J9193" },
        [14] = { name = "Bart Rielink", citizenid = "YOO09H193" },
        [15] = { name = "Antoon Henselijn", citizenid = "QBC091H93" },
        [16] = { name = "Aad Keizer", citizenid = "YDN091H93" },
        [17] = { name = "Thijn Kiel", citizenid = "PJD09D193" },
        [18] = { name = "Henkie Krikhaar", citizenid = "RND091D93" },
        [19] = { name = "Teun Blaauwkamp", citizenid = "QWE091A93" },
        [20] = { name = "Dries Stielstra", citizenid = "KJH0919M3" },
        [21] = { name = "Karlijn Hensbergen", citizenid = "ZXC09D193" },
        [22] = { name = "Aafke van Daalen", citizenid = "XYZ0919C3" },
        [23] = { name = "Door Leeferds", citizenid = "ZYX0919F3" },
        [24] = { name = "Nelleke Broedersen", citizenid = "IOP091O93" },
        [25] = { name = "Renske de Raaf", citizenid = "PIO091R93" },
        [26] = { name = "Krisje Moltman", citizenid = "LEK091X93" },
        [27] = { name = "Mirre Steevens", citizenid = "ALG091Y93" },
        [28] = { name = "Joosje Kalvenhaar", citizenid = "YUR09E193" },
        [29] = { name = "Mirte Ellenbroek", citizenid = "SOM091W93" },
        [30] = { name = "Marlieke Meilink", citizenid = "KAS09193" },
    }
    return names[math.random(1, #names)]
end

RebornCore.Functions.CreateCallback('cash-telephone:server:GetGarageVehicles', function(source, cb)
    local Player = RebornCore.Functions.GetPlayer(source)
    local Vehicles = {}

    -- RebornCore.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
    local result = exports.ghmattimysql:executeSync('SELECT * FROM player_vehicles WHERE citizenid=@citizenid', {['@citizenid'] = Player.PlayerData.citizenid})
    if result[1] ~= nil then
        for k, v in pairs(result) do
            local VehicleData = RebornCore.Shared.Vehicles[v.vehicle]

            local VehicleGarage = "None"
            if v.garage ~= nil then
                if Garages[v.garage] ~= nil then
                    VehicleGarage = Garages[v.garage]["label"]
                end
            end

            local VehicleState = "In"
            if v.state == 0 then
                VehicleState = "Out"
            elseif v.state == 2 then
                VehicleState = "In Impound"
            end

            local vehdata = {}

            if VehicleData["brand"] ~= nil then
                vehdata = {
                    fullname = VehicleData["brand"] .. " " .. VehicleData["name"],
                    brand = VehicleData["brand"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body,
                }
            else
                vehdata = {
                    fullname = VehicleData["name"],
                    brand = VehicleData["name"],
                    model = VehicleData["name"],
                    plate = v.plate,
                    garage = VehicleGarage,
                    state = VehicleState,
                    fuel = v.fuel,
                    engine = v.engine,
                    body = v.body,
                }
            end

            table.insert(Vehicles, vehdata)
        end
        cb(Vehicles)
    else
        cb(nil)
    end
    -- end)
end)

RebornCore.Functions.CreateCallback('cash-telephone:server:HasPhone', function(source, cb)
    local Player = RebornCore.Functions.GetPlayer(source)
    
    if Player ~= nil then
        local HasPhone = Player.Functions.GetItemByName("phone")
        local retval = false

        if HasPhone ~= nil then
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterServerEvent('cash-telephone:server:GiveContactDetails')
AddEventHandler('cash-telephone:server:GiveContactDetails', function(PlayerId)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    local SuggestionData = {
        name = {
            [1] = Player.PlayerData.charinfo.firstname,
            [2] = Player.PlayerData.charinfo.lastname
        },
        number = Player.PlayerData.charinfo.phone,
        bank = Player.PlayerData.charinfo.account
    }

    TriggerClientEvent('cash-telephone:client:AddNewSuggestion', PlayerId, SuggestionData)
end)

RegisterServerEvent('cash-telephone:server:AddTransaction')
AddEventHandler('cash-telephone:server:AddTransaction', function(data)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    exports.ghmattimysql:execute('INSERT INTO crypto_transactions (citizenid, title, message) VALUES (@citizenid, @title, @message)', {
        ['@citizenid'] = Player.PlayerData.citizenid, 
        ['@title'] = escape_sqli(data.TransactionTitle),
        ['@message'] = escape_sqli(data.TransactionMessage)
    })
end)

RebornCore.Functions.CreateCallback('cash-telephone:server:GetCurrentLawyers', function(source, cb)
    local Lawyers = {}
    for k, v in pairs(RebornCore.Functions.GetPlayers()) do
        local Player = RebornCore.Functions.GetPlayer(v)
        if Player ~= nil then
            if Player.PlayerData.job.name == "lawyer" then
                table.insert(Lawyers, {
                    name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
                    phone = Player.PlayerData.charinfo.phone,
                })
            end
        end
    end
    cb(Lawyers)
end)

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


local group_tasks = {}

RegisterServerEvent('reborn:create:grupo:recebendotrabalho')
AddEventHandler('reborn:create:grupo:recebendotrabalho', function()
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)

    print('entrei no task awaiting')
    local tempodeespera = math.random(30000,90000)
    print(tempodeespera)
    Citizen.Wait(tempodeespera)
    print('encontrou trabalho e enviou')

    TriggerClientEvent('RebornCore:Notify', src, "Encontramos um trabalho pra voce, cheque no seu GPS e siga as Instruições no Celular. ", "success")
    print('chegou onde eu buildo os dados do trabalho')
end)

--[[

local src = source
	local Player = RebornCore.Functions.GetPlayer(src)
	
	if Player ~= nil then
		Player.PlayerData.position = data.position

		local newHunger = Player.PlayerData.metadata["hunger"] - 4.2
		local newThirst = Player.PlayerData.metadata["thirst"] - 3.8
		if newHunger <= 0 then newHunger = 0 end
		if newThirst <= 0 then newThirst = 0 end
		Player.Functions.SetMetaData("thirst", newThirst)
		Player.Functions.SetMetaData("hunger", newHunger)
--
		Player.Functions.AddMoney("bank", Player.PlayerData.job.payment)
		TriggerClientEvent('RebornCore:Notify', src, "You received your payslip of $" ..Player.PlayerData.job.payment .." from the government")
		--TriggerEvent('rplay-basic:notification', src,"success","You received your payslip of"..Player.PlayerData.job.payment.." from the government",3000)
		TriggerClientEvent("hud:client:UpdateNeeds", src, newHunger, newThirst)

		Player.Functions.Save()
	end

]]

RegisterServerEvent('reborn:create:grupo:trabalho')
AddEventHandler('reborn:create:grupo:trabalho', function()
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    local LiderGrupo = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname

    RebornCore.Functions.ExecuteSql(false, "INSERT INTO `reborn_tasks` (`lider`, `queue`) VALUES ('"..Player.PlayerData.citizenid.."', 'sim')")

    print('server: server recebendo solicitação do client')
    TriggerClientEvent("reborn:create:grupo:client", source,true,LiderGrupo,"Lider de Grupo")
end)

RegisterServerEvent('reborn:add:membro:trabalho')
AddEventHandler('reborn:add:membro:trabalho', function(idplayer,rgplayer)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    local Jogador = RebornCore.Functions.GetPlayerByCitizenId(rgplayer)
    if Jogador ~= nil then
        local NomeMembro = Jogador.PlayerData.charinfo.firstname.." "..Jogador.PlayerData.charinfo.lastname
        local NomeLider = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname    
        RebornCore.Functions.ExecuteSql(true, "SELECT * FROM `reborn_tasks` WHERE `lider` = '"..Player.PlayerData.citizenid.."'", function(res)
            if res[1] ~= nil then
                if res[1].slot1  == "" and res[1].slot1 ~= rgplayer then
                    RebornCore.Functions.ExecuteSql(true, "UPDATE `reborn_tasks` SET `slot1` = '"..rgplayer.."' WHERE `lider` = '"..Player.PlayerData.citizenid.."'")
                    TriggerClientEvent('reborn:add:grupo:membro:client',src,"1",NomeMembro,"Membro")
                    TriggerClientEvent('RebornCore:Notify', idplayer, "Você agora faz parte do grupo de "..NomeLider, "success")
                elseif res[1].slot2 == "" and res[1].slot1 ~= rgplayer then
                    RebornCore.Functions.ExecuteSql(true, "UPDATE `reborn_tasks` SET `slot2` = '"..rgplayer.."' WHERE `lider` = '"..Player.PlayerData.citizenid.."'")
                    TriggerClientEvent('reborn:add:grupo:membro:client',src,"2",NomeMembro,"Membro")
                    TriggerClientEvent('RebornCore:Notify', idplayer, "Você agora faz parte do grupo de "..NomeLider, "success")
                elseif res[1].slot3 == "" and res[1].slot1 ~= rgplayer and res[1].slot2 ~= rgplayer then
                    RebornCore.Functions.ExecuteSql(true, "UPDATE `reborn_tasks` SET `slot3` = '"..rgplayer.."' WHERE `lider` = '"..Player.PlayerData.citizenid.."'")
                    TriggerClientEvent('reborn:add:grupo:membro:client',src,"3",NomeMembro,"Membro")
                    TriggerClientEvent('RebornCore:Notify', idplayer, "Você agora faz parte do grupo de "..NomeLider, "success")
                else
                    print('esta pessoa ja esta no seu grupo ou seu grupo esta cheio')
                end
            else
            print("nil?")
            end
        end)
    else
        print('Jogador esta offline')
    end

    print('server: adicionando membro ao grupo')
end)

RegisterServerEvent('reborn:update:grupo:queue')
AddEventHandler('reborn:update:grupo:queue', function(status)
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    if status == "sim" then 
        RebornCore.Functions.ExecuteSql(true, "SELECT * FROM `reborn_tasks` WHERE `lider` = '"..Player.PlayerData.citizenid.."'", function(res)
            if res[1] ~= nil then
                if res[1].lider == Player.PlayerData.citizenid and res[1].slot1 ~= "" then
                    if res[1].queue == "" then
                        RebornCore.Functions.ExecuteSql(true, "UPDATE `reborn_tasks` SET `queue` = 'sim' WHERE `lider` = '"..Player.PlayerData.citizenid.."'")
                        Player.Functions.SetJob("robberyqueue")
                    end
                end
            end
        end)
    elseif status == "nao" then 
        RebornCore.Functions.ExecuteSql(true, "SELECT * FROM `reborn_tasks` WHERE `lider` = '"..Player.PlayerData.citizenid.."'", function(res)
            if res[1] ~= nil then
                if res[1].lider == Player.PlayerData.citizenid then
                    if res[1].queue == "sim" then
                        RebornCore.Functions.ExecuteSql(true, "UPDATE `reborn_tasks` SET `queue` = 'nao' WHERE `lider` = '"..Player.PlayerData.citizenid.."'")
                        Player.Functions.SetJob("unemployed")
                    end
                end
            end
        end)
    end
end)


RegisterServerEvent('reborn:delete:grupo:trabalho')
AddEventHandler('reborn:delete:grupo:trabalho', function()
    local src = source
    local Player = RebornCore.Functions.GetPlayer(src)
    RebornCore.Functions.ExecuteSql(true, "DELETE FROM `reborn_tasks` WHERE `lider` = '"..Player.PlayerData.citizenid.."'")
end)


-- RebornCore.Commands.Add("camera", "Open admin menu", {{name="valor", help="valor do historico"},{name="titulo", help="Titulo do Historico"},{name="descricao", help="descrição do historico"},{name="tipo", help="[1] para valor recebido e [2] para valor pago"}}, false, function(source, args)
--     local src = source
--     TriggerClientEvent('camera:phone', src, 1)
-- end, "admin")


RegisterServerEvent('reborn:historico:add')
AddEventHandler('reborn:historico:add', function(citizenid,fvalor,ftitulo,fdescricao,ftipo)
    -- local src = source
    -- local Player = RebornCore.Functions.GetPlayer(src)

    local date_table = os.date("*t")
    local ms = string.match(tostring(os.clock()), "%d%.(%d+)")
    local hour, minute, second = date_table.hour, date_table.min, date_table.sec
    local year, month, day = date_table.year, date_table.month, date_table.day
    -- local dataatual = string.format("%d/%d %d:%d", day, month, hour, minute)
    -- print()
    if  day < 10 then
        day = '0'..day
    end
    -- print(day)
    if  month < 10 then
        month = '0'..month
    end
    if  hour < 10 then
        hour = '0'..hour
    end
    if  minute < 10 then
        minute = '0'..minute
    end

    exports.ghmattimysql:execute('INSERT INTO reborn_faturas (citizenid, valor, titulo, descricao, data, hora, tipo) VALUES (@citizenid, @valor, @titulo, @descricao, @data, @hora, @tipo)', {
        ['@citizenid'] = citizenid,
        ['@valor'] = fvalor,
        ['@titulo'] = ftitulo,
        ['@descricao'] = fdescricao,
        ['@data'] = day..'/'..month,
        ['@hora'] = hour..':'..minute,
        ['@tipo'] = ftipo,
    })

end)