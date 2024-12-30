var ContactSearchActive = false;
var CurrentFooterTab = "contacts";
var CallData = {};
var ClearNumberTimer = null;
var SelectedSuggestion = null;
var AmountOfSuggestions = 0;



$(document).on('click', '.phone-app-footer-button', function(e){
    e.preventDefault();

    var PressedFooterTab = $(this).data('phonefootertab');

    if (PressedFooterTab !== CurrentFooterTab) {
        var PreviousTab = $(this).parent().find('[data-phonefootertab="'+CurrentFooterTab+'"');

        $('.phone-app-footer').find('[data-phonefootertab="'+CurrentFooterTab+'"').removeClass('phone-selected-footer-tab');
        $(this).addClass('phone-selected-footer-tab');

        $(".phone-"+CurrentFooterTab).hide();
        $(".phone-"+PressedFooterTab).show();

        if (PressedFooterTab == "recent") {
            $.post('http://reborn_phone/ClearRecentAlerts');
        } else if (PressedFooterTab == "suggestedcontacts") {
            $.post('http://reborn_phone/ClearRecentAlerts');
        }

        CurrentFooterTab = PressedFooterTab;
    }
});



$(document).ready(function(){
    $(".voltar-icone-policia").fadeOut();
    $("#header-pesquisar-input").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".phone-contact").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    
});


$(document).on("click", "#phone-search-icon", function(e){
    e.preventDefault();

    if (!ContactSearchActive) {
        $("#phone-plus-icon").animate({
            opacity: "0.0",
            "display": "none"
        }, 150, function(){
            $("#contact-search").css({"display":"block"}).animate({
                opacity: "1.0",
            }, 150);
        });
    } else {
        $("#contact-search").animate({
            opacity: "0.0"
        }, 150, function(){
            $("#contact-search").css({"display":"none"});
            $("#phone-plus-icon").animate({
                opacity: "1.0",
                display: "block",
            }, 150);
        });
    }

    ContactSearchActive = !ContactSearchActive;
});

// $(document).ready(function(){
//     $("todasligacoes").on("keyup", function() {
//         var value = 'Ligação'
//         $(".phone-recent-call").filter(function() {
//           $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
//         });
//     });
//     $("#todasligacoes").on("keyup", function() {
//         var value = 'Ligação'
//         $(".phone-recent-call").filter(function() {
//           $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
//         });
//     });
// });


$(document).on('click', '.todasligacoes', function(e){
    var pesquisa = $(this).val().toLowerCase();
    //console.log(pesquisa)
    $(".phone-recent-call").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(pesquisa) > -1);
    });
});

$(document).on('click', '.ligacoesrecebidas', function(e){
    var pesquisa = $(this).val().toLowerCase();
    //console.log(pesquisa)
    $(".phone-recent-call").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(pesquisa) > -1);
    });
});


Reborn.Phone.Functions.SetupRecentCalls = function(recentcalls) {
    $(".phone-recent-calls").html("");

    recentcalls = recentcalls.reverse();

    $.each(recentcalls, function(i, recentCall){
        var FirstLetter = (recentCall.name).charAt(0);
        var TypeIcon = 'fas fa-phone-slash';
        var IconStyle = "color: #e74c3c;";
        //console.log(recentCall.type);
        if (recentCall.type === "outgoing") {
            var recebeuligacao = 'style="opacity: 1;"'
            var tipoligacao = 'Ligação Realizada'
            TypeIcon = 'fas fa-phone-volume';
            var cordonome = 'style="color: black;"'
            var IconStyle = "color: #2ecc71; font-size: 1.4vh;";
        } else {
            var recebeuligacao = 'style="opacity: 0;"'
            var cordonome = 'style="color: red;"'
            var tipoligacao = 'Ligação Recebida'
        }
        if (recentCall.anonymous) {
            FirstLetter = "A";
            recentCall.name = "Anonymous";
        }
        var elem = '<div class="phone-recent-call" id="recent-'+i+'"><div class="phone-recent-call-image" '+recebeuligacao+'><ion-icon name="call" class="ligou-icone"></ion-icon></div> <div class="phone-recent-call-name" '+cordonome+'>'+recentCall.name+'</div> <div class="phone-recent-call-type">'+tipoligacao+'</div> <div class="phone-recent-call-time">'+recentCall.time+'</div> </div>'

        $(".phone-recent-calls").append(elem);
        $("#recent-"+i).data('recentData', recentCall);
    });
}

