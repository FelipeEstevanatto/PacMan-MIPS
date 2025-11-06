.include"set0.asm"
.include"set0gameover.asm"
.include"set0youwin.asm"
.include"set0map1.asm"
.data
.eqv    KEYBOARD_ADDR, 68719411204($zero)
.eqv    KEY_A 97
.eqv    KEY_D 100
.eqv    KEY_W 119
.eqv    KEY_S 115

str1: .asciiz "game_advance_level"

.macro mov
.text
# Main player and ghosts start position initialization 
game_initialize:
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

main_game_loop: # Core loop of Input and Dispatch for the game
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    j main_game_loop

render_player_right:          #Movimento pac direira
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 5372($8)
    sw $22, 5884($8)
    sw $22, 5888($8)
    addi $16, $0, 50000       # Reduced delay - ghosts were moving faster
    jr $31

player_loop_stopped_right:          # Pauses Pacman movement on right wall
    lw $0, KEYBOARD_ADDR
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 5372($8)
    sw $22, 5884($8)
    sw $22, 5888($8)
    addi $26, $0, 5               #prende o pac man na parede e move todos fantasmas
    jal ghost1_ai_update
pintafanDP:
    jal ghost2_ai_update
pintafanDP2:
    jal ghost3_ai_update
pintafanDP3:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence                               #colisão com fantasma
    beq $11, $19, game_over_sequence
    jal delay_pac
    jal render_clear_player_right
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    lw $15, KEYBOARD_ADDR                         # Keep on loop until direction change
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    j player_loop_stopped_right


