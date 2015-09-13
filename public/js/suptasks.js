var Suptasks = {};

Suptasks.incrementTimer = function() {
  var input = document.getElementById('timer');
  var value = ~~timer.value;
  value = value + 1;

  input.value = value;
};

Suptasks.startStopWatch = function() {
  stopWatch = window.setInterval(function() { Suptasks.incrementTimer() }, 60000);
};

Suptasks.stopStopWatch = function() {
  window.clearInterval(stopWatch);
};

Suptasks.startStopWatch();