$(document).on('click', '.phone-recent-call', function(e){
    e.preventDefault();

    var RecendId = $(this).attr('id');
    var RecentData = $("#"+RecendId).data('recentData');

    cData = {
        number: RecentData.number,
        name: RecentData.name
    }

    //console.log(Reborn.Phone.Data.AnonymousCall)

    $.post('http://reborn_phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: Reborn.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== Reborn.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        if (Reborn.Phone.Data.AnonymousCall) {
                            // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You have started an anonymous call!");
                            NotifyInside('Phone','blabla','telefone','Você iniciou uma chamada desconhecida')
                        }
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        Reborn.Phone.Functions.HeaderTextColor("white", 400);
                        Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".phone-app").css({"display":"none"});
                            Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            Reborn.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);
    
                        CallData.name = cData.name;
                        CallData.number = cData.number;
                    
                        Reborn.Phone.Data.currentApplication = "phone-call";
                    } else {
                        // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You are already busy!");
                        NotifyInside('Phone','Celular','telefone','Você já está ocupado')
                    }
                } else {
                    // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is talking!");
                    NotifyInside('Phone','Celular','telefone','Esta pessoa está em chamada')
                }
            } else {
                // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
                NotifyInside('Phone','Celular','telefone','Esta pessoa não está disponivel')
            }
        } else {
            // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You cannot call your own number!");
            NotifyInside('Phone','Celular','telefone','Você não pode ligar para você mesmo')
        }
    });
});

$(document).on('click', ".phone-keypad-key-call", function(e){
    e.preventDefault();

    var InputNum = toString($(".phone-keypad-input").text());

    cData = {
        number: InputNum,
        name: InputNum,
    }

    $.post('http://reborn_phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: Reborn.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== Reborn.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        Reborn.Phone.Functions.HeaderTextColor("white", 400);
                        Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".phone-app").css({"display":"none"});
                            Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            Reborn.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);
    
                        CallData.name = cData.name;
                        CallData.number = cData.number;
                    
                        Reborn.Phone.Data.currentApplication = "phone-call";
                    } else {
                        // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You are already busy!");
                        NotifyInside('Phone','Celular','telefone','Você já está ocupado')
                    }
                } else {
                    // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is talking!");
                    NotifyInside('Phone','Celular','telefone','Esta pessoa já está em ligação')
                }
            } else {
                // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not talking!");
                NotifyInside('Phone','Celular','telefone','Esta pessoa não está disponível')
            }
        } else {
            // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You cannot call your own number!");
            NotifyInside('Phone','Celular','telefone','Você não pode ligar para você mesmo')
        }
    });
});

Reborn.Phone.Functions.LoadContacts = function(myContacts) {
    var ContactsObject = $(".phone-contact-list");
    $(ContactsObject).html("<div class='ios-meunumero'><div class='profile-avatar-contatos'></div><span class='profile-nome-pessoal'></span><span class='profile-subname-pessoal'>Meu Cartão</span></div>");
    var TotalContacts = 0;

    $(".phone-contacts").hide();
    $(".phone-recent").hide();
    $(".phone-keypad").hide();

    $(".phone-"+CurrentFooterTab).show();

    //parte de ligar
    //<div class="phone-contact-firstletter" style="background-color: #e74c3c;">'+((contact.name).charAt(0)).toUpperCase()+'</div>
    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            var ContactElement = '<div class="phone-contact" data-contactid="'+i+'"><div class="phone-contact-name">'+contact.name+'</div></div>'
            //<div class="phone-contact-firstletter" style="background-color: #2ecc71;">'+((contact.name).charAt(0)).toUpperCase()+'</div>
            if (contact.status) {
                ContactElement = '<div class="phone-contact" data-contactid="'+i+'"><div class="phone-contact-name">'+contact.name+'</div></div>'
            }
            TotalContacts = TotalContacts + 1
            $(ContactsObject).append(ContactElement);
            $("[data-contactid='"+i+"']").data('contactData', contact);
        });
        $("#total-contacts").text(TotalContacts+ " Contatos");
    } else {
        $("#total-contacts").text("Nenhum contato");
    }
};

