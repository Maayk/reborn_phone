M.AutoInit();
Reborn = {}
Reborn.Phone = {}
Reborn.Screen = {}
Reborn.Phone.Functions = {}
Reborn.Phone.Animations = {}
Reborn.Phone.Notifications = {}
var idstartnoti = 2500000;
Reborn.Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

Reborn.Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
}

$(document).ready(function(){
    $('.materialboxed').materialbox();
});



OpenedChatData = {
    number: null,
}

var CanOpenApp = true;

function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob && Reborn.Phone.Data.PlayerData.job.onduty) {
                retval = true;
            }
        });
    }
    return retval;
}

Reborn.Phone.Functions.SetupApplications = function(data) {
    $(".phone-footer").css({"display":"none"});
    Reborn.Phone.Data.Applications = data.applications;
    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, Reborn.Phone.Data.PlayerJob.name)
        $(applicationSlot).html("");
        $(applicationSlot).css({"background-color":"transparent"});
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        if (app.tooltipPos !== undefined) {
            $(applicationSlot).removeData('placement')
        }
        
        if ((!app.job || app.job === Reborn.Phone.Data.PlayerJob.name) && !blockedapp) {
            // $(applicationSlot).css({"background-color":app.color});

            var icon = '<img src="./img/'+app.icon+'.png" class="app-icones">';
            // if (app.app == "meos") {
            //     icon = '<img src="./img/policia.png" class="app-icones">';
            // }

            // waves-effect waves-light
            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div><span class="phone-app-nome">'+app.nome+'</span>');
            $(applicationSlot).prop('title', app.tooltipText);
            
            $(applicationSlot).data('app', app.app);
           

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

Reborn.Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');
        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

Reborn.Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
        }
    });
    return retval;
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (Reborn.Phone.Data.currentApplication == null) {
                Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                Reborn.Phone.Functions.ToggleApp(PressedApplication, "block");
                
                if (Reborn.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    Reborn.Phone.Functions.HeaderTextColor("black", 300);
                }
    
                Reborn.Phone.Data.currentApplication = PressedApplication;
    
                if (PressedApplication == "settings") {
                    $("#phone-time").css({'color':'black'});
                    $("#phone-icons").css({'color':'black'});
                    $("#myPhoneNumber").text(Reborn.Phone.Data.PlayerData.charinfo.phone)
                    $(".profile-phone-nome").text(Reborn.Phone.Data.PlayerData.charinfo.firstname+' '+Reborn.Phone.Data.PlayerData.charinfo.lastname)
                    $("#myRGNumber").text(Reborn.Phone.Data.PlayerData.citizenid)
                    $("#myJob").text(Reborn.Phone.Data.PlayerData.job.label)
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "twitter") {
                    $("#phone-time").css({'color':'black'});
                    $("#phone-icons").css({ 'color': 'black' });
                    $(".twitter-tab-avatar").css({"background-image":"url('"+Reborn.Phone.Data.MetaData.profilepicture+"')"})
                    $.post('http://reborn_phone/GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
                        Reborn.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
                    })
                    $.post('http://reborn_phone/GetHashtags', JSON.stringify({}), function(Hashtags){
                        Reborn.Phone.Notifications.LoadHashtags(Hashtags)
                    })
                    if (Reborn.Phone.Data.IsOpen) {
                        $.post('http://reborn_phone/GetTweets', JSON.stringify({}), function(Tweets){
                            Reborn.Phone.Notifications.LoadTweets(Tweets);
                        });
                    }
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "bank") {
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                    Reborn.Phone.Functions.DoBankOpen();
                    $.post('http://reborn_phone/GetBankContacts', JSON.stringify({}), function(contacts){
                        Reborn.Phone.Functions.LoadContactsWithNumber(contacts);
                    });
                    $.post('http://reborn_phone/GetInvoices', JSON.stringify({}), function(invoices){
                        Reborn.Phone.Functions.LoadBankInvoices(invoices);
                    });
                    $.post('http://reborn_phone/LoadandoFaturas', JSON.stringify({}), function(faturas){
                        Reborn.Phone.Functions.CarregandoFaturas(faturas);
                    });
                  
                } else if (PressedApplication == "whatsapp") {
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                    $("#phone-time").css({'color':'black'});
                    $("#phone-icons").css({'color':'black'});
                    $.post('http://reborn_phone/GetWhatsappChats', JSON.stringify({}), function(chats){
                        Reborn.Phone.Functions.LoadWhatsappChats(chats);         
                    });
                } else if (PressedApplication == "phone") {
                    $(".profile-phone-nome").text(Reborn.Phone.Data.PlayerData.charinfo.firstname+" "+Reborn.Phone.Data.PlayerData.charinfo.lastname)
                    $(".profile-nome-pessoal").text(Reborn.Phone.Data.PlayerData.charinfo.firstname+" "+Reborn.Phone.Data.PlayerData.charinfo.lastname)
                    $(".profile-avatar-contatos").css({"background-image":"url('"+Reborn.Phone.Data.MetaData.profilepicture+"')"})
                    $(".profile-subname-pessoal").text('Número '+ Reborn.Phone.Data.PlayerData.charinfo.phone)
                    $("#phone-time").css({'color':'black'});
                    $("#phone-icons").css({'color':'black'});
                    $.post('http://reborn_phone/GetMissedCalls', JSON.stringify({}), function(recent){
                        Reborn.Phone.Functions.SetupRecentCalls(recent);
                    });
                    $.post('http://reborn_phone/GetSuggestedContacts', JSON.stringify({}), function(suggested){
                        Reborn.Phone.Functions.SetupSuggestedContacts(suggested);
                    });
                    $.post('http://reborn_phone/ClearGeneralAlerts', JSON.stringify({
                        app: "phone"
                    }));
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "mail") {
                    $("#phone-time").css({'color':'black'});
                    $("#phone-icons").css({'color':'black'});
                    $.post('http://reborn_phone/GetMails', JSON.stringify({}), function(mails){
                        Reborn.Phone.Functions.SetupMails(mails);
                        // $("#toast-container").css({'display':'black'});
                        // M.toast({html: `
                        //     <div class='alert-bar'>
                        //         <span class='alerta-icone'>
                        //             <i class='material-icons'>bluetooth</i>
                        //         </span><span class='alerta-titulo'>Emprego</span>
                        //     </div>
                        //     <span class='alerta-mensagem'>aqui fica a mensagem</span>
                        //     `, classes: 'phone-alerta', displayLength: 3500 
                        // })
                    });
                    $.post('http://reborn_phone/ClearGeneralAlerts', JSON.stringify({
                        app: "mail"
                    }));
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "advert") {
                    $("#phone-time").css({'color':'black'});
                    $("#phone-icons").css({'color':'black'});
                    $.post('http://reborn_phone/LoadAdverts', JSON.stringify({}), function(Adverts){
                        Reborn.Phone.Functions.RefreshAdverts(Adverts);
                    })
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "garage") {
                    $("#phone-time").css({'color':'black'});
                    $("#phone-icons").css({'color':'black'});
                    $.post('http://reborn_phone/SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                        SetupGarageVehicles(Vehicles);
                    })
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "crypto") {

                    $.post('http://reborn_phone/GetCryptoData', JSON.stringify({
                        crypto: "bitcoins",
                    }), function(CryptoData){
                        SetupCryptoData(CryptoData);
                    })

                    $.post('http://reborn_phone/GetCryptoTransactions', JSON.stringify({}), function(data){
                        RefreshCryptoTransactions(data);
                    })
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "racing") {
              
                    $.post('http://reborn_phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                        SetupRaces(Races);
                    });
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "houses") {
                    
                    $.post('http://reborn_phone/GetPlayerHouses', JSON.stringify({}), function(HousesData){
                        SetupPlayerHouses(HousesData);
                    });
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "meos") {
                    $("#phone-time").css({'color':'black'});
                    $("#phone-icons").css({'color':'black'});
                    $(".foto-perfil-policial").css({"background-image":"url('"+Reborn.Phone.Data.MetaData.profilepicture+"')"})
                    $(".foto-perfil-policial-header").css({"background-image":"url('"+Reborn.Phone.Data.MetaData.profilepicture+"')"})
                    SetupMeosHome();
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                }  else if (PressedApplication == "lawyers") {
                    
                    $.post('http://reborn_phone/GetCurrentLawyers', JSON.stringify({}), function(data){
                        SetupLawyers(data);
                    });
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "trabalhar") {
                    
                    $.post('http://reborn_phone/GruposTrabalhosAtuais', JSON.stringify({}), function(data){
                        TrabalhosInfos(data);
                        // console.log('cliquei em trabalhos')
                    });
                    setTimeout(function(){
                        $(".phone-footer").css({"display":"block"});
                    }, 500);
                } else if (PressedApplication == "instagram") {
                    NotifyInside('Phone','Sistema','settings','Este aplicativo não está disponivel')
                }
            }
        }
    } else {
        if (PressedApplication == "camera") {
            // console.log('opa galera')
            Reborn.Phone.Functions.Close();
            $.post('http://reborn_phone/AbrirCamera', JSON.stringify({}), function(data){
                'camera'
            });
            // setTimeout(function(){
            //     $(".phone-footer").css({"display":"block"});
            // }, 500);
        } else {
            // Reborn.Phone.Notifications.Add("fas fa-exclamation-circle", "System", Reborn.Phone.Data.Applications[PressedApplication].tooltipText + " is not available!")
            NotifyInside('Phone','Sistema','settings','Este aplicativo não está disponivel')
        }
    }
});

