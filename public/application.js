$(function(){
  var answers;
  var enter_key = 13;

  $.get( "/answers", function( msg ) {
    answers = JSON.parse( msg );
  });

  $( "button[type=submit]" ).click( function(e) {
    e.preventDefault();
    var question = this.id;
    var answer = getAnswer( question );
    updateCell( question, answer, "incorrect" );
    checkFinished();
  });

  $( "input[type=text]" ).keypress( function ( e ) {

    if ( e.which == enter_key ) {
      e.preventDefault();
      var user_answer = $( this ).val();
      var question = this.id;
      var answer = getAnswer( question );

      if ( user_answer === answer ) {
        updateCell( question, answer, "correct" );
        checkFinished();
      } else {
        $( "#" + question + "_cell" ).attr('class', 'incorrect');
        $( "#" + question + "_cell" ).effect( "bounce", { times: 3 }, "slow" );
      }
    }
  });

  function getAnswer(question) {
    var route = question.split(/_(.+)/)[0];
    var column = question.split(/_(.+)/)[1];
    return answers[route][column];
  }

  function updateCell( question, answer, css_class ) {
    $( "#" + question ).replaceWith( answer );
    $( "#" + question + "_cell button" ).remove();
    $( "#" + question + "_cell" ).attr('class', css_class);
  }

  function checkFinished() {
    if ( $( "input" ).length ) {
      $( "input:first" ).focus();
    } else {
      gameOverMessage();
    }
  }

  function gameOverMessage() {
    if ( $( ".incorrect" ).length ) {
      standardGameOverMessage();
    } else {
      fullMarksMessage();
    }
  }

  function standardGameOverMessage() {
    var alert_content = "You have finished! You scored " + score_text() + ".";

    $( "#alert-space" ).replaceWith( $( "<div></div>", {
      class: "alert alert-info",
      text: alert_content
    }));
  }

  function fullMarksMessage() {
    var alert_content = "Well Done! You scored full marks - " +
      score_text() + ". Time to try the next level!";

    $( "td.correct" ).effect( "pulsate", { times: 1 }, 1500 );
    $( "#quiz" ).css( "margin", "0px" );
    $( "#alert-space" ).replaceWith( $( "<div></div>", {
      class: "alert alert-success",
      text: alert_content
    }));
  }

  function score_text() {
    return correct_amount() + " out of " + total_questions();
  }

  function correct_amount() {
    return $( ".correct" ).length;
  }

  function total_questions() {
    return correct_amount() + $( ".incorrect" ).length;
  }
});