render_clear_player_right:                           #apaga o pac man virado para direita
    sw $20, 4860($8)
    sw $20, 4864($8)
    sw $20, 5372($8)
    sw $20, 5884($8)
    sw $20, 5888($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


render_player_left:             #Movimento pac esquerda
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 5376($8)
    sw $22, 5884($8)
    sw $22, 5888($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31

player_loop_stopped_left:
    lw $0, KEYBOARD_ADDR
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 5376($8)
    sw $22, 5884($8)
    sw $22, 5888($8)                     #recebe valor do teclado
    addi $26, $0, 6
    jal ghost1_ai_update
pintafanEP:                          #move os fantasmas 
    jal ghost2_ai_update
pintafanEP2:
    jal ghost3_ai_update
pintafanEP3:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal delay_pac
    jal render_clear_player_left
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    j player_loop_stopped_left
#código para outras direcoes

render_clear_player_left:
    sw $20, 4860($8)
    sw $20, 4864($8)
    sw $20, 5376($8)
    sw $20, 5884($8)
    sw $20, 5888($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


render_player_up:
    sw $22, 4860($8)
    sw $22, 4868($8)
    sw $22, 5372($8)
    sw $22, 5376($8)
    sw $22, 5380($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


render_clear_player_up:
    sw $20, 4860($8)
    sw $20, 4868($8)
    sw $20, 5372($8)
    sw $20, 5376($8)
    sw $20, 5380($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


player_loop_stopped_up:
    lw $0, KEYBOARD_ADDR
    sw $22, 4860($8)
    sw $22, 4868($8)
    sw $22, 5372($8)
    sw $22, 5376($8)
    sw $22, 5380($8)                      #recebe valor do teclado
    addi $26, $0, 7
    jal ghost1_ai_update
pintafanCP:
    jal ghost2_ai_update                        #movimenta fantasmas
pintafanCP2:
    jal ghost3_ai_update
pintafanCP3:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal delay_pac
    jal render_clear_player_up
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    j player_loop_stopped_up


render_player_down:
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 4868($8)
    sw $22, 5372($8)
    sw $22, 5380($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31


render_clear_player_down:
    sw $20, 4860($8)
    sw $20, 4864($8)
    sw $20, 4868($8)
    sw $20, 5372($8)
    sw $20, 5380($8)
    addi $16, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $31

player_loop_stopped_down:
    lw $0, KEYBOARD_ADDR
    sw $22, 4860($8)
    sw $22, 4864($8)
    sw $22, 4868($8)
    sw $22, 5372($8)
    sw $22, 5380($8)
    addi $26, $0, 8
    jal ghost1_ai_update
pintafanBP:
    jal ghost2_ai_update
pintafanBP2:
    jal ghost3_ai_update
pintafanBP3:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal delay_pac
    jal render_clear_player_down
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    j player_loop_stopped_down


input_handle_left:
    sw $0, KEYBOARD_ADDR
    jal render_clear_player_left
    j player_loop_moving_left

player_loop_moving_left:
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    lw $11, 4856($8)  # Supondo que 4860 seja a posição à esquerda
    lw $12, 5368($8)  # Supondo que 4860 seja a posição à esquerda
    lw $13, 5880($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $21, player_loop_stopped_left
    beq $12, $21, player_loop_stopped_left
    beq $13, $21, player_loop_stopped_left
    beq $12, $23, player_score_point_left     # Check for point collection $23 color
    jal player_continue_move_left
player_score_point_left:
    addi $29, $29, 200
    beq $29, 1000, game_advance_level
player_continue_move_left:
    addi $8, $8, -4
    addi $26, $0, 1
    jal ghost1_ai_update
pintafanE:
    jal ghost2_ai_update
pintafanE2:
    jal ghost3_ai_update
pintafanE3:
    jal render_player_left
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal delay_pac
    jal render_clear_player_left
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    j player_loop_moving_left

input_handle_right:
    sw $0, KEYBOARD_ADDR
    jal render_clear_player_right
    j player_loop_moving_right

player_loop_moving_right:
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    lw $11, 4872($8)  # Supondo que 4860 seja a posição à esquerda
    lw $12, 5384($8)  # Supondo que 4860 seja a posição à esquerda
    lw $13, 5896($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $21, player_loop_stopped_right
    beq $12, $21, player_loop_stopped_right
    beq $13, $21, player_loop_stopped_right
    beq $12, $23, player_score_point_right     # Check for point collection $23 color
    jal player_continue_move_right
player_score_point_right:
    addi $29, $29, 200
    beq $29, 200, game_advance_level
player_continue_move_right:
    addi $8, $8, 4
    addi $26, $0, 2
    jal ghost1_ai_update
pintafanD:
    jal ghost2_ai_update
pintafanD2:
    jal ghost3_ai_update
pintafanD3:
    jal render_player_right
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal delay_pac
    jal render_clear_player_right
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    j player_loop_moving_right

game_over_sequence:
    set0gameover()          #perdeu o jogo
    jr $31
game_advance_level:
    addi $29, $0, 0
    lui $8, 0x1001		#Setar o primeiro pixel
    lui $10, 0x1001		#Setar o primeiro pixel
    lui $9, 0x1001		#Setar o primeiro pixel
    lui $18, 0x1001		#Setar o primeiro pixel
    addi $17, $17, 1
    beq $17, 1, load_map_2    #chama segunda fase
    beq $17, 2, load_map_1    #chama terceira fase
    beq $17, 3 game_win_screen       #completou tudo
load_map_2:
    set0()
    jr $31
load_map_1:
    Draw_Map1()
    jr $31
game_win_screen:
    set0youwin()
    jr $31

input_handle_up:
    sw $0, KEYBOARD_ADDR
    jal render_clear_player_up
    j player_loop_moving_up

player_loop_moving_up:
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    lw $11, 4348($8)  # Supondo que 4860 seja a posição à esquerda
    lw $12, 4352($8)  # Supondo que 4860 seja a posição à esquerda
    lw $13, 4356($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $21, player_loop_stopped_up
    beq $12, $21, player_loop_stopped_up
    beq $13, $21, player_loop_stopped_up
    beq $12, $23, player_score_point_up     # Check for point collection $23 color
    jal player_continue_move_up
player_score_point_up:
    addi $29, $29, 200
    beq $29, 1000, game_advance_level
player_continue_move_up:
    addi $8, $8, -512
    addi $26, $0, 3
    jal ghost1_ai_update
pintafanC:
    jal ghost2_ai_update
pintafanC2:
    jal ghost3_ai_update
pintafanC3:
    jal render_player_up
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal delay_pac
    jal render_clear_player_up
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    j player_loop_moving_up

input_handle_down:
    sw $0, KEYBOARD_ADDR
    jal render_clear_player_down
    j player_loop_moving_down

player_loop_moving_down:
    lw $15, KEYBOARD_ADDR
    beq $15, KEY_A, input_handle_left
    beq $15, KEY_D, input_handle_right
    beq $15, KEY_W, input_handle_up
    beq $15, KEY_S, input_handle_down
    lw $11, 6396($8)  # Supondo que 4860 seja a posição à esquerda
    lw $12, 6400($8)  # Supondo que 4860 seja a posição à esquerda
    lw $13, 6404($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $21, player_loop_stopped_down
    beq $12, $21, player_loop_stopped_down
    beq $13, $21, player_loop_stopped_down
    beq $12, $23, player_score_point_down     # Check for point collection $23 color
    jal player_continue_move_down
player_score_point_down:
    addi $29, $29, 200
    beq $29, 1000, game_advance_level
player_continue_move_down:
    addi $8, $8, 512
    addi $26, $0, 4
    jal ghost1_ai_update
pintafanB:
    jal ghost2_ai_update
pintafanB2:
    jal ghost3_ai_update
pintafanB3:
    jal render_player_down
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal delay_pac
    jal render_clear_player_down
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    j player_loop_moving_down

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

ghost1_ai_update:
    lw $11, 1040($10)  #parede cima
    lw $12, 2056($10)  #parede esquerda
    lw $13, 2072($10)  #parede direita
    lw $14, 3088($10)  #parede baixo
ghost1_ai_check_walls:                             #verifica todas possiveis colisões com a parede
    beq $11, $21, andBaixo
    beq $12, $21, andDireita
    beq $13, $21, andEsquerda
    beq $14, $21, andCima
    jal ghost1_ai_decide_all_dirs
ghost1_ai_return:
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
    beq $12, $21, ghost1_ai_decide_down_right
    beq $13, $21, ghost1_ai_decide_down_left
    beq $14, $21, decide_DireitaEsquerda
    jal ghost1_ai_decide_down_left_right
andBaixoDireita:
    beq $13, $21, ghost1_move_down
    beq $14, $21, ghost1_move_left
    jal andB2
andDireita:
    beq $13, $21, andDireitaEsquerda
andD2:
    beq $11, $21, ghost1_ai_decide_down_right
    beq $14, $21, decide_CimaDireita
    beq $13, $21, ghost1_ai_decide_up_down
    jal decideCDB
andDireitaEsquerda:
    beq $14, $21, ghost1_move_up
    jal andD2

andEsquerda:
    beq $11, $21, andEsquerdaBaixo
andE2:
    beq $14, $21, ghost1_ai_decide_up_left
    beq $11, $21, ghost1_ai_decide_down_left
    beq $12, $21, ghost1_ai_decide_up_down
    jal decideCEB
andEsquerdaBaixo:
    beq $13, $21, ghost1_move_down
    beq $14, $21, ghost1_move_right
andCima:
    beq $11, $21, decide_DireitaEsquerda
    beq $12, $21, decide_CimaDireita
    beq $13, $21, ghost1_ai_decide_up_left
    jal decideCED
ghost1_ai_decide_down_right:                            #decide através de uma random qual direção vai seguir

addi $30, $0, 0

    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
   
    addi $30, $0, 50
    bgt $a0, $30, ghost1_move_down
    jal ghost1_move_right
    
    ghost1_move_right:
    addi $30, $zero, 3
  
    
    addi $10, $10, 12
    jal ghost1_ai_return
    
    ghost1_move_down:
    addi $30, $zero, 3
    addi $10, $10, 1536
    jal ghost1_ai_return
    
ghost1_ai_decide_up_down:       # (A 2-way "hallway" decision)
    beq $30, 2, ghost1_move_up
    beq $30, 3, ghost1_move_down 
    
    jal ghost1_move_down
    
ghost1_move_up:
    addi $30, $zero, 2
    addi $10, $10, -1536
    jal ghost1_ai_return


decide_DireitaEsquerda:
    beq $30, 2, ghost1_move_left
    beq $30, 3, ghost1_move_right
    jal ghost1_move_right
    
ghost1_move_left:
    addi $30, $0, 2
    addi $10, $10, -12
    jal ghost1_ai_return
    
ghost1_ai_decide_down_left:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost1_move_down
    jal ghost1_move_left
    
ghost1_ai_decide_up_left:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost1_move_up
    jal ghost1_move_left
    
   
decide_CimaDireita:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost1_move_up
    jal ghost1_move_right
    
ghost1_ai_decide_down_left_right:   # (A 3-way "T-junction")
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 60
    bgt $a0, $30, ghost1_move_down
    bgt $a0, $5, ghost1_move_left
    jal ghost1_move_right
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
    bgt $a0, $30, ghost1_move_down
    bgt $a0, $5, ghost1_move_up
    jal ghost1_move_right

ghost1_ai_decide_all_dirs:      # (A 4-way intersection)
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
    bgt $a0, $30, ghost1_move_right
    bgt $a0, $5, ghost1_move_up
    bgt $a0, $6, ghost1_move_down
    jal ghost1_move_left
    
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
    bgt $a0, $30, ghost1_move_down
    bgt $a0, $5, ghost1_move_up
    jal ghost1_move_left
   
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
    bgt $a0, $30, ghost1_move_up
    bgt $a0, $5, ghost1_move_right
    jal ghost1_move_left
    
######################################## Ghost 2 
ghost2_ai_update:                             
    lw $11, 28688($9)  #parede cima
    lw $12, 29704($9)  #parede esquerda
    lw $13, 29720($9)  #parede direita
    lw $14, 30736($9)  #parede baixo
ghost2_ai_check_walls:                              #verifica todas possiveis colisões com a parede
    beq $11, $21, andBaixo2
    beq $12, $21, andDireita2
    beq $13, $21, andEsquerda2
    beq $14, $21, andCima2
    jal ghost2_ai_decide_all_dirs
ghost2_ai_return:
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
    beq $12, $21, ghost2_ai_decide_down_right
    beq $13, $21, ghost2_ai_decide_down_left
    beq $14, $21, decide_DireitaEsquerda2
    jal ghost2_ai_decide_down_left_right
andBaixoDireita2:
    beq $13, $21, ghost2_move_down
    beq $14, $21, ghost2_move_left
    jal andB22
andDireita2:
    beq $13, $21, andDireitaEsquerda2
andD22:
    beq $11, $21, ghost2_ai_decide_down_right
    beq $14, $21, decide_CimaDireita2
    beq $13, $21, ghost2_ai_decide_up_down
    jal decideCDB2
andDireitaEsquerda2:
    beq $14, $21, ghost2_move_up

    jal andD22

andEsquerda2:
    beq $11, $21, andEsquerdaBaixo2
andE22:
    beq $14, $21, ghost2_ai_decide_up_left
    beq $11, $21, ghost2_ai_decide_down_left
    beq $12, $21, ghost2_ai_decide_up_down
    jal decideCEB2
andEsquerdaBaixo2:
    beq $13, $21, ghost2_move_down
    beq $14, $21, ghost2_move_right
andCima2:
    beq $11, $21, decide_DireitaEsquerda2
    beq $12, $21, decide_CimaDireita2
    beq $13, $21, ghost2_ai_decide_up_left
    jal decideCED2

ghost2_ai_decide_down_right:
    addi $30, $0, 0                           #decide através de uma random qual direção vai seguir

    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $0, 50
    bgt $a0, $30, ghost2_move_down
    jal ghost2_move_right
    
ghost2_move_right:
    addi $27, $zero, 3
  
    
    addi $9, $9, 12
    jal ghost2_ai_return
    
ghost2_move_down:
    addi $27, $zero, 3
    addi $9, $9, 1536
    jal ghost2_ai_return
    
ghost2_ai_decide_up_down:       # (A 2-way "hallway" decision)
    beq $27, 2, ghost2_move_up
    beq $27, 3, ghost2_move_down

    jal ghost2_move_down
    
ghost2_move_up:
    addi $27, $zero, 2
    addi $9 $9, -1536
    jal ghost2_ai_return

decide_DireitaEsquerda2:
    beq $27, 2, ghost2_move_left
    beq $27, 3, ghost2_move_right
    jal ghost2_move_right
    
ghost2_move_left:
    addi $27, $0, 2
    addi $9, $9, -12
    jal ghost2_ai_return
    
ghost2_ai_decide_down_left:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost2_move_down
    jal ghost2_move_left
    
    
ghost2_ai_decide_up_left:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost2_move_up
    jal ghost2_move_left
   
decide_CimaDireita2:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost2_move_up
    jal ghost2_move_right
    
ghost2_ai_decide_down_left_right:   # (A 3-way "T-junction")
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
    bgt $a0, $30, ghost2_move_down
    bgt $a0, $5, ghost2_move_left
    jal ghost2_move_right

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
    bgt $a0, $5, ghost2_move_right
    bgt $a0, $30, ghost2_move_up
    jal ghost2_move_down

ghost2_ai_decide_all_dirs:      # (A 4-way intersection)
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
    bgt $a0, $6, ghost2_move_right
    bgt $a0, $5, ghost2_move_up
    bgt $a0, $30, ghost2_move_down
    jal ghost2_move_left
    
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
    bgt $a0, $5, ghost2_move_up
    bgt $a0, $30, ghost2_move_down
    jal ghost2_move_left
   
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
    bgt $a0, $5, ghost2_move_up
    bgt $a0, $30, ghost2_move_right
    jal ghost2_move_left
    
    ########################### Ghost3
    
ghost3_ai_update:
    lw $11, 29168($18)  #parede cima
    lw $12, 30184($18)  #parede esquerda
    lw $13, 30200($18)  #parede direita
    lw $14, 31216($18)  #parede baixo
ghost3_ai_check_walls:
    beq $11, $21, andBaixo3                            #verifica todas possiveis colisões com a parede
    beq $12, $21, andDireita3
    beq $13, $21, andEsquerda3
    beq $14, $21, andCima3
    jal ghost3_ai_decide_all_dirs
ghost3_ai_return:
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
    beq $12, $21, ghost3_ai_decide_down_right
    beq $13, $21, ghost3_ai_decide_down_left
    beq $14, $21, decide_DireitaEsquerda3
    jal ghost3_ai_decide_down_left_right
andBaixoDireita3:
    beq $13, $21, ghost3_move_down
    beq $14, $21, ghost3_move_left
    jal andB23
andDireita3:
    beq $13, $21, andDireitaEsquerda3
andD23:
    beq $11, $21, ghost3_ai_decide_down_right
    beq $14, $21, decide_CimaDireita3
    beq $13, $21, ghost3_ai_decide_up_down
    jal decideCDB3
andDireitaEsquerda3:
    beq $14, $21, ghost3_move_up

    jal andD23
andEsquerda3:
    beq $11, $21, andEsquerdaBaixo3
andE23:
    beq $14, $21, ghost3_ai_decide_up_left
    beq $11, $21, ghost3_ai_decide_down_left
    beq $12, $21, ghost3_ai_decide_up_down
    jal decideCEB3
andEsquerdaBaixo3:
    beq $13, $21, ghost3_move_down
    beq $14, $21, ghost3_move_right
andCima3:
    beq $11, $21, decide_DireitaEsquerda3
    beq $12, $21, decide_CimaDireita3
    beq $13, $21, ghost3_ai_decide_up_left
    jal decideCED3
ghost3_ai_decide_down_right:
    addi $30, $0, 0                         #decide através de uma random qual direção vai seguir

    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
   
    addi $30, $0, 50
    bgt $a0, $30, ghost3_move_down
    jal ghost3_move_right
    
ghost3_move_right:
    addi $28, $zero, 3
  
    
    addi $18, $18, 12
    jal ghost3_ai_return
    
ghost3_move_down:
    addi $28, $zero, 3
    addi $18, $18, 1536
    jal ghost3_ai_return
    
ghost3_ai_decide_up_down:       # (A 2-way "hallway" decision)
    beq $28, 2, ghost3_move_up
    beq $28, 3, ghost3_move_down
    
    jal ghost3_move_down
    
ghost3_move_up:
    addi $28, $zero, 2
    addi $18, $18, -1536
    jal ghost3_ai_return

decide_DireitaEsquerda3:
    beq $28, 2, ghost3_move_left
    beq $28, 3, ghost3_move_right
    jal ghost3_move_right
    
ghost3_move_left:
    addi $28, $0, 2
    addi $18, $18, -12
    jal ghost3_ai_return
    
ghost3_ai_decide_down_left:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost3_move_down
    jal ghost3_move_left
    
    
ghost3_ai_decide_up_left:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost3_move_up
    jal ghost3_move_left
    
   
decide_CimaDireita3:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 50
    bgt $a0, $30, ghost3_move_up
    jal ghost3_move_right
    
ghost3_ai_decide_down_left_right:   # (A 3-way "T-junction")
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $30, 60
    bgt $a0, $5, ghost3_move_down
    bgt $a0, $5, ghost3_move_left
    jal ghost3_move_right
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
    bgt $a0, $5, ghost3_move_down
    bgt $a0, $30, ghost3_move_up
    jal ghost3_move_right

ghost3_ai_decide_all_dirs:      # (A 4-way intersection)
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
    bgt $a0, $6, ghost3_move_right
    bgt $a0, $5, ghost3_move_up
    bgt $a0, $30, ghost3_move_down
    jal ghost3_move_left
    
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
    bgt $a0, $5, ghost3_move_down
    bgt $a0, $30, ghost3_move_up
    jal ghost3_move_left
   
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
    bgt $a0, $5, ghost3_move_up
    bgt $a0, $30, ghost3_move_right
    jal ghost3_move_left
    
render_ghost_1:                            #pinta e apaga os fantasmas
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

render_clear_ghost_1:
    sw $20, 1548($10)
    sw $20, 1552($10)
    sw $20, 1556($10)
    sw $20, 2060($10)
    sw $20, 2068($10)
    sw $20, 2572($10)
    sw $20, 2576($10)
    sw $20, 2580($10)
    jr $31

render_ghost_2:
    sw $19, 29196($9)
    sw $19, 29200($9)
    sw $19, 29204($9)
    sw $19, 29708($9)
    sw $19, 29716($9)
    sw $19, 30220($9)
    sw $19, 30224($9)
    sw $19, 30228($9)
    jr $31

render_clear_ghost_2:
    sw $20, 29196($9)
    sw $20, 29200($9)
    sw $20, 29204($9)
    sw $20, 29708($9)
    sw $20, 29716($9)
    sw $20, 30220($9)
    sw $20, 30224($9)
    sw $20, 30228($9)
    jr $31

render_ghost_3:
    sw $25, 29676($18)
    sw $25, 29680($18)
    sw $25, 29684($18)
    sw $25, 30188($18)
    sw $25, 30196($18)
    sw $25, 30700($18)
    sw $25, 30704($18)
    sw $25, 30708($18)
    jr $31

render_clear_ghost_3:
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