$(document).on('click', '.voltar-button', function(event){
    event.preventDefault();

    if (Reborn.Phone.Data.currentApplication === null) {
        Reborn.Phone.Functions.Close();
    } else {
        Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        Reborn.Phone.Animations.TopSlideUp('.'+Reborn.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            Reborn.Phone.Functions.ToggleApp(Reborn.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        Reborn.Phone.Functions.HeaderTextColor("white", 300);

        if (Reborn.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (Reborn.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});
    
                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');
    
                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');
    
                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (Reborn.Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("panicbutton");
                $(".meos-recent-alert").css({"background-color":"#004682"}); 
            }, 400)
        }

        Reborn.Phone.Data.currentApplication = null;
    }
});



// CLICK PARA VOLTAR PRA TELA DE APLICATIVOS
$(document).on('click', '.phone-home-container', function(event){
    event.preventDefault();

    if (Reborn.Phone.Data.currentApplication === null) {
        Reborn.Phone.Functions.Close();
        $("#phone-time").css({'color':'white'});
        $("#phone-icons").css({'color':'white'});
    } else {
        $("#phone-time").css({'color':'white'});
        $("#phone-icons").css({'color':'white'});
        $(".phone-footer").css({"display":"none"});
        Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        Reborn.Phone.Animations.TopSlideUp('.'+Reborn.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            Reborn.Phone.Functions.ToggleApp(Reborn.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        Reborn.Phone.Functions.HeaderTextColor("white", 300);

        if (Reborn.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (Reborn.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});
    
                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');
    
                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');
    
                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (Reborn.Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("panicbutton");
                $(".meos-recent-alert").css({"background-color":"#004682"}); 
            }, 400)
        }

        Reborn.Phone.Data.currentApplication = null;
    }
});

