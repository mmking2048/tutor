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
        
PROMPT  DC.B    'MONITOR441> '  ;prompt
        DC.B    $00
INVALID DC.B    'INVALID COMMAND'
        DC.B    $00

INPUT   DS.B    80              ;buffer for commands

COMP_TBL                        ;table of all commands
        DC.B    'HELP'
        DC.B    $00
        DS.B    1
        DC.B    'MDSP'
        DC.B    $00
        DS.B    1
        DC.B    'SORTW'
        DC.B    $00
        DC.B    'MM'
        DC.B    $00
        DS.B    3
        DC.B    'MS'
        DC.B    $00
        DS.B    3
        DC.B    'BF'
        DC.B    $00
        DS.B    3
        DC.B    'BMOV'
        DC.B    $00
        DS.B    1
        DC.B    'BTST'
        DC.B    $00
        DS.B    1
        DC.B    'BSCH'
        DC.B    $00
        DS.B    1
        DC.B    'GO'
        DC.B    $00
        DS.B    3
        DC.B    'DF'
        DC.B    $00
        DS.B    3
        DC.B    'EXIT'
        DC.B    $00
        DS.B    1

COMP_ADDR                       ;table of handlers
        DC.B    'beep'

*-----------------------------------------------------------
* Program segment
*-----------------------------------------------------------        
        ORG     $3000
*Start here: set up and call to main        
START                           ;set up here
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
HELP    RTS

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

        END START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
