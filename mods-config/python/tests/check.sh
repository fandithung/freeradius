blacklist=$(cat network.json | grep "blacklist" | cut -d ":" -f 2 | cut -d "[" -f 2 | cut -d "]" -f 1 | sed 's/"//g' | sed "s/,//g")
idx=0
mac=""
vlan=""
vlan_user=""
user=""
mac_multi=""
ALT="alt.json"
OUT="actual.log"
cat network.json | grep -v "blacklist" | head -n -1 > $ALT
echo ',"blacklist":[]}' >> $ALT
for b in $(echo $blacklist); do
    case $idx in
        0)
            mac=$b
            ;;
        1)
            vlan=$b
            ;;
        2)
            vlan_user=$b
            ;;
        3)
            user=$b
            ;;
        4)
            mac_multi=$b
            ;;
    esac
    idx=$((idx+1))
done

function test-objs()
{
    echo "$1 - $2"
    echo "==="
    for c in $(echo "network.json $ALT"); do
        echo "# $c"
        test-config $1 $2 $c
    done
}


function test-config()
{
    python2.7 ../utils/harness.py authorize User-Name=$1 Calling-Station-Id=$2 --json $3
}

function test-all()
{
    valid_mac="001122334455"
    test-objs $mac $mac
    test-objs vlan2.user6 "000011112222"
    test-objs vlan1.user4 $valid_mac
    test-objs vlan2.user1 $valid_mac
    test-objs vlan2.user2 $valid_mac
    test-objs vlan2.user3 $valid_mac
    test-objs vlan2.user6 $valid_mac
}

test-all > $OUT
