*-----------------------------------------------------------
* Title      : ECE 441 Design Project
* Written by : Michelle Yang
* Date       : 11/9/2018
* Description: Simple operating system for Easy 68K
*-----------------------------------------------------------
*-----------------------------------------------------------
* Data segment
*-----------------------------------------------------------
        ORG     $1000
        
PROMPT  DC.B    'MONITOR441> ',0 ;prompt
INVALID DC.B    'INVALID COMMAND',0

INPUT   DS.B    80              ;buffer for commands

COMP_TBL                        ;table of all commands
        DC.B    'HELP',0
        DS.B    2               ;padding so table is aligned at 6 bytes
        DC.B    'MDSP ',0
        DS.B    1
        DC.B    'SORTW ',0
        DC.B    'MM ',0
        DS.B    3
        DC.B    'MS ',0
        DS.B    3
        DC.B    'BF ',0
        DS.B    3
        DC.B    'BMOV ',0
        DS.B    1
        DC.B    'BTST ',0
        DS.B    1
        DC.B    'BSCH ',0
        DS.B    1
        DC.B    'GO ',0
        DS.B    3
        DC.B    'DF',0
        DS.B    4
        DC.B    'ECHO ',0
        DS.B    1
        DC.B    '. ',0
        DS.B    4
        DC.B    'EXIT',0
        DS.B    2

REGPC   DC.B    'PC=',0
REGSR   DC.B    'SR=',0
REGUS   DC.B    'US=',0
REGSS   DC.B    'SS=',0
REGD0   DC.B    'D0=',0
REGD1   DC.B    'D1=',0
REGD2   DC.B    'D2=',0
REGD3   DC.B    'D3=',0
REGD4   DC.B    'D4=',0
REGD5   DC.B    'D5=',0
REGD6   DC.B    'D6=',0
REGD7   DC.B    'D7=',0
REGA0   DC.B    'A0=',0
REGA1   DC.B    'A1=',0
REGA2   DC.B    'A2=',0
REGA3   DC.B    'A3=',0
REGA4   DC.B    'A4=',0
REGA5   DC.B    'A5=',0
REGA6   DC.B    'A6=',0
REGA7   DC.B    'A7=',0

REGVAL  DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1
        DS.L    1

REGNAME DC.B    $D0
        DC.B    $D1
        DC.B    $D2
        DC.B    $D3
        DC.B    $D4
        DC.B    $D5
        DC.B    $D6
        DC.B    $D7
        DC.B    $A0
        DC.B    $A1
        DC.B    $A2
        DC.B    $A3
        DC.B    $A4
        DC.B    $A5
        DC.B    $A6
        DC.B    $A7

HELP1   DC.B    'HELP: displays this help message',0
HELP2   DC.B    'MDSP <address1> <address2>: outputs address and memory contents from <address1> to <address2>',0
HELP2A  DC.B    'MDSP <address1>: outputs address and memory from <address1> to <address + 16 bytes',0
HELP3   DC.B    'SORTW <address1> <address2> <order>: sort block of memory between <address1> and <address2>, in ascending (A) or descending (D) order',0
HELP4   DC.B    'MM <address> <size>: display memory and modify/enter new data, showing byte (B), word (W), or longword (L) bytes',0
HELP5   DC.B    'MS <address> <data>: set memory at <address> to <data>, which is of type ASCII or hex',0
HELP6   DC.B    'BF <address1> <address2> <data>: fills memory between <address1> and <address2> with <data>, which is word size',0
HELP7   DC.B    'BMOV <address1> <address2> <address3>: move block of memory between <address1> and <address2> to location starting at <address3>',0
HELP8   DC.B    'BTST <address1> <address2>: test a block of memory between <address1> and <address2>',0
HELP9   DC.B    'BSCH <address1> <address2> <string>: search for <string> between <address1> and <address2>',0
HELP10  DC.B    'GO <address>: execute program at <address>',0
HELP11  DC.B    'DF: display registers and values',0
HELP12  DC.B    'ECHO <data>: prints <data> to terminal',0
HELP13  DC.B    '. <reg> <data>: put data into register specified, e.g. .D0 1000',0
HELP14  DC.B    'EXIT: terminate the program',0

