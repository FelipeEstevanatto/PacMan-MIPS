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
# $t0  : Player Position Address
# $t1  : Ghost 2 Position Address
# $t2 : Ghost 1 Position Address
# $s2 : Ghost 3 Position Address
# $k0 : Game State/Direction (1=Left, 2=Right, 3=Up, 4=Down, 5-8=Stopped)
# $a3 : Score (accumulates points, resets on level up)
# $s0 : Delay Counter

.macro mov
.text
# Main player and ghosts start position initialization 
game_initialize:
    lui $t2, 0x1001		# base address of the bitmap display memory (first pixel)
    add $t0, $0, $t2     # $t0 holds the current position of the main player
    add $t1, $0, $t2     # $t1 holds the current position of ghost 1
    addi $s2, $0, 0     # ghost 1 position offset  
    add $s2, $0, $t2    
    add $s1, $0, $0     # maybe level counter
    addi $a3, $0, 0     # score counter
    addi $fp, $0, 0     # maybe direction tracker for ghost 1
    addi $k1, $0, 0     # maybe direction tracker for ghost 2
    addi $gp, $0, 0     # maybe direction tracker for ghost 3

main_game_loop: # Core loop of Input and Dispatch for the game
    lw $t7, KEYBOARD_ADDR
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    j main_game_loop

render_player_right:          # Render Pac-Man facing right
    sw $s6, 4860($t0)
    sw $s6, 4864($t0)
    sw $s6, 5372($t0)
    sw $s6, 5884($t0)
    sw $s6, 5888($t0)
    addi $s0, $0, 50000       # Reduced delay - ghosts were moving faster
    jr $ra

player_loop_stopped_right:    # Pause Pac-Man movement on right wall, update ghosts
    lw $0, KEYBOARD_ADDR
    sw $s6, 4860($t0)
    sw $s6, 4864($t0)
    sw $s6, 5372($t0)
    sw $s6, 5884($t0)
    sw $s6, 5888($t0)
    addi $k0, $0, 5               #prende o pac man na parede e move todos fantasmas
    jal update_ghost1_ai
ghost1_return_stopped_right:
    jal update_ghost2_ai
ghost2_return_stopped_right:
    jal update_ghost3_ai
ghost3_return_stopped_right:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $t3, 4860($t0)  # Check for collision at Pac-Man's center
    beq $t3, $t8, game_over_sequence
    beq $t3, $t9, game_over_sequence  # Collision with ghost
    beq $t3, $s3, game_over_sequence
    jal general_delay         # Unified delay call
    jal render_clear_player_right
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    lw $t7, KEYBOARD_ADDR                         # Loop until direction change
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    j player_loop_stopped_right


render_clear_player_right:    # Clear Pac-Man facing right
    sw $s4, 4860($t0)
    sw $s4, 4864($t0)
    sw $s4, 5372($t0)
    sw $s4, 5884($t0)
    sw $s4, 5888($t0)
    addi $s0, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $ra

render_player_left:           # Render Pac-Man facing left
    sw $s6, 4860($t0)
    sw $s6, 4864($t0)
    sw $s6, 5376($t0)
    sw $s6, 5884($t0)
    sw $s6, 5888($t0)
    addi $s0, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $ra

player_loop_stopped_left:
    lw $0, KEYBOARD_ADDR
    sw $s6, 4860($t0)
    sw $s6, 4864($t0)
    sw $s6, 5376($t0)
    sw $s6, 5884($t0)
    sw $s6, 5888($t0)                     #recebe valor do teclado
    addi $k0, $0, 6
    jal update_ghost1_ai
ghost1_return_stopped_left:   # Return point for Ghost 1 when player is stopped left
    jal update_ghost2_ai
ghost2_return_stopped_left:
    jal update_ghost3_ai
ghost3_return_stopped_left:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $t3, 4860($t0)  # Check for collision at Pac-Man's center
    beq $t3, $t8, game_over_sequence
    beq $t3, $t9, game_over_sequence
    beq $t3, $s3, game_over_sequence
    jal general_delay         # Unified delay call
    jal render_clear_player_left
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    lw $t7, KEYBOARD_ADDR
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    j player_loop_stopped_left
#código para outras direcoes

render_clear_player_left:
    sw $s4, 4860($t0)
    sw $s4, 4864($t0)
    sw $s4, 5376($t0)
    sw $s4, 5884($t0)
    sw $s4, 5888($t0)
    addi $s0, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $ra