// $(document).on('click', '#new-chat-phone', function(e){
//     var ContactId = $(this).parent().parent().data('contactid');
//     var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');
//     setTimeout(function(){
//         $(".phone-footer").css({"display":"none"});
//     }, 500);
//     if (ContactData.number !== Reborn.Phone.Data.PlayerData.charinfo.phone) {
//         $.post('http://reborn_phone/GetWhatsappChats', JSON.stringify({}), function(chats){
//             Reborn.Phone.Functions.LoadWhatsappChats(chats);
//         });
    
//         $('.phone-application-container').animate({
//             top: -160+"%"
//         });
//         Reborn.Phone.Functions.HeaderTextColor("white", 400);
//         setTimeout(function(){
//             $('.phone-application-container').animate({
//                 top: 0+"%"
//             });
    
//             Reborn.Phone.Functions.ToggleApp("phone", "none");
//             Reborn.Phone.Functions.ToggleApp("whatsapp", "block");
//             Reborn.Phone.Data.currentApplication = "whatsapp";
        
//             $.post('http://reborn_phone/GetWhatsappChat', JSON.stringify({phone: ContactData.number}), function(chat){
//                 Reborn.Phone.Functions.SetupChatMessages(chat, {
//                     name: ContactData.name,
//                     number: ContactData.number
//                 });
//             });
        
//             $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 150);
//             $(".whatsapp-openedchat").css({"display":"block"});
//             $(".whatsapp-openedchat").css({left: 0+"vh"});
//             $(".whatsapp-chats").animate({left: 30+"vh"},100, function(){
//                 $(".whatsapp-chats").css({"display":"none"});
//             });
//         }, 400)
//     } else {
//         Reborn.Phone.Notifications.Add("fa fa-phone-alt", "Phone", "You can't app yourself, sad fuck..", "default", 3500);
//     }
// });

var CurrentEditContactData = {}


// $(document).on('click', '#edit-contact', function(e){
//     e.preventDefault();
//     var ContactId = $(this).parent().parent().data('contactid');
//     var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

//     CurrentEditContactData.name = ContactData.name
//     CurrentEditContactData.number = ContactData.number

//     $(".phone-edit-contact-header").text(ContactData.name+" Bewerken")
//     $(".phone-edit-contact-name").val(ContactData.name);
//     $(".phone-edit-contact-number").val(ContactData.number);
//     if (ContactData.iban != null && ContactData.iban != undefined) {
//         $(".phone-edit-contact-iban").val(ContactData.iban);
//         CurrentEditContactData.iban = ContactData.iban
//     } else {
//         $(".phone-edit-contact-iban").val("");
//         CurrentEditContactData.iban = "";
//     }

//     Reborn.Phone.Animations.TopSlideDown(".phone-edit-contact", 200, 0);
// });

$(document).on('click', '#edit-contact-save', function(e){
    e.preventDefault();

    var ContactName = $(".phone-edit-contact-name").val();
    var ContactNumber = $(".phone-edit-contact-number").val();
    var ContactIban = $(".phone-edit-contact-iban").val();

    if (ContactName != "" && ContactNumber != "") {
        $.post('http://reborn_phone/EditContact', JSON.stringify({
            CurrentContactName: ContactName,
            CurrentContactNumber: ContactNumber,
            CurrentContactIban: ContactIban,
            OldContactName: CurrentEditContactData.name,
            OldContactNumber: CurrentEditContactData.number,
            OldContactIban: CurrentEditContactData.iban,
        }), function(PhoneContacts){
            Reborn.Phone.Functions.LoadContacts(PhoneContacts);
        });
        Reborn.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
        setTimeout(function(){
            $(".phone-edit-contact-number").val("");
            $(".phone-edit-contact-name").val("");
        }, 250)
    } else {
        // Reborn.Phone.Notifications.Add("fas fa-exclamation-circle", "Contact edit", "Fill everything!");
        NotifyInside('Phone','Celular','telefone','Preencha todos os dados!')
    }
});

