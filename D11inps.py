s = "paddingVal,"*13
for c in open("inputs/D11.txt","r").read():
  s = s + c.replace("\n","paddingVal,paddingVal") + ","
s += "paddingVal,"*11
print(s[:-1])
print(len(s[:-1].split(",")))
