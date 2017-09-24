#!/usr/bin/env bash
PUBLIC="public"
ROUTERIP="192.168.2.1"
SNMPVER="2c" # SNMP version
MAXVAL="4294967296" # 2^32 for int32
IFACE="14" # Number of the interface to track. Discover with snmpwalk
DIR="/usr/local/rrd"
LOG="$DIR/db/log"

echo "$(tail -1000 $LOG)" > $LOG

source $DIR/db/weigths.conf

UPTIME="$(snmpget -v $SNMPVER -c $PUBLIC -O0qtv $ROUTERIP DISMAN-EVENT-MIB::sysUpTimeInstance)"
DATAOUT="$(snmpget -v $SNMPVER -c $PUBLIC -Oqv $ROUTERIP IF-MIB::ifOutOctets.$IFACE)"
DATAIN="$(snmpget -v $SNMPVER -c $PUBLIC -Oqv $ROUTERIP IF-MIB::ifInOctets.$IFACE)"

if [ $UPTIME ] && [ $DATAOUT ] && [ $DATAIN ]; then
	LASTUPTIME=$(cat $DIR/db/uptime)
	LASTDATAOUT=$(cat $DIR/db/dataout)
	LASTDATAIN=$(cat $DIR/db/datain)
	LASTHOUR=$(cat $DIR/db/hour)
	DATAUSAGE=$(cat $DIR/db/datausage)
	INUSAGE=$DATAIN
	OUTUSAGE=$DATAOUT

	if [ $LASTUPTIME -lt $UPTIME ]; then # Router not restarted
		INUSAGE=$(echo "$INUSAGE - $LASTDATAIN" | bc)
		OUTUSAGE=$(echo "$OUTUSAGE - $LASTDATAOUT" | bc)

		if [ $DATAIN -lt $LASTDATAIN ]; then # Counter overflowed
			INUSAGE=$(echo "$INUSAGE + $MAXVAL" | bc)
			echo "[$(date)] INFO: Counter overflow. Reason: $LASTDATAIN > $DATAIN" >> $LOG
		fi

		if [ $DATAOUT -lt $LASTDATAOUT ]; then # Counter overflowed
			OUTUSAGE=$(echo "$OUTUSAGE + $MAXVAL" | bc)
			echo "[$(date)] INFO: Counter overflow. Reason: $LASTDATAOUT > $DATAOUT" >> $LOG
		fi
	else
		echo "[$(date)] WARN: Router has problably restarted. Reason: $LASTUPTIME > $UPTIME. Some data lost." >> $LOG
	fi



	INUSAGE=$(echo "$INUSAGE * ${INWEIGTHS[$LASTHOUR]}" | bc)
	OUTUSAGE=$(echo "$OUTUSAGE * ${OUTWEIGTHS[$LASTHOUR]}" | bc)
	DATAUSAGE=$(echo "$DATAUSAGE + $OUTUSAGE + $INUSAGE" | bc)

	echo $UPTIME > $DIR/db/uptime
	echo $DATAOUT > $DIR/db/dataout
	echo $DATAIN > $DIR/db/datain
	echo $DATAUSAGE > $DIR/db/datausage

	rrdupdate $DIR/bandwidth.rrd N:$DATAIN:$DATAOUT
else
	echo "[$(date)] ERROR: no response from router" >> $LOG
fi

echo $(date +%-H) > $DIR/db/hour
