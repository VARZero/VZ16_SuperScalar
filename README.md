# 이건 OoOE를 구현하기 위한 Story
Out-Of-Order Execution을 구현하려는 연습용 레포입니다.<br>
방학 내에 성미니는 이걸 구현할 수 있을까요?

## 디렉토리 구조
- [RTL](RTL)
    - [Front-End](RTL/Front-End/): OoOE로 처리하기 위한 Decoder, Renamer, ROB, Architecture-Temp Register Pointer Map의 RTL 구현
    - [Back-End](RTL/Back-end/): 연산기 + Issue 반환기의 RTL 구현
    - [Cache-Mem](RTL/Cache-Mem/): 계층적 캐시 메모리 구현, V2부터 구현시작
    - [BranchPredictor](RTL/BranchPredictor/): 분기 예측기 구현, V1은 정적 V3는 동적
    - MMC16-OoOE.v: (P-, v4부터) Cpu Core의 Top Module
- [HOWTOWORK.md](HOWTOWORK.md) - 어떻게 OoOE로 구현하는가? 설명

## 구현에 대한 자세한 설명은 [HOWTOWORK.md](HOWTOWORK.md) 를 보시면 됩니다.