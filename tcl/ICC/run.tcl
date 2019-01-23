##cd tmp
##mkdir report
##mkdir results
##icc_shell | tee log1
##start_gui

##########Data Setup##########

file delete -force $my_mw_lib

# Create Milkyway Design Library
create_mw_lib $my_mw_lib -open -technology $tech_file \
	-mw_reference_library "$mw_path/sc/smic13g $mw_path/io/SP013W_V1p0_8MT"

# Load the netlist, constraints and controls.
import_designs $verilog_file \
	-format verilog \
	-top $top_design
current_design pad
# Load TLU+ files
set_tlu_plus_files \
	-max_tluplus $tlup_max \
	-min_tluplus $tlup_min \
	-tech2itf_map  $tlup_map

check_library
check_tlu_plus_files
list_libs

source $sdc_file

source $ctrl_file

save_mw_cel -as des_data_setup

##close_mw_lib

##open_mw_lib $my_mw_lib
##open_mw_cel des_data_setup
##set_tlu_plus_files -max_tluplus $tlup_max -min_tluplus $tlup_min -tech2itf_map $tlup_map
##source $sdc_file
##source $ctrl_file

##########Floorplan##########

gui_set_current_task -name {Design Planning}

# Initialize Floorplan

# Create corners and P/G pads and define all pad cell locations:
source -echo ../scripts/pad_cell_cons.tcl

create_floorplan -core_utilization 0.7 -left_io2core 30.0 -bottom_io2core 30.0 -right_io2core 30.0 -top_io2core 30.0 ;# from 20 to 30

insert_pad_filler -cell "PFILL50W PFILL5W PFILL20W PFILL2W PFILL10W PFILL1W PFILL01W PFILL001W" -overlap "PFILL001W"

derive_pg_connection -power_net VDD -ground_net VSS -create_ports top
derive_pg_connection -power_net VDD  -power_pin VDD  -ground_net VSS  -ground_pin VSS
derive_pg_connection -ground_net VDD -ground_net VSS -tie

create_pad_rings

save_mw_cel -as floorplan_init

#Build the power plan structure

set_fp_rail_constraints -add_layer  -layer METAL7 -direction horizontal -max_strap 14 -min_strap 2 -min_width 2 -max_width 4 -spacing 0.6
set_fp_rail_constraints -add_layer  -layer METAL8 -direction vertical -max_strap 14 -min_strap 2 -min_width 2 -max_width 4 -spacing 0.6
set_fp_rail_constraints  -set_ring -horizontal_ring_layer { METAL5 } -vertical_ring_layer { METAL6 } -ring_max_width 10 -ring_min_width 10 -extend_strap core_ring

synthesize_fp_rail  -nets {VDD VSS} -voltage_supply 1.32 -synthesize_power_plan -power_budget 350 -pad_masters { PVSS1W PVDD1W }

commit_fp_rail

save_mw_cel -as m4 

set_preroute_drc_strategy -min_layer METAL1 -max_layer METAL6
preroute_instances

#set_preroute_drc_strategy -min_layer METAL1 -max_layer METAL8
preroute_standard_cells -fill_empty_rows -remove_floating_pieces

#Analyze IR drop
analyze_fp_rail  -nets {VDD VSS} -voltage_supply 1.32 -power_budget 250 -pad_masters { PVSS1W PVDD1W }

save_mw_cel -as floorplan_pns

create_fp_placement -timing_driven -no_hierarchy_gravity

set_pnet_options -complete "METAL7 METAL8"
legalize_fp_placement

report_congestion -grc_based -by_layer -routing_stage global 

route_zrt_global
#Perform global route congestion map analysis from the GUI

verify_pg_nets

#Perform timing analysis
report_timing

report_constraint -all > report/all_vios.fp.rpt 

# Optional steps if there were timing violations:
#
# optimize_fp_timing -fix_design_rule
# route_zrt_global
# report_timing
# report_constraint -all > report/all_vios.fp.fix.rpt

save_mw_cel -as floorplan_complete

remove_placement -object_type standard_cell
write_def -placed -all_vias -blockages  -routed_nets -specialnets -rows_tracks_gcells -output results/des.def 

save_mw_cel -as ready_for_placement

##########Placement###########

check_physical_design -stage pre_place_opt
check_physical_constraints

set_separate_process_options -placement false

place_opt -area_recovery -power -congestion -effort high 

save_mw_cel -as des_place_opt

report_congestion -grc_based -by_layer -routing_stage global
report_design -physical
report_qor
report_power

report_constraint -all > report/all_vios.place.rpt

#psynopt -area_recovery -power

derive_pg_connection -power_net VDD -power_pin VDD -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VSS -ground_pin VSS -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VDD -ground_net VSS -tie


save_mw_cel -as des_placed

##########Clock Tree Synthesis##########

# Examine Clock Tree  