SUCCESS DC.B    'BTST successful',0
FAILURE DC.B    'BTST failed',0

BADREG  DC.B    'Register not found',0

BUS_MSG  DC.B   'Bus error occurred',0
ADDR_MSG DC.B   'Address error occurred',0
ILLI_MSG DC.B   'Illegal instruction error occurred',0
DIV0_MSG DC.B   'Divide by zero error occurred',0
CHK_MSG  DC.B   'Check error occurred',0
PRIV_MSG DC.B   'Privilege violation error occurred',0
LNEA_MSG DC.B   'Line 1010 error occurred',0
LNEF_MSG DC.B   'Line 1111 error occurred',0

*-----------------------------------------------------------
* Program segment
*-----------------------------------------------------------        
        ORG     $3000       
*-----------------------------------------------------------
* Start here: set up and call to main
*-----------------------------------------------------------
START   BSR     SAVE            ;save register values in memory
        BSR     SETUP           ;set up here
        BSR     MAIN            ;call main
        
        MOVE.B  #9,D0           ;exit program
        TRAP    #15
        
*-----------------------------------------------------------
* Main method
*-----------------------------------------------------------
MAIN    MOVEA.L #PROMPT,A1
        MOVE.B  #14,D0
        TRAP    #15             ;print prompt
        
        MOVEA.L #INPUT,A1
        MOVE.B  #2,D0
        TRAP    #15             ;read command

        BSR     PARSE

        TST.B   D7
        BNE     EXITMAIN
        
        BRA     MAIN            ;get next command
        
EXITMAIN RTS

*-----------------------------------------------------------
* Setup exception handler
*-----------------------------------------------------------
SETUP   MOVE.L  #BUS,$008
        MOVE.L  #ADDR,$00C
        MOVE.L  #ILLI,$010
        MOVE.L  #DIV0,$014
        MOVE.L  #CHK,$018
        MOVE.L  #PRIV,$020
        MOVE.L  #LNEA,$028
        MOVE.L  #LNEF,$02C
        RTS

*-----------------------------------------------------------
* SAVE: save registers
*-----------------------------------------------------------
SAVE    MOVEM.L D0/A0/A1,-(SP)
        MOVEM.L D0/A0/A1,-(SP)
        MOVEA.L #REGVAL,A1

        MOVE.L  0(PC),(A1)+
        MOVE.W  #0,(A1)+
        MOVE.W  SR,(A1)+
        MOVE.L  A7,(A1)+        ;SSP
        MOVE.L  SP,(A1)+        ;USP

        MOVEA.L #REGVAL,A1
        ADDA.L  #16,A1

        MOVE.L  D0,(A1)+
        MOVE.L  D1,(A1)+
        MOVE.L  D2,(A1)+
        MOVE.L  D3,(A1)+
        MOVE.L  D4,(A1)+
        MOVE.L  D5,(A1)+
        MOVE.L  D6,(A1)+
        MOVE.L  D7,(A1)+
        MOVE.L  A0,(A1)+

        MOVEM.L (SP)+,D0/A0/A1
        MOVEA.L #REGVAL,A0
        ADDA.L  #52,A0
        MOVE.L  A1,(A0)+


        MOVE.L  A2,(A0)+
        MOVE.L  A3,(A0)+
        MOVE.L  A4,(A0)+
        MOVE.L  A5,(A0)+
        MOVE.L  A6,(A0)+
        MOVE.L  A7,(A0)+

        MOVEM.L (SP)+,D0/A0/A1
        RTS