render_player_up:             # Render Pac-Man facing up
    sw $s6, 4860($t0)
    sw $s6, 4868($t0)
    sw $s6, 5372($t0)
    sw $s6, 5376($t0)
    sw $s6, 5380($t0)
    addi $s0, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $ra

render_clear_player_up:       # Clear Pac-Man facing up
    sw $s4, 4860($t0)
    sw $s4, 4868($t0)
    sw $s4, 5372($t0)
    sw $s4, 5376($t0)
    sw $s4, 5380($t0)
    addi $s0, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $ra


player_loop_stopped_up:
    lw $0, KEYBOARD_ADDR
    sw $s6, 4860($t0)
    sw $s6, 4868($t0)
    sw $s6, 5372($t0)
    sw $s6, 5376($t0)
    sw $s6, 5380($t0)                      #recebe valor do teclado
    addi $k0, $0, 7
    jal update_ghost1_ai
ghost1_return_stopped_up:     # Return point for Ghost 1 when player is stopped up
    jal update_ghost2_ai
ghost2_return_stopped_up:
    jal update_ghost3_ai
ghost3_return_stopped_up:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $t3, 4860($t0)  # Check for collision at Pac-Man's center
    beq $t3, $t8, game_over_sequence
    beq $t3, $t9, game_over_sequence
    beq $t3, $s3, game_over_sequence
    jal general_delay         # Unified delay call
    jal render_clear_player_up
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    lw $t7, KEYBOARD_ADDR
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    j player_loop_stopped_up


render_player_down:           # Render Pac-Man facing down
    sw $s6, 4860($t0)
    sw $s6, 4864($t0)
    sw $s6, 4868($t0)
    sw $s6, 5372($t0)
    sw $s6, 5380($t0)
    addi $s0, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $ra


render_clear_player_down:     # Clear Pac-Man facing down
    sw $s4, 4860($t0)
    sw $s4, 4864($t0)
    sw $s4, 4868($t0)
    sw $s4, 5372($t0)
    sw $s4, 5380($t0)
    addi $s0, $0, 10000       # Reduced delay - ghosts were moving faster
    jr $ra

player_loop_stopped_down:
    lw $0, KEYBOARD_ADDR
    sw $s6, 4860($t0)
    sw $s6, 4864($t0)
    sw $s6, 4868($t0)
    sw $s6, 5372($t0)
    sw $s6, 5380($t0)
    addi $k0, $0, 8
    jal update_ghost1_ai
ghost1_return_stopped_down:   # Return point for Ghost 1 when player is stopped down
    jal update_ghost2_ai
ghost2_return_stopped_down:
    jal update_ghost3_ai
ghost3_return_stopped_down:
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $t3, 4860($t0)  # Check for collision at Pac-Man's center
    beq $t3, $t8, game_over_sequence
    beq $t3, $t9, game_over_sequence
    beq $t3, $s3, game_over_sequence
    jal general_delay         # Unified delay call
    jal render_clear_player_down
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    lw $t7, KEYBOARD_ADDR
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    j player_loop_stopped_down


input_handle_left:
    sw $0, KEYBOARD_ADDR
    jal render_clear_player_left
    j player_loop_moving_left

player_loop_moving_left:
    lw $t7, KEYBOARD_ADDR
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    lw $t3, 4856($t0)  # Check left pixels for wall
    lw $t4, 5368($t0)  # Check left pixels for wall
    lw $t5, 5880($t0)  # Check left pixels for wall
    beq $t3, $s5, player_loop_stopped_left
    beq $t4, $s5, player_loop_stopped_left
    beq $t5, $s5, player_loop_stopped_left
    beq $t4, $s7, player_score_point_left     # Check for point collection ($s7 color)
    jal player_continue_move_left
player_score_point_left:
    addi $a3, $a3, 200  # Award 200 points per pellet
    beq $a3, 1000, game_advance_level  # Advance level at 1000 points (consistent threshold)
player_continue_move_left:
    addi $t0, $t0, -4
    addi $k0, $0, 1
    jal update_ghost1_ai
ghost1_return_moving_left:
    jal update_ghost2_ai
ghost2_return_moving_left:
    jal update_ghost3_ai