report_clock -skew -attributes
report_clock_tree -summary

remove_clock_tree
reset_design
# Preparing for Clock Tree Synthesis  

source ../input_data/prects.sdc 
set_clock_tree_options -max_tran  0.4 -clock_trees [all_clocks]
set_clock_tree_options -max_fanout 32 -clock_trees [all_clocks]
set_clock_tree_options -target_skew 0.02

set_clock_uncertainty 0.1 [all_clocks]

set_operating_conditions -analysis_type bc_wc \
	-max_library slow_1v08c125 -max slow_1v08c125 \
	-min_library fast_1v32cm40 -min fast_1v32cm40
set_tlu_plus_files \
	-max_tluplus $tlup_max \
	-min_tluplus $tlup_min \
	-tech2itf_map  $tlup_map

set_clock_tree_references -references {CLKBUFX2 CLKBUFX3 CLKBUFX4 CLKBUFX6 CLKBUFX8 CLKBUFX12 CLKBUFX16 CLKBUFX20}

define_routing_rule CLOCK_DOUBLE_SPACING -default_reference_rule -multiplier_spacing 2 
	
report_routing_rule CLOCK_DOUBLE_SPACING

set_clock_tree_options -routing_rule CLOCK_DOUBLE_SPACING \
	-layer_list {METAL3 METAL4 METAL5 METAL6 METAL7 METAL8} -use_default_routing_for_sinks 1

report_clock_tree -settings

check_physical_design -stage pre_clock_opt -display

check_clock_tree

# Perform Clock Tree Synthesis  

clock_opt -only_cts -no_clock_route

report_clock_tree -summary
report_clock_timing -type skew -significant_digits 4 

report_timing
report_constraint -all

report_clock_tree -all_drc_violators > report/drc.rpt

save_mw_cel -as clock_opt_cts

# Perform Hold Time Optimization  

source ../input_data/des_func.postCTS.sdc ;#Warning: No port objects matched 'clk' (SEL-004)

set_app_var timing_remove_clock_reconvergence_pessimism true 

report_qor

set_max_area 0
## Set Area Critical Range
## Typical value: 5 percent of critical clock period
set physopt_area_critical_range 0.5

extract_rc 
clock_opt -only_psyn -area_recovery -no_clock_route -power
route_zrt_group -all_clock_nets -reuse_existing_global_route true -stop_after_global_route true
extract_rc

report_qor
report_constraint -all > report/all_vios.cts.rpt

optimize_clock_tree -buffer_sizing -buffer_relocation -operating_condition min_max -routed_clock_stage global
psynopt -only_design_rule
report_constraint -all > report/all_vios.ctspsyn.rpt

save_mw_cel -as clock_opt_psyn

# Route the Clocks  

set_si_options -delta_delay true  \
               -route_xtalk_prevention true \
               -route_xtalk_prevention_threshold 0.25

set_si_options -min_delta_delay true 

set_route_mode_options -zroute true

route_zrt_group -all_clock_nets -reuse_existing_global_route true 

report_constraint -all > report/all_vios.ctsroute.rpt

derive_pg_connection -power_net VDD -power_pin VDD -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VSS -ground_pin VSS -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VDD -ground_net VSS -tie

report_design -physical

save_mw_cel -as clock_opt_route

##########Route##########

source ../scripts/common_route_si_settings_zrt_icc.tcl

report_preferred_routing_direction
report_tlu_plus_files

set_route_zrt_common_options -post_detail_route_redundant_via_insertion high
set_route_zrt_common_options -concurrent_redundant_via_mode reserve_space
set_route_zrt_common_options -concurrent_redundant_via_effort_level high

report_routing_rules; # report routing rules
report_route_opt_strategy; # report route_opt_stretegy
report_route_zrt_common_options; # Reports zrt common route options
report_route_zrt_global_options; # Reports zrt global route options
report_route_zrt_track_options; # Reports zrt route track assignment options
report_route_zrt_detail_options; # Reports zrt detail route options

route_opt -initial_route_only
report_constraint -all_violators > ./report/allvios.route.tcl

report_clock_tree -summary
report_clock_timing -type skew
report_qor
report_constraint -all

update_timing

route_opt -skip_initial_route -power -area -effort high -xtalk_reduction
report_constraint -all > ./report/all_vios.routeopt.rpt

derive_pg_connection -power_net VDD -power_pin VDD -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VSS -ground_pin VSS -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VDD -ground_net VSS -tie

report_design -physical

save_mw_cel -as clock_opt_route

#spread & widen wires
spread_zrt_wires
widen_zrt_wires

verify_pg_nets
verify_zrt_route
verify_lvs

report_design_physical -route

save_mw_cel -as route_opt_final

##########Chip Finishing##########

# in new icc_shell

set DATA_DIR results/v1
sh mkdir -p  $DATA_DIR
set from_mw_cel route_opt_final
set from_mw_lib $my_mw_lib

