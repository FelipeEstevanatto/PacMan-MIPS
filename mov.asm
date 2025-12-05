.include "clearScreen.asm"
.include "map1.asm"
.include "map2.asm"
.include "gameover.asm"
.include "youwin.asm"

.data
.eqv    KEYBOARD_ADDR, 68719411204($zero)
.eqv    KEY_A 97
.eqv    KEY_D 100
.eqv    KEY_W 119
.eqv    KEY_S 115

# REGISTER MAP:
# $8  : Player Position Address
# $9  : Ghost 2 Position Address
# $10 : Ghost 1 Position Address
# $18 : Ghost 3 Position Address
# $26 : Game State/Direction (1=Left, 2=Right, 3=Up, 4=Down, 5-8=Stopped)
# $29 : Score
# $16 : Delay Counter

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
ghost1_return_stopped_right:
    jal ghost2_ai_update
ghost2_return_stopped_right:
    jal ghost3_ai_update
ghost3_return_stopped_right:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence                               #colisão com fantasma
    beq $11, $19, game_over_sequence
    jal general_delay         # Refactored: Unified delay call
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


render_clear_player_right:                           # apaga o pac man virado para direita
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
ghost1_return_stopped_left:                          #move os fantasmas - Return target for Ghost 1 when player is stopped left
    jal ghost2_ai_update
ghost2_return_stopped_left:
    jal ghost3_ai_update
ghost3_return_stopped_left:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal general_delay         # Refactored: Unified delay call
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
ghost1_return_stopped_up:                             # Return target for Ghost 1 when player is stopped up.
    jal ghost2_ai_update                        #movimenta fantasmas
ghost2_return_stopped_up:
    jal ghost3_ai_update
ghost3_return_stopped_up:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal general_delay         # Refactored: Unified delay call
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
ghost1_return_stopped_down:                 # Return target for Ghost 1 when player is stopped down.
    jal ghost2_ai_update
ghost2_return_stopped_down:
    jal ghost3_ai_update
ghost3_return_stopped_down:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal general_delay         # Refactored: Unified delay call
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
ghost1_return_moving_left:
    jal ghost2_ai_update
ghost2_return_moving_left:
    jal ghost3_ai_update
ghost3_return_moving_left:
    jal render_player_left
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal general_delay         # Refactored: Unified delay call
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
ghost1_return_moving_right:                  # Return target for Ghost 1 when player is moving right.
    jal ghost2_ai_update
ghost2_return_moving_right:
    jal ghost3_ai_update
ghost3_return_moving_right:
    jal render_player_right
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal general_delay         # Refactored: Unified delay call
    jal render_clear_player_right
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    j player_loop_moving_right

game_over_sequence:  #perdeu o jogo
    clearScreen()
    gameover()

    li $v0, 10 # Exit program
    syscall

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
    clearScreen()
    drawn_map2()
    jr $31
load_map_1:
    clearScreen()
    drawn_map1()
    jr $31
game_win_screen:
    clearScreen()
    drawn_youwin()
    
    li $v0, 10 # Exit program
    syscall

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
ghost1_return_moving_up:
    jal ghost2_ai_update
ghost2_return_moving_up:
    jal ghost3_ai_update
ghost3_return_moving_up:
    jal render_player_up
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal general_delay         # Refactored: Unified delay call
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
ghost1_return_moving_down:
    jal ghost2_ai_update
ghost2_return_moving_down:
    jal ghost3_ai_update
ghost3_return_moving_down:
    jal render_player_down
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $11, 4860($8)  # Supondo que 4860 seja a posição à esquerda
    beq $11, $24, game_over_sequence
    beq $11, $25, game_over_sequence
    beq $11, $19, game_over_sequence
    jal general_delay         # Refactored: Unified delay call
    jal render_clear_player_down
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    j player_loop_moving_down

general_delay:
    addi $16, $16, -1
    nop
    bne $16, $0, general_delay
    jr $31
    
.text