ghost3_return_moving_left:
    jal render_player_left
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $t3, 4860($t0)  # Check for collision at Pac-Man's center
    beq $t3, $t8, game_over_sequence
    beq $t3, $t9, game_over_sequence
    beq $t3, $s3, game_over_sequence
    jal general_delay         # Unified delay call
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
    lw $t7, KEYBOARD_ADDR
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    lw $t3, 4872($t0)  # Check right pixels for wall
    lw $t4, 5384($t0)  # Check right pixels for wall
    lw $t5, 5896($t0)  # Check right pixels for wall
    beq $t3, $s5, player_loop_stopped_right
    beq $t4, $s5, player_loop_stopped_right
    beq $t5, $s5, player_loop_stopped_right
    beq $t4, $s7, player_score_point_right     # Check for point collection ($s7 color)
    jal player_continue_move_right
player_score_point_right:
    addi $a3, $a3, 200  # Award 200 points per pellet
    beq $a3, 1000, game_advance_level  # Advance level at 1000 points (fixed inconsistency)
player_continue_move_right:
    addi $t0, $t0, 4
    addi $k0, $0, 2
    jal update_ghost1_ai
ghost1_return_moving_right:   # Return point for Ghost 1 when player is moving right
    jal update_ghost2_ai
ghost2_return_moving_right:
    jal update_ghost3_ai
ghost3_return_moving_right:
    jal render_player_right
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $t3, 4860($t0)  # Check for collision at Pac-Man's center
    beq $t3, $t8, game_over_sequence
    beq $t3, $t9, game_over_sequence
    beq $t3, $s3, game_over_sequence
    jal general_delay         # Unified delay call
    jal render_clear_player_right
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    j player_loop_moving_right

game_over_sequence:  # Trigger game over
    clearScreen()
    gameover()

    li $v0, 10 # Exit program
    syscall

game_advance_level:
    addi $a3, $0, 0     # Reset score to 0 on level up (consider accumulating if desired)
    lui $t0, 0x1001		# Reset player position
    lui $t2, 0x1001		# Reset ghost 1 position
    lui $t1, 0x1001		# Reset ghost 2 position
    lui $s2, 0x1001		# Reset ghost 3 position
    addi $s1, $s1, 1
    beq $s1, 1, load_map_2    # Load second level
    beq $s1, 2, load_map_1    # Load third level
    beq $s1, 3, game_win_screen       # All levels completed
load_map_2:
    clearScreen()
    drawn_map2()
    jr $ra
load_map_1:
    clearScreen()
    drawn_map1()
    jr $ra
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
    lw $t7, KEYBOARD_ADDR
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    lw $t3, 4348($t0)  # Check up pixels for wall
    lw $t4, 4352($t0)  # Check up pixels for wall
    lw $t5, 4356($t0)  # Check up pixels for wall
    beq $t3, $s5, player_loop_stopped_up
    beq $t4, $s5, player_loop_stopped_up
    beq $t5, $s5, player_loop_stopped_up
    beq $t4, $s7, player_score_point_up     # Check for point collection ($s7 color)
    jal player_continue_move_up
player_score_point_up:
    addi $a3, $a3, 200  # Award 200 points per pellet
    beq $a3, 1000, game_advance_level  # Advance level at 1000 points
player_continue_move_up:
    addi $t0, $t0, -512
    addi $k0, $0, 3
    jal update_ghost1_ai
ghost1_return_moving_up:
    jal update_ghost2_ai
ghost2_return_moving_up:
    jal update_ghost3_ai
ghost3_return_moving_up:
    jal render_player_up
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $t3, 4860($t0)  # Check for collision at Pac-Man's center
    beq $t3, $t8, game_over_sequence
    beq $t3, $t9, game_over_sequence
    beq $t3, $s3, game_over_sequence
    jal general_delay         # Unified delay call
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
    lw $t7, KEYBOARD_ADDR
    beq $t7, KEY_A, input_handle_left
    beq $t7, KEY_D, input_handle_right
    beq $t7, KEY_W, input_handle_up
    beq $t7, KEY_S, input_handle_down
    lw $t3, 6396($t0)  # Check down pixels for wall
    lw $t4, 6400($t0)  # Check down pixels for wall
    lw $t5, 6404($t0)  # Check down pixels for wall
    beq $t3, $s5, player_loop_stopped_down
    beq $t4, $s5, player_loop_stopped_down
    beq $t5, $s5, player_loop_stopped_down
    beq $t4, $s7, player_score_point_down     # Check for point collection ($s7 color)
    jal player_continue_move_down
player_score_point_down:
    addi $a3, $a3, 200  # Award 200 points per pellet
    beq $a3, 1000, game_advance_level  # Advance level at 1000 points
player_continue_move_down:
    addi $t0, $t0, 512
    addi $k0, $0, 4
    jal update_ghost1_ai
