var key = null;
var updateRate = 3000;
var enabled = true;

function addLine(text, type) {
  var $elem = $('<li/>').addClass(type).html(text);
  $('#status').append($elem);
}

function Good(text) {
  addLine(text, 'good');
}

function Bad(text) {
  addLine(text, 'bad')
}

function removeLine(id) {
  $('#' + id).remove();
}

function getViolations() {
  function reschedule(time) {
    if (!enabled) {
      $('#update').html('disabled');
      return;
    }

    updateRate = time;
    setTimeout(getViolations, updateRate);
    $('#update').html('waiting..');
  }

  function success(data) {
    messages = data.messages;
    $.each(messages, function(key, val) { 
      if (val.indexOf("OK ") == 0) {
        Good(val.substring(4));
      } else {
        Bad(val); 
      }
    });
    reschedule(data.update_rate);
  }

  function error(jqXHR, textStatus, errorThrown) {
    Bad("Error accessing server for updates...");
    reschedule(updateRate * 2);
  }

  $('#update').html('updating..');

  $.ajax({
    url: '/violations',
    dataType: 'json',
    data: { 'key': key },
    cache: false,
    success: success,
    error: error
  });
}

$(document).ready(function(){
  removeLine('no_js');
  Good('Local script is working (as it should)');

  key = $('#status').attr('data_key');

  $('#sample').click(function() {
    $.getScript('http://google.com');
    return false;
  });

  getViolations();
});
