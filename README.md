# Compilar todos os arquivos
- Settings > Assemble all files in directory

# Abrir Tools
- Keyboard and Display MMIO Simulator
- Bitmap display configurado com 
  - Unit width and height: 4
  - Display width and height: 512 x 256
  - Base address: 0x10010000 (static)

# ROdar
- Após abrir as tools e configurar o Bitmap Display
- Focar no MMIO Simulator Keyboard e digitar lá


clearScreen - Pinta a tela toda de preto para "limpar" a tela entre grande sprites

Cores definidas no código no main.asm, desenhadas manualmente pixel a pixel por endereço de memória


`68719411204` é um decimal especifico que é interpretado como uma pseudo-instrução que se expande em duas funcções reais diferentes pelo assembler:
`lw $t7, 68719411204($zero)` se expande para as duas instruções MIPS abaixo no código gerado final:
`lui $at, 0xFFFF      # Load 0xFFFF into the upper 16 bits of $at. $at is now 0xFFFF0000`
`lw  $t7, 4($at)      # Load word from address 0xFFFF0000 + 4, which is 0xFFFF0004`

`sw $0, 68719411204($zero)` se expande para as duas instruções MIPS abaixo no código gerado final:
`lui $at, 0xFFFF      # $at = 0xFFFF0000`
`sw  $0, 4($at)       # Store the value of $0 (which is 0) to address 0xFFFF0004`
Isso escreve no buffer do teclado (teoricamente read-only) o valor 0, que é interpretado como "nenhuma tecla pressionada", anterior a qualquer leitura do teclado.

`lw $0, 68719411204($zero)` lê uma palavra buffer do teclado, que é mapeado para o endereço 0xFFFF0004, e
guarda o valor do registrador $0, que é hardwired parar ser 0, então o valor é lido e imediatamente descartado (útil para limpar o buffer do teclado).


# Macros e .eqv
[Macros in MIPS Assembly Language](https://dpetersanderson.github.io/Help/MacrosHelp.html) são o equivalente ao #define em C, e foram utilizados para simplificar alguns valores fixos, como os valores ASCII das teclas WASD, ou endereços de memória MMIO. O eqv é similar, mas não é uma macro, e sim uma substituição direta de texto pelo assembler antes da montagem do código.
DOC Syscalls: https://asm-editor.specy.app/documentation/mips/syscall

# Macros vs JAL
Macros são expandidas inline no código, ou seja, o código da macro é inserido diretamente no local onde a macro é chamada. Isso pode levar a um aumento do tamanho do código se a macro for chamada muitas vezes, mas evita a sobrecarga de uma chamada de função. Macros não têm um contexto de pilha separado, então variáveis locais não são possíveis.

## Problemas atuais
- [x] Timing, velocidade de movimento dos fantasmas está muito rápida
- [ ] Não faz muito sentido como passar para a próxima fase (quantas bolinhas coletar?)
- [ ] MUITO código repetido, principalmente na AI dos fantasmas
- [x] Aparentemente algumas vezes na diagonal os inimigos não matam o jogador mesmo quando deveriam (colisão não detectada?)
- [ ] Atualmente o programa utiliza muitos registradores apenas para cores
- [ ] Remover uso de registradores reservados para o sistema como $k0, $k1 ,$gp, e $fp
 
## Registradores usados
- $t2: Base address do mapa