ghost1_return_moving_down:
    jal update_ghost2_ai
ghost2_return_moving_down:
    jal update_ghost3_ai
ghost3_return_moving_down:
    jal render_player_down
    jal render_ghost_1
    jal render_ghost_2
    jal render_ghost_3
    lw $t3, 4860($t0)  # Check for collision at Pac-Man's center
    beq $t3, $t8, game_over_sequence
    beq $t3, $t9, game_over_sequence
    beq $t3, $s3, game_over_sequence
    jal general_delay         # Unified delay call
    jal render_clear_player_down
    jal render_clear_ghost_1
    jal render_clear_ghost_2
    jal render_clear_ghost_3
    j player_loop_moving_down

general_delay:
    addi $s0, $s0, -1
    nop
    bne $s0, $0, general_delay
    jr $ra
    
.text

# EXPLANATION OF CHANGES:
# 1. Collision Detection: Checks two corner pixels per direction to prevent clipping into walls.
# 2. Speed Control: Adjust movement increments (e.g., 'addi $t2, $t2, 4' for horizontal) to change speed.

update_ghost1_ai:
    # Check up corners for wall
    lw $t3, 1036($t2)       
    beq $t3, $s5, ghost1_detect_up_wall
    lw $t3, 1044($t2)       
ghost1_detect_up_wall:
    # $t3 holds wall color if any corner hit

    # Check left corners for wall
    lw $t4, 1544($t2)       
    beq $t4, $s5, ghost1_detect_left_wall
    lw $t4, 2568($t2)       
ghost1_detect_left_wall:

    # Check right corners for wall
    lw $t5, 1560($t2)       
    beq $t5, $s5, ghost1_detect_right_wall
    lw $t5, 2584($t2)       
ghost1_detect_right_wall:

    # Check down corners for wall
    lw $t6, 3084($t2)       
    beq $t6, $s5, ghost1_detect_down_wall
    lw $t6, 3092($t2)       
ghost1_detect_down_wall:

ghost1_check_walls:          # Evaluate all possible wall collisions
    beq $t3, $s5, ghost1_check_wall_down
    beq $t4, $s5, ghost1_check_wall_right
    beq $t5, $s5, ghost1_check_wall_left
    beq $t6, $s5, ghost1_check_wall_up
    jal ghost1_decide_all_dirs
ghost1_ai_return:
    beq $k0, 1, ghost1_return_moving_left
    beq $k0, 2, ghost1_return_moving_right
    beq $k0, 3, ghost1_return_moving_up
    beq $k0, 4, ghost1_return_moving_down
    beq $k0, 5, ghost1_return_stopped_right
    beq $k0, 6, ghost1_return_stopped_left
    beq $k0, 7, ghost1_return_stopped_up
    beq $k0, 8, ghost1_return_stopped_down
    jal ghost1_return_moving_right
ghost1_check_wall_down:
    beq $t4, $s5, ghost1_check_wall_down_right
ghost1_check_wall_down_cont:
    beq $t4, $s5, ghost1_decide_down_right
    beq $t5, $s5, ghost1_decide_down_left
    beq $t6, $s5, ghost1_decide_left_right
    jal ghost1_decide_down_left_right
ghost1_check_wall_down_right:
    beq $t5, $s5, ghost1_move_down
    beq $t6, $s5, ghost1_move_left
    jal ghost1_check_wall_down_cont
ghost1_check_wall_right:
    beq $t5, $s5, ghost1_check_wall_right_left
ghost1_check_wall_right_cont:
    beq $t3, $s5, ghost1_decide_down_right
    beq $t6, $s5, ghost1_decide_up_right
    beq $t5, $s5, ghost1_decide_up_down
    jal ghost1_decide_up_right_down
ghost1_check_wall_right_left:
    beq $t6, $s5, ghost1_move_up
    jal ghost1_check_wall_right_cont

ghost1_check_wall_left:
    beq $t3, $s5, ghost1_check_wall_left_down
ghost1_check_wall_left_cont:
    beq $t6, $s5, ghost1_decide_up_left
    beq $t3, $s5, ghost1_decide_down_left
    beq $t4, $s5, ghost1_decide_up_down
    jal ghost1_decide_up_left_down
ghost1_check_wall_left_down:
    beq $t5, $s5, ghost1_move_down
    beq $t6, $s5, ghost1_move_right
