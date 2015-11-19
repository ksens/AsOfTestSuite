# TEST OF ACCURACY

## Load the arrays using opaque load and verify the counts

Run:
```
./loadArrays.sh `pwd`/accuracy/left.array `pwd`/accuracy/right.array
```

count for Left array
```
>> 3031
```
count for Right array
```
>> 2
```

The outputs generated by as.of in R and axial_aggregate/cumulate in AFL are stored at:
```
accuracy/outputs/r_asof_<Symbols>_<times>.txt
accuracy/outputs/cumulate_asof_<Symbols>_<times>.txt
```

## Generate the output using Donghui's AsOf operator
iquery -aq "store(asof(left_array, right_array), asof_donghui)"

Then generate the output in format required for diff by the following query:

``` 
iquery -aq "
save(
    sort(
        project(
            apply(asof_donghui, 
                    Date, 20150918, 
                    asof_timestamp, timestamp, 
                    attr_Symbol_index, Symbol_index, 
                    synthetic, 0
                ), 
                Date, 
                attr_Symbol_index, 
                asof_timestamp,
                synthetic, 
                id,
                eventType,
                Symbol,
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
    ), attr_Symbol_index, asof_timestamp
    ), 
'`pwd`/accuracy/outputs/donghui_asof_symbols_1_times_47172300-49293354.txt',-2,'tsv')"
```

# Next diff the generated output with the one generated by R or cumulate AsOf

First verify that the output from R and Alex's AsOf are same
```
diff <(tail -n +2 accuracy/outputs/r_asof_symbols_1_times_47172300-49293354.txt) <(tail -n +2 accuracy/outputs/cumulate_asof_symbols_1_times_47172300-49293354.txt)
```

Next, verify Donghui's AsOf
```
diff <(tail -n +2 accuracy/outputs/r_asof_symbols_1_times_47172300-49293354.txt) <(tail -n +2 accuracy/outputs/donghui_asof_symbols_1_times_47172300-49293354.txt)
```

# TEST OF SPEED 

First copy the large data file into local folder (not under SVN control as it is quite large)
File is stored at salty (10.0.20.185)
```
cp -r /public/FinancePOC/AsOfJoinValidation/speed/*.array speed/
```

Load the arrays using opaque load and verify the counts

Run:
./loadArrays.sh `pwd`/speed/left.array `pwd`/speed/right.array

count for Left array
```
>> 619189
```
count for Right array
```
>> 5032
```

# Calculate the time for using Donghui's AsOf operator
```
time iquery -aq "consume(asof(left_array, right_array))"
```
# Now calculate the time for using Alex's AsOf operator
```
time ./speed/asofjoin_alex.sh left_array right_array
```
(Note that Alex's script stores the output into another array; it is not an operator and hence difficult to consume)