//aqui o novo
Reborn.Phone.Functions.OpenNotification = function (data) {
    
    $(".phone-lockscreem").fadeIn('slow')
    $(".phone-applications").css({ 'filter': 'blur(8px)' })
    Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 300, -160);
    $("#phone-time").css({'color':'white'});
    $("#phone-icons").css({'color':'white'});
    Reborn.Phone.Animations.BottomSlideUp('.container', 300, -30);
    $(".paginacao-ios").css({ "display": "none" })
    setTimeout(function () {
        if (Reborn.Phone.Data.currentApplication === null) {
            Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 300, -160);
            Reborn.Phone.Animations.BottomSlideUp('.container', 300, -70);
            return
        }
        Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
        Reborn.Phone.Functions.CloseWithNotification()
    }, 3000)
}

Reborn.Phone.Functions.Open = function(data) {
    Reborn.Phone.Animations.BottomSlideUp('.container', 300, 0);
    // $("#toast-container").css({ 'display': 'none' })
    Reborn.Phone.Notifications.LoadTweets(data.Tweets);
    Reborn.Phone.Data.IsOpen = true;
    
    $(".paginacao-ios").css({"display":"none"})
    $.post('http://reborn_phone/GetSuggestedContacts', JSON.stringify({}), function(suggested){
        Reborn.Phone.Functions.SetupSuggestedContacts(suggested);
    });
}

