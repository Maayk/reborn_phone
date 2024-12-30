ons.bootstrap()
.controller('NotificationController', function($scope) {
  $scope.alert = function(material) {
    ons.notification.alert({
      message: 'An error has occurred!',
      modifier: material ? 'material' : undefined
    });
  }

  $scope.confirm = function(material) {
    var mod = material ? 'material' : undefined;
    
    ons.notification.confirm({
      message: 'Are you sure you want to continue?',
      modifier: mod,
      callback: function(idx) {
        switch (idx) {
          case 0:
            ons.notification.alert({
              message: 'You pressed "Cancel".',
              modifier: mod
            });
            break;
          case 1:
            ons.notification.alert({
              message: 'You pressed "OK".',
              modifier: mod
            });
            break;
        }
      }
    });
  }

  $scope.prompt = function(material) {
    var mod = material ? 'material' : undefined;
    ons.notification.prompt({
      message: "Please enter your age",
      modifier: mod,
      callback: function(age) {
        ons.notification.alert({
          message: 'You are ' + parseInt(age || 0) + ' years old.',
          modifier: mod
        });
      }
    });
  }
});