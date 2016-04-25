; load rle data to vram!
  lda #<data  ; load the source address into a pointer in zero page
  sta chr_ram
  lda #>data
  sta chr_ram+1
  
  
  ldy #0       ; starting index into the first page
  sty PPU_CTRL2  ; turn off rendering just in case
  sty PPU_VRAM_ADDR2  ; load the destination address into the PPU
  sty PPU_VRAM_ADDR2

  
-: lda PPU_STATUS
  lda (chr_ram),y
  cmp #$ff
  beq rle_done
  cmp #$fe
  beq direct_copy
  
  tax
  
  jsr inc_chr_ram
  lda (chr_ram),y
@rle_loop_c:
  sta PPU_VRAM_IO
  dex
  bne @rle_loop_c
  
  jsr inc_chr_ram
  jmp -
  
direct_copy:
  jsr inc_chr_ram
  lda (chr_ram),y
  tax
  jsr inc_chr_ram
  
@rle_loop_d:
  lda (chr_ram),y
  sta PPU_VRAM_IO
  jsr inc_chr_ram
  dex
  bne @rle_loop_d
  
  jmp -
  
rle_done: jmp rle_complete

inc_chr_ram:
  inc chr_ram
  ldy chr_ram
  cpy #$00
  bne @no_high
  
  inc chr_ram+1
  ldy #$00
  rts
  
@no_high:
  ldy #$00
  rts
  
rle_complete: