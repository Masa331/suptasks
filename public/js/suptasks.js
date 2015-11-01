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

    var quickTimers = document.getElementsByClassName('quick-timer');
    for (i = 0; i < quickTimers.length; i++) {
      quickTimers[i].innerHTML = Suptasks.timer;
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
  },

  resetStopWatch: function() {
    Suptasks.timer = 0;
    sessionStorage.removeItem('suptasks_timer');
    Suptasks.updateView();
  }
};


window.onload = function() {
  Suptasks.renewStopWatchFromStore();
  Suptasks.updateView();
  Suptasks.startStopWatch();

  var timerForms = document.getElementsByClassName('time-records-form');
  if (timerForms.length > 0) {
    for (i = 0; i < timerForms.length; i++) {
      timerForms[i].addEventListener('submit', Suptasks.clearTimerStore);
    };
  };

  var durationReset = document.getElementById('duration-reset');
  if (durationReset) {
    durationReset.addEventListener('click', Suptasks.resetStopWatch);
  };
};