# EXPLANATION OF CHANGES:
# 1. Collision Detection: Previously, ghosts only checked the center pixel in the direction of movement.
#    This caused them to "eat" walls because their corners would clip into the wall before the center hit it.
#    The new logic checks TWO points (the corners) for each direction.
#    Example: Moving UP checks the pixel above the Top-Left corner AND the pixel above the Top-Right corner.
#
# 2. Speed Control: The speed is defined in the movement labels (e.g., ghost1_move_right).
#    Look for instructions like 'addi $10, $10, 4'.
#    - 4 bytes = 1 pixel horizontal movement.
#    - 512 bytes = 1 pixel vertical movement (assuming 512 bytes per line).
#    To make ghosts faster, increase these values (e.g., 8 for 2 pixels).
#    To make them slower, you would need a frame counter to only move every Nth frame, 
#    since 1 pixel is the minimum atomic movement in this bitmap setup.

ghost1_ai_update:
    # UP Check: Check pixels above Top-Left (1036) and Top-Right (1044)
    # Original was 1040 (Center). 
    lw $11, 1036($10)       
    beq $11, $21, g1_up_wall_detected
    lw $11, 1044($10)       
g1_up_wall_detected:
    # $11 now holds the wall color if either corner hit a wall

    # LEFT Check: Check pixels left of Top-Left (1544) and Bottom-Left (2568)
    # Original was 2056 (Center).
    lw $12, 1544($10)       
    beq $12, $21, g1_left_wall_detected
    lw $12, 2568($10)       
g1_left_wall_detected:

    # RIGHT Check: Check pixels right of Top-Right (1560) and Bottom-Right (2584)
    # Original was 2072 (Center).
    lw $13, 1560($10)       
    beq $13, $21, g1_right_wall_detected
    lw $13, 2584($10)       
g1_right_wall_detected:

    # DOWN Check: Check pixels below Bottom-Left (3084) and Bottom-Right (3092)
    # Original was 3088 (Center).
    lw $14, 3084($10)       
    beq $14, $21, g1_down_wall_detected
    lw $14, 3092($10)       
g1_down_wall_detected:

ghost1_ai_check_walls:                             #verifica todas possiveis colisões com a parede
    beq $11, $21, ghost1_ai_check_wall_down
    beq $12, $21, ghost1_ai_check_wall_right
    beq $13, $21, ghost1_ai_check_wall_left
    beq $14, $21, ghost1_ai_check_wall_up
    jal ghost1_ai_decide_all_dirs
ghost1_ai_return:
    beq $26, 1, ghost1_return_moving_left
    beq $26, 2, ghost1_return_moving_right
    beq $26, 3, ghost1_return_moving_up
    beq $26, 4, ghost1_return_moving_down
    beq $26, 5, ghost1_return_stopped_right              # Return target for Ghost 1 when player is stopped right.
    beq $26, 6, ghost1_return_stopped_left
    beq $26, 7, ghost1_return_stopped_up
    beq $26, 8, ghost1_return_stopped_down
    jal ghost1_return_moving_right
ghost1_ai_check_wall_down:
    beq $12, $21, ghost1_ai_check_wall_down_right
ghost1_ai_check_wall_down_cont:
    beq $12, $21, ghost1_ai_decide_down_right
    beq $13, $21, ghost1_ai_decide_down_left
    beq $14, $21, ghost1_ai_decide_left_right
    jal ghost1_ai_decide_down_left_right
ghost1_ai_check_wall_down_right:
    beq $13, $21, ghost1_move_down
    beq $14, $21, ghost1_move_left
    jal ghost1_ai_check_wall_down_cont
ghost1_ai_check_wall_right:
    beq $13, $21, ghost1_ai_check_wall_right_left
ghost1_ai_check_wall_right_cont:
    beq $11, $21, ghost1_ai_decide_down_right
    beq $14, $21, ghost1_ai_decide_up_right
    beq $13, $21, ghost1_ai_decide_up_down
    jal ghost1_ai_decide_up_right_down
