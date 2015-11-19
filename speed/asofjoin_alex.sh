#!/bin/bash
if test $# -lt 2; then
  echo "Usage: asofjoin_dvtr <LeftArray> <RightArray>"
  exit 1
fi

randstr="f557cd193ad4cc53" #$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 16)
A="asof_larger_$randstr"
B="asof_smaller_$randstr"
dims="Symbol_index=0:*,100,0, timestamp=0:*,2160000,0"

iquery -naq "remove($A)" >/dev/null 2>&1
iquery -naq "remove($B)" >/dev/null 2>&1

# Redimension the bigger quotes array (first argument)
echo ""
echo "### Storing attributes of A into a large ntuple"

# remove the temp array
iquery -naq "remove(${A})" > /dev/null 2>&1

iquery -naq "create array ${A} <nt1:ntuple null>[$dims]" >/dev/null 2>&1
time iquery -naq "
store(
  project(
    apply(left_array,
      nt1,
      ntuple_33(
        timestamp,
        id,
        eventType,
        BidPrc1,
        BidPrc2,
        BidPrc3,
        BidPrc4,
        BidPrc5,
        BidQty1,
        BidQty2,
        BidQty3,
        BidQty4,
        BidQty5,
        AskPrc1,
        AskPrc2,
        AskPrc3,
        AskPrc4,
        AskPrc5,
        AskQty1,
        AskQty2,
        AskQty3,
        AskQty4,
        AskQty5,
        BidCnt1,
        BidCnt2,
        BidCnt3,
        BidCnt4,
        BidCnt5,
        AskCnt1,
        AskCnt2,
        AskCnt3,
        AskCnt4,
        AskCnt5,
        left_timestamp
      )
    ), 
  nt1),
  ${A}
)
" 

echo "......."

# Redimension the smaller array

# get the smaller array's attribute schema:
smaller=$(echo $2 | sed -e "s/'/\\\\'/g")
echo "smaller="
echo $smaller
attrs="<$(iquery -aq "show('filter($smaller,true)','afl')" | tail -n 1 | cut -d '<' -f 2 | cut -d '>' -f 1)>"
echo "attrs="
echo $attrs

iquery -naq "create array $B <b: bool null>[$dims]" 
iquery -naq "
store(
  project(
    apply($2,
      b, bool(null)
    ), 
    b 
  ),  
$B
)
" 

echo ""
echo "### Creating the merged array"
iquery -aq "remove(tmp_merged2)" > /dev/null 2>&1
iquery -naq "
create TEMP array tmp_merged2
< nt1:ntuple null,
 b:bool null>
[$dims]"
time iquery -naq "
store(
 merge(
  join($A,$B),
  apply($A, b, iif(true, bool(missing(1)), bool(null))),
  project(apply($B, 
              nt1, iif(true, ntuple(missing(1)), ntuple(null))
          ),
          nt1,
          b
    )
  ),
 tmp_merged2
)"
echo "......."

echo ""
echo "### Doing the asof cumulation and joining with the left array"
iquery -naq "remove(asof_new_temp1)" > /dev/null 2>&1
iquery -naq "remove(asof_new_temp)" > /dev/null 2>&1
time iquery -naq "
store(
      join(
        $2,
        cumulate(
         project(
          tmp_merged2,
          nt1
         ),
         asof_cumulator(nt1),
         timestamp
        )
      ),
  asof_new_temp1)"

echo "### For timing, run consume() while projecting out the necessary attributes"
time iquery -aq "
consume(
  project(
    apply(
      asof_new_temp1,
      idA, int64(nth_tupleval(nt1_asof_cumulator, 0)), 
      eventTypeA, int8(nth_tupleval(nt1_asof_cumulator, 1)), 
      BidPrc1, nth_tupleval(nt1_asof_cumulator, 2), 
      BidPrc2, nth_tupleval(nt1_asof_cumulator, 3),
      BidPrc3, nth_tupleval(nt1_asof_cumulator, 4),
      BidPrc4, nth_tupleval(nt1_asof_cumulator, 5),
      BidPrc5, nth_tupleval(nt1_asof_cumulator, 6),
      BidQty1, int32(nth_tupleval(nt1_asof_cumulator, 7)),
      BidQty2, int32(nth_tupleval(nt1_asof_cumulator, 8)),
      BidQty3, int32(nth_tupleval(nt1_asof_cumulator, 9)),
      BidQty4, int32(nth_tupleval(nt1_asof_cumulator, 10)),
      BidQty5, int32(nth_tupleval(nt1_asof_cumulator, 11)),
      AskPrc1, nth_tupleval(nt1_asof_cumulator, 12),
      AskPrc2, nth_tupleval(nt1_asof_cumulator, 13),
      AskPrc3, nth_tupleval(nt1_asof_cumulator, 14),
      AskPrc4, nth_tupleval(nt1_asof_cumulator, 15),
      AskPrc5, nth_tupleval(nt1_asof_cumulator, 16),
      AskQty1, int32(nth_tupleval(nt1_asof_cumulator, 17)),
      AskQty2, int32(nth_tupleval(nt1_asof_cumulator, 18)),
      AskQty3, int32(nth_tupleval(nt1_asof_cumulator, 19)),
      AskQty4, int32(nth_tupleval(nt1_asof_cumulator, 20)),
      AskQty5, int32(nth_tupleval(nt1_asof_cumulator, 21)),
      BidCnt1, int32(nth_tupleval(nt1_asof_cumulator, 22)),
      BidCnt2, int32(nth_tupleval(nt1_asof_cumulator, 23)),
      BidCnt3, int32(nth_tupleval(nt1_asof_cumulator, 24)),
      BidCnt4, int32(nth_tupleval(nt1_asof_cumulator, 25)),
      BidCnt5, int32(nth_tupleval(nt1_asof_cumulator, 26)),
      AskCnt1, int32(nth_tupleval(nt1_asof_cumulator, 27)),
      AskCnt2, int32(nth_tupleval(nt1_asof_cumulator, 28)),
      AskCnt3, int32(nth_tupleval(nt1_asof_cumulator, 29)),
      AskCnt4, int32(nth_tupleval(nt1_asof_cumulator, 30)),
      AskCnt5, int32(nth_tupleval(nt1_asof_cumulator, 31)),
      left_timestamp, int32(nth_tupleval(nt1_asof_cumulator, 32))
    ), 
    idA,
    eventTypeA,
    BidPrc1,
    BidPrc2,
    BidPrc3,
    BidPrc4,
    BidPrc5,
    BidQty1,
    BidQty2,
    BidQty3,
    BidQty4,
    BidQty5,
    AskPrc1,
    AskPrc2,
    AskPrc3,
    AskPrc4,
    AskPrc5,
    AskQty1,
    AskQty2,
    AskQty3,
    AskQty4,
    AskQty5,
    BidCnt1,
    BidCnt2,
    BidCnt3,
    BidCnt4,
    BidCnt5,
    AskCnt1,
    AskCnt2,
    AskCnt3,
    AskCnt4,
    AskCnt5,
    left_timestamp, 
    id,
    eventType,
    Symbol,
    time,
    Qty,
    Price,
    Side
  )
)
"
echo "......."

iquery -naq "remove(tmp_merged2)" >/dev/null 2>&1
iquery -naq "remove(asof_new_temp1)" >/dev/null 2>&1

