var FoccusedBank = null;

$(document).on('click', '.bank-app-account', function(e){
    var copyText = document.getElementById("iban-account");
    copyText.select();
    copyText.setSelectionRange(0, 99999);
    document.execCommand("copy");

    // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "Bank account No. copied!", "#badc58", 1750);
    // NotifyInside('Banco','Sistema','settings','Este aplicativo não está disponivel')
});

var CurrentTab = "accounts";




$(document).on('click', '#filtro-todas-faturas', function(e){
    var pesquisa = $(this).val().toLowerCase();
    //console.log(pesquisa)
    $(".history-item").filter(function() {
      $(this).toggle($(this).text().toLowerCase().indexOf(pesquisa) > -1);
    });
});

// FORMATAÇÀO DO VALOR NESSA PORRA 


  

$(document).on('click', '#filtro-entradas', function(e){
    var pesquisa = $(this).val().toLowerCase();
    //console.log(pesquisa)
    $(".history-item").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(pesquisa) > -1);
    });
});

$(document).on('click', '#filtro-saidas', function(e){
    var pesquisa = $(this).val().toLowerCase();
    //console.log(pesquisa)
    $(".history-item").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(pesquisa) > -1);
    });
});




$(document).on('click', '.bank-app-header-button', function(e){
    e.preventDefault();

    var PressedObject = this;
    var PressedTab = $(PressedObject).data('headertype');

    if (CurrentTab != PressedTab) {
        var PreviousObject = $(".bank-app-header").find('[data-headertype="'+CurrentTab+'"]');

        if (PressedTab == "invoices") {
            $(".bank-app-"+CurrentTab).animate({
                left: -30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);
        } else if (PressedTab == "accounts") {
            $(".bank-app-"+CurrentTab).animate({
                left: 30+"vh"
            }, 250, function(){
                $(".bank-app-"+CurrentTab).css({"display":"none"})
            });
            $(".bank-app-"+PressedTab).css({"display":"block"}).animate({
                left: 0+"vh"
            }, 250);
        }

        $(PreviousObject).removeClass('bank-app-header-button-selected');
        $(PressedObject).addClass('bank-app-header-button-selected');
        setTimeout(function(){ CurrentTab = PressedTab; }, 300)
    }
})

//alterar aqui
Reborn.Phone.Functions.DoBankOpen = function() {
    // Reborn.Phone.Data.PlayerData.money.bank = (Reborn.Phone.Data.PlayerData.money.bank).toFixed();
    var formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    });    
    
    $(".bank-app-account-number").val(Reborn.Phone.Data.PlayerData.charinfo.account);
    $("#nome-titular-conta").html(Reborn.Phone.Data.PlayerData.charinfo.firstname+' '+Reborn.Phone.Data.PlayerData.charinfo.lastname);
    $("#numero-conta-banco").html(Reborn.Phone.Data.PlayerData.charinfo.account);
    $(".saldo-atual").html(formatter.format(Reborn.Phone.Data.PlayerData.money.bank));
    $(".avatar-banco").css({"background-image":"url('"+Reborn.Phone.Data.MetaData.profilepicture+"')"})
    $(".saldo-atual").data('balance', Reborn.Phone.Data.PlayerData.money.bank);

    // $(".bank-app-loaded").css({"display":"none", "padding-left":"30vh"});
    // $(".bank-app-accounts").css({"left":"30vh"});
    // $(".qbank-logo").css({"left": "0vh"});
    // $("#qbank-text").css({"opacity":"0.0", "left":"9vh"});
    // $(".bank-app-loading").css({
    //     "display":"block",
    //     "left":"0vh",
    // });
    // setTimeout(function(){
    //     CurrentTab = "accounts";
    //     $(".qbank-logo").animate({
    //         left: -12+"vh"
    //     }, 500);
    //     setTimeout(function(){
    //         $("#qbank-text").animate({
    //             opacity: 1.0,
    //             left: 14+"vh"
    //         });
    //     }, 100);
    //     setTimeout(function(){
    //         $(".bank-app-loaded").css({"display":"block"}).animate({"padding-left":"0"}, 300);
    //         $(".bank-app-accounts").animate({left:0+"vh"}, 300);
    //         $(".bank-app-loading").animate({
    //             left: -30+"vh"
    //         },300, function(){
    //             $(".bank-app-loading").css({"display":"none"});
    //         });
    //     }, 1500)
    // }, 500)
    // setTimeout(function(){
    //     $(".phone-footer").css({"display":"block"});
    // }, 500);
}