ghost1_ai_check_wall_right_left:
    beq $14, $21, ghost1_move_up
    jal ghost1_ai_check_wall_right_cont

ghost1_ai_check_wall_left:
    beq $11, $21, ghost1_ai_check_wall_left_down
ghost1_ai_check_wall_left_cont:
    beq $14, $21, ghost1_ai_decide_up_left
    beq $11, $21, ghost1_ai_decide_down_left
    beq $12, $21, ghost1_ai_decide_up_down
    jal ghost1_ai_decide_up_left_down
ghost1_ai_check_wall_left_down:
    beq $13, $21, ghost1_move_down
    beq $14, $21, ghost1_move_right
ghost1_ai_check_wall_up:
    beq $11, $21, ghost1_ai_decide_left_right
    beq $12, $21, ghost1_ai_decide_up_right
    beq $13, $21, ghost1_ai_decide_up_left
    jal ghost1_ai_decide_up_left_right
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
  
    # SPEED CONTROL: Horizontal
    # Change '4' to '8' to move 2 pixels at a time (faster).
    # Keep at '4' to match player speed (1 pixel).
    addi $10, $10, 4
    jal ghost1_ai_return
    
    ghost1_move_down:
    addi $30, $zero, 3
    # SPEED CONTROL: Vertical
    # Change '512' to '1024' to move 2 pixels at a time (faster).
    addi $10, $10, 512
    jal ghost1_ai_return
    
ghost1_ai_decide_up_down:       # (A 2-way "hallway" decision)
    beq $30, 2, ghost1_move_up
    beq $30, 3, ghost1_move_down 
    
    jal ghost1_move_down
    
ghost1_move_up:
    addi $30, $zero, 2
    # SPEED CONTROL: Vertical Up
    addi $10, $10, -512
    jal ghost1_ai_return


ghost1_ai_decide_left_right:
    beq $30, 2, ghost1_move_left
    beq $30, 3, ghost1_move_right
    jal ghost1_move_right
    
ghost1_move_left:
    addi $30, $0, 2
    # SPEED CONTROL: Horizontal Left
    addi $10, $10, -4
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
    
   
ghost1_ai_decide_up_right:
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
ghost1_ai_decide_up_right_down:
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
    bgt $a0, $6, ghost1_move_right
    bgt $a0, $5, ghost1_move_up
    bgt $a0, $30, ghost1_move_down
    jal ghost1_move_left
    
ghost1_ai_decide_up_left_down:
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
   
ghost1_ai_decide_up_left_right:
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
    # UP Check (Corners)
    lw $11, 28684($9)
    beq $11, $21, g2_up_wall
    lw $11, 28692($9)
g2_up_wall:

    # LEFT Check (Corners)
    lw $12, 29192($9)
    beq $12, $21, g2_left_wall
    lw $12, 30216($9)
g2_left_wall:

    # RIGHT Check (Corners)
    lw $13, 29208($9)
    beq $13, $21, g2_right_wall
    lw $13, 30232($9)
g2_right_wall:

    # DOWN Check (Corners)
    lw $14, 30732($9)
    beq $14, $21, g2_down_wall
    lw $14, 30740($9)
g2_down_wall:

ghost2_ai_check_walls:                              #verifica todas possiveis colisões com a parede
    beq $11, $21, ghost2_ai_check_wall_down
    beq $12, $21, ghost2_ai_check_wall_right
    beq $13, $21, ghost2_ai_check_wall_left
    beq $14, $21, ghost2_ai_check_wall_up
    jal ghost2_ai_decide_all_dirs
ghost2_ai_return:
    beq $26, 1, ghost2_return_moving_left
    beq $26, 2, ghost2_return_moving_right
    beq $26, 3, ghost2_return_moving_up
    beq $26, 4, ghost2_return_moving_down
    beq $26, 5, ghost2_return_stopped_right
    beq $26, 6, ghost2_return_stopped_left
    beq $26, 7, ghost2_return_stopped_up
    beq $26, 8, ghost2_return_stopped_down
    jal ghost2_return_moving_right