Reborn.Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}


Reborn.Phone.Functions.CloseWithNotification = function() {
    // mudar aqui
    if (Reborn.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            Reborn.Phone.Animations.TopSlideUp('.'+Reborn.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            Reborn.Phone.Functions.HeaderTextColor("white", 300);
    
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            Reborn.Phone.Data.currentApplication = null;
        }, 500)
    } else if (Reborn.Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("panicbutton");
        $(".meos-recent-alert").css({"background-color":"#004682"}); 
    }

    Reborn.Phone.Animations.BottomSlideDown('.container', 300, -70);
    // $('#ion-alert').remove();
    var RemoveContainerIonic = $(".alertas-ios-local");
    $(RemoveContainerIonic).html("");

    $.post('http://reborn_phone/CloseWithNotification');
    Reborn.Phone.Data.IsOpen = false;
}



Reborn.Phone.Functions.Close = function() {
    // mudar aqui
    if (Reborn.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            Reborn.Phone.Animations.TopSlideUp('.'+Reborn.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            Reborn.Phone.Functions.HeaderTextColor("white", 300);
    
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            Reborn.Phone.Data.currentApplication = null;
        }, 500)
    } else if (Reborn.Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("panicbutton");
        $(".meos-recent-alert").css({"background-color":"#004682"}); 
    }

    Reborn.Phone.Animations.BottomSlideDown('.container', 300, -70);
    // $('#ion-alert').remove();
    var RemoveContainerIonic = $(".alertas-ios-local");
    $(RemoveContainerIonic).html("");

    $.post('http://reborn_phone/Close');
    Reborn.Phone.Data.IsOpen = false;
}

Reborn.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

Reborn.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

Reborn.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

Reborn.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

Reborn.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