*-----------------------------------------------------------
* Parse commands
* D7 signifies EXIT command received
*-----------------------------------------------------------
PARSE   MOVEM.L A1/A2/A3/D0,-(SP)     ;save registers

        CLR D7

        MOVEA.L #INPUT,A1       ;get front of string
        
        MOVEA.L #COMP_TBL,A2    ;get item in command string table
        MOVEA.L #COMP_TBL,A3
        
        MOVE.L  #4,D0           ;set D0 to number of chars to check

PHELP   CMP.B   (A1)+,(A3)+     ;is command HELP?
        DBNE    D0,PHELP        ;check next character
        BNE     NHELP           ;if did not match, check next string
        BSR     HELP
        BRA     EXITPARSE

NHELP   MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #4,D0

PMDSP   CMP.B   (A1)+,(A3)+     ;is command MDSP?
        DBNE    D0,PMDSP        ;check next character
        BNE     NMDSP
        BSR     MDSP
        BRA     EXITPARSE       ;if all chars matched, exit

NMDSP   MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #5,D0

PSORTW  CMP.B   (A1)+,(A3)+     ;is command SORTW?
        DBNE    D0,PSORTW       ;check next character
        BNE     NSORTW
        BSR     SORTW
        BRA     EXITPARSE       ;if all chars matched, exit

NSORTW  MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #2,D0

PMM     CMP.B   (A1)+,(A3)+     ;is command MM?
        DBNE    D0,PMM          ;check next character
        BNE     NMM
        BSR     MM
        BRA     EXITPARSE       ;if all chars matched, exit

NMM     MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #2,D0

PMS     CMP.B   (A1)+,(A3)+     ;is command MS?
        DBNE    D0,PMS          ;check next character
        BNE     NMS
        BSR     MS
        BRA     EXITPARSE       ;if all chars matched, exit

NMS     MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #2,D0

PBF     CMP.B   (A1)+,(A3)+     ;is command BF?
        DBNE    D0,PBF          ;check next character
        BNE     NBF
        BSR     BF
        BRA     EXITPARSE       ;if all chars matched, exit

NBF     MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #4,D0

PBMOV   CMP.B   (A1)+,(A3)+     ;is command MOV?
        DBNE    D0,PBMOV        ;check next character
        BNE     NBMOV
        BSR     BMOV
        BRA     EXITPARSE       ;if all chars matched, exit

NBMOV   MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #4,D0

PBTST   CMP.B   (A1)+,(A3)+     ;is command BTST?
        DBNE    D0,PBTST        ;check next character
        BNE     NBTST
        BSR     BTST
        BRA     EXITPARSE       ;if all chars matched, exit

NBTST   MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #4,D0

PBSCH   CMP.B   (A1)+,(A3)+     ;is command BSCH?
        DBNE    D0,PBSCH        ;check next character
        BNE     NBSCH
        BSR     BSCH
        BRA     EXITPARSE       ;if all chars matched, exit

NBSCH   MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #2,D0

PGO     CMP.B   (A1)+,(A3)+     ;is command GO?
        DBNE    D0,PGO          ;check next character
        BNE     NGO
        BSR     GO
        BRA     EXITPARSE       ;if all chars matched, exit

NGO     MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #2,D0

PDF     CMP.B   (A1)+,(A3)+     ;is command DF?
        DBNE    D0,PDF          ;check next character
        BNE     NDF
        BSR     DF
        BRA     EXITPARSE       ;if all chars matched, exit

NDF     MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #4,D0

PECHO   CMP.B   (A1)+,(A3)+     ;is command ECHO?
        DBNE    D0,PECHO        ;check next character
        BNE     NECHO
        BSR     ECHO
        BRA     EXITPARSE       ;if all chars matched, exit

NECHO   MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #1,D0

PMOD    CMP.B   (A1)+,(A3)+     ;is command ECHO?
        DBNE    D0,PMOD         ;check next character
        BNE     NMOD
        BSR     REGMOD
        BRA     EXITPARSE       ;if all chars matched, exit

NMOD   MOVEA.L #INPUT,A1
        BSR     NCHAR
        MOVE.L  #4,D0