ghost2_ai_check_wall_down:
    beq $12, $21, ghost2_ai_check_wall_down_right
ghost2_ai_check_wall_down_cont:
    beq $12, $21, ghost2_ai_decide_down_right
    beq $13, $21, ghost2_ai_decide_down_left
    beq $14, $21, ghost2_ai_decide_left_right
    jal ghost2_ai_decide_down_left_right
ghost2_ai_check_wall_down_right:
    beq $13, $21, ghost2_move_down
    beq $14, $21, ghost2_move_left
    jal ghost2_ai_check_wall_down_cont
ghost2_ai_check_wall_right:
    beq $13, $21, ghost2_ai_check_wall_right_left
ghost2_ai_check_wall_right_cont:
    beq $11, $21, ghost2_ai_decide_down_right
    beq $14, $21, ghost2_ai_decide_up_right
    beq $13, $21, ghost2_ai_decide_up_down
    jal ghost2_ai_decide_up_right_down
ghost2_ai_check_wall_right_left:
    beq $14, $21, ghost2_move_up

    jal ghost2_ai_check_wall_right_cont

ghost2_ai_check_wall_left:
    beq $11, $21, ghost2_ai_check_wall_left_down
ghost2_ai_check_wall_left_cont:
    beq $14, $21, ghost2_ai_decide_up_left
    beq $11, $21, ghost2_ai_decide_down_left
    beq $12, $21, ghost2_ai_decide_up_down
    jal ghost2_ai_decide_up_left_down
ghost2_ai_check_wall_left_down:
    beq $13, $21, ghost2_move_down
    beq $14, $21, ghost2_move_right
ghost2_ai_check_wall_up:
    beq $11, $21, ghost2_ai_decide_left_right
    beq $12, $21, ghost2_ai_decide_up_right
    beq $13, $21, ghost2_ai_decide_up_left
    jal ghost2_ai_decide_up_left_right

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
  
    # SPEED CONTROL: Horizontal
    addi $9, $9, 4
    jal ghost2_ai_return
    
ghost2_move_down:
    addi $27, $zero, 3
    # SPEED CONTROL: Vertical
    addi $9, $9, 512
    jal ghost2_ai_return
    
ghost2_ai_decide_up_down:       # (A 2-way "hallway" decision)
    beq $27, 2, ghost2_move_up
    beq $27, 3, ghost2_move_down

    jal ghost2_move_down
    
ghost2_move_up:
    addi $27, $zero, 2
    # SPEED CONTROL: Vertical
    addi $9, $9, -512
    jal ghost2_ai_return

ghost2_ai_decide_left_right:
    beq $27, 2, ghost2_move_left
    beq $27, 3, ghost2_move_right
    jal ghost2_move_right
    
ghost2_move_left:
    addi $27, $0, 2
    # SPEED CONTROL: Horizontal
    addi $9, $9, -4
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
   
ghost2_ai_decide_up_right:
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

ghost2_ai_decide_up_right_down:
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
    
ghost2_ai_decide_up_left_down:
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
   
ghost2_ai_decide_up_left_right:
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
    # UP Check (Corners)
    lw $11, 29164($18)
    beq $11, $21, g3_up_wall
    lw $11, 29172($18)
g3_up_wall:

    # LEFT Check (Corners)
    lw $12, 29672($18)
    beq $12, $21, g3_left_wall
    lw $12, 30696($18)
g3_left_wall:

    # RIGHT Check (Corners)
    lw $13, 29688($18)
    beq $13, $21, g3_right_wall
    lw $13, 30712($18)
g3_right_wall:

    # DOWN Check (Corners)
    lw $14, 31212($18)
    beq $14, $21, g3_down_wall
    lw $14, 31220($18)
g3_down_wall:

ghost3_ai_check_walls:
    beq $11, $21, ghost3_ai_check_wall_down                            #verifica todas possiveis colisões com a parede
    beq $12, $21, ghost3_ai_check_wall_right
    beq $13, $21, ghost3_ai_check_wall_left
    beq $14, $21, ghost3_ai_check_wall_up
    jal ghost3_ai_decide_all_dirs
