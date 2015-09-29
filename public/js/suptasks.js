var Suptasks = {
  timer: 0,

  incrementTimer: function() { 
    Suptasks.timer = Suptasks.timer + 1; 
  },

  updateView: function() {
    var inputs = document.getElementsByClassName('timer-inputs');
    for (i = 0; i < inputs.length; i++) {
      inputs[i].value = Suptasks.timer;
    };
  },

  startStopWatch: function() {
    stopWatch = window.setInterval(function() { Suptasks.incrementTimer(); Suptasks.updateView() }, 6000);
  },

  stopStopWatch: function() {
    window.clearInterval(stopWatch);
  }
};


window.onload = function() {
  Suptasks.startStopWatch();
};
