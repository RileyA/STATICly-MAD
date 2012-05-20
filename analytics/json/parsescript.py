import json, sys
from datetime import datetime

if len(sys.argv) < 2:
    print "enter json file"
    sys.exit(0)
    
f = open(sys.argv[1]);
players = json.loads(f.read())

print "Number of players: %d" % len(players) 

for player in players: 
    print ""
    print "Player: %s" % player['uid']
    print "\tPage loads: %d" % len(player['pageloads'])
    print "\tLevels logged: %d" % len(player['levels'])
    
    levels = player['levels']
    for level in levels:
        print "\t\tLevel/'Quest' id: %s (%s)" % (level['qid'], datetime.fromtimestamp(level['log_q_ts']))
       
        actions = level['actions']
        for action in actions:
            print "\t\t\tTimestamp: %s, Action details: %s" % (action['ts'], action['a_detail'])
