(final: prev: {
  # ags-agenda = inputs.ags-agenda.packages."${system}".default;
  waitport = final.writeShellScriptBin "waitport" ''
    # This script takes a host and port, checks if it is responding, and will retry
    # it every 10th of a second for up to 1 minute before failing.
    host=$1
    port=$2
    tries=600
    for i in `seq $tries`; do
        if ${final.netcat}/bin/nc -z $host $port > /dev/null ; then
          # Ready
          exit 0
        fi
        ${final.coreutils}/bin/sleep 0.1
    done
    # FAIL
    exit -1
  '';
})
