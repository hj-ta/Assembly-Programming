# Assembly Programming

[KWU 2024년 2학기] 어셈블리프로그래밍 설계 및 실습 과목 과제. ARM 어셈블리(ARM Assembly)를 이용해 저수준 연산, 메모리 조작, 스택 관리, IEEE 754 부동소수점 연산, 이미지 보간 알고리즘 과제 정리.

## Assignments

| 구분            | 주제                               | 핵심 내용                                          |
| ------------- | -------------------------------- | ---------------------------------------------- |
| Assignment 01 | ARM Assembly Basics              | Shift 연산, 재귀 함수, Stack, Register Swap          |
| Assignment 02 | IEEE 754 Floating-Point Addition | 단정밀도 부동소수점 덧셈 직접 구현                            |
| Term Project  | MNIST Image Upscaling            | Bilinear Interpolation 기반 20×20 → 80×80 이미지 확대 |

## Assignment 01. ARM Assembly Basics

ARM 어셈블리의 기본 명령어와 스택 사용을 실습한 과제이다.

### 주요 내용

* Second Operand Shift를 이용한 `10!` 계산
* 재귀 함수(Recursive Function)와 Stack을 이용한 `10!` 계산
* `17×3`, `3×17` 곱셈 순서 비교
* `STMFD`, `LDMFD`를 이용한 R0~R7 레지스터 값 교환
* 결과값을 지정 메모리 주소에 저장하고 시스템 콜로 종료

### 핵심 정리

단순 산술 연산을 넘어, ARM에서 레지스터와 스택이 어떻게 사용되는지 확인한 과제이다.
특히 재귀 호출 과정에서 `PUSH`, `POP`, `BL`, `BX lr`의 역할을 직접 구현했다.

## Assignment 02. IEEE 754 Floating-Point Addition

IEEE 754 단정밀도(Single Precision) 부동소수점 덧셈을 ARM 어셈블리로 직접 구현한 과제이다.

### 주요 내용

* 32비트 부동소수점 값에서 Sign, Exponent, Mantissa 추출
* Hidden bit 복원
* Exponent 비교 및 Mantissa 정렬
* 부호에 따른 Mantissa 덧셈/뺄셈
* Normalize 과정 수행
* IEEE 754 형식으로 결과 재조합
* 결과값을 `0x40000000` 주소에 저장

### 테스트 케이스

| 입력              |   기대 결과 | IEEE 754 Hex |
| --------------- | ------: | ------------ |
| `0.25 + 0.125`  | `0.375` | `0x3EC00000` |
| `0.5 + (-1.75)` | `-1.25` | `0xBFA00000` |

### 핵심 정리

부동소수점 연산이 단순 덧셈이 아니라, 지수 정렬과 가수 정규화 과정을 거쳐 수행된다는 점을 어셈블리 레벨에서 확인했다.

## Term Project. MNIST Image Upscaling

ARM 어셈블리로 MNIST 숫자 이미지를 20×20에서 80×80으로 확대하는 프로젝트이다.

픽셀값은 IEEE 754 단정밀도 형식으로 저장되어 있으며, Bilinear Interpolation을 이용해 확대 이미지를 생성하도록 구현했다.

## Term Project Concept

Bilinear Interpolation은 주변 4개 픽셀을 기준으로 새 픽셀값을 계산하는 방식이다.

![Bilinear Interpolation Concept](./ASM-Project/assets/bilinear-interpolation-concept.png)

20×20 입력 이미지는 행과 열 방향으로 각각 4배 확대되어 80×80 결과 이미지가 된다.

![Input and Output Structure](./ASM-Project/assets/input-output-structure.png)

아래 그림은 작은 입력 행렬이 확대될 때 보간 픽셀이 어떻게 생성되는지 보여준다.

![Bilinear Interpolation Example](./ASM-Project/assets/bilinear-interpolation-example.png)

> 이미지 출처: 광운대학교 「어셈블리프로그래밍 설계 및 실습」 Term Project 과제 제안서, Figure 1~3.

### 주요 내용

* 20×20 MNIST 입력 이미지 로드
* 80×80 출력 좌표 순회
* 출력 좌표를 원본 이미지 좌표로 변환
* 주변 픽셀 `Q11`, `Q12`, `Q21`, `Q22` 로드
* `dx`, `dy`, `1-dx`, `1-dy` 가중치 계산
* IEEE 754 기반 부동소수점 곱셈/덧셈 구현
* Bilinear Interpolation 결과를 `ResultBuffer`에 저장

### 보간식

```text
P = Q11 × (1 - dx) × (1 - dy)
  + Q12 × dx × (1 - dy)
  + Q21 × (1 - dx) × dy
  + Q22 × dx × dy
```

### 주요 서브루틴

| 서브루틴                   | 역할                         |
| ---------------------- | -------------------------- |
| `get_dx`               | `dx` 값을 IEEE 754 가중치로 변환   |
| `get_dy`               | `dy` 값을 IEEE 754 가중치로 변환   |
| `get_one_minus_dx`     | `1 - dx` 가중치 계산            |
| `get_one_minus_dy`     | `1 - dy` 가중치 계산            |
| `bilinear_interpolate` | 주변 4개 픽셀과 가중치로 보간값 계산      |
| `multiply_float`       | IEEE 754 단정밀도 곱셈           |
| `add_float`            | IEEE 754 단정밀도 덧셈           |
| `normalize`            | Mantissa 정규화 및 Exponent 조정 |

### 구현 범위

Term Project는 완성형 이미지 처리 프로그램이라기보다, ARM 어셈블리 환경에서 Bilinear Interpolation과 IEEE 754 부동소수점 연산을 직접 구현한 실험적 프로젝트이다.

제출본 기준으로 숫자 `0` 데이터에 대한 확대 결과를 확인했으며, 나머지 숫자 데이터에 대한 한계와 디버깅 과정은 보고서에 정리했다.

## Repository Structure

```text
Assembly-Programming/
├── README.md
│
├── Assignment01/
│   ├── README.md
│   ├── problem1.s
│   ├── problem2.s
│   ├── problem3.s
│   ├── problem4.s
│   ├── memory.ini
│   └── report.pdf
│
├── Assignment02/
│   ├── README.md
│   ├── problem1.s
│   └── report.pdf
│
└── TermProject/
    ├── README.md
    ├── project.s
    ├── memory.ini
    ├── report.pdf
    └── assets/
        ├── bilinear-interpolation-concept.png
        ├── input-output-structure.png
        └── bilinear-interpolation-example.png
```

## Environment

* ARM Assembly
* ARM9E-S
* Keil µVision
* IEEE 754 Single Precision
* Memory-mapped Result Buffer

## Note

수업에서 제공된 과제 명세서, skeleton code, MNIST 데이터셋, 변환 유틸리티는 저장소에 포함하지 않았다.

저장소에는 직접 작성한 소스 코드, 실행에 필요한 최소 설정 파일, 보고서, README 설명용 이미지 자료만 정리했다.