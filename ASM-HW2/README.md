# Assignment 02. IEEE 754 Floating-Point Addition

ARM 어셈블리(ARM Assembly)를 이용해 IEEE 754 단정밀도(Single Precision) 부동소수점 덧셈을 구현한 과제이다.

하드웨어 부동소수점 명령어를 사용하지 않고, 32비트 IEEE 754 값을 직접 분해하여 sign, exponent, mantissa 단위로 연산을 수행했다.

## Project Overview

이 과제의 목표는 IEEE 754 부동소수점 표현 방식과 덧셈 연산 과정을 어셈블리 레벨에서 직접 구현하는 것이다.

구현 대상은 다음 네 가지 연산이다.

```text id="ez0lc9"
Value1 + Value2
Value1 - Value2
-Value1 + Value2
-Value1 - Value2
```

연산 결과는 메모리 주소 `0x40000000`에 저장한다.

## Key Concept

IEEE 754 single precision은 32비트로 구성된다.

```text id="9juqc8"
Sign      : 1 bit
Exponent  : 8 bits
Mantissa  : 23 bits
```

실제 연산은 다음 흐름으로 처리했다.

```text id="ax3x4i"
1. Value1, Value2 로드
2. Sign bit 추출
3. Exponent 추출
4. Mantissa 추출
5. Hidden bit 추가
6. Exponent 비교
7. 작은 exponent 쪽 mantissa shift
8. Sign에 따라 mantissa 덧셈 또는 뺄셈
9. Normalize
10. Sign, exponent, mantissa 재조합
11. 결과 메모리 저장
```

## Implementation Details

### 1. Value Load

`DCI`를 이용해 IEEE 754 형식의 32비트 값을 저장하고, `LDR` 명령어로 레지스터에 로드한다.

```armasm id="nbnazh"
LDR r0, value1
LDR r1, value2
LDR r10, =0x40000000
```

### 2. Sign Bit Extraction

각 값의 최상위 비트인 sign bit를 추출한다.

```armasm id="h4dbew"
MOV r2, r0, LSR #31
MOV r3, r1, LSR #31
```

### 3. Exponent Extraction

sign bit를 제거한 뒤 exponent 영역만 남기기 위해 shift 연산을 사용한다.

```armasm id="61v6xw"
LSL r4, r0, #1
LSR r4, r4, #24
```

### 4. Mantissa Extraction

하위 23비트를 추출한 뒤, normalized number의 hidden bit인 `1`을 추가한다.

```armasm id="10lvme"
LSL r6, r0, #9
LSR r6, r6, #9
ORR r6, r6, #0x00800000
```

### 5. Exponent Alignment

두 값의 exponent를 비교하고, exponent가 작은 쪽의 mantissa를 오른쪽으로 shift한다.

```text id="913q5j"
exp1 > exp2 → mantissa2 shift right
exp1 < exp2 → mantissa1 shift right
exp1 = exp2 → 바로 mantissa 연산
```

부동소수점 덧셈에서는 두 수의 exponent를 맞춘 뒤 mantissa를 계산해야 하므로 이 과정이 핵심이다.

### 6. Mantissa Operation

두 값의 sign bit가 같으면 mantissa를 더하고, sign bit가 다르면 더 큰 절댓값에서 작은 절댓값을 뺀다.

```text id="qmqm4q"
same sign      → mantissa addition
different sign → mantissa subtraction
```

결과 sign은 절댓값이 더 큰 피연산자의 sign을 따른다.

### 7. Normalization

mantissa 연산 결과가 normalized range를 벗어나면 shift를 수행하고 exponent를 조정한다.

```text id="r25w28"
mantissa >= 0x01000000 → shift right, exponent + 1
mantissa <  0x00800000 → shift left, exponent - 1
```

### 8. Result Build

정규화가 끝난 sign, exponent, mantissa를 다시 하나의 32비트 IEEE 754 값으로 조합한다.

```text id="t70c9s"
result = sign | exponent | mantissa
```

최종 결과는 `0x40000000` 주소에 저장한다.

## Test Cases

| Test Case | 입력              |   기대 결과 | IEEE 754 Hex |
| --------- | --------------- | ------: | ------------ |
| 1         | `0.25 + 0.125`  | `0.375` | `0x3EC00000` |
| 2         | `0.5 + (-1.75)` | `-1.25` | `0xBFA00000` |

보고서에서는 위 두 대표 케이스를 기준으로 레지스터 값과 메모리 저장 결과를 확인했다.

## File Structure

```text id="3r9dsc"
Assignment02/
├── README.md
├── problem1.s
└── report.pdf
```

## Execution Environment

* ARM Assembly
* ARM9E-S
* Keil µVision
* IEEE 754 Single Precision
* Memory-mapped result storage

## Report

구현 방법, IEEE 754 필드 분해 과정, normalize 과정, 테스트 케이스별 실행 결과는 `report.pdf`에 정리했다.

## Tech Stack

* ARM Assembly
* IEEE 754
* Floating-Point Addition
* Bit Manipulation
* Shift Operation
* Mantissa Alignment
* Normalization
* Memory Store
* Keil µVision

## Summary

이 과제는 IEEE 754 부동소수점 덧셈을 ARM 어셈블리로 직접 구현한 과제이다.

부동소수점 값을 sign, exponent, mantissa로 나누어 해석하고, exponent 정렬과 mantissa 정규화 과정을 직접 처리했다.
이를 통해 부동소수점 연산이 내부적으로 어떻게 수행되는지와, 로우 레벨에서 비트 조작이 왜 중요한지 확인할 수 있었다. 
솔직히 어렵고 진절머리 났지만 이 부분이 다른 과목이나 자격증 시험이나 곳곳에서 나왔을때 수월하게 할 수 있었고 큰 도움이 되었다.
