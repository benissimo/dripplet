// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


/**
* Returns an XMLHttp instance to use for asynchronous
* downloading. This method will never throw an exception, but will
* return NULL if the browser does not support XmlHttp for any reason.
* @return {XMLHttpRequest|Null}
*/
function createXmlHttpRequest() {
 try {
   if (typeof ActiveXObject != 'undefined') {
     return new ActiveXObject('Microsoft.XMLHTTP');
   } else if (window["XMLHttpRequest"]) {
     return new XMLHttpRequest();
   }
 } catch (e) {
   changeStatus(e);
 }
 return null;
};

/**
* This functions wraps XMLHttpRequest open/send function.
* It lets you specify a URL and will call the callback if
* it gets a status code of 200.
* @param {String} url The URL to retrieve
* @param {Function} callback The function to call once retrieved.
*/
function downloadUrl(url, callback) {
 var status = -1;
 var request = createXmlHttpRequest();
 if (!request) {
   return false;
 }

 request.onreadystatechange = function() {
   if (request.readyState == 4) {
     try {
       status = request.status;
     } catch (e) {
       // Usually indicates request timed out in FF.
     }
     if (status == 200) {
       callback(request.responseText, request.status);
       request.onreadystatechange = function() {};
     }
   }
 }
 request.open('GET', url, true);
 try {
   request.send(null);
 } catch (e) {
   changeStatus(e);
 }
};

function downloadScript(url) {
  var script = document.createElement('script');
  script.src = url;
  document.body.appendChild(script);
}

WH_LoadMarkerFeedRadioButtonFire = function () {
	var sort = $$('input:checked[type=radio]').pluck('value')[0]; 
	//window.alert('fire sort='+sort); 
	WH_LoadMarkerFeed(map, window.WH_mgr, sort);
}

WH_LoadMarkerFeedRadioButtonFireIfZoomed = function () {
  var zoom = map.getZoom();
  if (zoom > 3) {
    WH_LoadMarkerFeedRadioButtonFire();
  }
}

var eventlistener = null;

function WH_LoadMarkerFeed(map,mgr,feed_type,old_id_to_skip) {

  if (eventlistener == null) {
    //bounds_changed is too sensitive. makes too many calls. idle is when to make the call.
    eventlistener = google.maps.event.addListener(map, "idle", function() {
      //setTimeout(WH_LoadMarkerFeedRadioButtonFireIfZoomed, 10);//timeout useful?
      WH_LoadMarkerFeedRadioButtonFireIfZoomed();//timeout useful?
      }
    );
    return;
  }

	window.WH_feed_type = feed_type;
	//feed_type: all, score, visits, comments
	var bounds = map.getBounds();
	var southWest = bounds.getSouthWest();
	var northEast = bounds.getNorthEast();
	feed_url = '/en/water_points.json?sort='+encodeURIComponent(feed_type)+'&bounds='+southWest.lat() + ',' + southWest.lng() + 'x' + northEast.lat() + ',' + northEast.lng();
	//GDownloadUrl(feed_url,WH_reset_mgr);
	downloadUrl(feed_url,function(data, responseCode){
	/*
	* NB: this function needs to be defined like this, inline, so as to create a
	* closure on the 'mgr' variable. otherwise it has no access to it on callback.
	*/
  pathArray = window.location.pathname.split('/');
  var lang = pathArray[1];

	var blueIcon = new google.maps.MarkerImage("/images/markers/blue.png");
	var lightblueIcon = new google.maps.MarkerImage("/images/markers/lightblue.png");
	var greenIcon = new google.maps.MarkerImage("/images/markers/green.png");
	var redIcon = new google.maps.MarkerImage("/images/markers/red.png");
	var orangeIcon = new google.maps.MarkerImage("/images/markers/orange.png");
	var yellowIcon = new google.maps.MarkerImage("/images/markers/yellow.png");
	var pinkIcon = new google.maps.MarkerImage("/images/markers/pink.png");
	var violetIcon = new google.maps.MarkerImage("/images/markers/violet.png");
	
	markerOptions = {};
	switch (window.WH_feed_type) {
		case 'all':
	 		markerOptions.icon=blueIcon;
			break;
		case 'visits':
 			markerOptions.icon=greenIcon;
			break;					
		case 'comments':
	 		markerOptions.icon=orangeIcon;
			break;
		case 'score':
			markerOptions.icon=yellowIcon;
			break;					
		default: //search...
			markerOptions.icon=redIcon;		
	}

  //data is null??
	var markers = data.evalJSON();//prototype.js eval function

	//mgr.clearMarkers();//unset manager's markers to load new ones.


	var batch = [];
	for (var i = 0; i < markers.length ; i++ ) {
		var wp = markers[i].water_point;
		var lat = wp.lat;
		var lng = wp.lng;
		if (lat && lng) {
		  //alert('id:'+wp.id+' id_to_skip:'+id_to_skip);
			if (id_to_skip && wp.id && id_to_skip === wp.id) {
			  //alert('match');
				//id of marker already loaded. do not overwrite. skip it.
				continue;
			}
			var latlng = new google.maps.LatLng(parseFloat(lat),parseFloat(lng));

			//feed_type available if needed...
			if (wp.note == null) {
			  wp.note = ''
		  }
			var note = wp.note; //.length > 160 ? wp.note.substr(0,160)+'<a href="/'+lang+'/water_points/'+wp.id+'">...</a>' : wp.note;
      var info_content = '<div id="popup"><b><a href="/'+lang+'/water_points/'+wp.id+'">'+wp.title+'</a></b><br/>'+note+'</div>';
      m_marker = createMarker(markerOptions.icon, info_content, latlng )


			batch.push(m_marker);
		}
	} //end for

	mgr.clearMarkers();//unset manager's markers to load new ones.

	//alert('batch size: '+batch.length)
	mgr.addMarkers(batch,0);
	mgr.refresh();
	});//end downloadUrl's anonymous callback...
	
}