ghost1_check_wall_up:
    beq $t3, $s5, ghost1_decide_left_right
    beq $t4, $s5, ghost1_decide_up_right
    beq $t5, $s5, ghost1_decide_up_left
    jal ghost1_decide_up_left_right
ghost1_decide_down_right:     # Random decision for down-right path
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $0, 50
    bgt $a0, $fp, ghost1_move_down
    jal ghost1_move_right
    
    ghost1_move_right:
    addi $fp, $zero, 3
    # Horizontal movement (adjust for speed)
    addi $t2, $t2, 4
    jal ghost1_ai_return
    
    ghost1_move_down:
    addi $fp, $zero, 3
    # Vertical movement (adjust for speed)
    addi $t2, $t2, 512
    jal ghost1_ai_return
    
ghost1_decide_up_down:        # 2-way hallway decision
    beq $fp, 2, ghost1_move_up
    beq $fp, 3, ghost1_move_down 
    jal ghost1_move_down
    
ghost1_move_up:
    addi $fp, $zero, 2
    # Vertical up movement
    addi $t2, $t2, -512
    jal ghost1_ai_return


ghost1_decide_left_right:
    beq $fp, 2, ghost1_move_left
    beq $fp, 3, ghost1_move_right
    jal ghost1_move_right
    
ghost1_move_left:
    addi $fp, $0, 2
    # Horizontal left movement
    addi $t2, $t2, -4
    jal ghost1_ai_return
    
ghost1_decide_down_left:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost1_move_down
    jal ghost1_move_left
    
ghost1_decide_up_left:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost1_move_up
    jal ghost1_move_left
    
ghost1_decide_up_right:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost1_move_up
    jal ghost1_move_right
    
ghost1_decide_down_left_right: # 3-way T-junction decision
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 60
    bgt $a0, $fp, ghost1_move_down
    bgt $a0, $a1, ghost1_move_left
    jal ghost1_move_right
ghost1_decide_up_right_down:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 60
    bgt $a0, $fp, ghost1_move_down
    bgt $a0, $a1, ghost1_move_up
    jal ghost1_move_right

ghost1_decide_all_dirs:       # 4-way intersection decision
    addi $fp, $0, 0
    addi $a1, $zero, 100 
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 50
    addi $a2, $a2, 80
    bgt $a0, $a2, ghost1_move_right
    bgt $a0, $a1, ghost1_move_up
    bgt $a0, $fp, ghost1_move_down
    jal ghost1_move_left
    
ghost1_decide_up_left_down:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 50
    bgt $a0, $fp, ghost1_move_down
    bgt $a0, $a1, ghost1_move_up
    jal ghost1_move_left   
ghost1_decide_up_left_right:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 50
    bgt $a0, $a1, ghost1_move_up
    bgt $a0, $fp, ghost1_move_right
    jal ghost1_move_left
    
######################################## Ghost 2 
update_ghost2_ai:                             
    # Check up corners for wall
    lw $t3, 28684($t1)
    beq $t3, $s5, ghost2_detect_up_wall
    lw $t3, 28692($t1)
ghost2_detect_up_wall:

    # Check left corners for wall
    lw $t4, 29192($t1)
    beq $t4, $s5, ghost2_detect_left_wall
    lw $t4, 30216($t1)
ghost2_detect_left_wall:

    # Check right corners for wall
    lw $t5, 29208($t1)
    beq $t5, $s5, ghost2_detect_right_wall
    lw $t5, 30232($t1)
ghost2_detect_right_wall:

    # Check down corners for wall
    lw $t6, 30732($t1)
    beq $t6, $s5, ghost2_detect_down_wall
    lw $t6, 30740($t1)
ghost2_detect_down_wall:

ghost2_check_walls:           # Evaluate all possible wall collisions
    beq $t3, $s5, ghost2_check_wall_down
    beq $t4, $s5, ghost2_check_wall_right
    beq $t5, $s5, ghost2_check_wall_left
    beq $t6, $s5, ghost2_check_wall_up
    jal ghost2_decide_all_dirs
ghost2_ai_return:
    beq $k0, 1, ghost2_return_moving_left
    beq $k0, 2, ghost2_return_moving_right
    beq $k0, 3, ghost2_return_moving_up
    beq $k0, 4, ghost2_return_moving_down
    beq $k0, 5, ghost2_return_stopped_right
    beq $k0, 6, ghost2_return_stopped_left
    beq $k0, 7, ghost2_return_stopped_up
    beq $k0, 8, ghost2_return_stopped_down
    jal ghost2_return_moving_right