$(document).on('click', '#edit-contact-delete', function(e){
    e.preventDefault();

    var ContactName = $(".phone-edit-contact-name").val();
    var ContactNumber = $(".phone-edit-contact-number").val();
    var ContactIban = $(".phone-edit-contact-iban").val();

    $.post('http://reborn_phone/DeleteContact', JSON.stringify({
        CurrentContactName: ContactName,
        CurrentContactNumber: ContactNumber,
        CurrentContactIban: ContactIban,
    }), function(PhoneContacts){
        Reborn.Phone.Functions.LoadContacts(PhoneContacts);
    });
    Reborn.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
    setTimeout(function(){
        $(".phone-edit-contact-number").val("");
        $(".phone-edit-contact-name").val("");
    }, 250);
});

$(document).on('click', '#edit-contact-cancel', function(e){
    e.preventDefault();

    Reborn.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
    setTimeout(function(){
        $(".phone-edit-contact-number").val("");
        $(".phone-edit-contact-name").val("");
    }, 250)
});

$(document).on('click', '.phone-keypad-key', function(e){
    e.preventDefault();

    var PressedButton = $(this).data('keypadvalue');

    if (!isNaN(PressedButton)) {
        var keyPadHTML = $("#phone-keypad-input").text();
        $("#phone-keypad-input").text(keyPadHTML + PressedButton)
    } else if (PressedButton == "#") {
        var keyPadHTML = $("#phone-keypad-input").text();
        $("#phone-keypad-input").text(keyPadHTML + PressedButton)
    }
})

$(document).on('click', '.phone-keypad-key-apagar', function(e){
    e.preventDefault();
    var PressedButton = $(this).data('keypadvalue');
    if (PressedButton == "*") {
        if (ClearNumberTimer == null) {
            // $("#phone-keypad-input").text("Cleared")
            ClearNumberTimer = setTimeout(function(){
                $("#phone-keypad-input").text("");
                ClearNumberTimer = null;
            }, 750);
        }
    }
})

var OpenedContact = null;

$(document).on('click', '.phone-contact-actions', function(e){
    e.preventDefault();

    var FocussedContact = $(this).parent();
    var ContactId = $(FocussedContact).data('contactid');

    if (OpenedContact === null) {
        $(FocussedContact).animate({
            "height":"6vh"
        }, 150, function(){
            $(FocussedContact).find('.phone-contact-action-buttons').fadeIn(100);
        });
        OpenedContact = ContactId;
    } else if (OpenedContact == ContactId) {
        $(FocussedContact).find('.phone-contact-action-buttons').fadeOut(100, function(){
            $(FocussedContact).animate({
                "height":"3vh"
            }, 150);
        });
        OpenedContact = null;
    } else if (OpenedContact != ContactId) {
        var PreviousContact = $(".phone-contact-list").find('[data-contactid="'+OpenedContact+'"]');
        $(PreviousContact).find('.phone-contact-action-buttons').fadeOut(100, function(){
            $(PreviousContact).animate({
                "height":"4.5vh"
            }, 150);
            OpenedContact = ContactId;
        });
        $(FocussedContact).animate({
            "height":"7vh"
        }, 150, function(){
            $(FocussedContact).find('.phone-contact-action-buttons').fadeIn(100);
        });
    }
});


$(document).on('click', '#adicionar-contato', function(e){
    e.preventDefault();

    Reborn.Phone.Animations.TopSlideDown(".phone-add-contact", 200, 0);
});

$(document).on('click', '#add-contact-save', function(e){
    e.preventDefault();

    var ContactName = $(".phone-add-contact-name").val();
    var ContactNumber = $(".phone-add-contact-number").val();
    var ContactIban = $(".phone-add-contact-iban").val();

    if (ContactName != "" && ContactNumber != "") {
        $.post('http://reborn_phone/AddNewContact', JSON.stringify({
            ContactName: ContactName,
            ContactNumber: ContactNumber,
            ContactIban: ContactIban,
        }), function(PhoneContacts){
            Reborn.Phone.Functions.LoadContacts(PhoneContacts);
        });
        Reborn.Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
        setTimeout(function(){
            $(".phone-add-contact-number").val("");
            $(".phone-add-contact-name").val("");
        }, 250)

        if (SelectedSuggestion !== null) {
            $.post('http://reborn_phone/RemoveSuggestion', JSON.stringify({
                data: $(SelectedSuggestion).data('SuggestionData')
            }));
            $(SelectedSuggestion).remove();
            SelectedSuggestion = null;
            var amount = parseInt(AmountOfSuggestions);
            if ((amount - 1) === 0) {
                amount = 0
            }
            $(".amount-of-suggested-contacts").html(amount + " Contacts");
        }
    } else {
        Reborn.Phone.Notifications.Add("fas fa-exclamation-circle", "Contact add", "Fill everything!");
    }
});