function createMarker(iconimg, info_content, latlng) {
	var m_marker = new google.maps.Marker({
	  position: latlng,
	  icon: iconimg,
	  map: map
	  });
		  
	google.maps.event.addListener(m_marker, "click", function() {
	  if (typeof(infowindow) != 'undefined') {
	    infowindow.close();
    }
    infowindow.setContent(info_content);
	  infowindow.open(map.getStreetView().getVisible() ? map.getStreetView() : map, m_marker);
	});
	return m_marker;
}

function WH_address_search(query,showMarker) {
	
  //street view does not update when map relocates. so better to hide street view each time a search is performed.
  map.getStreetView().setVisible(false);

	var redIcon = new google.maps.MarkerImage("/images/markers/red.png");

	
	//window.alert('1) map query:'+query);
	//example of lat lon query = 43.345000,12.803061
	//window.alert('1) map query:'+query);
  var latlonquery;
  latlonquery = query.match(/([-+]?\d\d?(?:\.\d{0,8})?)[ ,]([-+]?\d\d?(?:\.\d{0,8})?)/);
  //latlonquery = query.match(/(\d+).*(\d+)/);
  
  //showMarker is set on normal searches (from main map page only)
  //showMarker is NOT set for the confirm location page (marker interferes with map centering)
  //lat lon queries should be centered precisely on lat lon query.
  if (!showMarker && latlonquery) {
    //map.setCenter(new GLatLng(43.345000,12.803061),13);
    map.setCenter(new google.maps.LatLng(latlonquery[1],latlonquery[2]),13);
    return false;
  } else {

  }
  
	
	if (geocoder) {
	  geocoder.geocode({'address': query}, function (results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      map.setCenter(results[0].geometry.location);
  	  if (window.search_marker) {
  		  window.search_marker.setMap(null);
  	  }
	
  		if (showMarker) {
        window.search_marker = new google.maps.Marker({
            map: map, 
            icon: redIcon,
            position: results[0].geometry.location
          });
     

		  // Desirable? Leave as clickable...?
//		  window.search_marker.bindInfoWindowHtml(place.address);
        infowindow.setContent('<div id="popup">' + results[0].formatted_address + '</div>');


        google.maps.event.addListener(window.search_marker, 'click', function() {
          if (infowindow) infowindow.close();
          infowindow.open(map,window.search_marker);
        });
        infowindow.open(map,window.search_marker);

	      // Add address information to marker
//	      window.search_marker.openInfoWindowHtml(place.address);
		  //window.alert('3) marker created');
		  }
	  } else {
			//error handling on fail?
			
	  }
	      
	}//end callback for geocode
	);//end geocode call...
}//end if geocoder

}

function toggleMap() {
  
  $('map').toggleClassName('fullscreen');
  
  $('map_toggle').toggleClassName('fullscreen');
  $('sort_filter').toggleClassName('fullscreen');
  $('logos').toggleClassName('fullscreen');
  $('mapsearch').toggleClassName('fullscreen');
  
  //google writes position=relative inline so a class definition toggle isn't sufficient. 
  //have to toggle this property manually
  if ($('map').style.position == 'relative') {
    $('map').style.position = 'fixed';
  } else {
    $('map').style.position = 'relative';
  }
  
  google.maps.event.trigger(map, 'resize'); 


}


function WH_reg_terms(form) {
	if (form.terms.checked){
		//alert(this.terms.checked);
		//return false;
		return true;
	}else{
		alert('Please accept the terms of service.');
		return false;
	}
}


//http://wiki.recaptcha.net/index.php/How_to_change_reCAPTCHA_colors
var RecaptchaOptions = {
   theme : 'clean'
};