ghost2_check_wall_down:
    beq $t4, $s5, ghost2_check_wall_down_right
ghost2_check_wall_down_cont:
    beq $t4, $s5, ghost2_decide_down_right
    beq $t5, $s5, ghost2_decide_down_left
    beq $t6, $s5, ghost2_decide_left_right
    jal ghost2_decide_down_left_right
ghost2_check_wall_down_right:
    beq $t5, $s5, ghost2_move_down
    beq $t6, $s5, ghost2_move_left
    jal ghost2_check_wall_down_cont
ghost2_check_wall_right:
    beq $t5, $s5, ghost2_check_wall_right_left
ghost2_check_wall_right_cont:
    beq $t3, $s5, ghost2_decide_down_right
    beq $t6, $s5, ghost2_decide_up_right
    beq $t5, $s5, ghost2_decide_up_down
    jal ghost2_decide_up_right_down
ghost2_check_wall_right_left:
    beq $t6, $s5, ghost2_move_up

    jal ghost2_check_wall_right_cont

ghost2_check_wall_left:
    beq $t3, $s5, ghost2_check_wall_left_down
ghost2_check_wall_left_cont:
    beq $t6, $s5, ghost2_decide_up_left
    beq $t3, $s5, ghost2_decide_down_left
    beq $t4, $s5, ghost2_decide_up_down
    jal ghost2_decide_up_left_down
ghost2_check_wall_left_down:
    beq $t5, $s5, ghost2_move_down
    beq $t6, $s5, ghost2_move_right
ghost2_check_wall_up:
    beq $t3, $s5, ghost2_decide_left_right
    beq $t4, $s5, ghost2_decide_up_right
    beq $t5, $s5, ghost2_decide_up_left
    jal ghost2_decide_up_left_right

ghost2_decide_down_right:     # Random decision for down-right path
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $0, 50
    bgt $a0, $fp, ghost2_move_down
    jal ghost2_move_right
    
ghost2_move_right:
    addi $k1, $zero, 3
    # Horizontal movement
    addi $t1, $t1, 4
    jal ghost2_ai_return
    
ghost2_move_down:
    addi $k1, $zero, 3
    # Vertical movement
    addi $t1, $t1, 512
    jal ghost2_ai_return
    
ghost2_decide_up_down:        # 2-way hallway decision
    beq $k1, 2, ghost2_move_up
    beq $k1, 3, ghost2_move_down
    jal ghost2_move_down
    
ghost2_move_up:
    addi $k1, $zero, 2
    # Vertical up movement
    addi $t1, $t1, -512
    jal ghost2_ai_return

ghost2_decide_left_right:
    beq $k1, 2, ghost2_move_left
    beq $k1, 3, ghost2_move_right
    jal ghost2_move_right
    
ghost2_move_left:
    addi $k1, $0, 2
    # Horizontal left movement
    addi $t1, $t1, -4
    jal ghost2_ai_return
    
ghost2_decide_down_left:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost2_move_down
    jal ghost2_move_left
    
ghost2_decide_up_left:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost2_move_up
    jal ghost2_move_left
   
ghost2_decide_up_right:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost2_move_up
    jal ghost2_move_right
    
ghost2_decide_down_left_right: # 3-way T-junction decision
    addi $fp, $0, 0
    addi $a1, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 35
    addi $a1, $a1, 65
    bgt $a0, $fp, ghost2_move_down
    bgt $a0, $a1, ghost2_move_left
    jal ghost2_move_right

ghost2_decide_up_right_down:
    addi $fp, $0, 0
    addi $a1, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 35
    addi $a1, $a1, 65
    bgt $a0, $a1, ghost2_move_right
    bgt $a0, $fp, ghost2_move_up
    jal ghost2_move_down

ghost2_decide_all_dirs:       # 4-way intersection decision
    addi $fp, $0, 0
    addi $a1, $0, 0
    addi $a2, $0, 0
    addi $a1, $zero, 100 
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 50
    addi $a2, $a2, 80
    bgt $a0, $a2, ghost2_move_right
    bgt $a0, $a1, ghost2_move_up
    bgt $a0, $fp, ghost2_move_down
    jal ghost2_move_left
    
ghost2_decide_up_left_down:
    addi $fp, $0, 0
    addi $a1, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 35
    addi $a1, $a1, 65
    bgt $a0, $a1, ghost2_move_up
    bgt $a0, $fp, ghost2_move_down
    jal ghost2_move_left   
