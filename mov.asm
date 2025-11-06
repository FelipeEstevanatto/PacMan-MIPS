.include"set0.asm"
.include"set0gameover.asm"
.include"set0youwin.asm"
.include"set0map1.asm"
.data
.eqv  KEYBOARD_ADDR, 68719411204($zero)
.eqv KEY_A 97
.eqv KEY_D 100
.eqv KEY_W 119
.eqv KEY_S 115

str1: .asciiz "Game_WinAndAdvance"

.macro mov
.text
# Main player and ghosts start position initialization 
Game_Init:
    lui $10, 0x1001		# base address of the bitmap display memory (first pixel)
    add $8, $0, $10     # $8 holds the current position of the main player
    add $9, $0, $10     # $9 holds the current position of ghost 1
    addi $18, $0, 0     # ghost 1 position offset  
    add $18, $0, $10    
    add $17, $0, $0     # maybe level counter
    addi $29, $0, 0     # $29 maybe score counter
    addi $7, $0, 0
    addi $30, $0, 0     # maybe direction tracker for ghost 1
    addi $27, $0, 0     # maybe direction tracker for ghost 2
    addi $28, $0, 0     # maybe direction tracker for ghost 3

Input_PollAndDispatch:
    lw $15, KEYBOARD_ADDR  #Receber o valor do teclado
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    j Input_PollAndDispatch

pinta_pac_direita:          #Movimento pac direira
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 5372($8)
    sw $22, 5884($8)
    sw $22, 5888($8)
    addi $16, $0, 50000       # Reduced delay - ghosts were moving faster
    jr $31

para_pac_direita:          # Pauses Pacman movement on right wall
    lw $0, KEYBOARD_ADDR
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 5372($8)
    sw $22, 5884($8)
    sw $22, 5888($8)
    addi $26, $0, 5               #prende o pac man na parede e move todos fantasmas
    jal moveGhost1
pintafanDP:
    jal moveGhost2
pintafanDP2:
    jal moveGhost3
pintafanDP3:
    jal pinta_fantasma1
    jal pinta_fantasma2
    jal pinta_fantasma3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, Game_Over
    beq $11, $25, Game_Over                               #colisão com fantasma
    beq $11, $19, Game_Over
    jal delay_pac
    jal apaga_pac_direita
    jal apaga_fantasma1
    jal apaga_fantasma2
    jal apaga_fantasma3
    lw $15, KEYBOARD_ADDR                         # Keep on loop until direction change
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    j para_pac_direita


