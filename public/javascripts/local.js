var key = null;
var updateRate = 3000;

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
  function success(data) {
    messages = data.messages;

    $.each(messages, function(key, val) { Bad(val); });

    updateRate = data.update_rate;
    setTimeout(getViolations, updateRate);
  }

  function error(jqXHR, textStatus, errorThrown) {
    console.log('Error !');
    Bad(textStatus);

    updateRate = updateRate * 2;
    setTimeout(getViolations, updateRate);
  }

  console.log('Starting ajax..');

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
