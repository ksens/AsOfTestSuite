#!/bin/bash
if test $# -lt 2; then
  echo "Usage: ./loadArrays.sh <FULL-PATH-TO-LEFT-ARRAY> <FULL-PATH-TO-RIGHT-ARRAY>"
  exit 1
fi

left="left_array"
right="right_array"

iquery -naq "remove($left)" >/dev/null 2>&1
iquery -naq "remove($right)" >/dev/null 2>&1

iquery -aq "create array $left <id:int64 NULL DEFAULT null,eventType:int8 NULL DEFAULT null,Symbol:string NULL DEFAULT null,BidPrc1:double NULL DEFAULT null,BidPrc2:double NULL DEFAULT null,BidPrc3:double NULL DEFAULT null,BidPrc4:double NULL DEFAULT null,BidPrc5:double NULL DEFAULT null,BidQty1:int32 NULL DEFAULT null,BidQty2:int32 NULL DEFAULT null,BidQty3:int32 NULL DEFAULT null,BidQty4:int32 NULL DEFAULT null,BidQty5:int32 NULL DEFAULT null,AskPrc1:double NULL DEFAULT null,AskPrc2:double NULL DEFAULT null,AskPrc3:double NULL DEFAULT null,AskPrc4:double NULL DEFAULT null,AskPrc5:double NULL DEFAULT null,AskQty1:int32 NULL DEFAULT null,AskQty2:int32 NULL DEFAULT null,AskQty3:int32 NULL DEFAULT null,AskQty4:int32 NULL DEFAULT null,AskQty5:int32 NULL DEFAULT null,BidCnt1:int32 NULL DEFAULT null,BidCnt2:int32 NULL DEFAULT null,BidCnt3:int32 NULL DEFAULT null,BidCnt4:int32 NULL DEFAULT null,BidCnt5:int32 NULL DEFAULT null,AskCnt1:int32 NULL DEFAULT null,AskCnt2:int32 NULL DEFAULT null,AskCnt3:int32 NULL DEFAULT null,AskCnt4:int32 NULL DEFAULT null,AskCnt5:int32 NULL DEFAULT null, left_timestamp:int64> [Symbol_index=0:*,100,0,timestamp=0:*,2160000,0]"

iquery -aq "create array $right <id:int64 NULL DEFAULT null,eventType:double NULL DEFAULT null,Symbol:string NULL DEFAULT null,time:string NULL DEFAULT null,Qty:double NULL DEFAULT null,Price:double NULL DEFAULT null,Side:double NULL DEFAULT null> [Symbol_index=0:*,100,0,timestamp=0:*,2160000,0]" 

iquery -naq "load($left, '$1' , -2 , 'opaque')"
iquery -naq "load($right, '$2' , -2 , 'opaque')"

iquery -aq "op_count($left)"
iquery -aq "op_count($right)"