ghost2_decide_up_left_right:
    addi $fp, $0, 0
    addi $a1, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $a1, $a1, 35
    addi $fp, $fp, 65
    bgt $a0, $a1, ghost2_move_up
    bgt $a0, $fp, ghost2_move_right
    jal ghost2_move_left
    
    ########################### Ghost3
    
update_ghost3_ai:
    # Check up corners for wall
    lw $t3, 29164($s2)
    beq $t3, $s5, ghost3_detect_up_wall
    lw $t3, 29172($s2)
ghost3_detect_up_wall:

    # Check left corners for wall
    lw $t4, 29672($s2)
    beq $t4, $s5, ghost3_detect_left_wall
    lw $t4, 30696($s2)
ghost3_detect_left_wall:

    # Check right corners for wall
    lw $t5, 29688($s2)
    beq $t5, $s5, ghost3_detect_right_wall
    lw $t5, 30712($s2)
ghost3_detect_right_wall:

    # Check down corners for wall
    lw $t6, 31212($s2)
    beq $t6, $s5, ghost3_detect_down_wall
    lw $t6, 31220($s2)
ghost3_detect_down_wall:

ghost3_check_walls:           # Evaluate all possible wall collisions
    beq $t3, $s5, ghost3_check_wall_down
    beq $t4, $s5, ghost3_check_wall_right
    beq $t5, $s5, ghost3_check_wall_left
    beq $t6, $s5, ghost3_check_wall_up
    jal ghost3_decide_all_dirs
ghost3_ai_return:
    beq $k0, 1, ghost3_return_moving_left
    beq $k0, 2, ghost3_return_moving_right
    beq $k0, 3, ghost3_return_moving_up
    beq $k0, 4, ghost3_return_moving_down
    beq $k0, 5, ghost3_return_stopped_right
    beq $k0, 6, ghost3_return_stopped_left
    beq $k0, 7, ghost3_return_stopped_up
    beq $k0, 8, ghost3_return_stopped_down
    jal ghost3_return_moving_right
ghost3_check_wall_down:
    beq $t4, $s5, ghost3_check_wall_down_right
ghost3_check_wall_down_cont:
    beq $t4, $s5, ghost3_decide_down_right
    beq $t5, $s5, ghost3_decide_down_left
    beq $t6, $s5, ghost3_decide_left_right
    jal ghost3_decide_down_left_right
ghost3_check_wall_down_right:
    beq $t5, $s5, ghost3_move_down
    beq $t6, $s5, ghost3_move_left
    jal ghost3_check_wall_down_cont
ghost3_check_wall_right:
    beq $t5, $s5, ghost3_check_wall_right_left
ghost3_check_wall_right_cont:
    beq $t3, $s5, ghost3_decide_down_right
    beq $t6, $s5, ghost3_decide_up_right
    beq $t5, $s5, ghost3_decide_up_down
    jal ghost3_decide_up_right_down
ghost3_check_wall_right_left:
    beq $t6, $s5, ghost3_move_up

    jal ghost3_check_wall_right_cont
ghost3_check_wall_left:
    beq $t3, $s5, ghost3_check_wall_left_down
ghost3_check_wall_left_cont:
    beq $t6, $s5, ghost3_decide_up_left
    beq $t3, $s5, ghost3_decide_down_left
    beq $t4, $s5, ghost3_decide_up_down
    jal ghost3_decide_up_left_down
ghost3_check_wall_left_down:
    beq $t5, $s5, ghost3_move_down
    beq $t6, $s5, ghost3_move_right
ghost3_check_wall_up:
    beq $t3, $s5, ghost3_decide_left_right
    beq $t4, $s5, ghost3_decide_up_right
    beq $t5, $s5, ghost3_decide_up_left
    jal ghost3_decide_up_left_right
ghost3_decide_down_right:     # Random decision for down-right path
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $0, 50
    bgt $a0, $fp, ghost3_move_down
    jal ghost3_move_right
    
ghost3_move_right:
    addi $gp, $zero, 3
    # Horizontal movement
    addi $s2, $s2, 4
    jal ghost3_ai_return
    
ghost3_move_down:
    addi $gp, $zero, 3
    # Vertical movement
    addi $s2, $s2, 512
    jal ghost3_ai_return
    
ghost3_decide_up_down:        # 2-way hallway decision
    beq $gp, 2, ghost3_move_up
    beq $gp, 3, ghost3_move_down
    jal ghost3_move_down
    
