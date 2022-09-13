STAMP_AMOUNT=10000000
STAMP_DEPTH=21
BYTES_PER_SPAM=$((100*1000*1000))
ATTEMPTS=$((1+1))
timestamp=$(date +%s)

t=1
while [ $t -le $ATTEMPTS ]
do
  echo "creating stamp..."
  stamp=$(curl -s -X POST "http://localhost:1635/stamps/$STAMP_AMOUNT/$STAMP_DEPTH" | jq .batchID | tr -d '"')
  echo $stamp
  x=1
  d=false
  while [ $d = false ]
  do
    use=$(curl -s http://localhost:1635/stamps/$stamp| jq -e '.usable')
    if [ $use == "true" ];
    then
      filename=tmpuploadfile-$(date +"%s")
      dd if=/dev/urandom bs=$BYTES_PER_SPAM count=1 status=none > "/tmp/$filename"
      ls -la /tmp/$filename
      x=$(( $x + 1 ))
      o=$(curl -s -X POST "http://localhost:1633/bzz?name=tmpuploadfile" -H "accept: application/json, text/plain, */*" -H "content-type: application/octet-stream" -H "Swarm-Deferred-Upload: false" -H "swarm-postage-batch-id: $stamp" -H "user-agent: bee-js/3.2.0" --data "@/tmp/$filename")
      echo $o
      if [ $(echo $o | jq -e '.code') == "402" ];
      then
	echo $x
	d=true
	sleep 1 
      fi
      u=$(curl -s http://localhost:1635/stamps/$stamp| jq -e '.utilization')
    else
      sleep 2
    fi
  done
  echo "welcomed depth $STAMP_DEPTH $BYTES_PER_SPAM bytes $x times $(($x*$BYTES_PER_SPAM))" >> "welcomes/welcome-$STAMP_DEPTH-$BYTES_PER_SPAM-$timestamp.log"
  t=$(( $t + 1 ))
done