ghost3_ai_return:
    beq $26, 1, ghost3_return_moving_left
    beq $26, 2, ghost3_return_moving_right
    beq $26, 3, ghost3_return_moving_up
    beq $26, 4, ghost3_return_moving_down
    beq $26, 5, ghost3_return_stopped_right
    beq $26, 6, ghost3_return_stopped_left
    beq $26, 7, ghost3_return_stopped_up
    beq $26, 8, ghost3_return_stopped_down
    jal ghost3_return_moving_right
ghost3_ai_check_wall_down:
    beq $12, $21, ghost3_ai_check_wall_down_right
ghost3_ai_check_wall_down_cont:
    beq $12, $21, ghost3_ai_decide_down_right
    beq $13, $21, ghost3_ai_decide_down_left
    beq $14, $21, ghost3_ai_decide_left_right
    jal ghost3_ai_decide_down_left_right
ghost3_ai_check_wall_down_right:
    beq $13, $21, ghost3_move_down
    beq $14, $21, ghost3_move_left
    jal ghost3_ai_check_wall_down_cont
ghost3_ai_check_wall_right:
    beq $13, $21, ghost3_ai_check_wall_right_left
ghost3_ai_check_wall_right_cont:
    beq $11, $21, ghost3_ai_decide_down_right
    beq $14, $21, ghost3_ai_decide_up_right
    beq $13, $21, ghost3_ai_decide_up_down
    jal ghost3_ai_decide_up_right_down
ghost3_ai_check_wall_right_left:
    beq $14, $21, ghost3_move_up

    jal ghost3_ai_check_wall_right_cont
ghost3_ai_check_wall_left:
    beq $11, $21, ghost3_ai_check_wall_left_down
ghost3_ai_check_wall_left_cont:
    beq $14, $21, ghost3_ai_decide_up_left
    beq $11, $21, ghost3_ai_decide_down_left
    beq $12, $21, ghost3_ai_decide_up_down
    jal ghost3_ai_decide_up_left_down
ghost3_ai_check_wall_left_down:
    beq $13, $21, ghost3_move_down
    beq $14, $21, ghost3_move_right
ghost3_ai_check_wall_up:
    beq $11, $21, ghost3_ai_decide_left_right
    beq $12, $21, ghost3_ai_decide_up_right
    beq $13, $21, ghost3_ai_decide_up_left
    jal ghost3_ai_decide_up_left_right
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
  
    # SPEED CONTROL: Horizontal
    addi $18, $18, 4
    jal ghost3_ai_return
    
ghost3_move_down:
    addi $28, $zero, 3
    # SPEED CONTROL: Vertical
    addi $18, $18, 512
    jal ghost3_ai_return
    
ghost3_ai_decide_up_down:       # (A 2-way "hallway" decision)
    beq $28, 2, ghost3_move_up
    beq $28, 3, ghost3_move_down
    
    jal ghost3_move_down
    
ghost3_move_up:
    addi $28, $zero, 2
    # SPEED CONTROL: Vertical
    addi $18, $18, -512
    jal ghost3_ai_return

ghost3_ai_decide_left_right:
    beq $28, 2, ghost3_move_left
    beq $28, 3, ghost3_move_right
    jal ghost3_move_right
    
ghost3_move_left:
    addi $28, $0, 2
    # SPEED CONTROL: Horizontal
    addi $18, $18, -4
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
    
   
ghost3_ai_decide_up_right:
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
    bgt $a0, $30, ghost3_move_left
    jal ghost3_move_right
ghost3_ai_decide_up_right_down:
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
    
ghost3_ai_decide_up_left_down:
    addi $30, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    
    move $a0, $a0
   
    addi $30, $30, 30
    addi $5, $5, 50
    bgt $a0, $30, ghost3_move_down
    bgt $a0, $5, ghost3_move_up
    jal ghost3_move_left
   
ghost3_ai_decide_up_left_right:
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
.end_macro