$(document).on('click', '#numero-conta-banco', function (e) {
    e.preventDefault();
    // var textocopiar = $('#numero-conta-banco').html()
    var numeroconta = Reborn.Phone.Data.PlayerData.charinfo.account

    navigator.clipboard.numeroconta.then(function() {
        // //console.log('Async: Copying to clipboard was successful!');
      }, function(err) {
        // console.error('Async: Could not copy text: ', err);
    });
});

$(document).on('click', '.bank-app-account-actions', function(e){
    Reborn.Phone.Animations.TopSlideDown(".bank-app-transfer", 400, 0);
});

$(document).on('click', '#cancel-transfer', function(e){
    e.preventDefault();

    Reborn.Phone.Animations.TopSlideUp(".bank-app-transfer", 400, -100);
});

$(document).on('click', '#accept-transfer', function(e){
    e.preventDefault();

    var iban = $("#bank-transfer-iban").val();
    var amount = $("#bank-transfer-amount").val();
    var amountData = $(".saldo-atual").data('balance');
    var formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    });   
    if (iban != "" && amount != "") {
        if (amountData >= amount) {
            $.post('http://reborn_phone/TransferMoney', JSON.stringify({
                iban: iban,
                amount: amount
            }), function (data) {
                // //console.log(data.CanTransfer)
                if (data.CanTransfer) {
                    $("#bank-transfer-iban").val("");
                    $("#bank-transfer-amount").val("");
                    data.NewAmount = (data.NewAmount).toFixed();
                    $(".saldo-atual").html("&#36; "+data.NewAmount);
                    $(".saldo-atual").data('balance', data.NewAmount);
                    // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "&#36; "+amount+",- transferred!", "#badc58", 1500);
                    NotifyInside('Banco','Transferencia','banco','Você transferiu '+formatter.format(amount))
                } else {
                    // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "You do not have enough balance!", "#badc58", 1500);
                    NotifyInside('Banco','Transferencia','banco','Você não tem esse valor na sua conta.')
                }
            })
            Reborn.Phone.Animations.TopSlideUp(".bank-app-transfer", 400, -100);
        } else {
            // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "You do not have enough balance!", "#badc58", 1500);
            NotifyInside('Banco','Transferencia','banco','Você não tem esse valor na sua conta.')
        }
    } else {
        // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "fill out all fields!", "#badc58", 1750);
        NotifyInside('Banco','Algo de errado','banco','Preencha todos os campos.')
    }
});

GetInvoiceLabel = function(type) {
    retval = null;
    if (type == "request") {
        retval = "Payment Request";
    }

    return retval
}

$(document).on('click', '.pay-invoice', function(event){
    event.preventDefault();

    var InvoiceId = $(this).parent().parent().attr('id');
   
    var InvoiceData = $("#"+InvoiceId).data('invoicedata');
    var BankBalance = $(".saldo-atual").data('balance');
    var formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    });

    if (BankBalance >= InvoiceData.amount) {
        $.post('http://reborn_phone/PayInvoice', JSON.stringify({
            sender: InvoiceData.sender,
            amount: InvoiceData.amount,
            invoiceId: InvoiceData.invoiceid,
        }), function (CanPay) {
            //console.log(CanPay)
            if (CanPay) {
                $("#"+InvoiceId).animate({
                    left: 30+"vh",
                }, 300, function(){
                    setTimeout(function(){
                        $("#"+InvoiceId).remove();
                    }, 100);
                });
                // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "&#36;"+InvoiceData.amount+" paid!", "#badc58", 1500);
                NotifyInside('Banco','Fatura','banco','Você pagou uma fatura de '+formatter.format(InvoiceData.amount))
                var amountData = $(".saldo-atual").data('balance');
                var NewAmount = (amountData - InvoiceData.amount).toFixed();
                $("#bank-transfer-amount").val(NewAmount);
                $(".saldo-atual").data('balance', NewAmount);
            } else {
                // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "You do not have enough balance!", "#badc58", 1500);
                NotifyInside('Banco','Fatura','banco','Você não tem este saldo disponível')
            }
        });
    } else {
        // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "You do not have enough balance!", "#badc58", 1500);
        NotifyInside('Banco','Fatura','banco','Você não tem este saldo disponível')
    }
});

