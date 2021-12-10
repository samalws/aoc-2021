#![allow(non_snake_case)]

use std::fs;

fn checkIfLowPoint(map: &Vec<Vec<u8>>, index: (usize,usize)) -> bool {
  let this = map[index.0][index.1];
  if index.0 != 0 && map[index.0-1][index.1] <= this {
    false
  } else if index.1 != 0 && map[index.0][index.1-1] <= this {
    false
  } else if index.0 != map.len()-1 && map[index.0+1][index.1] <= this {
    false
  } else if index.1 != map[0].len()-1 && map[index.0][index.1+1] <= this {
    false
  } else {
    true
  }
}

fn lowPoints(map: &Vec<Vec<u8>>) -> Vec<(usize,usize)> {
  let mut returnVal = Vec::new();
  for indexs in (0..map.len()).map(|i|
    (0..map[0].len())
      .filter(|j| checkIfLowPoint(map,(i,*j)))
      .map(|j| (i,j)).collect::<Vec<(usize,usize)>>()) {
    returnVal.append(&mut indexs.clone());
  }
  returnVal
}

fn adjPoints(mapSize: (usize, usize), index: (usize, usize)) -> Vec<(usize, usize)> {
  let mut retVal = Vec::new();
  if index.0 != 0 { retVal.push((index.0-1,index.1)) }
  if index.1 != 0 { retVal.push((index.0,index.1-1)) }
  if index.0 != mapSize.0-1 { retVal.push((index.0+1,index.1)) }
  if index.1 != mapSize.1-1 { retVal.push((index.0,index.1+1)) }
  retVal
}

fn floodFill(map: &mut Vec<Vec<u8>>, index: (usize, usize)) -> u64 {
  let mut size: u64 = 0;
  let mut ptsLookAt = vec![index];
  map[index.0][index.1] = 9;
  while ptsLookAt.len() > 0 {
    size += 1;
    for p in adjPoints((map.len(), map[0].len()), ptsLookAt.pop().unwrap()) {
      if map[p.0][p.1] != 9 {
        ptsLookAt.push(p);
        map[p.0][p.1] = 9;
      }
    }
  }
  size
}

fn part1(map: &Vec<Vec<u8>>) -> u64 {
  lowPoints(map).iter().map(|index| map[index.0][index.1]).fold(0, |a,b| 1+a+b as u64)
}

fn part2(map: &Vec<Vec<u8>>) -> u64 {
  let mut mapp = map.clone();
  let mut retVal = Vec::new();
  for p in lowPoints(map).iter() {
    let n = floodFill(&mut mapp, *p);
    retVal.push(n);
  }
  retVal.sort();
  retVal.reverse();
  retVal.iter().take(3).fold(1, |a,b| a*b)
}

fn parseFile(s: &String) -> Vec<Vec<u8>> {
  s.lines().map(|l|
    l.chars().map(|c| u8::from_str_radix(&c.to_string(),10).unwrap()).collect()
  ).collect()
}

fn main() {
  let v = parseFile(&fs::read_to_string("inputs/D9.txt").unwrap());
  println!("{}", part1(&v));
  println!("{}", part2(&v));
}
