SetupLawyers = function(data) {
    $(".lawyers-list").html("");

    if (data.length > 0) {
        $.each(data, function(i, lawyer){
            var element = '<div class="lawyer-list" id="lawyerid-'+i+'"> <div class="lawyer-list-firstletter">' + (lawyer.name).charAt(0).toUpperCase() + '</div> <div class="lawyer-list-fullname">' + lawyer.name + '</div> <div class="lawyer-list-call"><i class="fas fa-phone"></i></div> </div>'
            $(".lawyers-list").append(element);
            $("#lawyerid-"+i).data('LawyerData', lawyer);
        });
    } else {
        var element = '<div class="lawyer-list"><div class="no-lawyers">There are no lawyers available.</div></div>'
        $(".lawyers-list").append(element);
    }
}

$(document).on('click', '.lawyer-list-call', function(e){
    e.preventDefault();

    var LawyerData = $(this).parent().data('LawyerData');
    
    var cData = {
        number: LawyerData.phone,
        name: LawyerData.name
    }

    $.post('http://reborn_phone/CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: Reborn.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== Reborn.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        if (Reborn.Phone.Data.AnonymousCall) {
                            //checkpoint
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
                            $(".lawyers-app").css({"display":"none"});
                            Reborn.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            Reborn.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);
    
                        CallData.name = cData.name;
                        CallData.number = cData.number;
                    
                        Reborn.Phone.Data.currentApplication = "phone-call";
                    } else {
                        Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You are already busy!");
                    }
                } else {
                    Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is talking!");
                }
            } else {
                Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not talking!");
            }
        } else {
            Reborn.Phone.Notifications.Add("fas fa-phone", "Phone", "You cannot call your own number!");
        }
    });
});