function addCommas(nStr) {
    nStr += '';
    var x = nStr.split('.');
    var x1 = x[0];
    var x2 = x.length > 1 ? '.' + x[1] : '';
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(x1)) {
      x1 = x1.replace(rgx, '$1' + '.<span style="margin-left: 0px; margin-right: 1px;"/>' + '$2');
    }
    return x1 + x2;
}

// $(document).on('click', '.decline-invoice', function(event){
//     event.preventDefault();
//     var InvoiceId = $(this).parent().parent().attr('id');
//     var InvoiceData = $("#"+InvoiceId).data('invoicedata');
//     var formatter = new Intl.NumberFormat('en-US', {
//         style: 'currency',
//         currency: 'USD',
//     });  
//     $.post('http://reborn_phone/DeclineInvoice', JSON.stringify({
//         sender: InvoiceData.sender,
//         amount: InvoiceData.amount,
//         invoiceId: InvoiceData.invoiceid,
//     }));
//     $("#"+InvoiceId).animate({
//         left: 30+"vh",
//     }, 300, function(){
//         setTimeout(function(){
//             $("#"+InvoiceId).remove();
//         }, 100);
//     });
//     // Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "&#36;" + InvoiceData.amount + " paid!", "#badc58", 1500);
//     NotifyInside('Banco','Fatura','banco','Você pagou uma fatura de '+formatter.format(InvoiceData.amount))
// });

Reborn.Phone.Functions.LoadBankInvoices = function (invoices) {
    var formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    });   
    if (invoices !== null) {
        $(".lista-de-faturas").html("");

        $.each(invoices, function(i, invoice){
            var Elem = '<div class="bank-app-invoice" id="invoiceid-'+i+'"><div class="bank-app-invoice-title">Fatura#'+invoice.id+'</div><div class="invoice-sender-detail">Enviado por: <span class="sender-detail-name">'+invoice.name+'</span></div><div class="invoice-detalhes">'+invoice.type+'</div><div class="bank-app-invoice-amount">'+formatter.format(invoice.amount)+'</div><div class="bank-app-invoice-buttons"><i class="fas fa-check-circle pay-invoice"></i></div></div>';

            $(".lista-de-faturas").append(Elem);
            $("#invoiceid-"+i).data('invoicedata', invoice);
        });
    }
}


Reborn.Phone.Functions.CarregandoFaturas = function (faturas) {
    var formatter = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    });   
    if (faturas !== null) {
        //console.log('carregou as faturas')
        $(".transactions-list").html("");
        $.each(faturas, function (i, fatura) {
            //console.log(fatura.idfatura)
            if (fatura.tipo === "1") {
                var tipofatura = "+"
                var iconeitem = 'wallet'
                var corvalor = 'style="color: #0FA464;"'
            } else if (fatura.tipo === "2") {
                var tipofatura = "-"
                var iconeitem = 'arrow-undo'
                var corvalor = ''
            }else if (fatura.tipo === "3") {
                var tipofatura = "+"
                var iconeitem = 'wallet'
                var corvalor = 'style="color: #0FA464;"'
            }else if (fatura.tipo === "4") {
                var tipofatura = "-"
                var iconeitem = 'arrow-undo'
                var corvalor = ''
            }else if (fatura.tipo === "5") {
                var tipofatura = "+"
                var iconeitem = 'wallet'
                var corvalor = 'style="color: #0FA464;"'
            }else if (fatura.tipo === "6") {
                var tipofatura = "-"
                var iconeitem = 'arrow-undo'
                var corvalor = ''
            }else if (fatura.tipo === "7") {
                var tipofatura = "-"
                var iconeitem = 'arrow-undo'
                var corvalor = ''
            }
            var Elem = '<div class="history-item waves-effect waves-dark" id="faturaid-'+fatura.idfatura+'"><div class="history-item-type"><ion-icon name="'+iconeitem+'-outline"></ion-icon></div><div class="history-item-titulo">'+fatura.titulo+'</div><div class="history-item-descricao">'+fatura.descricao+'</div><div class="history-item-valor" '+corvalor+'>'+tipofatura+' '+formatter.format(fatura.valor)+'</div></div>';

            $(".transactions-list").append(Elem);
            // $("#invoiceid-"+i).data('invoicedata', invoice);
        });
    }
}