PEXIT   CMP.B   (A1)+,(A3)+     ;is command EXIT?
        DBNE    D0,PEXIT        ;check next character
        BNE     NEXIT
        MOVE.L  #1,D7
        BRA     EXITPARSE       ;if all chars matched, exit

NEXIT   MOVEA.L #INVALID,A1     ;if got here, failed
        MOVE.B  #13,D0
        TRAP    #15
        
EXITPARSE
        MOVEM.L (SP)+,A1/A2/A3/D0 ;restore registers
        RTS

*-----------------------------------------------------------
* Helper function for incrementing between checks
*-----------------------------------------------------------
NCHAR   MOVEA.L #INPUT,A1       ;reset A1 to beginning of input string
        ADDA.L  #7,A2           ;increment to get next command string
        MOVEA.L A2,A3           ;update counter 
        RTS

*-----------------------------------------------------------
* HELP
*-----------------------------------------------------------
HELP    MOVEM.L D0/A1,-(SP)     ;save registers

        MOVEA.L #HELP1,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP2,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP2A,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP3,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP4,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP5,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP6,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP7,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP8,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP9,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP10,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP11,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP12,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP13,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEA.L #HELP14,A1
        MOVE.B  #13,D0
        TRAP    #15

        MOVEM.L (SP)+,D0/A1     ;restore registers
        RTS

*-----------------------------------------------------------
* MDSP
*-----------------------------------------------------------
MDSP    MOVEM.L D0/D1/A2/A3,-(SP)

        BSR     ASCII           ;get first argument
        MOVEA.L D1,A2
        BSR     ASCII           ;get second argument
        MOVEA.L D1,A3

        CMPA.L  #0,A3           ;how many arguments?
        BNE     MEMLOOP
        MOVEA.L A2,A3
        ADDA.L  #16,A3          ;if one argument, 16 bytes
 
MEMLOOP CMPA.L  A2,A3           ;continue while still in range
        BLE     MDSPEXIT

        MOVE.L  A2,D1           ;print address
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        MOVE.L  #$3A,D1         ;print colon
        MOVE.B  #6,D0
        TRAP    #15
        
        MOVE.L  (A2)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        BSR     CRLF

        BRA     MEMLOOP

MDSPEXIT MOVEM.L (SP)+,D0/D1/A2/A3
        RTS

*-----------------------------------------------------------
* SORTW
*-----------------------------------------------------------
SORTW   MOVEM.L D0/D1/D2/A2/A3/A4,-(SP)

        BSR     ASCII           ;get first argument
        MOVEA.L D1,A2
        BSR     ASCII           ;get second argument
        MOVEA.L D1,A3
        MOVE.B  (A1)+,D2        ;get third argument

        MOVEA.L A2,A4
SORTLOOP MOVEA.L A4,A2
BUBBLE  CMP.B   #$41,D2         ;is it "A"?
        BGT     DSC
ASC     CMP.W   (A2)+,(A2)+
        BLS     CMPNXT          ;sort ascending
        BRA     SWAP
DSC     CMP.W   (A2)+,(A2)+
        BHI     CMPNXT          ;sort descending

SWAP    MOVE.L  -(A2),D0
        SWAP.W  D0
        MOVE.L  D0,(A2)
        BRA     SORTLOOP

CMPNXT  SUBA.L  #2,A2
        CMP.L   A2,A3
        BGT     BUBBLE

        MOVEM.L (SP)+,D0/D1/D2/A2/A3/A4
        RTS

*-----------------------------------------------------------
* MM
*-----------------------------------------------------------
MM      MOVEM.L D0/D1/D2/D3/A2,-(SP)

        BSR     ASCII           ;get address argument
        MOVEA.L D1,A2
        MOVE.B  (A1)+,D3

MMNXT   MOVE.L  A2,D1           ;print address
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        MOVE.L  #$3A,D1         ;print colon
        MOVE.B  #6,D0
        TRAP    #15
        
        CLR.L   D1
        CMP.B   #$42,D3         ;is it a byte?
        BNE     MMWORD
        MOVE.B  (A2)+,D1
        BRA     MMTRAP