sh rm -rf  $DATA_DIR/$my_mw_lib 
create_mw_lib $DATA_DIR/$my_mw_lib -open -technology $tech_file \
	-mw_reference_library "/home/ichip/project/chip/ref/mw_lib/sc/smic13g /home/ichip/project/chip/ref/mw_lib/io/SP013W_V1p0_8MT" ;#ERROR

copy_mw_cel -from_lib $from_mw_lib -to_lib $DATA_DIR/$my_mw_lib -from $from_mw_cel -to $top_design

list_mw_cels
set_tlu_plus_files \
	-max_tluplus $tlup_max \
	-min_tluplus $tlup_min \
	-tech2itf_map  $tlup_map
open_mw_cel $top_design 

set RESULTS_DIR $DATA_DIR

#Outputs Script

set enable_page_mode false
change_names -rules verilog -hierarchy
save_mw_cel

derive_pg_connection -power_net VDD -power_pin VDD -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VSS -ground_pin VSS -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VDD -ground_net VSS -tie

write_verilog -no_physical_only_cells -supply_statement none $RESULTS_DIR/des.output.pt.v

write_def -output  $RESULTS_DIR/des.output.def

#insert filler

remove_stdcell_filler -stdcell

set fillers "FILL64 FILL32 FILL16 FILL8 FILL4 FILL2 FILL1"

insert_stdcell_filler -respect_keepout -connect_to_power VDD -connect_to_ground VSS -cell_with_metal $fillers 

derive_pg_connection -power_net VDD -power_pin VDD -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VSS -ground_pin VSS -cells [get_flat_cells *] -reconnect
derive_pg_connection -ground_net VDD -ground_net VSS -tie

#for LVS use

save_mw_cel -as bak 
remove_cell *FILL* 
remove_cell *filler*
remove_cell *corner*
##########################################################
################# don't touch it !!!!!! ##################
##########################################################
write_verilog -diode_ports -pg /home/ichip/project/chip/icc/des.output.pg.lvs.filler.v 
########################################################## 
close_mw_cel
copy_mw_cel -from bak -to $top_design
open_mw_cel $top_design
remove_mw_cel bak

#timing driven metal fill
#
#source ../scripts/common_route_si_settings_zrt_icc.tcl
#
#set_ignored_layers -min_routing_layer METAL1 -max_routing_layer METAL8
#
#insert_metal_filler -routing_space 9 \
#	-timing_driven -from_metal 1 -to_metal 8 \
#	-stagger {m1 m2 m3 m4 m5 m6 m7 m8} \
#	-width {m1 0.3 m2 0.3 m3 0.3 m4 0.3 m5 0.3 m6 0.3 m7 0.3 m8 0.3 } \
#	-min_length {m1 0.5 m2 0.5 m3 0.5 m4 0.5 m5 0.5 m6 0.5 m7 0.5 m8 0.5 } \
#	-max_length {m1 1 m2 2 m3 2 m4 2 m5 2 m6 2  m7 2 m8 2}
#
#slot_wire -nets {VDD VSS} -cutwidth {METAL2 10} -cutlength {METAL2 20} \
#	-width {METAL2 2} -length {METAL2 4}

foreach_in_collection port [get_ports *] {
	set name [get_attri $port full_name]
	set center [get_attri $port center]
	set layer [get_attri $port layer]
	create_text -origin $center -layer $layer -height 1 $name
	
}
#set key_sel_0_x [lindex [ get_attribute key_sel[0] center ] 0 ]
#set key_sel_0_y [lindex [ get_attribute key_sel[0] center ] 1 ]
#set key_sel_1_x [lindex [ get_attribute key_sel[1] center ] 0 ]
#set key_sel_1_y [lindex [ get_attribute key_sel[1] center ] 1 ]
#set vss1left_x $key_sel_0_x
#set vss1left_y [ expr 2 * $key_sel_0_y - $key_sel_1_y ]
#set vdd1left_x $key_sel_0_x
#set vdd1left_y [ expr 2 * $vss1left_y - $key_sel_0_y ]
#create_text -origin " $vdd1left_x $vdd1left_y " -layer METAL8 -height 1 VDD
#create_text -origin " $vss1left_x $vss1left_y " -layer METAL8 -height 1 VSS

#GDSII

set_write_stream_options \
	-child_depth 255 \
	-map_layer /home/ichip/project/chip/ref/mw_lib/sc/gds2OutLayer.map \
      	-output_filling fill \
       	-output_outdated_fill \
       	-keep_data_type \
	-max_name_length 255 \
	-output_net_name_as_property 1 \
	-output_instance_name_as_property 1 \
	-output_pin {geometry text} \
	-output_polygon_pin \
	-output_design_intent 

write_stream -cells $top_design -format gds $RESULTS_DIR/$top_design.gds
  
