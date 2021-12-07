#![allow(non_snake_case)]

use num::BigInt;
use std::iter;
use rayon::par_iter::{IntoParallelIterator,ParallelIterator};
use std::fs;

#[derive(Clone)]
struct Matrix { elems: Vec<Vec<BigInt>> }

fn rows(a: &Matrix) -> usize {
  a.elems.len()
}

fn cols(a: &Matrix) -> usize {
  if rows(a) == 0 { return 0; }
  a.elems[0].len()
}

fn mul(a: &Matrix, b: &Matrix) -> Matrix {
  let ca = cols(a);
  if ca != rows(b) { panic!("mismatched dimensions"); }
  Matrix {
    elems : (0..rows(a))
      .into_par_iter()
      .map(move |r|
        (0..cols(b)).map(move |c|
          (0..ca).map(move |i| a.elems[r][i].clone()*b.elems[i][c].clone()).fold(BigInt::from(0),|a,b| a+b)
        ).collect()
      )
      .collect()
  }
}

fn toDigits(n: &BigInt) -> Vec<bool> {
  let mut m = n.clone();
  let mut result = Vec::new();
  while m > BigInt::from(0) {
    result.push(m.clone() % BigInt::from(2) != BigInt::from(0));
    m = m / BigInt::from(2);
  }
  result
}

fn exp(a: &Matrix, n: &BigInt) -> Matrix {
  let mut b = a.clone();
  let mut r = eye(rows(a));
  let v = toDigits(n);
  for i in 0..v.len() {
    if v[i] {
      r = mul(&r, &b);
    }
    b = mul(&b, &b);
  }
  r
}

fn matrixSum(a: &Matrix) -> BigInt {
  a.elems.iter().map(|r| r.iter().fold(BigInt::from(0), |x,y| x + y)).fold(BigInt::from(0), |x,y| x + y)
}

fn zero(n: usize) -> Matrix {
  Matrix {
    elems: iter::repeat(
      iter::repeat(
        BigInt::from(0)
      ).take(n).collect()
    ).take(n).collect()
  }
}

fn eye(n: usize) -> Matrix {
  Matrix {
    elems: (0..n).map(|i|
      (0..n).map(|j|
        BigInt::from(if i == j { 1 } else { 0 })
      ).collect()
    ).collect()
  }
}

fn vectorMatrix(v: &Vec<BigInt>) -> Matrix {
  Matrix {
    elems: v.iter().map(|x| vec![x.clone()]).collect()
  }
}

fn showMatrix(m: &Matrix) -> String {
  m.elems.iter().map(|r|
    r.iter().map(|v|
      v.to_string()
    ).fold("".to_string(), |a, b| a + &" ".to_string() + &b)
  ).fold("".to_string(), |a, b| a + &"\n".to_string() + &b)
}

fn fishMatrix(n: usize, s: usize) -> Matrix {
  let mut m = eye(n);
  for i in 0..n { m.elems[i].rotate_right(1); }
  m.elems[n-s-1][0] = BigInt::from(1);
  m
}

fn main() {
  let mut mulVec = vec![BigInt::from(0); 9];
  for i in fs::read_to_string("inputs/D6.txt").unwrap().split(",").map(|s| s.replace("\n","").parse::<usize>().unwrap()) {
    mulVec[i] = mulVec[i].clone() + BigInt::from(1);
  }
  let mulMat = &vectorMatrix(&mulVec);
  let fishA = exp(&fishMatrix(9,2), &BigInt::from(80));
  let fishB = exp(&fishMatrix(9,2), &BigInt::from(256));
  let mulledA = mul(&fishA, &mulMat);
  let mulledB = mul(&fishB, &mulMat);
  println!("{}, {}",matrixSum(&mulledA),matrixSum(&mulledB));
}