MMWORD  CMP.B   #$57,D3         ;is it a word?
        BNE     MMLONG
        MOVE.W  (A2)+,D1
        BRA     MMTRAP

MMLONG  MOVE.L  (A2)+,D1        ;it must be a long

MMTRAP  MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        MOVE.L  #$3F,D1         ;print ?
        MOVE.B  #6,D0
        TRAP    #15

        MOVEA.L #INPUT,A1
        MOVE.B  #2,D0
        TRAP    #15             ;read value

        CMP.B   #$2E,(A1)       ;quit on . entered
        BEQ     EXMM

        TST.B   D1
        BEQ     MMNXT
        
        BSR     ASCII           ;convert value to hex

        CMP.B   #$42,D3         ;is it a byte?
        BNE     MMWORD2
        MOVE.B  D1,-(A2)
        ADDA.L  #1,A2
        BRA     MMNXT

MMWORD2 CMP.B   #$57,D3         ;is it a word?
        BNE     MMLONG2
        MOVE.W  D1,-(A2)
        ADDA.L  #2,A2
        BRA     MMNXT

MMLONG2 MOVE.L  D1,-(A2)        ;it must be a long
        ADDA.L  #4,A2
        
        BRA     MMNXT

EXMM    MOVEM.L (SP)+,D0/D1/D2/D3/A2
        RTS

*-----------------------------------------------------------
* MS
*-----------------------------------------------------------
MS      MOVEM.L D1/A2,-(SP)

        BSR     ASCII           ;read address argument
        MOVEA.L D1,A2
        BSR     ASCII           ;read data argument

        MOVE.W  D1,(A2)         ;write data to memory

        MOVEM.L (SP)+,D1/A2
        RTS

*-----------------------------------------------------------
* BF
*-----------------------------------------------------------
BF      MOVEM.L D1/A2/A3,-(SP)

        BSR     ASCII           ;read start address
        MOVEA.L D1,A2
        BSR     ASCII           ;read end address
        MOVEA.L D1,A3
        BSR     ASCII           ;read data

BFLOOP  CMP.L   A2,A3
        BLT     EXBF
        MOVE.W  D1,(A2)+        ;write to memory
        BRA     BFLOOP

EXBF    MOVEM.L (SP)+,D1/A2/A3
        RTS

*-----------------------------------------------------------
* BMOV
*-----------------------------------------------------------
BMOV    MOVEM.L D1/A2/A3/A4,-(SP)

        BSR     ASCII           ;read original start address
        MOVEA.L D1,A2
        BSR     ASCII           ;read origina end address
        MOVEA.L D1,A3
        BSR     ASCII           ;read new start address
        MOVEA.L D1,A4

BMOVLOOP CMP.L  A2,A3
        BLT     EXBMOV
        MOVE.W  (A2)+,(A4)+     ;copy memory to new loc
        BRA     BMOVLOOP

EXBMOV  MOVEM.L (SP)+,D1/A2/A3/A4
        RTS

*-----------------------------------------------------------
* BTST
*-----------------------------------------------------------
BTST    MOVEM.L D0/D1/D2/A2/A3/A4,-(SP)

        BSR     ASCII           ;get start address
        MOVEA.L D1,A2
        MOVEA.L D1,A4
        BSR     ASCII           ;get end address
        MOVEA.L D1,A3

BTSTLOOP1 CMP.L A2,A3
        BLT     ENDLOOP1
        MOVE.B  #$55,(A2)+      ;fill memory
        BRA     BTSTLOOP1
ENDLOOP1 MOVEA.L A4,A2
        MOVE.B  #$55,D2

BTSTLOOP2 CMP.L A2,A3
        BLT     ENDLOOP2
        CMP.B   #$55,(A2)       ;check read value
        BNE     BAD
        MOVE.B  #$AA,(A2)+      ;fill memory
        BRA     BTSTLOOP2
