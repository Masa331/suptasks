var Suptasks = {
  timer: {
    setDuration: function(duration) { window.localStorage.setItem('suptasksDuration', duration) },
    getDuration: function() { return Number(window.localStorage.getItem('suptasksDuration')) },
    clearDuration: function() { return window.localStorage.removeItem('suptasksDuration') },
    interval_id: null,

    incrementValue: function(callback) {
      Suptasks.timer.setDuration(Number(Suptasks.timer.getDuration()) + 1);
      callback();
    },

    start: function(callback) {
      Suptasks.timer.interval_id = window.setInterval(function() { Suptasks.timer.incrementValue(callback) }, 60000);
    },

    stop: function() {
      window.clearInterval(Suptasks.timer.interval_id);

      var value = Suptasks.timer.getDuration();
      Suptasks.timer.setDuration(0);
      return value;
    }
  },

  task: {
    setId: function(id) { window.localStorage.setItem('suptasksTaskId', id) },
    getId: function() { return window.localStorage.getItem('suptasksTaskId') },
    clearId: function() { return window.localStorage.removeItem('suptasksTaskId') },

    submitTime: function(time) {
      var http = new XMLHttpRequest();
      var params = "task_id=" + Suptasks.task.getId().split('-')[1] + "&duration=" + time;
      http.open("POST", "time_records", true);

      http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http.setRequestHeader("Content-length", params.length);
      http.setRequestHeader("Connection", "close");

      http.send(params);
    }
  },

  toggleTimer: function() {
    var newTaskId = this.id;

    if (Suptasks.task.getId() == null) {
      Suptasks.startTimer(newTaskId);
    } else if(Suptasks.task.getId() == newTaskId) {
      Suptasks.stopTimer();
    } else {
      Suptasks.stopTimer();
      Suptasks.startTimer(newTaskId);
    };
  },

  startTimer: function(taskId) {
    Suptasks.timer.start(function() {
      document.getElementById(taskId).children[0].innerHTML = Suptasks.timer.getDuration();
    });
    Suptasks.task.setId(taskId);
    document.getElementById(taskId).classList.add('green');
    document.getElementById(taskId).children[0].innerHTML = Suptasks.timer.getDuration();
  },

  stopTimer: function() {
    document.getElementById(Suptasks.task.getId()).classList.remove('green');
    document.getElementById(Suptasks.task.getId()).children[0].innerHTML = '';
    Suptasks.task.submitTime(Suptasks.timer.stop());
    Suptasks.task.clearId();
  }
};

window.onload = function() {
  var timerStarters = document.getElementsByClassName('timer-starter');
  if (timerStarters.length > 0) {
    for (i = 0; i < timerStarters.length; i++) {
      timerStarters[i].addEventListener('click', Suptasks.toggleTimer);
    };
  };

  var taskClosers = document.getElementsByClassName('task-closer');
  if (taskClosers.length > 0) {
    for (i = 0; i < taskClosers.length; i++) {
      taskClosers[i].addEventListener('click', Suptasks.stopTimer);
    };
  };

  if (Suptasks.task.getId() && document.getElementById(Suptasks.task.getId())) {
    Suptasks.startTimer(Suptasks.task.getId());
  } else {
    Suptasks.timer.clearDuration();
    Suptasks.task.clearId();
  };
};