$(document).on('click', '.phone-contact', function(e){
    e.preventDefault();

    const actionSheet = document.createElement('ion-action-sheet');

    actionSheet.header = 'Ações';
    actionSheet.mode = 'ios';
    actionSheet.keyboardClose = true;
    actionSheet.cssClass = 'alertas-ios-local';
    actionSheet.buttons = [{
      text: 'Ligar',
    //   icon: 'share',
      handler: () => {
        var ContactId = $(this).data('contactid');
        //console.log(ContactId)
        var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');
        SetupCall(ContactData);
      }
    }, {
      text: 'Mensagem',
    //   icon: 'caret-forward-circle',
      handler: () => {
            var ContactId = $(this).data('contactid');
            var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');
            setTimeout(function(){
                $(".phone-footer").css({"display":"none"});
            }, 500);
            if (ContactData.number !== Reborn.Phone.Data.PlayerData.charinfo.phone) {
                $.post('http://reborn_phone/GetWhatsappChats', JSON.stringify({}), function(chats){
                    Reborn.Phone.Functions.LoadWhatsappChats(chats);
                });

                $('.phone-application-container').animate({
                    top: -160+"%"
                });
                Reborn.Phone.Functions.HeaderTextColor("white", 400);
                setTimeout(function(){
                    $('.phone-application-container').animate({
                        top: 0+"%"
                    });

                    Reborn.Phone.Functions.ToggleApp("phone", "none");
                    Reborn.Phone.Functions.ToggleApp("whatsapp", "block");
                    Reborn.Phone.Data.currentApplication = "whatsapp";
                
                    $.post('http://reborn_phone/GetWhatsappChat', JSON.stringify({phone: ContactData.number}), function(chat){
                        Reborn.Phone.Functions.SetupChatMessages(chat, {
                            name: ContactData.name,
                            number: ContactData.number
                        });
                    });
                
                    $('.whatsapp-openedchat-messages').animate({scrollTop: 9999}, 150);
                    $(".whatsapp-openedchat").css({"display":"block"});
                    $(".whatsapp-openedchat").css({left: 0+"vh"});
                    $(".whatsapp-chats").animate({left: 30+"vh"},100, function(){
                        $(".whatsapp-chats").css({"display":"none"});
                    });
                }, 400)
            } else {
                // Reborn.Phone.Notifications.Add("fa fa-phone-alt", "Phone", "You can't app yourself, sad fuck..", "default", 3500);
                NotifyInside('SMS','Messenger','sms','Você não pode abrir um chat com você mesmo.')
            }
      }
    }, {
      text: 'Editar',
    //   icon: 'heart',
      handler: () => {
        var ContactId = $(this).data('contactid');
        var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');
    
        CurrentEditContactData.name = ContactData.name
        CurrentEditContactData.number = ContactData.number
    
        $("#editar-contato-titulo-header").text(ContactData.name)
        $(".phone-edit-contact-name").val(ContactData.name);
        $(".phone-edit-contact-number").val(ContactData.number);
        if (ContactData.iban != null && ContactData.iban != undefined) {
            $(".phone-edit-contact-iban").val(ContactData.iban);
            CurrentEditContactData.iban = ContactData.iban
        } else {
            $(".phone-edit-contact-iban").val("");
            CurrentEditContactData.iban = "";
        }
    
        Reborn.Phone.Animations.TopSlideDown(".phone-edit-contact", 200, 0);
      }
    }, {
      text: 'Cancelar',
    //   icon: 'close',
      role: 'cancel',
      handler: () => {
      }
    }];
    document.getElementById("appendaqui").appendChild(actionSheet);
    // document.getElementById("appendaqui").appendChild(alert);
    return actionSheet.present();
});


