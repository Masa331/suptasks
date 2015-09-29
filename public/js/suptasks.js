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

  updateTimerStore: function() {
    sessionStorage.setItem('suptasks_timer', Suptasks.timer);
  },

  stopWatchIntervalFunction: function() {
    Suptasks.incrementTimer();
    Suptasks.updateTimerStore();
    Suptasks.updateView();
  },

  startStopWatch: function() {
    stopWatch = window.setInterval(function() { Suptasks.stopWatchIntervalFunction() }, 60000);
  },

  clearTimerStore: function() {
    sessionStorage.removeItem('suptasks_timer');
  },

  renewStopWatchFromStore: function() {
    if (sessionStorage.getItem('suptasks_timer')) {
      Suptasks.timer = ~~sessionStorage.getItem('suptasks_timer');
    };
  }
};


window.onload = function() {
  Suptasks.renewStopWatchFromStore();
  Suptasks.updateView();
  Suptasks.startStopWatch();

  var form = document.getElementById('time-records-form');
  if (form) {
    form.addEventListener('submit', Suptasks.clearTimerStore);
  };
};
