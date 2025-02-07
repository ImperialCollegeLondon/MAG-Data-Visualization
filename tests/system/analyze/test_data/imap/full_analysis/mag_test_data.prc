proc mag_test_data

declare VARIABLE $DURATION = 30
declare VARIABLE $PAUSE = 00:00:30

; ***Main body of the procedure***
begin

PRE:

start mag_pwr_on_tonormal_lab MRAMSLOT1
wait 00:01:00

TEST:

; Burst 64-8
start mag_science Burst, UNCHANGED, UNCHANGED, UNCHANGED, UNCHANGED, UNCHANGED, UNCHANGED, $DURATION
wait $PAUSE

; FIB Range
start mag_change_range FIB, RANGE2

; Normal 2-2
start mag_verif_science Normal, HZ_2, HZ_2
wait $PAUSE

; FOB Range
start mag_change_range FOB, RANGE2

; Burst 128-128
start mag_science Burst, HZ_128, HZ_128, SECS_2, UNCHANGED, UNCHANGED, UNCHANGED, $DURATION
wait $PAUSE

FINISH:
endproc