$(document).on('click', '#add-contact-cancel', function(e){
    e.preventDefault();

    Reborn.Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
    setTimeout(function(){
        $(".phone-add-contact-number").val("");
        $(".phone-add-contact-name").val("");
    }, 250)
});

$(document).on('click', '#phone-start-call', function(e){
    e.preventDefault();   
    
    var ContactId = $(this).parent().parent().data('contactid');
    var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');
    
    SetupCall(ContactData);
});

SetupCall = function(cData) {
    var retval = false;
    $.post('http://reborn_phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: Reborn.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== Reborn.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        Reborn.Phone.Functions.HeaderTextColor("white", 400);
                        Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".phone-app").css({"display":"none"});
                            Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            Reborn.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);
    
                        CallData.name = cData.name;
                        CallData.number = cData.number;
                    
                        Reborn.Phone.Data.currentApplication = "phone-call";
                    } else {
                        // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You are already busy!");
                        NotifyInside('Phone','Celular','telefone','Você já esta ocupado')
                    }
                } else {
                    // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is talking!");
                    NotifyInside('Phone','Celular','telefone','Esta pessoa está em ligação')
                }
            } else {
                // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
                // RebornPhoneNotificacao('Esta pessoa não está disponivel no momento', 2000)
                NotifyInside('Phone','Alerta','telefone','Esta pessoa não está disponivel no momento')
                // showLongToast()
            }
        } else {
            // Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You cannot call your own number!");
            NotifyInside('Phone','Celular','telefone','Você não pode ligar para você mesmo')
        }
    });
}

async function RebornPhoneNotificacao(message,duration) {
    const toast = document.createElement('ion-toast');
    toast.cssClass = 'alertas-ios-local';
    toast.mode = "ios";
    toast.animated = true;
    toast.color = 'light';
    toast.position = 'top';
    toast.message = message;
    toast.duration = duration;
  
    // document.body.appendChild(toast);

    document.getElementById("appendaqui").appendChild(toast);

    toast.present();
    toast.onDidDismiss().then(() => {
        //console.log('Dismissed toast');
    });

    // document.getElementById("appendaqui").appendChild(toast);
    // return toast.present();
}

CancelOutgoingCall = function() {
    if (Reborn.Phone.Data.currentApplication == "phone-call") {
        Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        Reborn.Phone.Animations.TopSlideUp('.'+Reborn.Phone.Data.currentApplication+"-app", 400, -160);
        setTimeout(function(){
            Reborn.Phone.Functions.ToggleApp(Reborn.Phone.Data.currentApplication, "none");
        }, 400)
        Reborn.Phone.Functions.HeaderTextColor("white", 300);
    
        Reborn.Phone.Data.CallActive = false;
        Reborn.Phone.Data.currentApplication = null;
    }
}

$(document).on('click', '#outgoing-cancel', function(e){
    e.preventDefault();

    $.post('http://reborn_phone/CancelOutgoingCall');
});

$(document).on('click', '#incoming-deny', function(e){
    e.preventDefault();

    $.post('http://reborn_phone/DenyIncomingCall');
});

$(document).on('click', '#ongoing-cancel', function(e){
    e.preventDefault();
    
    $.post('http://reborn_phone/CancelOngoingCall');
});

