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
        DS.B    1               ;padding so table is aligned at 6 bytes
        DC.B    'MDSP',0
        DS.B    1
        DC.B    'SORTW',0
        DC.B    'MM',0
        DS.B    3
        DC.B    'MS',0
        DS.B    3
        DC.B    'BF',0
        DS.B    3
        DC.B    'BMOV',0
        DS.B    1
        DC.B    'BTST',0
        DS.B    1
        DC.B    'BSCH',0
        DS.B    1
        DC.B    'GO',0
        DS.B    3
        DC.B    'DF',0
        DS.B    3
        DC.B    'EXIT',0
        DS.B    1

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
HELP12  DC.B    'EXIT: terminate the program',0

*-----------------------------------------------------------
* Program segment
*-----------------------------------------------------------        
        ORG     $3000
*Start here: set up and call to main        
START   BSR     SETUP           ;set up here
        BSR     MAIN            ;call main
        
        MOVE.B  #9,D0           ;exit program
        TRAP    #15
        
* Main method
MAIN    MOVEA.L #PROMPT,A1
        MOVE.B  #14,D0
        TRAP    #15             ;print prompt
        
        MOVEA.L #INPUT,A1
        MOVE.B  #2,D0
        TRAP    #15             ;read command

        BSR     PARSE
        
        BRA     MAIN            ;get next command
        
EXITMAIN RTS

*-----------------------------------------------------------
* Setup exception handler
*-----------------------------------------------------------
SETUP   MOVE.L  BUS,$008
        MOVE.L  ADDR,$00C
        MOVE.L  ILLI,$010
        MOVE.L  DIV0,$014
        MOVE.L  CHK,$018
        MOVE.L  PRIV,$020
        MOVE.L  LNEA,$028
        MOVE.L  LNEF,$02C
        RTS

*-----------------------------------------------------------
* Parse commands
*-----------------------------------------------------------
PARSE   MOVEM.L A1/A2/A3/D0,-(SP)     ;save registers
        MOVEA.L #INPUT,A1       ;get front of string
        
        MOVEA.L #COMP_TBL,A2    ;get item in command string table
        MOVEA.L #COMP_TBL,A3
        
        MOVE.L  #4,D0            ;set D0 to number of chars to check

PHELP   CMP.B   (A1)+,(A3)+
        DBNE    D0,PHELP        ;check next character
        BNE     NHELP           ;if did not match, check next string
        BSR     HELP
        BRA     EXITPARSE

NHELP   BSR     NCHAR
        MOVE.L  #4,D0

PMDSP   CMP.B   (A1)+,(A3)+
        DBNE    D0,PMDSP        ;check next character
        BNE     NMDSP
        BSR     MDSP
        BRA     EXITPARSE       ;if all chars matched, exit

NMDSP   BSR     NCHAR
        MOVE.L  #5,D0

PSORTW  CMP.B   (A1)+,(A3)+
        DBNE    D0,PSORTW       ;check next character
        BNE     NSORTW
        BSR     SORTW
        BRA     EXITPARSE       ;if all chars matched, exit

NSORTW  BSR     NCHAR
        MOVE.L  #2,D0

PMM     CMP.B   (A1)+,(A3)+
        DBNE    D0,PMM          ;check next character
        BNE     NMM
        BSR     MM
        BRA     EXITPARSE       ;if all chars matched, exit

NMM     BSR     NCHAR
        MOVE.L  #2,D0

PMS     CMP.B   (A1)+,(A3)+
        DBNE    D0,PMS          ;check next character
        BNE     NMS
        BSR     MS
        BRA     EXITPARSE       ;if all chars matched, exit

NMS     BSR     NCHAR
        MOVE.L  #2,D0

PBF     CMP.B   (A1)+,(A3)+
        DBNE    D0,PBF          ;check next character
        BNE     NBF
        BSR     BF
        BRA     EXITPARSE       ;if all chars matched, exit

NBF     BSR     NCHAR
        MOVE.L  #4,D0

PBMOV   CMP.B   (A1)+,(A3)+
        DBNE    D0,PBMOV        ;check next character
        BNE     NBMOV
        BSR     BMOV
        BRA     EXITPARSE       ;if all chars matched, exit

NBMOV   BSR     NCHAR
        MOVE.L  #4,D0

