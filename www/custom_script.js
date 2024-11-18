// Show the loader when Shiny is busy
$(document).on('shiny:busy', function() {
  $("#loading-screen").fadeIn();
});

// Hide the loader when Shiny is idle
$(document).on('shiny:idle', function() {
  $("#loading-screen").fadeOut();
});
