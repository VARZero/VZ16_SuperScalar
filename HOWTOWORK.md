# 어떻게 Out-Of-Order Excution를 구현할 것인가?

먼저, 프로세서는 INT 연산만 사용가능한 [MakeModCpu16 레포의 ISA를 사용 예정](https://github.com/VARZero/MakeModCpu16)<br>
해당 ISA를 Out-Of-Order Excution 방식으로 구동시킬 것이고, Tomasulo's Algorithm을 참조하여 구현 예정<br>
구현 과정에서 Cache Memory를 같이 구현

## 버전에 따른 구현 방법
1. v1 - OoOE의 구현에 집중, 메모리는 2Cycle 내에 접근 가능함, Branch Predictor는 정적으로, 웬만해서는 분기 되지 않는 방향으로 예측기를 설계(v3와 성능 비교를 위해, 컴파일러도 분기는 예외의 상황으로 동작하도록 구현)
2. v2 - 다층적 Cache Memory에 집중
3. v3 - 동적 Branch Predictor
4. v4 - OoOE 코어를 P코어로, In-Order를 E코어로 구현하여 P코어의 전력 소모를 최소한으로 할 수 있도록 Circuit 설계를 고려하고 P코어의 전원을 끄고 처리된 레지스터 값을 E코어로 전환할 수 있는 방법을 고려 및 구현

## OoOE를 어떻게 구현할 것인가

### 현재 구성 단위
1. 4-way Decoder
2. 7-way issue
3. 128 Re-Order Buffer
4. 64 Temp Register

### Tomasulo's Algorithm과 함께 고려한 동작 방식
1. 4개의 명령어를 메모리로 부터 가져와서 Micro-Op으로 변환 (Decoding)
2. 변환된 4개의 명령어의 Register Field를 Temp Register의 형태로 변환 및 ROB에 삽입 (Renameing)
3. Re-Order Buffer에서 Final_PC_Counter 레지스터 보다 작은(만약 모든 WAR, WAW Hazard가 없는 경우는 Last Completed PC 섹션이 0으로 지정) 이전 Issue에 수행되어 완료된 PC 값이 Last Completed PC 섹션에 존재하는 명령을 가져와서 연산 처리로 전달 (Issue)
4. 연산 처리 섹션인 Back-End 부분에서 연산이 끝나는 경우에는 Value를 해당 ROB에 저장하고 해당 PC가 끝났음을 Final_PC_Counter(처리된 명령의 PC가 이전에 저장된 PC값 보다 +WORD만큼 큰 경우) 혹은 MAX_PC_Counter(처리된 명령의 PC가 이전에 저장된 PC값 보다 크면 무조건)에 업데이트
5. Branch Predicter의 동작으로 Loop Unrolling 및 분기 예측을 진행하고 분기 예측기는 Branch #를 해당 명령의 ROB에 기입함. 참고로 예측 실패시 해당 Branch #보다 큰 모든 명령은 Flush를 하도록 함.

### 동작에 필요한 레지스터
|이름|Bit-Width|설명|
|----|----|----|
|Final_PC_Counter|16|해당 주소까지 완전히 완료된 Program Count 값이 기록됨|
|MAX_PC_Counter|16|미리 수행되어 ROB에 들어있는 최대의 PC Counter (단, Branch 이전까지)|
|ABRANCH_PC_Counter|16|미리 수행되어 ROB에 들어있는 최대의 PC Counter (Branch 이후의)|
|Branch ID|4|현재 동작중인 Branch의 ID|
|Last Branch ID|4|분기 예측 및 미리 수행되어 ROB에 들어있는 Branch의 ID|

### Re-Order Buffer의 구성
하나의 요소에서 86Bit를 사용, 이번 프로젝트에서 128개의 Re-Order Buffer가 존재하므로, 총 86x128 = 11008 Bit(FF) 사용<br>
Re-Order Buffer는 4-Input(Decoder), 7-Motifiy(Issue), 7-Output(Issue)의 Register File 및 7-Channel 7-Output FIFO Memory의 특성을 가짐 
|0~15 (16)|16~27 (12)|28~31 (4)|32~37 (6)|38~43 (6)|44~49 (6)|50~65 (16)|66~69 (4)|70~85 (16)|
|---|---|---|---|---|---|---|---|---|
|PC|Micro-Op|Target Architecture Register|Target Temp Register|R1(Temp) Register|R2(Temp) Register|Value|Branch #|Last Completed PC|

### 단점, 하지만 감수하는 이유
|단점|감수 이유|
|---|---|
|Area를 과도하게 차지|속도의 증가를 위해 병렬화를 선택하여 속도의 증가를 예상|
|Piplining으로 인한 여러 Cycle 소모|일반적인 경우도 하나의 명령어에 대한 처리에 5Cycle을 소모하고 현재 구현하는것은 최고의 조건에서 7개의 명령을 수행할 수 있으므로 파이프라이닝 단계가 늘어난다고 해도 한번씩 처리하는 것에 비해 빠른 처리가 가능할것을 예상|
|Power 제어가 힘듦|수많은 Flip-Flop의 사용으로 전력 사용량이 폭증하더라도 연산 속도가 빠르다면 한번 빠르게 하고 지속적으로 전력의 소모를 줄인다면 하나씩 처리하는 지속적인 전력소모에 비해 유리할 것이라 예상 + 현대 클라이언트 디바이스 컴퓨팅에서 주로 사용되는 P-E코어(a.k.a. big.LITTLE)을 이용한다면 효과적으로 전력 소모를 줄일것이라 판단|


## 참조 사항: MakeModCpu16(MMC16) ISA의 구성
16-bit WORD

## 레지스터 구조
먼저 일부 명령어를 제외하고 접근 불가능한 PC, Status, SP, BACK 레지스터가 있다<br>
정수 연산용 16개 레지스터가 있으며, 내용은 아래와 같다.

|이름|용도|
|---|---|
|zero|항상 0을 가진 레지스터|
|status(csr)|최상위 비트에 음수, 캐리, 제로, 오버(언더)플로우, 부호 여부 상태를 순서대로 저장해 두는 레지스터|
|SP|스택포인터 레지스터, PUSH/POP 명령어 사용시 이 레지스터의 값이 +2/-2가 됨|
|BACK|서브루틴에서 본 루틴으로 돌아갈 주소를 저장하기 위한 레지스터|
|r0|사용자 정의 레지스터|
|r1|사용자 정의 레지스터|
|r2|사용자 정의 레지스터|
|r3|사용자 정의 레지스터|
|r4|사용자 정의 레지스터|
|r5|사용자 정의 레지스터|
|r6|사용자 정의 레지스터|
|r7|사용자 정의 레지스터|
|r8|사용자 정의 레지스터|
|r9|사용자 정의 레지스터|
|r10|사용자 정의 레지스터|
|r11|사용자 정의 레지스터, MUL 연산시 상위(31~16) 값, DIV 연산시 나머지 값은 여기에 저장됨|

### status 레지스터
|15|14|13|12|11 10 9 8|7 6 5 4|3 2 1 0|
|-|-|-|-|-|-|-|
|S|C|Z|F|하위비트는 이 명령어|체계에서|사용하지 않습니다.|

## 명령어 설명
명령어에서 직접적으로 zero(접근은 가능하나 결론적으로 수정이 안됨), status, PC, SP, BACK은 수정할 수 없습니다.<br><br>
여기 쓰여져 있는 대문자 R은 레지스터 이름에 쓰이는 r과 연관이 없습니다. 같은거 아니니 주의!
|15 14 13 12|11 10 9 8|7 6 5 4|3 2 1 0|
|---|---|---|---|
|R2|R1|Rn|Opcode|

### 명령어 리스트
|Opcode 이진수|이름|용도와 특징|
|----|----|----|
|0000|IMM|값을 바로 집어넣기 위해 사용 Rn에 해당하는 레지스터를, R1에 비트 위치, R2에 4비트 값을 넣어 사용합니다.|
|0001|JUMP|PC레지스터를 바로 변환하기 위해 사용, 사용시 현재 명령어 바로 뒤의 명령어 주소가 BACK레지스터에 저장. Rn은 PC레지스터(if문 쓰듯이 Rn을 마음대로 지정할 수 있도록 할지 고민중), R1에는 주소가 들어있는 레지스터, R2에는 세부 특징이 작성됨(후술함)|
|0010|LOAD|메모리에서 레지스터로 값을 가져옴 (주소: R1)|
|0011|SAVE|레지스터 값을 메모리에 저장 (주소: R1)|
|0100|PUSH|SP레지스터 값을 +2하고 SP레지스터를 주소로 변환하여 R1레지스터의 값을 저장|
|0101|POP|SP레지스터 값을 -2하고 해당 메모리 주소에 있는 값을 Rn의 레지스터에 저장|
|0110|SL|R2만큼 R1의 비트를 왼쪽으로 이동한 것을 Rn에|
|0111|SR|R2만틈 R1의 비트를 오른쪽으로 이동한 것을 Rn에|
|1000|ADD|Rn = R1 + R2|
|1001|SUB|Rn = R1 - R2|
|1010|MUL|Rn = R1 * R2|
|1011|DIV|Rn = R1 / R2|
|1100|AND|Rn = R1 (AND) R2|
|1101|OR|Rn = R1 (OR) R2|
|1110|XOR|Rn = R1 (XOR) R2|
|1111|NOT|Rn = (NOT) R1|

MOV 명령어 R2 세부사함은 아래와 같습니다. 
|작성되어야 하는 수|이진수|별칭|의미|
|--|------|---|---|
|0(또는 공백)|0000|NONE|아무 조건도 없음 ~~(경 아무것도안함 축)~~|
|1|0001|SAME|= (status Z=1)|
|2|0010|LSAME|>= (status Z=1)|
|3|0011|L|> (status Z=0 & F=0 | N=0)|
|4|0100|RSAME|<= (status Z=1 | F=1 | N=1)|
|5|0101|R|< (status Z=0 | F=1 | N=1)|
|8|1000|BACK|BACK 레지스터에 저장된 주소로 돌아감|