PBTST   CMP.B   (A1)+,(A3)+
        DBNE    D0,PBTST        ;check next character
        BNE     NBTST
        BSR     BTST
        BRA     EXITPARSE       ;if all chars matched, exit

NBTST   BSR     NCHAR
        MOVE.L  #4,D0

PBSCH   CMP.B   (A1)+,(A3)+
        DBNE    D0,PBSCH        ;check next character
        BNE     NBSCH
        BSR     BSCH
        BRA     EXITPARSE       ;if all chars matched, exit

NBSCH   BSR     NCHAR
        MOVE.L  #2,D0

PGO     CMP.B   (A1)+,(A3)+
        DBNE    D0,PGO          ;check next character
        BNE     NGO
        BSR     GO
        BRA     EXITPARSE       ;if all chars matched, exit

NGO     BSR     NCHAR
        MOVE.L  #2,D0

PDF     CMP.B   (A1)+,(A3)+
        DBNE    D0,PDF          ;check next character
        BNE     NDF
        BSR     DF
        BRA     EXITPARSE       ;if all chars matched, exit

NDF     BSR     NCHAR
        MOVE.L  #4,D0

PEXIT   CMP.B   (A1)+,(A3)+
        DBNE    D0,PEXIT         ;check next character
        BNE     NEXIT
        BSR     EXIT
        BRA     EXITPARSE        ;if all chars matched, exit

NEXIT   MOVEA.L #INVALID,A1      ;if got here, failed
        MOVE.B  #13,D0
        TRAP    #15
        
EXITPARSE
        MOVEM.L (SP)+,A1/A2/A3/D0 ;restore registers
        RTS

*-----------------------------------------------------------
* Helper function for incrementing between checks
*-----------------------------------------------------------
NCHAR   MOVEA.L #INPUT,A1       ;reset A1 to beginning of input string
        ADDA.L  #6,A2           ;increment to get next command string
        MOVEA.L A2,A3           ;update counter 
        RTS

*-----------------------------------------------------------
* HELP
*-----------------------------------------------------------
HELP    MOVEM.L D0/A1,-(SP)     ;save registers

        MOVEA.L #HELP1,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP2,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP2A,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP3,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP4,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP5,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP6,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP7,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP8,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP9,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP10,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP11,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEA.L #HELP12,A1
        MOVE.B #13,D0
        TRAP #15

        MOVEM.L (SP)+,D0/A1     ;restore registers
        RTS

*-----------------------------------------------------------
* MDSP
*-----------------------------------------------------------
MDSP    RTS

*-----------------------------------------------------------
* SORTW
*-----------------------------------------------------------
SORTW   RTS

*-----------------------------------------------------------
* MM
*-----------------------------------------------------------
MM      RTS

*-----------------------------------------------------------
* MS
*-----------------------------------------------------------
MS      RTS

*-----------------------------------------------------------
* BF
*-----------------------------------------------------------
BF      RTS

*-----------------------------------------------------------
* BMOV
*-----------------------------------------------------------
BMOV    RTS

*-----------------------------------------------------------
* BTST
*-----------------------------------------------------------
BTST    RTS

*-----------------------------------------------------------
* BSCH
*-----------------------------------------------------------
BSCH    RTS

*-----------------------------------------------------------
* GO
*-----------------------------------------------------------
GO      RTS

*-----------------------------------------------------------
* DF
*-----------------------------------------------------------
DF      RTS

*-----------------------------------------------------------
* EXIT
*-----------------------------------------------------------
EXIT    RTS

*-----------------------------------------------------------
* Bus error exception
*-----------------------------------------------------------
BUS     RTE

*-----------------------------------------------------------
* Address error exception
*-----------------------------------------------------------
ADDR    RTE

*-----------------------------------------------------------
* Illegal instruction exception
*-----------------------------------------------------------
ILLI    RTE

*-----------------------------------------------------------
* Privilege violation exception
*-----------------------------------------------------------
PRIV    RTE

*-----------------------------------------------------------
* Divide by zero exception
*-----------------------------------------------------------
DIV0    RTE

*-----------------------------------------------------------
* Check instruction exception
*-----------------------------------------------------------
CHK     RTE

*-----------------------------------------------------------
* Line A emulator exception
*-----------------------------------------------------------
LNEA    RTE

*-----------------------------------------------------------
* Line F emulator exception
*-----------------------------------------------------------
LNEF    RTE

        END START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