IncomingCallAlert = function(CallData, Canceled, AnonymousCall) {
    if (!Canceled) {
        if (!Reborn.Phone.Data.CallActive) {
            //console.log('aqui ?');
            //console.log(CallData.name);
            //console.log(CallData.number);
            Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            Reborn.Phone.Animations.TopSlideUp('.'+Reborn.Phone.Data.currentApplication+"-app", 400, -160);
            setTimeout(function(){
                var Label = CallData.name + " Esta te ligando"
                if (AnonymousCall) {
                    Label = "Você esta recebendo uma ligação desconhecida."
                }
                $(".call-notifications-title").html("Ligação Recebida");
                $(".call-notifications-content").html(Label);
                $(".call-notifications").css({"display":"block"});
                $(".call-notifications").animate({
                    right: 5+"vh"
                }, 400);
                $(".phone-call-outgoing").css({"display":"none"});
                $(".phone-call-incoming").css({"display":"block"});
                $(".phone-call-ongoing").css({"display":"none"});
                // $(".header-call-info").css({"background-image":CallData.fotinha});
                $(".phone-call-incoming-picture").css({"background-image":CallData.fotinha});
                $(".phone-call-incoming-caller").html(CallData.name);
                $(".phone-call-incoming-caller-number").html('Celular - ' + CallData.number);
                $(".phone-app").css({"display":"none"});
                Reborn.Phone.Functions.HeaderTextColor("white", 400);
                $("."+Reborn.Phone.Data.currentApplication+"-app").fadeOut('fast');
                $(".phone-call-app").fadeIn('fast');
                setTimeout(function(){
                    Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                }, 400);
            }, 400);
        
            Reborn.Phone.Data.currentApplication = "phone-call";
            Reborn.Phone.Data.CallActive = true;
        }
        setTimeout(function(){
            $(".call-notifications").addClass('call-notifications-shake');
            setTimeout(function(){
                $(".call-notifications").removeClass('call-notifications-shake');
            }, 1000);
        }, 400);
    } else {
        $(".call-notifications").animate({
            right: -35+"vh"
        }, 400);
        Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        Reborn.Phone.Animations.TopSlideUp('.'+Reborn.Phone.Data.currentApplication+"-app", 400, -160);
        setTimeout(function(){
            $("."+Reborn.Phone.Data.currentApplication+"-app").css({"display":"none"});
            $(".phone-call-outgoing").css({"display":"none"});
            $(".phone-call-incoming").css({"display":"none"});
            $(".phone-call-ongoing").css({"display":"none"});
            $(".call-notifications").css({"display":"block"});
        }, 400)
        Reborn.Phone.Functions.HeaderTextColor("white", 300);
        Reborn.Phone.Data.CallActive = false;
        Reborn.Phone.Data.currentApplication = null;
    }
}

// IncomingCallAlert = function(CallData, Canceled) {
//     if (!Canceled) {
//         if (!Reborn.Phone.Data.CallActive) {
//             $(".call-notifications-title").html("Inkomende Oproep");
//             $(".call-notifications-content").html("Je hebt een inkomende oproep van "+CallData.name);
//             $(".call-notifications").css({"display":"block"});
//             $(".call-notifications").animate({
//                 right: 5+"vh"
//             }, 400);
//             $(".phone-call-outgoing").css({"display":"none"});
//             $(".phone-call-incoming").css({"display":"block"});
//             $(".phone-call-ongoing").css({"display":"none"});
//             $(".phone-call-incoming-caller").html(CallData.name);
//             $(".phone-app").css({"display":"none"});
//             Reborn.Phone.Functions.HeaderTextColor("white", 400);
//             Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
//             $(".phone-call-app").css({"display":"block"});
//             setTimeout(function(){
//                 Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
//             }, 450);
        
//             Reborn.Phone.Data.currentApplication = "phone-call";
//             Reborn.Phone.Data.CallActive = true;
//         }
//         setTimeout(function(){
//             $(".call-notifications").addClass('call-notifications-shake');
//             setTimeout(function(){
//                 $(".call-notifications").removeClass('call-notifications-shake');
//             }, 1000);
//         }, 400);
//     } else {
//         $(".call-notifications").animate({
//             right: -35+"vh"
//         }, 400);
//         Reborn.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
//         Reborn.Phone.Animations.TopSlideUp('.'+Reborn.Phone.Data.currentApplication+"-app", 400, -160);
//         setTimeout(function(){
//             Reborn.Phone.Functions.ToggleApp(Reborn.Phone.Data.currentApplication, "none");
//             $(".phone-call-outgoing").css({"display":"none"});
//             $(".phone-call-incoming").css({"display":"none"});
//             $(".phone-call-ongoing").css({"display":"none"});
//             $(".call-notifications").css({"display":"block"});
//         }, 400)
//         Reborn.Phone.Functions.HeaderTextColor("white", 300);
    
//         Reborn.Phone.Data.CallActive = false;
//         Reborn.Phone.Data.currentApplication = null;
//     }
// }

