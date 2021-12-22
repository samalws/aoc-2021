def rectArea(l):
  area = 1
  for (a0,a1) in l:
    if a0 > a1: return 0
    area *= a1-a0+1
  return area

def applyInputs(inps,ignoreOver50):
  bigTotal = 0
  areasAdd = []
  for (b,(x0,x1),(y0,y1),(z0,z1)) in inps:
    if ignoreOver50 and (min([x0,y0,z0]) < -50 or max([x1,y1,z1]) > 50): continue
    tot = rectArea([(x0,x1),(y0,y1),(z0,z1)]) if b else 0
    newAreas = [(True,(x0,x1),(y0,y1),(z0,z1))] if b else []
    for (B,(X0,X1),(Y0,Y1),(Z0,Z1)) in areasAdd:
      rectOverlap = [(max(x0,X0),min(x1,X1)),(max(y0,Y0),min(y1,Y1)),(max(z0,Z0),min(z1,Z1))]
      areaOverlap = rectArea(rectOverlap)
      tot += areaOverlap * (-1 if B else 1)
      if areaOverlap > 0:
        newAreas += [(not B, rectOverlap[0], rectOverlap[1], rectOverlap[2])]
    bigTotal += tot
    areasAdd += newAreas
  return bigTotal

def parseInputs(s):
  retVal = []
  for line in s.strip().split("\n"):
    lspl = line.split(" ")
    b = lspl[0] == "on"
    l = []
    for a in lspl[1].split(","):
      aspl = a[2:].split("..")
      l += [(int(aspl[0]),int(aspl[1]))]
    retVal += [(b,l[0],l[1],l[2])]
  return retVal

f = parseInputs(open("inputs/D22.txt","r").read())
print(applyInputs(f,True))
print(applyInputs(f,False))
