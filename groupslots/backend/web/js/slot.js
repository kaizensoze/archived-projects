'use strict';

/////////////////////////////////////////////////////////////////////////////////// GLOBAL FUNCTIONS

// Execute an action
function fbExecuteAction(oSettings) {
	// Define local variables
	var	nArgumentsExpected = 1,
		oAjaxSettings,
		sExpectedDatatype = 'object',
		sKey;
	
	// Enforce the expected number of arguments
	if(arguments.length !== nArgumentsExpected) {
		error(nArgumentsExpected + ' arguments expected, ' + arguments.length + ' encountered');
		return false;
	}
	
	// Validate argument datatype
	if(typeof(oSettings) !== sExpectedDatatype) {
		error('argument #1 is not of type "' + sExpectedDatatype + '"');
		return false;
	}
	
	// Validate object member datatypes
	for(sKey in oSettings) {
		if(oSettings.hasOwnProperty(sKey)) {
		// if(oSettings.hasOwnProperty(sKey) === true) {
			switch(sKey) {
				case 'oAjaxSettings':
				case 'sAction':
					switch(sKey.substr(0, 1)) {
						case 'o':
							sExpectedDatatype = 'object';
							break;
						case 's':
							sExpectedDatatype = 'string';
							break;
						default:
							return;
					}
					if(typeof(oSettings[sKey]) !== sExpectedDatatype) {
						error(
							'object member "' + sKey + ' is not of type "' + sExpectedDatatype + '"'
						);
						return false;
					}
					break;
				default:
					error('unexpected object member "' + sKey + '" encountered');
					return false;
			}
		}
	}
	
	// Apply restrictions and default values for important, undefined object members of oAjaxSettings
	oAjaxSettings = oSettings.oAjaxSettings;
	oAjaxSettings.cache = (oAjaxSettings.cache === undefined ? false : oAjaxSettings.cache);
	if((typeof(oAjaxSettings.data) === 'object' && typeof(oAjaxSettings.data.action) === 'string') || (typeof(oAjaxSettings.data) === 'string' && oAjaxSettings.data.indexOf('action=') !== -1)) {
		error('oAjaxSettings.data cannot define an "action" key-value pair');
		return false;
	}
	oAjaxSettings.dataType = (oAjaxSettings.dataType === undefined ? 'text' : oAjaxSettings.dataType);
	if(oAjaxSettings.error === undefined) {
		oAjaxSettings.error = function(jXHR) {
			error(
				'action "' + oSettings.sAction + '" failed with error message "' + jXHR.status +
				': ' + jXHR.statusText + '"'
			);
		};
	}
	oAjaxSettings.timeout = (oAjaxSettings.timeout === undefined ? 30000 : oAjaxSettings.timeout);
	oAjaxSettings.type = (oAjaxSettings.type === undefined ? 'POST' : oAjaxSettings.type);
	if(window.location.pathname.search(/slot\.php$/) !== -1) {
		oSettings.oAjaxSettings.url = 'admin/';
	} else if(window.location.pathname.search(/facebook\/index\.php$/) !== -1) {
		oSettings.oAjaxSettings.url = "/admin/";
	} else {
		oSettings.oAjaxSettings.url = '';
	}
	oSettings.oAjaxSettings.url += 'service.php?action=' + oSettings.sAction;
	
	// Make an AJAX request that will execute the desired action
	$.ajax(oAjaxSettings);
	return true;
}

function convertDate(dateTime) {
    var	t = dateTime.split(/[\- :]/);
    return (new Date(t[0], t[1]-1, t[2], t[3], t[4], t[5]));
}

function error(sMessage, sPrefix) {
	if(sPrefix === undefined) {
		sPrefix = 'ERROR: ';
	}
	window.alert(sPrefix + sMessage);
}





/////////////////////////////////////////////////////////////////////////////// DOCUMENT READY EVENT
$(document).ready(function() {
	$('#logout').click(function(oEvent) {
		oEvent.preventDefault();
		fbExecuteAction({
			sAction : 'logout',
			oAjaxSettings : {
				data : {card_id : $('#card_id').val()},
				success : function(sResponse) {
					if(sResponse === 'ERROR') {
						window.alert('logout failed');
						return;
					}
					window.location.reload();
				}
			}
		});
	});
});