Reborn.Phone.Functions.SetupCurrentCall = function(cData) {
    if (cData.InCall) {
        CallData = cData;
        $(".phone-currentcall-container").css({"display":"block"});

        if (cData.CallType == "incoming") {
            $(".phone-currentcall-title").html("Incoming call");
        } else if (cData.CallType == "outgoing") {
            $(".phone-currentcall-title").html("Outgoing call");
        } else if (cData.CallType == "ongoing") {
            $(".phone-currentcall-title").html("Calling ("+cData.CallTime+")");
        }

        $(".phone-currentcall-contact").html("met "+cData.TargetData.name);
    } else {
        $(".phone-currentcall-container").css({"display":"none"});
    }
}

$(document).on('click', '.phone-currentcall-container', function(e){
    e.preventDefault();

    if (CallData.CallType == "incoming") {
        $(".phone-call-incoming").css({"display":"block"});
        $(".phone-call-outgoing").css({"display":"none"});
        $(".phone-call-ongoing").css({"display":"none"});
    } else if (CallData.CallType == "outgoing") {
        $(".phone-call-incoming").css({"display":"none"});
        $(".phone-call-outgoing").css({"display":"block"});
        $(".phone-call-ongoing").css({"display":"none"});
    } else if (CallData.CallType == "ongoing") {
        $(".phone-call-incoming").css({"display":"none"});
        $(".phone-call-outgoing").css({"display":"none"});
        $(".phone-call-ongoing").css({"display":"block"});
    }
    $(".phone-call-ongoing-caller").html(CallData.name);

    Reborn.Phone.Functions.HeaderTextColor("white", 500);
    Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 500, 0);
    Reborn.Phone.Animations.TopSlideDown('.phone-call-app', 500, 0);
    Reborn.Phone.Functions.ToggleApp("phone-call", "block");
                
    Reborn.Phone.Data.currentApplication = "phone-call";
});

$(document).on('click', '#incoming-answer', function(e){
    e.preventDefault();

    $.post('http://reborn_phone/AnswerCall');
});

Reborn.Phone.Functions.AnswerCall = function(CallData) {
    $(".phone-call-incoming").css({"display":"none"});
    $(".phone-call-outgoing").css({"display":"none"});
    $(".phone-call-ongoing").css({"display":"block"});
    $(".phone-call-ongoing-caller").html(CallData.TargetData.name);

    Reborn.Phone.Functions.Close();
}

Reborn.Phone.Functions.SetupSuggestedContacts = function(Suggested) {
    // $(".lock-notification-area").html("");
    AmountOfSuggestions = Suggested.length;
    if (AmountOfSuggestions > 0) {
        // $(".amount-of-suggested-contacts").html(AmountOfSuggestions + " contacts");
        // Suggested = Suggested.reverse();

        $.each(Suggested, function (index, suggest) {
            if (idstartnoti) {
                idstartnoti = idstartnoti - 1
                //console.log(idstartnoti)
                var elem = '<div class="notify-item-lock" id="suggest-'+idstartnoti+'"><div class="notificacao-header"><span class="icone-notificacao" style="background-image: url(./img/telefone.png); background-size: contain; background-color: transparent;"></span><span class="titulo-notificacao">Contatos</span><span class="time-notificacao"></span></div><div class="notificacao-mensagem-area"><div class="titulo-mensagem-lock">Sugestão de Contato</div><div class="mensagem-lock-full">Você recebeu uma sugestão de contato de <strong>'+suggest.number+'</strong></div></div></div>';
                $(".lock-notification-area").append(elem);
                // $(".suggested-contacts").append(elem);
                $("#suggest-"+idstartnoti).data('SuggestionData', suggest);
            }
        });
    } else {
        $(".amount-of-suggested-contacts").html("0 Contacts");
    }
}

$(document).on('click', '.notify-item-lock', function(e){
    e.preventDefault();
    var SuggestionData = $(this).data('SuggestionData');
    SelectedSuggestion = this;
    $(".phone-add-contact-name").val(SuggestionData.name[0] + " " + SuggestionData.name[1]);
    $(".phone-add-contact-number").val(SuggestionData.number);
    $(".phone-add-contact-iban").val(SuggestionData.bank);
});