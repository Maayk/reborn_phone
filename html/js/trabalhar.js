TrabalhosInfos = function(data) {
     var grupo = data
     console.log(grupo)
}

$(document).ready(function (){
     window.addEventListener('message', function (event) {
          var reborn = event.data
          if (reborn.condicao == true){
               console.log(reborn.condicao)
               $('.trabalhar-loading').fadeOut(250);
               $('.leader-nome').html(reborn.nome + '#'+reborn.idgrupo);
               $('.job-cargo').html(reborn.cargo);
               $('.trabalhar-leader-info').fadeIn(250);
               console.log('client-js: builda a tela de procurando job')
          }
          if (reborn.adicionando == true){
               if (reborn.slot == "1"){
                    $('#slot1').fadeIn(250);
                    $('#slotname1').html(reborn.mnome);
                    $('#slotcargo1').html(reborn.mcargo);
               }
               if (reborn.slot == "2"){
                    $('#slot2').fadeIn(250);
                    $('#slotname2').html(reborn.mnome);
                    $('#slotcargo2').html(reborn.mcargo);
               }
               if (reborn.slot == "3"){
                    $('#slot3').fadeIn(250);
                    $('#slotname3').html(reborn.mnome);
                    $('#slotcargo3').html(reborn.mcargo);
               }
          }
     });
});


$(document).on('click', '#criar-grupo', function(e){
     e.preventDefault();
     console.log('aguardando 3 segundos')
     $('.trabalhar-button').fadeOut(0);
     $('.trabalhar-loading').fadeIn(500);
     setTimeout(function(){
          $.post('http://reborn_phone/reborn:CriarGrupo');
     }, 1600);
 });