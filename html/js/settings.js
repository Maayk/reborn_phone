Reborn.Phone.Settings = {};
Reborn.Phone.Settings.Background = "default-cash";
Reborn.Phone.Settings.OpenedTab = null;
Reborn.Phone.Settings.Backgrounds = {
    'default-cash': {
        label: "IOS"
    }
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;


$(document).ready(function(){
    $("#ajuestes-pesquisar-input").on("keyup", function() {
        var value = $(this).val().toLowerCase();
        $(".ajustes-item").filter(function() {
          $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
        });
    });
});


function formatPhoneNumber(phoneNumberString) {
    var cleaned = ('' + phoneNumberString).replace(/\D/g, '')
    var match = cleaned.match(/^(1|)?(\d{3})(\d{3})(\d{4})$/)
    if (match) {
      var intlCode = (match[1] ? '+1 ' : '')
      return [intlCode, '(', match[2], ') ', match[3], '-', match[4]].join('')
    }
    return null
}



$(document).on('click', '#ios-voltar-menu', function(e){
    //console.log('resultando')
    $(".settings-background-tab").animate({
        left: 30+"vh"
    },200);
});



$(document).on('click', '.ajustes-item', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        $(".settings-"+PressedTab+"-tab").animate({
            left: 0+"vh"
        },200);
        // Reborn.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        Reborn.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "profilepicture") {
        Reborn.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        Reborn.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        //console.log('apertou')
        var checkBoxes = $(".numberrec-box");
        Reborn.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", Reborn.Phone.Data.AnonymousCall);

        if (!Reborn.Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Off');
        } else {
            $("#numberrecognition > p").html('On');
        }
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = Reborn.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        Reborn.Phone.Notifications.Add("fas fa-paint-brush", "Settings", Reborn.Phone.Settings.Backgrounds[Reborn.Phone.Settings.Background].label+" set!")
        Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+Reborn.Phone.Settings.Background+".png')"})
    } else {
        // Reborn.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Own background set!")
        NotifyInside('Plano de Fundo','Sistema','settings','Plano de Fundo alterado')
        Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+Reborn.Phone.Settings.Background+"')"});
    }

    $.post('http://reborn_phone/SetBackground', JSON.stringify({
        background: Reborn.Phone.Settings.Background,
    }))
});

Reborn.Phone.Functions.LoadMetaData = function(MetaData) {
    $(".profile-phone-foto").css({"background-image":"url('"+Reborn.Phone.Data.MetaData.profilepicture+"')"})
    $(".ajustes-atual-background").css({"background-image":"url('/html/img/backgrounds/default-cash.png')"})
    $(".ajustes-change-background").css({"background-image":"url('"+Reborn.Phone.Data.MetaData.background+"')"})
    if (MetaData.background !== null && MetaData.background !== undefined) {
        Reborn.Phone.Settings.Background = MetaData.background;
    } else {
        Reborn.Phone.Settings.Background = "default-cash";
    }

    var hasCustomBackground = Reborn.Phone.Functions.IsBackgroundCustom();

    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+Reborn.Phone.Settings.Background+".png')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+Reborn.Phone.Settings.Background+"')"});
    }

    if (MetaData.profilepicture == "default") {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+MetaData.profilepicture+'">');
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

Reborn.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(Reborn.Phone.Settings.Backgrounds, function(i, background){
        if (Reborn.Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

function FotoDePerfil() {
    const alert = document.createElement('ion-alert');
    alert.cssClass = 'alertas-ios-local';
    alert.keyboardClose = true;
    alert.header = 'Foto de Perfil';
    alert.mode = "ios"
    alert.inputs = [
        {
          placeholder: 'Link da Imagem'
        },
    ];
    alert.buttons = [
        {
          text: 'Cancelar',
          role: 'cancel',
          cssClass: 'secondary',
          handler: (blah) => {
            //console.log('clickou em cancelar');
          }
        }, {
          text: 'Alterar',
          handler: () => {
            var fotomudada = $(".alert-input").val()
            Reborn.Phone.Data.MetaData.profilepicture = $(".alert-input").val()
            $(".profile-phone-foto").css({"background-image":"url('"+fotomudada+"')"})
            $.post('http://reborn_phone/UpdateProfilePicture', JSON.stringify({
                profilepicture: fotomudada,
            }));
            NotifyInside('Foto de Perfil','Sistema','settings','Foto de Perfil alterada com sucesso!')
          }
        }
      ];
    document.getElementById("appendaqui").appendChild(alert);
    return alert.present();
}


function ImagemDeFundo() {
    const alert = document.createElement('ion-alert');
    alert.cssClass = 'alertas-ios-local';
    alert.header = 'Imagem de Fundo';
    alert.mode = "ios"
    alert.inputs = [
        {
          placeholder: 'Link da Imagem'
        },
    ];
    alert.buttons = [
        {
          text: 'Cancelar',
          role: 'cancel',
          cssClass: 'secondary',
          handler: (blah) => {
            //console.log('clickou em cancelar');
          }
        }, {
          text: 'Alterar',
          handler: () => {
            //console.log('clickou em alterar')
            var imagemdefundo = $(".alert-input").val()

            Reborn.Phone.Settings.Background = $(".alert-input").val();

            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });

            $(".ajustes-change-background").css({"background-image":"url('"+Reborn.Phone.Settings.Background+"')"});

            // $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
            // Reborn.Phone.Animations.TopSlideUp(".background-custom", 200, -23);

            var hasCustomBackground = Reborn.Phone.Functions.IsBackgroundCustom();
        
            if (hasCustomBackground === false) {
                Reborn.Phone.Notifications.Add("fas fa-paint-brush", "Settings", Reborn.Phone.Settings.Backgrounds[Reborn.Phone.Settings.Background].label+" set!")
                // Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
                $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+Reborn.Phone.Settings.Background+".png')"})
            } else {
                // Reborn.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Own background set!")
                NotifyInside('Plano de Fundo','Sistema','settings','Plano de Fundo alterado')
                // Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
                $(".phone-background").css({"background-image":"url('"+Reborn.Phone.Settings.Background+"')"});
            }
        
            $.post('http://reborn_phone/SetBackground', JSON.stringify({
                background: imagemdefundo,
            }))
            



          }
        }
      ];
    document.getElementById("appendaqui").appendChild(alert);
    return alert.present();
}
  





  

