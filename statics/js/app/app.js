angular.module('DouDATA', []).
  config(['$routeProvider', function($routeProvider) {
    $routeProvider.
      when('/events/:locId', {templateUrl: '/doudata/templates/map.html',   controller: EventsMapCtrl}).
      otherwise({redirectTo: '/phones'});
  }]);

function EventsMapCtrl($scope, $http, $routeParams){

  var locId = $routeParams.locId,
      pos = {
        bj: [39.93, 116.40]
      },
      eventsData = new google.maps.MVCArray(),
      latlng, myOptions, map, styles, heatmap, tem;

  initialize(pos[locId]);

  function initialize(pos) {
    latlng = new google.maps.LatLng(pos[0], pos[1]);
    myOptions = {
      zoom: 12,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    styles = [{
      "stylers": [
        { "hue": "#0099ff" },
        { "lightness": 40 },
        { "saturation": -100 },
        { "gamma": 0.95 }
      ]
    }];

    heatmap = new google.maps.visualization.HeatmapLayer({
      map: map,
      data: eventsData,
      radius: 10,
      dissipate: false,
      maxIntensity: 8/*,
      gradient: [
        'rgba(0, 0, 0, 0)',
        'rgba(255, 255, 0, 0.50)',
        'rgba(255, 128, 0, 1.0)'
      ]*/
    });
    google.maps.event.addListener(map, 'tilesloaded', function() {
      $http.get('/doudata/json/events/'+ locId +'_heat.json').success(function(data){
        $scope.events = data;
        data.forEach(function(val, idx, arr){
          val[0] = val[0].split(' ');
          tem = val[3] * 1;
          while(tem >= 0){
            eventsData.push(new google.maps.LatLng(val[0][0], val[0][1]));
            tem -= 1;
          }
        });
      });
    });
    map.setOptions({styles: styles});
  }
}
EventsMapCtrl.$inject = ['$scope', '$http', '$routeParams'];
