.text
.globl	main
.type	main, @function

main:

    lui  x1,0x100
    
    addi x2,x0,1
    sw   x2,0(x1)
    addi x2,x0,0
    lw   x2,0(x1)
    
    addi x3,x2,1
    sw   x3,0(x1)
    addi x3,x0,0
    lw   x3,0(x1)
    
    addi x4,x3,1
    sw   x4,0(x1)
    addi x4,x0,0
    lw   x4,0(x1)
    
    addi x5,x4,1
    sw   x5,0(x1)
    addi x5,x0,0
    lw   x5,0(x1)
    
    addi x6,x5,1
    sw   x6,0(x1)
    addi x6,x0,0
    lw   x6,0(x1)
    
    addi x7,x6,1
    sw   x7,0(x1)
    addi x7,x0,0
    lw   x7,0(x1)
    
    addi x8,x7,1
    sw   x8,0(x1)
    addi x8,x0,0
    lw   x8,0(x1)
    
    addi x9,x8,1
    sw   x9,0(x1)
    addi x9,x0,0
    lw   x9,0(x1)
    
    addi x10,x9,1
    sw   x10,0(x1)
    addi x10,x0,0
    lw   x10,0(x1)
    
    addi x11,x10,1
    sw   x11,0(x1)
    addi x11,x0,0
    lw   x11,0(x1)
    
    addi x12,x11,1
    sw   x12,0(x1)
    addi x12,x0,0
    lw   x12,0(x1)
    
    addi x13,x12,1
    sw   x13,0(x1)
    addi x13,x0,0
    lw   x13,0(x1)
    
    addi x14,x13,1
    sw   x14,0(x1)
    addi x14,x0,0
    lw   x14,0(x1)
    
    addi x15,x14,1
    sw   x15,0(x1)
    addi x15,x0,0
    lw   x15,0(x1)
    
    addi x16,x15,1
    sw   x16,0(x1)
    addi x16,x0,0
    lw   x16,0(x1)
    
    addi x17,x16,1
    sw   x17,0(x1)
    addi x17,x0,0
    lw   x17,0(x1)
    
    addi x18,x17,1
    sw   x18,0(x1)
    addi x18,x0,0
    lw   x18,0(x1)
    
    addi x19,x18,1
    sw   x19,0(x1)
    addi x19,x0,0
    lw   x19,0(x1)
    
    addi x20,x19,1
    sw   x20,0(x1)
    addi x20,x0,0
    lw   x20,0(x1)
    
    addi x21,x20,1
    sw   x21,0(x1)
    addi x21,x0,0
    lw   x21,0(x1)
    
    addi x22,x21,1
    sw   x22,0(x1)
    addi x22,x0,0
    lw   x22,0(x1)
    
    addi x23,x22,1
    sw   x23,0(x1)
    addi x23,x0,0
    lw   x23,0(x1)
    
    addi x24,x23,1
    sw   x24,0(x1)
    addi x24,x0,0
    lw   x24,0(x1)
    
    addi x25,x24,1
    sw   x25,0(x1)
    addi x25,x0,0
    lw   x25,0(x1)
    
    addi x26,x25,1
    sw   x26,0(x1)
    addi x26,x0,0
    lw   x26,0(x1)
    
    addi x27,x26,1
    sw   x27,0(x1)
    addi x27,x0,0
    lw   x27,0(x1)
    
    addi x28,x27,1
    sw   x28,0(x1)
    addi x28,x0,0
    lw   x28,0(x1)
    
    addi x29,x28,1
    sw   x29,0(x1)
    addi x29,x0,0
    lw   x29,0(x1)
    
    addi x30,x29,1
    sw   x30,0(x1)
    addi x30,x0,0
    lw   x30,0(x1)
    
    addi x31,x30,1
    sw   x31,0(x1)
    addi x31,x0,0
    lw   x31,0(x1)
    
    addi x31, x0, 0x012
    sb   x31,0(x1)
    addi x31,x0,0x010
    lb   x31,0(x1)
    sh   x31,0(x1)
    addi x31,x31,0
    lh   x31,0(x1)

stop: j stop
