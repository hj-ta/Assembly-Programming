# Assignment 01. ARM Assembly Basics

ARM 어셈블리(ARM Assembly)를 이용해 팩토리얼 계산, 재귀 함수, 곱셈 연산 비교, 스택 기반 레지스터 교환을 구현한 과제이다.

기본 명령어, 레지스터 조작, 스택(Stack), 메모리 저장, 서브루틴(Subroutine) 호출을 실습했다.

## Problems

| 문제        | 파일           | 내용                                        |
| --------- | ------------ | ----------------------------------------- |
| Problem 1 | `problem1.s` | Second Operand Shift를 이용한 `10!` 계산        |
| Problem 2 | `problem2.s` | 재귀 함수와 Stack을 이용한 `10!` 계산                |
| Problem 3 | `problem3.s` | ARM9E-S에서 `17×3`, `3×17` 곱셈 비교            |
| Problem 4 | `problem4.s` | Stack과 Block Data Transfer를 이용한 레지스터 값 교환 |

## Problem 1. Shift-based Factorial

`problem1.s`는 곱셈 명령어를 직접 사용하지 않고, `ADD`와 `LSL`을 조합해 `10!`을 계산한다.

예를 들어 `R1 + (R1 << 3)`은 `9 × R1`과 같은 방식으로 사용할 수 있다.

```text
ADD R0, R1, R1, LSL #3
```

계산 결과는 다음 주소에 저장된다.

```text
0x40000000
```

핵심은 ARM 명령어의 second operand에서 shift 연산을 함께 사용할 수 있다는 점이다.

## Problem 2. Recursive Factorial

`problem2.s`는 재귀 함수(Recursive Function)를 이용해 `10!`을 계산한다.

구현 구조는 다음과 같다.

```text
start
→ recursion 호출
→ base case 확인
→ r0, lr 저장
→ n-1 재귀 호출
→ stack에서 이전 값 복원
→ MUL로 결과 누적
```

사용한 주요 명령어는 다음과 같다.

```text
BL recursion
PUSH {r0, lr}
POP {r1, lr}
MUL r0, r1, r0
BX lr
```

재귀 호출마다 현재 값과 복귀 주소를 스택에 저장하고, 복귀 과정에서 값을 다시 꺼내 팩토리얼 결과를 누적한다.

## Problem 3. Multiplication Order Analysis

`problem3.s`는 ARM9E-S 환경에서 아래 두 연산을 비교한다.

```text
17 × 3
3 × 17
```

두 연산 모두 `MUL` 명령어를 사용한다.

```text
MUL r2, r0, r1
MUL r3, r0, r1
```

이 문제의 목적은 단순 결과 계산보다, 피연산자 순서가 곱셈 연산 성능에 영향을 주는지 분석하는 것이다.

실제 디버깅에서는 두 결과 모두 `0x33`, 즉 10진수 51로 동일하게 계산된다.

## Problem 4. Register Swap with Stack

`problem4.s`는 R0부터 R7까지 값을 초기화한 뒤, 스택을 이용해 지정된 순서로 값을 교환한다.

초기값은 다음과 같다.

```text
R0 = 1
R1 = 2
R2 = 3
R3 = 4
R4 = 5
R5 = 6
R6 = 7
R7 = 8
```

먼저 `STMFD`를 이용해 R0~R7 값을 스택에 저장한다.

```text
STMFD sp!, {r0-r7}
```

이후 `LDMFD`를 이용해 값을 다른 레지스터로 다시 불러와 교환을 수행한다.

```text
LDMFD sp!, {r1}
LDMFD sp!, {r6}
LDMFD sp!, {r0}
...
```

이 과정을 통해 단순 `MOV` 명령어가 아니라, Stack과 Block Data Transfer를 활용한 데이터 이동 방식을 확인했다.

## File Structure

```text
Assignment01/
├── README.md
├── problem1.s
├── problem2.s
├── problem3.s
├── problem4.s
├── memory.ini
└── report.pdf
```

## Execution Environment

* ARM Assembly
* ARM9E-S
* Keil µVision
* `memory.ini` 기반 메모리 매핑

`memory.ini`는 `0x40000000` 주소 영역에 결과를 저장하기 위해 사용한다.

```text
MAP 0x40000000, 0x40400000 READ WRITE
```

## Report

문제 설명, 구현 방법, 디버깅 화면, 레지스터 및 메모리 결과는 `report.pdf`에 정리했다.

## Tech Stack

* ARM Assembly
* ARM9E-S
* Keil µVision
* Register Operation
* Stack
* Recursive Function
* Block Data Transfer
* Memory Mapping

## Summary

이 과제는 ARM 어셈블리의 기본 명령어와 실행 구조를 실습한 과제이다.

Shift 연산을 이용한 계산, 재귀 호출과 스택 관리, 곱셈 연산 분석, 블록 데이터 전송을 통한 레지스터 교환을 구현했다.
이를 통해 ARM에서 레지스터, 메모리, 스택, 서브루틴이 어떻게 동작하는지 확인했다.
