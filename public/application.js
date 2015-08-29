$(function(){

    $('button[type=submit]').click(function(){
        $.post('show_answer', {value:$(this).val()}, function(msg){
            var json_returned = JSON.parse(msg);
            $(json_returned.cell_id).replaceWith(json_returned.html);
            $('form:first *:input[type!=hidden]:first').focus();
        });
        return false;
    });

    $('input[type=text]').keypress(function (e) {
      if (e.which == 13) {
        $.post('check_answer', {user_answer:$(this).val(), answer_lookup: this.id}, function(msg){
          var json_returned = JSON.parse(msg);
            if (json_returned.correct == true) {
              $(json_returned.cell_id).replaceWith(json_returned.html);
              $('form:first *:input[type!=hidden]:first').focus();
            }
            else {
              $(json_returned.cell_id).addClass("pass");
              $(json_returned.cell_id).effect( "bounce", { times: 3 }, "slow" );
            }
        });
        return false;
      }
    });
});