Reborn.Phone.Functions.LoadContactsWithNumber = function(myContacts) {
    var ContactsObject = $(".bank-app-my-contacts-list");
    $(ContactsObject).html("");
    var TotalContacts = 0;

    $("#bank-app-my-contact-search").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".bank-app-my-contacts-list .bank-app-my-contact").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });

    if (myContacts !== null) {
        $.each(myContacts, function(i, contact){
            var RandomNumber = Math.floor(Math.random() * 6);
            var ContactColor = Reborn.Phone.ContactColors[RandomNumber];
            var ContactElement = '<div class="bank-app-my-contact" data-bankcontactid="'+i+'"> <div class="bank-app-my-contact-firstletter">'+((contact.name).charAt(0)).toUpperCase()+'</div> <div class="bank-app-my-contact-name">'+contact.name+'</div> </div>'
            TotalContacts = TotalContacts + 1
            $(ContactsObject).append(ContactElement);
            $("[data-bankcontactid='"+i+"']").data('contactData', contact);
        });
    }
};


// FUNÇÕES DE PAGINAS 

$(document).on('click', '#banco-pagina-home', function(e){
    // Reborn.Phone.Animations.TopSlideDown(".bank-app-transfer", 400, 0);
    e.preventDefault();
    $(".faturas-container").fadeOut('middle')
    $(".transf-container").fadeOut('fast')
    $(".bank-profile-container").fadeOut('fast')

    setTimeout(function(){
        $(".transactions-recentes").fadeIn('fast')
    }, 500);
});

function TransfValueRange(myValue){
    document.getElementById("currentValue").innerHTML = myValue;
  }

$(document).on('click', '#banco-pagina-faturas', function(e){
    // Reborn.Phone.Animations.TopSlideDown(".bank-app-transfer", 400, 0);
    e.preventDefault();

    $(".transactions-recentes").fadeOut('fast')
    $(".transf-container").fadeOut('fast')
    $(".bank-profile-container").fadeOut('fast')
    
    setTimeout(function(){
        $(".faturas-container").fadeIn('middle')
    }, 500);
});

$(document).on('click', '#banco-pagina-transf', function(e){
    // Reborn.Phone.Animations.TopSlideDown(".bank-app-transfer", 400, 0);
    e.preventDefault();

    $(".transactions-recentes").fadeOut('fast')
    $(".faturas-container").fadeOut('fast')
    $(".bank-profile-container").fadeOut('fast')
    
    setTimeout(function(){
        $(".transf-container").fadeIn('middle')
    }, 500);
});

$(document).on('click', '#banco-pagina-perfil', function(e){
    // Reborn.Phone.Animations.TopSlideDown(".bank-app-transfer", 400, 0);
    e.preventDefault();

    $(".transactions-recentes").fadeOut('fast')
    $(".faturas-container").fadeOut('fast')
    $(".transf-container").fadeOut('fast')
    
    setTimeout(function(){
        $(".bank-profile-container").fadeIn('middle')
    }, 500);
});





$(document).on('click', '.bank-app-my-contacts-list-back', function(e){
    e.preventDefault();

    Reborn.Phone.Animations.TopSlideUp(".bank-app-my-contacts", 400, -100);
});

$(document).on('click', '.bank-transfer-mycontacts-icon', function(e){
    e.preventDefault();

    Reborn.Phone.Animations.TopSlideDown(".bank-app-my-contacts", 400, 0);
});

$(document).on('click', '.bank-app-my-contact', function(e){
    e.preventDefault();
    var PressedContactData = $(this).data('contactData');

    if (PressedContactData.iban !== "" && PressedContactData.iban !== undefined && PressedContactData.iban !== null) {
        $("#bank-transfer-iban").val(PressedContactData.iban);
    } else {
        Reborn.Phone.Notifications.Add("fas fa-university", "COA Bank", "There is no # tied to this contact!", "#badc58", 2500);
    }
    Reborn.Phone.Animations.TopSlideUp(".bank-app-my-contacts", 400, -100);
});