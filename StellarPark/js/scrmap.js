function initMap() {
  var senaLocation = { lat:  7.117192172198442, lng: -73.1167041882077 };
  var mapOptions = {
      center: senaLocation,
      zoom: 15,
      mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  var map = new google.maps.Map(document.getElementById("map"), mapOptions);
  var marker = new google.maps.Marker({
      position: senaLocation,
      map: map,
      title: "SENA Bucaramanga"
  });
  marker.addListener("click", function() {
      document.getElementById("info-panel").style.display = "block";
  });
}

function closeInfoPanel() {
  document.getElementById("info-panel").style.display = "none";
}
