#![allow(non_snake_case)]

use std::collections::HashSet;
use std::cmp::{min,max};
use parse_int::parse;
use std::fs;
use std::time::Instant;

type Point = (i64,i64);
type Line = (Point,Point);
type Board = HashSet<Point>;

fn parseLine(s: &str) -> Line {
  let a: Vec<&str> = s.split(" -> ").collect();
  let f = |x: &str| parse::<i64>(x).unwrap();
  let g = |x: &str| x.split(",").map(f).collect();
  let b: Vec<i64> = g(a[0]);
  let c: Vec<i64> = g(a[1]);
  ((b[0],b[1]),(c[0],c[1]))
}

fn parseFile(s: String) -> Vec<Line> {
  s.split('\n').filter(|l| l.to_string() != "").map(parseLine).collect()
}

fn cartesianProduct<T: Copy>(a: &Vec<T>, b: &Vec<T>) -> Vec<(T,T)> {
  let mut v = Vec::new();
  for aa in a {
    for bb in b {
      v.push((*aa,*bb));
    }
  }
  v
}

fn sign(n: i64) -> i64 {
  if n > 0 {
    1
  } else if n < 0 {
    -1
  } else { // n == 0
    0
  }
}

fn lineIsVert(l: Line) -> bool {
  l.0.0 == l.1.0
}

fn lineIsHoriz(l: Line) -> bool {
  l.0.1 == l.1.1
}

fn addPoint(p: Point, b0: &mut Board, b1: &mut Board) {
  if b0.contains(&p) {
    b1.insert(p);
  } else {
    b0.insert(p);
  }
}

fn addPoints(v: Vec<Point>, b0: &mut Board, b1: &mut Board) {
  for p in v {
    addPoint(p, b0, b1);
  }
}

fn lineToPoints(l: Line) -> Vec<Point> {
  if lineIsHoriz(l) || lineIsVert(l) {
    cartesianProduct(&(min(l.0.0,l.1.0)..max(l.0.0,l.1.0)+1).collect(), &(min(l.0.1,l.1.1)..max(l.0.1,l.1.1)+1).collect())
  } else { // line is horizontal
    let sx = sign(l.1.0 - l.0.0);
    let sy = sign(l.1.1 - l.0.1);
    let range = 0..(l.0.0-l.1.0).abs()+1;
    range.map(|n| (l.0.0 + sx*n, l.0.1 + sy*n)).collect()
  }
}

fn addLine(l: Line, b0: &mut Board, b1: &mut Board) {
  addPoints(lineToPoints(l),b0,b1);
}

fn addLines(v: &Vec<Line>, b0: &mut Board, b1: &mut Board) {
  for l in v {
    addLine(*l,b0,b1);
  }
}

fn numIntersectionsLines(v: &Vec<Line>) -> usize {
  let mut b0 = Board::new();
  let mut b1 = Board::new();
  addLines(v,&mut b0,&mut b1);
  b1.len()
}

fn part1(v: &Vec<Line>) -> usize {
  numIntersectionsLines(&v.iter().filter(|l| lineIsHoriz(**l) || lineIsVert(**l)).map(|t| *t).collect())
}

fn part2(v: &Vec<Line>) -> usize {
  numIntersectionsLines(v)
}

fn main() {
  let contents = fs::read_to_string("inputs/D5.txt").unwrap();
  let f = parseFile(contents);

  let now = Instant::now();
  let p1Ans = part1(&f);
  let dist = now.elapsed().as_millis();
  println!("P1: {}; time to compute: {} ms",p1Ans,dist);

  let now = Instant::now();
  let p2Ans = part2(&f);
  let dist = now.elapsed().as_millis();
  println!("P2: {}; time to compute: {} ms",p2Ans,dist);
}
