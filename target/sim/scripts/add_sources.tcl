# This script was generated automatically by bender.
set ROOT "/home/mc2101-pynq/Desktop/mc2101"
add_files -norecurse -fileset [current_fileset] [list \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_core.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_controller.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_adder_subtractor.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_adder.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_barrel_shifter.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_comparator.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_counter.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_datapath.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_decoder.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_full_adder.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_half_adder.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_isseu.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_llu.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_multiplexer.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_one_bit_register.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_opt_adder.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_register_file.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_register.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_sulu.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_booth_multiplier/aftab_booth_multiplier_controller.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_booth_multiplier/aftab_booth_multiplier_datapath.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_booth_multiplier/aftab_booth_multiplier.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_su_divider/aftab_divider_controller.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_su_divider/aftab_divider_datapath.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_su_divider/aftab_divider.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_su_divider/aftab_su_divider.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_su_divider/aftab_tcl.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_aau.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_aau/aftab_shift_register.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_csr_address_ctrl.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_csr_address_logic.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_csr_addressing_decoder.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_csr_counter.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_csr_isl.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_csr_registers.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_iccd.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_isagu.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_csr/aftab_register_bank.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_daru/aftab_daru_controller.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_daru/aftab_daru_datapath.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_daru/aftab_daru_error_detector.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_daru/aftab_daru.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_dawu/aftab_dawu_controller.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_dawu/aftab_dawu_datapath.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_dawu/aftab_dawu_error_detector.vhd \
    $ROOT/.bender/git/checkouts/aftab-ac8298492ac7b662/rtl/aftab_datapath/aftab_dawu/aftab_dawu.vhd \
]
add_files -norecurse -fileset [current_fileset] [list \
    $ROOT/hw/gpio/gpio_bus_wrap.vhd \
    $ROOT/hw/gpio/gpio_controller.vhd \
    $ROOT/hw/uart/fifo.vhd \
    $ROOT/hw/uart/uart_bus_wrap.vhd \
    $ROOT/hw/uart/uart_controller.vhd \
    $ROOT/hw/uart/uart_interrupt.vhd \
    $ROOT/hw/uart/uart_rx_core.vhd \
    $ROOT/hw/uart/uart_tx_core.vhd \
    $ROOT/hw/uart/uart.vhd \
    $ROOT/hw/ssram/ssram_controller.vhd \
    $ROOT/hw/ssram/ssram_bus_wrap.vhd \
    $ROOT/hw/core_bus_wrap.vhd \
    $ROOT/hw/mc2101.vhd \
    $ROOT/hw/include/Constants.vhd \
]
add_files -norecurse -fileset [current_fileset] [list \
    $ROOT/target/sim/src/tb_mc2101.vhd \
    $ROOT/target/sim/src/tb_uart_fifo.vhd \
    $ROOT/target/sim/src/tb_uart_interrupt.vhd \
    $ROOT/target/sim/src/tb_uart_tx_core.vhd \
    $ROOT/target/sim/src/tb_uart_rx_core.vhd \
    $ROOT/target/sim/src/tb_uart_periph.vhd \
    $ROOT/target/sim/src/tb_gpio_pad.vhd \
    $ROOT/target/sim/src/tb_gpios_pads.vhd \
    $ROOT/target/sim/src/mc2101_wrapper.vhd \
    $ROOT/target/sim/src/gpio_pad.vhd \
    $ROOT/target/sim/src/gpio_pads_if.vhd \
    $ROOT/target/sim/src/gpio_core.vhd \
    $ROOT/target/sim/src/gpio.vhd \
    $ROOT/target/sim/src/blk_mem_gen_0.vhd \
]

set_property include_dirs [list \
    $ROOT/hw/include \
] [current_fileset]

set_property include_dirs [list \
    $ROOT/hw/include \
] [current_fileset -simset]

set_property verilog_define [list \
    TARGET_SIMULATION \
] [current_fileset]

set_property verilog_define [list \
    TARGET_SIMULATION \
] [current_fileset -simset]