ghost3_move_up:
    addi $gp, $zero, 2
    # Vertical up movement
    addi $s2, $s2, -512
    jal ghost3_ai_return

ghost3_decide_left_right:
    beq $gp, 2, ghost3_move_left
    beq $gp, 3, ghost3_move_right
    jal ghost3_move_right
    
ghost3_move_left:
    addi $gp, $0, 2
    # Horizontal left movement
    addi $s2, $s2, -4
    jal ghost3_ai_return
    
ghost3_decide_down_left:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost3_move_down
    jal ghost3_move_left
    
ghost3_decide_up_left:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost3_move_up
    jal ghost3_move_left
    
ghost3_decide_up_right:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 50
    bgt $a0, $fp, ghost3_move_up
    jal ghost3_move_right
    
ghost3_decide_down_left_right: # 3-way T-junction decision
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $fp, 60
    bgt $a0, $a1, ghost3_move_down
    bgt $a0, $fp, ghost3_move_left
    jal ghost3_move_right
ghost3_decide_up_right_down:
    addi $fp, $0, 0
   addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 60
    bgt $a0, $a1, ghost3_move_down
    bgt $a0, $fp, ghost3_move_up
    jal ghost3_move_right

ghost3_decide_all_dirs:       # 4-way intersection decision
    addi $fp, $0, 0
    addi $a1, $zero, 100 
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 50
    addi $a2, $a2, 80
    bgt $a0, $a2, ghost3_move_right
    bgt $a0, $a1, ghost3_move_up
    bgt $a0, $fp, ghost3_move_down
    jal ghost3_move_left
    
ghost3_decide_up_left_down:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42 
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $fp, $fp, 30
    addi $a1, $a1, 50
    bgt $a0, $fp, ghost3_move_down
    bgt $a0, $a1, ghost3_move_up
    jal ghost3_move_left   
ghost3_decide_up_left_right:
    addi $fp, $0, 0
    addi $a1, $zero, 100
    addi $v0, $zero, 42
    syscall
    addi $v0, $zero, 1
    syscall
    move $a0, $a0
    addi $a1, $a1, 35
    addi $fp, $fp, 65
    bgt $a0, $a1, ghost3_move_up
    bgt $a0, $fp, ghost3_move_right
    jal ghost3_move_left
    
render_ghost_1:               # Render and clear ghost 1
    sw $t8, 1548($t2)
    sw $t8, 1552($t2)
    sw $t8, 1556($t2)
    sw $t8, 2060($t2)
    sw $t8, 2068($t2)
    sw $t8, 2572($t2)
    sw $t8, 2576($t2)
    sw $t8, 2580($t2)
    addi $s0, $0, 60000      # Set delay to match Pac-Man speed (this defines ghost speed also for some reason)
    jr $ra

render_clear_ghost_1:
    sw $s4, 1548($t2)
    sw $s4, 1552($t2)
    sw $s4, 1556($t2)
    sw $s4, 2060($t2)
    sw $s4, 2068($t2)
    sw $s4, 2572($t2)
    sw $s4, 2576($t2)
    sw $s4, 2580($t2)
    jr $ra

render_ghost_2:
    sw $s3, 29196($t1)
    sw $s3, 29200($t1)
    sw $s3, 29204($t1)
    sw $s3, 29708($t1)
    sw $s3, 29716($t1)
    sw $s3, 30220($t1)
    sw $s3, 30224($t1)
    sw $s3, 30228($t1)
    jr $ra

render_clear_ghost_2:
    sw $s4, 29196($t1)
    sw $s4, 29200($t1)
    sw $s4, 29204($t1)
    sw $s4, 29708($t1)
    sw $s4, 29716($t1)
    sw $s4, 30220($t1)
    sw $s4, 30224($t1)
    sw $s4, 30228($t1)
    jr $ra

render_ghost_3:
    sw $t9, 29676($s2)
    sw $t9, 29680($s2)
    sw $t9, 29684($s2)
    sw $t9, 30188($s2)
    sw $t9, 30196($s2)
    sw $t9, 30700($s2)
    sw $t9, 30704($s2)
    sw $t9, 30708($s2)
    jr $ra

render_clear_ghost_3:
    sw $s4, 29676($s2)
    sw $s4, 29680($s2)
    sw $s4, 29684($s2)
    sw $s4, 30188($s2)
    sw $s4, 30196($s2)
    sw $s4, 30700($s2)
    sw $s4, 30704($s2)
    sw $s4, 30708($s2)
    jr $ra
.end_macro