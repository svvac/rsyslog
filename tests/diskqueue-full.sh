#!/bin/bash
# checks that nothing bad happens if a DA (disk) queue runs out
# of configured disk space
# addd 2017-02-07 by RGerhards, released under ASL 2.0
. $srcdir/diag.sh init

. $srcdir/diag.sh generate-conf
. $srcdir/diag.sh add-conf '
module(load="../plugins/omtesting/.libs/omtesting")
global(workDirectory="test-spool")
main_queue(queue.filename="mainq" queue.maxDiskSpace="4m"
	queue.maxfilesize="1m"
	queue.timeoutenqueue="300000"
	queue.lowwatermark="5000"
)

module(load="../plugins/imtcp/.libs/imtcp")
$InputTCPServerRun 13514

template(name="outfmt" type="string"
	 string="%msg:F,58:2%,%msg:F,58:3%,%msg:F,58:4%\n")

:omtesting:sleep 0 5000
:msg, contains, "msgnum:" action(type="omfile" template="outfmt"
			         file="rsyslog.out.log")
'
. $srcdir/diag.sh startup
. $srcdir/diag.sh injectmsg 0 20000
ls -l test-spool
. $srcdir/diag.sh shutdown-when-empty
. $srcdir/diag.sh wait-shutdown
ls -l test-spool
. $srcdir/diag.sh seq-check 0 19999

. $srcdir/diag.sh exit
