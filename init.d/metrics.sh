#!/bin/sh
### BEGIN INIT INFO
# Provides:          metrics.sh
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop metrics.sh
# Description:       Controls the metrics daemon "metrics.sh"
### END INIT INFO

SCRIPT=<SCRIPT>
RUNAS=<USER>
CONFIG_FILE=<CONFIG_FILE>
ARGS="-c $CONFIG_FILE"
NAME=metrics.sh

PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/log/$NAME.log

# Exit if the package is not installed
[ -x "$DAEMON" ] || exit 0

start() {
  if [ -f $PIDFILE ] && kill -0 $(cat $PIDFILE); then
    echo 'Service already running' >&2
    return 1
  fi
  echo 'Starting service...' >&2
  local CMD="$SCRIPT &> \"$LOGFILE\" & echo \$!"
  su -c "$CMD $ARGS" $RUNAS > "$PIDFILE"
  echo 'Service started' >&2
}

stop() {
  if [ ! -f "$PIDFILE" ] || ! kill -0 $(cat "$PIDFILE"); then
    echo 'Service not running' >&2
    return 1
  fi
  echo 'Stopping service...' >&2
  kill -15 $(cat "$PIDFILE") && rm -f "$PIDFILE"
  echo 'Service stopped' >&2
}

status() {
  printf "%-50s" "Checking $NAME..."
  if [ -f $PIDFILE ]; then
    PID=$(cat $PIDFILE)
    if [ -z "$(ps axf | grep ${PID} | grep -v grep)" ]; then
      printf "%s\n" "The process appears to be dead but pidfile still exists"
    else
      echo "Running, the PID is $PID"
    fi
  else
    printf "%s\n" "Service not running"
  fi
}

uninstall() {
  echo -n 'Are you really sure you want to uninstall this service? That cannot be undone. [yes|No] '
  local SURE
  read SURE
  if [ "$SURE" = "yes" ]; then
    stop
    rm -f "$PIDFILE"
    echo "Notice: log file was not removed: '$LOGFILE'" >&2
    update-rc.d -f <NAME> remove
    rm -fv "$0"
  fi
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  uninstall)
    uninstall
    ;;
  restart)
    stop
    start
    ;;
  *)
    echo "Usage: $0 {start|stop|status|restart|uninstall}"
esac
