$(document).on('click', '.garage-vehicle', function(e){
    e.preventDefault();
    
    $(".garage-homescreen").animate({
        left: -30+"vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: 0+"vh"
    }, 200);

    var Id = $(this).attr('id');
    var VehData = $("#"+Id).data('VehicleData');
    setTimeout(function(){
        $(".garage-cardetails-footer").css({"display":"block"});
    }, 250);
    SetupDetails(VehData);  
});

$(document).on('click', '.garage-cardetails-footer', function(e){
    e.preventDefault();

    $(".garage-homescreen").animate({
        left: 00+"vh"
    }, 200);
    $(".garage-detailscreen").animate({
        left: +30+"vh"
    }, 200);
    $(".garage-cardetails-footer").css({"display":"none"});
});

SetupGarageVehicles = function(Vehicles) {
    $(".garage-vehicles").html("");
    if (Vehicles != null) {
        $.each(Vehicles, function(i, vehicle){
            var Element = '<div class="garage-vehicle waves-effect waves-dark" id="vehicle-'+i+'"><div class="garage-vehicle-foto"><ion-icon name="car-sport"></ion-icon></div><div class="garage-vehicle-name"><span class="nome-do-carro">'+vehicle.fullname+'</span><span class="placa-do-carro">Placa: <strong class="placadocarro">'+vehicle.plate+'</strong></span></div></div>';
            
            $(".garage-vehicles").append(Element);
            $("#vehicle-"+i).data('VehicleData', vehicle);
        });
    }
}

SetupDetails = function(data) {
    $(".branditem").html(data.model);
    $(".modeloitem").html(data.brand);
    $(".placaitem").html(data.plate);
    $(".garagemitem").html(data.garage);
    $(".statusitem").html(data.state);
    $(".combustivelitem").html(Math.ceil(data.fuel)+"%");
    $(".motoritem").html(Math.ceil(data.engine / 10)+"%");
    $(".latariaitem").html(Math.ceil(data.body / 10)+"%");
}