ENDLOOP2 MOVEA.L A4,A2
        MOVE.B  #$AA,D2

BTSTLOOP3 CMP.L A2,A3
        BLT     GOOD
        CMP.B   #$AA,(A2)+      ;check read value
        BNE     BAD
        BRA     BTSTLOOP3

BAD     SUBA.L  #1,A2           ;go back to broken address

        MOVEA.L #FAILURE,A1     ;print failure message
        MOVE.B  #13,D0
        TRAP    #15

        MOVE.L  A2,D1           ;print address
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        MOVE.L  #$3A,D1         ;print colon
        MOVE.B  #6,D0
        TRAP    #15

        MOVE.L  D2,D1           ;print data stored
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        
        MOVE.L  #$2C,D1         ;print comma
        MOVE.B  #6,D0
        TRAP    #15

        MOVE.L  (A2),D1         ;print data read
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        BRA     EXBTST

GOOD    MOVEA.L #SUCCESS,A1     ;print success message
        MOVE.B  #13,D0
        TRAP    #15

EXBTST  MOVEM.L (SP)+,D0/D1/D2/A2/A3/A4
        RTS

*-----------------------------------------------------------
* BSCH
*-----------------------------------------------------------
BSCH    MOVEM.L D0/D1/D2/A1/A2/A3/A4/A5,-(SP)

        BSR     ASCII           ;get start address
        MOVEA.L D1,A2
        MOVEA.L A2,A5
        BSR     ASCII           ;get end address
        MOVEA.L D1,A3
        MOVEA.L A1,A4           ;save start of search string

        CLR.L   D0
LENSCH  CMP.B   #$00,(A1)+      ;get length of search string
        BEQ     SAVELEN     
        ADDI.L  #1,D0
        BRA     LENSCH

SAVELEN MOVE.L  D0,D3

SCHLOOP MOVEA.L A4,A1           ;restore to start of search
        MOVEA.L A5,A2           ;check with next char
        MOVE.L  D3,D0           ;restore search length
        CMP.L   A2,A3
        BLT     ENDSCH

        ADDA.L  #1,A5           ;next starting point

SCHFIND CMP.B   (A1)+,(A2)+     ;does string match?
        DBNE    D0,SCHFIND      ;check next character
        BNE     SCHLOOP

        SUBA.L  #1,A5           ;go back to starting address
        MOVE.L  A5,D1           ;print address
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        MOVE.L  #$3A,D1         ;print colon
        MOVE.B  #6,D0
        TRAP    #15

        MOVE.L  A5,A1           ;print data
        MOVE.B  #13,D0
        TRAP    #15

        ADDA.L  #1,A5           ;restore to next starting address
        BRA     SCHLOOP

ENDSCH  MOVEM.L (SP)+,D0/D1/D2/A1/A2/A3/A4/A5
        RTS

*-----------------------------------------------------------
* GO
*-----------------------------------------------------------
GO      MOVEM.L D1/A1,-(SP)

        BSR     ASCII           ;get address
        MOVEA.L D1,A1           ;use arbitrary address
        JSR     0(A1)

        MOVEM.L (SP)+,D1/A1
        RTS

