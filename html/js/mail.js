var OpenedMail = null;

$(document).on('click', '.mail', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 30+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: 0+"vh"
    }, 300);

    var MailData = $("#"+$(this).attr('id')).data('MailData');
    Reborn.Phone.Functions.SetupMail(MailData);

    OpenedMail = $(this).attr('id');
});

$(document).on('click', '.mail-back', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
    OpenedMail = null;
});



$(document).ready(function(){
    $("#inbox-pesquisar-input").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".mail").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});

$(document).on('click', '.mail-button-lido', function(e){
    e.preventDefault();
    //console.log('clickei aqui?')
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('http://reborn_phone/AcceptMailButton', JSON.stringify({
        buttonEvent: MailData.button.buttonEvent,
        buttonData: MailData.button.buttonData,
        mailId: MailData.mailid,
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

$(document).on('click', '.mail-button-deletar', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('http://reborn_phone/RemoveMail', JSON.stringify({
        mailId: MailData.mailid
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});

Reborn.Phone.Functions.SetupMails = function(Mails) {
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
    var MessageTime = Hourssssss + ":" + Minutessss;

    // $("#mail-header-mail").html(Reborn.Phone.Data.PlayerData.charinfo.firstname+"."+Reborn.Phone.Data.PlayerData.charinfo.lastname+"@reborncity.com");
    $("#mail-header-lastsync").html(MessageTime);
    if (Mails !== null && Mails !== undefined) {
        if (Mails.length > 0) {
            $(".mail-list").html("");
            $.each(Mails, function(i, mail){
                var date = new Date(mail.date);
                var DateString = date.getDay()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
                var element = '<div class="mail waves-effect waves-dark" id="mail-'+mail.mailid+'"><span class="mail-sender" style="font-weight: bold;">'+mail.sender+'</span> <div class="mail-text"><p>'+mail.message+'</p></div> <div class="mail-time">'+DateString+'  <i class="material-icons dp48 email-seta-entrar">chevron_right</i></div></div>';
    
                $(".mail-list").append(element);
                $("#mail-"+mail.mailid).data('MailData', mail);
            });
        } else {
            $(".mail-list").html('<p class="nomails">Você não tem emails</p>');
        }

    }
}

var MonthFormatting = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "November", "Dezembro"];

Reborn.Phone.Functions.SetupMail = function(MailData) {
    var date = new Date(MailData.date);
    var DateString = date.getDay()+" "+MonthFormatting[date.getMonth()]+" "+date.getFullYear()+" "+date.getHours()+":"+date.getMinutes();
    $(".mail-subject").html(MailData.sender);
    $(".mail-pessoa").html(Reborn.Phone.Data.PlayerData.charinfo.firstname+"."+Reborn.Phone.Data.PlayerData.charinfo.lastname+"@reborn.com");
    $(".mail-date").html("<p>"+DateString+"</p>");
    $(".mail-content").html("<p>"+MailData.message+"</p>");

    var AcceptElem = '<ion-icon class="mail-button-deletar" name="trash"></ion-icon>';
    var RemoveElem = '<ion-icon class="mail-button-lido" name="folder"></ion-icon>';

    $(".opened-mail-footer").html("");    

    if (MailData.button !== undefined && MailData.button !== null) {
        $(".opened-mail-footer").append(AcceptElem);
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"50%"});
    } else {
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"100%"});
    }
}

// Advert JS

$(document).on('click', '#novo-anuncio', function(e){
    e.preventDefault();
    const alert = document.createElement('ion-alert');
    alert.cssClass = 'alertas-ios-local';
    alert.keyboardClose = true;
    alert.header = 'Anunciar';
    alert.mode = "ios"
    alert.inputs = [
        {
            name: 'paragraph',
            id: 'paragraph',
            type: 'textarea',
            placeholder: 'Digite seu Anuncio aqui'
        },
    ];
    alert.buttons = [
        {
          text: 'Cancelar',
          role: 'cancel',
          cssClass: 'secondary',
          handler: (blah) => {
          }
        }, {
          text: 'Anunciar',
          handler: () => {
            var Advert = $(".alert-input").val()
            if (Advert !== "") {
                $.post('http://reborn_phone/NovoAnuncio', JSON.stringify({
                    message: Advert,
                }));
            } else {
                console.log('notificação falando que voce precisa digitar alguma coisa')
            }
          }
        }
      ];
    document.getElementById("appendaqui").appendChild(alert);
    return alert.present();
});


$(document).on('click', '.copiar-numero-celular', function(e){
    e.preventDefault();
    var numerocelular = $(this).data('numcelular');
    SetupCall(numerocelular);
});

Reborn.Phone.Functions.RefreshAdverts = function(Adverts) {
        if (Adverts.length > 0 || Adverts.length == undefined) {
            $(".advert-list").html("");
            var linkimagem = 'https://i.imgur.com/bMpeJRl.png'
            $.each(Adverts, function(i, advert){
                var element = '<div class="advert waves-effect waves-light"> <div class="avatar-advert" style="background-image: url('+linkimagem+')"></div><p>'+advert.message+'</p><div class="advert-sender"><p>'+advert.name+'</p><ion-icon class="copiar-numero-celular tooltipped" name="call" data-numcelular="'+advert.number+'"></ion-icon></div></div>';
                $(".advert-list").append(element).hide().fadeIn(500);
            });
        } else {
            $(".advert-list").html("");
            var element = '<div class="advert"><p>Nenhum anuncio encontrado.</p></div>';
            $(".advert-list").append(element).hide().fadeIn(500);
        }
}