$(document).on('click', '.select-background', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');
    // if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            Reborn.Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            Reborn.Phone.Animations.TopSlideDown(".background-custom", 200, 30);
        }
    // }
});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();
    Reborn.Phone.Settings.Background = $(".custom-background-input").val();
    $(OldBackground).fadeOut(50, function(){
        $(OldBackground).remove();
    });
    $(".ajustes-change-background").css({"background-image":"url('"+Reborn.Phone.Settings.Background+"')"});
    $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    Reborn.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
    var hasCustomBackground = Reborn.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        Reborn.Phone.Notifications.Add("fas fa-paint-brush", "Settings", Reborn.Phone.Settings.Backgrounds[Reborn.Phone.Settings.Background].label+" set!")
        // Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+Reborn.Phone.Settings.Background+".png')"})
    } else {
        // Reborn.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Own background set!")
        NotifyInside('Plano de Fundo','Sistema','settings','Plano de Fundo alterado')
        // Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+Reborn.Phone.Settings.Background+"')"});
    }

    $.post('http://reborn_phone/SetBackground', JSON.stringify({
        background: Reborn.Phone.Settings.Background,
    }))
});


$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    Reborn.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedProfilePicture = null;
var PressedProfilePictureObject = null;
var OldProfilePicture = null;
var ProfilePictureIsChecked = null;

$(document).on('click', '#accept-profilepicture', function(e){
    e.preventDefault();
    var ProfilePicture = Reborn.Phone.Data.MetaData.profilepicture;
    if (ProfilePicture === "default") {
        Reborn.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Default portfolio is set!")
        Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        // Reborn.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Own profile picture set!")
        NotifyInside('Plano de Fundo','Sistema','settings','Plano de Fundo alterado')
        Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
        //console.log(ProfilePicture)
        $(".profile-phone-foto").css({"background-image":"url('"+ProfilePicture+"')"})
        // $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+ProfilePicture+'">');
    }
    $.post('http://reborn_phone/UpdateProfilePicture', JSON.stringify({
        profilepicture: ProfilePicture,
    }));
});

$(document).on('click', '#accept-custom-profilepicture', function(e){
    e.preventDefault();
    Reborn.Phone.Data.MetaData.profilepicture = $(".custom-profilepicture-input").val();
    $(OldProfilePicture).fadeOut(50, function(){
        $(OldProfilePicture).remove();
    });
    $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
    Reborn.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

$(document).on('click', '.profilepicture-option', function(e){
    e.preventDefault();
    PressedProfilePicture = $(this).data('profilepicture');
    PressedProfilePictureObject = this;
    OldProfilePicture = $(this).parent().find('.profilepicture-option-current');
    ProfilePictureIsChecked = $(this).find('.profilepicture-option-current');
    if (ProfilePictureIsChecked.length === 0) {
        if (PressedProfilePicture != "custom-profilepicture") {
            Reborn.Phone.Data.MetaData.profilepicture = PressedProfilePicture
            $(OldProfilePicture).fadeOut(50, function(){
                $(OldProfilePicture).remove();
            });
            $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            Reborn.Phone.Animations.TopSlideDown(".profilepicture-custom", 200, 13);
        }
    }
});

$(document).on('click', '#cancel-profilepicture', function(e){
    e.preventDefault();
    Reborn.Phone.Animations.TopSlideUp(".settings-"+Reborn.Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-profilepicture', function(e){
    e.preventDefault();
    Reborn.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});