$(function(){

  $('.ajax_request').click(function() {
    $(this).addClass('hidden');
    $(this).next().removeClass('hidden');
  });

});