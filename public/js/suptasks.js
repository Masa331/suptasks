var Suptasks = {
  timer: 0
};

Suptasks.incrementTimer = function() {
  Suptasks.timer = Suptasks.timer + 1;
};

Suptasks.updateView = function() {
  var inputs = document.getElementsByClassName('timer-inputs');
  for (i = 0; i < inputs.length; i++) {
    inputs[i].value = Suptasks.timer;
  };

  var tags = document.getElementsByClassName('timer-tags');
  for (i = 0; i < tags.length; i++) {
    tags[i].innerHTML = Suptasks.timer;
  };
};

Suptasks.startStopWatch = function() {
  stopWatch = window.setInterval(function() { Suptasks.incrementTimer(); Suptasks.updateView() }, 60000);
};

Suptasks.stopStopWatch = function() {
  window.clearInterval(stopWatch);
};

window.onload = function() {
  Suptasks.startStopWatch();
};
