$(function(){

    $('button[type=submit]').click(function(){
        $.post('/show_answer', {value:$(this).val()}, function(msg){
            var msg = JSON.parse(msg);
            $(msg.cell_id).replaceWith(msg.html);
            if (msg.questions_completed == msg.total_questions) {
              $('#quiz').css( "margin", "0px" );
              $('#quiz').prepend('<div class="alert alert-info">You have finished! You scored ' +
                msg.correct_amount + ' out of ' + msg.total_questions +
                '. Choose level for a new game.</div>');
            }
            else {
              $('form:first *:input[type!=hidden]:first').focus();
            }
        });
        return false;
    });

    $('input[type=text]').keypress(function (e) {
      if (e.which == 13) {
        $.post('/check_answer', {user_answer:$(this).val(), question: this.id}, function(msg){
          var msg = JSON.parse(msg);
          if (msg.correct == true) {
            $(msg.cell_id).replaceWith(msg.html);
            if (msg.questions_completed == msg.total_questions) {
              if (msg.correct_amount == msg.total_questions) {
                $('td.success').effect("pulsate", {times: 1}, 1500);
                $('#quiz').css( "margin", "0px" );
                $('#quiz').prepend('<div class="alert alert-success">Well Done! You scored full marks - ' +
                  msg.correct_amount + ' out of ' + msg.total_questions +
                  '. Maybe time to try the next level!</div>');
              }
              else {
                $('#quiz').css( "margin", "0px" );
                $('#quiz').prepend('<div class="alert alert-info">You have finished! You scored ' +
                  msg.correct_amount + ' out of ' + msg.total_questions + '.</div>');
              }
            }
            else {
              $('form:first *:input[type!=hidden]:first').focus();
            }
          }
          else {
            $(msg.cell_id).addClass("pass");
            $(msg.cell_id).effect( "bounce", { times: 3 }, "slow" );
          }
        });
        return false;
      }
    });
});
