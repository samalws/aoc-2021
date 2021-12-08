import statistics
import math
f = open("inputs/D7.txt","r")
l = eval("["+f.read()+"]")
m = math.floor(statistics.median(l))
a = sum(l)/len(l)
(a1, a2) = (math.floor(a), math.ceil(a))
dA = sum(map(lambda x: abs(x-m), l))
dB = lambda aa: sum(map(lambda x: abs(x-aa)*(abs(x-aa)+1)/2, l))
(dB1, dB2) = (dB(a1), dB(a2))
print(dA)
print(min(dB1,dB2))