*-----------------------------------------------------------
* DF
*-----------------------------------------------------------
DF      MOVEM.L D0/D1/D2/A0/A1,-(SP)

        MOVEA.L #REGVAL,A0

        MOVEA.L #REGPC,A1
        MOVE.B  #14,D0          ;print PC
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGSR,A1
        MOVE.B  #14,D0          ;print SR
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGUS,A1
        MOVE.B  #14,D0          ;print US
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGSS,A1
        MOVE.B  #14,D0          ;print SS
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGD0,A1
        MOVE.B  #14,D0          ;print D0
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGD1,A1
        MOVE.B  #14,D0          ;print D1
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGD2,A1
        MOVE.B  #14,D0          ;print D2
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGD3,A1
        ADDA.L  #4,A1
        MOVE.B  #14,D0          ;print D3
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF
        
        MOVEA.L #REGD4,A1
        MOVE.B  #14,D0          ;print D4
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGD5,A1
        MOVE.B  #14,D0          ;print D5
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGD6,A1
        MOVE.B  #14,D0          ;print D6
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGD7,A1
        MOVE.B  #14,D0          ;print D7
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGA0,A1
        MOVE.B  #14,D0          ;print A0
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGA1,A1
        MOVE.B  #14,D0          ;print A1
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGA2,A1
        MOVE.B  #14,D0          ;print A2
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGA3,A1
        MOVE.B  #14,D0          ;print A3
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGA4,A1
        MOVE.B  #14,D0          ;print A4
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGA5,A1
        MOVE.B  #14,D0          ;print A5
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGA6,A1
        MOVE.B  #14,D0          ;print A6
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEA.L #REGA7,A1
        MOVE.B  #14,D0          ;print A7
        TRAP    #15
        MOVE.L  (A0)+,D1        ;print value
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15
        BSR     CRLF

        MOVEM.L (SP)+,D0/D1/D2/A0/A1
        RTS

*-----------------------------------------------------------
* ECHO
*-----------------------------------------------------------
ECHO    MOVEM.L D0,-(SP)
        MOVE.B  #13,D0          ;echo input
        TRAP #15
        MOVEM.L (SP)+,D0
        RTS

*-----------------------------------------------------------
* REGMOD
*-----------------------------------------------------------
REGMOD  MOVEM.L D0/D1/D2/A1/A2,-(SP)

        CLR     D0
        BSR     ASCII           ;get register
        MOVE.L  D1,D2
        BSR     ASCII           ;get data

        MOVEA.L #REGVAL,A1
        ADDA.L  #16,A1
        MOVEA.L #REGNAME,A2

MODLOOP CMP.B   (A2)+,D2
        BEQ     MODFOUND
        ADDA.L  #4,A1
        ADDI.B  #1,D0
        CMP.B   #16,D0
        BGT     NOTFOUND
        BRA     MODLOOP

NOTFOUND MOVEA.L #BADREG,A1
        MOVE.B  #13,D0
        TRAP    #15
        BRA EXREGMOD

MODFOUND MOVE.L D1,(A1)
EXREGMOD MOVEM.L (SP)+,D0/D1/D2/A1/A2
        RTS

*-----------------------------------------------------------
* Bus error exception
*-----------------------------------------------------------
BUS     MOVEM.L D0/A1,-(SP)
        
        MOVEA.L #BUS_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15

        CLR     D1
        SUBA.W  #$2,A7          ;move SSP to point to SSW
        MOVE.L  (A7)+,D1        ;print SSW
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        BSR     SPACE

        CLR     D1
        MOVE.L  (A7)+,D1        ;print BA
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        BSR     SPACE

        CLR     D1
        MOVE.W  (A7)+,D1        ;print IR
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        BSR     CRLF
        BSR     DF

        MOVEM.L (SP)+,D0/A1
        RTE

*-----------------------------------------------------------
* Address error exception
*-----------------------------------------------------------
ADDR    MOVEM.L D0/D1/D2/A1,-(SP)
        
        MOVEA.L #ADDR_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15

        CLR     D1
        SUBA.W  #$2,A7          ;move SSP to point to SSW
        MOVE.L  (A7)+,D1        ;print SSW
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        BSR     SPACE

        CLR     D1
        MOVE.L  (A7)+,D1        ;print BA
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        BSR     SPACE

        CLR     D1
        MOVE.W  (A7)+,D1        ;print IR
        MOVE.B  #16,D2
        MOVE.B  #15,D0
        TRAP    #15

        BSR     CRLF
        BSR     DF
        
        MOVEM.L (SP)+,D0/D1/D2/A1
        RTE

*-----------------------------------------------------------
* Illegal instruction exception
*-----------------------------------------------------------
ILLI    MOVEM.L D0/A1,-(SP)
        MOVEA.L #ILLI_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15
        BSR     DF
        MOVEM.L (SP)+,D0/A1
        RTE

