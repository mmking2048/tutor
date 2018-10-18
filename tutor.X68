*-----------------------------------------------------------
* Title      : ECE 441 Design Project
* Written by : Michelle Yang
* Date       : 11/9/2018
* Description: Simple operating system for Easy 68K
*-----------------------------------------------------------        ORG     $1000
        ORG     $1000
        
PROMPT  DC.B    'MONITOR441> '  ;prompt
        DC.B    $00
BUFFER  DS.B    80              ;buffer for commands
        
        ORG     $3000
        
START   MOVEM.L A1,-(SP)        ;save A1
        
        MOVEA.L #PROMPT,A1      
        MOVE.B  #14,D0
        TRAP    #15             ;print prompt
        
        MOVEA.L #BUFFER,A1
        MOVE.B  #2,D0
        TRAP    #15
        
        BRA     START            ;get next command
        
EXIT    MOVE.B  #9,D0
        TRAP    #15
        
        END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