Reborn.Phone.Notifications.Add = function(icon, title, text, color, timeout) {
    $.post('http://reborn_phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            if (Reborn.Phone.Notifications.Timeout == undefined || Reborn.Phone.Notifications.Timeout == null) {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else if (color == "default" || color == null || color == undefined) {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                Reborn.Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
                if (icon !== "police") {
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                } else {
                    $(".notification-icon").html('<img src="./img/police.png" class="police-icon-notify">');
                }
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (Reborn.Phone.Notifications.Timeout !== undefined || Reborn.Phone.Notifications.Timeout !== null) {
                    clearTimeout(Reborn.Phone.Notifications.Timeout);
                }
                Reborn.Phone.Notifications.Timeout = setTimeout(function(){
                    Reborn.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    Reborn.Phone.Notifications.Timeout = null;
                }, timeout);
            } else {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                $(".notification-icon").html('<i class="'+icon+'"></i>');
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (Reborn.Phone.Notifications.Timeout !== undefined || Reborn.Phone.Notifications.Timeout !== null) {
                    clearTimeout(Reborn.Phone.Notifications.Timeout);
                }
                Reborn.Phone.Notifications.Timeout = setTimeout(function(){
                    Reborn.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    Reborn.Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

Reborn.Phone.Functions.LoadPhoneData = function(data) {
    Reborn.Phone.Data.PlayerData = data.PlayerData;
    Reborn.Phone.Data.PlayerJob = data.PlayerJob;
    Reborn.Phone.Data.MetaData = data.PhoneData.MetaData;
    Reborn.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    Reborn.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    Reborn.Phone.Functions.SetupApplications(data);
}

Reborn.Phone.Functions.UpdateTime = function(data) {    
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss

    $("#phone-time").html(data.InGameTime.hour + ":" + data.InGameTime.minute);



    $(".lockscream-time").html(data.InGameTime.hour + ":" + data.InGameTime.minute);
    $(".lockscream-mes").html(data.InGameTime.mes + ", dia " + data.InGameTime.dia);
    $(".lockscream-msgtempo").html(data.InGameTime.msgtmp);
    $(".lockscream-good").html(data.InGameTime.msggood);
    $(".lockscream-temperatura").html(data.InGameTime.temp);
}

function UnlockTela() {
    setTimeout(function(){
        $(".phone-applications").css({'filter':'none'})
        $(".phone-lockscreem").fadeOut('middle')
        $('.phone-home-applications').show('middle')
        $('.phone-footer-applications').show('middle')
        $(".paginacao-ios").show('middle')
        $(".phone-footer").css({"display":"none"});
        // console.log('[reborn_phone][unlocked = true][version: 0.1.2]')
        $.post('http://reborn_phone/ClearContatosSugeridos', JSON.stringify({}));
        $(".lock-notification-area").html("");
    }, 1000);
}
var firstnotifyinside = true
var idinitial = 70000
var divnum = 1

function NotifyInside(titulo, subtitulo, app, mensagem) {
    var NotificacaoId = Math.floor((Math.random() * 100000) + 1)
    divnum = divnum+1
    var Notificacao = '<div class="notificacao-celular" style="display:none;" id="notify-'+NotificacaoId+'"><div class="notificacao-header"><div class="icone-notificacao" style="background-image: url(./img/' + app + '.png); background-size: contain; background-color: transparent;"></div><div class="titulo-notificacao" style="color: white;">'+titulo+'</div></div><div class="notificacao-mensagem-area"><div class="titulo-mensagem-lock" style="color: white;">'+subtitulo+'</div><div class="mensagem-lock-full" style="color: white;">'+mensagem+'</div></div></div>'
    
    $(".lugar-da-notificacao").append(Notificacao);

    var parent = document.getElementsByClassName('lugar-da-notificacao')[0],
    divs = parent.children,
    i = divs.length - 1;

    for (; i--;) {
        parent.appendChild(divs[i])
    }
    setTimeout(function(){
        $('#notify-' + NotificacaoId).fadeIn('fast');
        $('#play_notify_hidden').append('<audio id="bg_music-'+NotificacaoId+'" class="audio" autoplay controls><source  src="./img/sms.mp3" type="audio/mp3"/></audio>');
          setTimeout(function(){
            $('#notify-' + NotificacaoId).fadeOut('fast');
             setTimeout(function(){
                 $('#notify-' + NotificacaoId).remove()
                 $('#bg_music-'+NotificacaoId).remove()
                }, 3100);        
         }, 2500);
      }, 500);
}

var idsoundplay = 1
function NotificationCenter(titulo, conteudo, app, dtitulo) {
    if (idstartnoti) {
        idstartnoti = idstartnoti - 1
        var elem = '<div class="notify-item-lock" id="' + idstartnoti + '"><div class="notificacao-header"><span class="icone-notificacao" style="background-image: url(./img/' + app + '.png); background-size: contain; background-color: transparent;"></span><span class="titulo-notificacao">' + titulo + '</span><span class="time-notificacao"></span></div><div class="notificacao-mensagem-area"><div class="titulo-mensagem-lock">' + dtitulo + '</div><div class="mensagem-lock-full">' + conteudo + '</div></div></div>';
        $(".lock-notification-area").append(elem);

        var parent = document.getElementsByClassName('lock-notification-area')[0],
        divs = parent.children,
        i = divs.length - 1;
    
        for (; i--;) {
            parent.appendChild(divs[i])
        }

        idsoundplay = idsoundplay+1
        $('#play_notify_hidden').append('<audio id="bg_music-'+idsoundplay+'" class="audio" autoplay controls><source  src="./img/sms.mp3" type="audio/mp3"/></audio>');
        setTimeout(function () {
            $('#bg_music-'+idsoundplay).remove()
        }, 2100);
    }
}


var NotificationTimeout = null;

Reborn.Screen.Notification = function(title, content, app, mtitulo) {
    $.post('http://reborn_phone/HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            console.log(title, content, app, mtitulo)
            NotificationCenter(title,content,app,mtitulo)
        }
    });
}


$(document).ready(function(){
    $('.phone-home-applications').fadeOut('middle')
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                //checkpoint
                $(".phone-lockscreem").fadeIn('slow')
                $(".phone-applications").css({'filter':'blur(8px)'})
                $('.phone-home-applications').fadeOut('middle')
                $('.phone-footer-applications').fadeOut('middle')

                // var parent = document.getElementsByClassName('lock-notification-area')[0],
                // divs = parent.children,
                // i = divs.length - 1;
            
                // for (; i--;) {
                //     parent.appendChild(divs[i])
                // }
                //mudar aqui
                Reborn.Phone.Functions.Open(event.data);
                Reborn.Phone.Functions.SetupAppWarnings(event.data.AppData);
                Reborn.Phone.Functions.SetupCurrentCall(event.data.CallData);
                Reborn.Phone.Data.IsOpen = true;
                Reborn.Phone.Data.PlayerData = event.data.PlayerData;
                break;
            case "LoadPhoneData":
                Reborn.Phone.Functions.LoadPhoneData(event.data);
                break;
            case "UpdateTime":
                Reborn.Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                Reborn.Phone.Functions.OpenNotification()
                NotificationCenter(event.data.NotifyData.title,event.data.NotifyData.text,event.data.NotifyData.app,event.data.NotifyData.mtitulo)
                break;
            case "PhoneNotification":
                NotificationCenter(event.data.PhoneNotify.title,event.data.PhoneNotify.text,event.data.PhoneNotify.app,event.data.PhoneNotify.mtitulo)
                break;
            case "InsidePhoneNotify":
                NotifyInside(event.data.PhoneNotify.title,event.data.PhoneNotify.mtitulo,event.data.PhoneNotify.app,event.data.PhoneNotify.text)
                break
            case "RefreshAppAlerts":
                Reborn.Phone.Functions.SetupAppWarnings(event.data.AppData);                
                break;
            case "UpdateMentionedTweets":
                Reborn.Phone.Notifications.LoadMentionedTweets(event.data.Tweets);                
                break;
            case "UpdateBank":
                var formatter = new Intl.NumberFormat('en-US', {
                    style: 'currency',
                    currency: 'USD',
                });    
                $(".bank-app-account-balance").html(formatter.format(event.data.NewBalance));
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateChat":
                if (Reborn.Phone.Data.currentApplication == "whatsapp") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        // console.log('Chat reloaded')
                        Reborn.Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        // console.log('Chats reloaded')
                        Reborn.Phone.Functions.LoadWhatsappChats(event.data.Chats);
                    }
                }
                break;
            case "UpdateHashtags":
                Reborn.Phone.Notifications.LoadHashtags(event.data.Hashtags);
                break;
            case "RefreshWhatsappAlerts":
                Reborn.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('http://reborn_phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('http://reborn_phone/HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "SetupHomeCall":
                Reborn.Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                Reborn.Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);

                if (!Reborn.Phone.Data.IsOpen) {
                    if ($(".call-notifications").css("right") !== "52.1px") {
                        $(".call-notifications").css({"display":"block"});
                        $(".call-notifications").animate({right: 5+"vh"});
                    }
                    $(".call-notifications-title").html("In conversation ("+timeString+")");
                    $(".call-notifications-content").html("Call with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                }

                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html("In conversation ("+timeString+")");
                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    Reborn.Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                Reborn.Phone.Functions.HeaderTextColor("white", 300);
    
                Reborn.Phone.Data.CallActive = false;
                Reborn.Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                Reborn.Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                Reborn.Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (Reborn.Phone.Data.currentApplication == "advert") {
                    Reborn.Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                Reborn.Phone.Data.PlayerJob = event.data.JobData;
                Reborn.Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateRacingApp":
                $.post('http://reborn_phone/GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
        }
    })
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
            Reborn.Phone.Functions.Close();
            $('.phone-home-applications').fadeOut('middle')
            break;
    }
});