apaga_pac_direita:                           #apaga o pac man virado para direita
    sw $20, 4860($8)
    sw $20, 4864($8)
    sw $20, 5372($8)
    sw $20, 5884($8)
    sw $20, 5888($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


pinta_pac_esquerda:             #Movimento pac esquerda
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 5376($8)
    sw $22, 5884($8)
    sw $22, 5888($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31

para_pac_esquerda:
    lw $0, KEYBOARD_ADDR
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 5376($8)
    sw $22, 5884($8)
    sw $22, 5888($8)                     #recebe valor do teclado
    addi $26, $0, 6
    jal moveGhost1
pintafanEP:                          #move os fantasmas 
    jal moveGhost2
pintafanEP2:
    jal moveGhost3
pintafanEP3:
    jal pinta_fantasma1
    jal pinta_fantasma2
    jal pinta_fantasma3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, Game_Over
    beq $11, $25, Game_Over
    beq $11, $19, Game_Over
    jal delay_pac
    jal apaga_pac_esquerda
    jal apaga_fantasma1
    jal apaga_fantasma2
    jal apaga_fantasma3
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    j para_pac_esquerda
#código para outras direcoes

apaga_pac_esquerda:
    sw $20, 4860($8)
    sw $20, 4864($8)
    sw $20, 5376($8)
    sw $20, 5884($8)
    sw $20, 5888($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


pinta_pac_cima:
    sw $22, 4860($8)
    sw $22, 4868($8)
    sw $22, 5372($8)
    sw $22, 5376($8)
    sw $22, 5380($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


apaga_pac_cima:
    sw $20, 4860($8)
    sw $20, 4868($8)
    sw $20, 5372($8)
    sw $20, 5376($8)
    sw $20, 5380($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


para_pac_cima:
    lw $0, KEYBOARD_ADDR
    sw $22, 4860($8)
    sw $22, 4868($8)
    sw $22, 5372($8)
    sw $22, 5376($8)
    sw $22, 5380($8)                      #recebe valor do teclado
    addi $26, $0, 7
    jal moveGhost1
pintafanCP:
    jal moveGhost2                        #movimenta fantasmas
pintafanCP2:
    jal moveGhost3
pintafanCP3:
    jal pinta_fantasma1
    jal pinta_fantasma2
    jal pinta_fantasma3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, Game_Over
    beq $11, $25, Game_Over
    beq $11, $19, Game_Over
    jal delay_pac
    jal apaga_pac_cima
    jal apaga_fantasma1
    jal apaga_fantasma2
    jal apaga_fantasma3
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    j para_pac_cima


pinta_pac_baixo:
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 4868($8)
    sw $22, 5372($8)
    sw $22, 5380($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


apaga_pac_baixo:
    sw $20, 4860($8)
    sw $20, 4864($8)
    sw $20, 4868($8)
    sw $20, 5372($8)
    sw $20, 5380($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31

para_pac_baixo:
    lw $0, KEYBOARD_ADDR
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 4868($8)
    sw $22, 5372($8)
    sw $22, 5380($8)
    addi $26, $0, 8
    jal moveGhost1
pintafanBP:
    jal moveGhost2
pintafanBP2:
    jal moveGhost3
pintafanBP3:
    jal pinta_fantasma1
    jal pinta_fantasma2
    jal pinta_fantasma3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, Game_Over
    beq $11, $25, Game_Over
    beq $11, $19, Game_Over
    jal delay_pac
    jal apaga_pac_baixo
    jal apaga_fantasma1
    jal apaga_fantasma2
    jal apaga_fantasma3
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    j para_pac_baixo


esquerda:
    sw $0, KEYBOARD_ADDR
    jal apaga_pac_esquerda
    j move_pac_esquerda

move_pac_esquerda:
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    lw $11, 4856($8)  # Supondo que 4860 seja a posição à esquerda
    lw $12, 5368($8)  # Supondo que 4860 seja a posição à esquerda
    lw $13, 5880($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $21, para_pac_esquerda
    beq $12, $21, para_pac_esquerda
    beq $13, $21, para_pac_esquerda
    beq $12, $23, pontuaEsq     # Check for point collection $23 color
    jal cont_Esq
pontuaEsq:
    addi $29, $29, 200
    beq $29, 1000, Game_WinAndAdvance
cont_Esq:
    addi $8, $8, -4
    addi $26, $0, 1
    jal moveGhost1
pintafanE:
    jal moveGhost2
pintafanE2:
    jal moveGhost3
pintafanE3:
    jal pinta_pac_esquerda
    jal pinta_fantasma1
    jal pinta_fantasma2
    jal pinta_fantasma3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, Game_Over
    beq $11, $25, Game_Over
    beq $11, $19, Game_Over
    jal delay_pac
    jal apaga_pac_esquerda
    jal apaga_fantasma1
    jal apaga_fantasma2
    jal apaga_fantasma3
    j move_pac_esquerda

direita:
    sw $0, KEYBOARD_ADDR
    jal apaga_pac_direita
    j move_pac_direita

move_pac_direita:
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    lw $11, 4872($8)  # Supondo que 4860 seja a posição à esquerda
    lw $12, 5384($8)  # Supondo que 4860 seja a posição à esquerda
    lw $13, 5896($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $21, para_pac_direita
    beq $12, $21, para_pac_direita
    beq $13, $21, para_pac_direita
    beq $12, $23, pontuaDir     # Check for point collection $23 color
    jal cont_Dir
pontuaDir:
    addi $29, $29, 200
    beq $29, 200, Game_WinAndAdvance
cont_Dir:
    addi $8, $8, 4
    addi $26, $0, 2
    jal moveGhost1
pintafanD:
    jal moveGhost2
pintafanD2:
    jal moveGhost3
pintafanD3:
    jal pinta_pac_direita
    jal pinta_fantasma1
    jal pinta_fantasma2
    jal pinta_fantasma3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, Game_Over
    beq $11, $25, Game_Over
    beq $11, $19, Game_Over
    jal delay_pac
    jal apaga_pac_direita
    jal apaga_fantasma1
    jal apaga_fantasma2
    jal apaga_fantasma3
    j move_pac_direita

Game_Over:
    set0gameover()          #perdeu o jogo
    jr $31
Game_WinAndAdvance:
    addi $29, $0, 0
    lui $8, 0x1001		#Setar o primeiro pixel
    lui $10, 0x1001		#Setar o primeiro pixel
    lui $9, 0x1001		#Setar o primeiro pixel
    lui $18, 0x1001		#Setar o primeiro pixel
    addi $17, $17, 1
    beq $17, 1, Load_Map2    #chama segunda fase
    beq $17, 2, Load_Map1    #chama terceira fase
    beq $17, 3 Show_YouWin       #completou tudo
Load_Map2:
    set0()
    jr $31
Load_Map1:
    Draw_Map1()
    jr $31
Show_YouWin:
    set0youwin()
    jr $31

cima:
    sw $0, KEYBOARD_ADDR
    jal apaga_pac_cima
    j move_pac_cima

move_pac_cima:
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    lw $11, 4348($8)  # Supondo que 4860 seja a posição à esquerda
    lw $12, 4352($8)  # Supondo que 4860 seja a posição à esquerda
    lw $13, 4356($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $21, para_pac_cima
    beq $12, $21, para_pac_cima
    beq $13, $21, para_pac_cima
    beq $12, $23, pontuaCima     # Check for point collection $23 color
    jal cont_Cima
pontuaCima:
    addi $29, $29, 200
    beq $29, 1000, Game_WinAndAdvance
cont_Cima:
    addi $8, $8, -512
    addi $26, $0, 3
    jal moveGhost1
pintafanC:
    jal moveGhost2
pintafanC2:
    jal moveGhost3
pintafanC3:
    jal pinta_pac_cima
    jal pinta_fantasma1
    jal pinta_fantasma2
    jal pinta_fantasma3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, Game_Over
    beq $11, $25, Game_Over
    beq $11, $19, Game_Over
    jal delay_pac
    jal apaga_pac_cima
    jal apaga_fantasma1
    jal apaga_fantasma2
    jal apaga_fantasma3
    j move_pac_cima

baixo:
    sw $0, KEYBOARD_ADDR
    jal apaga_pac_baixo
    j move_pac_baixo

move_pac_baixo:
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, esquerda
    beq $15, KEY_D, direita
    beq $15, KEY_W, cima
    beq $15, KEY_S, baixo
    lw $11, 6396($8)  # Supondo que 4860 seja a posição à esquerda
    lw $12, 6400($8)  # Supondo que 4860 seja a posição à esquerda
    lw $13, 6404($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $21, para_pac_baixo
    beq $12, $21, para_pac_baixo
    beq $13, $21, para_pac_baixo
    beq $12, $23, pontuaBaixo     # Check for point collection $23 color
    jal cont_baixo
pontuaBaixo:
    addi $29, $29, 200
    beq $29, 1000, Game_WinAndAdvance
cont_baixo:
    addi $8, $8, 512
    addi $26, $0, 4
    jal moveGhost1
pintafanB:
    jal moveGhost2
pintafanB2:
    jal moveGhost3
pintafanB3:
    jal pinta_pac_baixo
    jal pinta_fantasma1
    jal pinta_fantasma2
    jal pinta_fantasma3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, Game_Over
    beq $11, $25, Game_Over
    beq $11, $19, Game_Over
    jal delay_pac
    jal apaga_pac_baixo
    jal apaga_fantasma1
    jal apaga_fantasma2
    jal apaga_fantasma3
    j move_pac_baixo

delay:
    addi $16, $16, -1
    nop
    bne $16, $0, delay
    jr $31
    
delay_pac:
    addi $16, $16, -1
    nop
    bne $16, $0, delay
    jr $31

.text

moveGhost1:
    lw $11, 1040($10)  #parede cima
    lw $12, 2056($10)  #parede esquerda
    lw $13, 2072($10)  #parede direita
    lw $14, 3088($10)  #parede baixo
branchs:                             #verifica todas possiveis colisões com a parede
    beq $11, $21, andBaixo
    beq $12, $21, andDireita
    beq $13, $21, andEsquerda
    beq $14, $21, andCima
    jal decideCBED
returnpac:
    beq $26, 1, pintafanE
    beq $26, 2, pintafanD
    beq $26, 3, pintafanC
    beq $26, 4, pintafanB
    beq $26, 5, pintafanDP
    beq $26, 6, pintafanEP
    beq $26, 7, pintafanCP
    beq $26, 8, pintafanBP
    jal pintafanD
andBaixo:
    beq $12, $21, andBaixoDireita
andB2:
    beq $12, $21, decide_baixodireita
    beq $13, $21, decide_baixoEsquerda
    beq $14, $21, decide_DireitaEsquerda
    jal decideBED
andBaixoDireita:
    beq $13, $21, baixofan
    beq $14, $21, esquerdafan
    jal andB2
andDireita:
    beq $13, $21, andDireitaEsquerda
andD2:
    beq $11, $21, decide_baixodireita
    beq $14, $21, decide_CimaDireita
    beq $13, $21, decide_CimaBaixo
    jal decideCDB
andDireitaEsquerda:
    beq $14, $21, cimafan
    jal andD2

andEsquerda:
    beq $11, $21, andEsquerdaBaixo
andE2:
    beq $14, $21, decide_CimaEsquerda
    beq $11, $21, decide_baixoEsquerda
    beq $12, $21, decide_CimaBaixo
    jal decideCEB
andEsquerdaBaixo:
    beq $13, $21, baixofan
    beq $14, $21, direitafan
andCima:
    beq $11, $21, decide_DireitaEsquerda
    beq $12, $21, decide_CimaDireita
    beq $13, $21, decide_CimaEsquerda
    jal decideCED
decide_baixodireita:                            #decide através de uma random qual direção vai seguir

addi $30, $0, 0

    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
   
    addi $30, $0, 50
    bgt $a0, $30, baixofan
    jal direitafan
    
    direitafan:
    addi $30, $zero, 3
  
    
    addi $10, $10, 12
    jal returnpac
    
    baixofan:
    addi $30, $zero, 3
    addi $10, $10, 1536
    jal returnpac
    
decide_CimaBaixo:
    beq $30, 2, cimafan
    beq $30, 3, baixofan 
    
    jal baixofan
    
cimafan:
    addi $30, $zero, 2
    addi $10, $10, -1536
    jal returnpac


decide_DireitaEsquerda:
    beq $30, 2, esquerdafan
    beq $30, 3, direitafan
    jal direitafan
    
esquerdafan:
    addi $30, $0, 2
    addi $10, $10, -12
    jal returnpac
    
decide_baixoEsquerda:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, baixofan
    jal esquerdafan
    
decide_CimaEsquerda:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, cimafan
    jal esquerdafan
    
   
decide_CimaDireita:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, cimafan
    jal direitafan
    
decideBED:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 60
    bgt $a0, $30, baixofan
    bgt $a0, $5, esquerdafan
    jal direitafan
decideCDB:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 60
    bgt $a0, $30, baixofan
    bgt $a0, $5, cimafan
    jal direitafan

decideCBED:
    addi $30, $0, 0
    addi $a1, $zero, 100 
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 50
    addi $6, $6, 80
    bgt $a0, $30, direitafan
    bgt $a0, $5, cimafan
    bgt $a0, $6, baixofan
    jal esquerdafan
    
decideCEB:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 50
    bgt $a0, $30, baixofan
    bgt $a0, $5, cimafan
    jal esquerdafan
   
decideCED:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 50
    bgt $a0, $30, cimafan
    bgt $a0, $5, direitafan
    jal esquerdafan
    
######################################## Ghost 2 
moveGhost2:                             
    lw $11, 28688($9)  #parede cima
    lw $12, 29704($9)  #parede esquerda
    lw $13, 29720($9)  #parede direita
    lw $14, 30736($9)  #parede baixo
branchs2:                              #verifica todas possiveis colisões com a parede
    beq $11, $21, andBaixo2
    beq $12, $21, andDireita2
    beq $13, $21, andEsquerda2
    beq $14, $21, andCima2
    jal decideCBED2
returnpac2:
    beq $26, 1, pintafanE2
    beq $26, 2, pintafanD2
    beq $26, 3, pintafanC2
    beq $26, 4, pintafanB2
    beq $26, 5, pintafanDP2
    beq $26, 6, pintafanEP2
    beq $26, 7, pintafanCP2
    beq $26, 8, pintafanBP2
    jal pintafanD2
andBaixo2:
    beq $12, $21, andBaixoDireita2
andB22:
    beq $12, $21, decide_baixodireita2
    beq $13, $21, decide_baixoEsquerda2
    beq $14, $21, decide_DireitaEsquerda2
    jal decideBED2
andBaixoDireita2:
    beq $13, $21, baixofan2
    beq $14, $21, esquerdafan2
    jal andB22
andDireita2:
    beq $13, $21, andDireitaEsquerda2
andD22:
    beq $11, $21, decide_baixodireita2
    beq $14, $21, decide_CimaDireita2
    beq $13, $21, decide_CimaBaixo2
    jal decideCDB2
andDireitaEsquerda2:
    beq $14, $21, cimafan2

    jal andD22

andEsquerda2:
    beq $11, $21, andEsquerdaBaixo2
andE22:
    beq $14, $21, decide_CimaEsquerda2
    beq $11, $21, decide_baixoEsquerda2
    beq $12, $21, decide_CimaBaixo2
    jal decideCEB2
andEsquerdaBaixo2:
    beq $13, $21, baixofan2
    beq $14, $21, direitafan2
andCima2:
    beq $11, $21, decide_DireitaEsquerda2
    beq $12, $21, decide_CimaDireita2
    beq $13, $21, decide_CimaEsquerda2
    jal decideCED2

decide_baixodireita2:
    addi $30, $0, 0                           #decide através de uma random qual direção vai seguir

    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $0, 50
    bgt $a0, $30, baixofan2
    jal direitafan2
    
direitafan2:
    addi $27, $zero, 3
  
    
    addi $9, $9, 12
    jal returnpac2
    
baixofan2:
    addi $27, $zero, 3
    addi $9, $9, 1536
    jal returnpac2
    
decide_CimaBaixo2:

    beq $27, 2, cimafan2
    beq $27, 3, baixofan2

    jal baixofan2
    
cimafan2:
    addi $27, $zero, 2
    addi $9 $9, -1536
    jal returnpac2

decide_DireitaEsquerda2:
    beq $27, 2, esquerdafan2
    beq $27, 3, direitafan2
    jal direitafan2
    
esquerdafan2:
    addi $27, $0, 2
    addi $9, $9, -12
    jal returnpac2
    
decide_baixoEsquerda2:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, baixofan2
    jal esquerdafan2
    
    
decide_CimaEsquerda2:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, cimafan2
    jal esquerdafan2
   
decide_CimaDireita2:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, cimafan2
    jal direitafan2
    
decideBED2:
    addi $30, $0, 0
    addi $5, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 35
    addi $5, $5, 65
    bgt $a0, $30, baixofan2
    bgt $a0, $5, esquerdafan2
    jal direitafan2

decideCDB2:
    addi $30, $0, 0
    addi $5, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 35
    addi $5, $5, 65
    bgt $a0, $5, direitafan2
    bgt $a0, $30, cimafan2
    jal baixofan2

decideCBED2:
    addi $30, $0, 0
    addi $5, $0, 0
    addi $6, $0, 0
    addi $a1, $zero, 100 
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 50
    addi $6, $6, 80
    bgt $a0, $6, direitafan2
    bgt $a0, $5, cimafan2
    bgt $a0, $30, baixofan2
    jal esquerdafan2
    
decideCEB2:
    addi $30, $0, 0
    addi $5, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall

    move $a0, $a0
   
    addi $30, $30, 35
    addi $5, $5, 65
    bgt $a0, $5, cimafan2
    bgt $a0, $30, baixofan2
    jal esquerdafan2
   
decideCED2:
    addi $30, $0, 0
    addi $5, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $5, $5, 35
    addi $30, $30, 65
    bgt $a0, $5, cimafan2
    bgt $a0, $30, direitafan2
    jal esquerdafan2
    
    ########################### Ghost3
    
moveGhost3:
    lw $11, 29168($18)  #parede cima
    lw $12, 30184($18)  #parede esquerda
    lw $13, 30200($18)  #parede direita
    lw $14, 31216($18)  #parede baixo
branchs3:
    beq $11, $21, andBaixo3                            #verifica todas possiveis colisões com a parede
    beq $12, $21, andDireita3
    beq $13, $21, andEsquerda3
    beq $14, $21, andCima3
    jal decideCBED3
returnpac3:
    beq $26, 1, pintafanE3
    beq $26, 2, pintafanD3
    beq $26, 3, pintafanC3
    beq $26, 4, pintafanB3
    beq $26, 5, pintafanDP3
    beq $26, 6, pintafanEP3
    beq $26, 7, pintafanCP3
    beq $26, 8, pintafanBP3
    jal pintafanD3
andBaixo3:
    beq $12, $21, andBaixoDireita3
andB23:
    beq $12, $21, decide_baixodireita3
    beq $13, $21, decide_baixoEsquerda3
    beq $14, $21, decide_DireitaEsquerda3
    jal decideBED3
andBaixoDireita3:
    beq $13, $21, baixofan3
    beq $14, $21, esquerdafan3
    jal andB23
andDireita3:
    beq $13, $21, andDireitaEsquerda3
andD23:
    beq $11, $21, decide_baixodireita3
    beq $14, $21, decide_CimaDireita3
    beq $13, $21, decide_CimaBaixo3
    jal decideCDB3
andDireitaEsquerda3:
    beq $14, $21, cimafan3

    jal andD23
andEsquerda3:
    beq $11, $21, andEsquerdaBaixo3
andE23:
    beq $14, $21, decide_CimaEsquerda3
    beq $11, $21, decide_baixoEsquerda3
    beq $12, $21, decide_CimaBaixo3
    jal decideCEB3
andEsquerdaBaixo3:
    beq $13, $21, baixofan3
    beq $14, $21, direitafan3
andCima3:
    beq $11, $21, decide_DireitaEsquerda3
    beq $12, $21, decide_CimaDireita3
    beq $13, $21, decide_CimaEsquerda3
    jal decideCED3
decide_baixodireita3:
    addi $30, $0, 0                         #decide através de uma random qual direção vai seguir

    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
   
    addi $30, $0, 50
    bgt $a0, $30, baixofan3
    jal direitafan3
    
direitafan3:
    addi $28, $zero, 3
  
    
    addi $18, $18, 12
    jal returnpac3
    
baixofan3:
    addi $28, $zero, 3
    addi $18, $18, 1536
    jal returnpac3
    
decide_CimaBaixo3:
    beq $28, 2, cimafan3
    beq $28, 3, baixofan3
    
    jal baixofan3
    
cimafan3:
    addi $28, $zero, 2
    addi $18, $18, -1536
    jal returnpac3

decide_DireitaEsquerda3:
    beq $28, 2, esquerdafan3
    beq $28, 3, direitafan3
    jal direitafan3
    
esquerdafan3:
    addi $28, $0, 2
    addi $18, $18, -12
    jal returnpac3
    
decide_baixoEsquerda3:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, baixofan3
    jal esquerdafan3
    
    
decide_CimaEsquerda3:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, cimafan3
    jal esquerdafan3
    
   
decide_CimaDireita3:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, cimafan3
    jal direitafan3
    
decideBED3:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $30, 60
    bgt $a0, $5, baixofan3
    bgt $a0, $5, esquerdafan3
    jal direitafan3
decideCDB3:
    addi $30, $0, 0
   addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 60
    bgt $a0, $5, baixofan3
    bgt $a0, $30, cimafan3
    jal direitafan3

decideCBED3:
    addi $30, $0, 0
    addi $a1, $zero, 100 
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 50
    addi $6, $6, 80
    bgt $a0, $6, direitafan3
    bgt $a0, $5, cimafan3
    bgt $a0, $30, baixofan3
    jal esquerdafan3
    
decideCEB3:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 50
    bgt $a0, $5, baixofan3
    bgt $a0, $30, cimafan3
    jal esquerdafan3
   
decideCED3:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 50
    bgt $a0, $5, cimafan3
    bgt $a0, $30, direitafan3
    jal esquerdafan3
    
pinta_fantasma1:                            #pinta e apaga os fantasmas
    sw $24, 1548($10)
    sw $24, 1552($10)
    sw $24, 1556($10)
    sw $24, 2060($10)
    sw $24, 2068($10)
    sw $24, 2572($10)
    sw $24, 2576($10)
    sw $24, 2580($10)
    addi $16, $0, 60000      # Set delay to match Pac-Man speed (this defines ghost speed also for some reason)
    jr $31

apaga_fantasma1:
    sw $20, 1548($10)
    sw $20, 1552($10)
    sw $20, 1556($10)
    sw $20, 2060($10)
    sw $20, 2068($10)
    sw $20, 2572($10)
    sw $20, 2576($10)
    sw $20, 2580($10)
    jr $31

pinta_fantasma2:
    sw $19, 29196($9)
    sw $19, 29200($9)
    sw $19, 29204($9)
    sw $19, 29708($9)
    sw $19, 29716($9)
    sw $19, 30220($9)
    sw $19, 30224($9)
    sw $19, 30228($9)
    jr $31

apaga_fantasma2:
    sw $20, 29196($9)
    sw $20, 29200($9)
    sw $20, 29204($9)
    sw $20, 29708($9)
    sw $20, 29716($9)
    sw $20, 30220($9)
    sw $20, 30224($9)
    sw $20, 30228($9)
    jr $31

pinta_fantasma3:
    sw $25, 29676($18)
    sw $25, 29680($18)
    sw $25, 29684($18)
    sw $25, 30188($18)
    sw $25, 30196($18)
    sw $25, 30700($18)
    sw $25, 30704($18)
    sw $25, 30708($18)
    jr $31

apaga_fantasma3:
    sw $20, 29676($18)
    sw $20, 29680($18)
    sw $20, 29684($18)
    sw $20, 30188($18)
    sw $20, 30196($18)
    sw $20, 30700($18)
    sw $20, 30704($18)
    sw $20, 30708($18)
    jr $31

delay2:
    addi $16, $16, -1
    nop
    bne $16, $0, delay2
    jr $31
delay_ghost:
    addi $16, $16, -1
    nop
    bne $16, $0, delay_ghost
    jr $31
.end_macro
