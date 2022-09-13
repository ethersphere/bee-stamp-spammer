```
./spamit.sh > runs/run-$(date +%s).log
```

```
bee-factory start 1.7.0
```

```
mkdir processed
ls processed/*.log | xargs -I% sed -i '' 's/ /,/g' %
```
