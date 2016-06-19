$(function(){
  $( "button[type=submit]" ).click( function() {
    $.post( "/show_answer", { value: $( this ).val() }, function( msg ) {
      msg = JSON.parse( msg );
      $( msg.cell_id ).replaceWith( msg.html );
      checkFinished(msg);
    });
    return false;
  });

  $( 'input[type=text]' ).keypress( function ( e ) {
    if ( e.which == 13 ) {
      $.post( '/check_answer', { user_answer: $( this ).val(), question: this.id }, function( msg ) {
        msg = JSON.parse( msg );
        if ( msg.correct === true ) {
          $( msg.cell_id ).replaceWith( msg.html );
          checkFinished(msg);
        } else {
          $( msg.cell_id ).addClass( "pass" );
          $( msg.cell_id ).effect( "bounce", { times: 3 }, "slow" );
        }
      });
      return false;
    }
  });

  function checkFinished( msg ) {
    if ( msg.questions_completed === msg.total_questions ) {
      if ( msg.correct_amount === msg.total_questions ) {
        fullMarksMessage( msg );
      } else {
        gameOverMessage( msg );
      }
    } else {
      $( "form:first *:input[type!=hidden]:first" ).focus();
    }
  }

  function gameOverMessage( msg ) {
    var alert_content = "You have finished! You scored " + score_text( msg ) + ".";

    $( "#quiz" ).prepend( $( "<div></div>", {
      class: "alert alert-info",
      text: alert_content
    }));
  }

  function fullMarksMessage( msg ) {
    var alert_content = "Well Done! You scored full marks - " +
      score_text( msg ) + ". Time to try the next level!";

    $( "td.success" ).effect( "pulsate", { times: 1 }, 1500 );
    $( "#quiz" ).css( "margin", "0px" );
    $( "#quiz" ).prepend( $( "<div></div>", {
      class: "alert alert-success",
      text: alert_content
    }));
  }

  function score_text( msg ) {
    return msg.correct_amount + " out of " + msg.total_questions;
  }
});