*-----------------------------------------------------------
* Privilege violation exception
*-----------------------------------------------------------
PRIV    MOVEM.L D0/A1,-(SP)
        MOVEA.L #PRIV_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15
        BSR     DF
        MOVEM.L (SP)+,D0/A1
        RTE

*-----------------------------------------------------------
* Divide by zero exception
*-----------------------------------------------------------
DIV0    MOVEM.L D0/A1,-(SP)
        MOVEA.L #DIV0_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15
        BSR     DF
        MOVEM.L (SP)+,D0/A1
        RTE

*-----------------------------------------------------------
* Check instruction exception
*-----------------------------------------------------------
CHK     MOVEM.L D0/A1,-(SP)
        MOVEA.L #CHK_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15
        BSR     DF
        MOVEM.L (SP)+,D0/A1
        RTE

*-----------------------------------------------------------
* Line A emulator exception
*-----------------------------------------------------------
LNEA    MOVEM.L D0/A1,-(SP)
        MOVEA.L #LNEA_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15
        BSR     DF
        MOVEM.L (SP)+,D0/A1
        RTE

*-----------------------------------------------------------
* Line F emulator exception
*-----------------------------------------------------------
LNEF    MOVEM.L D0/A1,-(SP)
        MOVEA.L #LNEF_MSG,A1
        MOVE.B  #13,D0
        TRAP    #15
        BSR     DF
        MOVEM.L (SP)+,D0/A1
        RTE

*-----------------------------------------------------------
* DIGIT: convert single ascii digit to hex
* Input: single ascii character in register D0
* Output: hex value in register D0
*-----------------------------------------------------------
DIGIT   CMP.B   #$40,D0
        BGT     HIGHER
        SUBI.B  #$30,D0
        BRA     EXITDIGIT
HIGHER  SUBI.B  #$37,D0
EXITDIGIT RTS

*-----------------------------------------------------------
* ASCII: convert ascii to hex
* Input: pointer to start of string in A1
* Output: hex value in register D1
*-----------------------------------------------------------
ASCII   MOVEM.L D0,-(SP)        ;save registers
        CLR.L   D0              ;clear for digit manipulation
        CLR.L   D1              ;clear for sum

CHAR    MOVE.B  (A1)+,D0        ;move digit
        TST.B   D0              ;continue until end of string
        BEQ     EXITASCII
        CMP.B   #$20,D0         ;continue until empty space
        BEQ     EXITASCII

        BSR     DIGIT

        MULS.W  #$10,D1         ;multiply by 10
        ADD.L   D0,D1           ;add digit (Horner)

        BRA     CHAR

EXITASCII MOVEM.L (SP)+,D0      ;restore registers
        RTS

*-----------------------------------------------------------
* SPACE: print space
*-----------------------------------------------------------
SPACE   MOVEM.L D0/D1,-(SP)

        MOVE.L  #$20,D1         ;print space
        MOVE.B  #6,D0
        TRAP    #15

        MOVEM.L (SP)+,D0/D1
        RTS

*-----------------------------------------------------------
* CRLF: print carriage return followed by line feed
*-----------------------------------------------------------
CRLF    MOVEM.L D0/D1,-(SP)

        MOVE.B  #$D,D1          ;print cr
        MOVE.B  #6,D0
        TRAP    #15
        MOVE.B  #$A,D1          ;print lf
        MOVE.B  #6,D0
        TRAP    #15

        MOVEM.L (SP)+,D0/D1
        RTS

        ORG     $50
TEST    DC.B    'Hello World!',0

        ORG     $100
        MOVEA.L #TEST,A1
        MOVE.B  #13,D0
        TRAP    #15
        RTS

        ORG     $200
        MOVE.W  D0,A1
        MOVE.W  D1,(A1)+
        RTS

        ORG     $300
        CLR     D0
        DIVS    D0,D0
        RTS

        END     START







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
